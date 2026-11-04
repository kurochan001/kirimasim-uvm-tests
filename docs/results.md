# Current results and measurement methodology

[日本語](results.ja.md) · [README](../README.md) · [Known differences](known-differences.md)

## Current snapshot

The Verilator snapshot assembled on 2026-11-05 covers all 1895 current tests.
Guest records retain 1083 compatible current inputs; 812 inputs are
unmeasured, including two revised old inputs. Each record
fingerprints its inputs and conditions.
The suite has 1895 fixtures in 21 directories: 1835 simulation and 60
elaboration. Milestone totals are M1 766 (719/47), M2 547 (542/5) and M3 582
(574/8), with runtime/elaboration counts in parentheses. All use `spec_check: ai`;
none records human review. Of 1866 no-DPI fixtures, 60 are illegal elaboration
checks. The eleven HDL-DPI and eighteen command-line/regex-DPI runtime fixtures
remain separate.

Counts do not establish a reviewed coverage percentage.

| Simulator and library | Observation | Execution scope |
| --- | --- | --- |
| Verilator 5.052, pinned UVM | 1621 `pass`: 1564 runtime + 57 compile rejection; 274 `known` | Runtime matches use seeds 1/73; expected compiler rejections execute no runtime seed |
| Verilator 5.052, original VPI HDL backend | 10 `pass`; 1 `fail` | Separate overlapping 11-case condition; matches at seeds 1/73, difference at seed 1 |
| Verilator 5.052, original command-line VPI bridge and pinned regex DPI | 17 `pass`; 1 `known` | Separate overlapping 18-case condition; matches at seeds 1/73, difference at seed 1 |
| kirimasim, pinned UVM | 1074 `unsupported`; nine `fail` | 1083 unchanged inputs; 812 inputs unmeasured |
| Ghost, bundled UVM | 207 `pass`; 876 `fail` | 1083 unchanged inputs at each seed; identical failing sets; 812 inputs unmeasured |
| Ghost, pinned UVM | Not measured for the current executable snapshot | No current pinned-mode claim |

