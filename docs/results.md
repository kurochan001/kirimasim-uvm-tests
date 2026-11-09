# Current results and measurement methodology

[日本語](results.ja.md) · [README](../README.md) · [Known differences](known-differences.md)

## Current snapshot

Runtime matches, compiler rejections and unmeasured inputs describe different execution conditions; [Read a result](reading-guide.md#read-a-result) explains how to read the counts together.

The Verilator snapshot assembled on 2026-11-09 covers all 2755 two-state tests; the seven four-state tests have no Verilator record.
Guest records retain 1081 compatible current inputs; 1681 inputs are
unmeasured, including four revised old inputs. Each record
fingerprints its inputs and conditions.
The suite has 2762 fixtures in 22 directories: 2663 simulation and 99
elaboration. Milestone totals are M1 1187 (1106/81), M2 633 (626/7) and M3 942
(931/11), with runtime/elaboration counts in parentheses. All use `spec_check: ai`;
none records human review. Of 2701 no-DPI fixtures, 99 are illegal elaboration
checks. The thirty-eight HDL-DPI and twenty-three command-line/regex-DPI runtime fixtures
remain separate.

Counts do not establish a reviewed coverage percentage.

Backend rows revisit inputs already included in the ordinary row under different conditions; [the execution setup](testing.md#the-uvm-library) explains why their results are counted separately.

A runtime match at seeds 1/73 still counts as one fixture, while a seed requested in configuration may be skipped after a first mismatch; [the seed-count explanation](faq.md#q201-did-all-2762-tests-run-at-two-seeds) explains how to read the execution scope column.

| Simulator and library | Observation | Execution scope |
| --- | --- | --- |
| Verilator 5.052, pinned UVM | 2292 `pass`: 2198 runtime + 94 compile rejection; 463 `known` | Runtime matches use seeds 1/73; expected compiler rejections execute no runtime seed |
| Verilator 5.052, original VPI HDL backend | 37 `pass`; 1 `fail` | Separate overlapping 38-case condition; matches at seeds 1/73, difference at seed 1 |
| Verilator 5.052, original command-line VPI bridge and pinned regex DPI | 20 `pass`; 3 `known` | Separate overlapping 23-case condition; matches at seeds 1/73, differences at seed 1 |
| Verilator 5.052, listed ordinary fixtures with regex and command-line DPI | 26 `pass` | Separate overlapping 26-case condition from `coverage/regex_dpi_variants.txt`; matches at seeds 1/73 |
| kirimasim, pinned UVM | 1072 `unsupported`; nine `fail` | 1081 unchanged inputs; 1681 inputs unmeasured |
| Ghost, bundled UVM | 206 `pass`; 875 `fail` | 1081 unchanged inputs at each seed; identical failing sets; 1681 inputs unmeasured |
| Ghost, pinned UVM | Not measured for the current executable snapshot | No current pinned-mode claim |

The pinned library is Accellera UVM 2020.3.1, commit `78c06547a2a0`, with
326 files checked against [the lock](../third_party/uvm.lock). A Ghost bundled
run uses the supplied library rather than that lock's package. Private
simulator identity, version, paths, profile contents and diagnostics are
not published. [Ghost setup](testing.md#ghost) describes the public interface.
Icarus Verilog is not used for this UVM suite.

## Interpretation

One test may check several observations, and a required mismatch keeps the whole case from passing even when other rows match; [the judgment rules](faq.md#q5-what-do-pass-fail-known-and-unsupported-mean) explain its recorded status.

To investigate an individual row, [Trace a difference](reading-guide.md#trace-a-difference) connects its result JSON to the source, expected observation and runner condition.

If the identifiers are unfamiliar, [the smoke-test example](reading-guide.md#follow-one-test-through-the-files) shows how a result ID, source filename, UVM class and requirement ID relate to one another.

For a runtime output mismatch, `reason` identifies the first differing selected line, so use [the observation rules](testing.md#what-is-observed) to compare it with the declared expected sequence.

A build failure stops before simulation, while a runtime difference comes from an executed model; [Q14](faq.md#q14-do-two-seeds-prove-determinism-or-four-state-correctness) explains which seed results exist in each case.

94 valid negative expectations match by compiler rejection with the
declared fixture/type/member diagnostic. Five illegal designs remain accepted:
subscriber write, visitor visit, proxy get_immediate_children and adapter accept omissions, and direct construction of the
printed virtual builtin dispatcher. They retain the rejection oracle as known
differences without runtime, even when accepted. The 140 unexpected simulation
builds remain separate. A pass requires the declared expectation.

[The cause record](known-differences.md#causes-of-the-known-differences) assigns causes to these
differences separately from the symptom categories below: 319 library, 60 interpretation,
27 simulator and 57 DPI-condition causes, with no entry unassigned.

The 463 measured spec-only cases retain standard-derived output or compile-diagnostic
expectations; the seven four-state spec-only cases have no Verilator record. Five are illegal compiler acceptances; 458 are simulation cases.
Of these, 318 first differ at runtime seed 1 without seed 73. Forty-three cannot build
because of missing APIs/type names: one time API, fourteen sequence-library APIs,
twelve HDL slice-view cases, one named-concat constructor, five object active-policy API cases,
three catcher message-handle cases, the printed base recording-state getter,
the printed report callback typedef and two builtin type_id cases, plus three typed resource-DB helper cases.

One time-decrement build requires the printed optional secs argument.
Two declaration builds retain incompatible defaults; two retain printed
all_dropped function/task and clone implicit-scalar/map-return conflicts. Two
retain incompatible inherited type_id registry specializations; one retains the
protected memory backdoor_read accessibility difference. Two legal extensions, resource-base and listed-only complete core service,
also require unlisted pure hooks. Another 61 request
unlinked DPI: thirty-eight HDL and twenty-three command-line cases. Three additional legal
builds use the literal enum-collection T interpretation. Seven further builds
retain six strict attribute definitions and the printed enum-unpack arity.
Three more builds retain dependent visitor defaults with custom STRUCTURE.
Two qualified virtual-abstraction overview-base inputs retain the wording
conflict; their explicit class-base controls match separately. Two additional
printed dedicated-pool return-type inputs retain the pool/item conflict. These 140
simulation builds have no runtime result. Separate command-line evidence has
twenty matches, one quit-warning difference and two regular-expression differences.

One additional legal construction input is rejected as an abstract uvm_vreg_cbs
facade under the pinned virtual declaration; its printed concrete expectation is
retained without runtime.

Four additional bare-packet simulation builds stop at the typed factory result used for predictor type naming; they have no runtime evidence and do not create a mandatory IEEE registration prerequisite.

Two additional simulation builds report unsupported enum methods for the large
flag extension and an undefined UVM_PACKER_MIN_BITS; neither has a runtime result.

The shared-handler reset case retains the severity/ID verbosity value while
general and ID values, action and file return to defaults. The expected reset
and subsequent boundary delivery remain unchanged. This adds one runtime
fixture to the known set; prior severity-override reset differences remain.

The separate VPI condition has thirty-eight fixtures: thirty-seven match both
seeds. Three memory inputs access real array cells through inherited tasks,
split banks and ROM write versus poke; wrappers retain the separate public-read
declaration limitation. Nine primitive force/release inputs check real public
8/40-bit regs/wires and immediate release/read behavior.

Eight new positive-duration force_time inputs observe periods 5/13, interior
force retention, post-period reg/wire state, later updates and dormant/peer
isolation. Calls are sequential in the shared compilation-default time unit;
no exact-expiry ordering, return-time/result or overlapping-argument claim is
made. The backend and both runners are unchanged. Six actual-register inputs cover
public backdoor_read, peek and poke observations for 16/40-bit whole variables
and legal two-variable split references. All thirty-eight current HDL records
are retained unchanged in this increment.

The E.7 inaccessible-path sequence still reports ERROR and attempts reads rather
than the retained warning/no-transfer expectation at seed 1, with no seed 73
result. General types/selects/arrays, cross-unit/rounding, overlapping timed calls,
failure/cancellation and four-state behavior remain open. Do not add overlapping
matches to ordinary results; see [HDL setup](testing.md#verilator-vpi-hdl-subset)
and [known differences](known-differences.md).

kirimasim reports `uvm_object_wrapper` as unsupported on 1072 cases; the other
nine encounter missing library APIs first. Neither category establishes
execution of the UVM behavior beyond those blockers. Ghost's bundled
mismatches do not identify whether the simulator or its library caused them,
and they do not establish results for the pinned library. Ghost's annex E matches cover only the
[RO register skip](../tests/uE/test_single_register_access_sequence_skips_a_readonly_register.sv),
[missing-register-backdoor skip](../tests/uE/test_single_register_access_sequence_skips_a_register_without_a_backdoor.sv) and
[missing-memory-backdoor skip](../tests/uE/test_single_memory_access_sequence_skips_a_memory_without_a_backdoor.sv).
They establish no frontdoor/backdoor transfer behavior.

`known` and `unsupported` are not passes. A command's exit code alone is not
a suite pass count; the [FAQ](faq.md#understanding-a-result) explains status
and exit-code rules. Two seeds do not prove determinism or four-state correctness.

Two additional simulation builds are the conditional B.4 directional type controls, with assignment-type errors and no runtime; [Q392](faq.md#q392-do-the-type-relation-controls-settle-the-b4-base-wording) explains why they do not establish mandatory ancestry or a library-only cause.

## Evidence assembly

This section explains how existing records can support a combined snapshot; for a first local measurement, use [the single-test command](faq.md#q3-how-can-i-run-one-test-first) and [the JSON-reading example](reading-guide.md#open-the-result-json).

A fingerprint identifies the exact inputs behind a reused record, so [Execution and result records](glossary.md#execution-and-result-records) explains why an old match may not apply after an edit.

Here an unmeasured input has no compatible current record, even if an older version was run; [Q15](faq.md#q15-how-do-i-know-whether-an-old-result-still-applies) explains the checks needed before reusing it.

The snapshot starts from [4a9f9e4](https://github.com/kurochan001/kirimasim-uvm-tests/commit/4a9f9e4d026a8c58a48c16447f8e43071d9ab047), retains all 2750 old two-state records,
and adds five user-package inputs (four M1, one M2) on 2026-11-09 JST; the seven four-state inputs still have no record.

The profiles below check only their stated conditions, so a match under a different premise cannot pass an original difference; [the requirement-link guide](requirements.md#citations-requirements-and-execution-evidence) explains the recorded direct/control roles.

The 120th expansion implements the external review's fifth item, user
packages. Four original packages in `tests/u08/helpers120_pkg/` hold an agent (item, driver,
sequencer type and agent), a sequence, an environment and extension classes.
Each test lists them in `:files:` in that order, because 1800-2023 26.3
requires a package to be compiled before the scopes that import it; the agent
and sequence packages never import the extension package. Five profiles check
that utility-macro types in other packages are registered by static
initialization before run_test, so the factory finds and creates types that no
code names; that run_test creates a test class declared in a package; that
type_id::create in the environment, agent and sequence packages builds the
hierarchy and item flow; that type and instance overrides set through type_id,
and a by-name type override with creation by name, reach creation in packages
that do not import the override classes; and that a default-sequence wrapper
from another package honors an instance override for the sequencer's path.
All five match seeds 1/73 before and after tagging from the first freeze;
[the package FAQ](faq.md#q442-what-do-the-user-package-profiles-check) describes them and [the override FAQ](faq.md#q443-why-do-the-by-name-overrides-use-creation-by-name) explains
why by-name overrides are checked only with creation by name.

Nine new duties cover these conditions. The total is 4150 AI duties, with all
4141 old objects and 445 assessments unchanged; 2706 tests have direct links,
158 have controls and 56 are control-only. All 2750 old ordinary records and
463 old known inputs remain unchanged. Four inputs count as M1 and one as M2.
The requirement table also corrects rows 15 and 18, which had each missed one
duty of the 116th expansion.

The suite has 2762 tests (2663 simulation/99 elaboration). Ordinary results
are 2292 matches: 2198 runtime inputs at both seeds and 94 compiler rejections.
Known inputs total 463: 318 runtime seed 1 differences, 140 simulation builds
and five accepted illegal designs without runtime; spec-only cases total 470
with the seven four-state inputs. The command-line condition keeps 23 fixtures
(20 pass, 3 known) and the regex-DPI variant condition 26 (all pass); neither
is added to the ordinary totals. No guest run/filter is added: 1081
compatible records remain byte-identical and 1681 inputs are unmeasured (1677
additions/four revised originals; 1582 simulation/99 elaboration).

Primary-focused identifiers remain 1319; candidates are 1167 zero/764 below
target/551 at least two. All 2062 partial identifiers, actual remaining
conditions, original milestone targets, human review and scope/denominator
approval remain open; [the progress guide](reading-guide.md#read-coverage-and-progress)
explains why matching conditions do not supply completion.

Retained kirimasim/Ghost records were collected with fixed executable
snapshots and Ghost's seed-specific private profiles.

Commercial simulator results are excluded under the
[reporting policy](faq.md#commercial-simulator-and-issue-reporting-policy).

The earlier temporary kirimasim/Ghost executable/profile snapshots are no
longer available, so no guest rerun is claimed. Historical source files retain
1085 records. Earlier filters excluded four revisions: command-enum citation,
Boolean rerandomization, virtual-field configuration and reraise primary citation.
This increment performs no new filtering. All 1081 compatible records and
filter metadata are retained byte-identically. Four more additions increase the
unmeasured set to 1681: 1677 additions and four revised originals. Ghost remains
206 pass/875 fail per seed and kirimasim remains 1072 unsupported/nine API failures.
The latest exclusions are recorded in `out/thin-one-hundred-sixth-guest-exclusions.json`;
the current scope is in `out/thin-one-hundred-twentieth-evidence-scope.json`.

The fingerprints identify different inputs:

SHA-256 is a digest of recorded content, and [the fingerprint glossary](glossary.md#execution-and-result-records) explains why matching one digest alone does not establish the same execution conditions.

Editing only a requirement's wording calls for a regenerated inventory, while editing a test header changes its test fingerprint and requires compatible execution evidence; [the update procedure](requirements.md#updating-a-test-or-mapping) describes both paths.

| Identity | What it identifies | How to use it |
| --- | --- | --- |
| `inputs_sha256` | Test source, expected files, collected helpers/data and library lock | Compare each record with the current test inputs |
| `runner_sha256` | Selected runner, `suite_results.py` and `uvm_common.py` | Match across batches and require `runner_changed` to be false |
| `ledger_inputs_sha256` | Canonical scope, requirements, assessments, test index and clause catalog | Identify a generated inventory/backlog, separately from simulation evidence |

The [ledger identity](requirements.md#generated-report-identity) belongs to
generated review reports. Matching input/runner hashes still requires checking
simulator, configuration and library identities before reusing execution records.

Before combining records, check that:

- Verilator IDs cover every current two-state input exactly; the seven
  four-state inputs have no Verilator record. Retained guest IDs match
  their declared 1081-case subset; 1681 input IDs remain unmeasured.
- Each record's `inputs_sha256` matches its current source, expected output,
  associated inputs and library lock as collected by the runner.
- Simulator version, configuration and `runner_sha256` match between batches,
  and `runner_changed` is false.
- Every Verilator-tagged case is `pass` and every current two-state untagged
  case is `known` in this snapshot.
- Ghost's two seed runs have the same failing test set.

This is compatible recorded evidence over the current inputs; it does not
claim that a single invocation reran the entire suite. The
[development history](history.md) retains increment counts, measurements,
prior smoke tests and build-change details. Refreshed records replace older
ones only after their current input fingerprints are verified.

The [draft ledger](requirements.md) has 4150 AI duties and 0 unassessed
identifiers: 2062 partial/445 assessed. Chapter 10 is 87/29/0; chapter 18 is
393/63/0. Their partial contracts and original targets remain open. Direct
links cover 2706 tests; 56 others have only controls. Guests retain 1081
compatible inputs; 1681 (1582 simulation/99 elaboration), including four
revised originals, are unmeasured. Scope and denominator remain unapproved.

## Reproducing and retaining results

Writing to the same `--json` path replaces that file, so choose a new filename to retain an earlier run when following [the runner commands](testing.md#running-the-suite).

A rerun creates a new local measurement, and [the result-saving guide](testing.md#running-the-suite) explains how to choose an output JSON for that run.

An entry missing from one JSON file supplies no judgment for that case, so [the JSON-reading example](reading-guide.md#open-the-result-json) explains where to find its status and how to check the selected inputs.

To investigate one listed difference, select its source path with [the single-test command](faq.md#q3-how-can-i-run-one-test-first) and retain the same library and backend conditions as the record.

The JSON output is a local record of a selected run, and [Q10](faq.md#q10-where-is-nightly-or-the-public-results-dashboard) explains how it relates to the public Check badge.

Historical `out/` files may be absent in a fresh clone, so [the local-material guide](handoff.md#files-and-local-material) distinguishes reproducible tracked commands from optional measurement artifacts.

A result test ID is the path below `tests/` without `.sv`, so [the layout guide](testing.md#layout) helps locate the source and its declared expected file from a JSON entry.

The [testing guide](testing.md#running-the-suite) documents the commands,
profile modes and library settings. Request `--json out/<name>.json` to retain
statuses, reasons, configuration and fingerprints. `out/` is ignored by Git,
and Check does not publish these local evidence files. A result from different
inputs, a different runner, executable, profile or library is a separate condition.

## Continuous integration

A commit identifies a repository revision, so check the revision on a linked workflow run before comparing it with your files; [the handoff snapshot guide](handoff.md#snapshot-and-objective) explains how to establish the workspace's starting point.

A shard runs a disjoint subset of the selected tests, and the final gate requires every shard to succeed; [Q268](faq.md#q268-does-dividing-check-into-shards-reduce-the-required-test-scope) explains how that relates to the test scope.

[Check](../.github/workflows/check.yml) runs on pushes to `main`, pull requests
and manual dispatch. It checks pinned-library integrity, 140 tool unit tests,
2762 metadata records, the draft ledger/index and the cause record of the known
differences. Its Verilator job runs the
tagged ordinary checks whose recorded inputs changed since the base revision,
plus the canary `tests/u09/test_common_phases_run_in_order.sv`, with runtime
seeds 1/73 ([the selection tool](../tools/ci_select.py)). When the base is
unavailable, when the runner, its normalization, the library lock or the
fetcher changed, or when more than 30 checks are affected, only the canary runs
and a warning asks for Regression. The Verilator job also rebuilds the cause
record's twelve reproducers. A green Check covers the selected checks only.

[Regression](../.github/workflows/regression.yml) runs on manual dispatch and
weekly (Saturdays 17:23 UTC). It runs all 2292 tagged ordinary checks (2198
runtime cases at seeds 1/73 and 94 compiler rejections without runtime seeds)
in 20 disjoint shards (seven of 115 and thirteen of 114), at most 4 concurrent so
that Check and other repositories keep hosted job slots, each limited to 360 minutes, the twenty explicit command-line checks in a
separate job under their condition, and the twenty-six regex-DPI variants in another job. Its gate requires all three. A newer request
waits for a run in progress instead of cancelling it.

The former single Check ran the whole selection on every push. Its unsharded
[run](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/41976785278)
exceeded the 150-minute job limit, and the 8-shard version did not finish either:
in its one [run](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42121591333)
not superseded by a newer push, all eight shards reached the 150-minute limit,
and the other runs after 2026-10-31 were cancelled by newer pushes. The split
keeps seeds 1/73, compiler-rejection judgment, pinned dependencies and runner
fingerprints unchanged; the selection tool is not part of the runner fingerprint.
The shard count is estimated from local build times, so local validation does
not establish a successful hosted Regression result.

The first Regression dispatch, [run 42359747603](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42359747603)
on 42d03ab, was cancelled after its command-line job and three of its twenty
shards had completed. The command-line job succeeded; the three shards matched
334 of 342 checks. All eight differences were checks that depend on constrained
randomization: the hosted image provided no SMT solver on the path, so
`randomize()` failed. Each matches locally with z3, and removing z3 from the
local path reproduced the four differences checked, including the same seed-1
value. Earlier green Check runs selected no check that randomizes. The
[setup action](../.github/actions/setup-verilator/action.yml) now installs z3
in every job, and the cancelled run is not a Regression result for any commit.

After the fix, [run 42372122368](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42372122368) on db06513 matched all 2273 tagged checks in its 20 shards
at seeds 1/73 and passed the seventeen command-line checks. Each shard took 113
to 199 minutes, within the 360-minute limit. This first complete hosted
Regression result covers that commit; later commits need their own Check or
Regression.

Neither workflow runs kirimasim, Ghost or spec-only cases. The README's badge is
the live Check state, separate from these local measurements. A green Check or
Regression does not establish complete UVM conformance or a passing result for
every simulator. There is no automatic result publication.
