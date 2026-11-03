# kirimasim-uvm-tests

[日本語](README.ja.md)

[![Check](https://github.com/kurochan001/kirimasim-uvm-tests/actions/workflows/check.yml/badge.svg)](https://github.com/kurochan001/kirimasim-uvm-tests/actions/workflows/check.yml)
[![License: Apache-2.0 WITH LLVM-exception](https://img.shields.io/badge/license-Apache--2.0%20WITH%20LLVM--exception-blue)](LICENSE)

A simulator conformance test suite for IEEE 1800.2-2020, the Universal
Verification Methodology (UVM). It targets
[kirimasim](https://github.com/kurochan001/kirimasim) and complements
[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests), which tests
the IEEE 1800-2023 SystemVerilog language.

> **Status: M4 in progress.** 1201 simulation tests in 21 chapter/annex
> directories; 1073 have a `verilator@5.052` oracle and 128 are spec-only.
> All use `:spec_check: ai`; none records human review.
> M1, M2 and M3 retain open requirement-coverage targets.
> M4 has 1395 draft requirements, 1200 directly linked tests and an index of all 1201;
> 0 tests lack requirement links and 0 drafts lack direct tests, including a
> qualified historical memory-walk interpretation. 1,584 identifiers remain
> unassessed; forty-six others have explicit AI classifications. Scope remains unapproved.

## Contents

- [Current scope](#current-scope)
- [Running the suite](#running-the-suite)
- [Current results](#current-results)
- [Documentation](#documentation)
- [Plan](#plan), [reporting issues](#reporting-issues) and [license](#license)

## Current scope

- **M1: 401 cases.** Objects, transactions and copy/compare/print/pack policies;
  reporting, hierarchy, factory, phases and graphs, objections, events and
  callbacks, barriers, configuration, database connections/streams/links/
  recorders, component recording, core services, visitors, component searches, pools, queues,
  agents, string splitting/matching, enum-name and command-line queries.
- **M2: 437 cases.** TLM 1 FIFOs, analysis, request/response and blocking
  transport channels; TLM 2 payloads, extensions and selected socket transports;
  sequences/libraries, state waits, response queues/handlers, reporting, action macros, pull/push
  sequencers and callbacks.
- **M3: 363 cases.** Register/field/block and memory models, hierarchy queries,
  field controls, operation descriptors, maps, read checks, transaction-order policies, adapters,
  predictors, HDL paths, built-in/custom frontdoors, sequence convenience
  APIs, callbacks, coverage controls/sampling, indirect registers, virtual-register
  layout/transfers/allocation/callbacks, user backdoors, dynamic implementation,
  memory regions, partial-width transfers, failure/retry status and annex E
  reset/bit-bash/register/memory/shared access, memory-walk sequences, combined
  access wrappers, unknown-policy skips and selected test-dispatch masks.

Built-in frontdoors use testbench adapter/sequencer/driver connections.
Custom frontdoors model storage in their sequence bodies; passive predictor
fixtures supply observations separately. User backdoors model storage through
`uvm_reg_backdoor` extensions. Eight separate HDL fixtures use actual public
variables through an original VPI backend; see the testing guide.
Expected results follow the cited standard, and normative expectations remain
when a simulator/library combination differs. The SystemVerilog language
itself belongs to kirimasim-tests.

Test counts and clause citations are not a reviewed requirement-coverage
percentage. M4 provides a primary-citation census and explicit requirement links;
normative decomposition and denominator approval remain open. See the
[requirement ledger guide](docs/requirements.md) and [FAQ](docs/faq.md).

## Running the suite

Use Python 3.10 or later. The fixed-release oracle requires Verilator 5.052,
a C++ toolchain and make. Run from the repository root:

```sh
python3 tools/fetch_uvm.py
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 1 \
  --json out/verilator-smoke.json tests/u09/test_common_phases_run_in_order.sv
```

The fetcher checks the pinned Accellera UVM 2020.3.1 library. The smoke
command selects one test. To run all 1073 tagged cases:

```sh
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 2 \
  --json out/verilator.json
```

Add `--all` to include all two-state cases, including the 128 spec-only cases.
`known` results do not fail that command; tagged regressions do. `-j` controls
concurrent tests and `--build-jobs` controls C++ jobs within each build.
Each model is built once and run in a fresh process for each seed.

For kirimasim:

```sh
python3 tools/run_kirimasim.py --kirimasim /path/to/kirimasim -j 8 \
  --json out/kirimasim.json
```

kirimasim and Ghost select all cases by default. See the
[testing guide](docs/testing.md#running-the-suite) for library/DPI settings,
Ghost profiles, test metadata, judgment rules and checks. `out/` is ignored
by Git; results are not automatically published.

## Current results

The Verilator evidence dated 2026-11-03 covers all 1201 current cases.
Guest records cover 1085 unchanged cases; 116 additions are unmeasured.
These results are separate from the Check badge.

| Simulator and library | Observed result |
| --- | --- |
| Verilator 5.052, pinned UVM, ordinary runner | 1073 match seeds 1 and 73; 128 known differences |
| Verilator 5.052, original VPI HDL backend | Separate 8-case subset: 7 match both seeds; 1 differs |
| kirimasim, pinned UVM | 1076 `unsupported`; nine missing-API `fail` in 1085 cases; 116 unmeasured |
| Ghost, bundled UVM | 207 match and 878 fail at each seed in 1085 cases; 116 unmeasured |

The ordinary runner records 110 runtime differences at seed 1, 10 missing-API
builds and eight unlinked-DPI builds. The VPI subset is a separate condition.
`known` and `unsupported` are not passes. Ghost bundled results do not establish
results for the pinned library.

[Results and methodology](docs/results.md) gives the full execution conditions
and evidence scope. [Known differences](docs/known-differences.md) lists the
library limitations and spec-only tests. [Check](.github/workflows/check.yml)
runs tool, metadata, library and tagged Verilator checks; it does not run
kirimasim or Ghost. There is no Nightly workflow or automatic result publication.

## Documentation

Every guide has complete English and Japanese versions. Each page links to
its counterpart; commands and API identifiers retain their original spelling.

| Guide | English | 日本語 |
| --- | --- | --- |
| Resuming development and remaining work | [Handoff](docs/handoff.md) | [ハンドオフ](docs/handoff.ja.md) |
| Test format, execution and contributions | [Testing guide](docs/testing.md) | [テストと開発のガイド](docs/testing.ja.md) |
| Current measurements and methodology | [Results](docs/results.md) | [実行結果](docs/results.ja.md) |
| Draft scope, requirement links and coverage census | [Requirement ledger](docs/requirements.md) | [要求台帳](docs/requirements.ja.md) |
| Terminology | [Glossary](docs/glossary.md) | [用語集](docs/glossary.ja.md) |
| Behavior and fixture scope | [FAQ](docs/faq.md) | [FAQ](docs/faq.ja.md) |
| Library limitations and spec-only tests | [Known differences](docs/known-differences.md) | [既知差分](docs/known-differences.ja.md) |
| Development and measurement history | [History](docs/history.md) | [開発履歴](docs/history.ja.md) |
| Repository relationship and source attribution | [Provenance](docs/provenance.md) | [出典](docs/provenance.ja.md) |

## Plan

| Stage | Scope | Current state / target |
| --- | --- | --- |
| M0 | Fetcher, runners, metadata/tools checks, Check and smoke test | Infrastructure implemented |
| M1 | Core classes, policies, factory, phases and their graphs, objections, configuration and reporting | 401 cases; reviewed two-tests-per-clause target open |
| M2 | Sequences, sequencers, TLM and callbacks | 437 cases; target open |
| M3 | Register layer (17–19, annex E) | 363 cases in chapters 17–19 and annex E; target open |
| M4 | Requirement ledger and coverage | In progress: 1395 AI drafts; 1395 requirements link to 1200 tests; denominator unapproved |

M1, M2 and M3 are independently incomplete. Remaining M2 work includes queued
ownership/termination/default-resource conditions, callbacks and broader
TLM 2 protocol, timing and socket combinations. Remaining M3 work includes
broader allocation-policy and lifecycle/transfer conditions,
memory packing/partial beats, error/policy/map combinations, integrated
prediction, frontdoor/callback combinations, HDL-path/DPI, and broader
annex E policy/error/mask conditions.
Library annotations can guide the inventory but need review against the
standard. RTL protocol and timing coverage remain separate work.

## Reporting issues

Commercial simulator results, outputs and diagnostics are not used or accepted,
including third-party material, anonymized summaries, attachments and links.
Use the [posting policy](docs/faq.md#commercial-simulator-and-issue-reporting-policy)
and bilingual [Issue form](.github/ISSUE_TEMPLATE/report.yml). Describe expected
behavior using IEEE 1800.2-2020 clauses and an independent reproducer.

## License

Apache License 2.0 with LLVM Exceptions (`Apache-2.0 WITH LLVM-exception`).
[LICENSE](LICENSE) is the original text; [日本語参考訳](LICENSE.ja.md) is a
complete, non-authoritative translation. Source attribution and rights
handling are in [provenance](docs/provenance.md) and the
[testing guide](docs/testing.md#rights-and-sources).
