# Claude Code handoff

[日本語](claude-code-handoff.ja.md) · [README](../README.md) · [Detailed handoff](handoff.md)

## Start here

Updated on 2026-11-07. A Claude Code session took over from the previous handoff; the user approved resuming the persistent M1–M4 goal, fixing CI first and publishing to main. That session split CI in [a897c68](https://github.com/kurochan001/kirimasim-uvm-tests/commit/a897c6820b037b8fddecfbf7c72c7997bcd075f4) and [42d03ab](https://github.com/kurochan001/kirimasim-uvm-tests/commit/42d03abae20701f344697d13bdca83043c3710f1), then published the 113th expansion in the commit that carries this text. **The goal remains open; it is not complete.**

Inspect the actual branch and working tree before editing. All native measurements of the 113th expansion have terminated.

Read the current workspace instructions first. The user's agent instructions reference `RTK.md`; resolve it in the current environment. No private configuration or absolute user path belongs in published files.

## What is complete, and what remains

The three generated queues are 0: unlinked tests, requirements without direct tests, and unassessed catalog identifiers. **Zero actual remaining work has not been demonstrated.** The catalog contains 2507 identifiers: 2062 partial and 445 assessed. Scope is proposed, completeness is false, the approved denominator and coverage percentage are null, and human review is unrecorded. Original M1–M4 targets and remaining normative applicability conditions stay open; [the requirements guide](requirements.md) explains these distinct measures.

- Tests: 2727 = 2628 simulation + 99 elaboration, across 22 directories. M1: 1171 (1090/81); M2: 624 (617/7); M3: 932 (921/11).
- AI duties: 4102, all directly linked to 2671 tests; 56 tests are control-only. No human review is claimed.
- Ordinary passing inputs: 2269 = 2175 runtime matches at seeds 1/73 + 94 expected compiler rejections.
- Known differences: 458 = 318 runtime differences + 135 simulation build failures + 5 illegal compile acceptances. A failed first seed does not establish a second-seed result.
- Guest evidence: 1081 compatible records; 1646 unmeasured inputs (1642 additions and 4 revised originals). No guest run occurred in expansions 112 or 113. Previously used temporary private executable/profile snapshots are unavailable; obtain authorized local configuration before measuring guests.
- Candidate placement: 1170 have no primary test, 768 have one, and 544 have at least two. These counts do not prove clause coverage or independent passing checks.

Additional HDL-backend and command-line checks have separate execution conditions; see [results](results.md) and [testing](testing.md). Do not add their counts to ordinary totals without checking scope.

## CI state

Hosted CI had not finished a Verilator selection since 2026-10-31: the single Check ran everything on each push with cancel-in-progress, and its one uninterrupted 8-shard run reached the 150-minute limit on every shard. [The CI section](results.md#continuous-integration) describes the replacement.

- [Check](../.github/workflows/check.yml) runs tools, metadata, library and ledger checks plus the tagged checks whose inputs changed and one canary ([the selection tool](../tools/ci_select.py)). [Run 42359747127](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42359747127) on 42d03ab succeeded; it ran only the canary, because that commit changed no test input.
- [Regression](../.github/workflows/regression.yml) runs all tagged checks in 20 shards, four at a time with 360 minutes each, plus the 17 command-line checks, manually and weekly. Its first dispatch, [run 42359747603](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42359747603) on 42d03ab, was still running when this was written, so no Regression result is claimed. The hosted canary took about 2.5 minutes, suggesting roughly 2.2 hours per shard and 11 hours in total; that is an estimate, not a measurement.
- A ten-concurrent dispatch was cancelled because it filled the account's shared hosted job slots and delayed other repositories. Keep Regression's concurrency modest.
- Check the outcome of run 42359747603 first. If a shard times out or fails, investigate before publishing more tests. That run covers 42d03ab; the four 113th tests are covered by Check's changed-input job on the 113th commit and by the local measurements. Dispatch Regression again for a full hosted result on a later commit.

## Preserve these decisions

- Derive independent expectations from the user-provided IEEE standards. The ignored local PDFs are `IEEE_Std_1800.2-2020.pdf` and `IEEE_Std_1800-2023_SystemVerilog.pdf`; they are absent from a fresh clone and must not be redistributed. Do not copy standard prose, figures or examples into tests or documentation.
- Never use commercial simulator results, output or diagnostics, including anonymized or third-party material. Never read GPL/LGPL simulator implementation source. Follow [provenance](provenance.md) and [submission policy](faq.md#commercial-simulator-and-issue-reporting-policy).
- Pinned Apache UVM source can explain a difference after the standard-derived oracle is frozen; it does not define the expected result. Preserve valid spec-only differences and qualified interpretations. Never change an expectation merely to match observed output.
- Keep Ghost's real identity, version, executable/profile paths, profile contents and raw diagnostics private. Keep PDFs, fetched library source, logs, private settings and generated scratch files out of Git.
- Maintain complete English/Japanese pairs. README describes the current state; [history](history.md) records past increments. Preserve the recent reader explanations and links, historical FAQ checkpoints, AI review status and existing evidence identity.
- Do not change `tools/run_verilator.py`, `tools/suite_results.py` or `tools/uvm_common.py` casually: they form the runner fingerprint, and changing them invalidates every stored record. `tools/ci_select.py` is outside it.

## The latest implementation and its limits

Expansion 113 added four M3 stale memory-manager descriptor profiles under `tests/u18/`, sharing `tests/u18/helpers113_mam_stale/stale_release113.svh`: a release of all regions or a region-facade release, crossed with the first or last descriptor in allocation-call order. All four match seeds 1/73 before and after tagging. 18.12.5.3 requires an error for a region that is no longer allocated; only the presence of an error is checked, and DIAG113 counts are diagnostic. After the invalid call the target manager is not inspected; an independent manager supplies later checks.

A variant that releases the stale descriptor while the same range is reserved again was considered and dropped: 18.12.7 does not state whether a later same-range reservation returns a new descriptor instance. The new duty is `UVM-MAM-AUDIT-STALE-DESCRIPTOR-RELEASE-ERROR`; `UVM-MAM-AUDIT-REGION-RELEASE` gained the two region-facade profiles as direct links. `UVM-MAM-RELEASE-ALL-REUSE` was not extended, because its conditions name two specific ranges. See [the completion FAQ](faq.md#q429-do-the-stale-descriptor-profiles-complete-the-release-contract).

The 112th unpack interpretation remains qualified: whether the listed setters require actual virtual visits, including empty arrays, still needs review, and the two observed profiles stay known. Other open interpretations include physical address translation, automatic recording with storage disabled or mutated, exact event-delta applicability, and cancellation of otherwise activated or suspended waiters. The [detailed handoff](handoff.md) retains the surrounding conditions and older valid differences.

## Local artifacts

The ignored `out/` directory is optional local evidence, not a tracked source of truth. It may be absent after cloning. On this host, the 113th-expansion files are:

```text
out/thin-one-hundred-thirteenth-pretag-freeze.json
out/thin-one-hundred-thirteenth-verilator-pretag.json
out/thin-one-hundred-thirteenth-verilator-final.json
out/thin-one-hundred-thirteenth-verilator-combined.json
out/thin-one-hundred-thirteenth-evidence-scope.json
out/thin-one-hundred-thirteenth-inventory.json
out/thin-one-hundred-thirteenth-backlog.json
out/thin-one-hundred-thirteenth-doc-contents-effective.json
```

Guest records remain the 112th files listed in [the detailed handoff](handoff.md#evidence-and-latest-differences). `out/thin-one-hundred-thirteenth-generator-used.py` and `out/thin-one-hundred-thirteenth-docs-used.py` are the scripts actually used; their guards refer to a897c68 and the 112th document text, so do not rerun them. The earlier draft `out/thin-one-hundred-thirteenth-generate.py` was never executed and is superseded. For later document updates, start from the effective snapshot and the current tracked files. Preserve existing index order when appending records, and check input, runner, library and simulator fingerprints before carrying evidence forward; [evidence assembly](results.md#evidence-assembly) gives the rules.

## Next candidates

These are suggestions, not approved scope. Regenerate the backlog before choosing.

- Stale descriptors from request_region and regions implementing virtual registers: read 18.12.5.2 and 18.9.1.1.6 first, compare the existing virtual-register release tests, and keep the descriptor-identity limit above.
- The 112th named-setter question for unpack, reviewed against the standard without promoting the known cases on library evidence.
- Other partial M3 conditions in chapter 18 (393 partial identifiers), and the 2062 partial identifiers overall, compared with the original M1–M3 targets.

## Verify and resume

Before each increment, regenerate the backlog, review a real remaining duty against the standards, freeze the independent oracle, measure the final inputs, update compatible evidence and both languages, then publish. Do not declare the goal complete until actual remaining duties and original milestone targets have been audited. Claude Code does not inherit a conversation's native goal state automatically.

Use Python 3.10 or later. Native reproduction uses Verilator 5.052, a C++ toolchain and make. Fetch the pinned Accellera UVM 2020.3.1 library if absent. A restart checklist:

```sh
git status --short --branch
git log -1 --oneline
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

> Read the current workspace instructions, README and both Claude Code handoff files. Verify main, the working tree, the latest Check run and the outcome of Regression run 42359747603. Continue the open M1–M4 goal only as authorized by the user. The three generated queues are zero, but 2062 partial identifiers and original milestone targets remain; zero actual gaps is unproven. Audit a meaningful remaining condition against the local IEEE standards and avoid duplicating existing tests. Preserve independent expectations, qualified known differences, compatible evidence, the runner fingerprint, commercial-result exclusion, Ghost privacy and complete bilingual documentation. Do not replay completed scratch scripts. Measure final inputs, run appropriate checks, report limitations and publish to main as authorized. Do not manufacture review, scope approval, passing results or goal completion.
