# Development handoff

[日本語](handoff.ja.md) · [README](../README.md) · [Requirements](requirements.md)

## Snapshot and objective

Updated on 2026-11-05 for the sixty-third thin-area expansion, based on
[b95b8a8](https://github.com/kurochan001/kirimasim-uvm-tests/commit/b95b8a891128bdcf2c7639a820d1edd428873b2c)
on `main`. Verify the current publishing commit and working tree before resuming.

The project tests IEEE 1800.2-2020 UVM conformance, targeting kirimasim.
SystemVerilog language-only reproducers belong in
[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests).
Continue strengthening thin areas across M1–M4. M4 remains in progress;
zero unlinked tests does not complete any milestone.

| Area | Current snapshot |
| --- | --- |
| M1 | 766 tests (719 runtime, 47 elaboration): core objects, policies, reporting, hierarchy, factory, phases, synchronization, recording and utilities |
| M2 | 547 tests (542 runtime, 5 elaboration): sequences, sequencers, callbacks and TLM |
| M3 | 582 tests (574 runtime, 8 elaboration): register/memory layer and annex E |
| Entire suite | 1895 tests (1835 simulation, 60 elaboration) in 21 chapter/annex directories; all AI-reviewed, none human-reviewed |
| M4 | 3307 AI requirement drafts; 3307 have direct links to 1882 tests; thirteen control-only tests; zero tests without links |
| Normative inventory | 1819 of 2,507 identifiers partially decomposed; 388 explicitly assessed; 300 unassessed; zero drafts without direct tests |

`scope_status` remains proposed, `normative_inventory_complete` is false,
and `approved_denominator` / `coverage_percentage` remain null. All twenty-one
roots with primary-focus tests have zero unlinked tests. Their normative
decomposition and human review remain incomplete.

## Policies to preserve

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

- [Testing guide](testing.md): metadata, compilation, runner options and
  contribution rules. [Results](results.md): evidence interpretation and
  assembly. [Known differences](known-differences.md): all 274 spec-only cases.
- [Requirement guide](requirements.md), [scope](../coverage/scope.json),
  [ledger](../coverage/requirements.json), [assessments](../coverage/assessments.json) and [test index](../coverage/test_index.json):
  canonical M4 state. Generated inventories are review aids, not replacements
  for these versioned inputs.
- [Library lock](../third_party/uvm.lock): Accellera UVM 2020.3.1 at
  `78c06547a2a0`, 326 files. Fetch with the tracked tool; the library itself
  is not committed. 1866 fixtures use `UVM_NO_DPI`; eleven explicitly request the original VPI HDL backend.
- The user supplied `IEEE_Std_1800.2-2020.pdf` and
  `IEEE_Std_1800-2023_SystemVerilog.pdf` in the repository root. They are
  ignored local files, unavailable in a fresh clone, and must not be
  redistributed. Extracted text under `out/` is local and ignored; `/tmp` contents may disappear.
- Results under `out/` are ignored and local. Temporary expansion helpers
  under `out/thin-sixty-third-scratch-*.py` are optional local aids,
  not maintained entry points. Some append drafts/history and must not be
  rerun blindly. Recreate missing helpers using the tracked tools.

## Resume and verify

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

The snapshot passed 110 tool unit tests, metadata for all 1895 tests (1835 simulation, 60 elaboration),
ledger/index validation, library integrity and current-input evidence checks.
A documentation-only change does not require rebuilding the entire suite.
Current full-suite evidence is available for Verilator only; guest records
cover 1083 unchanged inputs, with 812 inputs unmeasured.
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

| Simulator / library | Recorded result |
| --- | --- |
| Verilator 5.052 / pinned UVM | 1564 runtime passes at seeds 1/73; 57 expected compile rejections; 274 known |
| Verilator 5.052 / original VPI HDL backend | Separate eleven-case condition: ten pass at both seeds, one fails at seed 1 |
| Verilator 5.052 / command-line VPI and pinned regex DPI | Separate 18-case condition: 17 pass both seeds; 1 known at seed 1 |
| kirimasim / pinned UVM | 1083 unchanged cases: 1074 unsupported and nine missing-API failures; 812 inputs unmeasured |
| Ghost / bundled UVM | 1083 unchanged cases: 207 pass and 876 fail at each seed; 812 inputs unmeasured |
| Ghost / pinned UVM | No measurement for the current executable snapshot |

The ordinary condition retains 274 known cases: 206 runtime first differences,
65 simulation builds and three illegal compiler acceptances. Builds are 27 missing
API/type names, one time-decrement argument default, two type-default declarations, two printed signature conflicts,
two inherited type_id registry specializations, one protected-access build, one unlisted-pure-hook build and 29 unlinked DPI cases. Separate HDL/command-line evidence is reported independently.

Thirty-seven M3 inputs add nineteen two-seed runtime matches and eighteen
seed-1 runtime differences without seed 73. Twenty-five use the listed APIs,
including an independent ordinary-register bus control; twelve additional
control-only inputs explicitly initialize the pinned FIFO with its unlisted
build method. They have separately indexed fingerprints and expected observations.
Seven initialized controls match; five retain differences. No control result
passes the constructor/configure-only premise of a direct requirement.

Memory address defaults select the sole member or shared parent-default map.
Unrelated-map address/offset/address-array warnings match, including minus-one
and unchanged caller-array duties. The rights query returns RW but generates
no required warning. Original delayed backdoor reads see external adjacent-word
changes. Memory/indirect/FIFO builtin factory exceptions retain legal registered
extension controls; indirect omitted/explicit constructors and register-base
write/read routing match.

Twelve constructor/configure-only FIFO inputs stop on a null internal field
before completing set/predict, transfer/update or compare/mirror observations.
After expectations were fixed, diagnosis in the pinned Apache-2.0 UVM identified
its unlisted build initializer. This is an explicit premise/interpretation
boundary, not an invented IEEE prerequisite or proof of independent library bugs.
The separately initialized controls reach the selected algorithms: set/full,
write/read prediction, the four comparison gates and omitted compare default
match. Direct write is rejected with Needs Update despite no external FIFO set;
external observation then duplicates abstract state without a bus write. Update
duplicates the two preloads into four entries/transfers; repeated update also
retains four entries. A checked matching public FIFO/DUT pair pops both queues
but reports an internal zero-mirror mismatch. The public-queue expectation is
qualified and remains open for review.

The final write control returns after its rejected write, avoiding a cascading
empty-original-DUT read. Its standard-derived expectation remains unchanged.
Two isolated declared helper directories preserve the original 1858 input
identities. Source/metadata preflight corrections are fixture work, not UVM
differences. All other earlier ordinary/compiler/guest/backend records remain
unchanged; no guest rerun or completion is claimed.

Totals are 1895 (1835 simulation/60 elaboration): M1 766 (719/47), M2 547
(542/5), M3 582 (574/8). Ordinary pass is 1621 (1564 runtime/57 rejections);
known is 274 (206 runtime/65 builds/three illegal acceptances). All 1858 prior
ordinary inputs/records, 3262 duties, 387 assessments and 60 compiler records
remain unchanged. All 110 tool tests, metadata/ledger/library, current evidence
and paired docs pass. Guest/HDL/command-line records are unchanged; 812 guest
inputs remain unmeasured. No human approval or goal completion is claimed.

The assembled Verilator snapshot retains unchanged prior inputs and replaces only
remeasured records. It is not one invocation rerunning the entire suite.
On the current host, the compatible local records are:

```text
out/thin-sixty-third-verilator-combined.json
out/thin-sixty-third-ghost-final-1.json
out/thin-sixty-third-ghost-final-73.json
out/thin-sixty-third-kirimasim-final.json
out/thin-sixty-third-inventory.json
out/thin-sixty-third-backlog-final.json
out/thin-sixty-third-evidence-scope.json
out/thin-sixty-third-hdl-combined.json
out/thin-sixty-third-cmdline-final.json
```

Before reuse, verify test-ID sets within each declared full/subset scope, current `inputs_sha256`, identical
simulator version/configuration/library identity and `runner_sha256`, and
false `runner_changed`. Do not merge incompatible records. These ignored
files may be absent on another host; use the tracked runners to regenerate
measurements with authorized configuration. See [evidence assembly](results.md#evidence-assembly).

## Persistent goal and completion audit

The user requested a persistent goal to continue until M1–M4 have zero gaps.
At activation there were 1,463 unassessed identifiers, zero unlinked tests and
zero requirements without direct tests. Thirty-five iterations reduce unassessed
to 300, a decrease of 1163. The latest memory/indirect/FIFO increment individually
decomposes or assesses fifteen identifiers. Chapter 18 retains 101 unassessed
and 312 partial identifiers; zero unassessed in 18.6–18.8 does not complete
their remaining conditions or any original milestone target.

The separate earlier 12.2.9.2 reassessment did not reduce unassessed. Keep the
goal active. Zero unassessed in chapter 12 does not complete its 169 partial
identifiers or explicit milestone targets. Final audit must check the original
scope, actual standard duties, meaningful conditions and compatible execution
evidence. Preserve qualified interpretations, known differences and unmeasured
guests; do not invent approval or mark them passed.

Maintain bilingual docs and publish validated increments to main. Native goal
state is conversation-owned; these notes are a handoff, not a replacement goal.

## Remaining work and suggested order

These are prioritization suggestions, not approved exclusions or a coverage
percentage. Regenerate the backlog before choosing the next increment.

The existing-test mapping queue is empty across all roots. Review the 300
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
15.2.1 ancestry conflict. Annex B still has 100 unassessed identifiers; read
report/object/field/pack macros individually, retaining static-library differences.

Resource follow-up: audit all 71 partial annex-C identifiers, including
the recent-set sorting interpretation, empty/duplicate/null queues, matching
dialects/backend variants, virtual regex/scope declarations and the missing
typed-DB maximum helper. Preserve first-maximum ties separately from recent-set
sort order, all precedence/lookup_type conflicts and existing missing-warning
and unlisted-pure-hook builds. Selected aliases, component get and interface
handles do not certify every type, automatic configuration or concurrent
history. C has no unassessed identifier; its contracts remain partial.

Package follow-up: audit annex F’s 63 unassessed identifiers and all partial
type, global service, callback mutation, initialization and run/abort duties.
Keep return-value and actual delivery evidence separate; preserve the isolated
PRE_RUN and report-default differences.

Memory/special-register follow-up: chapter 18 retains 101 unassessed identifiers.
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
grammar merely to close it. Chapter 16 retains three unassessed identifiers: the chapter introduction,
table-format overview and transaction-recorder lifecycle/link overview. Audit default format semantics, recursion history keys,
depth boundaries, cyclic graphs, scope separators, four-state values, all radix
and configuration combinations and caller ownership. Preserve the qualified
entry-depth matrix and the independent already-above-limit mismatch separately.

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
Chapter 18 retains 101 unassessed identifiers. Subclauses 18.1–18.3 have none,
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
checks and real force/release support. Task-based read boundary cases and
callback value pipelines now have selected fixtures; their existence does not
close broader applicability or the four retained propagation differences.
Review the printed write declaration conflict and pending-predictor check
contract before deriving a diagnostic severity expectation.

No current draft lacks a direct test. This closes the direct-link queue,
including a qualified historical interpretation for memory-walk; it does not
complete M1–M4. Review that interpretation and the remaining 300 identifiers,
then extend applicability, failures, lifecycle/concurrency and independent checks.
Chapter 11 method clauses remain partially decomposed, while its overview and
structural headings now have explicit AI assessments. Read other material
individually and preserve rationale; do not infer classification from heading names.
Broader HDL behavior, the E.7 interpretation, human review and denominator
approval remain open.

## Workflow for the next increment

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

## Suggested restart message

> Read README and the bilingual handoff, verify the working tree and latest
> Check status, and regenerate the requirement backlog. Continue strengthening
> thin areas across M1–M4 using the supplied IEEE standards. Consider the
> unassessed normative obligations and review of the memory-walk interpretation,
> while adding meaningful new behaviors in M1–M3. Preserve standard-derived expectations, the commercial-result
> exclusion, Ghost privacy, AI review status and complete bilingual docs.
> Measure final inputs, retain valid spec-only differences and report the
> completed changes, validation and remaining limitations.
