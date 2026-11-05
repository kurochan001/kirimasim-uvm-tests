# Current results and measurement methodology

[日本語](results.ja.md) · [README](../README.md) · [Known differences](known-differences.md)

## Current snapshot

The Verilator snapshot assembled on 2026-11-05 covers all 2008 current tests.
Guest records retain 1083 compatible current inputs; 925 inputs are
unmeasured, including two revised old inputs. Each record
fingerprints its inputs and conditions.
The suite has 2008 fixtures in 21 directories: 1920 simulation and 88
elaboration. Milestone totals are M1 843 (768/75), M2 547 (542/5) and M3 618
(610/8), with runtime/elaboration counts in parentheses. All use `spec_check: ai`;
none records human review. Of 1979 no-DPI fixtures, 88 are illegal elaboration
checks. The eleven HDL-DPI and eighteen command-line/regex-DPI runtime fixtures
remain separate.

Counts do not establish a reviewed coverage percentage.

| Simulator and library | Observation | Execution scope |
| --- | --- | --- |
| Verilator 5.052, pinned UVM | 1722 `pass`: 1637 runtime + 85 compile rejection; 286 `known` | Runtime matches use seeds 1/73; expected compiler rejections execute no runtime seed |
| Verilator 5.052, original VPI HDL backend | 10 `pass`; 1 `fail` | Separate overlapping 11-case condition; matches at seeds 1/73, difference at seed 1 |
| Verilator 5.052, original command-line VPI bridge and pinned regex DPI | 17 `pass`; 1 `known` | Separate overlapping 18-case condition; matches at seeds 1/73, difference at seed 1 |
| kirimasim, pinned UVM | 1074 `unsupported`; nine `fail` | 1083 unchanged inputs; 925 inputs unmeasured |
| Ghost, bundled UVM | 207 `pass`; 876 `fail` | 1083 unchanged inputs at each seed; identical failing sets; 925 inputs unmeasured |
| Ghost, pinned UVM | Not measured for the current executable snapshot | No current pinned-mode claim |

