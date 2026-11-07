# kirimasim-uvm-tests

[日本語](README.ja.md)

[![Check](https://github.com/kurochan001/kirimasim-uvm-tests/actions/workflows/check.yml/badge.svg)](https://github.com/kurochan001/kirimasim-uvm-tests/actions/workflows/check.yml)
[![License: Apache-2.0 WITH LLVM-exception](https://img.shields.io/badge/license-Apache--2.0%20WITH%20LLVM--exception-blue)](LICENSE)

Check reports an automated workflow run; [the CI scope](docs/results.md#continuous-integration) explains which checks its badge represents.

A simulator conformance test suite for IEEE 1800.2-2020, the Universal Verification Methodology (UVM). It targets
[kirimasim](https://github.com/kurochan001/kirimasim) and complements
[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests), which tests the IEEE 1800-2023 SystemVerilog language.

If UVM is new to you, [the reading guide](docs/reading-guide.md#what-this-repository-tests) connects the simulator, library and test before you interpret the counts below.

An oracle records the expectation's basis: `spec` cites the standard and `verilator@5.052` adds reproduction;
[Standards and expectations](docs/glossary.md#standards-and-expectations) explains spec-only cases.

> **Status: M4 in progress.** 2701 tests: 2602 simulation and 99 elaboration,
> in 22 chapter/annex directories; 2245 tagged oracles and 456 spec-only cases.
> All use `:spec_check: ai`, recording AI review as explained in [review terms](docs/glossary.md#standards-and-expectations); none records human review. M1–M3 targets remain open.
> M4 has 4096 [observable-duty drafts](docs/requirements.md#counting-unit-and-scope-proposal) reviewed by AI, 2645 directly linked tests and an index of all 2701.
> 0 tests lack requirement links and 0 drafts lack direct tests; the historical
> [memory-walk interpretation](docs/faq.md#q134-how-is-the-memory-walk-algorithm-interpreted) requires review. 0 identifiers remain unassessed;
> 2062 identifiers remain partial and 445 have AI classifications; [zero unassessed](docs/faq.md#q390-does-zero-unassessed-identifiers-mean-zero-remaining-work) does not establish completion. Scope and denominator remain unapproved.

## Contents

The `unassessed` count records unfinished clause review, while `known` records a measured difference; [the progress guide](docs/reading-guide.md#read-coverage-and-progress) and [result definitions](docs/faq.md#q5-what-do-pass-fail-known-and-unsupported-mean) explain the two kinds of remaining work.

- [Current scope](#current-scope)
- [Running the suite](#running-the-suite)
- [Current results](#current-results)
- [Documentation](#documentation)
- [Plan](#plan), [reporting issues](#reporting-issues) and [license](#license)

## Current scope

Factory controls object creation and phases organize execution, while TLM carries transactions between components; [UVM building blocks](docs/glossary.md#uvm-building-blocks) and [TLM terms](docs/glossary.md#transaction-level-communication) introduce these names before the scope list.

- **M1: 1161 tests (1080 simulation, 81 elaboration).** Objects and policies,
  reporting, factory, hierarchy, phases, synchronization, configuration,
  recording, core services and typed utilities, including [static callback iterators](docs/faq.md#q397-do-the-new-primary-citations-complete-the-iterator-clauses) and [objection cancellation](docs/faq.md#q405-what-is-added-beyond-re-raising-during-drain).
- **M2: 612 tests (605 simulation, 7 elaboration).** Sequences and sequencers,
  request/response lifecycle, callbacks, TLM 1 channels and selected TLM 2 transports, including [nested input/ref paths](docs/faq.md#q402-does-a-delay-reference-mean-an-endpoint-can-replace-the-callers-handle); F.2.3 port-role, F.2.4.2 state and F.2.4.3 sequence-library fixtures in uF count as M2 under the [milestone grouping](docs/glossary.md#scope-and-coverage).
- **M3: 928 tests (917 simulation, 11 elaboration).** Register, field, block,
  memory and virtual-register models; access paths, prediction, callbacks,
  coverage, allocation and built-in test sequences; D.3 fixtures in uD and model API profiles in u01 count as M3 under [the functional grouping](docs/faq.md#q381-why-do-profiles-under-the-same-u01-directory-use-three-milestones).

Frontdoor and backdoor are access routes; the [register glossary](docs/glossary.md#register-model) explains their roles and the distinction from actual HDL access.
Built-in frontdoors use testbench adapter/sequencer/driver connections.
Custom frontdoors model storage in their sequence bodies; passive predictor
fixtures supply observations separately. User backdoors model storage through
`uvm_reg_backdoor` extensions. Thirty-eight separate HDL fixtures use actual public
variables through an original VPI backend; [HDL setup](docs/testing.md#verilator-vpi-hdl-subset) explains the linked implementation needed to reach that storage.
Eighteen command-line fixtures opt into a separate VPI argument bridge and
pinned UVM regex DPI; seventeen match both seeds and one retains a diagnostic
severity difference. The [command-line runner](docs/testing.md#verilator-command-line-subset) supplies that bridge; ordinary runs leave it unlinked.

Expected results follow the cited standard, and normative expectations remain when a simulator/library combination differs. The SystemVerilog language itself belongs to kirimasim-tests.

Test counts and clause citations are not a reviewed requirement-coverage
percentage. M4 provides a primary-citation census and explicit requirement links;
normative decomposition and denominator approval remain open. See the
[requirement ledger guide](docs/requirements.md) and [FAQ](docs/faq.md).

## Running the suite

Start with one ordinary-runner test to check your setup; [the first-run notes](docs/reading-guide.md#before-the-first-run) explain prerequisites and seeds, and [choosing a runner](docs/reading-guide.md#choose-an-execution-condition) explains when a separate backend is needed.

Use Python 3.10 or later. The fixed-release oracle requires Verilator 5.052, a C++ toolchain and make. Run from the repository root:

```sh
python3 tools/fetch_uvm.py
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 1 \
  --json out/verilator-smoke.json tests/u09/test_common_phases_run_in_order.sv
```

The fetcher downloads and checks the pinned Accellera UVM 2020.3.1 library; install the simulator and build tools separately as described in [the environment FAQ](docs/faq.md#q2-what-do-i-need-and-where-does-uvm-come-from). The smoke command selects one test.
To see what that case checks, [follow the worked example](docs/reading-guide.md#follow-one-test-through-the-files) from its source to its expected output and requirement.
The saved JSON lists each case's judgment; [an example for opening it](docs/reading-guide.md#open-the-result-json) shows how to read it. If it reports a difference, [Trace a difference](docs/reading-guide.md#trace-a-difference) shows how to locate the checked expectation and execution conditions.

To run all 2245 tagged checks (2151 runtime, 94 compile rejection):

```sh
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 2 \
  --json out/verilator.json
```

Add `--all` to include all two-state cases, including the 456 spec-only cases.
`known` results do not fail that command; tagged regressions do. `-j` controls concurrent tests and `--build-jobs` controls C++ jobs within each build; [Q13](docs/faq.md#q13-why-is-compilation-heavy-and-what-do-the-two-job-options-control) explains the build cost.
Each runtime model is built once and run in a fresh process for each seed.

For kirimasim, replace `/path/to/kirimasim` with the installed executable's path; [the runner guide](docs/testing.md#running-the-suite) explains test selection and result files.

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

The Verilator snapshot assembled on 2026-11-07 covers all 2701 current cases.
Guest records retain 1081 compatible inputs; 1620 inputs are unmeasured, meaning no compatible current record is available under [the evidence-reuse rules](docs/results.md#evidence-assembly).

| Simulator and library | Observed result |
| --- | --- |
| Verilator 5.052, pinned UVM, ordinary runner | 2151 runtime matches at seeds 1/73; 94 expected compile rejections; 456 known differences |
| Verilator 5.052, original VPI HDL backend | Separate 38-case subset: 37 match both seeds; 1 differs |
| Verilator 5.052, VPI command-line bridge and pinned regex DPI | Separate 18-case subset: 17 match both seeds; 1 known difference |
| kirimasim, pinned UVM | 1072 `unsupported`; nine missing-API `fail` in 1081 cases; 1620 unmeasured |
| Ghost, bundled UVM | 206 match and 875 fail at each seed in 1081 cases; 1620 unmeasured |

The ordinary runner records 316 runtime differences at seed 1, 135 simulation build failures
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
| M1 | Core classes, policies, factory, phases and their graphs, objections, configuration and reporting | 1161 tests; reviewed two-tests-per-clause target open |
| M2 | Sequences, sequencers, TLM and callbacks | 612 tests; target open |
| M3 | Register layer (17–19, D.3, annex E) and shared API rules | 928 tests, including model API profiles under 1.4.2/1.4.3; target open |
| M4 | Requirement ledger and coverage | In progress: 4096 AI drafts; 4096 requirements link to 2645 tests; denominator unapproved |

The primary-citation census tracks the two-tests-per-clause target; [the counting explanation](docs/requirements.md#citations-requirements-and-execution-evidence) describes the additional review needed to establish independent checks of required behavior.

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

Apache License 2.0 with LLVM Exceptions (`Apache-2.0 WITH LLVM-exception`). [LICENSE](LICENSE) is the original text; [日本語参考訳](LICENSE.ja.md) is a
complete, non-authoritative translation. Source attribution and rights
handling are in [provenance](docs/provenance.md) and the
[testing guide](docs/testing.md#rights-and-sources).
