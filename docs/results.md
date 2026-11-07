# Current results and measurement methodology

[日本語](results.ja.md) · [README](../README.md) · [Known differences](known-differences.md)

## Current snapshot

Runtime matches, compiler rejections and unmeasured inputs describe different execution conditions; [Read a result](reading-guide.md#read-a-result) explains how to read the counts together.

The Verilator snapshot assembled on 2026-11-07 covers all 2705 current tests.
Guest records retain 1081 compatible current inputs; 1624 inputs are
unmeasured, including four revised old inputs. Each record
fingerprints its inputs and conditions.
The suite has 2705 fixtures in 22 directories: 2606 simulation and 99
elaboration. Milestone totals are M1 1161 (1080/81), M2 616 (609/7) and M3 928
(917/11), with runtime/elaboration counts in parentheses. All use `spec_check: ai`;
none records human review. Of 2649 no-DPI fixtures, 99 are illegal elaboration
checks. The thirty-eight HDL-DPI and eighteen command-line/regex-DPI runtime fixtures
remain separate.

Counts do not establish a reviewed coverage percentage.

Backend rows revisit inputs already included in the ordinary row under different conditions; [the execution setup](testing.md#the-uvm-library) explains why their results are counted separately.

| Simulator and library | Observation | Execution scope |
| --- | --- | --- |
| Verilator 5.052, pinned UVM | 2249 `pass`: 2155 runtime + 94 compile rejection; 456 `known` | Runtime matches use seeds 1/73; expected compiler rejections execute no runtime seed |
| Verilator 5.052, original VPI HDL backend | 37 `pass`; 1 `fail` | Separate overlapping 38-case condition; matches at seeds 1/73, difference at seed 1 |
| Verilator 5.052, original command-line VPI bridge and pinned regex DPI | 17 `pass`; 1 `known` | Separate overlapping 18-case condition; matches at seeds 1/73, difference at seed 1 |
| kirimasim, pinned UVM | 1072 `unsupported`; nine `fail` | 1081 unchanged inputs; 1624 inputs unmeasured |
| Ghost, bundled UVM | 206 `pass`; 875 `fail` | 1081 unchanged inputs at each seed; identical failing sets; 1624 inputs unmeasured |
| Ghost, pinned UVM | Not measured for the current executable snapshot | No current pinned-mode claim |

The pinned library is Accellera UVM 2020.3.1, commit `78c06547a2a0`, with
326 files checked against [the lock](../third_party/uvm.lock). A Ghost bundled
run uses the supplied library rather than that lock's package. Private
simulator identity, version, paths, profile contents and diagnostics are
not published. [Ghost setup](testing.md#ghost) describes the public interface.
Icarus Verilog is not used for this UVM suite.

## Interpretation

One test may check several observations, and a required mismatch keeps the whole case from passing even when other rows match; [the judgment rules](faq.md#q5-what-do-pass-fail-known-and-unsupported-mean) explain its recorded status.

To investigate an individual row, [Trace a difference](reading-guide.md#trace-a-difference) connects its result JSON to the source, expected observation and runner condition.

If the identifiers are unfamiliar, [the smoke-test example](reading-guide.md#follow-one-test-through-the-files) shows how a result ID, source filename, UVM class and requirement ID relate to one another.

For a runtime output mismatch, `reason` identifies the first differing selected line, so use [the observation rules](testing.md#what-is-observed) to compare it with the declared expected sequence.

A build failure stops before simulation, while a runtime difference comes from an executed model; [Q14](faq.md#q14-do-two-seeds-prove-determinism-or-four-state-correctness) explains which seed results exist in each case.

94 valid negative expectations match by compiler rejection with the
declared fixture/type/member diagnostic. Five illegal designs remain accepted:
subscriber write, visitor visit, proxy get_immediate_children and adapter accept omissions, and direct construction of the
printed virtual builtin dispatcher. They retain the rejection oracle as known
differences without runtime, even when accepted. The 135 unexpected simulation
builds remain separate. A pass requires the declared expectation.

The 456 spec-only cases retain standard-derived output or compile-diagnostic
expectations. Five are illegal compiler acceptances; 451 are simulation cases.
Of these, 316 first differ at runtime seed 1 without seed 73. Forty-three cannot build
because of missing APIs/type names: one time API, fourteen sequence-library APIs,
twelve HDL slice-view cases, one named-concat constructor, five object active-policy API cases,
three catcher message-handle cases, the printed base recording-state getter,
the printed report callback typedef and two builtin type_id cases, plus three typed resource-DB helper cases.

One time-decrement build requires the printed optional secs argument.
Two declaration builds retain incompatible defaults; two retain printed
all_dropped function/task and clone implicit-scalar/map-return conflicts. Two
retain incompatible inherited type_id registry specializations; one retains the
protected memory backdoor_read accessibility difference. Two legal extensions, resource-base and listed-only complete core service,
also require unlisted pure hooks. Another 56 request
unlinked DPI: thirty-eight HDL and eighteen command-line cases. Three additional legal
builds use the literal enum-collection T interpretation. Seven further builds
retain six strict attribute definitions and the printed enum-unpack arity.
Three more builds retain dependent visitor defaults with custom STRUCTURE.
Two qualified virtual-abstraction overview-base inputs retain the wording
conflict; their explicit class-base controls match separately. Two additional
printed dedicated-pool return-type inputs retain the pool/item conflict. These 135
simulation builds have no runtime result. Separate command-line evidence remains
seventeen matches and one quit-warning difference.

One additional legal construction input is rejected as an abstract uvm_vreg_cbs
facade under the pinned virtual declaration; its printed concrete expectation is
retained without runtime.

Four additional bare-packet simulation builds stop at the typed factory result used for predictor type naming; they have no runtime evidence and do not create a mandatory IEEE registration prerequisite.

Two additional simulation builds report unsupported enum methods for the large
flag extension and an undefined UVM_PACKER_MIN_BITS; neither has a runtime result.

The shared-handler reset case retains the severity/ID verbosity value while
general and ID values, action and file return to defaults. The expected reset
and subsequent boundary delivery remain unchanged. This adds one runtime
fixture to the known set; prior severity-override reset differences remain.

The separate VPI condition has thirty-eight fixtures: thirty-seven match both
seeds. Three memory inputs access real array cells through inherited tasks,
split banks and ROM write versus poke; wrappers retain the separate public-read
declaration limitation. Nine primitive force/release inputs check real public
8/40-bit regs/wires and immediate release/read behavior.

Eight new positive-duration force_time inputs observe periods 5/13, interior
force retention, post-period reg/wire state, later updates and dormant/peer
isolation. Calls are sequential in the shared compilation-default time unit;
no exact-expiry ordering, return-time/result or overlapping-argument claim is
made. The backend and both runners are unchanged. Six actual-register inputs cover
public backdoor_read, peek and poke observations for 16/40-bit whole variables
and legal two-variable split references. All thirty-eight current HDL records
are retained unchanged in this increment.

The E.7 inaccessible-path sequence still reports ERROR and attempts reads rather
than the retained warning/no-transfer expectation at seed 1, with no seed 73
result. General types/selects/arrays, cross-unit/rounding, overlapping timed calls,
failure/cancellation and four-state behavior remain open. Do not add overlapping
matches to ordinary results; see [HDL setup](testing.md#verilator-vpi-hdl-subset)
and [known differences](known-differences.md).

kirimasim reports `uvm_object_wrapper` as unsupported on 1072 cases; the other
nine encounter missing library APIs first. Neither category establishes
execution of the UVM behavior beyond those blockers. Ghost's bundled
mismatches do not identify whether the simulator or its library caused them,
and they do not establish results for the pinned library. Ghost's annex E matches cover only the
[RO register skip](../tests/uE/test_single_register_access_sequence_skips_a_readonly_register.sv),
[missing-register-backdoor skip](../tests/uE/test_single_register_access_sequence_skips_a_register_without_a_backdoor.sv) and
[missing-memory-backdoor skip](../tests/uE/test_single_memory_access_sequence_skips_a_memory_without_a_backdoor.sv).
They establish no frontdoor/backdoor transfer behavior.

`known` and `unsupported` are not passes. A command's exit code alone is not
a suite pass count; the [FAQ](faq.md#understanding-a-result) explains status
and exit-code rules. Two seeds do not prove determinism or four-state correctness.

Two additional simulation builds are the conditional B.4 directional type controls, with assignment-type errors and no runtime; [Q392](faq.md#q392-do-the-type-relation-controls-settle-the-b4-base-wording) explains why they do not establish mandatory ancestry or a library-only cause.

## Evidence assembly

This section explains how existing records can support a combined snapshot; for a first local measurement, use [the single-test command](faq.md#q3-how-can-i-run-one-test-first) and [the JSON-reading example](reading-guide.md#open-the-result-json).

A fingerprint identifies the exact inputs behind a reused record, so [Execution and result records](glossary.md#execution-and-result-records) explains why an old match may not apply after an edit.

Here an unmeasured input has no compatible current record, even if an older version was run; [Q15](faq.md#q15-how-do-i-know-whether-an-old-result-still-applies) explains the checks needed before reusing it.

The snapshot starts from [0fcabc4](https://github.com/kurochan001/kirimasim-uvm-tests/commit/0fcabc4f3f4ba715bb7c6ff1627742492194ccc8), retains all 2701 old ordinary records,
and adds four M2 simulation inputs on 2026-11-07 JST.

The profiles below check only their stated conditions, so a match under a different premise cannot pass an original difference; [the requirement-link guide](requirements.md#citations-requirements-and-execution-evidence) explains the recorded direct/control roles.

The 108th expansion adds four M2 recording-disable profiles through the
actual sequencer base API, crossing pull/push traffic and omitted/explicit
driver transaction marks. Each case connects independent selected and peer
sequencers, each with one actual request. Disable is called twice before
worker start and before the gated pull driver's first request; [the effect
FAQ](faq.md#q413-what-do-the-recording-disable-profiles-add-beyond-a-flag-query)
explains why observed traffic and marks add evidence beyond a state query.

All four final tagged inputs match seeds1/73. Without driver marks, selected
begin/end timestamps retain their captured values and neither named event
callback runs. With explicit component begin/end calls, each event callback
runs once at the captured driver mark and transaction times match. Real
original request handles arrive, both producers remain blocked while driver
returns are gated, and both complete after release. Per-driver gates avoid
assuming a relative delivery time or sibling callback order.

Peer begin/end counts produce four DIAG108 rows per seed, eight current rows
in total, with no oracle or requirement link. Peer traffic is checked, but
those diagnostics do not certify default push recording semantics; [the peer
FAQ](faq.md#q414-why-are-peer-event-counts-diagnostic-only)
records the distinction. The separately known printed 15.3.2.23 query input
remains unchanged; no alternate query name is substituted.

Five stable duties expand applicability: sequencer-base disable, transaction
zero/default-time begin/end and their named event notifications. Their old
text and links remain, and all 4091 other old requirement objects and 445
assessments are identical. No per-profile obligation duplicates are added;
[the mapping FAQ](faq.md#q415-why-extend-five-existing-duties-instead-of-adding-four-requirements)
explains the unchanged 4096-draft count. All 2701 old ordinary/index records and
456 known inputs remain. Initial nongated inputs matched both seeds but are
archived and excluded after strengthening the observer; all four gated inputs
were remeasured before tagging. Two pull-header citations were corrected
before any native run, with expectations unchanged throughout.

The suite has 2705 tests, 2649 directly linked tests, 56 control-only and 156
control-linked tests. Ordinary results are 2249 pass (2155 runtime both seeds,
94 compiler rejections) and 456 known (316 runtime seed1, 135 builds,five illegal
acceptances). Guests retain 1081 byte-identical compatible records; 1624 inputs
are unmeasured (1620 additions, four revised originals), with no rerun or new
filter. Primary census is 1172 zero, 771 below-target, 539 at least two; the new
primary focus does not certify independent coverage. All 2062 partial
identifiers, applicability conditions and original targets remain open.
Human review and scope/denominator approval remain unrecorded.

Retained kirimasim/Ghost records were collected with fixed executable
snapshots and Ghost's seed-specific private profiles.

Commercial simulator results are excluded under the
[reporting policy](faq.md#commercial-simulator-and-issue-reporting-policy).

The earlier temporary kirimasim/Ghost executable/profile snapshots are no
longer available, so no guest rerun is claimed. Historical source files retain
1085 records. Earlier filters excluded four revisions: command-enum citation,
Boolean rerandomization, virtual-field configuration and reraise primary citation.
This increment performs no new filtering. All 1081 compatible records and
filter metadata are retained byte-identically. Four additions increase the
unmeasured set to 1624: 1620 additions and four revised originals. Ghost remains
206 pass/875 fail per seed and kirimasim remains 1072 unsupported/nine API failures.
The latest exclusions are recorded in `out/thin-one-hundred-sixth-guest-exclusions.json`;
the current scope is in `out/thin-one-hundred-eighth-evidence-scope.json`.

The fingerprints identify different inputs:

SHA-256 is a digest of recorded content, and [the fingerprint glossary](glossary.md#execution-and-result-records) explains why matching one digest alone does not establish the same execution conditions.

Editing only a requirement's wording calls for a regenerated inventory, while editing a test header changes its test fingerprint and requires compatible execution evidence; [the update procedure](requirements.md#updating-a-test-or-mapping) describes both paths.

| Identity | What it identifies | How to use it |
| --- | --- | --- |
| `inputs_sha256` | Test source, expected files, collected helpers/data and library lock | Compare each record with the current test inputs |
| `runner_sha256` | Selected runner, `suite_results.py` and `uvm_common.py` | Match across batches and require `runner_changed` to be false |
| `ledger_inputs_sha256` | Canonical scope, requirements, assessments, test index and clause catalog | Identify a generated inventory/backlog, separately from simulation evidence |

The [ledger identity](requirements.md#generated-report-identity) belongs to
generated review reports. Matching input/runner hashes still requires checking
simulator, configuration and library identities before reusing execution records.

Before combining records, check that:

- Verilator IDs cover the current suite exactly. Retained guest IDs match
  their declared 1081-case subset; 1624 input IDs remain unmeasured.
- Each record's `inputs_sha256` matches its current source, expected output,
  associated inputs and library lock as collected by the runner.
- Simulator version, configuration and `runner_sha256` match between batches,
  and `runner_changed` is false.
- Every Verilator-tagged case is `pass` and every current untagged case is
  `known` in this snapshot.
- Ghost's two seed runs have the same failing test set.

This is compatible recorded evidence over the current inputs; it does not
claim that a single invocation reran the entire suite. The
[development history](history.md) retains increment counts, measurements,
prior smoke tests and build-change details. Refreshed records replace older
ones only after their current input fingerprints are verified.

The [draft ledger](requirements.md) has 4096 AI duties and 0 unassessed
identifiers: 2062 partial/445 assessed. Chapter 10 is 87/29/0; chapter 18 is
393/63/0. Their partial contracts and original targets remain open. Direct
links cover 2649 tests; 56 others have only controls. Guests retain 1081
compatible inputs; 1624 (1525 simulation/99 elaboration), including four
revised originals, are unmeasured. Scope and denominator remain unapproved.

## Reproducing and retaining results

Writing to the same `--json` path replaces that file, so choose a new filename to retain an earlier run when following [the runner commands](testing.md#running-the-suite).

A rerun creates a new local measurement, and [the result-saving guide](testing.md#running-the-suite) explains how to choose an output JSON for that run.

An entry missing from one JSON file supplies no judgment for that case, so [the JSON-reading example](reading-guide.md#open-the-result-json) explains where to find its status and how to check the selected inputs.

To investigate one listed difference, select its source path with [the single-test command](faq.md#q3-how-can-i-run-one-test-first) and retain the same library and backend conditions as the record.

The JSON output is a local record of a selected run, and [Q10](faq.md#q10-where-is-nightly-or-the-public-results-dashboard) explains how it relates to the public Check badge.

Historical `out/` files may be absent in a fresh clone, so [the local-material guide](handoff.md#files-and-local-material) distinguishes reproducible tracked commands from optional measurement artifacts.

A result test ID is the path below `tests/` without `.sv`, so [the layout guide](testing.md#layout) helps locate the source and its declared expected file from a JSON entry.

The [testing guide](testing.md#running-the-suite) documents the commands,
profile modes and library settings. Request `--json out/<name>.json` to retain
statuses, reasons, configuration and fingerprints. `out/` is ignored by Git,
and Check does not publish these local evidence files. A result from different
inputs, a different runner, executable, profile or library is a separate condition.

## Continuous integration

A commit identifies a repository revision, so check the revision on a linked workflow run before comparing it with your files; [the handoff snapshot guide](handoff.md#snapshot-and-objective) explains how to establish the workspace's starting point.

A shard runs a disjoint subset of the selected tests, and the final gate requires every shard to succeed; [Q268](faq.md#q268-does-dividing-check-into-shards-reduce-the-required-test-scope) explains how that relates to the test scope.

[Check](../.github/workflows/check.yml) runs on pushes to `main`, pull requests
and manual dispatch. It checks pinned-library integrity, 110 tool unit tests,
2705 metadata records and the draft ledger/index. Its 2249 tagged ordinary
Verilator checks comprise 2155 runtime cases at seeds 1/73 and 94 compiler
rejections without runtime seeds, plus seventeen
explicit command-line checks under their separate condition.
The previous unsharded [Check run](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/41976785278)
exceeded the configured 150-minute job limit. The current workflow partitions
the current 2249 tagged checks into 8 disjoint shards (282/281/281/281/281/281/281/281),
with at most 4 concurrent shard jobs. The exact union and absence of duplicates are
verified locally. The 17 command-line checks run once, on shard 0 before
ordinary checks. Seeds 1/73, compiler-rejection judgment, pinned dependencies
and runner fingerprints are unchanged. The existing verilator gate requires
all shards to succeed. Sharding is orchestration; local
validation does not establish a successful hosted workflow result.

It does not run kirimasim, Ghost or spec-only cases. The README's badge is the
live CI state, separate from these local measurements. A green Check does
not establish complete UVM conformance or a passing result for every simulator.
There is no Nightly workflow or automatic result publication.
