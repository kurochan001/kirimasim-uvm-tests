# Claude Code handoff

[日本語](claude-code-handoff.ja.md) · [README](../README.md) · [Detailed handoff](handoff.md)

## Start here

Prepared on 2026-11-07 because the user has 1% quota remaining and requested a handoff, commit and push. The persistent M1–M4 goal is **paused at the user's request**; this handoff does not resume it or declare it complete. The next agent should continue implementation when the user requests resumption. This publication changes documentation only.

The last implementation checkpoint is [ba28ff5](https://github.com/kurochan001/kirimasim-uvm-tests/commit/ba28ff5eb4abed79b6b0a1c752e0213a9b6a685f), the published 112th expansion, on main. The handoff commit follows that checkpoint; inspect the actual branch and working tree before editing. All native measurements from that expansion have terminated; no 113th measurement was started.

Read the current workspace instructions first. The user's agent instructions reference `RTK.md`; resolve it in the current environment. No private configuration or absolute user path belongs in published files.

## What is complete, and what remains

The three generated queues are 0: unlinked tests, requirements without direct tests, and unassessed catalog identifiers. **Zero actual remaining work has not been demonstrated.** The catalog contains 2507 identifiers: 2062 partial and 445 assessed. Scope is proposed, completeness is false, the approved denominator and coverage percentage are null, and human review is unrecorded. Original M1–M4 targets and remaining normative applicability conditions stay open; [the requirements guide](requirements.md) explains these distinct measures.

- Tests: 2723 = 2624 simulation + 99 elaboration, across 22 directories. M1: 1171 (1090/81); M2: 624 (617/7); M3: 928 (917/11).
- AI duties: 4101, all directly linked to 2667 tests; 56 tests are control-only. No human review is claimed.
- Ordinary passing inputs: 2265 = 2171 runtime matches at seeds 1/73 + 94 expected compiler rejections.
- Known differences: 458 = 318 runtime differences + 135 simulation build failures + 5 illegal compile acceptances. A failed first seed does not establish a second-seed result.
- Guest evidence: 1081 compatible records; 1642 unmeasured inputs (1638 additions and 4 revised originals). No new guest run occurred in expansion 112. Previously used temporary private executable/profile snapshots are unavailable; obtain authorized local configuration before measuring guests.
- Candidate placement: 1170 have no primary test, 768 have one, and 544 have at least two. These counts do not prove clause coverage or independent passing checks.

Additional HDL-backend and command-line checks have separate execution conditions; see [results](results.md) and [testing](testing.md). Do not add their counts to ordinary totals without checking scope.

## Preserve these decisions

- Derive independent expectations from the user-provided IEEE standards. The ignored local PDFs are `IEEE_Std_1800.2-2020.pdf` and `IEEE_Std_1800-2023_SystemVerilog.pdf`; they are absent from a fresh clone and must not be redistributed. Do not copy standard prose, figures or examples into tests or documentation.
- Never use commercial simulator results, output or diagnostics, including anonymized or third-party material. Never read GPL/LGPL simulator implementation source. Follow [provenance](provenance.md) and [submission policy](faq.md#commercial-simulator-and-issue-reporting-policy).
- Pinned Apache UVM source can explain a difference after the standard-derived oracle is frozen; it does not define the expected result. Preserve valid spec-only differences and qualified interpretations. Never change an expectation merely to match observed output.
- Keep Ghost's real identity, version, executable/profile paths, profile contents and raw diagnostics private. Keep PDFs, fetched library source, logs, private settings and generated scratch files out of Git.
- Maintain complete English/Japanese pairs. README describes the current state; [history](history.md) records past increments. Preserve the recent reader explanations and links, historical FAQ checkpoints, AI review status and existing evidence identity.

## The latest implementation and its limits

Expansion 112 added four M2 independent payload-unpack profiles under `tests/u12/`, sharing `tests/u12/helpers112_unpack/payload_unpack112.svh`. Two plain-target final-tagged tests match both seeds. Two observed-target tests remain known differences at seed 1, normal exit 0, with no seed 73. Only UT rows 6/12, the first-setter-visit trace, differ; the other ten rows match. Diagnostic counts are not oracles.

Public typed packer inputs are independent of payload packing. Direct setter calibration is separate from inherited unpack. The interpretation that the listed setters require actual virtual visits remains qualified, including empty arrays. The fixtures check associated serialized active lengths, not unused retained capacity or the complete current-size wording. Empty IGNORE payloads are unsubmitted serialization cases, not live zero-length transfer evidence. See [the completion FAQ](faq.md#q427-do-the-unpack-profiles-complete-the-payload-clause).

After freezing expectations and finishing measurements, the locked Apache payload unpack body and unpack macros were inspected. Their direct member assignments are consistent with the missing setter visits; they do not settle the IEEE interpretation. Do not promote these tests to pass on that basis.

Other open interpretations include physical address translation, automatic recording with storage disabled or mutated, exact event-delta applicability, and cancellation of otherwise activated or suspended waiters. The [detailed handoff](handoff.md) retains the surrounding conditions and older valid differences.

## Local artifacts and the unexecuted proposal

The ignored `out/` directory is optional local evidence, not a tracked source of truth. It may be absent after cloning. On this host, inspect these 112th-expansion files before reusing any record:

```text
out/thin-one-hundred-twelfth-publication.json
out/thin-one-hundred-twelfth-resume-state.json
out/thin-one-hundred-twelfth-next-audit-observations.json
out/thin-one-hundred-twelfth-audit.json
out/thin-one-hundred-twelfth-evidence-scope.json
out/thin-one-hundred-twelfth-verilator-combined.json
out/thin-one-hundred-twelfth-post-measurement-library-diagnostic.json
out/thin-one-hundred-twelfth-doc-contents-effective.json
```

Do not rerun completed 112th-expansion generators, ledger installers, assemblers, documentation mutators or prepublication audits: their guards and baselines refer to the previous checkpoint. For later document updates, inspect the effective document snapshot and current tracked files rather than replaying the raw document mutator, which would lose later manual corrections. Preserve existing index order when appending records. Check input, runner, library and simulator fingerprints before carrying evidence forward; [evidence assembly](results.md#evidence-assembly) describes the compatibility rules.

Only `out/thin-one-hundred-thirteenth-generate.py` was drafted for the next expansion. **It has not been executed or validated**: no 113th tests, expectations, ledger updates or measurements exist. Do not treat that generator as approved test content or run it during the pause.

Its proposed M3 topic is releasing stale memory-manager descriptors after bulk release or region-facade release, then applying the manager release operation. Review IEEE 18.12.5.3 and surrounding context first, and compare existing second-release, foreign-region, bulk-release and region-release tests to avoid duplication. Four proposed profiles combine the two release paths with the first/last allocation-call handle, without assuming iterator order. Complete all valid target-state observations before the invalid call; afterwards, do not inspect or reuse the target manager or descriptors. Later valid checks must use an independent manager. Check that an error occurred rather than asserting an exact report count; keep exact counts diagnostic. This is a proposal for missing applicability conditions, not a way to reduce a placement counter.

## Verify and resume

After the user resumes work, regenerate the backlog, review a real remaining duty against the standards, freeze the independent oracle, measure final inputs, update compatible evidence and both languages, then publish a validated increment. Do not declare the goal complete until actual remaining duties and original milestone targets have been audited. Claude Code does not inherit this conversation's native goal state automatically.

Use Python 3.10 or later. Native reproduction uses Verilator 5.052, a C++ toolchain and make. Fetch the pinned Accellera UVM 2020.3.1 library if absent. These commands are a restart checklist, not checks rerun for this documentation-only handoff:

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
```

The last implementation publication recorded [Check run 42355593581](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42355593581) as queued at 2026-11-07 08:29:08 UTC; this is historical observation, not a success claim. Check the run for the actual current commit. Eight ordinary shards, at most four concurrent, feed the aggregate gate; local passing results do not establish hosted CI success.

## Message to give Claude Code when resuming

> Read the current workspace instructions, README and both Claude Code handoff files. Verify main, the working tree and latest CI. Resume the paused M1–M4 effort only as now authorized by the user. The three generated queues are zero, but 2062 partial identifiers and original milestone targets remain; zero actual gaps is unproven. Audit a meaningful remaining condition against the local IEEE standards, considering the unexecuted stale-descriptor proposal after duplicate review. Preserve independent expectations, qualified known differences, compatible evidence, commercial-result exclusion, Ghost privacy and complete bilingual documentation. Do not replay completed scratch mutators. Measure final inputs, run appropriate checks, report limitations and publish to main as authorized. Do not manufacture review, scope approval, passing results or goal completion.