The pinned library is Accellera UVM 2020.3.1, commit `78c06547a2a0`, with
326 files checked against [the lock](../third_party/uvm.lock). A Ghost bundled
run uses the supplied library rather than that lock's package. Private
simulator identity, version, paths, profile contents and diagnostics are
not published. [Ghost setup](testing.md#ghost) describes the public interface.
Icarus Verilog is not used for this UVM suite.

## Interpretation

85 valid negative expectations match by compiler rejection with the
declared fixture/type/member diagnostic. Three illegal designs remain accepted:
subscriber write and visitor visit omissions, and direct construction of the
printed virtual builtin dispatcher. They retain the rejection oracle as known
differences without runtime, even when accepted. The 69 unexpected simulation
builds remain separate. A pass requires the declared expectation.

The 286 spec-only cases retain standard-derived output or compile-diagnostic
expectations. Three are illegal compiler acceptances; 283 are simulation cases.
Of these, 214 first differ at runtime seed 1 without seed 73. Twenty-seven cannot build
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
unlinked DPI: eleven HDL and eighteen command-line cases. Three additional legal builds use the literal enum-collection T interpretation. These 69 simulation
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

The snapshot retains all 1972 prior ordinary inputs/records from [f827d1e](https://github.com/kurochan001/kirimasim-uvm-tests/commit/f827d1e9922e5b1cb4d58318a257370b617c8057)
and measures the field-access increment on 2026-11-05 JST.

36 M3 inputs add 31 runtime matches at seeds 1/73 and 5 retained seed-1
differences without seed 73. They cover field/callback construction, constrained
public value, configured randomization modes, pending state, actual read/write
hooks, callback enable/delete, selected backdoor slices and mirror check gates.
The 2 explicit second-map controls and standalone read-only poke also have
direct duties; no new input is control-only.

Containing-register write/read traces expect RCFDBcrdf but observe FDRCBcrdf:
field pre hooks precede register pre hooks. Separate post observations match
crdf, while the complete inputs retain the order differences. Field pre-read
and pre-write map changes still use provider A; explicit initial map B controls
match. Independent original route buffers distinguish providers without
claiming physical map-alias coherence or RTL protocol evidence.

Original backdoor storage uses physical neighbor nibbles B/D distinct from
model A/3. Poke deposits B39D from B75D, peek preserves storage, and selected
failure/extension checks match. A read-only write preserves the selected 75
slice but produces A753. The whole-word expectation retains a qualified
best-effort interpretation; it is not an unconditional neighbor guarantee or
an independent defect count. The following poke explicitly resets physical
storage to B75D first and matches; a standalone read-only poke also matches.

The intended reset and slice telemetry initially missed insertion into the
history fixture. The corrected final source is remeasured. A superseded
initial seed-73 log used matching physical/model neighbors and remains
archived under its old input fingerprint; it is excluded from final evidence.
Final expected order and map outcomes remain standard-derived and unchanged.

Field-access auditing adds 69 bilingual AI duties and 5 individually read
assessments: 4 structural headings and 1 contextual type-forwarding clause.
Of 22 previously unassessed identifiers, 17 receive partial decompositions
and 5 explicit classifications. Chapter 18 is 329 partial/48 assessed/79
unassessed with 717 drafts and 405 primary tests. Field 18.5 has zero unassessed
identifiers but retains partial contracts. Global state is 1893 partial/395
assessed/219 unassessed (272 structural/123 contextual). Original targets remain open.

All 3575 duties have direct tests; 1990 tests have direct links, 18 have only
controls and 64 have control links. The 3 new controls also have their own
direct duties and never pass another input's original premise. All 3506 prior
duties, 390 assessments, 1972 indexed inputs/ordinary records and 88 compiler
records remain unchanged. Scope/denominator approval, human review and complete
coverage are not established.

Retained kirimasim/Ghost records were collected with fixed executable
snapshots and Ghost's seed-specific private profiles.

Commercial simulator results are excluded under the
[reporting policy](faq.md#commercial-simulator-and-issue-reporting-policy).

The earlier temporary kirimasim/Ghost executable/profile snapshots are no
longer available, so no guest rerun is claimed. Historical files retain 1085
records. Two current inputs differ: a command-enum citation and the corrected
Boolean rerandomization observation. Their stale records are excluded.
The compatible current subset has 1083 records: kirimasim 1074 unsupported/
nine missing-API failures; Ghost 207 pass/876 fail at each seed. The 925
unmeasured inputs are 923 additions and the two revised old inputs. The filtered
files and `out/thin-sixty-sixth-evidence-scope.json` retain the explicit exclusions
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
  their declared 1083-case subset; 925 input IDs remain unmeasured.
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

The [draft ledger](requirements.md) has 3575 AI duties and 219 unassessed
identifiers: 1893 partial/395 assessed. Chapter 18 is 329/48/79; field 18.5
retains partial contracts despite zero unassessed identifiers. Direct links
cover 1990 tests; 18 others have only controls. Guest records retain 1083
compatible inputs; 925 (837 simulation/88 elaboration), including 2 revised
original inputs, are unmeasured. Scope/denominator and original targets remain open.

## Reproducing and retaining results

The [testing guide](testing.md#running-the-suite) documents the commands,
profile modes and library settings. Request `--json out/<name>.json` to retain
statuses, reasons, configuration and fingerprints. `out/` is ignored by Git,
and Check does not publish these local evidence files. A result from different
inputs, a different runner, executable, profile or library is a separate condition.

## Continuous integration

[Check](../.github/workflows/check.yml) runs on pushes to `main`, pull requests
and manual dispatch. It checks pinned-library integrity, 110 tool unit tests,
2008 metadata records and the draft ledger/index. Its 1722 tagged ordinary
Verilator checks comprise 1637 runtime cases at seeds 1/73 and 85 compiler
rejections without runtime seeds, plus seventeen
explicit command-line checks under their separate condition.
It does not run kirimasim, Ghost or spec-only cases. The README's badge is the
live CI state, separate from these local measurements. A green Check does
not establish complete UVM conformance or a passing result for every simulator.
There is no Nightly workflow or automatic result publication.
