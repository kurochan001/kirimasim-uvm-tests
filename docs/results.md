# Current results and measurement methodology

[日本語](results.ja.md) · [README](../README.md) · [Known differences](known-differences.md)

## Current snapshot

The Verilator snapshot assembled on 2026-11-04 covers all 1640 current tests.
Guest records retain 1083 compatible current inputs; 557 inputs are
unmeasured, including two revised old inputs. Each record
fingerprints its inputs and conditions.
The suite has 1640 fixtures in 21 directories: 1597 simulation and 43
elaboration. Milestone totals are M1 603 (570/33), M2 538 (533/5) and M3 499
(494/5), with runtime/elaboration counts in parentheses. All use `spec_check: ai`;
none records human review. Of 1614 no-DPI fixtures, 43 are illegal elaboration
checks. The eight HDL-DPI and eighteen command-line/regex-DPI runtime fixtures
remain separate.

Counts do not establish a reviewed coverage percentage.

| Simulator and library | Observation | Execution scope |
| --- | --- | --- |
| Verilator 5.052, pinned UVM | 1435 `pass`: 1394 runtime + 41 compile rejection; 205 `known` | Runtime matches use seeds 1/73; expected compiler rejections execute no runtime seed |
| Verilator 5.052, original VPI HDL backend | 7 `pass`; 1 `fail` | Separate overlapping 8-case condition; matches at seeds 1/73, difference at seed 1 |
| Verilator 5.052, original command-line VPI bridge and pinned regex DPI | 17 `pass`; 1 `known` | Separate overlapping 18-case condition; matches at seeds 1/73, difference at seed 1 |
| kirimasim, pinned UVM | 1074 `unsupported`; nine `fail` | 1083 unchanged inputs; 557 inputs unmeasured |
| Ghost, bundled UVM | 207 `pass`; 876 `fail` | 1083 unchanged inputs at each seed; identical failing sets; 557 inputs unmeasured |
| Ghost, pinned UVM | Not measured for the current executable snapshot | No current pinned-mode claim |

