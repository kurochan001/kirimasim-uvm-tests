"""Regression checks for draft scope, explicit mappings and stale bindings."""

import contextlib
import copy
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest import mock

import requirements
import suite_results


class RequirementLedger(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        self.root = Path(temp.name).resolve()
        for folder in ('coverage', 'tools', 'third_party'):
            (self.root / folder).mkdir()
        (self.root / 'third_party/uvm.lock').write_text('fixture-lock\n')
        (self.root / 'tools/clauses_1800_2.txt').write_text('5\n5.1\n5.2\n6\n6.1\nH\nH.1\n')
        for module in (requirements, suite_results):
            patch = mock.patch.object(module, 'ROOT', self.root)
            patch.start()
            self.addCleanup(patch.stop)
        self.first = self.make('u05/test_first', '5.1 5.2')
        self.second = self.make('u06/test_second', '6.1')
        self.text = {'en': 'Fixture obligation.', 'ja': '検査用の義務。'}
        self.scope = dict(schema_version=1, standard=requirements.STANDARD, status='proposed',
                          normative_inventory_complete=False, approved_denominator=None,
                          counting_unit=self.text, candidate_roots=['5', '6'], context_roots=[],
                          deferred_roots={'H': self.text}, legacy_clause_target=2)
        self.entry = dict(id='UVM-FIXTURE', clause='5.2', statement=self.text,
                          conditions=self.text, expected=self.text, limitations=self.text,
                          review=dict(status='ai', reviewer=None, reviewed_at=None),
                          test_links=[dict(test='u05/test_first', role='direct',
                                           expected_observations=['UT: expected'])])
        self.write('scope.json', self.scope)
        self.write('requirements.json', dict(schema_version=1, standard=requirements.STANDARD,
                                             status='partial', requirements=[self.entry]))
        self.write('test_index.json', dict(schema_version=1, standard=requirements.STANDARD,
                                          tests={suite_results.test_id(p): {
                                              'primary_clause': c,
                                              'inputs_sha256': suite_results.input_digest(p)}
                                              for p, c in ((self.first, '5.1'), (self.second, '6.1'))}))

    def make(self, name, clauses):
        path = self.root / 'tests' / (name + '.sv')
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text('/*\n:lrm: 1800.2-2020 ' + clauses + '\n:spec_check: ai\n'
                        ':oracle: spec\n:files: helper.svh\n'
                        ':expected_stdout: @' + path.stem + '.expected\n*/\n')
        path.with_suffix('.expected').write_text('UT: expected\n')
        (path.parent / 'helper.svh').write_text('// original helper\n')
        return path

    def write(self, name, value):
        requirements.write_json(self.root / 'coverage' / name, value)

    def data(self):
        return requirements.load(self.root)

    def test_supporting_citation_needs_explicit_mapping_and_does_not_roll_up(self):
        report = requirements.inventory(self.data())
        clauses = {c['clause']: c for c in report['clauses']}
        self.assertEqual(clauses['5.2']['requirement_ids'], ['UVM-FIXTURE'])
        self.assertEqual(clauses['5.2']['primary_tests'], [])
        self.assertEqual(clauses['5.1']['requirement_ids'], [])
        self.assertEqual(clauses['5']['decomposition'], 'unassessed')
        self.assertEqual(report['summary']['referenced_identifiers'], 3)
        self.assertEqual(report['summary']['tests_without_requirement_links'], 1)
        self.assertIsNone(report['approved_denominator'])
        self.assertIsNone(report['coverage_percentage'])

    def test_control_does_not_supply_a_direct_requirement_link(self):
        data = self.data()
        data['ledger']['requirements'][0]['test_links'][0]['role'] = 'control'
        summary = requirements.inventory(data)['summary']
        self.assertEqual(summary['requirements_with_direct_tests'], 0)
        self.assertEqual(summary['requirements_without_direct_tests'], 1)
        self.assertEqual(summary['tests_with_control_links'], 1)
        self.assertEqual(summary['tests_with_direct_links'], 0)

    def test_unknown_metadata_clause_is_rejected(self):
        self.first.write_text(self.first.read_text().replace('5.2', '5.99'))
        with self.assertRaisesRegex(requirements.LedgerError, 'unknown UVM clause'):
            self.data()

    def test_direct_mapping_requires_the_specific_clause(self):
        data = self.data()
        data['ledger']['requirements'][0]['clause'] = '6.1'
        with self.assertRaisesRegex(requirements.LedgerError, 'does not cite'):
            requirements.validate(data)

    def test_unknown_test_link_is_rejected(self):
        data = self.data()
        data['ledger']['requirements'][0]['test_links'][0]['test'] = 'u05/test_missing'
        with self.assertRaisesRegex(requirements.LedgerError, 'unknown test'):
            requirements.validate(data)

    def test_observation_must_exist_and_be_distinct_and_nonempty(self):
        for anchors in ([], ['UT: absent'], ['plain'], ['UT: expected'] * 2, [1]):
            with self.subTest(anchors=anchors):
                data = self.data()
                data['ledger']['requirements'][0]['test_links'][0]['expected_observations'] = anchors
                with self.assertRaises(requirements.LedgerError):
                    requirements.validate(data)

    def test_duplicate_requirement_ids_are_rejected(self):
        data = self.data()
        data['ledger']['requirements'].append(copy.deepcopy(data['ledger']['requirements'][0]))
        with self.assertRaisesRegex(requirements.LedgerError, 'duplicate requirement ID'):
            requirements.validate(data)

    def test_duplicate_json_keys_are_not_silently_overwritten(self):
        path = self.root / 'coverage/scope.json'
        path.write_text('{"status":"proposed","status":"approved"}')
        with self.assertRaisesRegex(requirements.LedgerError, 'duplicate JSON key'):
            self.data()

    def test_bilingual_requirement_fields_are_mandatory(self):
        for field in ('statement', 'conditions', 'expected', 'limitations'):
            data = self.data()
            data['ledger']['requirements'][0][field] = {'en': 'Only English'}
            with self.subTest(field=field), self.assertRaises(requirements.LedgerError):
                requirements.validate(data)

    def test_scope_roots_must_have_one_disposition(self):
        for roots in (['5'], ['5', '6', 'H'], ['5', '6', '99'], ['5', '6', '6']):
            data = self.data()
            data['scope']['candidate_roots'] = roots
            with self.subTest(roots=roots), self.assertRaises(requirements.LedgerError):
                requirements.validate(data)

    def test_schema_one_cannot_claim_an_approved_denominator(self):
        for field, value in (('approved_denominator', 36), ('status', 'approved'),
                             ('normative_inventory_complete', True)):
            data = self.data()
            data['scope'][field] = value
            with self.subTest(field=field), self.assertRaisesRegex(requirements.LedgerError,
                                                                  'unapproved, incomplete'):
                requirements.validate(data)

    def test_human_review_requires_identity_and_a_valid_date(self):
        data = self.data()
        review = data['ledger']['requirements'][0]['review']
        review['status'] = 'human'
        for reviewer, date in ((None, None), ('reviewer', '2026-02-30'), ('reviewer', None)):
            review.update(reviewer=reviewer, reviewed_at=date)
            with self.subTest(reviewer=reviewer, date=date), self.assertRaises(requirements.LedgerError):
                requirements.validate(data)
        review.update(reviewer='fixture reviewer', reviewed_at='2026-11-01')
        requirements.validate(data)
        review['status'] = 'ai'
        with self.assertRaisesRegex(requirements.LedgerError, 'non-human'):
            requirements.validate(data)

    def test_expected_helper_and_lock_changes_invalidate_bindings(self):
        for path in (self.first.with_suffix('.expected'), self.first.parent / 'helper.svh',
                     self.root / 'third_party/uvm.lock'):
            original = path.read_text()
            path.write_text(original + '// changed\n')
            with self.subTest(path=path.name), self.assertRaisesRegex(requirements.LedgerError, 'stale index'):
                requirements.validate(self.data())
            path.write_text(original)

    def test_index_cannot_hide_missing_or_removed_tests(self):
        for operation in ('missing', 'removed'):
            data = self.data()
            tests = data['index']['tests']
            if operation == 'missing':
                del tests['u06/test_second']
            else:
                tests['u06/test_removed'] = dict(tests['u06/test_second'])
            with self.subTest(operation=operation), self.assertRaisesRegex(requirements.LedgerError,
                                                                          'review a sync proposal'):
                requirements.validate(data)

    def test_sync_preserves_stale_linked_bindings_but_refreshes_unlinked(self):
        old = self.data()['index']['tests']
        for test in (self.first, self.second):
            test.with_suffix('.expected').write_text('UT: expected\nUT: additional\n')
        third = self.make('u06/test_third', '6.1')
        data = self.data()
        proposal = requirements.sync_proposal(data)
        self.assertEqual(proposal['tests']['u05/test_first'], old['u05/test_first'])
        self.assertNotEqual(proposal['tests']['u06/test_second'], old['u06/test_second'])
        self.assertEqual(proposal['tests']['u06/test_third']['inputs_sha256'],
                         suite_results.input_digest(third))
        data['index'] = proposal
        with self.assertRaisesRegex(requirements.LedgerError, 'stale index'):
            requirements.validate(data)

    def test_deleted_linked_test_must_be_reassessed_before_sync(self):
        self.first.unlink()
        with self.assertRaisesRegex(requirements.LedgerError, 'unknown test'):
            requirements.sync_proposal(self.data())

    def test_generated_files_cannot_overwrite_any_ledger_input(self):
        for command, option in (('sync', '--output'), ('inventory', '--json')):
            for name in ('scope.json', 'requirements.json', 'test_index.json'):
                path = self.root / 'coverage' / name
                original = path.read_bytes()
                with self.subTest(command=command, name=name), contextlib.redirect_stderr(io.StringIO()):
                    with self.assertRaises(SystemExit) as caught:
                        requirements.main([command, option, str(path)])
                    self.assertEqual(caught.exception.code, 2)
                self.assertEqual(path.read_bytes(), original)

    def test_cli_writes_a_machine_readable_partial_inventory(self):
        path = self.root / 'out/report.json'
        with contextlib.redirect_stdout(io.StringIO()) as output:
            self.assertEqual(requirements.main(['inventory', '--json', str(path), '--lang', 'ja']), 0)
        self.assertIn('未設定', output.getvalue())
        report = json.loads(path.read_text())
        self.assertEqual(report['summary']['draft_requirements'], 1)
        self.assertFalse(report['normative_inventory_complete'])
        self.assertIsNone(report['coverage_percentage'])

    def test_extra_schema_fields_and_unknown_requirement_clauses_are_rejected(self):
        for kind in ('extra', 'clause'):
            data = self.data()
            entry = data['ledger']['requirements'][0]
            if kind == 'extra':
                entry['coverage_percentage'] = 100
            else:
                entry['clause'] = '5.99'
            with self.subTest(kind=kind), self.assertRaises(requirements.LedgerError):
                requirements.validate(data)

    def test_two_requirements_from_one_clause_do_not_duplicate_test_counts(self):
        data = self.data()
        second = copy.deepcopy(data['ledger']['requirements'][0])
        second['id'] = 'UVM-SECOND'
        data['ledger']['requirements'].append(second)
        summary = requirements.inventory(data)['summary']
        self.assertEqual(summary['requirements_with_direct_tests'], 2)
        self.assertEqual(summary['tests_with_direct_links'], 1)
        self.assertEqual(summary['primary_focus_identifiers'], 2)


if __name__ == '__main__':
    unittest.main()
