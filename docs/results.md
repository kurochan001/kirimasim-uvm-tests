# Current results and measurement methodology

[日本語](results.ja.md) · [README](../README.md) · [Known differences](known-differences.md)

## Current snapshot

The local evidence dated 2026-11-01 covers the 757 current tests. Each record
identifies its test inputs and execution conditions through fingerprints.
The suite contains
229 M1, 360 M2 and 168 M3 cases in 14 chapter/annex directories. All record
`spec_check: ai`, use `UVM_NO_DPI` and request no deprecated API. None records
human review. Counts do not establish a reviewed requirement-coverage percentage.

| Simulator and library | Observation | Execution scope |
| --- | --- | --- |
| Verilator 5.052, pinned UVM | 691 `pass`; 66 `known` | Matches reproduced at seeds 1 and 73; runtime differences stop at seed 1 |
| kirimasim, pinned UVM | 750 `unsupported`; seven `fail` | Fixed executable build and all current inputs |
| Ghost, bundled UVM | 150 `pass`; 607 `fail` | Each of seeds 1 and 73; identical failing sets |
| Ghost, pinned UVM | Not measured for the current executable snapshot | No current pinned-mode claim |

The pinned library is Accellera UVM 2020.3.1, commit `78c06547a2a0`, with
326 files checked against [the lock](../third_party/uvm.lock). A Ghost bundled
run uses the supplied library rather than that lock's package. Private
simulator identity, version, paths, profile contents and diagnostics are
not published. [Ghost setup](testing.md#ghost) describes the public interface.
Icarus Verilog is not used for this UVM suite.

## Interpretation

The 66 spec-only cases retain standard-derived expected output. Of their
Verilator records, 59 first differ at runtime seed 1. The runner stops at that
seed, so those records contain no seed 73 result. Seven cannot build because
of missing library APIs: one time API and six sequence-library APIs. They
have no runtime seed result. The known-differences guide links every spec-only
case and describes the combined simulator/library limitation where the cause
has not been assigned.

kirimasim reports `uvm_object_wrapper` as unsupported on 750 cases; the other
seven encounter missing library APIs first. Neither category establishes
execution of the UVM behavior beyond those blockers. Ghost's bundled
mismatches do not identify whether the simulator or its library caused them,
and they do not establish results for the pinned library.

`known` and `unsupported` are not passes. A command's exit code alone is not
a suite pass count; the [FAQ](faq.md#understanding-a-result) explains status
and exit-code rules. Two seeds do not prove determinism or four-state correctness.

## Evidence assembly

The current snapshot combines an unchanged 733-case baseline at
[ac008b6](https://github.com/kurochan001/kirimasim-uvm-tests/commit/ac008b6a6353a0c3bafc17348ea4cccf9759b83f)
with 24 newly measured cases. Verilator uses the fixed release; kirimasim and
the project's guest Ghost use fixed executable snapshots. Ghost reuses the
same private profile snapshot for each seed as its baseline. Commercial
simulator results are excluded under the
[reporting policy](faq.md#commercial-simulator-and-issue-reporting-policy).

Before combining records, check that:

- Test IDs cover the current suite exactly, without missing or extra cases.
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

## Reproducing and retaining results

The [testing guide](testing.md#running-the-suite) documents the commands,
profile modes and library settings. Request `--json out/<name>.json` to retain
statuses, reasons, configuration and fingerprints. `out/` is ignored by Git,
and Check does not publish these local evidence files. A result from different
inputs, a different runner, executable, profile or library is a separate condition.

## Continuous integration

[Check](../.github/workflows/check.yml) runs on pushes to `main`, pull requests
and manual dispatch. It checks pinned-library integrity, 41 tool unit tests,
757 metadata records and the 691 tagged Verilator cases using seeds 1 and 73.
It does not run kirimasim, Ghost or spec-only cases. The README's badge is the
live CI state, separate from these local measurements. A green Check does
not establish complete UVM conformance or a passing result for every simulator.
There is no Nightly workflow or automatic result publication.
