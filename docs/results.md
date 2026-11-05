# Current results and measurement methodology

[日本語](results.ja.md) · [README](../README.md) · [Known differences](known-differences.md)

## Current snapshot

Runtime matches, compiler rejections and unmeasured inputs describe different execution conditions; [Read a result](reading-guide.md#read-a-result) explains how to read the counts together.

The Verilator snapshot assembled on 2026-11-06 covers all 2246 current tests.
Guest records retain 1082 compatible current inputs; 1164 inputs are
unmeasured, including three revised old inputs. Each record
fingerprints its inputs and conditions.
The suite has 2246 fixtures in 21 directories: 2154 simulation and 92
elaboration. Milestone totals are M1 962 (883/79), M2 547 (542/5) and M3 737
(729/8), with runtime/elaboration counts in parentheses. All use `spec_check: ai`;
none records human review. Of 2217 no-DPI fixtures, 92 are illegal elaboration
checks. The eleven HDL-DPI and eighteen command-line/regex-DPI runtime fixtures
remain separate.

Counts do not establish a reviewed coverage percentage.

Backend rows revisit inputs already included in the ordinary row under different conditions; [the execution setup](testing.md#the-uvm-library) explains why their results are counted separately.

| Simulator and library | Observation | Execution scope |
| --- | --- | --- |
| Verilator 5.052, pinned UVM | 1920 `pass`: 1833 runtime + 87 compile rejection; 326 `known` | Runtime matches use seeds 1/73; expected compiler rejections execute no runtime seed |
| Verilator 5.052, original VPI HDL backend | 10 `pass`; 1 `fail` | Separate overlapping 11-case condition; matches at seeds 1/73, difference at seed 1 |
| Verilator 5.052, original command-line VPI bridge and pinned regex DPI | 17 `pass`; 1 `known` | Separate overlapping 18-case condition; matches at seeds 1/73, difference at seed 1 |
| kirimasim, pinned UVM | 1073 `unsupported`; nine `fail` | 1082 unchanged inputs; 1164 inputs unmeasured |
| Ghost, bundled UVM | 206 `pass`; 876 `fail` | 1082 unchanged inputs at each seed; identical failing sets; 1164 inputs unmeasured |
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

The 326 spec-only cases retain standard-derived output or compile-diagnostic
expectations. Five are illegal compiler acceptances; 321 are simulation cases.
Of these, 238 first differ at runtime seed 1 without seed 73. Twenty-seven cannot build
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

The snapshot starts from [92a85d8](https://github.com/kurochan001/kirimasim-uvm-tests/commit/92a85d88963935846643688e76edc20cc5f7da6f), retains all 2222 ordinary input records
and adds twenty-four simulations on 2026-11-06 JST.

The control inputs below deliberately use different premises, so their matches cannot replace a differing original; [the requirement-link guide](requirements.md#citations-requirements-and-execution-evidence) explains the direct/control distinction.

Twenty-four new canonical bus-operation fixtures independently measure reads
and writes of a full register or first memory location. Profiles use 64 bits on
a 64-bit bus, 64 bits on a 32-bit bus, or 48 bits on a 32-bit bus, under both
endian settings. Twelve little-endian inputs match seeds 1 and 73; twelve
big-endian inputs retain value differences at seed 1 without seed 73. No new
build difference or compiler-rejection case is added.

An original numeric-word adapter records the canonical descriptor on entry to
reg2bus, before encoding a testbench item. Independent read storage is preseeded;
bus2reg counts in-place return conversions, not separate driver response packets.
Completed observer copies are sorted by address, without constraining temporal
bus order. Only declared data bits are checked. Single-word big-endian values
reverse bytes in the selected observations; split big-endian profiles have zero
selected write portions or returned values. Correct counts/widths do not pass a
complete input with differing data. These are twelve fixture differences, not
twelve proven independent bugs or a confirmed simulator/library attribution.

Five new bilingual AI duties partially decompose 19.1.2. One existing duty,
UVM-MEMORY-PARTIAL-BEAT-WIDTH, keeps its ID, statement, old links and qualifications
while adding the new register/memory conditions and width observations. Its
sub-byte 20-bit interpretation remains open. Of 3810 earlier duties, 3809 remain
unchanged and one is reassessed. No classification is added. Global state is
1963 partial/405 assessed/139 unassessed (279 structural/126 contextual).
Chapter 19 is 82/24/5, with 188 duties and 132 primary fixtures (127 simulation,
5 elaboration). Its pending-transaction, parent-sequence and HDL force/release
contracts, all partial obligations and original targets remain open.

All 3815 duties have direct links to 2222 tests; 24 other tests have only controls,
and 98 have control links. Eight single-cycle inputs also control the split-count
premise: four match both seeds and four remain known; each has its own direct
duty. No control replaces the split inputs. All 2222 prior ordinary inputs/records,
92 compiler records, compatible guests and both backend snapshots remain
unchanged. Builtin TLM payload byte conversion, external RTL, four-state data,
byte enables, arbitrary memory strides and protocol/timing remain separate.
Scope, denominator and human review remain unapproved/incomplete.

Supporting references were aligned with the actual setup/API calls, including
register write at 18.4.4.9 after an incorrect getter reference at 18.4.4.3.
Bodies, helpers, expected output and the tag partition stay unchanged. All 24
post-correction sources are freshly measured; earlier records keep their original
input identities and are archived rather than relabeled. See [Q293](faq.md#q293-why-remeasure-after-correcting-only-supporting-citations).

Retained kirimasim/Ghost records were collected with fixed executable
snapshots and Ghost's seed-specific private profiles.

Commercial simulator results are excluded under the
[reporting policy](faq.md#commercial-simulator-and-issue-reporting-policy).

The earlier temporary kirimasim/Ghost executable/profile snapshots are no
longer available, so no guest rerun is claimed. Historical source files retain
1085 records; earlier filters exclude three revised original inputs: command-enum
citation, Boolean rerandomization and virtual-field configuration citation.
This increment retains the same 1082 compatible records byte-for-byte and adds
twenty-four unmeasured inputs. Ghost remains 206 pass/876 fail per seed; kirimasim
remains 1073 unsupported/nine missing-API failures. The 1164 unmeasured inputs
are 1161 additions and three revised originals. No guest improvement or regression
is measured. Earlier filter provenance remains in
`out/thin-seventy-first-guest-exclusions.json`; the current input scope is in
`out/thin-seventy-second-evidence-scope.json`.

The fingerprints identify different inputs:

SHA-256 is a digest of recorded content, and [the fingerprint glossary](glossary.md#execution-and-result-records) explains why matching one digest alone does not establish the same execution conditions.

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
  their declared 1082-case subset; 1164 input IDs remain unmeasured.
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

The [draft ledger](requirements.md) has 3815 AI duties and 139 unassessed
identifiers: 1963 partial/405 assessed. Chapter 10 is 87/29/0; chapter 18 is
360/51/45. Their partial contracts and original targets remain open. Direct
links cover 2222 tests; 24 others have only controls. Guests retain 1082
compatible inputs; 1164 (1072 simulation/92 elaboration), including three
revised originals, are unmeasured. Scope and denominator remain unapproved.

## Reproducing and retaining results

The JSON output is a local record of a selected run, and [Q10](faq.md#q10-where-is-nightly-or-the-public-results-dashboard) explains how it relates to the public Check badge.

The [testing guide](testing.md#running-the-suite) documents the commands,
profile modes and library settings. Request `--json out/<name>.json` to retain
statuses, reasons, configuration and fingerprints. `out/` is ignored by Git,
and Check does not publish these local evidence files. A result from different
inputs, a different runner, executable, profile or library is a separate condition.

## Continuous integration

CI shards divide the existing test set without changing its expectations; [Q268. Does dividing Check into shards reduce the required test scope?](faq.md#q268-does-dividing-check-into-shards-reduce-the-required-test-scope) explains the relationship to the badge and local measurements.

[Check](../.github/workflows/check.yml) runs on pushes to `main`, pull requests
and manual dispatch. It checks pinned-library integrity, 110 tool unit tests,
2246 metadata records and the draft ledger/index. Its 1920 tagged ordinary
Verilator checks comprise 1833 runtime cases at seeds 1/73 and 87 compiler
rejections without runtime seeds, plus seventeen
explicit command-line checks under their separate condition.
The previous unsharded [Check run](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/41976785278)
exceeded the configured 150-minute job limit. The current workflow partitions
the current 1920 tagged checks into 8 disjoint shards (240/240/240/240/240/240/240/240),
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
