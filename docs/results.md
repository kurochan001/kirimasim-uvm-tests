# Current results and measurement methodology

[日本語](results.ja.md) · [README](../README.md) · [Known differences](known-differences.md)

## Current snapshot

Runtime matches, compiler rejections and unmeasured inputs describe different execution conditions; [Read a result](reading-guide.md#read-a-result) explains how to read the counts together.

The Verilator snapshot assembled on 2026-11-07 covers all 2583 current tests.
Guest records retain 1082 compatible current inputs; 1501 inputs are
unmeasured, including three revised old inputs. Each record
fingerprints its inputs and conditions.
The suite has 2583 fixtures in 21 directories: 2484 simulation and 99
elaboration. Milestone totals are M1 1113 (1032/81), M2 586 (579/7) and M3 884
(873/11), with runtime/elaboration counts in parentheses. All use `spec_check: ai`;
none records human review. Of 2527 no-DPI fixtures, 99 are illegal elaboration
checks. The thirty-eight HDL-DPI and eighteen command-line/regex-DPI runtime fixtures
remain separate.

Counts do not establish a reviewed coverage percentage.

Backend rows revisit inputs already included in the ordinary row under different conditions; [the execution setup](testing.md#the-uvm-library) explains why their results are counted separately.

| Simulator and library | Observation | Execution scope |
| --- | --- | --- |
| Verilator 5.052, pinned UVM | 2165 `pass`: 2071 runtime + 94 compile rejection; 418 `known` | Runtime matches use seeds 1/73; expected compiler rejections execute no runtime seed |
| Verilator 5.052, original VPI HDL backend | 37 `pass`; 1 `fail` | Separate overlapping 38-case condition; matches at seeds 1/73, difference at seed 1 |
| Verilator 5.052, original command-line VPI bridge and pinned regex DPI | 17 `pass`; 1 `known` | Separate overlapping 18-case condition; matches at seeds 1/73, difference at seed 1 |
| kirimasim, pinned UVM | 1073 `unsupported`; nine `fail` | 1082 unchanged inputs; 1501 inputs unmeasured |
| Ghost, bundled UVM | 206 `pass`; 876 `fail` | 1082 unchanged inputs at each seed; identical failing sets; 1501 inputs unmeasured |
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
differences without runtime, even when accepted. The 133 unexpected simulation
builds remain separate. A pass requires the declared expectation.

The 418 spec-only cases retain standard-derived output or compile-diagnostic
expectations. Five are illegal compiler acceptances; 413 are simulation cases.
Of these, 280 first differ at runtime seed 1 without seed 73. Forty-three cannot build
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
printed dedicated-pool return-type inputs retain the pool/item conflict. These 133
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

kirimasim reports `uvm_object_wrapper` as unsupported on 1073 cases; the other
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

## Evidence assembly

A fingerprint identifies the exact inputs behind a reused record, so [Execution and result records](glossary.md#execution-and-result-records) explains why an old match may not apply after an edit.

Here an unmeasured input has no compatible current record, even if an older version was run; [Q15](faq.md#q15-how-do-i-know-whether-an-old-result-still-applies) explains the checks needed before reusing it.

The snapshot starts from [37396d5](https://github.com/kurochan001/kirimasim-uvm-tests/commit/37396d52edda0342802becb128c653f8fcce75d1), retains all 2551 ordinary records,
and adds thirty-two runtime inputs on 2026-11-07 JST.

The control inputs below deliberately use different premises, so their matches cannot replace a differing original; [the requirement-link guide](requirements.md#citations-requirements-and-execution-evidence) explains the direct/control distinction.

Thirty-two new M1 runtime inputs cover twelve collection packing/unpacking
macros with two/four unsigned elements. Eight static-array inputs retain
qualified one-way scalar-API observations; twenty-four inputs check compatible
macro pairs, including opaque typed state transfer for unpack-focused inputs.
All final inputs match seeds 1/73. [The collection-macro FAQ](faq.md#collection-macro-values-and-opaque-state)
explains what each profile can establish.

Explicit N sizes are positive constants 9/97 with 109-bit storage and a set
bit outside the selected width. Inferred widths are 13/97. Static arrays use
nonzero ascending/descending ranges; dynamic arrays and queues are nonempty
and pre-sized. Independently chosen source values are restored into sentinel
destinations; shape, unchanged source/marker fields, independent object/policy
peers and a separate seven-bit trailer are observed. Opaque get_packed_bits
state is passed unchanged to set_packed_bits on a fresh, identically typed
compatible policy, and consuming that policy leaves the original unconsumed.
The state length and contents are never interpreted as a wire format.

The initial proposed flat/no-header dynamic-array and queue oracle was too
strong: the collection clauses do not promise an element-only sequence of
primitive operations or a particular length framing. Separately, IEEE
16.5.3.1/.2 leaves exported state length/format unspecified and supplies the
matched typed transfer used by the corrected inputs.
The provisional batch was deliberately stopped after that verified test-premise
error. The sixteen affected proposed inputs were corrected before canonical
indexing, with fresh measurements; completed initial records and inputs are
archived and excluded from UVM difference counts. The pinned Apache UVM macros
were read after the mismatch only to diagnose their length prefix; no header
algorithm or implementation-derived expectation was copied into the tests.
Eight valid static scalar probes retain their independent observations and
also have fresh final records. This is an explicit oracle correction, not a
neutral relabeling of a legitimate known result or reuse of an old fingerprint.

Paired restoration does not independently prove both one-way implementations
or rule out mutually compensating defects. Static scalar probes retain their
qualified interoperability reading. Empty/differently-sized destinations,
automatic allocation, signed/XZ values, invalid N diagnosis, alternate policies,
all error/lifecycle/concurrency conditions and complete framing remain open.
No universal no-header or mandatory length-header representation is asserted.

Twelve AI duties are appended without changing the 4041 prior requirement
objects or 422 assessments. There are 4053 duties, 2529 directly linked tests,
fifty-four control-only tests and 154 control-linked tests. Inventory is 2056
partial/422 assessed/29 unassessed. Annex B is 133/7/4 with 255 duties and 221
primary tests (217 simulation/four elaboration); twelve newly partial clauses
are not complete. Primary-focus identifiers are 1300 and identifiers with any
citation are 2088. All 2551 prior ordinary/index records and the 99 compiler,
38 HDL, 18 command-line and 1082 guest records are retained. Guests have 1501
unmeasured inputs: 1498 additions and three revised originals (1402 simulation/
99 elaboration). Human review, scope/denominator approval and original M1–M4
targets remain open.

Retained kirimasim/Ghost records were collected with fixed executable
snapshots and Ghost's seed-specific private profiles.

Commercial simulator results are excluded under the
[reporting policy](faq.md#commercial-simulator-and-issue-reporting-policy).

The earlier temporary kirimasim/Ghost executable/profile snapshots are no
longer available, so no guest rerun is claimed. Historical source files retain
1085 records; earlier filters exclude three revised original inputs: command-enum
citation, Boolean rerandomization and virtual-field configuration citation.
This increment retains the same 1082 compatible records byte-for-byte and adds
thirty-two unmeasured inputs. Ghost remains 206 pass/876 fail per seed; kirimasim
remains 1073 unsupported/nine missing-API failures. The 1501 unmeasured inputs
are 1498 additions and three revised originals. No guest improvement or regression
is measured. Earlier filter provenance remains in
`out/thin-seventy-first-guest-exclusions.json`; the current input scope is in
`out/thin-ninety-fifth-evidence-scope.json`.

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
  their declared 1082-case subset; 1501 input IDs remain unmeasured.
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

The [draft ledger](requirements.md) has 4053 AI duties and 29 unassessed
identifiers: 2056 partial/422 assessed. Chapter 10 is 87/29/0; chapter 18 is
393/62/1. Their partial contracts and original targets remain open. Direct
links cover 2529 tests; 54 others have only controls. Guests retain 1082
compatible inputs; 1501 (1402 simulation/99 elaboration), including three
revised originals, are unmeasured. Scope and denominator remain unapproved.

## Reproducing and retaining results

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

CI shards divide the existing test set without changing its expectations; [Q268. Does dividing Check into shards reduce the required test scope?](faq.md#q268-does-dividing-check-into-shards-reduce-the-required-test-scope) explains the relationship to the badge and local measurements.

[Check](../.github/workflows/check.yml) runs on pushes to `main`, pull requests
and manual dispatch. It checks pinned-library integrity, 110 tool unit tests,
2583 metadata records and the draft ledger/index. Its 2165 tagged ordinary
Verilator checks comprise 2071 runtime cases at seeds 1/73 and 94 compiler
rejections without runtime seeds, plus seventeen
explicit command-line checks under their separate condition.
The previous unsharded [Check run](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/41976785278)
exceeded the configured 150-minute job limit. The current workflow partitions
the current 2165 tagged checks into 8 disjoint shards (271/271/271/271/271/270/270/270),
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
