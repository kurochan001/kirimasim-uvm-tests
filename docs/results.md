# Current results and measurement methodology

[日本語](results.ja.md) · [README](../README.md) · [Known differences](known-differences.md)

## Current snapshot

Runtime matches, compiler rejections and unmeasured inputs describe different execution conditions; [Read a result](reading-guide.md#read-a-result) explains how to read the counts together.

The Verilator snapshot assembled on 2026-11-05 covers all 2100 current tests.
Guest records retain 1083 compatible current inputs; 1017 inputs are
unmeasured, including two revised old inputs. Each record
fingerprints its inputs and conditions.
The suite has 2100 fixtures in 21 directories: 2012 simulation and 88
elaboration. Milestone totals are M1 887 (812/75), M2 547 (542/5) and M3 666
(658/8), with runtime/elaboration counts in parentheses. All use `spec_check: ai`;
none records human review. Of 2071 no-DPI fixtures, 88 are illegal elaboration
checks. The eleven HDL-DPI and eighteen command-line/regex-DPI runtime fixtures
remain separate.

Counts do not establish a reviewed coverage percentage.

| Simulator and library | Observation | Execution scope |
| --- | --- | --- |
| Verilator 5.052, pinned UVM | 1803 `pass`: 1718 runtime + 85 compile rejection; 297 `known` | Runtime matches use seeds 1/73; expected compiler rejections execute no runtime seed |
| Verilator 5.052, original VPI HDL backend | 10 `pass`; 1 `fail` | Separate overlapping 11-case condition; matches at seeds 1/73, difference at seed 1 |
| Verilator 5.052, original command-line VPI bridge and pinned regex DPI | 17 `pass`; 1 `known` | Separate overlapping 18-case condition; matches at seeds 1/73, difference at seed 1 |
| kirimasim, pinned UVM | 1074 `unsupported`; nine `fail` | 1083 unchanged inputs; 1017 inputs unmeasured |
| Ghost, bundled UVM | 207 `pass`; 876 `fail` | 1083 unchanged inputs at each seed; identical failing sets; 1017 inputs unmeasured |
| Ghost, pinned UVM | Not measured for the current executable snapshot | No current pinned-mode claim |

The pinned library is Accellera UVM 2020.3.1, commit `78c06547a2a0`, with
326 files checked against [the lock](../third_party/uvm.lock). A Ghost bundled
run uses the supplied library rather than that lock's package. Private
simulator identity, version, paths, profile contents and diagnostics are
not published. [Ghost setup](testing.md#ghost) describes the public interface.
Icarus Verilog is not used for this UVM suite.

## Interpretation

A build failure stops before simulation, while a runtime difference comes from an executed model; [Q14](faq.md#q14-do-two-seeds-prove-determinism-or-four-state-correctness) explains which seed results exist in each case.

85 valid negative expectations match by compiler rejection with the
declared fixture/type/member diagnostic. Three illegal designs remain accepted:
subscriber write and visitor visit omissions, and direct construction of the
printed virtual builtin dispatcher. They retain the rejection oracle as known
differences without runtime, even when accepted. The 76 unexpected simulation
builds remain separate. A pass requires the declared expectation.

The 297 spec-only cases retain standard-derived output or compile-diagnostic
expectations. Three are illegal compiler acceptances; 294 are simulation cases.
Of these, 218 first differ at runtime seed 1 without seed 73. Twenty-seven cannot build
because of missing APIs/type names: one time API, six sequence-library APIs,
four HDL slice cases, one named-concat constructor, five object active-policy API cases,
three catcher message-handle cases, the printed base recording-state getter,
the printed report callback typedef and two builtin type_id cases, plus three typed resource-DB helper cases.

One time-decrement build requires the printed optional secs argument.
Two declaration builds retain incompatible defaults; two retain printed
all_dropped function/task and clone implicit-scalar/map-return conflicts. Two
retain incompatible inherited type_id registry specializations; one retains the
protected memory backdoor_read accessibility difference. Two legal extensions, resource-base and listed-only complete core service,
also require unlisted pure hooks. Another 29 request
unlinked DPI: eleven HDL and eighteen command-line cases. Three additional legal builds use the literal enum-collection T interpretation. Seven further builds retain six strict attribute definitions and the printed enum-unpack arity. These 76 simulation
builds have no runtime result. Separate command-line evidence remains seventeen
matches and one quit-warning difference.

The shared-handler reset case retains the severity/ID verbosity value while
general and ID values, action and file return to defaults. The expected reset
and subsequent boundary delivery remain unchanged. This adds one runtime
fixture to the known set; prior severity-override reset differences remain.

The separate VPI condition has eleven HDL fixtures: ten match seeds 1/73.
Three memory fixtures access actual public array cells: inherited base-task
read/write, split 8/16-bit banks forming a 24-bit word, and ROM write versus
poke/read/peek. They verify selected data and neighboring cells through the
unchanged original backend. Derived wrappers reach the inherited implementation
without certifying the separately blocked public-read declaration.

The inaccessible-path sequence still first differs at seed 1, reporting ERROR
rather than warning and attempting reads under the retained E.7 no-transfer
interpretation. The earlier eight HDL input identities and records remain
unchanged. Selected packed cells up to 64 bits and these two-state array cases
do not establish general array/type, vendor-overlay, force/release or four-state
support. Do not add overlapping pass counts to the ordinary total. See
[HDL setup](testing.md#verilator-vpi-hdl-subset) and [known differences](known-differences.md).

kirimasim reports `uvm_object_wrapper` as unsupported on 1074 cases; the other
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

## Evidence assembly

A fingerprint identifies the exact inputs behind a reused record, so [Execution and result records](glossary.md#execution-and-result-records) explains why an old match may not apply after an edit.

The snapshot retains all 2056 prior ordinary inputs/records from [e8a6d8e](https://github.com/kurochan001/kirimasim-uvm-tests/commit/e8a6d8e1b5a955baed158d3e2bbaaab861a713ef)
and measures the recording/scalar-macro increment on 2026-11-05 JST.

The 44 new M1 inputs have 33 runtime matches at seeds 1/73, four runtime
differences at seed 1 without seed 73, and seven legal-input build differences.
Scalar pack/unpack macros use the public scalar API in the other direction and
a seven-bit trailer to observe value, width and remaining data. Selected
integral widths are 1/33/97, enums use 17 bits, strings include empty/nonempty
values, and reals include negative/zero values. No raw stream layout is fixed.

Recording probes use original recorder hooks opened through live transaction
handles. Default int/string/time/real and generic field routes are observed
separately from enabled typed attribute capture. The latter uses exact const-ref
types, including a 4301-bit value, packed struct and dynamic array.
Six printed three-argument attribute definitions fail because the pinned macros
pass an unlisted fourth recorder argument. Six separate extension-tolerant
controls match; they are control-only and preserve the original expectations.

The printed one-argument enum-unpack form cannot build without TYPE, while its
prose requires a type. A separately printed enumN form matches and has its own
direct duty plus a control link. Neither control resolves the original wording.
Two 33-bit integer macros use the integer hook rather than the stated field
hook; direct record_field controls match with default BIN and explicit HEX.
Default attribute raw-string delivery and peer selection retain two qualified
runtime differences. TR_HANDLE prose versus the zero-argument accessor is an
explicit interpretation boundary, not an unconditional independent defect claim.

Initial recorder support citations and the omitted-radix observation were
corrected against IEEE. The configured default may resolve at the hook, while
the declared field route remains required. Current recorder inputs and all
final sources, including a corrected supplementary citation, are remeasured.
All original expected files remain unchanged.

The recording/scalar-macro audit adds 41 bilingual AI duties and partially
decomposes 21 previously unassessed identifiers. No new classifications are
added; all 397 assessments remain unchanged. Annex B is 102 partial/4 assessed/
38 unassessed, with 204 duties and 139 primary tests (138 simulation/1 elaboration).
Chapter 16 has 263 duties and 152 primary tests. Global state is
1924 partial/397 assessed/186 unassessed (274 structural/123 contextual).
Collection macros, remaining size/error/lifecycle conditions and the original
milestone targets remain open.

All 3686 duties have direct tests; 2076 tests have direct links, 24 have only
controls and 72 have control links. The additions contain 38 directly linked
inputs and six control-only inputs. All 3645 prior duties, 397 assessments,
2056 indexed inputs/ordinary records and 88 compiler records remain unchanged.
No human review, approved scope/denominator or completed coverage is asserted.

Retained kirimasim/Ghost records were collected with fixed executable
snapshots and Ghost's seed-specific private profiles.

Commercial simulator results are excluded under the
[reporting policy](faq.md#commercial-simulator-and-issue-reporting-policy).

The earlier temporary kirimasim/Ghost executable/profile snapshots are no
longer available, so no guest rerun is claimed. Historical files retain 1085
records. Two current inputs differ: a command-enum citation and the corrected
Boolean rerandomization observation. Their stale records are excluded.
The compatible current subset has 1083 records: kirimasim 1074 unsupported/
nine missing-API failures; Ghost 207 pass/876 fail at each seed. The 1017
unmeasured inputs are 1015 additions and the two revised old inputs. The filtered
files and `out/thin-sixty-eighth-evidence-scope.json` retain the explicit exclusions
until authorized matching execution conditions are restored.

The fingerprints identify different inputs:

| Identity | What it identifies | How to use it |
| --- | --- | --- |
| `inputs_sha256` | Test source, expected files, collected helpers/data and library lock | Compare each record with the current test inputs |
| `runner_sha256` | Selected runner, `suite_results.py` and `uvm_common.py` | Match across batches and require `runner_changed` to be false |
| `ledger_inputs_sha256` | Canonical scope, requirements, assessments, test index and clause catalog | Identify a generated inventory/backlog, separately from simulation evidence |

The [ledger identity](requirements.md#generated-report-identity) belongs to
generated review reports. Matching input/runner hashes still requires checking
simulator, configuration and library identities before reusing execution records.

Before combining records, check that:

- Verilator IDs cover the current suite exactly. Retained guest IDs match
  their declared 1083-case subset; 1017 input IDs remain unmeasured.
- Each record's `inputs_sha256` matches its current source, expected output,
  associated inputs and library lock as collected by the runner.
- Simulator version, configuration and `runner_sha256` match between batches,
  and `runner_changed` is false.
- Every Verilator-tagged case is `pass` and every current untagged case is
  `known` in this snapshot.
- Ghost's two seed runs have the same failing test set.

This is compatible recorded evidence over the current inputs; it does not
claim that a single invocation reran the entire suite. The
[development history](history.md) retains increment counts, measurements,
prior smoke tests and build-change details. Refreshed records replace older
ones only after their current input fingerprints are verified.

The [draft ledger](requirements.md) has 3686 AI duties and 186 unassessed
identifiers: 1924 partial/397 assessed. Annex B is 102/4/38; the new scalar
observations leave collection and further applicability conditions partial.
Direct links cover 2076 tests; 24 others have only controls. Guest records retain
1083 compatible inputs; 1017 (929 simulation/88 elaboration), including two
revised original inputs, are unmeasured. Scope/denominator and original targets remain open.

## Reproducing and retaining results

The JSON output is a local record of a selected run, and [Q10](faq.md#q10-where-is-nightly-or-the-public-results-dashboard) explains how it relates to the public Check badge.

The [testing guide](testing.md#running-the-suite) documents the commands,
profile modes and library settings. Request `--json out/<name>.json` to retain
statuses, reasons, configuration and fingerprints. `out/` is ignored by Git,
and Check does not publish these local evidence files. A result from different
inputs, a different runner, executable, profile or library is a separate condition.

## Continuous integration

CI shards divide the existing test set without changing its expectations; [Q268. Does dividing Check into shards reduce the required test scope?](faq.md#q268-does-dividing-check-into-shards-reduce-the-required-test-scope) explains the relationship to the badge and local measurements.

[Check](../.github/workflows/check.yml) runs on pushes to `main`, pull requests
and manual dispatch. It checks pinned-library integrity, 110 tool unit tests,
2100 metadata records and the draft ledger/index. Its 1803 tagged ordinary
Verilator checks comprise 1718 runtime cases at seeds 1/73 and 85 compiler
rejections without runtime seeds, plus seventeen
explicit command-line checks under their separate condition.
The previous unsharded [Check run](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/41976785278)
exceeded the configured 150-minute job limit. The current workflow partitions
the current 1803 tagged checks into 8 disjoint shards (226/226/226/225/225/225/225/225),
with at most 4 concurrent shard jobs. The exact union and absence of duplicates are
verified locally. The 17 command-line checks run once, on shard 0 before
ordinary checks. Seeds 1/73, the 85 compiler rejections, pinned dependencies
and runner fingerprints are unchanged. The existing verilator gate requires
all shards to succeed. Sharding is orchestration; local
validation does not establish a successful hosted workflow result.

It does not run kirimasim, Ghost or spec-only cases. The README's badge is the
live CI state, separate from these local measurements. A green Check does
not establish complete UVM conformance or a passing result for every simulator.
There is no Nightly workflow or automatic result publication.
