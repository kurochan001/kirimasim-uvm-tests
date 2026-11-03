# Current results and measurement methodology

[日本語](results.ja.md) · [README](../README.md) · [Known differences](known-differences.md)

## Current snapshot

The Verilator evidence dated 2026-11-03 covers all 1238 current tests.
Guest records cover 1085 unchanged current-input tests, with 153 new
tests unmeasured. Each record fingerprints its inputs and conditions.
The suite contains 417 M1, 446 M2 and 375 M3 cases in 21 chapter/annex
directories. All record `spec_check: ai`; none records human review or asks
for deprecated APIs. Of these, 1230 use `UVM_NO_DPI` and eight explicitly
request HDL DPI. Counts do not establish a reviewed coverage percentage.

| Simulator and library | Observation | Execution scope |
| --- | --- | --- |
| Verilator 5.052, pinned UVM | 1105 `pass`; 133 `known` | Matches reproduced at seeds 1 and 73; runtime differences stop at seed 1 |
| Verilator 5.052, original VPI HDL backend | 7 `pass`; 1 `fail` | Separate overlapping 8-case condition; matches at seeds 1/73, difference at seed 1 |
| kirimasim, pinned UVM | 1076 `unsupported`; nine `fail` | 1085 unchanged inputs; 153 new tests unmeasured |
| Ghost, bundled UVM | 207 `pass`; 878 `fail` | 1085 unchanged inputs at each seed; identical failing sets; 153 new tests unmeasured |
| Ghost, pinned UVM | Not measured for the current executable snapshot | No current pinned-mode claim |

The pinned library is Accellera UVM 2020.3.1, commit `78c06547a2a0`, with
326 files checked against [the lock](../third_party/uvm.lock). A Ghost bundled
run uses the supplied library rather than that lock's package. Private
simulator identity, version, paths, profile contents and diagnostics are
not published. [Ghost setup](testing.md#ghost) describes the public interface.
Icarus Verilog is not used for this UVM suite.

## Interpretation

The 133 spec-only cases retain standard-derived expected output. In the
ordinary condition, 115 first differ at runtime seed 1, without a seed 73
result. 10 cannot build because of missing library APIs: one time API, six
sequence-library APIs, two HDL slice APIs and one object active-policy API.
Eight more request HDL DPI without the backend being linked by that runner.
These eighteen build records have no ordinary runtime seed result.

The separate VPI condition measures eight HDL fixtures with the original
backend: seven match seeds 1/73. The inaccessible-path sequence first differs
at seed 1, reporting ERROR rather than warning and attempting storage reads
under the retained E.7 no-transfer interpretation. The accessible-path control
and actual HDL deposit/read cases match. This backend's 64-bit packed-variable
scope does not establish vendor overlays, arrays or four-state behavior.
Do not add its overlapping pass count to the ordinary total. See
[HDL setup](testing.md#verilator-vpi-hdl-subset) and [known differences](known-differences.md).

kirimasim reports `uvm_object_wrapper` as unsupported on 1076 cases; the other
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

The ordinary snapshot retains all 1226 unchanged records from
[4b24dd2](https://github.com/kurochan001/kirimasim-uvm-tests/commit/4b24dd2df0a3a4065e89685822a150444a41755d)
and adds twelve final-input measurements: ten match seeds 1 and 73; two retain
seed-1 differences in individual field byte-enabled access. The pinned library
rejects two byte-isolated fields sharing a physical word, uses a full-word mask,
and affects the neighboring stored byte or mirror. The no-byte-enable fallback
control matches both seeds. Existing simulation inputs, all runners and the VPI
backend are unchanged. The separate eight-case VPI snapshot is retained
unchanged and never merged into the ordinary condition.

Retained kirimasim/Ghost records were collected with fixed executable
snapshots and Ghost's seed-specific private profiles.

Commercial simulator results are excluded under the
[reporting policy](faq.md#commercial-simulator-and-issue-reporting-policy).

The prior temporary kirimasim/Ghost executable/profile snapshots are no
longer available, and no compatible local replacement was found. No new
guest run is claimed. Their existing 1085 records still match current
inputs; the 153 new test IDs are explicitly unmeasured. The local
scope record is `out/thin-twenty-fifth-evidence-scope.json`. Preserve this
partial scope until the authorized execution environment is restored.

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
  their declared 1085-case subset; 153 new IDs remain unmeasured.
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

The [draft requirement ledger](requirements.md) maps twelve new fixtures and
extends three unchanged kill-hook mappings through forty-four AI drafts.
Four structural classifications preserve separate bilingual rationale/review
records. New inputs are measured with Verilator only; no guest measurement
is added.

All baseline input and runner fingerprints remain
compatible. Zero unmapped tests is still not a completed normative inventory.
Ledger anchors describe expected output, not additional measured passes.

## Reproducing and retaining results

The [testing guide](testing.md#running-the-suite) documents the commands,
profile modes and library settings. Request `--json out/<name>.json` to retain
statuses, reasons, configuration and fingerprints. `out/` is ignored by Git,
and Check does not publish these local evidence files. A result from different
inputs, a different runner, executable, profile or library is a separate condition.

## Continuous integration

[Check](../.github/workflows/check.yml) runs on pushes to `main`, pull requests
and manual dispatch. It checks pinned-library integrity, 88 tool unit tests,
1238 metadata records, the draft requirement ledger/test index and the 1105
tagged Verilator cases using seeds 1 and 73.
It does not run kirimasim, Ghost or spec-only cases. The README's badge is the
live CI state, separate from these local measurements. A green Check does
not establish complete UVM conformance or a passing result for every simulator.
There is no Nightly workflow or automatic result publication.
