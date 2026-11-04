# Development handoff

[日本語](handoff.ja.md) · [README](../README.md) · [Requirements](requirements.md)

## Snapshot and objective

Updated on 2026-11-05 for the fifty-ninth thin-area expansion, based on
[66c6075](https://github.com/kurochan001/kirimasim-uvm-tests/commit/66c6075b396f7b2ae0ba39a87e1be15f3d00e25c)
on `main`. Verify the current publishing commit and working tree before resuming.

The project tests IEEE 1800.2-2020 UVM conformance, targeting kirimasim.
SystemVerilog language-only reproducers belong in
[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests).
Continue strengthening thin areas across M1–M4. M4 remains in progress;
zero unlinked tests does not complete any milestone.

| Area | Current snapshot |
| --- | --- |
| M1 | 709 tests (667 runtime, 42 elaboration): core objects, policies, reporting, hierarchy, factory, phases, synchronization, recording and utilities |
| M2 | 547 tests (542 runtime, 5 elaboration): sequences, sequencers, callbacks and TLM |
| M3 | 516 tests (511 runtime, 5 elaboration): register/memory layer and annex E |
| Entire suite | 1772 tests (1720 simulation, 52 elaboration) in 21 chapter/annex directories; all AI-reviewed, none human-reviewed |
| M4 | 3110 AI requirement drafts; 3110 have direct links to 1771 tests; one additional control test; zero tests without links |
| Normative inventory | 1690 of 2,507 identifiers partially decomposed; 357 explicitly assessed; 460 unassessed; zero drafts without direct tests |

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
  assembly. [Known differences](known-differences.md): all 230 spec-only cases.
- [Requirement guide](requirements.md), [scope](../coverage/scope.json),
  [ledger](../coverage/requirements.json), [assessments](../coverage/assessments.json) and [test index](../coverage/test_index.json):
  canonical M4 state. Generated inventories are review aids, not replacements
  for these versioned inputs.
- [Library lock](../third_party/uvm.lock): Accellera UVM 2020.3.1 at
  `78c06547a2a0`, 326 files. Fetch with the tracked tool; the library itself
  is not committed. 1743 fixtures use `UVM_NO_DPI`; eleven explicitly request the original VPI HDL backend.
- The user supplied `IEEE_Std_1800.2-2020.pdf` and
  `IEEE_Std_1800-2023_SystemVerilog.pdf` in the repository root. They are
  ignored local files, unavailable in a fresh clone, and must not be
  redistributed. Extracted text under `out/` is local and ignored; `/tmp` contents may disappear.
- Results under `out/` are ignored and local. Temporary expansion helpers
  under `out/thin-fifty-ninth-scratch-*.py` are optional local aids,
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

The snapshot passed 110 tool unit tests, metadata for all 1772 tests (1720 simulation, 52 elaboration),
ledger/index validation, library integrity and current-input evidence checks.
A documentation-only change does not require rebuilding the entire suite.
Current full-suite evidence is available for Verilator only; guest records
cover 1083 unchanged inputs, with 689 inputs unmeasured.
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
| Verilator 5.052 / pinned UVM | 1492 runtime passes at seeds 1/73; 50 expected compile rejections; 230 known |
| Verilator 5.052 / original VPI HDL backend | Separate eleven-case condition: ten pass at both seeds, one fails at seed 1 |
| Verilator 5.052 / command-line VPI and pinned regex DPI | Separate 18-case condition: 17 pass both seeds; 1 known at seed 1 |
| kirimasim / pinned UVM | 1083 unchanged cases: 1074 unsupported and nine missing-API failures; 689 inputs unmeasured |
| Ghost / bundled UVM | 1083 unchanged cases: 207 pass and 876 fail at each seed; 689 inputs unmeasured |
| Ghost / pinned UVM | No measurement for the current executable snapshot |

The ordinary condition retains 230 known cases: 171 runtime first differences,
57 simulation builds and two illegal compiler acceptances. Builds are 20 missing
API/type names, two type-default declarations, two printed signature conflicts,
two inherited type_id registry specializations, one protected-access build, one unlisted-pure-hook build and 29 unlinked DPI cases. Separate HDL/command-line evidence is reported independently.

Nine M2 sequencer fixtures add eight two-seed runtime matches and one seed-1
runtime difference without seed 73. The relevance guard matches at time zero
with the omitted ten, explicit two and twelve, and a virtual base-view setter.
At time three, setting three before a fresh zero-time burst notifies only on
callback five. The retained qualified oracle permits notification at the bound
or first excess (three/four), so this remains spec-only. Raw callback/time
observations are separate from the boundary predicate; ERROR or FATAL is accepted
as the unspecified error notification, without an exact severity/ID/text rule.
No counter-reset, negative-limit or post-error recovery behavior is invented.

Real pull-port transfers match automatic named begin/end notifications and
timestamps, suppression after disabling before the first request, explicit
component recording that gates modeled pipelined completion, and separate
custom address/data events. Standard typed callbacks observe transaction-pool
entries; attaching them does not prove initial pool membership. No physical
DUT completion, recorder handle layout or database format is certified.
The interface overview's inheritance wording conflicts with the actual class
declarations and remains unresolved rather than becoming a new ancestry rule.

One new library-utils duty maps four unchanged macro fixtures. Each extension,
including the derived subtype, already invokes the required macro with its
own exact type. Their empty-static-membership differences remain unchanged;
no extra implementation initialization helper or new execution is claimed.

All 1763 prior ordinary inputs/records, 3094 requirements and 353 assessments
remain unchanged. Totals are 1772 (1720 simulation/52 elaboration): M1 709
(667/42), M2 547 (542/5), M3 516 (511/5). Ordinary pass is 1542 (1492 runtime/
50 rejections); known is 230 (171 runtime/57 builds/two illegal acceptances).
All 110 tool tests, metadata/ledger/library, current-input evidence and paired
docs pass. Guest/HDL/command-line records remain unchanged; guest-unmeasured
inputs total 689. No human approval or goal completion is claimed.

The assembled Verilator snapshot retains unchanged prior inputs and replaces only
remeasured records. It is not one invocation rerunning the entire suite.
On the current host, the compatible local records are:

```text
out/thin-fifty-ninth-verilator-combined.json
out/thin-fifty-ninth-ghost-final-1.json
out/thin-fifty-ninth-ghost-final-73.json
out/thin-fifty-ninth-kirimasim-final.json
out/thin-fifty-ninth-inventory.json
out/thin-fifty-ninth-backlog-final.json
out/thin-fifty-ninth-evidence-scope.json
out/thin-fifty-ninth-hdl-combined.json
out/thin-fifty-ninth-cmdline-final.json
```

Before reuse, verify test-ID sets within each declared full/subset scope, current `inputs_sha256`, identical
simulator version/configuration/library identity and `runner_sha256`, and
false `runner_changed`. Do not merge incompatible records. These ignored
files may be absent on another host; use the tracked runners to regenerate
measurements with authorized configuration. See [evidence assembly](results.md#evidence-assembly).

## Persistent goal and completion audit

The user requested a persistent goal to continue until M1–M4 have zero gaps.
At activation there were 1,463 unassessed identifiers, zero unlinked tests and
zero requirements without direct tests. Thirty-one iterations reduce unassessed to
460, a decrease of 1003. The latest sequencer increment individually decomposes
or assesses seven identifiers; earlier increments are retained in the development
history. Chapter 15 now has zero unassessed and 67 partial identifiers; that
does not complete its remaining conditions or any original milestone target.

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

The existing-test mapping queue is empty across all roots. Review the 460
unassessed identifiers against the standard, distinguishing headings from
normative obligations and splitting conditions before selecting new tests.
Prioritize meaningful defaults, failures, isolation, ordering and lifecycle
combinations in the partially decomposed areas. Review API omissions and
signature/prose conflicts before deriving an oracle.

Sequencer follow-up: audit all 67 partial chapter-15 identifiers, including
mid-burst relevance-limit changes with independently justified counter semantics,
per-sequencer state, push/peek/get automatic-recording conditions and arbitrary
pipeline cancellation. Preserve the positive-time bound interpretation and the
15.2.1 ancestry conflict. Annex B still has 100 unassessed identifiers; read
report/object/field/pack macros individually, retaining static-library differences.

Resource follow-up: audit annex C’s remaining twenty identifiers and all
52 partial ones. Derive sort/regex/scope-collection and typed-maximum behavior
from the standard, qualify its conflicting sentences, test default/static
config/DB declarations and aliases, and extend invalid arguments and lifecycle
conditions. Preserve both local/global name-precedence differences, missing
lookup warnings and the unlisted-pure-hook legal build. Do not substitute
compatibility bodies or matching default return values for those obligations.

Package follow-up: audit annex F’s 63 unassessed identifiers and all partial
type, global service, callback mutation, initialization and run/abort duties.
Keep return-value and actual delivery evidence separate; preserve the isolated
PRE_RUN and report-default differences.

Memory follow-up: audit the remaining 116 chapter-18 identifiers and partial
constructor/default/map/burst/policy/lifecycle combinations. Keep local-only
lookup history, previous-mask returns and public-read accessibility differences.
Derived-wrapper HDL results must remain separate from the public declaration
contract. Extend actual arrays, duplicate paths and failure behavior without
assuming the limited backend supports every type or operation.

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
Chapter 18 retains 116 unassessed identifiers. Subclauses 18.1–18.3 have none,
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
complete M1–M4. Review that interpretation and the remaining 460 identifiers,
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
