# Current results and measurement methodology

[日本語](results.ja.md) · [README](../README.md) · [Known differences](known-differences.md)

## Current snapshot

The Verilator snapshot assembled on 2026-11-05 covers all 1772 current tests.
Guest records retain 1083 compatible current inputs; 689 inputs are
unmeasured, including two revised old inputs. Each record
fingerprints its inputs and conditions.
The suite has 1772 fixtures in 21 directories: 1720 simulation and 52
elaboration. Milestone totals are M1 709 (667/42), M2 547 (542/5) and M3 516
(511/5), with runtime/elaboration counts in parentheses. All use `spec_check: ai`;
none records human review. Of 1743 no-DPI fixtures, 52 are illegal elaboration
checks. The eleven HDL-DPI and eighteen command-line/regex-DPI runtime fixtures
remain separate.

Counts do not establish a reviewed coverage percentage.

| Simulator and library | Observation | Execution scope |
| --- | --- | --- |
| Verilator 5.052, pinned UVM | 1542 `pass`: 1492 runtime + 50 compile rejection; 230 `known` | Runtime matches use seeds 1/73; expected compiler rejections execute no runtime seed |
| Verilator 5.052, original VPI HDL backend | 10 `pass`; 1 `fail` | Separate overlapping 11-case condition; matches at seeds 1/73, difference at seed 1 |
| Verilator 5.052, original command-line VPI bridge and pinned regex DPI | 17 `pass`; 1 `known` | Separate overlapping 18-case condition; matches at seeds 1/73, difference at seed 1 |
| kirimasim, pinned UVM | 1074 `unsupported`; nine `fail` | 1083 unchanged inputs; 689 inputs unmeasured |
| Ghost, bundled UVM | 207 `pass`; 876 `fail` | 1083 unchanged inputs at each seed; identical failing sets; 689 inputs unmeasured |
| Ghost, pinned UVM | Not measured for the current executable snapshot | No current pinned-mode claim |

