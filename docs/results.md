# Current results and measurement methodology

[日本語](results.ja.md) · [README](../README.md) · [Known differences](known-differences.md)

## Current snapshot

The Verilator snapshot assembled on 2026-11-04 covers all 1624 current tests.
Guest records retain 1083 compatible current inputs; 541 inputs are
unmeasured, including two revised old inputs. Each record
fingerprints its inputs and conditions.
The suite has 1624 fixtures in 21 directories: 1581 simulation and 43
elaboration. Milestone totals are M1 603 (570/33), M2 538 (533/5) and M3 483
(478/5), with runtime/elaboration counts in parentheses. All use `spec_check: ai`;
none records human review. Of 1598 no-DPI fixtures, 43 are illegal elaboration
checks. The eight HDL-DPI and eighteen command-line/regex-DPI runtime fixtures
remain separate.

Counts do not establish a reviewed coverage percentage.

| Simulator and library | Observation | Execution scope |
| --- | --- | --- |
| Verilator 5.052, pinned UVM | 1422 `pass`: 1381 runtime + 41 compile rejection; 202 `known` | Runtime matches use seeds 1/73; expected compiler rejections execute no runtime seed |
| Verilator 5.052, original VPI HDL backend | 7 `pass`; 1 `fail` | Separate overlapping 8-case condition; matches at seeds 1/73, difference at seed 1 |
| Verilator 5.052, original command-line VPI bridge and pinned regex DPI | 17 `pass`; 1 `known` | Separate overlapping 18-case condition; matches at seeds 1/73, difference at seed 1 |
| kirimasim, pinned UVM | 1074 `unsupported`; nine `fail` | 1083 unchanged inputs; 541 inputs unmeasured |
| Ghost, bundled UVM | 207 `pass`; 876 `fail` | 1083 unchanged inputs at each seed; identical failing sets; 541 inputs unmeasured |
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
executed at runtime, including the accepted ones. The 47 unexpected simulation
build failures remain separate. A `pass` requires the declared expectation.

The 202 spec-only cases retain standard-derived output or compile-diagnostic expectations.
Two are illegal compiler acceptances; 200 are simulation cases. Of these, 153
first differ at runtime seed 1 without seed 73. Eighteen cannot build because
of missing APIs/type names: one time API, six sequence-library APIs, four HDL
slice cases, one named-concat constructor, one object active-policy API, three
catcher message-handle cases, the printed base recording-state getter and the
printed report callback typedef. Two declaration builds retain incompatible
defaults; one retains the printed all_dropped function versus the available task.
Another 26 request unlinked DPI: eight HDL and eighteen command-line cases.
These 47 simulation builds have no runtime result. Separate command-line
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

The ordinary snapshot retains all 1609 earlier input identities and records from
[e3456d1](https://github.com/kurochan001/kirimasim-uvm-tests/commit/e3456d1e9af0222feec3be9e2b019e4722341dea)
and adds fifteen M3 runtime fixtures measured on 2026-11-04 JST. Thirteen match
both seeds; two retain effective-width differences at seed 1 without seed 73.
Empty and populated child maps report local width eight where the root-path
minimum is two. Those are two applicability fixtures, not two independently
isolated defects. The word-unit oracle retains the qualified printed
get_n_bytes default interpretation; the width difference prevents inferring
a separate unit defect from the numeric mismatch alone.

New matching cases cover map names/object views and the backdoor singleton,
local/system endian and sequencer/adapter queries, six map-specific enumeration
families, byte/word memory lookup boundaries and unmapped memory access through
an original custom frontdoor. A separate nested actual bus path changes the root
sequencer/adapter after completed transfers and observes independent storage.
Enumeration uses handle sets and counts without assigning iteration order.

Fifty-seven bilingual AI drafts and two individually read assessments are added.
All 2716 earlier requirements, 283 assessments and 1609 fixtures/records
remain unchanged. No new guest
measurement, human review, approved denominator or completion is claimed.
Schema, runners/library/catalog, workflow and SVGs remain unchanged.

Retained kirimasim/Ghost records were collected with fixed executable
snapshots and Ghost's seed-specific private profiles.

Commercial simulator results are excluded under the
[reporting policy](faq.md#commercial-simulator-and-issue-reporting-policy).

The earlier temporary kirimasim/Ghost executable/profile snapshots are no
longer available, so no guest rerun is claimed. Historical files retain 1085
records. Two current inputs differ: a command-enum citation and the corrected
Boolean rerandomization observation. Their stale records are excluded.
The compatible current subset has 1083 records: kirimasim 1074 unsupported/
nine missing-API failures; Ghost 207 pass/876 fail at each seed. The 541
unmeasured inputs are 539 additions and the two revised old inputs. The filtered
files and `out/thin-fifty-first-evidence-scope.json` retain the explicit exclusions
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
  their declared 1083-case subset; 541 input IDs remain unmeasured.
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

The [draft requirement ledger](requirements.md) has 2773 AI drafts. Fifty-seven
new duties cover map construction/singleton, hierarchy, settings, enumeration,
memory membership and lookup. 18.2 is contextual and 18.2.5 is structural after
individual reading. Totals are 1498 partial/285 assessed/724 unassessed;
chapter 18 is 260/30/166. Under 18.2, clone_and_update at 18.2.3.12 remains
unassessed: its printed prototype supplies no explicit map return type, and
the clone observation route must be derived without inventing an undocumented
return or registration contract. A callable marker alone would not prove the
required cloned content/rights behavior. Partial map conditions remain open.

Guest files keep 1083 byte-identical compatible records; 541 inputs remain
unmeasured (498 simulation/43 elaboration), including both earlier revised
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
1624 metadata records and the draft ledger/index. Its 1422 tagged ordinary
Verilator checks comprise 1381 runtime cases at seeds 1/73 and forty-one compiler
rejections without runtime seeds, plus seventeen
explicit command-line checks under their separate condition.
It does not run kirimasim, Ghost or spec-only cases. The README's badge is the
live CI state, separate from these local measurements. A green Check does
not establish complete UVM conformance or a passing result for every simulator.
There is no Nightly workflow or automatic result publication.
