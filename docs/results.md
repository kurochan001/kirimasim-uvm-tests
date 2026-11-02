# Current results and measurement methodology

[日本語](results.ja.md) · [README](../README.md) · [Known differences](known-differences.md)

## Current snapshot

The Verilator evidence dated 2026-11-03 covers all 1106 current tests.
Guest records cover 1085 unchanged current-input tests, with twenty-one new
tests unmeasured. Each record fingerprints its inputs and conditions.
The suite contains
360 M1, 420 M2 and 326 M3 cases in 21 chapter/annex directories. All record
`spec_check: ai`, use `UVM_NO_DPI` and request no deprecated API. None records
human review. Counts do not establish a reviewed requirement-coverage percentage.

| Simulator and library | Observation | Execution scope |
| --- | --- | --- |
| Verilator 5.052, pinned UVM | 999 `pass`; 107 `known` | Matches reproduced at seeds 1 and 73; runtime differences stop at seed 1 |
| kirimasim, pinned UVM | 1076 `unsupported`; nine `fail` | 1085 unchanged inputs; twenty-one new tests unmeasured |
| Ghost, bundled UVM | 207 `pass`; 878 `fail` | 1085 unchanged inputs at each seed; identical failing sets; twenty-one new tests unmeasured |
| Ghost, pinned UVM | Not measured for the current executable snapshot | No current pinned-mode claim |

The pinned library is Accellera UVM 2020.3.1, commit `78c06547a2a0`, with
326 files checked against [the lock](../third_party/uvm.lock). A Ghost bundled
run uses the supplied library rather than that lock's package. Private
simulator identity, version, paths, profile contents and diagnostics are
not published. [Ghost setup](testing.md#ghost) describes the public interface.
Icarus Verilog is not used for this UVM suite.

## Interpretation

The 107 spec-only cases retain standard-derived expected output. Of their
Verilator records, 97 first differ at runtime seed 1. The runner stops at that
seed, so those records contain no seed 73 result. Ten cannot build because
of missing library APIs: one time API, six sequence-library APIs, two HDL
slice APIs and one object active-policy API. They
have no runtime seed result. The known-differences guide links every spec-only
case and describes the combined simulator/library limitation where the cause
has not been assigned.

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

The current snapshot retains all 1105 unchanged Verilator records from
[88b6f34](https://github.com/kurochan001/kirimasim-uvm-tests/commit/88b6f3423ce0f7963036b9485f9ffa97eac49229)
and adds one measured policy/object synchronization fixture. Existing test bodies,
metadata and expected output are unchanged by this increment. Verilator uses
the fixed release. The retained kirimasim/Ghost records were collected with
fixed executable snapshots and Ghost's seed-specific private profiles.
Commercial simulator results are excluded under the
[reporting policy](faq.md#commercial-simulator-and-issue-reporting-policy).

The prior temporary kirimasim/Ghost executable/profile snapshots are no
longer available, and no compatible local replacement was found. No new
guest run is claimed. Their existing 1085 records still match current
inputs; the twenty-one new test IDs are explicitly unmeasured. The local
scope record is `out/zero-evidence-scope.json`. Preserve this
partial scope until the authorized execution environment is restored.

Before combining records, check that:

- Verilator IDs cover the current suite exactly. Retained guest IDs match
  their declared 1085-case subset; twenty-one new IDs remain unmeasured.
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

The [draft ledger](requirements.md) maps the new policy fixture and all
108 previously unlinked existing tests. Only new simulation
inputs are measured anew with Verilator; no new guest measurement is added.
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
and manual dispatch. It checks pinned-library integrity, 74 tool unit tests,
1106 metadata records, the draft requirement ledger/test index and the 999
tagged Verilator cases using seeds 1 and 73.
It does not run kirimasim, Ghost or spec-only cases. The README's badge is the
live CI state, separate from these local measurements. A green Check does
not establish complete UVM conformance or a passing result for every simulator.
There is no Nightly workflow or automatic result publication.
