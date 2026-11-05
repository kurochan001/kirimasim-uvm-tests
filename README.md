# kirimasim-uvm-tests

[日本語](README.ja.md)

[![Check](https://github.com/kurochan001/kirimasim-uvm-tests/actions/workflows/check.yml/badge.svg)](https://github.com/kurochan001/kirimasim-uvm-tests/actions/workflows/check.yml)
[![License: Apache-2.0 WITH LLVM-exception](https://img.shields.io/badge/license-Apache--2.0%20WITH%20LLVM--exception-blue)](LICENSE)

A simulator conformance test suite for IEEE 1800.2-2020, the Universal
Verification Methodology (UVM). It targets
[kirimasim](https://github.com/kurochan001/kirimasim) and complements
[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests), which tests
the IEEE 1800-2023 SystemVerilog language.

An oracle records the basis of an expected result; the tags below are explained in
[Standards and expectations](docs/glossary.md#standards-and-expectations).

> **Status: M4 in progress.** 2208 tests: 2116 simulation and 92 elaboration,
> in 21 chapter/annex directories; 1900 tagged oracles and 308 spec-only cases.
> All use `:spec_check: ai`; none records human review. M1–M3 targets remain open.
> M4 has 3796 AI drafts, 2184 directly linked tests and an index of all 2208.
> 0 tests lack requirement links and 0 drafts lack direct tests; the historical
> memory-walk interpretation requires review. 141 identifiers remain unassessed;
> 405 have explicit AI classifications. Scope and denominator remain unapproved.

## Contents

Test counts, execution matches and review status measure different things; [the reading guide](docs/reading-guide.md) explains how they fit together.

- [Current scope](#current-scope)
- [Running the suite](#running-the-suite)
- [Current results](#current-results)
- [Documentation](#documentation)
- [Plan](#plan), [reporting issues](#reporting-issues) and [license](#license)

## Current scope

- **M1: 948 tests (869 simulation, 79 elaboration).** Objects and policies,
  reporting, factory, hierarchy, phases, synchronization, configuration,
  recording, core services and typed utilities.
- **M2: 547 tests (542 simulation, 5 elaboration).** Sequences and sequencers,
  request/response lifecycle, callbacks, TLM 1 channels and selected TLM 2 transports.
- **M3: 713 tests (705 simulation, 8 elaboration).** Register, field, block,
  memory and virtual-register models; access paths, prediction, callbacks,
  coverage, allocation and built-in test sequences; D.3 fixtures in uD count as M3.

Frontdoor and backdoor are access routes; the [register glossary](docs/glossary.md#register-model) explains their roles and the distinction from actual HDL access.
Built-in frontdoors use testbench adapter/sequencer/driver connections.
Custom frontdoors model storage in their sequence bodies; passive predictor
fixtures supply observations separately. User backdoors model storage through
`uvm_reg_backdoor` extensions. Eleven separate HDL fixtures use actual public
variables through an original VPI backend; see the testing guide.
Eighteen command-line fixtures opt into a separate VPI argument bridge and
pinned UVM regex DPI; seventeen match both seeds and one retains a diagnostic
severity difference. Their ordinary runs do not link that backend.

Expected results follow the cited standard, and normative expectations remain
when a simulator/library combination differs. The SystemVerilog language
itself belongs to kirimasim-tests.

Test counts and clause citations are not a reviewed requirement-coverage
percentage. M4 provides a primary-citation census and explicit requirement links;
normative decomposition and denominator approval remain open. See the
[requirement ledger guide](docs/requirements.md) and [FAQ](docs/faq.md).

## Running the suite

Start with one test to check your setup; [the first-run notes](docs/reading-guide.md#before-the-first-run) explain the prerequisites and seed options.

Use Python 3.10 or later. The fixed-release oracle requires Verilator 5.052,
a C++ toolchain and make. Run from the repository root:

```sh
python3 tools/fetch_uvm.py
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 1 \
  --json out/verilator-smoke.json tests/u09/test_common_phases_run_in_order.sv
```

The fetcher checks the pinned Accellera UVM 2020.3.1 library. The smoke
command selects one test. To run all 1900 tagged checks (1813 runtime, 87 compile rejection):

```sh
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 2 \
  --json out/verilator.json
```

Add `--all` to include all two-state cases, including the 308 spec-only cases.
`known` results do not fail that command; tagged regressions do. `-j` controls concurrent tests and `--build-jobs` controls C++ jobs within each build; [Q13](docs/faq.md#q13-why-is-compilation-heavy-and-what-do-the-two-job-options-control) explains the build cost.
Each runtime model is built once and run in a fresh process for each seed.

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

Simulation matches and compiler rejections are different checks; [the result guide](docs/reading-guide.md#read-a-result) explains the labels and counts below.

The Verilator snapshot assembled on 2026-11-06 covers all 2208 current cases.
Guest records retain 1082 compatible inputs; 1126 inputs are unmeasured.
These results are separate from the Check badge.

| Simulator and library | Observed result |
| --- | --- |
| Verilator 5.052, pinned UVM, ordinary runner | 1813 runtime matches at seeds 1/73; 87 expected compile rejections; 308 known differences |
| Verilator 5.052, original VPI HDL backend | Separate 11-case subset: 10 match both seeds; 1 differs |
| Verilator 5.052, VPI command-line bridge and pinned regex DPI | Separate 18-case subset: 17 match both seeds; 1 known difference |
| kirimasim, pinned UVM | 1073 `unsupported`; nine missing-API `fail` in 1082 cases; 1126 unmeasured |
| Ghost, bundled UVM | 206 match and 876 fail at each seed in 1082 cases; 1126 unmeasured |

The ordinary runner records 220 runtime differences at seed 1, 83 simulation build failures
and five accepted illegal designs without runtime; [the detailed breakdown](docs/results.md#interpretation) explains API/declaration, macro and DPI categories and qualified premises.
The two VPI subsets are separate conditions.

`known` and `unsupported` are not passes. Ghost bundled results do not establish
results for the pinned library.

[Results and methodology](docs/results.md) gives the full execution conditions
and evidence scope. [Known differences](docs/known-differences.md) lists the
library limitations and spec-only tests. [Check](.github/workflows/check.yml)
runs tool, metadata, library, tagged ordinary Verilator across 8 shards and seventeen explicit
command-line checks; it does not run
kirimasim or Ghost. There is no Nightly workflow or automatic result publication.

## Documentation

Every guide has complete English and Japanese versions. Each page links to
its counterpart; commands and API identifiers retain their original spelling.

| Guide | English | 日本語 |
| --- | --- | --- |
| Reading order and explanations for a first visit | [Reading guide](docs/reading-guide.md) | [読み方ガイド](docs/reading-guide.ja.md) |
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
| M1 | Core classes, policies, factory, phases and their graphs, objections, configuration and reporting | 948 tests; reviewed two-tests-per-clause target open |
| M2 | Sequences, sequencers, TLM and callbacks | 547 tests; target open |
| M3 | Register layer (17–19, D.3, annex E) | 713 tests across chapters 17–19, D.3 and annex E; target open |
| M4 | Requirement ledger and coverage | In progress: 3796 AI drafts; 3796 requirements link to 2184 tests; denominator unapproved |

M1–M3 remain incomplete; [the milestone glossary](docs/glossary.md#scope-and-coverage) explains why starting M4 does not complete them. Further work covers sequence ownership/lifecycle,
default resources, callbacks and TLM 2 protocol/timing/socket combinations;
register allocation/lifecycle, memory packing/partial beats, error/policy/map/
prediction/frontdoor/callback/HDL and annex E combinations. Library annotations
need standard review. RTL protocol and timing coverage remain separate work.

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
