# kirimasim-uvm-tests

[日本語](README.ja.md)

A conformance test suite for simulators running the Universal Verification
Methodology, IEEE 1800.2-2020 (UVM). It is written for the
[kirimasim](https://github.com/kurochan001/kirimasim) simulator and pairs with
[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests), which checks
the SystemVerilog language of IEEE 1800-2023.

> **Status: M2 (TLM, sequences and callbacks in progress).** 301 tests,
> the pinned UVM fetcher, runners for kirimasim, Verilator and Ghost,
> metadata checks and the Check workflow. M1's clause-by-clause target
> remains open;
> see "Current M1 increment" and "Current M2 increment" below.

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
tools/sv_lifetimes.py        lexical guard for initialized procedural locals
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
With the second M1 increment, bundled runs match 31 of 61 tests with both
seeds; the same 30 cases differ. The third increment matches 41 of 101
tests with both seeds, with the same 60 differences. After the fourth
increment, both seeds match 45 of 133 tests, with the same 88 differences. The sixth
increment matches 49 of 157 tests with both seeds, with the same 108 differences.
The seventh increment matches 53 of 181 tests with both seeds, with the same
128 differences. The eighth increment matches 54 of 205 tests with both
seeds, with the same 151 differences. The ninth increment matches 57 of 229
tests with both seeds, with the same 172 differences. The first M2
increment matches 73 of 253 tests with both seeds, with the same 180
differences. The second M2 increment matches 79 of 277 tests with both
seeds, with the same 198 differences. The third M2 increment matches
82 of 301 tests with both seeds, with the same 219 differences.

| Simulator | Current status |
| --- | --- |
| kirimasim | local executable reports all 301 cases as unsupported at `uvm_object_wrapper` |
| Verilator 5.052 | `UVM_NO_DPI`: 295 oracle cases match seeds 1 and 73; six spec-only cases retain known differences |
| Ghost (an unreleased simulator, as in kirimasim-tests) | bundled UVM: 82/301 match with both seeds; pinned UVM: smoke test differs |
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

The second increment added another 34 tests, bringing the suite to 61:

- Object ID lifetime, static/dynamic wrappers, copy policy selection and
  comparison hook/results: eight tests.
- Report action and verbosity precedence, including NO_ACTION suppression:
  four tests.
- Factory type/instance aliases and override/registration queries: six tests.
- Common-phase lookup and ordering: two tests.
- Objection drain time and re-raising during drain: two tests.
- Configuration scope globs and blocked `wait_modified` notifications:
  four tests, with watchdogs for the blocking cases.
- String comparison/reset, string packing boundaries, nested deep copying
  and copier-hook state, and printer controls: two tests each.

The clause-number inventory also includes the previously omitted 6.3.5.2,
verified against the standard. ID tests compare identity relationships,
not particular numeric IDs; string packer tests check round trips without
prescribing an implementation's stream representation.

The third increment added 40 tests, bringing the suite to 101:

- Object pack/unpack through bit, byte, int and longint streams, including
  policy reuse and default selection, plus field-operation state and hook
  suppression: eight tests.
- Report-server severity counters, independent server state, quit limits
  and current-count updates: four tests.
- Object/component registry creation with parent and explicit contexts:
  four tests.
- Task-phase thread termination and completion while an objection is held:
  two tests.
- Objection source listing, zero-count removal and global clearing:
  four tests.
- Policy-side active-object stacks, comparer type/reference controls,
  printer file/default selection, and array/time/real packing: fourteen tests.
- Configuration presence, diagnostic spell checking and independent updates
  by field and scope: four tests.

Array packer tests use bit counts for explicit sizes and compare decoded
values. The empty-array unpack explicitly requests zero bits. Printer file
checks use a custom emission string; they do not prescribe a built-in layout.
Task-phase checks hold objections for positive delays and inspect child
state after the child would otherwise have resumed.

The fourth increment added 32 tests, bringing the suite to 133:

- Transaction lifecycle timestamps, hooks, identifiers, initiators and named
  events, including the normative initial inactive state: six tests.
- Report file selection and independent updates, severity-override precedence
  and replacement, and shared/replaced handlers: six tests.
- Registry convenience methods for relative instance overrides and type
  override replacement: four tests.
- Phase callback states, ready-to-end objections, iteration limits and state
  waiters: four tests.
- Objection event waiters for raised, dropped and all-dropped events, with
  callback/drain timing and target-object isolation: four tests.
- Real comparisons, ordered copy/compare histories, history reset and
  integer-array packing boundaries: eight tests.

Transaction cases disable recording before acceptance, keeping their
observations independent of recording backends. Blocking phase/objection
cases have watchdogs and positive delays before producer events. The phase
state observer holds a run objection until it has observed main ending.
Initialized procedural locals in this increment use automatic lifetime,
following SystemVerilog 6.21, so their initialization executes at block entry.
The phase-limit test samples its class default in an executable statement
after static initialization.

The fifth increment completes the initialized-local lifetime audit of all
133 cases. Across 84 earlier tests, 202 declarations now use `automatic`.
Four initialized variables in the two guarded-fork configuration tests
instead use static storage with separate block-entry assignments, keeping
shared state alive across the branches. All 206 initializations therefore
execute at block entry, including constructor and getter calls. The static
storage also avoids Verilator's rejection of potentially escaping automatic
references in those two cases. The tests cite SystemVerilog 1800-2023 6.21.
No expected file changes.
The other cases already use explicit lifetime, use automatic class methods,
or have no initialized procedural locals. The two module-level helper
functions are explicitly automatic.

The metadata check now uses `tools/sv_lifetimes.py` to catch the same implicit
lifetime pattern in initial/always begin/fork blocks. Its regression cases
cover nested scopes, parameterized/scoped types, arrays, comments, strings,
and explicit automatic/static declarations. It is a lexical source check;
it does not expand macros, parse subroutine lifetime, or inspect the pinned
library. Compiler execution remains part of validation.

The fifth increment kept 133 UVM tests and increased tool unit tests from
30 to 41. Changed cases were rebuilt with both Verilator seeds. Unchanged
execution evidence is reused only when input and runner fingerprints match.

The sixth increment adds 24 tests, bringing the suite to 157:

- Policy extension insertion, dynamic type keys, replacement, individual/all
  deletion, policy isolation, flush preservation, and use by copy/compare
  hooks: twelve tests.
- Configured object handle identity, class-type specializations, null values
  and replacement while old handles remain valid: four tests.
- Local phase schedule append, constrained insertion, parallel branches and
  adjacent-node queries: four tests, without executing the local schedules.
- Report-handler reset, report ID sets, and independent statistics snapshots:
  four tests. The severity-ID reset expectation is retained as spec-only.

Extension tests observe registered wrapper keys and handle relationships,
without depending on storage layout. Hook code handles absent extensions
explicitly. Report ID and graph-neighbor checks compare membership rather
than iteration order. Counter snapshots are populated through report calls,
without implementation-only ID counter setters.

The seventh increment adds 24 tests, bringing the suite to 181:

- Shared UVM seeding controls, disabled-reseed RNG state preservation,
  virtual object creation and default/custom string conversion: eight tests.
- Packer state transfer through bit, byte, int and longint snapshots,
  comparer reporting controls, printer array windows and element-stack
  push/pop/flush behavior: twelve tests.
- Task-phase objection forwarding and independent node counts, plus errors
  for invalid objection operations on function phases: four tests.

RNG state is compared only for equality on the same object; its encoding and
random values are not prescribed. Packer snapshots come from the matching
getter on a compatible implementation, without inspecting stream layout.
Printer stack accessors are exposed by a test subclass. Old element handles
are not inspected after flush, as they may be recycled. Function-phase error
cases discard invalid return values and check reports without fixing their
wording or identifiers. The local schedules are not executed.

The eighth increment adds 24 tests, bringing the suite to 205:

- Report-message common fields, independent action/file updates,
  infrastructure references, message isolation and calling-thread RNG
  preservation by the creation helper: eight tests.
- Field-operation names and types, accessor preconditions, repeated set
  calls and invalid combinations of operation flags: eight tests. The two
  accessor-precondition cases retain the required errors as spec-only.
- Factory registration and wrapper lookup, exact type/name queries,
  independent factory instances and selection through the core service:
  eight tests.

Message tests inspect assigned fields and handle identities without emitting
those messages or depending on descriptor values. RNG state is observed from
an initial process as an opaque equality comparison. Field-operation error
cases discard invalid return values and flush before reuse. Local factories
keep registration checks independent of globally registered built-in types;
selection tests restore the saved global factory handle.

The ninth increment selects previously untested API clauses before adding
24 tests, bringing the suite to 229:

- Wrapper object/component creation and represented type names: six tests,
  two each for 8.3.2.2.1, 8.3.2.2.2 and 8.3.2.2.3. The `test_wrapper_*`
  cases in `tests/u08/` call through the common proxy handle.
- Packer object round trips, non-consuming null queries, incompatible null
  targets, operation/hook order, active-object state and hook suppression:
  eight tests for 16.5.4.2, 16.5.4.3 and 16.5.4.4, with at least two
  focused cases for each clause.
- Printer element construction and field updates, plus immediate-child
  queries, queue-prefix preservation, leaves and repeated appends: ten
  tests. These cover 16.2.8.2.1 through 16.2.8.2.6 and 16.2.9.2.1 through
  16.2.9.2.2, with at least two focused cases for each clause.

These 14 reviewed API clauses now meet the two-test target. This is a
focused mapping, not a complete M1 requirement inventory. Other clauses
still need review: metadata citations can describe setup or structural
clauses, so citation counts alone do not establish requirement coverage
or an exact remaining test count.

Object streams come from the same packer implementation; marker widths and
encodings are not prescribed. After an incompatible null-target error, no
further unpack operation is attempted. Child relationships are constructed
through standard printer stack operations. Proxy cases compare membership
and preserved queue entries without assuming sibling order or using
implementation-specific child mutation APIs. They do not inspect handles
after printer flush. Virtual overrides use the base declaration's argument
names, including `op` for `do_execute_op`.

Across the second through eighth increments, nine additional limitations
of the pinned reference library were identified beyond its own `DEVIATIONS.md`:

- With no override installed, `find_override_by_name` returns null even
  when creation can instantiate the original type. Clause 8.3.1.7.1
  describes the wrapper of the object that would be created. The new
  lookup tests install overrides; alias tests inspect created objects.
- The default config_db implementation looks up field names literally,
  so a configured field-name glob does not select matching names as
  described by C.4.2.2.1. The new glob cases exercise scope patterns with
  literal field names.
- A nested field copied by a field macro still gets a distinct object
  under UVM_SHALLOW, while 16.6.3 describes reference treatment of nested
  objects. The new cases cover deep field-macro copying and the configured
  copier/active-object state visible to a user hook.
- `uvm_object::get_active_policy` from 5.3.14.3 is absent. The hook test
  observes the copier's active-object stack through the APIs of 16.1.3.
- `uvm_field_op::user_hook_enabled` rejects calls before `set` and after
  `flush`, although 5.7.2.7 does not state that restriction. The field-operation
  reset test queries the bit after `set`, including after a flush/reuse cycle.
- `get_objectors` retains a source whose count has reached zero until drain
  cleanup, while 10.5.1.5.1 describes the current objecting sources. The
  immediate post-drop list case preserves the standard's expected membership
  as a spec-only test.
- `uvm_transaction::is_active` reports 1 immediately after construction,
  although 5.4.2.12 requires 0 before the first begin. The initial inactive
  state is retained as a spec-only test; matching lifecycle tests observe
  active state only after a begin or end.
- Report-handler reset leaves severity-ID overrides in place, although
  6.3.8.3 requires clearing changes made through the override methods of
  6.3.7. The new count-based reset case preserves the required original
  severity as a spec-only expectation.
- `uvm_field_op::get_op_name` does not report an error before `set` or
  after `flush`, although 5.7.2.3 requires one. Both accessor-precondition
  cases keep the required error as spec-only; they also check the required
  errors from `get_op_type`, `get_policy` and `get_rhs`.

These branches are not treated as reproduced fixed-release oracles. The
post-drop list, initial transaction state, severity-ID reset and invalid
field-operation name cases are retained for diagnostics; the other library
limitations are avoided by the matching test scenarios.

Across the suite, 295 tests have the `verilator@5.052` oracle tag and six
cases are spec-only. Another spec-only case checks 9.6: a child's pre-reset
task must be killed when that phase ends, but the pinned-library run on Verilator 5.052
lets the child perform its delayed write during a later phase. The cause of
this combined simulator/library difference remains unassigned.

The six spec-only tests retain their normative expected files.
Default Verilator runs and CI select the 295 tagged cases. An explicit run
with `--all` includes the six spec-only cases and records them as `known`.
The runner stops each test at its first differing seed; their current
Verilator records establish seed 1 differences, without claiming a seed 73
result for those six tests.

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

### Current M2 increment

M2 starts with 24 TLM 1 tests in `tests/u12/`, bringing the suite to 253:

- Bounded/unbounded FIFO capacity, occupancy and availability, arrival order,
  non-consuming peeks, rejected writes, flush and independent storage:
  eight tests, centered on 12.2.8.2 and the methods of 12.2.4.2.
- Blocking FIFO get/put wait until data/space becomes available: two tests.
- Analysis FIFO write order, unbounded capacity, interleaved reads/writes,
  peeks, flush and independent instances: six tests for 12.2.8.3.
- Analysis-port broadcast to two receivers, object-handle preservation,
  zero-subscriber writes and forwarding through an analysis export:
  four tests for 12.2.10.
- Blocking/nonblocking put and combined get-peek ports connected to FIFO
  exports: four tests for 12.2.5.1 and 12.2.8.1.3/12.2.8.1.4.

Port tests run normal UVM elaboration before observing resolved bindings.
Analysis receivers are inspected after write returns; no subscriber-call
order is prescribed and subscribers do not mutate transaction objects.
Blocking tests hold objections, use positive delays to observe the waiting
state, keep shared values in the test object and include watchdogs. Stateful
operations execute in separate statements before their results are printed.
Unavailable-read cases observe return status and queue state; they do not
claim to cover the required preservation of output arguments on failure.

The first 24 M2 cases match Verilator 5.052 with seeds 1 and 73.

The second M2 increment adds 24 cases in `tests/u14/` and `tests/u15/`,
bringing the suite to 277:

- Sequence-item context assignment/replacement, parent/depth/root/path
  queries, sequence-info flags, inactive sequencer references and virtual
  item/sequence classification: eight tests for 14.1.2.
- Sequence execution hooks and states, optional pre/post-body suppression,
  parent hooks, priorities, restart, state waiters, randomization-enable
  controls and starting-phase/automatic-objection controls: eight tests
  for 14.2.
- Sequencer arbitration and request/response-buffer size controls, explicit
  item acknowledgements, peek/get consumption, two-item transfers and
  response routing via item_done/put: eight tests for 15.3 and 15.5.

The 24 new cases also match Verilator 5.052 with both seeds. Handshake cases
connect the driver's pull port to the sequencer export during normal UVM
elaboration and exercise it in run phase, with automatic item recording
disabled. Shared request/response handles live in the test object. Positive delays make pending acknowledgements
observable and let response waiters settle; watchdogs bound blocking cases.
Responses copy routing IDs with set_id_info. Only explicitly assigned
transaction IDs are printed, never allocated sequence IDs. Counters are
initialized explicitly, and the standalone state-wait test uses a module
handle with a positive body delay.

Control-setting cases do not claim to cover automatic randomization,
automatic phase objections, arbitration among competing sequences or buffer
contents.

The third M2 increment adds 24 cases, bringing the suite to 301:

- Callback enable transitions, ignored mode values, append/prepend execution
  order, instance-local registration/deletion, required duplicate/removal
  warnings, typewide registration/deletion and get_all membership: twelve
  tests for 10.7, with type-pair and execution macros from B.4.
- Forward/reverse callback traversal, disabled-entry filtering, current
  callback identity, independent iterator positions and object contexts:
  four tests for D.1.
- Request/response channel FIFO order, independent bounds, non-consuming
  peeks, unbounded queues, accepted-write analysis notifications, combined
  master/slave interfaces and blocking transport waits/reuse: eight tests
  for 12.2.9, using int requests and string responses.

These 24 cases also match Verilator 5.052 with both seeds. Callback enable
values are assigned explicitly. Execution checks use documented
append/prepend order, while get_all checks compare membership and preserved
queue prefixes. The fixture type is named user_callback to avoid collision
with the macro-local cb identifier; expected values do not depend on that
type name. Iterators are not used to mutate callback registrations.

Channel tests use public typed ports/exports after normal elaboration,
without inspecting the protected FIFOs. Analysis monitors are read after
accepted writes. Transport tests keep shared values in the test object,
use positive delays to observe waiting and include watchdogs. Nonblocking
transport and callback name-based registration/inheritance remain for later
coverage.

M1's six spec-only cases and remaining clause coverage are retained;
starting M2 does not mark M1 complete. More sequence/sequencer and callback
behavior, further TLM channel cases and TLM 2 remain M2 work. M2 is not complete.

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
