"""Checks of the CI selection: changed inputs, fallbacks and exact shards."""

import unittest

import ci_select
import suite_results

ROOT = suite_results.ROOT


class ChangedInputs(unittest.TestCase):
    def setUp(self):
        self.tests = ci_select.tagged()
        self.canary = [ROOT / name for name in ci_select.CANARY]
        # A tagged check with a declared helper shared by several tests.
        self.helper = "tests/u12/helpers112_unpack/payload_unpack112.svh"
        self.users = [t for t in self.tests
                      if ROOT / self.helper in suite_results.input_files(t)]

    def test_canary_is_a_tagged_check(self):
        for path in self.canary:
            self.assertIn(path, self.tests)

    def test_unrelated_change_runs_only_the_canary_without_warning(self):
        self.assertEqual(ci_select.plan(self.tests, {"README.md", "docs/faq.md"}),
                         (self.canary, None))

    def test_changed_expectation_selects_its_test(self):
        test = next(t for t in self.tests if t not in self.canary)
        expected = sorted(p for p in suite_results.input_files(test) if p.suffix == ".expected")
        self.assertTrue(expected)
        selected, reason = ci_select.plan(self.tests, {ci_select.relative(expected[0])})
        self.assertIsNone(reason)
        self.assertIn(test, selected)
        self.assertTrue(set(self.canary) <= set(selected))

    def test_changed_helper_selects_every_tagged_user(self):
        self.assertTrue(self.users)
        selected, reason = ci_select.plan(self.tests, {self.helper})
        self.assertIsNone(reason)
        self.assertTrue(set(self.users) <= set(selected))

    def test_global_change_and_unknown_base_fall_back_to_the_canary(self):
        for changed in ({"tools/suite_results.py"}, {"third_party/uvm.lock"}, None):
            selected, reason = ci_select.plan(self.tests, changed)
            self.assertEqual(selected, self.canary)
            self.assertTrue(reason)
        self.assertIsNone(ci_select.changed_paths("0" * 40))
        self.assertIsNone(ci_select.changed_paths(""))

    def test_too_many_affected_checks_fall_back_to_the_canary(self):
        selected, reason = ci_select.plan(self.tests, {self.helper}, limit=len(self.users) - 1)
        self.assertEqual(selected, self.canary)
        self.assertIn(str(len(self.users)), reason)


class Shards(unittest.TestCase):
    def test_shards_cover_the_selection_exactly_once(self):
        tests = ci_select.tagged()
        parts = [ci_select.shard(tests, i, 20) for i in range(20)]
        flat = [t for part in parts for t in part]
        self.assertEqual(len(flat), len(set(flat)))
        self.assertEqual(set(flat), set(tests))

    def test_out_of_range_or_empty_shard_is_rejected(self):
        with self.assertRaises(ValueError):
            ci_select.shard(["a"], 1, 1)
        with self.assertRaises(ValueError):
            ci_select.shard(["a"], 1, 2)



class Directories(unittest.TestCase):
    def setUp(self):
        self.tests = ci_select.tagged()

    def test_a_directory_selects_its_tests_and_the_users_of_its_helpers(self):
        helper = ROOT / "tests/u19/helpers116_rtl/rf_env116.svh"
        users = [t for t in self.tests if helper in suite_results.input_files(t)]
        outside = [t for t in users if t.parent.name != "u19"]
        self.assertTrue(outside)
        selected = ci_select.in_directories(self.tests, ["u19"])
        self.assertTrue(set(users) <= set(selected))
        own = [t for t in self.tests if t.parent.name == "u19"]
        self.assertTrue(set(own) <= set(selected))
        self.assertFalse(any(t.parent.name == "u05" for t in selected))

    def test_unknown_directories_are_rejected(self):
        for name in ("u99", "../tools", "u05/helpers"):
            with self.assertRaises(ValueError):
                ci_select.in_directories(self.tests, [name])

    def test_shard_count_follows_the_narrowed_size(self):
        self.assertEqual(ci_select.shard_count(2293, False), ci_select.SHARDS)
        self.assertEqual(ci_select.shard_count(6, True), 1)
        self.assertEqual(ci_select.shard_count(ci_select.SHARD_SIZE + 1, True), 2)
        self.assertEqual(ci_select.shard_count(10 ** 6, True), ci_select.SHARDS)
        self.assertEqual(ci_select.shard_count(0, True), 0)

    def test_the_plan_narrows_every_job(self):
        whole = ci_select.regression_plan([])
        self.assertEqual(whole["count"], str(ci_select.SHARDS))
        self.assertEqual((whole["cmdline"], whole["cmdline_tests"]), ("true", ""))
        self.assertEqual((whole["regex"], whole["regex_tests"]), ("true", ""))
        narrow = ci_select.regression_plan(["u17"])
        self.assertEqual(narrow["shards"], "[0]")
        self.assertEqual((narrow["cmdline"], narrow["regex"]), ("false", "false"))
        uc = ci_select.regression_plan(["uC"])
        self.assertEqual(uc["cmdline"], "true")
        self.assertTrue(all(name.startswith("tests/") for name in uc["cmdline_tests"].split()))


if __name__ == "__main__":
    unittest.main()
