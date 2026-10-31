# kirimasim-uvm-tests

[日本語](README.ja.md)

A conformance test suite for simulators running the Universal Verification
Methodology, IEEE 1800.2-2020 (UVM). It is written for the
[kirimasim](https://github.com/kurochan001/kirimasim) simulator and pairs with
[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests), which checks
the SystemVerilog language of IEEE 1800-2023.

> **Status: M1 (core expansion in progress).** 27 tests, the pinned UVM
> fetcher, runners for kirimasim, Verilator and Ghost, metadata checks and
> the Check workflow. The clause-by-clause M1 target is not complete;
> see "Current M1 increment" below.

## 1. What the suite checks

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

## 2. Relation to kirimasim-tests

| | kirimasim-tests | kirimasim-uvm-tests |
| --- | --- | --- |
| Standard | IEEE 1800-2023 | IEEE 1800.2-2020, run by the language of 1800-2023 |
| External dependency | none (small, self-contained designs) | the UVM library, pinned by version and digest |
| Layout | `tests/chNN/`, chapters of 1800-2023 | `tests/uNN/`, chapters of 1800.2 |
| Fixed-release oracles | Icarus Verilog 13.0, Verilator 5.052 | Verilator 5.052 where it reproduces (see 5) |
| Judging tools | the original | copied from a fixed commit (`tools/UPSTREAM`) |
| CI | its own | its own, as compiling UVM for every test is slow |

When a UVM test fails because of a language feature (classes, parameterized
classes, constraints, process control and so on), the minimal case goes to
kirimasim-tests as a language test. The UVM suite thus also finds what the
language tests are missing.

## 3. Layout

```text
tests/uNN/<name>.sv          a test with metadata; NN is the chapter of 1800.2 (u05 to u19)
tests/uNN/<name>.expected    its expected observed lines
tests/uB/ … tests/uH/        the annexes: B macros, C configuration and resources,
                             D convenience classes and interfaces, E register test
                             sequences, F package scope functionality, G command
                             line, H deprecated constructs
third_party/uvm.lock         the pinned library: release, source, commit, digest
third_party/uvm/<version>/   the library itself, fetched, not committed
tools/fetch_uvm.py           fetches the library and checks its digest
tools/uvm_common.py          how a test is compiled with the library, what is observed
tools/run_kirimasim.py       runner for kirimasim
tools/run_verilator.py       runner for Verilator
tools/run_ghost.py           private-profile runner under the public alias Ghost
tools/suite_results.py       judgment and result JSON, copied from kirimasim-tests
tools/lint_metadata.py       checks of the metadata and the form of the tests
tools/clauses_1800_2.txt     clause numbers of 1800.2-2020 (numbers only)
tools/UPSTREAM               where the copied tool comes from, and what changed
```

## 4. Test format

### 4.1 Example

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

### 4.2 Metadata

The format is that of kirimasim-tests and sv-tests, with these differences:

| Field | Meaning |
| --- | --- |
| `:lrm:` | `1800.2-2020 <clauses>`. A test that also relies on a rule of the language adds `1800-2023 <clauses>` after them. The first clause of 1800.2 sets the directory |
| `:tags:` | the chapter directory `uNN` and `uvm`, as sv-tests tags UVM tests |
| `:uvm:` | the library release the test is written for; it must be the locked one |
| `:uvm_dpi:` | `yes` to use the library's DPI code (regular expressions, HDL backdoor); see 6.2 |
| `:uvm_defines:` | macros for the library, such as `UVM_ENABLE_DEPRECATED_API` |
| `:args:` | run-time arguments such as `+UVM_TESTNAME=…` |

`:oracle:`, `:spec_check:`, `:fourstate:`, `:nondeterministic:`,
`:should_fail_because:`, `:expected_stderr_regex:`, `:expected_exit:`,
`:files:`, `:defines:`, `:incdirs:` and `:top_module:` mean what they mean in
kirimasim-tests.

### 4.3 What is observed

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

## 5. Where the expected outputs come from

1. The expected output is derived from the cited clauses (`:oracle: spec`).
2. The library's source (Apache-2.0) may be read to understand the text of the
   standard, but expected outputs come from the standard. Where the library
   and the standard differ, the difference is recorded with `DEVIATIONS.md`,
   and no test depends on it.
3. Reproduction with fixed releases:
   - Verilator 5.052 builds and runs the library with `UVM_NO_DPI`. A test that
     does not depend on x or z and that Verilator 5.052 reproduces with seeds
     1 and 73 gets `verilator@5.052`, as in kirimasim-tests.
   - Icarus Verilog 13.0 cannot run UVM and is not used.
4. A disagreement between a simulator and an expected output is never solved
   by copying the simulator's output; the clause decides.

## 6. The UVM library

### 6.1 Fetching

`python3 tools/fetch_uvm.py` fetches the release that `third_party/uvm.lock`
names from [accellera-official/uvm-core](https://github.com/accellera-official/uvm-core)
(tag `2020.3.1`, commit `78c06547a2a0`) into `third_party/uvm/2020.3.1/` and
checks the digest of its extracted files (the path and SHA-256 of each of its
326 files). The archive itself is not hashed, as the host may compress it
again. `--check` checks the copy that is there. The library is not committed.

### 6.2 Compiling

- Each runner passes `+incdir+<library>/src` and `<library>/src/uvm_pkg.sv`
  before the sources of the test.
- `UVM_NO_DPI` is defined unless the test sets `:uvm_dpi: yes`. The library's
  DPI code for HDL backdoor access has implementations for three commercial
  simulators only. Without DPI the library reads `+UVM_TESTNAME` itself,
  matches names with globs rather than regular expressions, and does not check
  component names; it also warns that support for `UVM_NO_DPI` may be removed.
  A test that depends on regular expressions or the backdoor sets
  `:uvm_dpi: yes` and runs only where the DPI code can be loaded
  (`UVM_HDL_NO_DPI` leaves out the backdoor alone).
- The deprecated API (annex H, the library's `deprecated/`) is compiled with
  `UVM_ENABLE_DEPRECATED_API`, by the tests of `tests/uH/` only.

## 7. Running the suite

```sh
python3 tools/fetch_uvm.py
python3 tools/run_kirimasim.py --kirimasim /path/to/kirimasim -j 8 --json out/kirimasim.json
python3 tools/run_verilator.py --all --seed 1 -j 2 --json out/verilator-1.json
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 2 --json out/verilator.json
```

The runners need Python 3.10 or later. The results JSON has the form of
kirimasim-tests (`tools/suite_results.py`), so its history and report tools
can read it. `run_verilator.py` builds each test, including the whole UVM
package, which takes about half a minute on eight cores (`--build-jobs`,
by default every hardware thread). It does not use ccache: Verilator builds
the large model with a precompiled header that records the absolute path of
its build directory, and a header that ccache kept from another directory
breaks the build.

`--seeds 1 73` builds each model once and runs it in a fresh process for each
seed. All seeds must match. `--seed N` remains available for a single seed.
The JSON configuration records either `seed` or `seeds` accordingly.

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

The initial M1 bundled-library runs match 18 of 27 tests with both seeds 1
and 73; the same nine cases differ. The pinned-library smoke test does not
match on that private executable, including with preprocessing enabled.
These differences are recorded as failures. They do not change expectations
or establish whether the cause is the simulator or its bundled library.

| Simulator | Current status |
| --- | --- |
| kirimasim | local executable reports all 27 cases as unsupported at `uvm_object_wrapper` |
| Verilator 5.052 | builds and runs the library with `UVM_NO_DPI` |
| Ghost (an unreleased simulator, as in kirimasim-tests) | bundled UVM: 18/27 match with both seeds; pinned UVM: smoke test differs |
| Icarus Verilog 13.0 | not used: it cannot run UVM |

## 8. Checks

```sh
python3 tools/fetch_uvm.py --check
python3 -m unittest discover -s tools -p 'test_*.py'
python3 tools/lint_metadata.py
```

`.github/workflows/check.yml` runs these and the tests recorded with Verilator
5.052, with seeds 1 and 73.

The multi-seed runner builds each test once for those two executions.

## 9. Plan

| Stage | Content | Done when |
| --- | --- | --- |
| M0 | skeleton: fetcher, runners for kirimasim and Verilator, checks, Check, one smoke test | Check passes and both runners write results JSON |
| M1 | core: base classes (5), policies (16: copy, compare, print, pack), factory (8), phasing (9), objections (10.5), config_db (C.4), report counts (6); the Ghost runner | two tests or more for each clause |
| M2 | sequences, sequencers, TLM (12 to 15), callbacks (10.7, annex D) | the same |
| M3 | the register layer (17 to 19, annex E), avoiding the three library deviations | the same |
| M4 | a requirement ledger for 1800.2 and its coverage, as in kirimasim-tests | an approved denominator |

### Current M1 increment

The first increment adds 26 independent tests to the original phase smoke
test. Expected observations are written before running the simulator:

- Object names, renaming, cloning and independence of cloned data: four tests.
- Factory type-override replacement and instance-override scope/priority:
  four tests.
- Build traversal and bottom-up connect traversal: two tests, in addition to
  the original common-phase test.
- Objection counts, partial drops and propagation to a parent: two tests.
- Configuration lookup scope, types, build precedence and runtime writes:
  four tests.
- Report severity/ID counts and verbosity filtering: two tests.
- Copier, comparer, printer and packer policies: two tests each. Printer
  tests capture policy inputs rather than built-in formatting; packer tests
  check values and sizes rather than an implementation-specific byte layout.

The cited behavior and expectations have been checked against IEEE
1800.2-2020. In particular, the clone tests observe independent copies,
without assuming an implementation's creation/copy callback sequence.
The standard PDFs used for review stay local and are ignored by Git.

This increment does not finish M1: the remaining clauses' two-test target
is still outstanding. Ghost differences are retained for separate triage.
The tests keep `:spec_check: ai`; this does not indicate human review or a
complete requirement inventory. M4's approved coverage denominator is a
separate step.

The library marks about 1,760 places with the clause of 1800.2 they implement
(`@uvm-ieee 1800.2-2020 auto <clause>`). They can guide an inventory of the
API, but they are the library's mapping, so a requirement is registered only
after review.

## 10. Rights and sources

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
