# Development handoff

[日本語](handoff.ja.md) · [README](../README.md) · [Requirements](requirements.md)

## Snapshot and objective

Prepared on 2026-11-02 for the code snapshot
[3329a52](https://github.com/kurochan001/kirimasim-uvm-tests/commit/3329a52addc6d09b4979c757af5af45dc87f5bf4)
on `main`, after the fourteenth expansion across M1–M4. The working tree
was clean before adding this document. This handoff adds documentation;
it does not add simulations or measurements. Recheck the branch and
working tree before resuming.

The project tests IEEE 1800.2-2020 UVM conformance, targeting kirimasim.
SystemVerilog language-only reproducers belong in
[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests).
The ongoing request is to strengthen thin areas across M1–M4. M4 is in
progress; M1–M3 remain independently incomplete.

| Area | Current snapshot |
| --- | --- |
| M1 | 351 simulations: core objects, policies, reporting, hierarchy, factory, phases, synchronization, recording and utilities |
| M2 | 416 simulations: sequences, sequencers, callbacks and TLM |
| M3 | 318 simulations: register/memory layer and annex E |
| Entire suite | 1085 simulations in 21 chapter/annex directories; all AI-reviewed, none human-reviewed |
| M4 | 1021 AI requirement drafts; 1017 have direct links to 956 tests; one additional control test; 128 tests without requirement links |
| Normative inventory | 684 of 2,504 identifiers partially decomposed; 1,820 unassessed; four drafts without direct tests |

`scope_status` remains proposed, `normative_inventory_complete` is false,
and `approved_denominator` / `coverage_percentage` remain null. A clause
citation, two tests on a clause, or zero unmapped tests does not establish
complete requirement coverage. Eighteen roots, including chapter 15, have
no unmapped primary-focus tests; their normative decomposition is partial.

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
  assembly. [Known differences](known-differences.md): all 106 spec-only cases.
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
  under `/tmp/kirimasim-uvm-thin-fourteenth-*.py` are optional local aids,
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

The snapshot passed 74 tool unit tests, metadata for all 1085 simulations,
ledger/index validation, library integrity and current-input evidence checks.
A documentation-only change does not require rebuilding the entire suite.
For a simulator smoke check:

```sh
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 1 \
  --json out/verilator-smoke.json tests/u09/test_common_phases_run_in_order.sv
```

The [Check run for the code snapshot](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/41351526515)
is retained as a reference. Use the README badge for the latest workflow
result; newer commits may supersede that run. Local checks are not proof
of a successful full CI run. Check runs tool,
metadata, ledger, library and tagged Verilator checks, not Ghost, kirimasim
or spec-only simulations. There is no Nightly workflow or automatic result
publication.

## Evidence and latest differences

| Simulator / library | Recorded result |
| --- | --- |
| Verilator 5.052 / pinned UVM | 979 pass at seeds 1 and 73; 106 known |
| kirimasim / pinned UVM | 1076 unsupported at the object-wrapper blocker; nine earlier missing-API failures |
| Ghost / bundled UVM | 207 pass and 878 fail at each seed; identical failing sets |
| Ghost / pinned UVM | No measurement for the current executable snapshot |

The 106 known Verilator cases comprise 97 runtime first differences at seed
1 and nine missing-API builds. They do not have seed-73 runtime evidence.
The missing APIs affect one time case, six sequence-library cases and two
HDL-slice cases. `known` and `unsupported` are not passes, and 106 cases do
not mean 106 independent bugs. Ghost bundled results do not establish
pinned-library behavior or isolate simulator from library causes.

The latest twenty additions cover simplified matching / enum-name conversion,
response waits / queue clearing, and register-operation descriptors.
Eighteen reproduce at both seeds. Two keep normative spec-only expectations:

- [Simplified plus](../tests/uF/test_is_match_plus_requires_at_least_one_character.sv):
  F.3.3.1/Table F.1 requires one-or-more characters; the tested no-DPI fallback
  treats plus literally. No DPI-enabled or POSIX-expression claim follows.
- [Descriptor invalid indices](../tests/u19/test_reg_item_invalid_value_indices_warn_without_changing_existing_data.sv):
  19.1.1.2.4 requires warnings, ignored writes and zero-valued reads. The
  library expands writes and omits warnings. Separate descriptors isolate
  reads from write expansion; small count/count-plus-one probes bound
  erroneous allocations.

The assembled snapshot retains unchanged prior inputs and replaces only
remeasured records. It is not one invocation rerunning the entire suite.
On the current host, the compatible local records are:

```text
out/thin-fourteenth-verilator-combined.json
out/thin-fourteenth-ghost-final-1.json
out/thin-fourteenth-ghost-final-73.json
out/thin-fourteenth-kirimasim-final.json
out/thin-fourteenth-inventory.json
out/thin-fourteenth-backlog-final.json
```

Before reuse, verify complete test-ID sets, current `inputs_sha256`, identical
simulator version/configuration/library identity and `runner_sha256`, and
false `runner_changed`. Do not merge incompatible records. These ignored
files may be absent on another host; use the tracked runners to regenerate
measurements with authorized configuration. See [evidence assembly](results.md#evidence-assembly).

## Remaining work and suggested order

These are prioritization suggestions, not approved exclusions or a coverage
percentage. Generate a fresh backlog before choosing the next increment.

| Root | Existing tests without requirement links | Suggested focus |
| --- | --- | --- |
| 14 | 20 | Remaining response, lock/grab, kill, relevance and completion-wait fixtures; a bounded batch can finish mapping this root |
| 18 | 62 | Register/virtual-register callbacks, dynamic allocation, regions and model controls |
| 12 | 46 | TLM 2 timing, exports/sockets, payload packing and nonblocking transport |

In parallel with mapping existing tests, select standard-derived behaviors
that remain thin in M1, M2 and M3. Prefer meaningful defaults, failures,
isolation, ordering and lifecycle combinations over nominal case counts.
Review API omissions and signature/prose conflicts in known differences
before selecting a case. Keep a batch small enough to measure and document
completely; do not claim milestone completion from mapping alone.

Four drafts still have no direct test:

| Requirement | Clause | Unresolved observation |
| --- | --- | --- |
| `UVM-POLICY-ACTIVE-POLICY-SYNC` | 16.1.3.1 | Object-side active-policy bookkeeping; policy-side depth/top controls are insufficient |
| `UVM-HDL-DEPOSIT` | 19.6.2.2 | HDL deposit; current fixtures disable HDL DPI |
| `UVM-HDL-PATH-ACCESSIBILITY` | E.7 | Actual HDL-path accessibility checks; current no-DPI fixtures do not supply them |
| `UVM-MEMORY-WALK-ALGORITHM` | E.6.1 | Full walking-ones algorithm; location masks and a stuck-bit fault are insufficient |

Library/backend limitations do not remove these obligations from proposed
scope. The broader unassessed inventory remains open even where all
existing tests have links.

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
> remaining chapter-14 mappings first, while adding meaningful new behaviors
> in M1–M3. Preserve standard-derived expectations, the commercial-result
> exclusion, Ghost privacy, AI review status and complete bilingual docs.
> Measure final inputs, retain valid spec-only differences and report the
> completed changes, validation and remaining limitations.