The pinned library is Accellera UVM 2020.3.1, commit `78c06547a2a0`, with
326 files checked against [the lock](../third_party/uvm.lock). A Ghost bundled
run uses the supplied library rather than that lock's package. Private
simulator identity, version, paths, profile contents and diagnostics are
not published. [Ghost setup](testing.md#ghost) describes the public interface.
Icarus Verilog is not used for this UVM suite.

## Interpretation

Fifty-seven valid negative expectations match by compiler rejection with the
declared fixture/type/member diagnostic. Three illegal designs remain accepted:
subscriber write and visitor visit omissions, and direct construction of the
printed virtual builtin dispatcher. They retain the rejection oracle as known
differences without runtime, even when accepted. The 65 unexpected simulation
builds remain separate. A pass requires the declared expectation.

The 274 spec-only cases retain standard-derived output or compile-diagnostic
expectations. Three are illegal compiler acceptances; 271 are simulation cases.
Of these, 206 first differ at runtime seed 1 without seed 73. Twenty-seven cannot build
because of missing APIs/type names: one time API, six sequence-library APIs,
four HDL slice cases, one named-concat constructor, five object active-policy API cases,
three catcher message-handle cases, the printed base recording-state getter,
the printed report callback typedef and two builtin type_id cases, plus three typed resource-DB helper cases.

One time-decrement build requires the printed optional secs argument.
Two declaration builds retain incompatible defaults; two retain printed
all_dropped function/task and clone implicit-scalar/map-return conflicts. Two
retain incompatible inherited type_id registry specializations; one retains the
protected memory backdoor_read accessibility difference. One legal resource-base
extension also requires unlisted pure hooks. Another 29 request
unlinked DPI: eleven HDL and eighteen command-line cases. These 65 simulation
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

The snapshot retains all 1858 prior ordinary inputs/records from [b95b8a8](https://github.com/kurochan001/kirimasim-uvm-tests/commit/b95b8a891128bdcf2c7639a820d1edd428873b2c)
and measures the memory/special-register increment on 2026-11-05 JST.

Thirty-seven M3 inputs add nineteen two-seed runtime matches and eighteen
seed-1 runtime differences without seed 73. Twenty-five use the listed APIs,
including an independent ordinary-register bus control; twelve additional
control-only inputs explicitly initialize the pinned FIFO with its unlisted
build method. They have separately indexed fingerprints and expected observations.
Seven initialized controls match; five retain differences. No control result
passes the constructor/configure-only premise of a direct requirement.

Memory address defaults select the sole member or shared parent-default map.
Unrelated-map address/offset/address-array warnings match, including minus-one
and unchanged caller-array duties. The rights query returns RW but generates
no required warning. Original delayed backdoor reads see external adjacent-word
changes. Memory/indirect/FIFO builtin factory exceptions retain legal registered
extension controls; indirect omitted/explicit constructors and register-base
write/read routing match.

Twelve constructor/configure-only FIFO inputs stop on a null internal field
before completing set/predict, transfer/update or compare/mirror observations.
After expectations were fixed, diagnosis in the pinned Apache-2.0 UVM identified
its unlisted build initializer. This is an explicit premise/interpretation
boundary, not an invented IEEE prerequisite or proof of independent library bugs.
The separately initialized controls reach the selected algorithms: set/full,
write/read prediction, the four comparison gates and omitted compare default
match. Direct write is rejected with Needs Update despite no external FIFO set;
external observation then duplicates abstract state without a bus write. Update
duplicates the two preloads into four entries/transfers; repeated update also
retains four entries. A checked matching public FIFO/DUT pair pops both queues
but reports an internal zero-mirror mismatch. The public-queue expectation is
qualified and remains open for review.

The final write control returns after its rejected write, avoiding a cascading
empty-original-DUT read. Its standard-derived expectation remains unchanged.
Two isolated declared helper directories preserve the original 1858 input
identities. Source/metadata preflight corrections are fixture work, not UVM
differences. All other earlier ordinary/compiler/guest/backend records remain
unchanged; no guest rerun or completion is claimed.

Forty-five bilingual AI duties and one individual structural assessment are
added. All 3262 earlier duties and 387 assessments remain unchanged, as do the
1083 guest, eleven HDL and eighteen command-line records. No human review,
denominator approval or completion is claimed.

Retained kirimasim/Ghost records were collected with fixed executable
snapshots and Ghost's seed-specific private profiles.

Commercial simulator results are excluded under the
[reporting policy](faq.md#commercial-simulator-and-issue-reporting-policy).

The earlier temporary kirimasim/Ghost executable/profile snapshots are no
longer available, so no guest rerun is claimed. Historical files retain 1085
records. Two current inputs differ: a command-enum citation and the corrected
Boolean rerandomization observation. Their stale records are excluded.
The compatible current subset has 1083 records: kirimasim 1074 unsupported/
nine missing-API failures; Ghost 207 pass/876 fail at each seed. The 812
unmeasured inputs are 810 additions and the two revised old inputs. The filtered
files and `out/thin-sixty-third-evidence-scope.json` retain the explicit exclusions
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
  their declared 1083-case subset; 812 input IDs remain unmeasured.
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

The [draft ledger](requirements.md) has 3307 AI duties. Forty-five new duties
and one individual heading assessment leave 300 identifiers unassessed:
1819 partial/388 assessed. Chapter 18 is 312/43/101 with 651 drafts; 18.6–18.8
have no unassessed identifier, with contracts remaining partial. Direct links
cover 1882 tests; thirteen others have only control links. Guest records retain
1083 compatible inputs; 812 (752 simulation/60 elaboration), including two
revised original inputs, are unmeasured. Scope/denominator and original targets
remain open.

## Reproducing and retaining results

The [testing guide](testing.md#running-the-suite) documents the commands,
profile modes and library settings. Request `--json out/<name>.json` to retain
statuses, reasons, configuration and fingerprints. `out/` is ignored by Git,
and Check does not publish these local evidence files. A result from different
inputs, a different runner, executable, profile or library is a separate condition.

## Continuous integration

[Check](../.github/workflows/check.yml) runs on pushes to `main`, pull requests
and manual dispatch. It checks pinned-library integrity, 110 tool unit tests,
1895 metadata records and the draft ledger/index. Its 1621 tagged ordinary
Verilator checks comprise 1564 runtime cases at seeds 1/73 and fifty-seven compiler
rejections without runtime seeds, plus seventeen
explicit command-line checks under their separate condition.
It does not run kirimasim, Ghost or spec-only cases. The README's badge is the
live CI state, separate from these local measurements. A green Check does
not establish complete UVM conformance or a passing result for every simulator.
There is no Nightly workflow or automatic result publication.
