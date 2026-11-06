# Reading guide

[日本語](reading-guide.ja.md) · [README](../README.md)

Start here if UVM, the result labels or the progress counts are unfamiliar; choose the section matching what you want to do.

- [What this repository tests](#what-this-repository-tests)
- [Before the first run](#before-the-first-run)
- [Read a result](#read-a-result)
- [Trace a difference](#trace-a-difference)
- [Read coverage and progress](#read-coverage-and-progress)
- [Before changing or reporting a test](#before-changing-or-reporting-a-test)
- [Choose the next document](#choose-the-next-document)

## What this repository tests

This repository supplies small UVM tests and scripts that run them. A simulator executes the SystemVerilog language; the UVM library supplies the verification classes used by a test. See [what the suite checks](testing.md#what-the-suite-checks) for the boundary with kirimasim-tests.

The expected result comes from the cited standard. The Accellera library is pinned to the version and content identified by the repository lock file (uvm.lock) and is the implementation exercised, so a mismatch can involve the simulator, library or test. See [the sources of expectations](provenance.md#library-and-standards).

A test directory such as `u09` follows its first UVM clause citation; [the layout guide](testing.md#layout) explains chapter and annex names when locating a source.

Each test starts with metadata describing its cited rule and expected output; [the test-header example](testing.md#example) shows where to find these in a source file.

Many register tests use original testbench storage; the words frontdoor or backdoor alone do not establish actual HDL access. See [the register model terms](glossary.md#register-model) and [the separate HDL backend](testing.md#verilator-vpi-hdl-subset) for that distinction.

## Before the first run

The source path selects a fixture, while `+UVM_TESTNAME=t` selects the registered UVM test class inside it; [the example header](testing.md#example) shows both names in use.

Use Python 3.10 or later, exactly Verilator 5.052, a C++ toolchain and make, then run the smoke command in [FAQ Q3](faq.md#q3-how-can-i-run-one-test-first) from the repository root, the directory containing README. Verilator generates a C++ model, so its build needs a C++ compiler and make. The UVM fetch command downloads the locked library; it does not install the simulator.

An explicit test path selects one case. Seeds 1 and 73 run that same built model in separate processes with different random initialization seeds, rather than selecting two different tests. See [the runner options](testing.md#running-the-suite) before expanding to the full suite.

If a command cannot start, check the executable version and build tools against [the prerequisites](faq.md#q2-what-do-i-need-and-where-does-uvm-come-from). If it runs but reports a difference, use the result explanations below.

## Read a result

For a simulation case, the runner compares the ordered lines beginning with `UT: ` to its `.expected` file, together with the declared exit and diagnostic checks; the complete log is not the expected output. See [what is observed](testing.md#what-is-observed).

`pass` means the declared checks matched; `fail` means a checked condition differed; `known` records a difference for an untagged Verilator case; `unsupported` records a kirimasim unsupported-feature diagnostic recognized by the runner. The last two are not passes. See [the status definitions](faq.md#q5-what-do-pass-fail-known-and-unsupported-mean).

The `elaboration` cases here expect the compiler to reject an illegal design and execute no runtime seed, while `simulation` cases run a model. Matches at both seeds do not establish four-state coverage including X/Z; see [the seed and compiler-count explanation](faq.md#q201-did-all-2384-tests-run-at-two-seeds).

With `--all`, known differences do not by themselves make the Verilator command fail, so inspect individual statuses as well as its exit code. See [why the exit code can still be zero](faq.md#q6-why-can-verilator-exit-successfully-with-known-results).

In a result JSON, find the test ID under `tests` and read its `status` and any `reason`; [the status definitions](faq.md#q5-what-do-pass-fail-known-and-unsupported-mean) explain the judgment before you investigate the expected output.

A reused result is evidence only for its recorded inputs, runner and library. See [how compatible records are combined](results.md#evidence-assembly) before treating an old JSON file as a current result.

When a case differs, inspect its cited rule, expected observation and setup before changing it; [Q18](faq.md#q18-how-should-i-report-or-correct-a-wrong-expectation) describes how to report or correct a suspected expectation error.

## Trace a difference

A difference is a starting point for investigation, and [the correction guide](faq.md#q18-how-should-i-report-or-correct-a-wrong-expectation) explains how to assess the expectation before proposing a change.

1. Find the case under `tests` in the result JSON and read its `status` and any `reason`; [the result definitions](faq.md#q5-what-do-pass-fail-known-and-unsupported-mean) distinguish an observed difference from an unsupported feature.
2. Use the test ID as the path below `tests/`, adding `.sv`, then read `:type:`, `:lrm:` and `:expected_stdout:` or `:expected_stderr_regex:`; [the metadata guide](testing.md#metadata) explains which checks apply to runtime and compiler-rejection cases.
3. Check the recorded library and runner before repeating the command, because the ordinary, HDL and command-line runners supply different implementations; [the execution setup](testing.md#the-uvm-library) describes those conditions.
4. For a runtime difference, compare the selected `UT: ` lines with the declared expected file, including their order, and check any exit or diagnostic condition; [the observation rules](testing.md#what-is-observed) explain why the complete log is not compared.
5. For a report or proposed correction, record the test path, suite commit, tool versions, command and expected behavior under its cited clause; [the reporting guide](provenance.md#issue-reporting-policy-and-form) explains the independent reproducer and accepted evidence.

A build failure has no runtime observation, while an accepted illegal design fails its compiler-rejection check without running a model; [Q199](faq.md#q199-why-does-a-compiler-rejection-count-as-a-match) explains the latter case.

## Read coverage and progress

Tests, standard identifiers and draft requirements are different counting units. M1–M4 name development stages; starting a later stage does not complete an earlier one. Use [the current README counts](../README.md#current-results) and [the counting rules](requirements.md#counting-unit-and-scope-proposal) together.

`unassessed` means no requirement decomposition or explicit classification has been recorded for an identifier; `partial` means its requirements are only partly decomposed; `assessed` records a reasoned structural or contextual classification. Structural covers grouping headings; contextual covers explanatory material tied to other requirements. None alone certifies complete behavior. See [the inventory states](requirements.md#review-work-queue-and-root-totals).

Zero tests without requirement links means every test has an explicit mapping. It does not mean every required behavior has a test, that every test passes, or that all scope decisions are approved; see [the zero-backlog explanation](faq.md#q128-does-zero-unmapped-tests-mean-m1m4-are-complete).

A `direct` link checks its stated duty; a `control` link helps assess a different premise. A control pass does not pass the original duty, and an `ai` review label does not record human review. See [how requirements link to observations](requirements.md#citations-requirements-and-execution-evidence).

The Check badge describes a workflow run; the result tables have their own measured conditions. See [the CI scope](results.md#continuous-integration) before comparing the two.

## Before changing or reporting a test

Derive an expectation from a standard clause before changing a test to address a difference. A changed source, helper or expectation needs a new input identity and compatible measurements; see [the mapping update procedure](requirements.md#updating-a-test-or-mapping).

The local standard PDFs and private Ghost configuration are not supplied by cloning this repository; [the handoff file guide](handoff.md#files-and-local-material) lists those prerequisites before you change an expectation or attempt a guest run.

Files under `out/` are generated local material and may be absent in a fresh clone. The versioned ledger and index record the maintained inputs; see [the file and evidence guide](handoff.md#files-and-local-material).

For an issue, describe the expected behavior and an independent reproducer using the [posting policy](faq.md#commercial-simulator-and-issue-reporting-policy); that page explains which source material the project accepts.

## Choose the next document

For a question about a particular API or clause, start with the test header and follow [its requirement and observation links](requirements.md#citations-requirements-and-execution-evidence) to see exactly which behavior is checked.

- [Run a test](testing.md#running-the-suite)
- [Look up a term](glossary.md)
- [Find a specific answer](faq.md)
- [Read current measurements](results.md)
- [Inspect requirement mappings](requirements.md)
- [Resume development](handoff.md)
- [Trace an earlier change](history.md)
