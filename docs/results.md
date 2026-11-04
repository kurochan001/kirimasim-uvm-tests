# Current results and measurement methodology

[日本語](results.ja.md) · [README](../README.md) · [Known differences](known-differences.md)

## Current snapshot

The Verilator snapshot assembled on 2026-11-05 covers all 1763 current tests.
Guest records retain 1083 compatible current inputs; 680 inputs are
unmeasured, including two revised old inputs. Each record
fingerprints its inputs and conditions.
The suite has 1763 fixtures in 21 directories: 1711 simulation and 52
elaboration. Milestone totals are M1 709 (667/42), M2 538 (533/5) and M3 516
(511/5), with runtime/elaboration counts in parentheses. All use `spec_check: ai`;
none records human review. Of 1734 no-DPI fixtures, 52 are illegal elaboration
checks. The eleven HDL-DPI and eighteen command-line/regex-DPI runtime fixtures
remain separate.

Counts do not establish a reviewed coverage percentage.

| Simulator and library | Observation | Execution scope |
| --- | --- | --- |
| Verilator 5.052, pinned UVM | 1534 `pass`: 1484 runtime + 50 compile rejection; 229 `known` | Runtime matches use seeds 1/73; expected compiler rejections execute no runtime seed |
| Verilator 5.052, original VPI HDL backend | 10 `pass`; 1 `fail` | Separate overlapping 11-case condition; matches at seeds 1/73, difference at seed 1 |
| Verilator 5.052, original command-line VPI bridge and pinned regex DPI | 17 `pass`; 1 `known` | Separate overlapping 18-case condition; matches at seeds 1/73, difference at seed 1 |
| kirimasim, pinned UVM | 1074 `unsupported`; nine `fail` | 1083 unchanged inputs; 680 inputs unmeasured |
| Ghost, bundled UVM | 207 `pass`; 876 `fail` | 1083 unchanged inputs at each seed; identical failing sets; 680 inputs unmeasured |
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

The 229 spec-only cases retain standard-derived output or compile-diagnostic
expectations. Two are illegal compiler acceptances; 227 are simulation cases.
Of these, 170 first differ at runtime seed 1 without seed 73. Twenty cannot build
because of missing APIs/type names: one time API, six sequence-library APIs,
four HDL slice cases, one named-concat constructor, one object active-policy API,
three catcher message-handle cases, the printed base recording-state getter,
the printed report callback typedef and two builtin type_id cases.

Two declaration builds retain incompatible defaults; two retain printed
all_dropped function/task and clone implicit-scalar/map-return conflicts. Two
retain incompatible inherited type_id registry specializations; one retains the
protected memory backdoor_read accessibility difference. One legal resource-base
extension also requires unlisted pure hooks. Another 29 request
unlinked DPI: eleven HDL and eighteen command-line cases. These 56 simulation
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

The snapshot retains all 1731 prior ordinary input identities/records from
[2240ea0](https://github.com/kurochan001/kirimasim-uvm-tests/commit/2240ea053b031f254e6625f6e1d98449fd62e858)
and measures the resource increment on 2026-11-05 JST.

Thirty-two M1 resource fixtures add twenty-four two-seed runtime matches,
four expected compiler rejections, three seed-1 runtime differences without
seed 73 and one legal extension build without runtime. Missing-name lookup
omits the required default warning. Both independently measured local and
global pool cases retain assigned precedence 3/9 but return the first resource
by name instead of the required maximum; type priority and its queue match.
The local public-constructor/singleton boundary remains explicitly qualified.

The original extensions declare separate direct base-constructor calls with an
explicit name and argument omission. They implement the standard-listed pure
type hook but cannot compile because the pinned library also requires unlisted pure helpers.
That legal declaration stays spec-only. A separate missing-type-hook negative
uses original compatibility bodies to isolate the required get_type_handle
rejection; it does not repair the legal extension. Other negative fixtures
reject direct virtual-base construction and incompatible typed read/write
contexts, each without a runtime seed and with independent legal controls.

Matching controls cover exact queue/DB aliases, default resource/DB types,
constructor names, static/polymorphic tokens, scalar/string/queue copying and
object-handle identity, read-only ERROR/storage, equal/rejected-write notification
suppression, all pending waiters on a changed write, scope replacement/deletion,
null insertion warnings, separate name/type/both priorities and overrides,
first-maximum queues, core-service pool/default selection, and DB values,
identity, failed-read sentinels and shared-scope writes.

Initial accessor setup mistakenly constructed abstract uvm_object directly.
Original concrete accessor classes now replace it and are remeasured; obsolete
setup builds are excluded rather than assigned to UVM. Expected outputs stay
standard-derived. Constructor prose/prototype differences, lookup_type's queue/
convenience-text conflict, type-priority versus broader lookup wording and the
type-write paragraph's name-based references remain explicit interpretations.
No successful-write return value is invented.

Sixty-three bilingual AI drafts and twelve individual assessments are added.
All 3031 earlier requirements and 341 assessments remain unchanged. The eleven
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
nine missing-API failures; Ghost 207 pass/876 fail at each seed. The 680
unmeasured inputs are 678 additions and the two revised old inputs. The filtered
files and `out/thin-fifty-eighth-evidence-scope.json` retain the explicit exclusions
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
  their declared 1083-case subset; 680 input IDs remain unmeasured.
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

The [draft requirement ledger](requirements.md) has 3094 AI drafts. Sixty-three
new duties and twelve individual assessments reduce unassessed identifiers to
467. Overall is 1687 partial/353 assessed; annex C is 52/12/20 and annex F is
60/14/63. All partial obligations and original milestone targets remain open.
Guest records retain 1083 compatible inputs; 680 are unmeasured (628 simulation/
52 elaboration), including two earlier revised inputs. No new guest result,
human review or denominator approval is claimed.

## Reproducing and retaining results

The [testing guide](testing.md#running-the-suite) documents the commands,
profile modes and library settings. Request `--json out/<name>.json` to retain
statuses, reasons, configuration and fingerprints. `out/` is ignored by Git,
and Check does not publish these local evidence files. A result from different
inputs, a different runner, executable, profile or library is a separate condition.

## Continuous integration

[Check](../.github/workflows/check.yml) runs on pushes to `main`, pull requests
and manual dispatch. It checks pinned-library integrity, 110 tool unit tests,
1763 metadata records and the draft ledger/index. Its 1534 tagged ordinary
Verilator checks comprise 1484 runtime cases at seeds 1/73 and fifty compiler
rejections without runtime seeds, plus seventeen
explicit command-line checks under their separate condition.
It does not run kirimasim, Ghost or spec-only cases. The README's badge is the
live CI state, separate from these local measurements. A green Check does
not establish complete UVM conformance or a passing result for every simulator.
There is no Nightly workflow or automatic result publication.
