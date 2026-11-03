# Current results and measurement methodology

[日本語](results.ja.md) · [README](../README.md) · [Known differences](known-differences.md)

## Current snapshot

The Verilator evidence dated 2026-11-03 covers all 1408 current tests.
Guest records retain 1084 compatible current inputs; 324 inputs are
unmeasured, including one metadata-revised old fixture. Each record
fingerprints its inputs and conditions.
The suite contains 470 M1, 512 M2 and 426 M3 cases in 21 chapter/annex
directories. All record `spec_check: ai`; none records human review or asks
for deprecated APIs. Of these, 1382 use `UVM_NO_DPI` and eight explicitly
request HDL DPI. Eighteen more enable command-line/regex DPI with HDL disabled.
Counts do not establish a reviewed coverage percentage.

| Simulator and library | Observation | Execution scope |
| --- | --- | --- |
| Verilator 5.052, pinned UVM | 1237 `pass`; 171 `known` | Matches reproduced at seeds 1 and 73; runtime differences stop at seed 1 |
| Verilator 5.052, original VPI HDL backend | 7 `pass`; 1 `fail` | Separate overlapping 8-case condition; matches at seeds 1/73, difference at seed 1 |
| Verilator 5.052, original command-line VPI bridge and pinned regex DPI | 17 `pass`; 1 `known` | Separate overlapping 18-case condition; matches at seeds 1/73, difference at seed 1 |
| kirimasim, pinned UVM | 1075 `unsupported`; nine `fail` | 1084 unchanged inputs; 324 inputs unmeasured |
| Ghost, bundled UVM | 207 `pass`; 877 `fail` | 1084 unchanged inputs at each seed; identical failing sets; 324 inputs unmeasured |
| Ghost, pinned UVM | Not measured for the current executable snapshot | No current pinned-mode claim |

The pinned library is Accellera UVM 2020.3.1, commit `78c06547a2a0`, with
326 files checked against [the lock](../third_party/uvm.lock). A Ghost bundled
run uses the supplied library rather than that lock's package. Private
simulator identity, version, paths, profile contents and diagnostics are
not published. [Ghost setup](testing.md#ghost) describes the public interface.
Icarus Verilog is not used for this UVM suite.

## Interpretation

The 171 spec-only cases retain standard-derived expected output. In the
ordinary condition, 128 first differ at runtime seed 1, without a seed 73
result. 16 cannot build because of missing library APIs: one time API, six
sequence-library APIs, four HDL slice cases, one named-concat-constructor case,
one object active-policy API and three catcher message-handle cases.
One more cannot build because the bidirectional response default differs from
the declared independent integer type. Another 26 request DPI without the
corresponding backend being linked: eight HDL and eighteen command-line cases.
These forty-three build records have no
ordinary runtime seed result. The separate command-line condition reproduces
seventeen inputs and retains the quit-warning difference; the older two
no-DPI argument fixtures remain unchanged runtime differences.

The separate VPI condition measures eight HDL fixtures with the original
backend: seven match seeds 1/73. The inaccessible-path sequence first differs
at seed 1, reporting ERROR rather than warning and attempting storage reads
under the retained E.7 no-transfer interpretation. The accessible-path control
and actual HDL deposit/read cases match. This backend's 64-bit packed-variable
scope does not establish vendor overlays, arrays or four-state behavior.
Do not add its overlapping pass count to the ordinary total. See
[HDL setup](testing.md#verilator-vpi-hdl-subset) and [known differences](known-differences.md).

kirimasim reports `uvm_object_wrapper` as unsupported on 1075 cases; the other
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

The ordinary snapshot retains all 1396 unchanged records from
[1eedd32](https://github.com/kurochan001/kirimasim-uvm-tests/commit/1eedd326e86dfaa657fbadf0f4ed3c3620b7ec37)
and adds twelve current-input M2 fixtures. Nine match both seeds; three
qualified interpretation probes first differ at seed 1. They cover literal
nonblocking provider lists under blocking relay headings and a no-direct-entry
interpretation after forbidden same-kind terminator connects. Operational
blocking relays match; initiator rejection reports ERROR but keeps a raw entry.
Neither observation settles conflicting standard wording or proves a bug.
No seed 73 result exists for those three inputs.

Matching additions cover extension names/legal types, socket/port/export/imp
defaults and exact views, actual default imp delegation, explicit/parent socket
implementations, custom-phase two-way relays and all three listed nonblocking
initiator providers. Original backend algorithms are setup. An initial fixture
used a packed-string conditional label with leading padding; assigning each
label to a string corrected the formatting without changing normative output,
and both seeds were rerun. All earlier inputs/runners and separate VPI
conditions remain unchanged.

Retained kirimasim/Ghost records were collected with fixed executable
snapshots and Ghost's seed-specific private profiles.

Commercial simulator results are excluded under the
[reporting policy](faq.md#commercial-simulator-and-issue-reporting-policy).

The prior temporary kirimasim/Ghost executable/profile snapshots are no
longer available. No new guest run is claimed. Their historical files contain
1085 records; exactly one command fixture now has a changed citation/fingerprint
and is excluded. The compatible current subset has 1084 records: kirimasim
1075 unsupported/nine missing-API failures; Ghost 207 pass/877 fail at each
seed. There are 324 unmeasured current inputs: 323 additions since those
snapshots and the revised command fixture. The filtered files and
`out/thin-thirty-eighth-evidence-scope.json` preserve this distinction until
the authorized execution environment is restored.

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
  their declared 1084-case subset; 324 input IDs remain unmeasured.
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

The [draft requirement ledger](requirements.md) adds eighty-three AI drafts
for twelve new fixtures. All earlier drafts, assessments and fixture inputs
remain unchanged. Twelve individual structural assessments reach 182 total
(131 structural/51 contextual). Chapter 12 is 169 partial, 45 assessed and
zero unassessed; normative overviews are decomposed, not excluded. The active
M1–M4 goal retains 1,151 unassessed and 1,174 partially decomposed identifiers.
The compatible guest subset stays at 1084, with 324 current inputs unmeasured.
No guest execution is added.

All retained records must match current input and runner fingerprints. Zero
unlinked tests or zero chapter-12 unassessed identifiers does not complete the
normative inventory. Ledger anchors describe expected output, not additional
measured passes. Qualified interpretations require standard review.

## Reproducing and retaining results

The [testing guide](testing.md#running-the-suite) documents the commands,
profile modes and library settings. Request `--json out/<name>.json` to retain
statuses, reasons, configuration and fingerprints. `out/` is ignored by Git,
and Check does not publish these local evidence files. A result from different
inputs, a different runner, executable, profile or library is a separate condition.

## Continuous integration

[Check](../.github/workflows/check.yml) runs on pushes to `main`, pull requests
and manual dispatch. It checks pinned-library integrity, 101 tool unit tests,
1408 metadata records, the draft requirement ledger/test index and the 1237
tagged ordinary Verilator cases using seeds 1 and 73, plus seventeen
explicit command-line checks under their separate condition.
It does not run kirimasim, Ghost or spec-only cases. The README's badge is the
live CI state, separate from these local measurements. A green Check does
not establish complete UVM conformance or a passing result for every simulator.
There is no Nightly workflow or automatic result publication.
