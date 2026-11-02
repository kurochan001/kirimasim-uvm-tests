# Development handoff

[日本語](handoff.ja.md) · [README](../README.md) · [Requirements](requirements.md)

## Snapshot and objective

Updated on 2026-11-03 after clearing the existing-test requirement-link
backlog, based on [88b6f34](https://github.com/kurochan001/kirimasim-uvm-tests/commit/88b6f3423ce0f7963036b9485f9ffa97eac49229)
on `main`. Verify the latest publishing commit and working tree before resuming.

The project tests IEEE 1800.2-2020 UVM conformance, targeting kirimasim.
SystemVerilog language-only reproducers belong in
[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests).
Continue strengthening thin areas across M1–M4. M4 remains in progress;
zero unlinked tests does not complete any milestone.

| Area | Current snapshot |
| --- | --- |
| M1 | 360 simulations: core objects, policies, reporting, hierarchy, factory, phases, synchronization, recording and utilities |
| M2 | 420 simulations: sequences, sequencers, callbacks and TLM |
| M3 | 326 simulations: register/memory layer and annex E |
| Entire suite | 1106 simulations in 21 chapter/annex directories; all AI-reviewed, none human-reviewed |
| M4 | 1163 AI requirement drafts; 1160 have direct links to 1105 tests; one additional control test; zero tests without links |
| Normative inventory | 735 of 2,504 identifiers partially decomposed; 1,769 unassessed; three drafts without direct tests |

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
  assembly. [Known differences](known-differences.md): all 107 spec-only cases.
- [Requirement guide](requirements.md), [scope](../coverage/scope.json),
  [ledger](../coverage/requirements.json) and [test index](../coverage/test_index.json):
  canonical M4 state. Generated inventories are review aids, not replacements
  for these versioned inputs.
- [Library lock](../third_party/uvm.lock): Accellera UVM 2020.3.1 at
  `78c06547a2a0`, 326 files. Fetch with the tracked tool; the library itself
  is not committed. All current fixtures use `UVM_NO_DPI`.
- The user supplied `IEEE_Std_1800.2-2020.pdf` and
  `IEEE_Std_1800-2023_SystemVerilog.pdf` in the repository root. They are
  ignored local files, unavailable in a fresh clone, and must not be
  redistributed. Existing extracted text under `/tmp` is also transient.
- Results under `out/` are ignored and local. Temporary expansion helpers
  under `/tmp/kirimasim-uvm-zero-*.py` are optional local aids,
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

The snapshot passed 74 tool unit tests, metadata for all 1106 simulations,
ledger/index validation, library integrity and current-input evidence checks.
A documentation-only change does not require rebuilding the entire suite.
Current full-suite evidence is available for Verilator only; guest records
cover 1085 unchanged inputs, with twenty-one new cases unmeasured.
For a simulator smoke check:

```sh
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 1 \
  --json out/verilator-smoke.json tests/u09/test_common_phases_run_in_order.sv
```

The [Check run for the code snapshot](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/41459306291)
is retained as a reference. Use the README badge for the latest workflow
result; newer commits may supersede that run. Local checks are not proof
of a successful full CI run. Check runs tool,
metadata, ledger, library and tagged Verilator checks, not Ghost, kirimasim
or spec-only simulations. There is no Nightly workflow or automatic result
publication.

## Evidence and latest differences

| Simulator / library | Recorded result |
| --- | --- |
| Verilator 5.052 / pinned UVM | 999 pass at seeds 1 and 73; 107 known |
| kirimasim / pinned UVM | 1085 unchanged cases: 1076 unsupported and nine missing-API failures; twenty-one new cases unmeasured |
| Ghost / bundled UVM | 1085 unchanged cases: 207 pass and 878 fail at each seed; twenty-one new cases unmeasured |
| Ghost / pinned UVM | No measurement for the current executable snapshot |

The 107 known Verilator cases comprise 97 runtime first differences at seed
1 and ten missing-API builds. They do not have seed-73 runtime evidence.
The missing APIs affect one time case, six sequence-library cases, two
HDL-slice cases and one object active-policy case. `known` and `unsupported`
are not passes, and 107 cases do not mean 107 independent bugs. Ghost bundled
results do not establish pinned-library behavior or isolate simulator from
library causes.

The latest addition observes nested policy/object synchronization using the
standard getter, which the pinned library lacks. It retains a spec-only
build difference. All 108 previously unlinked fixtures now have requirement
links; mapping them adds no new simulation result. No new guest measurement
is available because the temporary execution snapshots were lost and no
compatible replacement was found. Two earlier normative spec-only
expectations remain relevant:

- [Simplified plus](../tests/uF/test_is_match_plus_requires_at_least_one_character.sv):
  F.3.3.1/Table F.1 requires one-or-more characters; the tested no-DPI fallback
  treats plus literally. No DPI-enabled or POSIX-expression claim follows.
- [Descriptor invalid indices](../tests/u19/test_reg_item_invalid_value_indices_warn_without_changing_existing_data.sv):
  19.1.1.2.4 requires warnings, ignored writes and zero-valued reads. The
  library expands writes and omits warnings. Separate descriptors isolate
  reads from write expansion; small count/count-plus-one probes bound
  erroneous allocations.

The assembled Verilator snapshot retains unchanged prior inputs and replaces only
remeasured records. It is not one invocation rerunning the entire suite.
On the current host, the compatible local records are:

```text
out/zero-verilator-combined.json
out/thin-fourteenth-ghost-final-1.json
out/thin-fourteenth-ghost-final-73.json
out/thin-fourteenth-kirimasim-final.json
out/zero-inventory.json
out/zero-backlog-final.json
out/zero-evidence-scope.json
```

Before reuse, verify test-ID sets within each declared full/subset scope, current `inputs_sha256`, identical
simulator version/configuration/library identity and `runner_sha256`, and
false `runner_changed`. Do not merge incompatible records. These ignored
files may be absent on another host; use the tracked runners to regenerate
measurements with authorized configuration. See [evidence assembly](results.md#evidence-assembly).

## Remaining work and suggested order

These are prioritization suggestions, not approved exclusions or a coverage
percentage. Regenerate the backlog before choosing the next increment.

The existing-test mapping queue is empty across all roots. Review the 1,769
unassessed identifiers against the standard, distinguishing headings from
normative obligations and splitting conditions before selecting new tests.
Prioritize meaningful defaults, failures, isolation, ordering and lifecycle
combinations in the partially decomposed areas. Review API omissions and
signature/prose conflicts before deriving an oracle.

Three drafts still have no direct test:

| Requirement | Clause | Unresolved observation |
| --- | --- | --- |
| `UVM-HDL-DEPOSIT` | 19.6.2.2 | HDL deposit; current fixtures disable HDL DPI |
| `UVM-HDL-PATH-ACCESSIBILITY` | E.7 | Actual HDL-path accessibility checks; current no-DPI fixtures do not supply them |
| `UVM-MEMORY-WALK-ALGORITHM` | E.6.1 | Full walking-ones algorithm; location masks and a stuck-bit fault are insufficient |

Restore an authorized HDL-capable backend for the first two. For the algorithm
requirement, establish defensible algorithm-specific observations from the
standard before writing an exact oracle; do not copy library traffic.
Library/backend limitations do not remove these obligations from proposed
scope. Zero unlinked tests leaves normative decomposition, independent
coverage, human review and denominator approval open.

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
> unassessed normative obligations and the three drafts without direct tests,
> while adding meaningful new behaviors in M1–M3. Preserve standard-derived expectations, the commercial-result
> exclusion, Ghost privacy, AI review status and complete bilingual docs.
> Measure final inputs, retain valid spec-only differences and report the
> completed changes, validation and remaining limitations.
