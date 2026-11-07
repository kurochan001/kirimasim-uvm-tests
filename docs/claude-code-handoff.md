# Claude Code handoff

[日本語](claude-code-handoff.ja.md) · [README](../README.md) · [Detailed handoff](handoff.md)

## Start here

Updated on 2026-11-07. A Claude Code session took over from the previous handoff; the user approved resuming the persistent M1–M4 goal, fixing CI first and publishing to main. That session split CI in [a897c68](https://github.com/kurochan001/kirimasim-uvm-tests/commit/a897c6820b037b8fddecfbf7c72c7997bcd075f4) and [42d03ab](https://github.com/kurochan001/kirimasim-uvm-tests/commit/42d03abae20701f344697d13bdca83043c3710f1) and published the 113th expansion in [f94ba4a](https://github.com/kurochan001/kirimasim-uvm-tests/commit/f94ba4ab94a67d5e9eeb2fcaf7e19a57b4596cc4). The first Regression then showed that hosted runners lacked the z3 constraint solver; the session installed it in the setup action and published the 114th expansion in [db06513](https://github.com/kurochan001/kirimasim-uvm-tests/commit/db06513ce8c467d7a2e87e972beae496ff73c828). It then published the 115th expansion in the commit that carries this text. **The goal remains open; it is not complete.**

Inspect the actual branch and working tree before editing. All native measurements of the 115th expansion have terminated.

Read the current workspace instructions first. The user's agent instructions reference `RTK.md`; resolve it in the current environment. No private configuration or absolute user path belongs in published files.

## What is complete, and what remains

The three generated queues are 0: unlinked tests, requirements without direct tests, and unassessed catalog identifiers. **Zero actual remaining work has not been demonstrated.** The catalog contains 2507 identifiers: 2062 partial and 445 assessed. Scope is proposed, completeness is false, the approved denominator and coverage percentage are null, and human review is unrecorded. Original M1–M4 targets and remaining normative applicability conditions stay open; [the requirements guide](requirements.md) explains these distinct measures.

- Tests: 2735 = 2636 simulation + 99 elaboration, across 22 directories. M1: 1171 (1090/81); M2: 624 (617/7); M3: 940 (929/11).
- AI duties: 4109, all directly linked to 2679 tests; 56 tests are control-only. No human review is claimed.
- Ordinary passing inputs: 2277 = 2183 runtime matches at seeds 1/73 + 94 expected compiler rejections.
- Known differences: 458 = 318 runtime differences + 135 simulation build failures + 5 illegal compile acceptances. A failed first seed does not establish a second-seed result.
- Guest evidence: 1081 compatible records; 1654 unmeasured inputs (1650 additions and 4 revised originals). No guest run occurred in expansions 112 to 115. Previously used temporary private executable/profile snapshots are unavailable; obtain authorized local configuration before measuring guests.
- Candidate placement: 1170 have no primary test, 768 have one, and 544 have at least two. These counts do not prove clause coverage or independent passing checks.

Additional HDL-backend and command-line checks have separate execution conditions; see [results](results.md) and [testing](testing.md). Do not add their counts to ordinary totals without checking scope.

## CI state

Hosted CI had not finished a Verilator selection since 2026-10-31: the single Check ran everything on each push with cancel-in-progress, and its one uninterrupted 8-shard run reached the 150-minute limit on every shard. [The CI section](results.md#continuous-integration) describes the replacement and the solver fix.

- [Check](../.github/workflows/check.yml) runs tools, metadata, library and ledger checks plus the tagged checks whose inputs changed and one canary ([the selection tool](../tools/ci_select.py)). It succeeded on 42d03ab ([run 42359747127](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42359747127), canary only) and on f94ba4a ([run 42360326889](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42360326889), the four 113th inputs and the canary). Neither selection randomizes.
- [Regression](../.github/workflows/regression.yml) runs all tagged checks in 20 shards, four at a time with 360 minutes each, plus the 17 command-line checks, manually and weekly. Its first dispatch, [run 42359747603](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42359747603) on 42d03ab, was cancelled after the command-line job (success) and shards 0, 2 and 3 (334 of 342 matched). All eight differences depend on constrained randomization: the image had no SMT solver on the path. Removing z3 locally reproduced the four differences checked. That run is not a Regression result for any commit.
- The [setup action](../.github/actions/setup-verilator/action.yml) now installs z3 in every job and prints its version. The Check for [db06513](https://github.com/kurochan001/kirimasim-uvm-tests/commit/db06513ce8c467d7a2e87e972beae496ff73c828), [run 42371357208](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42371357208), installed z3 4.8.12 and matched its five selected checks, including the two request profiles that randomize an allocation policy.
- Regression was dispatched again on db06513 as [run 42372122368](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42372122368); it was still running when the 115th text was written, so no Regression result is claimed. The 115th commit was published after checking that run; read its outcome with `gh run list --workflow regression.yml`. If a shard times out or fails, investigate before publishing more tests.
- A ten-concurrent dispatch was cancelled earlier because it filled the account's shared hosted job slots and delayed other repositories. Keep Regression's concurrency modest and do not overlap full runs.

## Preserve these decisions

- Derive independent expectations from the user-provided IEEE standards. The ignored local PDFs are `IEEE_Std_1800.2-2020.pdf` and `IEEE_Std_1800-2023_SystemVerilog.pdf`; they are absent from a fresh clone and must not be redistributed. Do not copy standard prose, figures or examples into tests or documentation.
- Never use commercial simulator results, output or diagnostics, including anonymized or third-party material. Never read GPL/LGPL simulator implementation source. Follow [provenance](provenance.md) and [submission policy](faq.md#commercial-simulator-and-issue-reporting-policy).
- Pinned Apache UVM source can explain a difference after the standard-derived oracle is frozen; it does not define the expected result. Preserve valid spec-only differences and qualified interpretations. Never change an expectation merely to match observed output; disclose and archive any pre-tag revision.
- Keep Ghost's real identity, version, executable/profile paths, profile contents and raw diagnostics private. Keep PDFs, fetched library source, logs, private settings and generated scratch files out of Git.
- Maintain complete English/Japanese pairs. README describes the current state; [history](history.md) records past increments. Preserve the recent reader explanations and links, historical FAQ checkpoints, AI review status and existing evidence identity.
- Do not change `tools/run_verilator.py`, `tools/suite_results.py` or `tools/uvm_common.py` casually: they form the runner fingerprint, and changing them invalidates every stored record. `tools/ci_select.py` and the workflow files are outside it.

## The latest implementation and its limits

Expansion 115 added four M3 profiles under `tests/u18/`, sharing `tests/u18/helpers115_mam_reconfigure/reconfigure115.svh`. A manager holding region 12..15 is reconfigured from 8..23 to 4..27 or from 4..27 to 8..23; afterwards reservations or fixed-start requests at each new edge must succeed with exact geometry and those just outside each new bound must be rejected. The request profiles also check, in pre_randomize, that min_offset, max_offset and len present the new bounds. The first freeze did not build because a policy handle used the reserved word `before`; only the two handle names changed, and the unbuilt inputs are archived under `out/thin-one-hundred-fifteenth-before-identifier-fix/`. New duties are `UVM-MAM-AUDIT-RECONFIGURED-BOUNDS-RESERVE`, `-BOUNDS-REQUEST`, `-POLICY-MINIMUM` and `-POLICY-MAXIMUM`; see [the reconfiguration FAQ](faq.md#q432-what-do-the-reconfigured-bounds-profiles-check). The 112th setter-order duty's limitations now record an AI re-review: the 12.3.4.2.6 note supports the virtual-visit reading but is informative, so the two observed profiles stay known pending human review.

Expansion 114 added four M3 profiles under `tests/u18/`, sharing `tests/u18/helpers114_mam_stale_source/stale_source114.svh`. The stale descriptor comes from request_region (released through the manager or its region facade) or from a dynamic virtual-register array (implemented or allocated, then released with the virtual-register method). Each keeps a peer reservation, reuses the freed range, then releases the saved descriptor through the manager; 18.12.5.3 requires an error. For virtual-register regions the stale call is made only after the array is unimplemented, a stated interpretation, because 18.9.1.1.4 and 18.9.1.1.5 direct release through the virtual-register method. Only the presence of an error is checked.

The first freeze also asserted the region-owner query in the virtual-register setup row. Both virtual-register inputs differed only there, reproducing the existing 18.12.7.2.7 owner known difference, while the request inputs matched. That query became a DIAG114 row, the getter identity stayed asserted and expected files are unchanged; the first-freeze inputs and batches are archived under `out/thin-one-hundred-fourteenth-before-owner-split/`. The revised inputs match seeds 1/73 before and after tagging. New duties are `UVM-MAM-AUDIT-STALE-REQUEST-DESCRIPTOR-RELEASE-ERROR`, `UVM-VREG-AUDIT-STALE-REGION-MANAGER-RELEASE-ERROR` and `UVM-VREG-AUDIT-RELEASE-KEEPS-PEER-RESERVATION`; `UVM-MAM-AUDIT-REGION-RELEASE` gained the requested region-facade profile. See [the source FAQ](faq.md#q430-what-do-the-stale-descriptor-source-profiles-add).

The 113th limit stays: no stale call is made while the same range is reserved again, because 18.12.7 does not state whether a later reservation returns a new descriptor instance. A manager release of a region that still implements a virtual-register array is not checked. The 112th unpack interpretation remains qualified: whether the listed setters require actual virtual visits, including empty arrays, still needs review, and the two observed profiles stay known. Other open interpretations include physical address translation, automatic recording with storage disabled or mutated, exact event-delta applicability, and cancellation of otherwise activated or suspended waiters. The [detailed handoff](handoff.md) retains the surrounding conditions and older valid differences.

## Local artifacts

The ignored `out/` directory is optional local evidence, not a tracked source of truth. It may be absent after cloning. On this host, the 115th-expansion files are:

```text
out/thin-one-hundred-fifteenth-pretag-freeze.json
out/thin-one-hundred-fifteenth-verilator-pretag.json
out/thin-one-hundred-fifteenth-verilator-final.json
out/thin-one-hundred-fifteenth-verilator-combined.json
out/thin-one-hundred-fifteenth-evidence-scope.json
out/thin-one-hundred-fifteenth-inventory.json
out/thin-one-hundred-fifteenth-backlog.json
out/thin-one-hundred-fifteenth-doc-contents-effective.json
out/thin-one-hundred-fifteenth-before-identifier-fix/
```

The 114th files keep the same names with `fourteenth`, plus `out/thin-one-hundred-fourteenth-regression-42359747603.json` and `out/thin-one-hundred-fourteenth-before-owner-split/`.

Guest records remain the 112th files listed in [the detailed handoff](handoff.md#evidence-and-latest-differences). `out/thin-one-hundred-fifteenth-generator-used.py`, `-ledger-used.py` and `-docs-used.py`, and the 114th scripts of the same form, are the scripts actually used; their guards refer to earlier commits and document text, so do not rerun them. For later document updates, start from the effective snapshot and the current tracked files. Preserve existing index order when appending records, and check input, runner, library and simulator fingerprints before carrying evidence forward; [evidence assembly](results.md#evidence-assembly) gives the rules.

## Next candidates

These are suggestions, not approved scope. Regenerate the backlog before choosing.

- Review [run 42372122368](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42372122368) first; it is the first full hosted result with the solver.
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

> Read the current workspace instructions, README and both Claude Code handoff files. Verify main, the working tree, the latest Check run and the latest Regression run (42372122368 or later), the first dispatched after the z3 solver fix. Continue the open M1–M4 goal only as authorized by the user. The three generated queues are zero, but 2062 partial identifiers and original milestone targets remain; zero actual gaps is unproven. Audit a meaningful remaining condition against the local IEEE standards and avoid duplicating existing tests. Preserve independent expectations, qualified known differences, compatible evidence, the runner fingerprint, commercial-result exclusion, Ghost privacy and complete bilingual documentation. Do not replay completed scratch scripts. Measure final inputs, run appropriate checks, report limitations and publish to main as authorized. Do not manufacture review, scope approval, passing results or goal completion.
