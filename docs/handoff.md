# Development handoff

[日本語](handoff.ja.md) · [README](../README.md) · [Requirements](requirements.md)

## Snapshot and objective

Updated on 2026-11-04 for the forty-ninth thin-area expansion, based on
[6ad9de9](https://github.com/kurochan001/kirimasim-uvm-tests/commit/6ad9de903b459b3a42701be8579e908306f3aec7)
on `main`. Verify the current publishing commit and working tree before resuming.

The project tests IEEE 1800.2-2020 UVM conformance, targeting kirimasim.
SystemVerilog language-only reproducers belong in
[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests).
Continue strengthening thin areas across M1–M4. M4 remains in progress;
zero unlinked tests does not complete any milestone.

| Area | Current snapshot |
| --- | --- |
| M1 | 603 tests (570 runtime, 33 elaboration): core objects, policies, reporting, hierarchy, factory, phases, synchronization, recording and utilities |
| M2 | 538 tests (533 runtime, 5 elaboration): sequences, sequencers, callbacks and TLM |
| M3 | 458 tests (453 runtime, 5 elaboration): register/memory layer and annex E |
| Entire suite | 1599 tests (1556 simulation, 43 elaboration) in 21 chapter/annex directories; all AI-reviewed, none human-reviewed |
| M4 | 2678 AI requirement drafts; 2678 have direct links to 1598 tests; one additional control test; zero tests without links |
| Normative inventory | 1468 of 2,507 identifiers partially decomposed; 281 explicitly assessed; 758 unassessed; zero drafts without direct tests |

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
  assembly. [Known differences](known-differences.md): all 199 spec-only cases.
- [Requirement guide](requirements.md), [scope](../coverage/scope.json),
  [ledger](../coverage/requirements.json), [assessments](../coverage/assessments.json) and [test index](../coverage/test_index.json):
  canonical M4 state. Generated inventories are review aids, not replacements
  for these versioned inputs.
- [Library lock](../third_party/uvm.lock): Accellera UVM 2020.3.1 at
  `78c06547a2a0`, 326 files. Fetch with the tracked tool; the library itself
  is not committed. 1573 fixtures use `UVM_NO_DPI`; eight explicitly request the original VPI HDL backend.
- The user supplied `IEEE_Std_1800.2-2020.pdf` and
  `IEEE_Std_1800-2023_SystemVerilog.pdf` in the repository root. They are
  ignored local files, unavailable in a fresh clone, and must not be
  redistributed. Existing extracted text under `/tmp` is also transient.
- Results under `out/` are ignored and local. Temporary expansion helpers
  under `/tmp/kirimasim-uvm-thin-forty-ninth-*.py` are optional local aids,
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

The snapshot passed 110 tool unit tests, metadata for all 1599 tests (1556 simulation, 43 elaboration),
ledger/index validation, library integrity and current-input evidence checks.
A documentation-only change does not require rebuilding the entire suite.
Current full-suite evidence is available for Verilator only; guest records
cover 1083 unchanged inputs, with 516 inputs unmeasured.
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
| Verilator 5.052 / pinned UVM | 1359 runtime passes at seeds 1/73; 41 expected compile rejections; 199 known |
| Verilator 5.052 / original VPI HDL backend | Separate eight-case condition: seven pass at both seeds, one fails at seed 1 |
| Verilator 5.052 / command-line VPI and pinned regex DPI | Separate 18-case condition: 17 pass both seeds; 1 known at seed 1 |
| kirimasim / pinned UVM | 1083 unchanged cases: 1074 unsupported and nine missing-API failures; 516 inputs unmeasured |
| Ghost / bundled UVM | 1083 unchanged cases: 207 pass and 876 fail at each seed; 516 inputs unmeasured |
| Ghost / pinned UVM | No measurement for the current executable snapshot |

The ordinary condition retains 199 known cases: 150 runtime first differences,
47 simulation builds and two illegal compiler acceptances. Builds are 18 missing
API/type names, two type-default declarations, one printed hook-signature conflict
and 26 unlinked DPI cases. Separate HDL/command-line evidence remains 7/1 and 17/1.

The latest nine M3 runtime fixtures all match both seeds. Six D.3 named
register/memory cases cover genuine lookup, independent forwarding, real
frontdoor storage, debug invariance and failure/retry results. They live in uD
under the primary-clause rule and count toward the register-layer M3 milestone.
Three u18 cases cover hierarchical needs_update, minimum selected update writes,
clean no-write behavior and mirror read/refresh/default-versus-explicit checking.
No sibling order, failed-read data or exact debug forwarding is prescribed.

Milestones: M1 603 (570 runtime/33 elaboration), M2 538 (533/5), M3 458
(453/5), totaling 1599 (1556/43). Ordinary pass is 1400: 1359 runtime matches
and 41 compiler rejections. All 1590 prior inputs/records, 2613 requirements and
279 assessments remain unchanged. Sixty-five drafts reach 2678; two contextual
assessments reach 281 (187/94). Totals are 1468 partial/281 assessed/758
unassessed. Annex D is 39/8/0 and chapter 18 is 230/26/200. All partial
conditions and milestone targets remain open.

All 110 tool tests, metadata, ledger/library, current-input evidence and paired
docs pass. Guest files retain 1083 byte-identical compatible records, with 516
unmeasured inputs (473 simulation/43 elaboration), including both earlier revised
inputs. No new guest result, human review, approval or goal completion is claimed.
Schema, runners/library/catalog, workflow and SVGs remain unchanged.

The assembled Verilator snapshot retains unchanged prior inputs and replaces only
remeasured records. It is not one invocation rerunning the entire suite.
On the current host, the compatible local records are:

```text
out/thin-forty-ninth-verilator-combined.json
out/thin-forty-ninth-ghost-final-1.json
out/thin-forty-ninth-ghost-final-73.json
out/thin-forty-ninth-kirimasim-final.json
out/thin-forty-ninth-inventory.json
out/thin-forty-ninth-backlog-final.json
out/thin-forty-ninth-evidence-scope.json
out/thin-forty-ninth-hdl-combined.json
out/thin-forty-ninth-cmdline-final.json
```

Before reuse, verify test-ID sets within each declared full/subset scope, current `inputs_sha256`, identical
simulator version/configuration/library identity and `runner_sha256`, and
false `runner_changed`. Do not merge incompatible records. These ignored
files may be absent on another host; use the tracked runners to regenerate
measurements with authorized configuration. See [evidence assembly](results.md#evidence-assembly).

## Persistent goal and completion audit

The user requested a persistent goal to continue until M1–M4 have zero gaps.
At activation there were 1,463 unassessed identifiers, zero unlinked tests and
zero requirements without direct tests. Twenty-one iterations reduce unassessed to
758, a decrease of 705: 29 register-global, 21 command-line, 12 sequence,
36 register-interaction, 22 translation/callback/HDL-parameter, 35 synchronization,
34 objection/callback, 45 TLM 1, 33 channel/analysis/TLM 2 and 45 TLM 2
socket/extension/port/imp, four abstract-declaration, eight pure-interface/subscriber, 41 reporting, 68 printer/reporting and 60 comparer/copier/packer/recorder and 29 memory-manager and 43 sequencer and 67 component/default-runtime and 22 component/convenience and 42 recording/declaration and nine named-access/block identifiers were
individually decomposed or assessed.
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

The existing-test mapping queue is empty across all roots. Review the 758
unassessed identifiers against the standard, distinguishing headings from
normative obligations and splitting conditions before selecting new tests.
Prioritize meaningful defaults, failures, isolation, ordering and lifecycle
combinations in the partially decomposed areas. Review API omissions and
signature/prose conflicts before deriving an oracle.

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

Chapter 15 retains the interface introduction's inconsistent claim that sequence
items subtype the interface, and the zero-time relevance-wait limit. Read the
class declarations together before deriving a new inheritance oracle. Keep
wait_for_sequences waiting behavior qualified separately from immediate try.
Further partial work includes default/invalid connector types, priorities,
recording events, phase/default interactions and complete protocol histories.

Chapters 7 and 13 have no unassessed identifiers. Audit their 50 and 89 partial
identifiers, including recording activity/handles, event pools, transaction
ordering, configuration, asynchronous domains and complete error conditions.
Error/event backend timestamps remain qualified; do not impose one token or
string encoding across applications. Keep the all_dropped function/task,
create_object equivalent-call arity and report_db/report_cb name conflicts open.
Annex D has no unassessed identifier but retains 39 partial identifiers.
Named wrappers still need missing-name/path/map and complete status/protocol
audits; do not infer undocumented null-target diagnostics from a library result.
Chapter 18 retains 200 unassessed identifiers. Read remaining block declarations,
configuration/backdoor APIs, adapter/predictor callbacks and register/memory
lifecycle conditions, extending meaningful partial conditions as well as new IDs.

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
complete M1–M4. Review that interpretation and the remaining 758 identifiers,
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
