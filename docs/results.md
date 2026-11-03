# Current results and measurement methodology

[日本語](results.ja.md) · [README](../README.md) · [Known differences](known-differences.md)

## Current snapshot

The Verilator snapshot assembled on 2026-11-04 covers all 1472 current tests.
Guest records retain 1084 compatible current inputs; 388 inputs are
unmeasured, including one metadata-revised old fixture. Each record
fingerprints its inputs and conditions.
The suite has 1472 fixtures in 21 directories: 1447 simulation and 25
elaboration. Milestone totals are M1 524 (507/17), M2 516 (513/3) and M3 432
(427/5), with runtime/elaboration counts in parentheses. All use `spec_check: ai`;
none records human review. Of 1446 no-DPI fixtures, 25 are illegal elaboration
checks. The eight HDL-DPI and eighteen command-line/regex-DPI runtime fixtures
remain separate.

Counts do not establish a reviewed coverage percentage.

| Simulator and library | Observation | Execution scope |
| --- | --- | --- |
| Verilator 5.052, pinned UVM | 1290 `pass`: 1267 runtime + 23 compile rejection; 182 `known` | Runtime matches use seeds 1/73; expected compiler rejections execute no runtime seed |
| Verilator 5.052, original VPI HDL backend | 7 `pass`; 1 `fail` | Separate overlapping 8-case condition; matches at seeds 1/73, difference at seed 1 |
| Verilator 5.052, original command-line VPI bridge and pinned regex DPI | 17 `pass`; 1 `known` | Separate overlapping 18-case condition; matches at seeds 1/73, difference at seed 1 |
| kirimasim, pinned UVM | 1075 `unsupported`; nine `fail` | 1084 unchanged inputs; 388 inputs unmeasured |
| Ghost, bundled UVM | 207 `pass`; 877 `fail` | 1084 unchanged inputs at each seed; identical failing sets; 388 inputs unmeasured |
| Ghost, pinned UVM | Not measured for the current executable snapshot | No current pinned-mode claim |

The pinned library is Accellera UVM 2020.3.1, commit `78c06547a2a0`, with
326 files checked against [the lock](../third_party/uvm.lock). A Ghost bundled
run uses the supplied library rather than that lock's package. Private
simulator identity, version, paths, profile contents and diagnostics are
not published. [Ghost setup](testing.md#ghost) describes the public interface.
Icarus Verilog is not used for this UVM suite.

## Interpretation

Twenty-three valid negative expectations match by compiler rejection with the
declared fixture/class/method or const-reference diagnostic. Two other illegal
designs are accepted: subscriber write and visitor visit are left unimplemented.
These retain the rejection oracle as known differences. No illegal design is
executed at runtime, including the accepted ones. The 43 unexpected simulation
build failures remain separate. A `pass` requires the declared expectation.

The 182 spec-only cases retain standard-derived output or compile-diagnostic expectations.
Two are illegal compile acceptances; the other 180 are simulation differences. In the
ordinary condition, 137 first differ at runtime seed 1, without a seed 73
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

The ordinary snapshot retains all 1446 unchanged input records from
[a8258fb](https://github.com/kurochan001/kirimasim-uvm-tests/commit/a8258fb2f84e5cbcaab824e49d21a8bf211aed30)
and adds 26 inputs measured on 2026-11-04 JST. Sixteen new runtime fixtures
match seeds 1/73; two virtual policy/printer constructions reject with the
declared diagnostic and no runtime seeds. Eight new printer fixtures first
differ at seed 1 without seed 73. All earlier known records remain unchanged.

The differences cover SHALLOW recursion, an entry-depth boundary interpretation,
an independently already-above-bound scope, disabled radix prefixes, the root
control default, and table/tree/line controls after flush. The boundary reading
remains qualified; the above-bound probe starts with two active entries and
limits zero/one, avoiding equality. Matching earlier rows never make a whole
fixture pass. No measured mismatch is used to replace a normative expectation.

Initial observer handling was corrected to accept decimal generic values as
well as raw integers. Final source hashes include promoted tags only on matches.
The 2177 earlier requirement IDs and links remain; one constructor entry gains
a direct link. Ninety-seven new bilingual drafts and thirteen individually read
assessments are added. Two initially overlapping drafts were removed rather
than duplicating an existing obligation. All prior fixture inputs/records,
assessments, runner/library/catalog, schema, workflow and SVGs are unchanged.

Retained kirimasim/Ghost records were collected with fixed executable
snapshots and Ghost's seed-specific private profiles.

Commercial simulator results are excluded under the
[reporting policy](faq.md#commercial-simulator-and-issue-reporting-policy).

The prior temporary kirimasim/Ghost executable/profile snapshots are no
longer available. No new guest run is claimed. Their historical files contain
1085 records; exactly one command fixture now has a changed citation/fingerprint
and is excluded. The compatible current subset has 1084 records: kirimasim
1075 unsupported/nine missing-API failures; Ghost 207 pass/877 fail at each
seed. There are 388 unmeasured current inputs: 387 additions since those
snapshots and the revised command fixture. The filtered files and
`out/thin-forty-second-evidence-scope.json` preserve this distinction until
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
  their declared 1084-case subset; 388 input IDs remain unmeasured.
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

The [draft requirement ledger](requirements.md) now has 2274 AI drafts.
The 97 new entries cover selected message/handler print content, printer hooks
and history, recursion, element/array structure, radix controls, root names,
prefixes, constructors/base types and default-instance lifecycles. Eleven
grouping headings and two representational introductions have explicit related
requirements where contextual. Totals: 1273 partial, 204 assessed and 1,030
unassessed. Chapter 6 is 98/19/0, with all partial conditions open. Chapter 16
is 132/13/63; printer subclause 16.2 retains one unassessed table-format overview.

All 1084 compatible guest runtime records remain; 388 inputs are unmeasured
(363 simulation/25 elaboration). No guest run is claimed. Zero unassessed in
one chapter, structure/marker observations and zero direct-link queues do not
certify complete formatting, normative coverage or an approved denominator.

## Reproducing and retaining results

The [testing guide](testing.md#running-the-suite) documents the commands,
profile modes and library settings. Request `--json out/<name>.json` to retain
statuses, reasons, configuration and fingerprints. `out/` is ignored by Git,
and Check does not publish these local evidence files. A result from different
inputs, a different runner, executable, profile or library is a separate condition.

## Continuous integration

[Check](../.github/workflows/check.yml) runs on pushes to `main`, pull requests
and manual dispatch. It checks pinned-library integrity, 110 tool unit tests,
1472 metadata records and the draft ledger/index. Its 1290 tagged ordinary
Verilator checks comprise 1267 runtime cases at seeds 1/73 and twenty-three compiler
rejections without runtime seeds, plus seventeen
explicit command-line checks under their separate condition.
It does not run kirimasim, Ghost or spec-only cases. The README's badge is the
live CI state, separate from these local measurements. A green Check does
not establish complete UVM conformance or a passing result for every simulator.
There is no Nightly workflow or automatic result publication.
