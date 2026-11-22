"""Checks of tools/full_output.py that need no simulator."""

import contextlib
import io
import json
from pathlib import Path
import subprocess
import tempfile
import types
import unittest

import full_output


class FullOutput(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        self.root = Path(temp.name).resolve()

    def capture(self, name, outputs, simulator="verilator"):
        out = self.root / name
        full_output.write_capture(out, simulator, "Sim 1.0", 1, "abc", outputs,
                                  {n: "match" for n in outputs})
        return out

    def test_place_and_run_lines_are_normalized(self):
        text = (f"UVM_INFO {self.root}/third_party/x.svh(3) @ 0: r [ID] text\n"
                "- Verilator: $finish at 55ns; walltime 0.001 s\n"
                "wrote /tmp/tmpabc123/obj/log.txt\nUT: one\n")
        got = full_output.normalize(text, "verilator", self.root)
        self.assertEqual(got, "UVM_INFO <root>/third_party/x.svh(3) @ 0: r [ID] text\n"
                              "wrote <tmp>\nUT: one\n")
        self.assertIn("- Verilator", full_output.normalize(text, "kirimasim", self.root))

    def test_compare_separates_differences_in_and_outside_the_observed_lines(self):
        base = self.capture("base", {"u05/test_a": "UVM_INFO x\nUT: 1\n",
                                     "u05/test_b": "banner\nUT: 1\n",
                                     "u05/test_c": "UT: 1\n", "u05/test_d": "UT: 1\n"})
        other = self.capture("other", {"u05/test_a": "UVM_INFO x\nUT: 1\n",
                                       "u05/test_b": "other banner\nUT: 1\n",
                                       "u05/test_c": "UT: 2\n", "u05/test_e": "UT: 1\n"},
                             simulator="kirimasim")
        result = full_output.compare(base, other)
        self.assertEqual(result["counts"], {
            "differs in UT lines": 1, "differs outside UT lines": 1, "identical": 1,
            "missing in base": 1, "missing in other": 1})
        self.assertEqual(result["tests"]["u05/test_b"]["first"],
                         {"line": 1, "base": "banner", "other": "other banner"})
        self.assertEqual(result["other"]["simulator"], "kirimasim")

    def test_a_longer_output_differs_at_its_first_extra_line(self):
        self.assertEqual(full_output.first_difference("a\n", "a\nb\n"),
                         {"line": 2, "base": None, "other": "b"})
        self.assertEqual(full_output.first_difference("a\nlong line\n", "a\n"),
                         {"line": 2, "base": "long line", "other": None})
        self.assertEqual(full_output.first_difference("x" * 300, "")["base"], "x" * 200)

    def test_the_index_lists_the_digest_and_the_status_of_each_output(self):
        out = self.root / "cap"
        full_output.write_capture(out, "verilator", "Sim 1.0", 73, "sha",
                                  {"u05/test_a": "UT: 1\nUT: 2\n"},
                                  {"u05/test_a": "match", "u05/test_b": "seed 1"})
        index = json.loads((out / "index.json").read_text())
        self.assertEqual(index["seed"], 73)
        self.assertEqual(index["runner_sha256"], "sha")
        self.assertEqual(index["tests"]["u05/test_a"],
                         {"sha256": full_output.digest("UT: 1\nUT: 2\n"), "lines": 2,
                          "status": "match"})
        self.assertEqual(index["without_output"], ["u05/test_b"])
        self.assertEqual((out / "u05/test_a.txt").read_text(), "UT: 1\nUT: 2\n")

    def test_the_command_reports_only_the_differences_and_their_total(self):
        base = self.capture("base", {"u05/test_a": "UT: 1\n", "u05/test_c": "UT: 1\n"})
        other = self.capture("other", {"u05/test_a": "UT: 1\n", "u05/test_c": "UT: 2\n"})
        out = self.root / "cmp.json"
        stream = io.StringIO()
        with contextlib.redirect_stdout(stream):
            self.assertEqual(full_output.main(["compare", str(base), str(other),
                                               "--json", str(out)]), 0)
        printed = stream.getvalue()
        self.assertNotIn("u05/test_a", printed)
        self.assertIn("differs in UT lines: u05/test_c (line 1)", printed)
        self.assertIn("1 differs in UT lines, 1 identical", printed)
        self.assertEqual(json.loads(out.read_text())["counts"],
                         {"identical": 1, "differs in UT lines": 1})

    def test_the_command_fails_only_when_a_directory_is_not_a_capture(self):
        base = self.capture("base", {"u05/test_a": "UT: 1\n"})
        stream = io.StringIO()
        with contextlib.redirect_stderr(stream):
            self.assertEqual(full_output.main(["compare", str(self.root / "absent"),
                                               str(base)]), 1)
        self.assertIn("not a capture", stream.getvalue())
        other = self.capture("empty", {})
        self.capture("empty2", {})
        stream = io.StringIO()
        with contextlib.redirect_stdout(stream):
            self.assertEqual(full_output.main(["compare", str(self.root / "empty2"),
                                               str(other)]), 0)
        self.assertIn("no test in either capture", stream.getvalue())

    def test_capturing_kirimasim_needs_the_simulator_to_be_findable(self):
        stream = io.StringIO()
        with contextlib.redirect_stderr(stream):
            self.assertEqual(full_output.main(
                ["capture", "--simulator", "kirimasim", "--output", str(self.root / "o"),
                 "--kirimasim", "no-such-kirimasim-4f2a"]), 1)
        self.assertIn("cannot find", stream.getvalue())

    def test_a_directory_without_an_index_is_not_a_capture(self):
        with self.assertRaisesRegex(ValueError, "not a capture"):
            full_output.load_capture(self.root)
        (self.root / "index.json").write_text(json.dumps({"kind": "other"}))
        with self.assertRaisesRegex(ValueError, "not a capture"):
            full_output.load_capture(self.root)

    def test_the_recorder_keeps_only_simulation_output_and_restores_the_module(self):
        calls = []

        def fake_run(command, *args, **kwargs):
            calls.append(command[0])
            return subprocess.CompletedProcess(command, 0, f"out of {command[0]}\n", "")
        module = types.SimpleNamespace(subprocess=types.SimpleNamespace(run=fake_run, PIPE=-1))
        original = module.subprocess
        with full_output.Recorder(module, lambda c: c[0] == "model") as recorder:
            self.assertEqual(module.subprocess.PIPE, -1)
            _, got = recorder.collect(lambda: [module.subprocess.run(["build"]),
                                               module.subprocess.run(["model"])])
            module.subprocess.run(["model"])   # outside collect: not kept
        self.assertEqual(got, ["out of model\n"])
        self.assertEqual(calls, ["build", "model", "model"])
        self.assertIs(module.subprocess, original)


if __name__ == "__main__":
    unittest.main()
