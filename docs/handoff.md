# Development handoff

[日本語](handoff.ja.md) · [README](../README.md) · [Requirements](requirements.md)

Current transfer: the user resumed the goal on 2026-11-07, and the 124th expansion, the seventh item of an external review, is published. Read the [Claude Code handoff](claude-code-handoff.md) for the published checkpoint, next proposals and restart instructions.

This page supports resuming development; if you want to run or understand a first test, start with [the reading guide](reading-guide.md).

## Snapshot and objective

The base commit below identifies the starting point for the described work, so check uncommitted changes before treating saved results as evidence for the current files; [the input-update procedure](requirements.md#updating-a-test-or-mapping) explains how to review their compatibility.

Updated on 2026-11-09 for the 124th expansion, based on
[9601387](https://github.com/kurochan001/kirimasim-uvm-tests/commit/960138734ce23d521c36a645315044e070487cfa)
on `main`. Verify the current publishing commit and working tree before resuming.

The project tests IEEE 1800.2-2020 UVM conformance, targeting kirimasim.
SystemVerilog language-only reproducers belong in
[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests).
Continue strengthening thin areas across M1–M4. M4 remains in progress;
zero unlinked tests does not complete any milestone.

| Area | Current snapshot |
| --- | --- |
| M1 | 1188 tests (1107 runtime, 81 elaboration): core objects, policies, reporting, hierarchy, factory, phases, synchronization, recording and utilities |
| M2 | 633 tests (626 runtime, 7 elaboration): sequences, sequencers, callbacks and TLM |
| M3 | 942 tests (931 runtime, 11 elaboration): register/memory layer and annex E |
| Entire suite | 2763 tests (2664 simulation, 99 elaboration) in 22 chapter/annex directories; all AI-reviewed, none human-reviewed |
| M4 | 4151 AI requirement drafts; 4151 have direct links to 2707 tests; fifty-six control-only tests; zero tests without links |
| Normative inventory | 2062 of 2,507 identifiers partially decomposed; 445 explicitly assessed; 0 unassessed; zero drafts without direct tests |

`scope_status` remains proposed, `normative_inventory_complete` is false,
and `approved_denominator` / `coverage_percentage` remain null. All twenty-two
roots with primary-focus tests have zero unlinked tests. Their normative
decomposition and human review remain incomplete.

## Policies to preserve

Ghost configuration is needed only for its private guest measurements; [the public runner commands](testing.md#running-the-suite) provide a starting point without that configuration.

- Read the active workspace instructions first. The user-supplied agent
  guidance for this session references `RTK.md`; resolve it in the current
  environment before continuing.
- Derive expectations from the user-provided IEEE standards. Keep original
  fixtures and bilingual paraphrases; do not copy standard text, figures or
  examples. The pinned Apache-2.0 UVM source may explain a difference but
  does not define the oracle. See [provenance](provenance.md).
- Do not read GPL/LGPL simulator implementation source. Running permitted
  executables and inspecting test output is allowed.
- Commercial simulator results, outputs and diagnostics are excluded,
  including third-party or anonymized material. Follow the
  [reporting policy](faq.md#commercial-simulator-and-issue-reporting-policy)
  and [Issue form](../.github/ISSUE_TEMPLATE/report.yml).
- Ghost is the permitted private guest under its public alias. Keep real
  identity, version, executable/profile paths, profile contents and raw
  diagnostics private. Obtain authorized local configuration separately;
  never place it in tracked documentation.
- Keep every guide fully English/Japanese. README describes current state;
  increment narratives belong in [history](history.md). Keep
  `spec_check: ai` and AI requirement review until actual human review.
- When behavior differs, review the fixture and cited clause first. Correct
  fixture mistakes; retain a valid normative expectation as spec-only and
  document the difference. Do not copy observed output to make a test pass.

## Files and local material

Canonical files are the versioned inputs maintained in Git, while generated reports summarize those inputs; [Versioned data and generated inventory](requirements.md#versioned-data-and-generated-inventory) identifies which files to review and update.

- [Testing guide](testing.md): metadata, compilation, runner options and
  contribution rules. [Results](results.md): evidence interpretation and
  assembly. [Known differences](known-differences.md): all 470 spec-only cases.
- [Requirement guide](requirements.md), [scope](../coverage/scope.json),
  [ledger](../coverage/requirements.json), [assessments](../coverage/assessments.json) and [test index](../coverage/test_index.json):
  canonical M4 state. Generated inventories are review aids, not replacements
  for these versioned inputs.
- [Library lock](../third_party/uvm.lock): Accellera UVM 2020.3.1 at
  `78c06547a2a0`, 326 files. Fetch with the tracked tool; the library itself
  is not committed. 2702 fixtures use `UVM_NO_DPI`; thirty-eight explicitly request the original VPI HDL backend.
- The user supplied `IEEE_Std_1800.2-2020.pdf` and
  `IEEE_Std_1800-2023_SystemVerilog.pdf` in the repository root. They are
  ignored local files, unavailable in a fresh clone, and must not be
  redistributed. Extracted text under `out/` is local and ignored; `/tmp` contents may disappear.
- Results under `out/` are ignored and local. Temporary expansion helpers
  under `out/thin-one-hundred-*-*.py` are optional local aids,
  not maintained entry points. Some append drafts/history and must not be
  rerun blindly. Recreate missing helpers using the tracked tools.

For a first run, [the smoke command](faq.md#q3-how-can-i-run-one-test-first) uses a tracked fixture and the fetched library; the local PDFs support standards review and Ghost settings support guest measurements.

## Resume and verify

A nonempty working-tree status may include unfinished input changes, so review [the input and mapping update procedure](requirements.md#updating-a-test-or-mapping) before treating saved evidence as current.

The validation commands below check tools and maintained inputs; [the checks guide](testing.md#checks) distinguishes those checks from running simulator models.

Use Python 3.10 or later. Verilator measurements require exactly 5.052,
a C++ toolchain, make and the z3 solver on the path. Run from the repository root:

```sh
git status --short --branch
python3 tools/fetch_uvm.py
python3 -m unittest discover -s tools -p 'test_*.py'
python3 tools/lint_metadata.py
python3 tools/requirements.py check
python3 tools/known_causes.py check
python3 tools/requirements.py inventory --json out/requirements-inventory.json
python3 tools/requirements.py backlog --json out/requirements-backlog.json --lang ja
```

The snapshot passed 140 tool unit tests, metadata for all 2763 tests (2664 simulation, 99 elaboration),
ledger/index validation, the cause-record check, library integrity and current-input evidence checks.
A documentation-only change needs the paired-language and link checks described in [documentation maintenance](testing.md#documentation-maintenance), without rebuilding the entire suite.
Current full-suite evidence is available for Verilator only; guest records
cover 1081 unchanged inputs, with 1682 inputs unmeasured.
For a simulator smoke check:

```sh
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 1 \
  --json out/verilator-smoke.json tests/u09/test_common_phases_run_in_order.sv
```

An earlier [Check run](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/41561342697)
is retained as a reference. Use the README badge for the latest workflow
result; newer commits may supersede that run. Local checks are not proof
of a successful full CI run. Check runs tool,
metadata, ledger, library and cause-record checks and the tagged ordinary Verilator checks
whose inputs changed, plus a canary; Regression runs all tagged ordinary checks
and twenty command-line checks and twenty-six regex-DPI variants, manually and weekly. Neither runs Ghost,
kirimasim or spec-only cases. There is no automatic result publication.

## Evidence and latest differences

The smoke command above writes your own per-test record, and [Open the result JSON](reading-guide.md#open-the-result-json) shows how to inspect it before comparing it with this snapshot.

Chapter totals below give partial decomposition, explicit classification and unassessed identifiers in that order, using the states defined in [the root table](requirements.md#review-work-queue-and-root-totals).

A test can appear in both ordinary and backend measurements, so [the measurement scope](results.md#current-snapshot) explains which rows overlap before you compare their totals.

| Simulator / library | Recorded result |
| --- | --- |
| Verilator 5.052 / pinned UVM | 2199 runtime passes at seeds 1/73; 94 expected compile rejections; 463 known |
| Verilator 5.052 / original VPI HDL backend | Separate thirty-eight-case condition: thirty-seven pass at both seeds, one fails at seed 1 |
| Verilator 5.052 / command-line VPI and pinned regex DPI | Separate 23-case condition: 20 pass both seeds; 3 known at seed 1 |
| Verilator 5.052 / listed ordinary fixtures with regex and command-line DPI | Separate 26-case condition: 26 pass both seeds |
| kirimasim / pinned UVM | 1081 unchanged cases: 1072 unsupported and nine missing-API failures; 1682 inputs unmeasured |
| Ghost / bundled UVM | 1081 unchanged cases: 206 pass and 875 fail at each seed; 1682 inputs unmeasured |
| Ghost / pinned UVM | No measurement for the current executable snapshot |

The ordinary condition retains 463 known cases: 318 runtime first differences,
140 simulation builds and five illegal compiler acceptances. One legal printed-concrete callback-facade construction is rejected as abstract. Builds are 43 missing
API/type names, one time-decrement argument default, two type-default declarations, three dependent visitor-default builds, two printed signature conflicts,
two inherited type_id registry specializations, one protected-access build, two unlisted-pure-hook builds and 61 unlinked DPI cases. Two qualified virtual-abstraction overview-base builds and two printed dedicated-pool return-type builds also remain. Three additional legal builds retain the enum-collection T interpretation. Seven more builds retain strict attribute/enum-unpack arities. Separate HDL/command-line evidence is reported independently.

The remaining six simulation build failures are four unregistered-packet predictor type-name builds and two size/flag declaration builds; [the result breakdown](results.md#interpretation) records their conditions without adding a registration prerequisite to the standard.

The 124th expansion implements the seventh item, the bring-up stages of kirimasim. Every test
has a stage from 0 to 6 in `coverage/kirimasim_stages.json`, decided by markers in its own
sources, and each stage has a short set of tagged representatives that `tools/kirimasim_stages.py
short` prints for the kirimasim runner; Check runs `tools/kirimasim_stages.py check`. One new
stage-0 input, [`tests/u01/test_uvm_pkg_import_only_reaches_package_items.sv`](../tests/u01/test_uvm_pkg_import_only_reaches_package_items.sv), matches seeds 1/73 before and after tagging.
[The stage guide](kirimasim-stages.md) maps the SystemVerilog features of each stage to
kirimasim-tests; no kirimasim-tests simulation test calls a method through a handle whose type
is a type parameter, which the TLM imps of stage 5 need.

The 123rd expansion is the third and last batch of the sixth item. It classifies the other 264
runtime differences (u05, u12, u14 to u16, u18, u19, uB, uC, uE and uF), checking every differing
row of the saved seed-1 outputs, and the four inputs that still differ under their DPI condition,
whose whole outputs were saved by running them through their own runners. It adds 214 library, 41
interpretation and 13 simulator causes and six reproducers without UVM; the record is complete
with 319 library, 60 interpretation, 27 simulator, 57 condition and no unassigned entry, and the
kirimasim targets are 2384 measurable and 379 kept from the expectation by the pinned library. No
test, expectation, stored record or duty changes.

The 122nd expansion is the second batch of the sixth item. It classifies 54 runtime differences
(all of those in u01, u06 to u11, u13, uD and uG, and three each in uC and uE), using a seed-1
diagnostic run that saved the whole output of each under `out/`. Six are simulator
causes with three new reproducers without UVM: kill() leaves forked children running (four
phase-termination inputs), and two class-member event patterns lose a wakeup (one input each).
Thirty-nine are library causes and nine interpretations; the totals are 105 library, 19
interpretation, 14 simulator, 57 condition and 268 unassigned, and the kirimasim targets are 2370
measurable and 124 kept from the expectation by the pinned library. No test, expectation, record or
duty changes.

The 121st expansion implements the first batch of the external review's sixth item, after the
user approved the proposal and chose to record no library output values (A1). [The cause
record](../coverage/known_causes.json) gives each of the 463 known inputs one entry with its kind,
DPI condition, cause, evidence and explanation; `tools/known_causes.py` checks it against the tests
and their input fingerprints, summarizes the kirimasim targets and lists the candidates for human
review, and Check runs the check and rebuilds the three simulator reproducers. The 140 builds and
five accepted illegal designs are classified: 66 library, 10 interpretation, 8 simulator and 57
DPI-condition causes. The 318 runtime differences and four inputs that still differ under their DPI
condition remain unassigned, to be diagnosed directory by directory; see
[the causes](known-differences.md#causes-of-the-known-differences). No test, expectation, record or
duty changes.

The 124th expansion implements the external review's seventh item, the
bring-up stages of kirimasim. [`coverage/kirimasim_stages.json`](../coverage/kirimasim_stages.json)
gives every test a stage from 0 (uvm_pkg only) to 6 (register layer), decided
by markers of each part of UVM in the test's own sources, and a short set of
representatives for each stage; `tools/kirimasim_stages.py` checks it in Check
and prints the short sets for the kirimasim runner. The stages hold 1, 1030,
95, 111, 326, 250 and 950 tests, and every current kirimasim record stops at
the same unsupported `uvm_object_wrapper` construct in every stage;
[the stage guide](kirimasim-stages.md) explains the rules, the short sets and
the SystemVerilog features that each stage needs, with tests of kirimasim-tests.
No test header changes, so no input fingerprint changes.

One new stage-0 input in u01 imports uvm_pkg and names UVM_LOW through the
import and through the package name, without creating a UVM object or calling
run_test. It matches seeds 1/73 before and after tagging from the first freeze,
and one new duty covers it. The total is 4151 AI duties, with all 4150 old
objects and 445 assessments unchanged; 2707 tests have direct links, 158 have
controls and 56 are control-only. All 2755 old ordinary records and 463 old
known inputs remain unchanged. The new input counts as M1.

The suite has 2763 tests (2664 simulation/99 elaboration). Ordinary results
are 2293 matches: 2199 runtime inputs at both seeds and 94 compiler rejections.
Known inputs total 463: 318 runtime seed 1 differences, 140 simulation builds
and five accepted illegal designs without runtime; spec-only cases total 470
with the seven four-state inputs. The command-line condition keeps 23 fixtures
(20 pass, 3 known) and the regex-DPI variant condition 26 (all pass); neither
is added to the ordinary totals. No guest run/filter is added: 1081
compatible records remain byte-identical and 1682 inputs are unmeasured (1678
additions/four revised originals; 1583 simulation/99 elaboration).

Primary-focused identifiers are 1320; candidates are 1167 zero/764 below
target/551 at least two. All 2062 partial identifiers, actual remaining
conditions, original milestone targets, human review and scope/denominator
approval remain open; [the progress guide](reading-guide.md#read-coverage-and-progress)
explains why matching conditions do not supply completion.

Totals are 2763 (2664 simulation/99 elaboration): M1 1188 (1107/81), M2 633
(626/7), M3 942 (931/11). Ordinary pass is 2293 (2199 runtime/94 rejections),
with 463 known (318 runtime/140 builds/5 illegal acceptances). Guests retain
1081 compatible records; 1682 unmeasured inputs are 1678 additions and four revised originals.

The former single Check never finished its whole selection after 2026-10-31:
its one [run](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42121591333)
not superseded by a newer push reached the 150-minute limit on all eight
shards. Check now runs the changed tagged inputs and a canary, and
[Regression](../.github/workflows/regression.yml) runs all 2293 tagged checks in
20 disjoint shards with the 20 command-line checks and 26 regex-DPI variants; [the CI section](results.md#continuous-integration)
gives the limits. Seeds 1/73, compiler-rejection judgment, pinned dependencies
and runner fingerprints are unchanged. After a change that Check reports as
canary-only, dispatch Regression and check its result for the current commit;
local validation does not establish a successful hosted workflow result.
The first dispatch exposed a missing constraint solver on the hosted image;
[the CI section](results.md#continuous-integration) records the cancelled run and the fix.
After the fix, Regression run 42372122368 on db06513 matched every tagged and
command-line check.

The assembled Verilator snapshot retains unchanged prior inputs and replaces only
remeasured records. It is not one invocation rerunning the entire suite.
On the current host, the compatible local records are:

```text
out/thin-one-hundred-twenty-fourth-verilator-combined.json
out/thin-one-hundred-twelfth-ghost-final-1.json
out/thin-one-hundred-twelfth-ghost-final-73.json
out/thin-one-hundred-twelfth-kirimasim-final.json
out/thin-one-hundred-twenty-fourth-inventory.json
out/thin-one-hundred-twenty-fourth-backlog.json
out/thin-one-hundred-twenty-fourth-evidence-scope.json
out/thin-one-hundred-sixth-hdl-combined.json
out/thin-one-hundred-sixth-cmdline-final.json
```

Before reuse, verify test-ID sets within each declared full/subset scope, current `inputs_sha256`, identical
simulator version/configuration/library identity and `runner_sha256`, and
false `runner_changed`. Do not merge incompatible records. These ignored
files may be absent on another host; use the tracked runners to regenerate
measurements with authorized configuration. See [evidence assembly](results.md#evidence-assembly).

The earlier field-configuration filter reduced 1083 compatible records to 1082. The subsequent reraise primary-citation filter reduced 1082 to 1081; this increment retains those records without another filter or guest run, and [the input-identity explanation](faq.md#q408-does-the-citation-repair-improve-guest-results-or-prove-clause-coverage) and [evidence assembly](results.md#evidence-assembly) distinguish the two stages.

## Persistent goal and completion audit

The completion audit compares remaining duties and conditions with the original M1–M4 targets; [Q390](faq.md#q390-does-zero-unassessed-identifiers-mean-zero-remaining-work) explains why clearing the three generated queues is only one checkpoint.

Unassessed counts and partial obligations track different remaining work; [Read coverage and progress](reading-guide.md#read-coverage-and-progress) explains why a smaller counter does not by itself complete the goal.

The user requested a persistent goal to continue until M1–M4 have zero gaps.
At activation there were 1,463 unassessed identifiers, zero unlinked tests and
zero requirements without direct tests. 96 iterations retain zero unassessed, a decrease of 1463 since activation. The user resumed the paused goal on 2026-11-07. The 113th to 115th iterations split CI, fixed the missing z3 solver on hosted runners and added twelve M3 memory-manager inputs. On 2026-11-08 the user supplied an external review with eight items; the 116th to 118th iterations added RTL integration, four-state and randomization-property inputs, the 119th added a regex-DPI variant condition and five regular-expression fixtures, the 120th added five user-package inputs that match both seeds, the 121st to 123rd recorded the causes of the known differences in three batches without changing any duty, and the 124th adds the kirimasim bring-up stages and one stage-0 input that matches both seeds. One new duty produces 4151 duties, with all 4150 old objects identical. All 2755 old ordinary records, 463 old known inputs and 445 assessments remain. Guests retain 1081 compatible/1682 unmeasured. All 2062 partial contracts, applicability, original targets, human review and scope/denominator approval remain open; the goal is not complete.

The separate earlier 12.2.9.2 reassessment did not reduce unassessed. Do not mark
the goal complete before the final audit. Zero unassessed in chapter 12 does not complete its 169 partial
identifiers or explicit milestone targets. Final audit must check the original
scope, actual standard duties, meaningful conditions and compatible execution
evidence. Preserve qualified interpretations, known differences and unmeasured
guests; do not invent approval or mark them passed.

Maintain bilingual docs and publish validated increments to main. Native goal
state is conversation-owned; these notes are a handoff, not a replacement goal.

## Remaining work and suggested order

An empty mapping queue can coexist with partially decomposed obligations, so use [the inventory states](requirements.md#versioned-data-and-generated-inventory) to distinguish remaining review from missing test links.

These are prioritization suggestions, not approved exclusions or a coverage
percentage. Regenerate the backlog before choosing the next increment.

The mapping and unassessed queues are empty across all roots. Audit the
2062 partial identifiers against the standard, distinguishing headings from
normative obligations and splitting remaining applicability conditions before selecting new tests.
Prioritize meaningful defaults, failures, isolation, ordering and lifecycle
combinations in the partially decomposed areas. Review API omissions and
signature/prose conflicts before deriving an oracle.

Base-class follow-up: audit all 99 partial chapter-5 identifiers, including
the pure-method/default-body wording, complete virtual-declaration conditions,
initiator print/record, transaction event/record ordering, parent links,
recording defaults/error intervals and handle retention. Review all time units,
resolution/default arguments and field-operation reuse; preserve the four
missing active-policy builds and argument-default build. Audit older virtual
overrides for standard formal names before treating compiler acceptance as
language validity. Selected custom hook probes do not establish all automatic
macro/configuration behavior. Chapter 5 has no unassessed identifier, but its
contracts and original M1–M4 targets remain open.

Builtin-sequence follow-up: audit all 74 partial annex-E identifiers, including
physical reset hooks, actual selected-child algorithms, model/child lifecycle,
abortion and concurrent starts, skip/error combinations, all map/abstraction
shapes and the historical walking-ones interpretation. Preserve both default-name
differences, the accepted virtual dispatcher and literal protected-member names.
Original live-slot probes certify delegation only. No identifier remains
unassessed in E; no contract has thereby been marked complete.

Sequencer follow-up: audit all 67 partial chapter-15 identifiers, including
mid-burst relevance-limit changes with independently justified counter semantics,
per-sequencer state, push/peek/get automatic-recording conditions and arbitrary
pipeline cancellation. Preserve the positive-time bound interpretation and the
15.2.1 ancestry conflict. Annex B has no unassessed identifier; review B.4's unresolved callback-base
wording and all135partial identifiers while continuing all partial reporting, utility, field, I/O and TLM macro duties.

Resource follow-up: audit all 71 partial annex-C identifiers, including
the recent-set sorting interpretation, empty/duplicate/null queues, matching
dialects/backend variants, virtual regex/scope declarations and the missing
typed-DB maximum helper. Preserve first-maximum ties separately from recent-set
sort order, all precedence/lookup_type conflicts and existing missing-warning
and unlisted-pure-hook builds. Selected aliases, component get and interface
handles do not certify every type, automatic configuration or concurrent
history. C has no unassessed identifier; its contracts remain partial.

Package follow-up: use [the current root totals](requirements.md#review-work-queue-and-root-totals)
to audit annex F’s 112 partial identifiers, including type, global
service, callback mutation, initialization and run/abort duties.
Keep return-value and actual delivery evidence separate; preserve the isolated
PRE_RUN and report-default differences.

Dedicated-pool follow-up: keep printed pool-return and item-return prose
inputs separate. Explicitly seeded global bindings and bounded waits do not
settle absent-key static behavior or full concurrency/lifetime conditions.
Preserve the legacy field citation correction, parent-only stable duty and
separate width/LSB links. One combined expected row is one test, not three.
The changed metadata invalidates one guest record; never restore its old hash
under the current source or describe the 207-to-206 Ghost filter as a rerun.

Virtual-query follow-up: preserve the overview-versus-class base conflict,
the narrow constructor/getter width observation and unrelated-map ERROR duty.
Do not infer an invalid address return or queue order/append behavior. Audit
additional sole-map/default/hierarchical paths, array indices, region failure/
overlap/reuse, callback/lifetime and transfer conditions separately. Getters
and model-only field layouts do not certify actual storage accesses.

Traversal follow-up: retain the three STRUCTURE-only dependent-default inputs
and explicit-VISITOR controls separately, without assigning a cause from a
build diagnostic. Keep pure-method rejection oracles and never execute accepted
illegal designs. Audit additional tree/graph shapes, aliasing/cycles, null and
callback mutation conditions; default empty hooks and constructor profiles are
selected evidence. Review the printed non-virtual/pure-accept conflict rather
than treating F.5's zero unassessed identifiers as complete traversal coverage.

Recording/scalar-macro follow-up: retain the literal enum signature, strict
three-argument attributes and separately indexed controls. Audit collection
macros, further positive widths and nonconstant/zero/negative N conditions
against the standard before adding rejection expectations. Keep TR_HANDLE
interpretation and generic conversion distinct. Direct API control success
does not close small-integer macro delegation or remaining recording lifecycles.

Protection-callback follow-up: maintain distinct register/field and frontdoor/
backdoor rejection conditions, opposite-direction controls, peer/family isolation
and removal histories. Continue independent callback ordering, failure and
concurrency conditions and post-predict access-policy combinations. Passing
selected guards and zero unassessed in 18.11 do not complete these contracts.

Field-access follow-up: preserve register-before-field pre-hook expectations
and the 2 callback-driven map differences separately from explicit initial-map
controls. Keep the qualified whole-word best-effort RO condition separate from
selected-slice protection and passing poke controls. Continue partial access
policies, callback/error histories, map changes, prediction and side effects;
zero unassessed in 18.5 does not establish their completeness.

Field-macro follow-up: retain the literal collection-T and PACK-only differences
separately from their four passing controls. Continue event properties,
empty/null/alias/type-invalid combinations, independent one-way pack/unpack,
printing/recording/configuration and radix/recursion combinations. Selected
two-state copy/compare observations do not certify all macro operations.

Core-service follow-up: the listed-only complete subclass still requires the
pinned unlisted phase-hopper hook. Preserve that build difference and the
separate extra-hook control. The twenty-six isolated omissions now reject for
their selected method alone. Audit actual facility behavior, initial custom
service selection, enabled seed determinism and global ready-limit propagation;
do not substitute successful original override bodies for builtin algorithms.

Memory/special-register follow-up: chapter 18 has zero unassessed identifiers but retains 393 partial identifiers.
Subclauses 18.6–18.8 have none but remain partial. Audit the constructor-only FIFO
premise separately from its explicitly initialized control condition, direct
write/update behavior, abstract/public versus internal mirror interpretation,
backdoor exclusion, widths/capacities, failures and concurrent histories. Keep
the missing memory-rights warning and all earlier local-only lookup, coverage
return, public-read and map-default differences. Original driver queues are
testbench models; physical HDL evidence stays a separate condition. Continue
field and virtual-register declarations, adapter/predictor and callback duties.
No initialized control pass replaces a direct constructor/API obligation.

Chapter 8 has zero unassessed identifiers, but 60 remain partial. Audit every
builtin type_id category and explicit exception, all name/type/default/override
combinations, recursive-loop recovery, wildcard contexts, aliases, print state,
wrapper lifetime and the overview's qualified one-instance wording. Declaration
builds are legal simulations with no runtime, separately from negative compiler
rejections. Print review must include the framed runtime regex, not just UT
markers. Keep ERROR/null obligations distinct and retain their measured differences.

Chapter 9 has zero unassessed identifiers, but 94 remain partially decomposed.
Audit every class's inheritance/declaration conditions, all graph shapes,
active sync/unsync mutation and topology, invalid/unrelated/forward jumps,
complete callback transitions and task-thread cleanup. The eight-function and
thirteen-task matrices are two direct-delegate fixtures; they do not prove
all automatic scheduling behavior. Preserve the get_imp/get_schedule and
default-iteration prototype conflicts and the actual timeout heading F.7.3.3.

The earlier M4 negative-elaboration link gap is resolved by ledger schema 2.
Extend only with diagnostic links whose stage and exact declared regex are
bound to genuine illegal-elaboration metadata. Keep compile return codes and
matching errors as measurement evidence, separately from runtime seeds.
Remaining negative matrices include other virtual/pure-method declarations,
invalid derived classes/types and constructor visibility. The selected
direct-construction prohibitions do not close all abstract-type obligations.

Chapter 12 has no unassessed identifier. Audit its partial obligations before
claiming closure: printed blocking/nonblocking provider conflicts, same-kind
post-invalid-call bookkeeping, connect P signatures, the forward-port prose,
other abstract/invalid-derivation conditions, user-derivation constraints, exact member
ownership and full compatible/invalid topology and protocol histories remain.
Use qualified interpretation probes as review evidence, not proven bugs.

TLM candidates include broader channel/analysis applicability,
nonblocking/binding compatibility, TLM 2 protocol conditions, the independent
RSP default difference, zero-capacity is_full wording and summary aliases/imp
parameters. Keep declaration failures separate from missing APIs and unlinked
DPI; no runtime result exists for the REQ-only failed build.

Synchronization candidates include the pool get_global signature/prose
conflicts, callback_mode omitted-default conflict, invalid callback pair
conditions, delta-delay wait options and broader reset/cancel/concurrency
coverage. Existing tests avoid assuming initial pool size; preserve that
independence while keeping required initial membership as a separate spec-only
case. Correct mode-zero callback routing does not settle intermediate totals.

Chapter 6 now has zero unassessed identifiers but retains 98 partial clauses.
Print probes observe selected common/configuration content, not all categories,
default text or complete reporting behavior. Printer subclause 16.2 now partially decomposes 16.2.10 under a qualified short-row
reading; do not turn that observation into unprinted universal column/row grammar.
Chapter 16 has zero unassessed but 176 partial identifiers;
introduction 16 is individually classified as contextual and the recorder-link
overview remains partially decomposed. Audit default format semantics, recursion history keys,
depth boundaries, cyclic graphs, scope separators, four-state values, all radix
and configuration combinations and caller ownership. Preserve the qualified
entry-depth matrix and the independent already-above-limit mismatch separately.

Continue the policy-substitution audit beyond the selected A/B/A scalar inputs:
review nested objects, aliases, hooks disabled by field operations, additional
configuration combinations and repeated-recorder histories from the standard.
The chapter introduction links to those partial duties; its contextual assessment
does not certify all combinations.

Chapter 15 has zero unassessed identifiers and 67 partial ones. Selected
relevance bounds and real pull-port recording events now have direct checks;
the positive-time bound and interface-ancestry interpretation remain qualified.
Read class declarations together before deriving a new inheritance oracle.
Keep wait_for_sequences waiting behavior separate from immediate try. Further
conditions include default/invalid connector types, priorities, other recording
routes, phase/default interactions and complete protocol histories.

Chapters 7 and 13 have no unassessed identifiers. Audit their 50 and 89 partial
identifiers, including recording activity/handles, event pools, transaction
ordering, configuration, asynchronous domains and complete error conditions.
Error/event backend timestamps remain qualified; do not impose one token or
string encoding across applications. Keep the all_dropped function/task,
create_object equivalent-call arity and report_db/report_cb name conflicts open.
Annex D has no unassessed identifier but retains 39 partial identifiers.
Named wrappers still need missing-name/path/map and complete status/protocol
audits; do not infer undocumented null-target diagnostics from a library result.
Chapter 18 has zero unassessed identifiers but retains 393 partial identifiers. Subclauses 18.1–18.3 have none,
but partial map/register-file obligations remain. Clone availability/source
preservation now has direct observations; new-map contents/rights and the printed
scalar/map return conflict remain open. Do not invent a handle-return or
registration contract to hide them. Preserve the effective-width, qualified
word-unit, sole-map null-default and pre-lock field-name differences.
Continue register frontdoors/backdoors, coverage, field/memory declarations,
adapter/predictor callbacks and lifecycle/concurrent access conditions.

Useful next candidates include report reset/filter interactions, active
lock/grab ownership with relevance, sequence-library mode execution and
unbound applicability, independent one-way adapter lane/byte-order obligations
and adapter parent-sequence conditions. Missing catcher APIs and partial-byte
valid-bit reconstruction remain separate review work.
The parent_sequence clause names do_clone; review that wording before assuming
it means the object clone API. Keep unresolved obligations in the backlog.

Memory-manager follow-up retains allocation/locality enum and configuration
member meanings, human-readable state and region creation/ownership overview.
Do not infer GREEDY/THRIFTY or BROAD/NEARBY behavior from assignments alone.
Audit retained partial conditions, reconfiguration constraints and real backend
transfers. Keep the burst-write offset and burst-read output/ref discrepancies
separate from the selected delegation observations. Stale descriptors now have
direct release-error checks after a release of all regions, a region-facade
release, a release of a requested descriptor and a virtual-register release;
a manager release of a region that still implements a virtual-register array
and calls while the range is reserved again remain. Reconfigured bounds now
have direct reservation, request and policy-bound checks; changing mode or
locality with the bounds, other byte widths and incompatible reconfiguration remain.
RTL integration now has five direct profiles; other protocols, clock domains,
byte enables, error responses and the remaining review items remain.
Four-state paths now have seven spec-only profiles without Verilator records;
the unspecified paths are listed in the testing guide. Macro-driven
randomization now has five property profiles; distribution quality and
behavior after a failed randomization remain. Regular expressions now have a
regex-DPI variant condition and five command-line profiles; other DPI-dependent
behavior, such as HDL DPI with regular expressions, remains. User packages now
have five factory profiles; separate compilation units and libraries, and
package-level parameterized classes, remain.

Register-interaction candidates include callback resize/disable and operation
failure conditions, wider translation beats, independent one-way payload
checks, broader force/release types and timed-wrapper interactions. Task-based read boundary cases and
callback value pipelines now have selected fixtures; their existence does not
close broader applicability or the four retained propagation differences.
Review the printed write declaration conflict and pending-predictor check
contract before deriving a diagnostic severity expectation.

No current draft lacks a direct test. This closes the direct-link queue,
including a qualified historical interpretation for memory-walk; it does not
complete M1–M4. Review that interpretation and the remaining partial obligations,
then extend applicability, failures, lifecycle/concurrency and independent checks.
Chapter 11 method clauses remain partially decomposed, while its overview and
structural headings now have explicit AI assessments. Read other material
individually and preserve rationale; do not infer classification from heading names.
Broader HDL behavior, the E.7 interpretation, human review and denominator
approval remain open.

## Workflow for the next increment

A passing control helps evaluate a different premise but cannot replace a direct duty; see [Citations, requirements and execution evidence](requirements.md#citations-requirements-and-execution-evidence) when selecting the next fixture.

1. Read the cited local standard clauses and relevant fixtures. Write
   independent expected observations before measuring. Use public APIs and
   original testbench models; distinguish fixture algorithms from UVM behavior.
2. Finish names, formatting, metadata and lifetimes before starting runners.
   Initialize procedural locals with explicit lifetime where required.
   Use concrete subclasses for virtual bases. Obtain enum names from a typed
   enum value. Keep each display format a string literal.
3. Measure final inputs with Verilator 5.052 at seeds 1/73 and the authorized
   guest configurations. Keep long jobs in managed sessions and persist
   completed batches. Do not edit inputs while they are being measured.
4. Diagnose fixture errors separately from normative differences. Rerun
   only affected inputs after changes, including metadata/comment changes
   that affect fingerprints. Keep valid missing-API cases spec-only rather
   than substituting legacy fields for required standard APIs.
5. Add bilingual obligations and exact expected-output anchors to the ledger.
   Review a `sync` proposal when adding/changing indexed inputs; preserve
   unchanged records and unique requirement IDs. Several obligations may
   share an observation without becoming independent tests.
6. Validate ledger/index, current fingerprints and compatible evidence.
   Update current README/results/known differences, paired guides, FAQ and
   glossary where useful; put increment details in history.
7. Check both languages' headings, facts, literals, commands, tables, diagrams
   and local links. Check staged whitespace, commit the reviewed scope and
   verify the remote/CI state when pushing is authorized. Do not publish
   local standards or private simulator configuration/diagnostics.

Measurement inputs include headers, expectations and collected helpers, so use [the fingerprint checklist](results.md#evidence-assembly) to decide which records need refreshing after a change.

A `--root` value selects a standard chapter or annex, rather than an M1–M4 stage or test directory, and [the backlog guide](requirements.md#review-work-queue-and-root-totals) explains why the whole ledger is still validated before that filtered view is produced.

Useful backlog and index-proposal commands:

```sh
python3 tools/requirements.py backlog --root 14 --lang ja \
  --json out/requirements-backlog-14.json
python3 tools/requirements.py backlog --root 18 --lang ja \
  --json out/requirements-backlog-18.json
python3 tools/requirements.py backlog --root 12 --lang ja \
  --json out/requirements-backlog-12.json
python3 tools/requirements.py sync --output out/test-index-proposal.json
```

The `sync` command above writes an index proposal for mapping review; [the update procedure](requirements.md#updating-a-test-or-mapping) explains how to adopt it after checking affected links.

## Suggested restart message

The template below conveys the recorded baseline, so include any unfinished working-tree changes with it; [the resume checks](#resume-and-verify) show how to inspect the local state first.

> Read README and the bilingual handoff, verify the working tree and latest
> Check status, and regenerate the requirement backlog. Continue strengthening
> thin areas across M1–M4 using the supplied IEEE standards. Consider the
> unassessed normative obligations and review of the memory-walk interpretation,
> while adding meaningful new behaviors in M1–M3. Preserve standard-derived expectations, the commercial-result
> exclusion, Ghost privacy, AI review status and complete bilingual docs.
> Measure final inputs, retain valid spec-only differences and report the
> completed changes, validation and remaining limitations.
