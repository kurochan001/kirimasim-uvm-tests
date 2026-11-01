# Draft requirement ledger and coverage inventory

[日本語](requirements.ja.md) · [README](../README.md) · [Testing guide](testing.md)

## Current state

M4 is in progress. The [scope proposal](../coverage/scope.json),
[requirement ledger](../coverage/requirements.json) and
[test index](../coverage/test_index.json) are versioned inputs. The ledger
contains 376 AI-drafted requirements: 361 link directly to 417 tests and 15
have no direct test. One additional test is a control. The other 407 of the 825 tests have
not yet been mapped at requirement level; that does not mean they test no
normative behavior. No requirement records human review.

The clause catalog has 2,504 identifiers. 274 have a partial
requirement decomposition; the other 2,230 are unassessed. Neither group is
complete. Starting M4 does not approve the scope or denominator, or complete
M1–M3. `approved_denominator` and `coverage_percentage` remain `null`.

## Counting unit and scope proposal

The proposed unit is one observable normative obligation together with its
applicability conditions. A method clause may need separate requirements for
success, failure, default arguments, ordering and side effects. Conversely,
a heading is not an obligation. The 376 draft entries span several areas,
without exhausting the obligations in their clauses.

The proposal assigns every root in the existing identifier catalog once:

| Disposition | Roots | Identifier count | Meaning |
| --- | --- | --- | --- |
| Candidate | 5–19, B–G | 2,479 | Examine normative behavior for requirement decomposition |
| Context | 1–4 | 16 | Scope, references, definitions and acronyms; still inform interpretation |
| Deferred | H | 9 | Deprecated APIs await a separate scope decision; no approved exclusion |

These are identifier counts, not requirement counts. Annex A is informative
and absent from this catalog. This census does not independently certify the
catalog's completeness. Normative/non-normative distinctions still require
reading the standard. Library omissions, known differences, unimplemented
HDL/DPI support and backend availability do not silently remove candidate
obligations. SystemVerilog language requirements belong to kirimasim-tests;
UVM requirements that depend on language or HDL facilities remain candidates.

