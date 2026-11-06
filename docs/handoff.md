# Development handoff

[日本語](handoff.ja.md) · [README](../README.md) · [Requirements](requirements.md)

This page supports resuming development; if you want to run or understand a first test, start with [the reading guide](reading-guide.md).

## Snapshot and objective

Updated on 2026-11-07 for the eighty-ninth thin-area expansion, based on
[79c6f77](https://github.com/kurochan001/kirimasim-uvm-tests/commit/79c6f77be3581580c3228ce19443e241aa296390)
on `main`. Verify the current publishing commit and working tree before resuming.

The project tests IEEE 1800.2-2020 UVM conformance, targeting kirimasim.
SystemVerilog language-only reproducers belong in
[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests).
Continue strengthening thin areas across M1–M4. M4 remains in progress;
zero unlinked tests does not complete any milestone.

| Area | Current snapshot |
| --- | --- |
| M1 | 1034 tests (953 runtime, 81 elaboration): core objects, policies, reporting, hierarchy, factory, phases, synchronization, recording and utilities |
| M2 | 568 tests (561 runtime, 7 elaboration): sequences, sequencers, callbacks and TLM |
| M3 | 868 tests (857 runtime, 11 elaboration): register/memory layer and annex E |
| Entire suite | 2470 tests (2371 simulation, 99 elaboration) in 21 chapter/annex directories; all AI-reviewed, none human-reviewed |
| M4 | 3973 AI requirement drafts; 3973 have direct links to 2426 tests; forty-four control-only tests; zero tests without links |
| Normative inventory | 2025 of 2,507 identifiers partially decomposed; 420 explicitly assessed; 62 unassessed; zero drafts without direct tests |

`scope_status` remains proposed, `normative_inventory_complete` is false,
and `approved_denominator` / `coverage_percentage` remain null. All twenty-one
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
  assembly. [Known differences](known-differences.md): all 395 spec-only cases.
- [Requirement guide](requirements.md), [scope](../coverage/scope.json),
  [ledger](../coverage/requirements.json), [assessments](../coverage/assessments.json) and [test index](../coverage/test_index.json):
  canonical M4 state. Generated inventories are review aids, not replacements
  for these versioned inputs.
- [Library lock](../third_party/uvm.lock): Accellera UVM 2020.3.1 at
  `78c06547a2a0`, 326 files. Fetch with the tracked tool; the library itself
  is not committed. 2414 fixtures use `UVM_NO_DPI`; thirty-eight explicitly request the original VPI HDL backend.
- The user supplied `IEEE_Std_1800.2-2020.pdf` and
  `IEEE_Std_1800-2023_SystemVerilog.pdf` in the repository root. They are
  ignored local files, unavailable in a fresh clone, and must not be
  redistributed. Extracted text under `out/` is local and ignored; `/tmp` contents may disappear.
- Results under `out/` are ignored and local. Temporary expansion helpers
  under `out/thin-eighty-ninth-*.py` are optional local aids,
  not maintained entry points. Some append drafts/history and must not be
  rerun blindly. Recreate missing helpers using the tracked tools.

For a first run, [the smoke command](faq.md#q3-how-can-i-run-one-test-first) uses a tracked fixture and the fetched library; the local PDFs support standards review and Ghost settings support guest measurements.

## Resume and verify

A nonempty working-tree status may include unfinished input changes, so review [the input and mapping update procedure](requirements.md#updating-a-test-or-mapping) before treating saved evidence as current.

The validation commands below check tools and maintained inputs; [the checks guide](testing.md#checks) distinguishes those checks from running simulator models.

Use Python 3.10 or later. Verilator measurements require exactly 5.052,
a C++ toolchain and make. Run from the repository root:

```sh
git status --short --branch
python3 tools/fetch_uvm.py
python3 -m unittest discover -s tools -p 'test_*.py'
python3 tools/lint_metadata.py
python3 tools/requirements.py check
python3 tools/requirements.py inventory --json out/requirements-inventory.json
python3 tools/requirements.py backlog --json out/requirements-backlog.json --lang ja
```

The snapshot passed 110 tool unit tests, metadata for all 2470 tests (2371 simulation, 99 elaboration),
ledger/index validation, library integrity and current-input evidence checks.
A documentation-only change needs the paired-language and link checks described in [documentation maintenance](testing.md#documentation-maintenance), without rebuilding the entire suite.
Current full-suite evidence is available for Verilator only; guest records
cover 1082 unchanged inputs, with 1388 inputs unmeasured.
For a simulator smoke check:

```sh
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 1 \
  --json out/verilator-smoke.json tests/u09/test_common_phases_run_in_order.sv
```

An earlier [Check run](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/41561342697)
is retained as a reference. Use the README badge for the latest workflow
result; newer commits may supersede that run. Local checks are not proof
of a successful full CI run. Check runs tool,
metadata, ledger, library, tagged ordinary Verilator and seventeen command-line
checks, not Ghost, kirimasim
or spec-only cases. There is no Nightly workflow or automatic result
publication.

## Evidence and latest differences

Chapter totals below give partial decomposition, explicit classification and unassessed identifiers in that order, using the states defined in [the root table](requirements.md#review-work-queue-and-root-totals).

A test can appear in both ordinary and backend measurements, so [the measurement scope](results.md#current-snapshot) explains which rows overlap before you compare their totals.

| Simulator / library | Recorded result |
| --- | --- |
| Verilator 5.052 / pinned UVM | 1981 runtime passes at seeds 1/73; 94 expected compile rejections; 395 known |
| Verilator 5.052 / original VPI HDL backend | Separate thirty-eight-case condition: thirty-seven pass at both seeds, one fails at seed 1 |
| Verilator 5.052 / command-line VPI and pinned regex DPI | Separate 18-case condition: 17 pass both seeds; 1 known at seed 1 |
| kirimasim / pinned UVM | 1082 unchanged cases: 1073 unsupported and nine missing-API failures; 1388 inputs unmeasured |
| Ghost / bundled UVM | 1082 unchanged cases: 206 pass and 876 fail at each seed; 1388 inputs unmeasured |
| Ghost / pinned UVM | No measurement for the current executable snapshot |

The ordinary condition retains 395 known cases: 265 runtime first differences,
125 simulation builds and five illegal compiler acceptances. One legal printed-concrete callback-facade construction is rejected as abstract. Builds are 35 missing
API/type names, one time-decrement argument default, two type-default declarations, three dependent visitor-default builds, two printed signature conflicts,
two inherited type_id registry specializations, one protected-access build, two unlisted-pure-hook builds and 56 unlinked DPI cases. Two qualified virtual-abstraction overview-base builds and two printed dedicated-pool return-type builds also remain. Three additional legal builds retain the enum-collection T interpretation. Seven more builds retain strict attribute/enum-unpack arities. Separate HDL/command-line evidence is reported independently.

The remaining six simulation build failures are four unregistered-packet predictor type-name builds and two size/flag declaration builds; [the result breakdown](results.md#interpretation) records their conditions without adding a registration prerequisite to the standard.

Fourteen new runtime inputs add two M1 callback-order cases and twelve M3
manager/configuration cases. Nine match seeds 1/73. Five retain seed-1 exit-0
preference differences without seed 73: GREEDY with high released history,
THRIFTY with low/high history, and NEARBY with one/two live regions.
Bounds, width, disjointness, held endpoints/membership and cleanup observations
match in those differing inputs; another condition's pass does not pass them.
[The enum/allocation FAQ](faq.md#enum-effects-and-allocation-preferences) explains the distinct premises.

Actual enabled callback dispatch observes five alternating typed append/prepend
insertions from either first mode and an independent empty peer. The unchanged
typed/default agent tests already cite F.2.1.7 and retain compatible measured
records; adding their new requirement link is neither new execution nor a new
primary-focus count. No numeric enum encoding or full agent behavior is inferred.

Manager configuration cycles observe typed modes/locality, previous/current
handles, an independent peer and an existing region. Separate random-field
inputs initialize the selected field to its opposite value, then constrain
object randomization to change it. Readback alone does not prove randomness or
allocation preference. The historical fresh/reuse reading is qualified; each
trial is one observed request, not a statistical guarantee. NEARBY permits either
side/any eligible neighbor; BROAD checks selected explicit nonadjacent policies,
not unconstrained sampling distribution.

Before final selection, only the MAM helper gained pre-request held-endpoint
snapshots. All twelve initial source-file bodies and expected files, plus two
later random-field bodies/expectations, remain unchanged apart from measured
tags. Earlier MAM input/log versions are archived and excluded; every changed
input is freshly measured without relabeling fingerprints. Thirteen bilingual
AI duties partially decompose six enum/configuration leaves, with no new
classification. All 3960 earlier duties, 420 assessments and proposed scope
retain their objects. Global state is 2025 partial/420 assessed/62 unassessed.
Annex F is 102/23/12 with 233 duties and 151 primary tests (117 simulation/34
elaboration); chapter 18 is 389/62/5 with 913 duties and 598 primary tests (595/3).
All 3973 duties directly link 2426 tests; forty-four others are control-only and
136 have control links.

All 2456 prior ordinary, 99 compiler, 38 HDL, 18 command-line and 1082 compatible
guest records retain their content. Nine proof-based tags have fresh final
measurements. Guest unmeasured inputs are 1388: 1385 additions and three revised
originals (1289 simulation/99 elaboration). There is no guest rerun/filter,
runner/backend/tool/workflow change, implementation-derived oracle, commercial
result, human review or scope/denominator approval. All partial applicability,
qualified histories/locality readings and original milestone targets remain open.

Totals are 2470 (2371 simulation/99 elaboration): M1 1034 (953/81), M2 568
(561/7), M3 868 (857/11). Ordinary pass is 2075 (1981 runtime/94 rejections),
with 395 known (265 runtime/125 builds/5 illegal acceptances). Guests retain
1082 compatible records; 1388 unmeasured inputs are 1385 additions and three revised originals.

The previous unsharded [Check run](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/41976785278)
exceeded the configured 150-minute job limit. The current workflow partitions
the current 2075 tagged checks into 8 disjoint shards (260/260/260/259/259/259/259/259),
with at most 4 concurrent shard jobs. The exact union and absence of duplicates are
verified locally. The 17 command-line checks run once, on shard 0 before
ordinary checks. Seeds 1/73, compiler-rejection judgment, pinned dependencies
and runner fingerprints are unchanged. The existing verilator gate requires
all shards to succeed. Sharding is orchestration; local
validation does not establish a successful hosted workflow result.

The assembled Verilator snapshot retains unchanged prior inputs and replaces only
remeasured records. It is not one invocation rerunning the entire suite.
On the current host, the compatible local records are:

```text
out/thin-eighty-ninth-verilator-combined.json
out/thin-eighty-ninth-ghost-final-1.json
out/thin-eighty-ninth-ghost-final-73.json
out/thin-eighty-ninth-kirimasim-final.json
out/thin-eighty-ninth-inventory.json
out/thin-eighty-ninth-backlog-final.json
out/thin-eighty-ninth-evidence-scope.json
out/thin-eighty-ninth-hdl-combined.json
out/thin-eighty-ninth-cmdline-final.json
```

Before reuse, verify test-ID sets within each declared full/subset scope, current `inputs_sha256`, identical
simulator version/configuration/library identity and `runner_sha256`, and
false `runner_changed`. Do not merge incompatible records. These ignored
files may be absent on another host; use the tracked runners to regenerate
measurements with authorized configuration. See [evidence assembly](results.md#evidence-assembly).

The latest guest filter excludes the corrected field-configuration citation input: 1083 prior compatible records become 1082, with no new guest execution. [The evidence guide](results.md#evidence-assembly) records the exact exclusion and resulting counts.

## Persistent goal and completion audit

Unassessed counts and partial obligations track different remaining work; [Read coverage and progress](reading-guide.md#read-coverage-and-progress) explains why a smaller counter does not by itself complete the goal.

The user requested a persistent goal to continue until M1–M4 have zero gaps.
At activation there were 1,463 unassessed identifiers, zero unlinked tests and
zero requirements without direct tests. 61 iterations reduce unassessed to 62, a decrease of 1401 since activation.
Six enum/configuration leaves gain partial duties; no new classification is
added. Two unchanged agent sources gain new links without new execution or
primary-focus counts. Nine new runtime inputs match both seeds; five retain
only-preference differences at seed 1. The strengthened MAM helper compares
held endpoints before/after requests; initial records are not relabeled.
Annex F is 102/23/12 and chapter 18 is 389/62/5. Full history/locality/randomization
applicability, all partial duties and original targets remain open.

Chapter 16 still retains 16.2.10; existing known differences are unchanged.
No original milestone is complete.

The separate earlier 12.2.9.2 reassessment did not reduce unassessed. Keep the
goal active. Zero unassessed in chapter 12 does not complete its 169 partial
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

The existing-test mapping queue is empty across all roots. Review the 62
unassessed identifiers against the standard, distinguishing headings from
normative obligations and splitting conditions before selecting new tests.
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
15.2.1 ancestry conflict. Annex B still has 19 unassessed identifiers; read
report/object/field/pack macros individually, retaining static-library differences.

Resource follow-up: audit all 71 partial annex-C identifiers, including
the recent-set sorting interpretation, empty/duplicate/null queues, matching
dialects/backend variants, virtual regex/scope declarations and the missing
typed-DB maximum helper. Preserve first-maximum ties separately from recent-set
sort order, all precedence/lookup_type conflicts and existing missing-warning
and unlisted-pure-hook builds. Selected aliases, component get and interface
handles do not certify every type, automatic configuration or concurrent
history. C has no unassessed identifier; its contracts remain partial.

Package follow-up: use [the current root totals](requirements.md#review-work-queue-and-root-totals)
to audit annex F’s remaining unassessed identifiers and all partial type, global
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

Memory/special-register follow-up: chapter 18 retains 5 unassessed identifiers.
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
default text or complete reporting behavior. Printer subclause 16.2 retains the
unassessed 16.2.10 tabular-format overview; do not impose unprinted column/row
grammar merely to close it. Chapter 16 retains one unassessed identifier, the table-format overview;
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
Chapter 18 retains 9 unassessed identifiers. Subclauses 18.1–18.3 have none,
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
separate from the selected delegation observations.

Register-interaction candidates include callback resize/disable and operation
failure conditions, wider translation beats, independent one-way payload
checks, broader force/release types and timed-wrapper interactions. Task-based read boundary cases and
callback value pipelines now have selected fixtures; their existence does not
close broader applicability or the four retained propagation differences.
Review the printed write declaration conflict and pending-predictor check
contract before deriving a diagnostic severity expectation.

No current draft lacks a direct test. This closes the direct-link queue,
including a qualified historical interpretation for memory-walk; it does not
complete M1–M4. Review that interpretation and the remaining 99 identifiers,
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

The message below summarizes the work to resume, and [Resume and verify](#resume-and-verify) gives the commands for establishing the current state before using its priorities.

> Read README and the bilingual handoff, verify the working tree and latest
> Check status, and regenerate the requirement backlog. Continue strengthening
> thin areas across M1–M4 using the supplied IEEE standards. Consider the
> unassessed normative obligations and review of the memory-walk interpretation,
> while adding meaningful new behaviors in M1–M3. Preserve standard-derived expectations, the commercial-result
> exclusion, Ghost privacy, AI review status and complete bilingual docs.
> Measure final inputs, retain valid spec-only differences and report the
> completed changes, validation and remaining limitations.