The pinned library is Accellera UVM 2020.3.1, commit `78c06547a2a0`, with
326 files checked against [the lock](../third_party/uvm.lock). A Ghost bundled
run uses the supplied library rather than that lock's package. Private
simulator identity, version, paths, profile contents and diagnostics are
not published. [Ghost setup](testing.md#ghost) describes the public interface.
Icarus Verilog is not used for this UVM suite.

## Interpretation

Fifty valid negative expectations match by compiler rejection with the
declared fixture/class/method, forbidden-member or const-reference diagnostic. Two other illegal
designs are accepted: subscriber write and visitor visit are left unimplemented.
These retain the rejection oracle as known differences. No illegal design is
executed at runtime, including the accepted ones. The 57 unexpected simulation
build failures remain separate. A `pass` requires the declared expectation.

The 230 spec-only cases retain standard-derived output or compile-diagnostic
expectations. Two are illegal compiler acceptances; 228 are simulation cases.
Of these, 171 first differ at runtime seed 1 without seed 73. Twenty cannot build
because of missing APIs/type names: one time API, six sequence-library APIs,
four HDL slice cases, one named-concat constructor, one object active-policy API,
three catcher message-handle cases, the printed base recording-state getter,
the printed report callback typedef and two builtin type_id cases.

Two declaration builds retain incompatible defaults; two retain printed
all_dropped function/task and clone implicit-scalar/map-return conflicts. Two
retain incompatible inherited type_id registry specializations; one retains the
protected memory backdoor_read accessibility difference. One legal resource-base
extension also requires unlisted pure hooks. Another 29 request
unlinked DPI: eleven HDL and eighteen command-line cases. These 57 simulation
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

The snapshot retains all 1763 prior ordinary input identities/records from
[66c6075](https://github.com/kurochan001/kirimasim-uvm-tests/commit/66c6075b396f7b2ae0ba39a87e1be15f3d00e25c)
and measures the sequencer increment on 2026-11-05 JST.

Nine M2 sequencer fixtures add eight two-seed runtime matches and one seed-1
runtime difference without seed 73. The relevance guard matches at time zero
with the omitted ten, explicit two and twelve, and a virtual base-view setter.
At time three, setting three before a fresh zero-time burst notifies only on
callback five. The retained qualified oracle permits notification at the bound
or first excess (three/four), so this remains spec-only. Raw callback/time
observations are separate from the boundary predicate; ERROR or FATAL is accepted
as the unspecified error notification, without an exact severity/ID/text rule.
No counter-reset, negative-limit or post-error recovery behavior is invented.

Real pull-port transfers match automatic named begin/end notifications and
timestamps, suppression after disabling before the first request, explicit
component recording that gates modeled pipelined completion, and separate
custom address/data events. Standard typed callbacks observe transaction-pool
entries; attaching them does not prove initial pool membership. No physical
DUT completion, recorder handle layout or database format is certified.
The interface overview's inheritance wording conflicts with the actual class
declarations and remains unresolved rather than becoming a new ancestry rule.

One new library-utils duty maps four unchanged macro fixtures. Each extension,
including the derived subtype, already invokes the required macro with its
own exact type. Their empty-static-membership differences remain unchanged;
no extra implementation initialization helper or new execution is claimed.

Sixteen bilingual AI drafts and four individual assessments are added.
All 3094 earlier requirements and 353 assessments remain unchanged. The eleven
HDL and eighteen command-line records also remain byte-identical. No guest run,
human review, denominator approval or completion is claimed.

Retained kirimasim/Ghost records were collected with fixed executable
snapshots and Ghost's seed-specific private profiles.

Commercial simulator results are excluded under the
[reporting policy](faq.md#commercial-simulator-and-issue-reporting-policy).

The earlier temporary kirimasim/Ghost executable/profile snapshots are no
longer available, so no guest rerun is claimed. Historical files retain 1085
records. Two current inputs differ: a command-enum citation and the corrected
Boolean rerandomization observation. Their stale records are excluded.
The compatible current subset has 1083 records: kirimasim 1074 unsupported/
nine missing-API failures; Ghost 207 pass/876 fail at each seed. The 689
unmeasured inputs are 687 additions and the two revised old inputs. The filtered
files and `out/thin-fifty-ninth-evidence-scope.json` retain the explicit exclusions
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
  their declared 1083-case subset; 689 input IDs remain unmeasured.
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

The [draft ledger](requirements.md) has 3110 AI drafts. Sixteen new duties
and four individual assessments leave 460 identifiers unassessed; overall is
1690 partial/357 assessed. Chapter 15 is 67/18/0 and annex B 40/4/100.
All partial duties and original milestone targets remain open. Guest records
retain 1083 compatible inputs; 689 (637 simulation/52 elaboration), including
two revised old inputs, are unmeasured. No new guest result, human review or
denominator approval is claimed.

## Reproducing and retaining results

The [testing guide](testing.md#running-the-suite) documents the commands,
profile modes and library settings. Request `--json out/<name>.json` to retain
statuses, reasons, configuration and fingerprints. `out/` is ignored by Git,
and Check does not publish these local evidence files. A result from different
inputs, a different runner, executable, profile or library is a separate condition.

## Continuous integration

[Check](../.github/workflows/check.yml) runs on pushes to `main`, pull requests
and manual dispatch. It checks pinned-library integrity, 110 tool unit tests,
1772 metadata records and the draft ledger/index. Its 1542 tagged ordinary
Verilator checks comprise 1492 runtime cases at seeds 1/73 and fifty compiler
rejections without runtime seeds, plus seventeen
explicit command-line checks under their separate condition.
It does not run kirimasim, Ghost or spec-only cases. The README's badge is the
live CI state, separate from these local measurements. A green Check does
not establish complete UVM conformance or a passing result for every simulator.
There is no Nightly workflow or automatic result publication.