The pinned library is Accellera UVM 2020.3.1, commit `78c06547a2a0`, with
326 files checked against [the lock](../third_party/uvm.lock). A Ghost bundled
run uses the supplied library rather than that lock's package. Private
simulator identity, version, paths, profile contents and diagnostics are
not published. [Ghost setup](testing.md#ghost) describes the public interface.
Icarus Verilog is not used for this UVM suite.

## Interpretation

Forty-one valid negative expectations match by compiler rejection with the
declared fixture/class/method, forbidden-member or const-reference diagnostic. Two other illegal
designs are accepted: subscriber write and visitor visit are left unimplemented.
These retain the rejection oracle as known differences. No illegal design is
executed at runtime, including the accepted ones. The 48 unexpected simulation
build failures remain separate. A `pass` requires the declared expectation.

The 205 spec-only cases retain standard-derived output or compile-diagnostic expectations.
Two are illegal compiler acceptances; 203 are simulation cases. Of these, 155
first differ at runtime seed 1 without seed 73. Eighteen cannot build because
of missing APIs/type names: one time API, six sequence-library APIs, four HDL
slice cases, one named-concat constructor, one object active-policy API, three
catcher message-handle cases, the printed base recording-state getter and the
printed report callback typedef. Two declaration builds retain incompatible
defaults; two retain the printed all_dropped function/task and clone implicit-scalar/map-return conflicts.
Another 26 request unlinked DPI: eight HDL and eighteen command-line cases.
These 48 simulation builds have no runtime result. Separate command-line
evidence remains seventeen matches and one quit-warning difference.

The shared-handler reset case retains the severity/ID verbosity value while
general and ID values, action and file return to defaults. The expected reset
and subsequent boundary delivery remain unchanged. This adds one runtime
fixture to the known set; prior severity-override reset differences remain.

The separate VPI condition measures eight HDL fixtures with the original
backend: seven match seeds 1/73. The inaccessible-path sequence first differs
at seed 1, reporting ERROR rather than warning and attempting storage reads
under the retained E.7 no-transfer interpretation. The accessible-path control
and actual HDL deposit/read cases match. This backend's 64-bit packed-variable
scope does not establish vendor overlays, arrays or four-state behavior.
Do not add its overlapping pass count to the ordinary total. See
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

The ordinary snapshot retains all 1624 earlier input identities and records from
[c9d237e](https://github.com/kurochan001/kirimasim-uvm-tests/commit/c9d237ef2ae8f49bfdc4e64c50eaaa10deb2da2b)
and adds sixteen M3 simulation fixtures measured on 2026-11-04 JST. Thirteen
match both seeds. Two retain seed-1 runtime differences without seed 73:
the null local-map query differs from the selected parent block default in
the sole-registered-map condition, and named field lookup misses before lock. Ordered field handles
and the later locked lookup control do not make that whole fixture pass.

The literal clone implicit-return probe cannot build against the available
map-return signature and has no runtime. This is a qualified declaration
interpretation, separate from the matching public clone call/source-preservation
control, not an expected compiler rejection of an illegal test. New-map identity,
contents/rights and the printed return-type question remain partial duties.

New matching controls cover constructor names/widths/coverage availability,
block/file identity, map membership removal/listing, local/ancestor resolution,
global maximum width, reset kinds, model-only value/debug queries and live gated
busy state across successful and failed transfers. Original backend counters
and subsequent peek distinguish model getters from real storage access.
Fifty-eight bilingual AI drafts and five individually read assessments are
added. All 2773 earlier requirements, 285 assessments and 1624 fixtures/records
remain unchanged. Schema, runners/library/catalog, workflow and SVGs are unchanged.
No new guest run, human review, denominator approval or completion is claimed.

Retained kirimasim/Ghost records were collected with fixed executable
snapshots and Ghost's seed-specific private profiles.

Commercial simulator results are excluded under the
[reporting policy](faq.md#commercial-simulator-and-issue-reporting-policy).

The earlier temporary kirimasim/Ghost executable/profile snapshots are no
longer available, so no guest rerun is claimed. Historical files retain 1085
records. Two current inputs differ: a command-enum citation and the corrected
Boolean rerandomization observation. Their stale records are excluded.
The compatible current subset has 1083 records: kirimasim 1074 unsupported/
nine missing-API failures; Ghost 207 pass/876 fail at each seed. The 557
unmeasured inputs are 555 additions and the two revised old inputs. The filtered
files and `out/thin-fifty-second-evidence-scope.json` retain the explicit exclusions
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
  their declared 1083-case subset; 557 input IDs remain unmeasured.
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

The [draft requirement ledger](requirements.md) has 2831 AI drafts. Fifty-eight
new duties cover selected register construction, placement, membership, queries,
reset metadata, busy state and clone declaration/source boundaries. Individual
assessments add two contextual and three structural entries. Totals are 1516
partial/290 assessed/701 unassessed; chapter 18 is 278/35/143. Subclauses 18.2
and 18.3 have no unassessed identifier, but their partial conditions remain open.
Clone callability/source preservation does not certify a new map's contents or
resolve its scalar/map return-type interpretation. Register ownership, reverse-map
cache views, every field policy, interrupted access and concurrent mutation
remain separate audits.

Guest files keep 1083 byte-identical compatible records; 557 inputs remain
unmeasured (514 simulation/43 elaboration), including both earlier revised
inputs. No new guest result, human review or denominator approval is claimed.

## Reproducing and retaining results

The [testing guide](testing.md#running-the-suite) documents the commands,
profile modes and library settings. Request `--json out/<name>.json` to retain
statuses, reasons, configuration and fingerprints. `out/` is ignored by Git,
and Check does not publish these local evidence files. A result from different
inputs, a different runner, executable, profile or library is a separate condition.

## Continuous integration

[Check](../.github/workflows/check.yml) runs on pushes to `main`, pull requests
and manual dispatch. It checks pinned-library integrity, 110 tool unit tests,
1640 metadata records and the draft ledger/index. Its 1435 tagged ordinary
Verilator checks comprise 1394 runtime cases at seeds 1/73 and forty-one compiler
rejections without runtime seeds, plus seventeen
explicit command-line checks under their separate condition.
It does not run kirimasim, Ghost or spec-only cases. The README's badge is the
live CI state, separate from these local measurements. A green Check does
not establish complete UVM conformance or a passing result for every simulator.
There is no Nightly workflow or automatic result publication.
