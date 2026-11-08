# Claude Code handoff

[日本語](claude-code-handoff.ja.md) · [README](../README.md) · [Detailed handoff](handoff.md)

## Start here

Updated on 2026-11-07. A Claude Code session took over from the previous handoff; the user approved resuming the persistent M1–M4 goal, fixing CI first and publishing to main. That session split CI in [a897c68](https://github.com/kurochan001/kirimasim-uvm-tests/commit/a897c6820b037b8fddecfbf7c72c7997bcd075f4) and [42d03ab](https://github.com/kurochan001/kirimasim-uvm-tests/commit/42d03abae20701f344697d13bdca83043c3710f1) and published the 113th expansion in [f94ba4a](https://github.com/kurochan001/kirimasim-uvm-tests/commit/f94ba4ab94a67d5e9eeb2fcaf7e19a57b4596cc4). The first Regression then showed that hosted runners lacked the z3 constraint solver; the session installed it in the setup action and published the 114th expansion in [db06513](https://github.com/kurochan001/kirimasim-uvm-tests/commit/db06513ce8c467d7a2e87e972beae496ff73c828). It then published the 115th expansion in [eeda25d](https://github.com/kurochan001/kirimasim-uvm-tests/commit/eeda25d9b378773a2841076706f8e8029d87c08d). On 2026-11-08 the user supplied an external review; its first item, RTL integration, is the 116th expansion in [c314982](https://github.com/kurochan001/kirimasim-uvm-tests/commit/c314982e5c42e5333790b7ba7bb00bbaef8da2f7); its second item, four-state paths, is the 117th expansion in [46e8106](https://github.com/kurochan001/kirimasim-uvm-tests/commit/46e81064f9d1a89764027b7ec8b02b7cdc0ce624); its third item, randomization properties, is the 118th expansion in [8e056d1](https://github.com/kurochan001/kirimasim-uvm-tests/commit/8e056d11f8c9671dfe0197cf888e74fdb8e79bb8); its fourth item, DPI configurations, is the 119th expansion in [4a9f9e4](https://github.com/kurochan001/kirimasim-uvm-tests/commit/4a9f9e4d026a8c58a48c16447f8e43071d9ab047); its fifth item, user packages, is the 120th expansion in the commit that carries this text. **The goal remains open; it is not complete.**

Inspect the actual branch and working tree before editing. All native measurements of the 120th expansion have terminated; the 117th four-state inputs have no native measurement.

Read the current workspace instructions first. The user's agent instructions reference `RTK.md`; resolve it in the current environment. No private configuration or absolute user path belongs in published files.

## What is complete, and what remains

The three generated queues are 0: unlinked tests, requirements without direct tests, and unassessed catalog identifiers. **Zero actual remaining work has not been demonstrated.** The catalog contains 2507 identifiers: 2062 partial and 445 assessed. Scope is proposed, completeness is false, the approved denominator and coverage percentage are null, and human review is unrecorded. Original M1–M4 targets and remaining normative applicability conditions stay open; [the requirements guide](requirements.md) explains these distinct measures.

- Tests: 2762 = 2663 simulation + 99 elaboration, across 22 directories. M1: 1187 (1106/81); M2: 633 (626/7); M3: 942 (931/11). Seven are four-state (`:fourstate: yes`) spec-only inputs without Verilator records.
- AI duties: 4150, all directly linked to 2706 tests; 56 tests are control-only. No human review is claimed.
- Ordinary passing inputs: 2292 = 2198 runtime matches at seeds 1/73 + 94 expected compiler rejections.
- Known differences: 463 = 318 runtime differences + 140 simulation build failures + 5 illegal compile acceptances. A failed first seed does not establish a second-seed result. Spec-only cases total 470 with the seven four-state inputs.
- Separate conditions: command-line 23 fixtures (20 match seeds 1/73, 3 known); regex-DPI variants 26 (all match).
- Guest evidence: 1081 compatible records; 1681 unmeasured inputs (1677 additions and 4 revised originals). No guest run occurred in expansions 112 to 120. Previously used temporary private executable/profile snapshots are unavailable; obtain authorized local configuration before measuring guests.
- Candidate placement: 1167 have no primary test, 764 have one, and 551 have at least two. These counts do not prove clause coverage or independent passing checks.

Additional HDL-backend, command-line and regex-DPI variant checks have separate execution conditions; see [results](results.md) and [testing](testing.md). Do not add their counts to ordinary totals without checking scope.

## CI state

Hosted CI had not finished a Verilator selection since 2026-10-31: the single Check ran everything on each push with cancel-in-progress, and its one uninterrupted 8-shard run reached the 150-minute limit on every shard. [The CI section](results.md#continuous-integration) describes the replacement and the solver fix.

- [Check](../.github/workflows/check.yml) runs tools, metadata, library and ledger checks plus the tagged checks whose inputs changed and one canary ([the selection tool](../tools/ci_select.py)). It succeeded on 42d03ab ([run 42359747127](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42359747127), canary only) and on f94ba4a ([run 42360326889](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42360326889), the four 113th inputs and the canary). Neither selection randomizes.
- [Regression](../.github/workflows/regression.yml) runs all tagged checks in 20 shards, four at a time with 360 minutes each, plus the 20 command-line checks and the 26 regex-DPI variants in separate jobs, manually and weekly. Its first dispatch, [run 42359747603](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42359747603) on 42d03ab, was cancelled after the command-line job (success) and shards 0, 2 and 3 (334 of 342 matched). All eight differences depend on constrained randomization: the image had no SMT solver on the path. Removing z3 locally reproduced the four differences checked. That run is not a Regression result for any commit.
- The [setup action](../.github/actions/setup-verilator/action.yml) now installs z3 in every job and prints its version. The Check for [db06513](https://github.com/kurochan001/kirimasim-uvm-tests/commit/db06513ce8c467d7a2e87e972beae496ff73c828), [run 42371357208](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42371357208), installed z3 4.8.12 and matched its five selected checks, including the two request profiles that randomize an allocation policy.
- Regression was dispatched again on db06513 as [run 42372122368](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42372122368). All 20 shards matched the 2273 tagged checks at seeds 1/73, taking 113 to 199 minutes each, and the command-line job succeeded; the 115th commit was published after that result. The run covers db06513, while Check's changed-input job and the local measurements cover the four 115th inputs. The 116th inputs are covered by Check on their commit and the local measurements, the 117th four-state inputs are selected by neither Check nor Regression, the 118th inputs are covered by Check on their commit and the local measurements, and the 119th command-line fixtures and regex-DPI variants are covered by the local measurements, while Check runs only the canary for them and the next Regression covers them in its command-line and regex jobs, and the 120th inputs are covered by Check on their commit and the local measurements; dispatch Regression again when a later full hosted result is needed, and if a shard times out or fails, investigate before publishing more tests.
- A ten-concurrent dispatch was cancelled earlier because it filled the account's shared hosted job slots and delayed other repositories. Keep Regression's concurrency modest and do not overlap full runs.

## External review

On 2026-11-08 the user supplied an external static review with eight prioritized items, to strengthen the suite as a measure of whether kirimasim can run real UVM testbenches. The fact check confirmed its counts, except that randomization already had 36 sequence-library files, 52 pre/post_randomize files and seven inline-constraint `uvm_do` files, and that `uvm_do_with` is not part of 1800.2-2020 (B.3.1.4 uses the `CONSTRAINTS` argument). Each item is committed separately, and Check on main confirms it before the next item is published.

- Item 1, RTL integration: implemented in the 116th expansion below.
- Item 2, four-state paths: implemented in the 117th expansion below.
- Item 3, randomization properties: implemented in the 118th expansion below.
- Item 4, DPI configurations: implemented in the 119th expansion below, after the user approved the proposal (a separate regex-DPI runner and variant list, no new metadata field).
- Item 5, user packages: implemented in the 120th expansion below, without format changes.
- Item 6 (cause classification of the known inputs, now 463) and item 7 (kirimasim stages): propose first and wait for the user's confirmation. For item 6, storing values that the pinned library would produce, derived from its source, changes the provenance policy and needs an explicit user decision. Stage tags and cause records are proposed as separate tracked files, because header fields would change every input fingerprint.
- Item 8 (readability): changing comments and helpers re-fingerprints most inputs; a directory filter for Regression dispatch is proposed so that each directory does not need a full thirteen-hour run.

## Preserve these decisions

- Derive independent expectations from the user-provided IEEE standards. The ignored local PDFs are `IEEE_Std_1800.2-2020.pdf` and `IEEE_Std_1800-2023_SystemVerilog.pdf`; they are absent from a fresh clone and must not be redistributed. Do not copy standard prose, figures or examples into tests or documentation.
- Never use commercial simulator results, output or diagnostics, including anonymized or third-party material. Never read GPL/LGPL simulator implementation source. Follow [provenance](provenance.md) and [submission policy](faq.md#commercial-simulator-and-issue-reporting-policy).
- Pinned Apache UVM source can explain a difference after the standard-derived oracle is frozen; it does not define the expected result. Preserve valid spec-only differences and qualified interpretations. Never change an expectation merely to match observed output; disclose and archive any pre-tag revision.
- Keep Ghost's real identity, version, executable/profile paths, profile contents and raw diagnostics private. Keep PDFs, fetched library source, logs, private settings and generated scratch files out of Git.
- Maintain complete English/Japanese pairs. README describes the current state; [history](history.md) records past increments. Preserve the recent reader explanations and links, historical FAQ checkpoints, AI review status and existing evidence identity.
- Do not change `tools/run_verilator.py`, `tools/suite_results.py` or `tools/uvm_common.py` casually: they form the runner fingerprint, and changing them invalidates every stored record. `tools/ci_select.py` and the workflow files are outside it.

## The latest implementation and its limits

Expansion 120 implements item 5 without format changes. Four original packages in `tests/u08/helpers120_pkg/` (agent, sequence, environment, extension) are compiled from separate `:files:` entries in dependency order; the agent and sequence packages never import the extension package. Five profiles in u08 and u15 check static factory registration of types that no code names (queried before run_test), creation by name, run_test of a test class declared in a package, the hierarchy that type_id::create builds across packages, type and relative instance overrides set through type_id, a by-name type override with creation by name, and a default-sequence wrapper from another package replaced on one sequencer by an instance override. All five match seeds 1/73 before and after tagging from the first freeze. By-name overrides are checked only with creation by name, because 8.3.1.4 ties them to create_* calls with the same string. Nine `UVM-USER-PACKAGE-*` duties were added (the `UVM-PKG-*` prefix already names uvm_pkg enumeration duties); see [the package FAQ](faq.md#q442-what-do-the-user-package-profiles-check). The requirement table's rows 15 and 18 had each missed one 116th-expansion duty and are corrected, and the local 119th evidence scope's build count was corrected from 135 to 140.

Expansion 119 implements item 4 as the user approved it. [The regex-DPI runner](../tools/run_verilator_regex.py) is a separate condition (`verilator_regex`): it rebuilds the two-state fixtures listed in `coverage/regex_dpi_variants.txt` without UVM_NO_DPI, defining UVM_HDL_NO_DPI and linking the pinned regex wrapper and the original command-line VPI bridge. Fixture files, expected files and stored records are unchanged. A first configuration with UVM_CMDLINE_NO_DPI did not deliver +UVM_TESTNAME (NOCOMP in the five RTL profiles), so the bridge is enabled. All 26 listed fixtures match seeds 1/73 and Regression runs them in a `regex` job; its gate requires the command-line, regex and shard jobs. Five new spec-only fixtures in the command-line condition check F.3.3.1 notation, regular-expression and plus scopes in configuration and resource lookups (C.4.2.2.1, C.2.4.3), component lookup (F.7.4.1) and get_arg_matches (G.1.3.4). Three match both seeds and are tagged; two remain known in one row each, and the pinned library source, read only after the oracle was frozen, explains them (`uvm_re_deglobbed` keeps an unslashed caret and dollar sign as anchors; the default configuration lookup finds field names exactly). Eight `UVM-REGEX-*` duties were added; see [the DPI FAQ](faq.md#q440-what-do-the-regex-dpi-variants-and-profiles-check) and [Regular-expression matching](known-differences.md#regular-expression-matching).

Expansion 118 added five randomization-property profiles in uB, sharing `tests/uB/helpers118_rand/rand118.svh` (event log, driver and test base). They check constraint_mode after uvm_create, inline constraints with single randomization and start/randomize/finish order over twenty-four uvm_do items, randc cycling over repeated uvm_rand_send of one item, a child-sequence field kept by rand_mode before pre_start, and inline-constraint name resolution with local::. Judgments use properties, never particular values. Two readings are stated: an empty inline constraint does not change randc constraints, and macro CONSTRAINTS are evaluated as an inline constraint at the macro call. All five match seeds 1/73 before and after tagging from the first freeze. Six `UVM-RAND-PROPERTY-*` duties were added; see [the randomization FAQ](faq.md#q438-what-do-the-randomization-property-profiles-check).

Expansion 117 added seven four-state spec-only inputs (`:fourstate: yes`) in uC, u12, u11, u16 and uB. They check configuration lookups, typed resources, TLM FIFOs, missing pool keys and queue entries (all X under 1800-2023 Table 7-1), direct and field-macro recording, and field-macro copy and clone, with case equality. The ordinary Verilator runner selects only two-state fixtures, so they have no records; a two-state build was only a diagnostic, and Verilator rejected most tristate constructs. Unspecified paths, such as comparing, printing and packing X and Z bits, are listed in [the four-state section](testing.md#four-state-paths). Nine `UVM-FOURSTATE-*` duties were added; see [the four-state FAQ](faq.md#q436-what-do-the-four-state-profiles-check).

Expansion 116 added five RTL integration profiles in uC, u14, u19 and u12, sharing `tests/u19/helpers116_rtl/rf_rtl116.sv` (an original register-file design and an interface with driver and monitor clocking blocks) and `tests/u19/helpers116_rtl/rf_env116.svh` (driver, monitor, register model, adapter, optional predictor, collector and analysis-FIFO scoreboard). They check configuration-database delivery of the virtual interface, finish_item completion with clocked request timing, frontdoor access through the adapter with auto-prediction, explicit prediction with its register-item port, and analysis-FIFO buffering. Expectations combine the helper's design rules, the cited UVM clauses and 1800-2023 clocking-block timing; no runner change was needed. The first freeze did not build because a scoreboard counter used the reserved word `matches`; only that identifier changed, and the unbuilt inputs are archived under `out/thin-one-hundred-sixteenth-before-identifier-fix/`. All five match seeds 1/73 before and after tagging. Nine `UVM-RTL-*` duties were added; see [the RTL FAQ](faq.md#q434-what-do-the-rtl-integration-profiles-check).

Expansion 115 added four M3 profiles under `tests/u18/`, sharing `tests/u18/helpers115_mam_reconfigure/reconfigure115.svh`. A manager holding region 12..15 is reconfigured from 8..23 to 4..27 or from 4..27 to 8..23; afterwards reservations or fixed-start requests at each new edge must succeed with exact geometry and those just outside each new bound must be rejected. The request profiles also check, in pre_randomize, that min_offset, max_offset and len present the new bounds. The first freeze did not build because a policy handle used the reserved word `before`; only the two handle names changed, and the unbuilt inputs are archived under `out/thin-one-hundred-fifteenth-before-identifier-fix/`. New duties are `UVM-MAM-AUDIT-RECONFIGURED-BOUNDS-RESERVE`, `-BOUNDS-REQUEST`, `-POLICY-MINIMUM` and `-POLICY-MAXIMUM`; see [the reconfiguration FAQ](faq.md#q432-what-do-the-reconfigured-bounds-profiles-check). The 112th setter-order duty's limitations now record an AI re-review: the 12.3.4.2.6 note supports the virtual-visit reading but is informative, so the two observed profiles stay known pending human review.

Expansion 114 added four M3 profiles under `tests/u18/`, sharing `tests/u18/helpers114_mam_stale_source/stale_source114.svh`. The stale descriptor comes from request_region (released through the manager or its region facade) or from a dynamic virtual-register array (implemented or allocated, then released with the virtual-register method). Each keeps a peer reservation, reuses the freed range, then releases the saved descriptor through the manager; 18.12.5.3 requires an error. For virtual-register regions the stale call is made only after the array is unimplemented, a stated interpretation, because 18.9.1.1.4 and 18.9.1.1.5 direct release through the virtual-register method. Only the presence of an error is checked.

The first freeze also asserted the region-owner query in the virtual-register setup row. Both virtual-register inputs differed only there, reproducing the existing 18.12.7.2.7 owner known difference, while the request inputs matched. That query became a DIAG114 row, the getter identity stayed asserted and expected files are unchanged; the first-freeze inputs and batches are archived under `out/thin-one-hundred-fourteenth-before-owner-split/`. The revised inputs match seeds 1/73 before and after tagging. New duties are `UVM-MAM-AUDIT-STALE-REQUEST-DESCRIPTOR-RELEASE-ERROR`, `UVM-VREG-AUDIT-STALE-REGION-MANAGER-RELEASE-ERROR` and `UVM-VREG-AUDIT-RELEASE-KEEPS-PEER-RESERVATION`; `UVM-MAM-AUDIT-REGION-RELEASE` gained the requested region-facade profile. See [the source FAQ](faq.md#q430-what-do-the-stale-descriptor-source-profiles-add).

The 113th limit stays: no stale call is made while the same range is reserved again, because 18.12.7 does not state whether a later reservation returns a new descriptor instance. A manager release of a region that still implements a virtual-register array is not checked. The 112th unpack interpretation remains qualified: whether the listed setters require actual virtual visits, including empty arrays, still needs review, and the two observed profiles stay known. Other open interpretations include physical address translation, automatic recording with storage disabled or mutated, exact event-delta applicability, and cancellation of otherwise activated or suspended waiters. The [detailed handoff](handoff.md) retains the surrounding conditions and older valid differences.

## Local artifacts

The ignored `out/` directory is optional local evidence, not a tracked source of truth. It may be absent after cloning. On this host, the 120th-expansion files are:

```text
out/thin-one-hundred-twentieth-pretag-freeze.json
out/thin-one-hundred-twentieth-verilator-pretag.json
out/thin-one-hundred-twentieth-verilator-final.json
out/thin-one-hundred-twentieth-verilator-combined.json
out/thin-one-hundred-twentieth-evidence-scope.json
out/thin-one-hundred-twentieth-inventory.json
out/thin-one-hundred-twentieth-backlog.json
out/thin-one-hundred-twentieth-doc-contents-effective.json
```

The 119th files keep the same names with `nineteenth`, including `cmdline-pretag.json`, `cmdline-final.json`, `cmdline-combined.json`, `regex-variants.json` and `diag-cmdline-known.txt`; its evidence scope was corrected locally to 140 builds. The 118th files keep the same names with `eighteenth`, including `verilator-pretag.json`. The 117th files keep the same names with `seventeenth`; its four-state inputs have only `freeze.json` and the two-state diagnostic log, without batches. The 116th files keep the same names with `sixteenth`, including pretag/final batches and `before-identifier-fix/`. The 115th files keep the same names with `fifteenth`. The 114th files keep the same names with `fourteenth`, plus `out/thin-one-hundred-fourteenth-regression-42359747603.json` and `out/thin-one-hundred-fourteenth-before-owner-split/`.

Guest records remain the 112th files listed in [the detailed handoff](handoff.md#evidence-and-latest-differences). `out/thin-one-hundred-twentieth-generator-used.py`, `-ledger-used.py` and `-docs-used.py`, and the 114th to 119th scripts of the same form, are the scripts actually used; their guards refer to earlier commits and document text, so do not rerun them. For later document updates, start from the effective snapshot and the current tracked files. Preserve existing index order when appending records, and check input, runner, library and simulator fingerprints before carrying evidence forward; [evidence assembly](results.md#evidence-assembly) gives the rules.

## Next candidates

These are suggestions, not approved scope. Regenerate the backlog before choosing.

- The next external review item in order (item 6, cause classification of the 463 known inputs), following the review plan above. It needs a proposal first, and the user's decision on storing library-derived values is still pending.
- Reconfiguration that changes mode or locality together with the bounds, or other byte widths, under 18.12.4.2.
- The 112th named-setter question for unpack, reviewed against the standard without promoting the known cases on library evidence.
- Other partial M3 conditions in chapter 18 (393 partial identifiers), and the 2062 partial identifiers overall, compared with the original M1–M3 targets.

## Verify and resume

Before each increment, regenerate the backlog, review a real remaining duty against the standards, freeze the independent oracle, measure the final inputs, update compatible evidence and both languages, then publish. Do not declare the goal complete until actual remaining duties and original milestone targets have been audited. Claude Code does not inherit a conversation's native goal state automatically.

Use Python 3.10 or later. Native reproduction uses Verilator 5.052, a C++ toolchain, make and the z3 solver on the path. Fetch the pinned Accellera UVM 2020.3.1 library if absent. A restart checklist:

```sh
git status --short --branch
git log -1 --oneline
z3 --version
python3 tools/fetch_uvm.py
python3 tools/fetch_uvm.py --check
python3 tools/lint_metadata.py
python3 tools/requirements.py check
python3 tools/requirements.py inventory --json out/requirements-inventory.json
python3 tools/requirements.py backlog --json out/requirements-backlog.json --lang ja
python3 -m unittest discover -s tools -p 'test_*.py'
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 1 --json out/verilator-smoke.json tests/u09/test_common_phases_run_in_order.sv
gh run list --workflow regression.yml --limit 3
```

## Message to give Claude Code when resuming

> Read the current workspace instructions, README and both Claude Code handoff files. Verify main, the working tree, the latest Check run and the latest Regression run. Continue the open M1–M4 goal only as authorized by the user. The three generated queues are zero, but 2062 partial identifiers and original milestone targets remain; zero actual gaps is unproven. Audit a meaningful remaining condition against the local IEEE standards and avoid duplicating existing tests. Preserve independent expectations, qualified known differences, compatible evidence, the runner fingerprint, commercial-result exclusion, Ghost privacy and complete bilingual documentation. Do not replay completed scratch scripts. Measure final inputs, run appropriate checks, report limitations and publish to main as authorized. Do not manufacture review, scope approval, passing results or goal completion.