All decomposition uses the user-provided IEEE 1800.2-2020 standard. Statements
are original English/Japanese paraphrases with clause references, not copied
standard text or implementation-derived expectations. Commercial simulator
results remain excluded under the [posting policy](faq.md#commercial-simulator-and-issue-reporting-policy).
The ledger tool consumes no simulator results.

## Citations, requirements and execution evidence

A test's first UVM `:lrm:` reference is its **primary focus**; later UVM
references are **supporting citations**. Of the catalog identifiers, 363
have a primary-focus test and 840 have either kind of citation. Supporting
references often describe setup APIs. No reference creates a requirement link,
and a child-clause reference is not automatically rolled up to its parent.

For the 2,479 candidate identifiers, the historical two-tests-per-clause
census currently shows 2,116 with zero primary-focus tests, 159 with one,
and 204 with at least two. It measures test placement only. It does not
establish that an identifier has two independent checks, that its normative
obligations are decomposed, or that either test passes. It is not an approved
requirement denominator or a declaration that all zero-focus clauses are gaps.

Requirement IDs such as `UVM-CLONE-DISTINCT` are stable names independent of
test filenames. Two clone requirements can share clause 5.3.5.2 while checking
distinct-handle creation and subsequent scalar independence separately.
The callback requirement `UVM-VREG-FIELD-POST-WRITE-ORDER` links the standalone
field test directly and a parent-register write test as a control. A control
helps assess the fixture but does not supply a direct link for the requirement.

Each link names exact `UT: ` lines from the generic expected output. These
**expected observations** bind the mapping to an oracle, not to an observed
pass. An anchored line can also contain observations for other obligations;
it does not make this requirement cover all of them. The checker verifies
references, fields, anchor membership and input identities. It cannot prove
that the test actually exercises the requirement or that its assertion is
sufficient. That needs review of the test, fixture and standard. Ordering in
an oracle remains a runner check; the ledger's anchor-membership check alone
does not establish ordering or repetition counts. Repeated identical expected
lines are anchored once; the runner still compares the complete expected sequence.

[Execution evidence](results.md) is separate and needs matching input, runner,
library and configuration identities. A direct link may retain a spec-only
known difference. It is not a pass or a conformance claim. The current 825-test
snapshot includes newly measured fixtures; mapping existing FIFO tests adds no
new execution result for them.

## Versioned data and generated inventory

All JSON uses UTF-8 and schema version 1. Unknown fields, duplicate keys,
duplicate requirement IDs and unknown clauses/tests are rejected.

- `coverage/scope.json` records the bilingual counting unit, root dispositions
  and historical primary-focus target. Schema 1 permits only a proposed,
  incomplete scope with no approved denominator.
- `coverage/requirements.json` records each stable ID, clause, bilingual
  `statement`, `conditions`, `expected` and `limitations`, `review`, and
  `test_links`. A link has a test ID, `direct` or `control` role and nonempty
  `expected_observations`. A direct test must cite the requirement clause;
  a supporting citation is allowed when review establishes the actual link.
- `coverage/test_index.json` snapshots every current test's `primary_clause`
  and `inputs_sha256`. The fingerprint uses the existing runner collector:
  source, declared helpers/includes/data, expected files and UVM lock. The
  index is an inventory, not 825 reviewed requirement mappings.

Review status is `ai`, `unreviewed` or `human`. Human status requires an
identified `reviewer` and ISO date in `reviewed_at`; other statuses must leave
both fields `null`. These fields record a review claim; the checker cannot
authenticate the reviewer. Changing a requirement does not automatically
establish renewed human review.

Run from the repository root:

```sh
python3 tools/requirements.py check
python3 tools/requirements.py inventory --json out/requirements-inventory.json --lang ja
python3 tools/requirements.py sync --output out/test-index-proposal.json
```

`check` validates the canonical inputs and prints a summary. `inventory` also
writes all identifier dispositions, decomposition states, primary/supporting
citations, requirement links, review/oracle metadata, fingerprints and root totals. A
clause with entries is `partial`; one without entries is `unassessed`. Neither
state means complete or covered. Generated denominator and percentage fields
remain `null`. `--lang en` or `--lang ja` selects summary language; JSON keys
and stable identifiers do not change. Generated files under `out/` are ignored
by Git, and no generated output may overwrite the three canonical inputs.

## Review work queue and root totals

Use `backlog` to extract work items without editing the ledger:

```sh
python3 tools/requirements.py backlog --json out/requirements-backlog.json --lang ja
python3 tools/requirements.py backlog --root E --json out/requirements-backlog-E.json --lang ja
```

`--root` accepts an exact catalog root such as `5`, `17` or `E`, only with
`backlog`. Unknown roots, subclauses and directory labels such as `u05` are
rejected. Validation of the whole canonical ledger/index precedes extraction;
a root filter cannot hide a stale binding elsewhere.

The JSON separates `requirements_without_direct_tests` (full bilingual draft
records, including control-only requirements), `tests_without_requirement_links`
(test metadata and fingerprints without either link role), and
`unassessed_identifiers` (catalog identifiers with no requirement entry).
These are review queues, not established conformance gaps. Context/deferred
identifiers remain visible with their disposition, and all denominator and
percentage fields remain unset.

`inventory` and `backlog` include `roots` totals. Requirements belong to their
own clause root; tests belong to their primary-focus root. Thus chapter 17
requirements can link to tests placed under annex E without moving those
tests into chapter 17's primary count. Counts are not rolled up from children
to certify a parent requirement. Multiple requirements can share a test, and
one requirement can have multiple test links; neither implies independent
coverage from every anchor in a shared expected-output line.

Every existing primary-focus test in these fifteen roots now has a requirement
link, while normative decomposition remains partial:

| Root | Draft requirements | Primary-focus tests | Tests without links | Unassessed identifiers |
| --- | --- | --- | --- | --- |
| 5 | 44 | 42 | 0 | 82 |
| 6 | 34 | 28 | 0 | 87 |
| 7 | 3 | 2 | 0 | 67 |
| 8 | 23 | 32 | 0 | 52 |
| 9 | 25 | 19 | 0 | 97 |
| 10 | 29 | 36 | 0 | 99 |
| 11 | 3 | 2 | 0 | 29 |
| 13 | 4 | 2 | 0 | 108 |
| 16 | 76 | 80 | 0 | 145 |
| B | 36 | 54 | 0 | 110 |
| C | 9 | 16 | 0 | 80 |
| D | 6 | 6 | 0 | 40 |
| E | 48 | 54 | 0 | 79 |
| F | 1 | 2 | 0 | 136 |
| G | 1 | 2 | 0 | 21 |

Zero unmapped tests is not complete coverage. Annex E still has two requirements
without direct tests: HDL-path accessibility and the walking-ones algorithm
itself. Location masks
are linked only to the necessary location-access property, not to the whole
walking algorithm. B.5.11's conflicting printed invocation is recorded as an
interpretation requiring review. Known differences retain normative oracles;
all 376 requirement reviews are still `ai`.

Selected FIFO mappings bind blocking/nonblocking behavior, capacity, flush,
arrival order and analysis notifications to their actual expected observations.
Failed-get output values, broader concurrency and two-tests-per-requirement
coverage remain unassessed. Foundation mappings cover local database hooks,
pools, agent status, string fields and literal argument suffix queries; none
claims external database, full agent traffic or a working DPI backend.

Remaining unlinked work also distinguishes report-statistic merging and
quit-limit termination from getters, ready-to-end cap enforcement from one
retry, clear from dropped callbacks, object-side policy synchronization from
policy-side stacks, and printer/comparer output behavior from control values.
Factory no-override lookup, reference-mode copy errors and oversize integral
packing are retained as separate unlinked branches. The quit-action wording
in 6.5.1.2.3 is interpreted using declared `UVM_COUNT` in F.2.2.2 and root
termination in F.7.3.2; its printed `UVM_QUIT` is not a declared action value.

## Generated report identity

Every generated inventory and backlog carries `ledger_inputs_sha256`. It
identifies the complete validated input state: `coverage/scope.json`,
`coverage/requirements.json`, `coverage/test_index.json` and the catalog's
`catalog_sha256`. The index contains the current test-input fingerprints;
ledger validation binds those snapshots to the actual test inputs first.

The tool hashes UTF-8 canonical JSON with sorted object keys and compact
separators. JSON whitespace, key order and escaped versus literal Japanese
text do not affect this identity. Array order is retained, and catalog byte
changes affect its own fingerprint. Absolute repository paths, generated
output paths, report language and a backlog root filter are not input fields.
The identity is shared by full and filtered reports from the same inputs.
Compare the report schema and selection as well when comparing different views;
this is an input identity, not a hash of the generated output file.

Requirement wording, applicability, expectations, limitations, review or link
changes affect the identity, as do scope or accepted snapshot changes. A digest
is neither review approval nor an execution result. It is separate from each
test's `inputs_sha256` and the runner's `runner_sha256`. Old generated reports
need regeneration after a semantic ledger change even when the simulation
sources stay unchanged. A same-hash report can still describe an incomplete,
unapproved inventory with known differences.

## Updating a test or mapping

1. Read the applicable normative behavior; write or revise the bilingual
   requirement, conditions and limitations. Reassess its review status.
2. Inspect the test and expected observations. Add explicit `direct` or
   `control` links; leave links empty when the requirement is not yet mapped.
3. Run `check`. Changed inputs or primary focus, added tests and removed tests
   invalidate the canonical index.
4. Use `sync` to create a separate proposal. It adds current tests and refreshes
   unlinked snapshots, but preserves existing snapshots of linked tests. Thus
   adopting a proposal alone does not clear a stale linked mapping. Removing
   a linked test first requires reviewing/removing its links.
5. Compare the proposal and source changes. After reassessing every affected
   mapping, update its fingerprint/focus from the current inputs and adopt
   the reviewed index changes. A new snapshot is not itself a human review.
6. Run metadata, ledger and tool checks; update the paired guides when scope,
   schema or inventory claims change. Reproduce affected execution evidence
   separately when simulation inputs or runners change.

There is deliberately no command that silently certifies existing mappings
when their inputs change. The regression tests cover stale expected/helper/
lock inputs, direct/control distinctions, citation non-promotion, duplicate
or invalid data, scope claims and generated-output protection. Check CI runs
this validation alongside the existing metadata and library checks.

## Remaining M4 work and approval

Continue reading candidate clauses and splitting their obligations and
conditions. Map existing tests before deciding which new tests are necessary;
record unsupported or unmatched behavior without changing its normative
expectation. Review the context/deferred choices, catalog completeness,
requirement identities, overlap and genuinely non-normative material. Track
backend constraints as limitations rather than hidden denominator exclusions.

Before publishing a coverage percentage, finish and review the normative
inventory, resolve the scope choices and obtain explicit approval of the
counting rule and frozen requirement set. Define separately what counts as
reviewed test coverage and as execution success, including execution conditions
and evidence identity. Approval needs a later schema/procedure update; schema
1 intentionally cannot express a completed inventory or approved denominator.
The current 376 AI drafts and their direct links do not satisfy that gate.
