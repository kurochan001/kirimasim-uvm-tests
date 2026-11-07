# Current results and measurement methodology

[日本語](results.ja.md) · [README](../README.md) · [Known differences](known-differences.md)

## Current snapshot

Runtime matches, compiler rejections and unmeasured inputs describe different execution conditions; [Read a result](reading-guide.md#read-a-result) explains how to read the counts together.

The Verilator snapshot assembled on 2026-11-07 covers all 2715 current tests.
Guest records retain 1081 compatible current inputs; 1634 inputs are
unmeasured, including four revised old inputs. Each record
fingerprints its inputs and conditions.
The suite has 2715 fixtures in 22 directories: 2616 simulation and 99
elaboration. Milestone totals are M1 1167 (1086/81), M2 620 (613/7) and M3 928
(917/11), with runtime/elaboration counts in parentheses. All use `spec_check: ai`;
none records human review. Of 2659 no-DPI fixtures, 99 are illegal elaboration
checks. The thirty-eight HDL-DPI and eighteen command-line/regex-DPI runtime fixtures
remain separate.

Counts do not establish a reviewed coverage percentage.

Backend rows revisit inputs already included in the ordinary row under different conditions; [the execution setup](testing.md#the-uvm-library) explains why their results are counted separately.

A runtime match at seeds 1/73 still counts as one fixture, while a seed requested in configuration may be skipped after a first mismatch; [the seed-count explanation](faq.md#q201-did-all-2715-tests-run-at-two-seeds) explains how to read the execution scope column.

| Simulator and library | Observation | Execution scope |
| --- | --- | --- |
| Verilator 5.052, pinned UVM | 2259 `pass`: 2165 runtime + 94 compile rejection; 456 `known` | Runtime matches use seeds 1/73; expected compiler rejections execute no runtime seed |
| Verilator 5.052, original VPI HDL backend | 37 `pass`; 1 `fail` | Separate overlapping 38-case condition; matches at seeds 1/73, difference at seed 1 |
| Verilator 5.052, original command-line VPI bridge and pinned regex DPI | 17 `pass`; 1 `known` | Separate overlapping 18-case condition; matches at seeds 1/73, difference at seed 1 |
| kirimasim, pinned UVM | 1072 `unsupported`; nine `fail` | 1081 unchanged inputs; 1634 inputs unmeasured |
| Ghost, bundled UVM | 206 `pass`; 875 `fail` | 1081 unchanged inputs at each seed; identical failing sets; 1634 inputs unmeasured |
| Ghost, pinned UVM | Not measured for the current executable snapshot | No current pinned-mode claim |

The pinned library is Accellera UVM 2020.3.1, commit `78c06547a2a0`, with
326 files checked against [the lock](../third_party/uvm.lock). A Ghost bundled
run uses the supplied library rather than that lock's package. Private
simulator identity, version, paths, profile contents and diagnostics are
not published. [Ghost setup](testing.md#ghost) describes the public interface.
Icarus Verilog is not used for this UVM suite.

## Interpretation

One test may check several observations, and a required mismatch keeps the whole case from passing even when other rows match; [the judgment rules](faq.md#q5-what-do-pass-fail-known-and-unsupported-mean) explain its recorded status.

To investigate an individual row, [Trace a difference](reading-guide.md#trace-a-difference) connects its result JSON to the source, expected observation and runner condition.

If the identifiers are unfamiliar, [the smoke-test example](reading-guide.md#follow-one-test-through-the-files) shows how a result ID, source filename, UVM class and requirement ID relate to one another.

For a runtime output mismatch, `reason` identifies the first differing selected line, so use [the observation rules](testing.md#what-is-observed) to compare it with the declared expected sequence.

A build failure stops before simulation, while a runtime difference comes from an executed model; [Q14](faq.md#q14-do-two-seeds-prove-determinism-or-four-state-correctness) explains which seed results exist in each case.

94 valid negative expectations match by compiler rejection with the
declared fixture/type/member diagnostic. Five illegal designs remain accepted:
subscriber write, visitor visit, proxy get_immediate_children and adapter accept omissions, and direct construction of the
printed virtual builtin dispatcher. They retain the rejection oracle as known
differences without runtime, even when accepted. The 135 unexpected simulation
builds remain separate. A pass requires the declared expectation.

The 456 spec-only cases retain standard-derived output or compile-diagnostic
expectations. Five are illegal compiler acceptances; 451 are simulation cases.
Of these, 316 first differ at runtime seed 1 without seed 73. Forty-three cannot build
because of missing APIs/type names: one time API, fourteen sequence-library APIs,
twelve HDL slice-view cases, one named-concat constructor, five object active-policy API cases,
three catcher message-handle cases, the printed base recording-state getter,
the printed report callback typedef and two builtin type_id cases, plus three typed resource-DB helper cases.

One time-decrement build requires the printed optional secs argument.
Two declaration builds retain incompatible defaults; two retain printed
all_dropped function/task and clone implicit-scalar/map-return conflicts. Two
retain incompatible inherited type_id registry specializations; one retains the
protected memory backdoor_read accessibility difference. Two legal extensions, resource-base and listed-only complete core service,
also require unlisted pure hooks. Another 56 request
unlinked DPI: thirty-eight HDL and eighteen command-line cases. Three additional legal
builds use the literal enum-collection T interpretation. Seven further builds
retain six strict attribute definitions and the printed enum-unpack arity.
Three more builds retain dependent visitor defaults with custom STRUCTURE.
Two qualified virtual-abstraction overview-base inputs retain the wording
conflict; their explicit class-base controls match separately. Two additional
printed dedicated-pool return-type inputs retain the pool/item conflict. These 135
simulation builds have no runtime result. Separate command-line evidence remains
seventeen matches and one quit-warning difference.

One additional legal construction input is rejected as an abstract uvm_vreg_cbs
facade under the pinned virtual declaration; its printed concrete expectation is
retained without runtime.

Four additional bare-packet simulation builds stop at the typed factory result used for predictor type naming; they have no runtime evidence and do not create a mandatory IEEE registration prerequisite.

Two additional simulation builds report unsupported enum methods for the large
flag extension and an undefined UVM_PACKER_MIN_BITS; neither has a runtime result.

The shared-handler reset case retains the severity/ID verbosity value while
general and ID values, action and file return to defaults. The expected reset
and subsequent boundary delivery remain unchanged. This adds one runtime
fixture to the known set; prior severity-override reset differences remain.

The separate VPI condition has thirty-eight fixtures: thirty-seven match both
seeds. Three memory inputs access real array cells through inherited tasks,
split banks and ROM write versus poke; wrappers retain the separate public-read
declaration limitation. Nine primitive force/release inputs check real public
8/40-bit regs/wires and immediate release/read behavior.

Eight new positive-duration force_time inputs observe periods 5/13, interior
force retention, post-period reg/wire state, later updates and dormant/peer
isolation. Calls are sequential in the shared compilation-default time unit;
no exact-expiry ordering, return-time/result or overlapping-argument claim is
made. The backend and both runners are unchanged. Six actual-register inputs cover
public backdoor_read, peek and poke observations for 16/40-bit whole variables
and legal two-variable split references. All thirty-eight current HDL records
are retained unchanged in this increment.

The E.7 inaccessible-path sequence still reports ERROR and attempts reads rather
than the retained warning/no-transfer expectation at seed 1, with no seed 73
result. General types/selects/arrays, cross-unit/rounding, overlapping timed calls,
failure/cancellation and four-state behavior remain open. Do not add overlapping
matches to ordinary results; see [HDL setup](testing.md#verilator-vpi-hdl-subset)
and [known differences](known-differences.md).

kirimasim reports `uvm_object_wrapper` as unsupported on 1072 cases; the other
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

Two additional simulation builds are the conditional B.4 directional type controls, with assignment-type errors and no runtime; [Q392](faq.md#q392-do-the-type-relation-controls-settle-the-b4-base-wording) explains why they do not establish mandatory ancestry or a library-only cause.

## Evidence assembly

This section explains how existing records can support a combined snapshot; for a first local measurement, use [the single-test command](faq.md#q3-how-can-i-run-one-test-first) and [the JSON-reading example](reading-guide.md#open-the-result-json).

A fingerprint identifies the exact inputs behind a reused record, so [Execution and result records](glossary.md#execution-and-result-records) explains why an old match may not apply after an edit.

Here an unmeasured input has no compatible current record, even if an older version was run; [Q15](faq.md#q15-how-do-i-know-whether-an-old-result-still-applies) explains the checks needed before reusing it.

The snapshot starts from [63e7b02](https://github.com/kurochan001/kirimasim-uvm-tests/commit/63e7b026a48a6c0279e8887383b0d55e0711986b), retains all 2709 old ordinary records,
and adds six M1 simulation inputs on 2026-11-07 JST.

The profiles below check only their stated conditions, so a match under a different premise cannot pass an original difference; [the requirement-link guide](requirements.md#citations-requirements-and-execution-evidence) explains the recorded direct/control roles.

The 110th expansion adds six M1 event-wait profiles: wait_on/wait_off with
the delta argument omitted, explicitly zero or explicitly one. They call the
actual event methods in two reuse rounds, with an already blocked default
waiter, a later controlled release of an unsatisfied wait and an independent
peer event. [The delta FAQ](faq.md#q419-what-do-the-event-delta-profiles-add)
explains the three argument forms.

An original no-wait task checks the SystemVerilog deferred-child premise.
A fresh fork/join_none child cannot start until its parent blocks or ends:
it must remain pending across an already-satisfied omitted/zero call and run
across an explicit-one call. Both time and realtime must remain unchanged.
A separate module process queues a real NBA update in Active before the
tested call; that update must still be pending at return and visible after
a positive-time drain. These are observations of yielding and pre-NBA return,
not a count of every consecutive #0 control; [the scheduler-witness FAQ](faq.md#q420-why-use-both-a-deferred-child-and-a-pending-nba)
explains the limits. The fixture inserts no #0 workaround.

All six final tagged inputs match seeds 1/73. Each initially unsatisfied wait
remains blocked until its controlled trigger/reset and returns at that
transition's time, while the peer remains waiting until its own reset.
Existing ready-waiter completion order is investigative for every argument:
four DIAG110 rows per case per seed, 48 current rows in total, have no oracle
or requirement link. The delta sentence's scope after an initially
unsatisfied wait still needs review; no stronger waiter-completion ordering
is inferred from the printed opportunity to resume.

The earlier six pretag and six tagged inputs also matched, but lacked the
NBA-region witness. They are archived under
`out/thin-one-hundred-tenth-before-region-witness/` and are not current evidence.
The region review strengthened the independently derived expectation and
removed the earlier ready-waiter completion assertion before new measurement.
The current pretag and final batches each match all six cases at both seeds;
only the oracle tag changes between those current batches.

Two new already-satisfied delta-yield duties and two prefix-preserved
persistence/reset extensions produce 4099 AI duties. The other 4095 old
requirements and all 445 assessments are unchanged. All 2709 old ordinary
and index records, all 456 known inputs and both backend subsets are retained.
There are 2259 ordinary matches: 2165 runtime inputs at both seeds and 94
expected compiler rejections. No guest run or filter is added: 1081 compatible
records remain byte-identical and 1634 inputs are unmeasured, comprising
1630 additions and four revised originals (1535 simulation, 99 elaboration).

Chapter 10 still has 87 partial/29 assessed/0 unassessed identifiers, with
169 duties and 140 primary-focus tests. Across the catalog, 1315 identifiers
have primary tests; candidates are 1171 zero/770 below target/541 at least two.
The suite has 2062 partial/445 assessed/0 unassessed identifiers and 2659
directly linked tests, with 56 control-only tests. Scope, denominator and
human review remain unapproved/unrecorded. Exact consecutive-delta counts,+post-blocking delta applicability, event callbacks, waiter-count/reset and
kill/cancel combinations, full event contracts and original milestone targets
remain open; [the completion FAQ](faq.md#q421-do-the-six-matching-event-profiles-complete-the-clauses)
distinguishes this progress from completion.

Retained kirimasim/Ghost records were collected with fixed executable
snapshots and Ghost's seed-specific private profiles.

Commercial simulator results are excluded under the
[reporting policy](faq.md#commercial-simulator-and-issue-reporting-policy).

The earlier temporary kirimasim/Ghost executable/profile snapshots are no
longer available, so no guest rerun is claimed. Historical source files retain
1085 records. Earlier filters excluded four revisions: command-enum citation,
Boolean rerandomization, virtual-field configuration and reraise primary citation.
This increment performs no new filtering. All 1081 compatible records and
filter metadata are retained byte-identically. Six additions increase the
unmeasured set to 1634: 1630 additions and four revised originals. Ghost remains
206 pass/875 fail per seed and kirimasim remains 1072 unsupported/nine API failures.
The latest exclusions are recorded in `out/thin-one-hundred-sixth-guest-exclusions.json`;
the current scope is in `out/thin-one-hundred-tenth-evidence-scope.json`.

The fingerprints identify different inputs:

SHA-256 is a digest of recorded content, and [the fingerprint glossary](glossary.md#execution-and-result-records) explains why matching one digest alone does not establish the same execution conditions.

Editing only a requirement's wording calls for a regenerated inventory, while editing a test header changes its test fingerprint and requires compatible execution evidence; [the update procedure](requirements.md#updating-a-test-or-mapping) describes both paths.

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
  their declared 1081-case subset; 1634 input IDs remain unmeasured.
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

The [draft ledger](requirements.md) has 4099 AI duties and 0 unassessed
identifiers: 2062 partial/445 assessed. Chapter 10 is 87/29/0; chapter 18 is
393/63/0. Their partial contracts and original targets remain open. Direct
links cover 2659 tests; 56 others have only controls. Guests retain 1081
compatible inputs; 1634 (1535 simulation/99 elaboration), including four
revised originals, are unmeasured. Scope and denominator remain unapproved.

## Reproducing and retaining results

Writing to the same `--json` path replaces that file, so choose a new filename to retain an earlier run when following [the runner commands](testing.md#running-the-suite).

A rerun creates a new local measurement, and [the result-saving guide](testing.md#running-the-suite) explains how to choose an output JSON for that run.

An entry missing from one JSON file supplies no judgment for that case, so [the JSON-reading example](reading-guide.md#open-the-result-json) explains where to find its status and how to check the selected inputs.

To investigate one listed difference, select its source path with [the single-test command](faq.md#q3-how-can-i-run-one-test-first) and retain the same library and backend conditions as the record.

The JSON output is a local record of a selected run, and [Q10](faq.md#q10-where-is-nightly-or-the-public-results-dashboard) explains how it relates to the public Check badge.

Historical `out/` files may be absent in a fresh clone, so [the local-material guide](handoff.md#files-and-local-material) distinguishes reproducible tracked commands from optional measurement artifacts.

A result test ID is the path below `tests/` without `.sv`, so [the layout guide](testing.md#layout) helps locate the source and its declared expected file from a JSON entry.

The [testing guide](testing.md#running-the-suite) documents the commands,
profile modes and library settings. Request `--json out/<name>.json` to retain
statuses, reasons, configuration and fingerprints. `out/` is ignored by Git,
and Check does not publish these local evidence files. A result from different
inputs, a different runner, executable, profile or library is a separate condition.

## Continuous integration

A commit identifies a repository revision, so check the revision on a linked workflow run before comparing it with your files; [the handoff snapshot guide](handoff.md#snapshot-and-objective) explains how to establish the workspace's starting point.

A shard runs a disjoint subset of the selected tests, and the final gate requires every shard to succeed; [Q268](faq.md#q268-does-dividing-check-into-shards-reduce-the-required-test-scope) explains how that relates to the test scope.

[Check](../.github/workflows/check.yml) runs on pushes to `main`, pull requests
and manual dispatch. It checks pinned-library integrity, 110 tool unit tests,
2715 metadata records and the draft ledger/index. Its 2259 tagged ordinary
Verilator checks comprise 2165 runtime cases at seeds 1/73 and 94 compiler
rejections without runtime seeds, plus seventeen
explicit command-line checks under their separate condition.
The previous unsharded [Check run](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/41976785278)
exceeded the configured 150-minute job limit. The current workflow partitions
the current 2259 tagged checks into 8 disjoint shards (283/283/283/282/282/282/282/282),
with at most 4 concurrent shard jobs. The exact union and absence of duplicates are
verified locally. The 17 command-line checks run once, on shard 0 before
ordinary checks. Seeds 1/73, compiler-rejection judgment, pinned dependencies
and runner fingerprints are unchanged. The existing verilator gate requires
all shards to succeed. Sharding is orchestration; local
validation does not establish a successful hosted workflow result.

It does not run kirimasim, Ghost or spec-only cases. The README's badge is the
live CI state, separate from these local measurements. A green Check does
not establish complete UVM conformance or a passing result for every simulator.
There is no Nightly workflow or automatic result publication.
