# Current results and measurement methodology

[日本語](results.ja.md) · [README](../README.md) · [Known differences](known-differences.md)

## Current snapshot

Runtime matches, compiler rejections and unmeasured inputs describe different execution conditions; [Read a result](reading-guide.md#read-a-result) explains how to read the counts together.

The Verilator snapshot assembled on 2026-11-06 covers all 2283 current tests.
Guest records retain 1082 compatible current inputs; 1201 inputs are
unmeasured, including three revised old inputs. Each record
fingerprints its inputs and conditions.
The suite has 2283 fixtures in 21 directories: 2191 simulation and 92
elaboration. Milestone totals are M1 982 (903/79), M2 547 (542/5) and M3 754
(746/8), with runtime/elaboration counts in parentheses. All use `spec_check: ai`;
none records human review. Of 2245 no-DPI fixtures, 92 are illegal elaboration
checks. The twenty HDL-DPI and eighteen command-line/regex-DPI runtime fixtures
remain separate.

Counts do not establish a reviewed coverage percentage.

Backend rows revisit inputs already included in the ordinary row under different conditions; [the execution setup](testing.md#the-uvm-library) explains why their results are counted separately.

| Simulator and library | Observation | Execution scope |
| --- | --- | --- |
| Verilator 5.052, pinned UVM | 1944 `pass`: 1857 runtime + 87 compile rejection; 339 `known` | Runtime matches use seeds 1/73; expected compiler rejections execute no runtime seed |
| Verilator 5.052, original VPI HDL backend | 19 `pass`; 1 `fail` | Separate overlapping 20-case condition; matches at seeds 1/73, difference at seed 1 |
| Verilator 5.052, original command-line VPI bridge and pinned regex DPI | 17 `pass`; 1 `known` | Separate overlapping 18-case condition; matches at seeds 1/73, difference at seed 1 |
| kirimasim, pinned UVM | 1073 `unsupported`; nine `fail` | 1082 unchanged inputs; 1201 inputs unmeasured |
| Ghost, bundled UVM | 206 `pass`; 876 `fail` | 1082 unchanged inputs at each seed; identical failing sets; 1201 inputs unmeasured |
| Ghost, pinned UVM | Not measured for the current executable snapshot | No current pinned-mode claim |

The pinned library is Accellera UVM 2020.3.1, commit `78c06547a2a0`, with
326 files checked against [the lock](../third_party/uvm.lock). A Ghost bundled
run uses the supplied library rather than that lock's package. Private
simulator identity, version, paths, profile contents and diagnostics are
not published. [Ghost setup](testing.md#ghost) describes the public interface.
Icarus Verilog is not used for this UVM suite.

## Interpretation

One test may check several observations, and a required mismatch keeps the whole case from passing even when other rows match; [the judgment rules](faq.md#q5-what-do-pass-fail-known-and-unsupported-mean) explain its recorded status.

A build failure stops before simulation, while a runtime difference comes from an executed model; [Q14](faq.md#q14-do-two-seeds-prove-determinism-or-four-state-correctness) explains which seed results exist in each case.

87 valid negative expectations match by compiler rejection with the
declared fixture/type/member diagnostic. Five illegal designs remain accepted:
subscriber write, visitor visit, proxy get_immediate_children and adapter accept omissions, and direct construction of the
printed virtual builtin dispatcher. They retain the rejection oracle as known
differences without runtime, even when accepted. The 92 unexpected simulation
builds remain separate. A pass requires the declared expectation.

The 339 spec-only cases retain standard-derived output or compile-diagnostic
expectations. Five are illegal compiler acceptances; 334 are simulation cases.
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
also require unlisted pure hooks. Another 38 request
unlinked DPI: twenty HDL and eighteen command-line cases. Three additional legal
builds use the literal enum-collection T interpretation. Seven further builds
retain six strict attribute definitions and the printed enum-unpack arity.
Three more builds retain dependent visitor defaults with custom STRUCTURE.
Two qualified virtual-abstraction overview-base inputs retain the wording
conflict; their explicit class-base controls match separately. Two additional
printed dedicated-pool return-type inputs retain the pool/item conflict. These 92
simulation builds have no runtime result. Separate command-line evidence remains
seventeen matches and one quit-warning difference.

The shared-handler reset case retains the severity/ID verbosity value while
general and ID values, action and file return to defaults. The expected reset
and subsequent boundary delivery remain unchanged. This adds one runtime
fixture to the known set; prior severity-override reset differences remain.

The separate VPI condition has twenty HDL fixtures: nineteen match seeds 1/73.
Three memory fixtures access actual public array cells: inherited base-task
read/write, split 8/16-bit banks forming a 24-bit word, and ROM write versus
poke/read/peek. Original wrappers reach inherited protected-read implementations
without passing the separately blocked public-read declaration.

Nine force/release inputs add real public forceable 8/40-bit reg and wire
observations, immediate release/read values, later assignment/driver updates
and missing/uninstrumented failure controls. All eleven older sources and
oracles are unchanged, but the declared backend and HDL runner identities
change; all twenty ordinary and HDL inputs are freshly measured.

The inaccessible-path sequence still first differs at seed 1, reporting ERROR
rather than warning and attempting reads under the retained E.7 no-transfer
interpretation. General arrays/selects/types, positive-duration force_time,
vendor overlays and four-state behavior remain open. Do not add overlapping
matches to the ordinary total; see [HDL setup](testing.md#verilator-vpi-hdl-subset)
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

The snapshot starts from [27159dc](https://github.com/kurochan001/kirimasim-uvm-tests/commit/27159dc60e2bf932a2a17faebe843d01fa4b3f80), retains 2263 unaffected ordinary records,
refreshes eleven older inputs and adds nine simulations on 2026-11-06 JST.

The control inputs below deliberately use different premises, so their matches cannot replace a differing original; [the requirement-link guide](requirements.md#citations-requirements-and-execution-evidence) explains the direct/control distinction.

Nine new HDL force/release fixtures match seeds 1 and 73 under the separate VPI
condition. Public forceable 8/40-bit reg and wire signals receive forced values,
opposing procedural or driver updates, plain release and immediate release/read.
Reg values persist until a new procedural assignment; driven wires immediately
return their resolved driver value. Independent unforced peers and missing or
uninstrumented paths distinguish valid calls and declared backend failures.
The original backend uses standard VPI force/release flags and the documented
public capability marker, with no path/value mock or simulator source copy.

Changing the declared backend changes eleven older input fingerprints even
though their sources and expectations are unchanged. All eleven mappings are
reviewed and all twenty ordinary/HDL inputs are freshly measured. Separate HDL
totals are nineteen both-seed matches and the retained E.7 warning/no-transfer
difference at seed 1, without a seed 73 result. All twenty ordinary inputs fail
to link DPI and keep their spec-only build-known status; no backend match
becomes an ordinary-runner pass.

Seven new bilingual AI duties partially decompose 19.6.2.3/.5/.6. Two zero-time
force_time duty limitations retain historical wording and add current backend/
runner identity refresh; their source/oracle and deposit-only premise are
unchanged. The other 3821 earlier duties, all 406 classifications and proposed
scope are unchanged. Global state is 1967 partial/406 assessed/134 unassessed.
Chapter 19 is 86/24/1 with 196 duties and 149 primary fixtures (144 simulation/
5 elaboration); predictor check_phase remains unassessed. Positive-duration
force_time, broader HDL types and all partial obligations remain open.

All 3830 duties link directly to 2259 tests; 24 others remain control-only and
103 have control links. Unaffected 2263 ordinary records, all 92 compiler
records, 18 command-line records and 1082 compatible guest records are retained.
There is no new guest run/filter. Scope, denominator, human review and the
original M1–M4 targets remain unapproved/incomplete.

Retained kirimasim/Ghost records were collected with fixed executable
snapshots and Ghost's seed-specific private profiles.

Commercial simulator results are excluded under the
[reporting policy](faq.md#commercial-simulator-and-issue-reporting-policy).

The earlier temporary kirimasim/Ghost executable/profile snapshots are no
longer available, so no guest rerun is claimed. Historical source files retain
1085 records; earlier filters exclude three revised original inputs: command-enum
citation, Boolean rerandomization and virtual-field configuration citation.
This increment retains the same 1082 compatible records byte-for-byte and adds
nine unmeasured inputs. Ghost remains 206 pass/876 fail per seed; kirimasim
remains 1073 unsupported/nine missing-API failures. The 1201 unmeasured inputs
are 1198 additions and three revised originals. No guest improvement or regression
is measured. Earlier filter provenance remains in
`out/thin-seventy-first-guest-exclusions.json`; the current input scope is in
`out/thin-seventy-seventh-evidence-scope.json`.

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
  their declared 1082-case subset; 1201 input IDs remain unmeasured.
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

The [draft ledger](requirements.md) has 3830 AI duties and 134 unassessed
identifiers: 1967 partial/406 assessed. Chapter 10 is 87/29/0; chapter 18 is
360/51/45. Their partial contracts and original targets remain open. Direct
links cover 2259 tests; 24 others have only controls. Guests retain 1082
compatible inputs; 1201 (1109 simulation/92 elaboration), including three
revised originals, are unmeasured. Scope and denominator remain unapproved.

## Reproducing and retaining results

To investigate one listed difference, select its source path with [the single-test command](faq.md#q3-how-can-i-run-one-test-first) and retain the same library and backend conditions as the record.

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
2283 metadata records and the draft ledger/index. Its 1944 tagged ordinary
Verilator checks comprise 1857 runtime cases at seeds 1/73 and 87 compiler
rejections without runtime seeds, plus seventeen
explicit command-line checks under their separate condition.
The previous unsharded [Check run](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/41976785278)
exceeded the configured 150-minute job limit. The current workflow partitions
the current 1944 tagged checks into 8 disjoint shards (243/243/243/243/243/243/243/243),
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
