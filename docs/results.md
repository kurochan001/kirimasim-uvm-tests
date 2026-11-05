# Current results and measurement methodology

[日本語](results.ja.md) · [README](../README.md) · [Known differences](known-differences.md)

## Current snapshot

Runtime matches, compiler rejections and unmeasured inputs describe different execution conditions; [Read a result](reading-guide.md#read-a-result) explains how to read the counts together.

The Verilator snapshot assembled on 2026-11-06 covers all 2266 current tests.
Guest records retain 1082 compatible current inputs; 1184 inputs are
unmeasured, including three revised old inputs. Each record
fingerprints its inputs and conditions.
The suite has 2266 fixtures in 21 directories: 2174 simulation and 92
elaboration. Milestone totals are M1 982 (903/79), M2 547 (542/5) and M3 737
(729/8), with runtime/elaboration counts in parentheses. All use `spec_check: ai`;
none records human review. Of 2237 no-DPI fixtures, 92 are illegal elaboration
checks. The eleven HDL-DPI and eighteen command-line/regex-DPI runtime fixtures
remain separate.

Counts do not establish a reviewed coverage percentage.

Backend rows revisit inputs already included in the ordinary row under different conditions; [the execution setup](testing.md#the-uvm-library) explains why their results are counted separately.

| Simulator and library | Observation | Execution scope |
| --- | --- | --- |
| Verilator 5.052, pinned UVM | 1936 `pass`: 1849 runtime + 87 compile rejection; 330 `known` | Runtime matches use seeds 1/73; expected compiler rejections execute no runtime seed |
| Verilator 5.052, original VPI HDL backend | 10 `pass`; 1 `fail` | Separate overlapping 11-case condition; matches at seeds 1/73, difference at seed 1 |
| Verilator 5.052, original command-line VPI bridge and pinned regex DPI | 17 `pass`; 1 `known` | Separate overlapping 18-case condition; matches at seeds 1/73, difference at seed 1 |
| kirimasim, pinned UVM | 1073 `unsupported`; nine `fail` | 1082 unchanged inputs; 1184 inputs unmeasured |
| Ghost, bundled UVM | 206 `pass`; 876 `fail` | 1082 unchanged inputs at each seed; identical failing sets; 1184 inputs unmeasured |
| Ghost, pinned UVM | Not measured for the current executable snapshot | No current pinned-mode claim |

The pinned library is Accellera UVM 2020.3.1, commit `78c06547a2a0`, with
326 files checked against [the lock](../third_party/uvm.lock). A Ghost bundled
run uses the supplied library rather than that lock's package. Private
simulator identity, version, paths, profile contents and diagnostics are
not published. [Ghost setup](testing.md#ghost) describes the public interface.
Icarus Verilog is not used for this UVM suite.

## Interpretation

A build failure stops before simulation, while a runtime difference comes from an executed model; [Q14](faq.md#q14-do-two-seeds-prove-determinism-or-four-state-correctness) explains which seed results exist in each case.

87 valid negative expectations match by compiler rejection with the
declared fixture/type/member diagnostic. Five illegal designs remain accepted:
subscriber write, visitor visit, proxy get_immediate_children and adapter accept omissions, and direct construction of the
printed virtual builtin dispatcher. They retain the rejection oracle as known
differences without runtime, even when accepted. The 83 unexpected simulation
builds remain separate. A pass requires the declared expectation.

The 330 spec-only cases retain standard-derived output or compile-diagnostic
expectations. Five are illegal compiler acceptances; 325 are simulation cases.
Of these, 242 first differ at runtime seed 1 without seed 73. Twenty-seven cannot build
because of missing APIs/type names: one time API, six sequence-library APIs,
four HDL slice cases, one named-concat constructor, five object active-policy API cases,
three catcher message-handle cases, the printed base recording-state getter,
the printed report callback typedef and two builtin type_id cases, plus three typed resource-DB helper cases.

One time-decrement build requires the printed optional secs argument.
Two declaration builds retain incompatible defaults; two retain printed
all_dropped function/task and clone implicit-scalar/map-return conflicts. Two
retain incompatible inherited type_id registry specializations; one retains the
protected memory backdoor_read accessibility difference. Two legal extensions, resource-base and listed-only complete core service,
also require unlisted pure hooks. Another 29 request
unlinked DPI: eleven HDL and eighteen command-line cases. Three additional legal
builds use the literal enum-collection T interpretation. Seven further builds
retain six strict attribute definitions and the printed enum-unpack arity.
Three more builds retain dependent visitor defaults with custom STRUCTURE.
Two qualified virtual-abstraction overview-base inputs retain the wording
conflict; their explicit class-base controls match separately. Two additional
printed dedicated-pool return-type inputs retain the pool/item conflict. These 83
simulation builds have no runtime result. Separate command-line evidence remains
seventeen matches and one quit-warning difference.

The shared-handler reset case retains the severity/ID verbosity value while
general and ID values, action and file return to defaults. The expected reset
and subsequent boundary delivery remain unchanged. This adds one runtime
fixture to the known set; prior severity-override reset differences remain.

The separate VPI condition has eleven HDL fixtures: ten match seeds 1/73.
Three memory fixtures access actual public array cells: inherited base-task
read/write, split 8/16-bit banks forming a 24-bit word, and ROM write versus
poke/read/peek. They verify selected data and neighboring cells through the
unchanged original backend. Derived wrappers reach the inherited implementation
without certifying the separately blocked public-read declaration.

The inaccessible-path sequence still first differs at seed 1, reporting ERROR
rather than warning and attempting reads under the retained E.7 no-transfer
interpretation. The earlier eight HDL input identities and records remain
unchanged. Selected packed cells up to 64 bits and these two-state array cases
do not establish general array/type, vendor-overlay, force/release or four-state
support. Do not add overlapping pass counts to the ordinary total. See
[HDL setup](testing.md#verilator-vpi-hdl-subset) and [known differences](known-differences.md).

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

The snapshot starts from [eb5b929](https://github.com/kurochan001/kirimasim-uvm-tests/commit/eb5b929b837bb160446929ced4a508cc1f388fb7), retains all 2256 ordinary input records
and adds ten simulations on 2026-11-06 JST.

The control inputs below deliberately use different premises, so their matches cannot replace a differing original; [the requirement-link guide](requirements.md#citations-requirements-and-execution-evidence) explains the direct/control distinction.

Ten new printer visibility inputs retain six matches at seeds 1/73 and four
default-peer differences at seed 1 without seed 73. Actual table/tree/line
emitters each exercise eight name/type/size masks, before object sprint or after
collection under the opposite mask. Distinct caller-supplied textual attributes
isolate visibility from numeric size conversion, row grammar, headings, column
order/widths, borders and punctuation. Current values, stale-value absence and
an independent peer are observed.

All selected main visibility/value checks match. Fresh tree/line peers return
type-name and size controls as zero rather than the required one. The two table
default-peer inputs and four separately named, explicitly enabled tree/line peer
controls match both seeds. Controls do not pass the omitted-default inputs; four
fixture differences do not establish four independent defects or assign a cause.

Two new AI duties decompose actual type-name/size emission. The name-emission
and three configuration-getter duties keep stable IDs, statements and old links,
with new conditions and separately identified controls; 3816 other duties remain
unchanged. All 406 classifications and the proposed scope remain unchanged.
16.2.10 stays unassessed: the tabular-format overview does not specify the exact
row/column grammar, and these visibility checks do not close that interpretation.
Global state remains 1963 partial/406 assessed/138 unassessed. Chapter 16 remains
175/32/1, with 279 duties and 186 primary fixtures (177 simulation/9 elaboration).
All partial conditions and original M1–M4 targets remain open.

All 3822 duties have direct links to 2242 tests; 24 others are control-only and
102 have control links. All 2256 prior ordinary inputs/records, 92 compiler
records, compatible guests and both backend snapshots remain unchanged.
Scope, denominator and human review remain unapproved/incomplete.

Retained kirimasim/Ghost records were collected with fixed executable
snapshots and Ghost's seed-specific private profiles.

Commercial simulator results are excluded under the
[reporting policy](faq.md#commercial-simulator-and-issue-reporting-policy).

The earlier temporary kirimasim/Ghost executable/profile snapshots are no
longer available, so no guest rerun is claimed. Historical source files retain
1085 records; earlier filters exclude three revised original inputs: command-enum
citation, Boolean rerandomization and virtual-field configuration citation.
This increment retains the same 1082 compatible records byte-for-byte and adds
ten unmeasured inputs. Ghost remains 206 pass/876 fail per seed; kirimasim
remains 1073 unsupported/nine missing-API failures. The 1184 unmeasured inputs
are 1181 additions and three revised originals. No guest improvement or regression
is measured. Earlier filter provenance remains in
`out/thin-seventy-first-guest-exclusions.json`; the current input scope is in
`out/thin-seventy-fifth-evidence-scope.json`.

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
  their declared 1082-case subset; 1184 input IDs remain unmeasured.
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

The [draft ledger](requirements.md) has 3822 AI duties and 138 unassessed
identifiers: 1963 partial/406 assessed. Chapter 10 is 87/29/0; chapter 18 is
360/51/45. Their partial contracts and original targets remain open. Direct
links cover 2242 tests; 24 others have only controls. Guests retain 1082
compatible inputs; 1184 (1092 simulation/92 elaboration), including three
revised originals, are unmeasured. Scope and denominator remain unapproved.

## Reproducing and retaining results

The JSON output is a local record of a selected run, and [Q10](faq.md#q10-where-is-nightly-or-the-public-results-dashboard) explains how it relates to the public Check badge.

Historical `out/` files may be absent in a fresh clone, so [the local-material guide](handoff.md#files-and-local-material) distinguishes reproducible tracked commands from optional measurement artifacts.

The [testing guide](testing.md#running-the-suite) documents the commands,
profile modes and library settings. Request `--json out/<name>.json` to retain
statuses, reasons, configuration and fingerprints. `out/` is ignored by Git,
and Check does not publish these local evidence files. A result from different
inputs, a different runner, executable, profile or library is a separate condition.

## Continuous integration

CI shards divide the existing test set without changing its expectations; [Q268. Does dividing Check into shards reduce the required test scope?](faq.md#q268-does-dividing-check-into-shards-reduce-the-required-test-scope) explains the relationship to the badge and local measurements.

[Check](../.github/workflows/check.yml) runs on pushes to `main`, pull requests
and manual dispatch. It checks pinned-library integrity, 110 tool unit tests,
2266 metadata records and the draft ledger/index. Its 1936 tagged ordinary
Verilator checks comprise 1849 runtime cases at seeds 1/73 and 87 compiler
rejections without runtime seeds, plus seventeen
explicit command-line checks under their separate condition.
The previous unsharded [Check run](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/41976785278)
exceeded the configured 150-minute job limit. The current workflow partitions
the current 1936 tagged checks into 8 disjoint shards (242/242/242/242/242/242/242/242),
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
