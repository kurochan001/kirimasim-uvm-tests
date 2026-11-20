"""Checks of tools/full_output.py that need no simulator."""

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
