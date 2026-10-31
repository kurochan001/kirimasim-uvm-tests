# kirimasim-uvm-tests

[日本語](README.ja.md)

[![Check](https://github.com/kurochan001/kirimasim-uvm-tests/actions/workflows/check.yml/badge.svg)](https://github.com/kurochan001/kirimasim-uvm-tests/actions/workflows/check.yml)
[![License: Apache-2.0 WITH LLVM-exception](https://img.shields.io/badge/license-Apache--2.0%20WITH%20LLVM--exception-blue)](LICENSE)

A conformance test suite for simulators running the Universal Verification
Methodology, IEEE 1800.2-2020 (UVM). It is written for the
[kirimasim](https://github.com/kurochan001/kirimasim) simulator and pairs with
[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests), which checks
the SystemVerilog language of IEEE 1800-2023.

See the [glossary](docs/glossary.md) for terminology, the [FAQ](docs/faq.md)
for running and interpreting tests, and [known differences](docs/known-differences.md)
for library limitations. Earlier increments and measurements are in the
[development history](docs/history.md). This README describes the current suite.

> **Status: M3 in progress.** 661 simulation tests in 14 chapter/annex
> directories; 604 have a `verilator@5.052` oracle and 57 are spec-only.
> All use `:spec_check: ai`; none records human review yet.
> M1 and M2 retain open clause targets; M3 now includes testbench frontdoor traffic and passive prediction.

## Contents

- [Current scope](#current-scope) and [results](#current-results)
- [Running the suite](#running-the-suite)
- [Test format](#test-format) and [expected outputs](#where-the-expected-outputs-come-from)
- [The UVM library](#the-uvm-library), [checks](#checks) and [plan](#plan)
- [Glossary](docs/glossary.md), [FAQ](docs/faq.md),
  [known differences](docs/known-differences.md), [history](docs/history.md)

## Current scope

The 229 M1 cases exercise objects and transactions, copy/compare/print/pack
policies, reporting, the factory, phases, objections and configuration.
The 360 M2 cases add TLM 1 FIFOs, analysis paths and request/response channels;
TLM 2 payloads, extensions and selected socket transports; sequence execution,
responses, action macros and pull/push sequencer controls; and callback
registration, inheritance, iteration and early exit.

The 72 M3 cases cover register fields, registers and blocks, memories,
address maps, transaction descriptors, adapters and predictors in chapters
18–19. Frontdoor cases use a testbench bus model with real sequencer/driver
handshakes; passive predictor cases supply observed transactions separately.
No RTL DUT or DPI implementation is required by these fixtures.

The latest 24 add seven adapter cases and one operation-descriptor case,
eight predictor cases and eight frontdoor paths. Twenty-two match Verilator
at both seeds. Two retain spec-only expectations for predictor redirection
and big-endian frontdoor read data. See the
[FAQ](docs/faq.md#adapter-predictor-and-frontdoor-paths) for fixture scope.

These are focused behavior tests. The stages still need a reviewed inventory
against their target of at least two tests per clause. Citation counts include
setup and structural references, so they do not establish full requirement
coverage. Further register-layer interactions and an approved requirement-coverage
denominator remain planned work.

## Current results

The latest local evidence covers 661 tests (2026-11-01). Verilator and
Ghost combine the latest 24 cases with the unchanged 637-case baseline at
[aec3626](https://github.com/kurochan001/kirimasim-uvm-tests/commit/aec3626355be5ba8cc74d3cc5259a5642417c4ea)
after checking input, runner and configuration fingerprints. Ghost retains
the executable/profile snapshot used for its preceding full-suite measurement.
kirimasim uses a newly measured full suite on a fixed build, with corrected
cases refreshed; its executable version changed since the baseline.

| Simulator | Observed result |
| --- | --- |
| Verilator 5.052, pinned UVM, `UVM_NO_DPI` | 604 match seeds 1 and 73; 50 spec-only cases differ at seed 1; seven spec-only cases cannot build due to missing library APIs |
| kirimasim, pinned UVM | 654 report `uvm_object_wrapper` as unsupported; seven fail first on missing library APIs |
| Ghost, bundled UVM | 140 match and 521 fail at each seed; the same cases fail at seeds 1 and 73 |
| Ghost, pinned UVM | Earlier executable's smoke test differs; no pinned-mode measurement for the sampled build |
| Icarus Verilog 13.0 | Not used for this UVM suite |

The Verilator runner stops a test at its first differing seed. The runtime
records establish seed 1 differences for 50 known cases, without seed 73
results. Seven missing-API cases have no runtime seed result: one time API
and six sequence-library cases. `known` and
`unsupported` are not passes. See [known differences](docs/known-differences.md).

The Check badge reports GitHub Actions, separately from these local results.
Check runs tool/metadata/library checks and the 604 tagged Verilator cases;
it does not run Ghost or kirimasim. This repository has no Nightly workflow
or automatic result publication.

## What the suite checks

- **Subject:** whether a simulator runs the UVM library so that the results
  are those IEEE 1800.2-2020 sets: the order of the phases, the end of a phase
  by objections, factory overrides, config_db lookups, sequences and
  sequencers, TLM connections, the register layer and so on.
- **Ground of an expected result:** a clause of 1800.2-2020, cited in `:lrm:`.
  A comment at the top of each test says, in our own words, what it checks; no
  text of the standard is copied.
- **Library:** the Accellera UVM library, release 2020.3.1, pinned by
  `third_party/uvm.lock` (see "The UVM library"). Its `DEVIATIONS.md` lists
  three places where the library differs from the standard (18.2.3.4,
  18.4.3.6 and 13.1.5.1). No expected result depends on them; a test that has
  to touch one records the difference.
- **Out of scope:** the SystemVerilog language itself (kirimasim-tests),
  teaching material for UVM, performance, generators of register models, and
  vendor extensions.

## Relation to kirimasim-tests

| | kirimasim-tests | kirimasim-uvm-tests |
| --- | --- | --- |
| Standard | IEEE 1800-2023 | IEEE 1800.2-2020, run by the language of 1800-2023 |
| External dependency | none (small, self-contained designs) | the UVM library, pinned by version and digest |
| Layout | `tests/chNN/`, chapters of 1800-2023 | `tests/uNN/`, chapters of 1800.2 |
| Fixed-release oracles | Icarus Verilog 13.0, Verilator 5.052 | Verilator 5.052 where it reproduces |
| Shared judgment/result JSON | the original | `suite_results.py` copied from a fixed commit; runners are original suite code (`tools/UPSTREAM`) |
| CI | its own | its own, as compiling UVM for every test is slow |

When a UVM test fails because of a language feature (classes, parameterized
classes, constraints, process control and so on), the minimal case goes to
kirimasim-tests as a language test. The UVM suite thus also finds what the
language tests are missing.

## Layout

```text
tests/uNN/<name>.sv          a test with metadata; NN is the chapter of 1800.2
tests/uNN/<name>.expected    its expected observed lines
tests/uB/, uC/, uD/          current annex tests: macros, configuration, callbacks
docs/glossary*.md            terminology
docs/faq*.md                 common questions
docs/known-differences*.md   current limitations and spec-only expectations
docs/history*.md             earlier increments and measurements
third_party/uvm.lock         the pinned library: release, source, commit, digest
third_party/uvm/<version>/   the library itself, fetched, not committed
tools/fetch_uvm.py           fetches the library and checks its digest
tools/uvm_common.py          how a test is compiled with the library, what is observed
tools/run_kirimasim.py       runner for kirimasim
tools/run_verilator.py       runner for Verilator
tools/run_ghost.py           private-profile runner under the public alias Ghost
tools/suite_results.py       judgment and result JSON, copied from kirimasim-tests
tools/lint_metadata.py       checks of the metadata and the form of the tests
tools/sv_lifetimes.py        lexical guard for initialized procedural locals
tools/clauses_1800_2.txt     clause numbers of 1800.2-2020 (numbers only)
tools/UPSTREAM               where the copied tool comes from, and what changed
```

## Test format

### Example

```systemverilog
/*
:name: test_common_phases_run_in_order
:description: the common phases run in their order, ... (IEEE 1800.2-2020 Section 9.8.1)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.8.1 9.5 9.6 9.7 10.5.1
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +UVM_TESTNAME=t
:expected_stdout: @test_common_phases_run_in_order.expected
*/
```

### Metadata

The format is that of kirimasim-tests and sv-tests, with these differences:

| Field | Meaning |
| --- | --- |
| `:lrm:` | `1800.2-2020 <clauses>`. A test that also relies on a rule of the language adds `1800-2023 <clauses>` after them. The first clause of 1800.2 sets the directory |
| `:tags:` | the chapter directory `uNN` and `uvm`, as sv-tests tags UVM tests |
| `:uvm:` | the library release the test is written for; it must be the locked one |
| `:uvm_dpi:` | `yes` requests DPI-enabled macros; supplying/linking the implementation is separate; see [compiling](#compiling) |
| `:uvm_defines:` | macros for the library, such as `UVM_ENABLE_DEPRECATED_API` |
| `:args:` | run-time arguments such as `+UVM_TESTNAME=…` |

`:oracle:`, `:spec_check:`, `:fourstate:`, `:nondeterministic:`,
`:should_fail_because:`, `:expected_stderr_regex:`, `:expected_exit:`,
`:files:`, `:defines:`, `:incdirs:` and `:top_module:` mean what they mean in
kirimasim-tests.

### What is observed

1800.2 defines what the methods that build a report do, not the text they
produce: `compose_report_message` (6.5.1.2.15) builds the string from the
severity, the component name, the id and the message, while the layout
`UVM_INFO file(line) @ time: name [id] msg` is the library's. File names, line
numbers and the format of times also depend on the library and the simulator.
So:

- **The default report lines are not compared.**
- **A test prints what it observes on lines that begin with `UT: `**, with
  `$display`, and only the values that the standard fixes: the order of phases,
  counts, values read back, results of comparisons. Only those lines are
  compared with the expected output. A failure of the report machinery then
  does not take down the tests of other chapters.
- **Report counts are read as values**, with `get_severity_count` and
  `get_id_count` of the report server, and printed on `UT: ` lines.
- **Tests of chapter 6 (reporting)** install their own report server or
  report catcher and check, on `UT: ` lines, how the inputs that the standard
  defines (severity, id, verbosity, actions) lead to results.
- A test does not depend on what the standard leaves open: random values, the
  order of processes started at the same time, generated names other than
  those the standard fixes.

## Where the expected outputs come from

1. The expected output is derived from the cited clauses (`:oracle: spec`).
2. The library's source (Apache-2.0) may be read to understand the text of the
   standard, but expected outputs come from the standard. The library's
   `DEVIATIONS.md` and our [known differences](docs/known-differences.md)
   distinguish library limitations from reproduced fixed-release oracles.
   Tests directly checking missing required behavior keep spec-only expectations.
3. Reproduction with fixed releases:
   - Verilator 5.052 builds and runs the library with `UVM_NO_DPI`. A test that
     does not depend on x or z and that Verilator 5.052 reproduces with seeds
     1 and 73 gets `verilator@5.052`, as in kirimasim-tests.
   - Icarus Verilog 13.0 cannot run UVM and is not used.
4. A disagreement between a simulator and an expected output is never solved
   by copying the simulator's output; the clause decides.

### From a test to a result

The two paths meet at judgment: the cited clauses determine the expectation,
and execution supplies the observation.

```mermaid
flowchart TB
    standard["IEEE 1800.2-2020<br/>Cited clauses"]
    test["Test source<br/>SystemVerilog + metadata"]
    expected["Expected result<br/>.expected + metadata conditions"]
    library["UVM library<br/>Pinned or Ghost bundled"]
    execute["Build and run<br/>Selected simulator"]
    judge["Runner judgment<br/>UT: lines + exit / diagnostics"]
    result["Result JSON with --json<br/>Status + fingerprints"]

    standard --> test
    standard --> expected
    test --> execute
    library --> execute
    execute --> judge
    expected --> judge
    judge --> result
```

Build and run failures also receive a result. The library identity remains
part of the execution conditions; a Ghost bundled run uses its supplied UVM.
For status meanings and command exit codes, see the
[FAQ](docs/faq.md#understanding-a-result).

## The UVM library

### Fetching

`python3 tools/fetch_uvm.py` fetches the release that `third_party/uvm.lock`
names from [accellera-official/uvm-core](https://github.com/accellera-official/uvm-core)
(tag `2020.3.1`, commit `78c06547a2a0`) into `third_party/uvm/2020.3.1/` and
checks the digest of its extracted files (the path and SHA-256 of each of its
326 files). The archive itself is not hashed, as the host may compress it
again. `--check` checks the copy that is there. The library is not committed.

### Compiling

- Pinned-library runs add the library's `src` include directory and compile
  `src/uvm_pkg.sv` before the test sources. Verilator uses `-I`; kirimasim
  and Ghost use `+incdir+`. Ghost's bundled mode supplies its own package.
- `UVM_NO_DPI` is defined unless the test sets `:uvm_dpi: yes`. The library's
  DPI code for HDL backdoor access has implementations for three commercial
  simulators only. Without DPI the library reads `+UVM_TESTNAME` itself,
  matches names with globs rather than regular expressions, and does not check
  component names; it also warns that support for `UVM_NO_DPI` may be removed.
  A test that depends on regular expressions or the backdoor sets
  `:uvm_dpi: yes` and runs only where the DPI code can be loaded
  (`UVM_HDL_NO_DPI` leaves out the backdoor alone).
- All 661 current cases use `UVM_NO_DPI`. `:uvm_dpi: yes` removes that macro;
  it does not automatically compile or link the C/C++ DPI implementation.
  The current Verilator runner does not add DPI C/C++ sources.
- `:uvm_defines:` can request `UVM_ENABLE_DEPRECATED_API`. There are currently
  no annex H tests or cases requesting this macro.

## Running the suite

```sh
python3 tools/fetch_uvm.py
python3 tools/run_kirimasim.py --kirimasim /path/to/kirimasim -j 8 --json out/kirimasim.json
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 2 --json out/verilator.json
```

The runners need Python 3.10 or later. The results JSON has the form of
kirimasim-tests (`tools/suite_results.py`), so its history and report tools
can read it. `run_verilator.py` builds each test, including the whole UVM
package. `-j` controls concurrent tests; `--build-jobs` controls C++ build jobs
per test (0, the default, uses every hardware thread). It does not use ccache: Verilator builds
the large model with a precompiled header that records the absolute path of
its build directory, and a header that ccache kept from another directory
breaks the build.

`--seeds 1 73` builds each model once and runs it in a fresh process for each
seed. All seeds must match. `--seed N` remains available for a single seed.
The JSON configuration records either `seed` or `seeds` accordingly.

By default, Verilator selects the 604 tagged two-state cases. To include
the 57 spec-only cases as well, add `--all`. A mismatch in an untagged case
is `known` and does not fail the command; a tagged mismatch does.
Explicit test paths select only those tests. For a single smoke test:

```sh
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 1 \
  --json out/verilator-smoke.json tests/u09/test_common_phases_run_in_order.sv
```

Each run uses a temporary build directory. `out/` is ignored by Git; Check
does not publish these JSON files. See the [FAQ](docs/faq.md) for result
statuses, exit codes and fingerprint interpretation.

### Ghost

```sh
python3 tools/run_ghost.py --simulator /path/to/private/simulator \
  --profile /path/to/private-profile.json -j 2 --json out/ghost.json
```

The private JSON profile supplies `arguments` (a list of strings),
`environment` (a mapping of strings) and an explicit `uvm_mode`:

- `pinned`: the runner includes and compiles the locked UVM package before
  the test sources. The profile must disable any automatic bundled package.
- `bundled`: the profile and simulator supply UVM; the runner does not compile
  another package. Such a run compares the same spec expectations but is
  **not evidence for the pinned library**. No bundled-library version is
  inferred from the test's `:uvm:` field.

Bundled profiles also provide `uvm_library_dir`, the private directory tree
containing the library's source and headers. The profile's arguments must
select that same library. For a library whose code and headers are actually
embedded in the executable, use `uvm_embedded: true` instead. Exactly one
identity is required; paths are never copied into results.

Public JSON records `uvm_source`, `uvm_pinned`, the test's library release
(`test_uvm`) and SHA-256 fingerprints of the executable and profile. Pinned
and directory-backed bundled runs also record the library's content digest
and file count. The simulator's name, version, paths, profile contents and
diagnostics stay private. If its executable, profile or library changes
during a run, results are not written. Pinned mode verifies the actual tree
against the lock before executing.

## Checks

```sh
python3 tools/fetch_uvm.py --check
python3 -m unittest discover -s tools -p 'test_*.py'
python3 tools/lint_metadata.py
```

The current tool suite has 41 unit tests; metadata validation checks all
661 simulation tests. [Check](.github/workflows/check.yml) runs on pushes to
`main`, pull requests and manual dispatch. Its separate Verilator job uses
5.052, `UVM_NO_DPI` and seeds 1 and 73 for the tagged cases. Each model is
built once for the two executions. A green Check establishes those checks,
not that every UVM requirement or every simulator passes.

## Plan

| Stage | Scope | Current state / target |
| --- | --- | --- |
| M0 | Fetcher, runners, metadata/tools checks, Check and smoke test | Infrastructure implemented |
| M1 | Core classes, policies, factory, phases, objections, configuration and reporting | 229 cases; reviewed two-tests-per-clause target still open |
| M2 | Sequences, sequencers, TLM and callbacks | 360 cases; expanding toward the same target |
| M3 | Register layer (17–19, annex E) | 72 cases across chapters 18–19; broader bus interactions remain |
| M4 | Requirement ledger and coverage | Planned; approve the denominator before claiming coverage |

Remaining M2 work includes further queued ownership, termination and
default-resource conditions, callback behavior and broader TLM 2 protocol,
timing and socket combinations. Annotation and routing checks do not establish
full protocol or timing coverage. Library clause annotations can guide the
inventory, but require review against the standard. Starting M2 does not mark
M1 complete. Starting M3 likewise leaves M1 and M2 open.

Remaining M3 work includes memory transfers, virtual-register models,
broader adapter/predictor, policy and map conditions, frontdoor errors and
bus-protocol combinations, backdoor/DPI setups, callbacks and annex E
sequences. The current bus-model fixtures establish selected UVM paths;
RTL protocol and timing coverage remain separate work.

## Adding or correcting a test

Derive observations from the cited standard before running the simulator.
Keep each test independent, print only prescribed results on `UT: ` lines,
and retain normative expectations when a simulator/library pair differs.
Use explicit lifetimes for initialized procedural locals (SystemVerilog 6.21),
keep shared fork state alive, and bound blocking observations with watchdogs.
Run metadata and tool checks; reproduce new fixed-release oracles at both
seeds before adding the tag. The standard PDFs remain local and ignored by Git.

## Rights and sources

- No text, figure or example code of 1800.2 is copied; clauses are cited by
  number and described in our own words.
- The UVM library is Apache-2.0. It is fetched, not committed; if it is ever
  committed, its `LICENSE.txt` and `NOTICE.txt` go with it.
- The sources of GPL or LGPL simulators (Icarus Verilog, Verilator) are not read.
- The name, version, profile and paths of the unreleased simulator are not
  published.

## License

Apache License 2.0 with LLVM Exceptions (`Apache-2.0 WITH LLVM-exception`).
See [LICENSE](LICENSE).
