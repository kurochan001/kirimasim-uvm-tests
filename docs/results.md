# Current results and measurement methodology

[日本語](results.ja.md) · [README](../README.md) · [Known differences](known-differences.md)

## Current snapshot

Runtime matches, compiler rejections and unmeasured inputs describe different execution conditions; [Read a result](reading-guide.md#read-a-result) explains how to read the counts together.

The Verilator snapshot assembled on 2026-11-05 covers all 2133 current tests.
Guest records retain 1083 compatible current inputs; 1050 inputs are
unmeasured, including two revised old inputs. Each record
fingerprints its inputs and conditions.
The suite has 2133 fixtures in 21 directories: 2041 simulation and 92
elaboration. Milestone totals are M1 920 (841/79), M2 547 (542/5) and M3 666
(658/8), with runtime/elaboration counts in parentheses. All use `spec_check: ai`;
none records human review. Of 2104 no-DPI fixtures, 92 are illegal elaboration
checks. The eleven HDL-DPI and eighteen command-line/regex-DPI runtime fixtures
remain separate.

Counts do not establish a reviewed coverage percentage.

| Simulator and library | Observation | Execution scope |
| --- | --- | --- |
| Verilator 5.052, pinned UVM | 1831 `pass`: 1744 runtime + 87 compile rejection; 302 `known` | Runtime matches use seeds 1/73; expected compiler rejections execute no runtime seed |
| Verilator 5.052, original VPI HDL backend | 10 `pass`; 1 `fail` | Separate overlapping 11-case condition; matches at seeds 1/73, difference at seed 1 |
| Verilator 5.052, original command-line VPI bridge and pinned regex DPI | 17 `pass`; 1 `known` | Separate overlapping 18-case condition; matches at seeds 1/73, difference at seed 1 |
| kirimasim, pinned UVM | 1074 `unsupported`; nine `fail` | 1083 unchanged inputs; 1050 inputs unmeasured |
| Ghost, bundled UVM | 207 `pass`; 876 `fail` | 1083 unchanged inputs at each seed; identical failing sets; 1050 inputs unmeasured |
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
differences without runtime, even when accepted. The 79 unexpected simulation
builds remain separate. A pass requires the declared expectation.

The 302 spec-only cases retain standard-derived output or compile-diagnostic
expectations. Five are illegal compiler acceptances; 297 are simulation cases.
Of these, 218 first differ at runtime seed 1 without seed 73. Twenty-seven cannot build
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
unlinked DPI: eleven HDL and eighteen command-line cases. Three additional legal builds use the literal enum-collection T interpretation. Seven further builds retain six strict attribute definitions and the printed enum-unpack arity. Three more builds retain dependent visitor defaults with custom STRUCTURE. These 79 simulation
builds have no runtime result. Separate command-line evidence remains seventeen
matches and one quit-warning difference.

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

kirimasim reports `uvm_object_wrapper` as unsupported on 1074 cases; the other
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

The snapshot retains all 2100 prior ordinary inputs/records from [19c4d55](https://github.com/kurochan001/kirimasim-uvm-tests/commit/19c4d5513ad8137d0dc1f122c0bb0568adfaf743)
and measures the traversal-declaration increment on 2026-11-05 JST.

The 33 new M1 inputs contain 29 simulations and four compiler checks.
Twenty-six simulations match seeds 1/73; two printed virtual bases are rejected
as expected without runtime. Three legal STRUCTURE-only specializations cannot
build, and two concrete subtypes omitting pure methods are accepted without
executing their binaries. All original expected outputs and diagnostics remain.

The probes check exact default/explicit NODE and STRUCTURE types, object/base
handle identity and omitted/explicit constructor names. Direct subtype wrappers
call the actual base constructor with the tested argument form. Inherited
begin/end hooks preserve selected original state; separate original pure-method
bodies expose typed argument and reference-queue dispatch. These bodies do not
certify an unimplemented builtin algorithm.

Actual top-down, bottom-up and by-level adapters traverse selected acyclic trees
through supplied proxies. Membership, specified parent/depth partial order and
begin/end bracketing are observed without imposing sibling order. STRUCTURE-only
inputs retain the printed dependent VISITOR default; explicit VISITOR controls
match separately and have their own direct duties. The three pinned declarations
were inspected only after deriving expectations and do express the standard's
dependent default. The component-versus-node69 build diagnostics do not assign
a simulator/library cause or establish three independent defects.

The missing get_immediate_children/accept inputs retain compiler-rejection
oracles. Complete legal controls do not pass them, and no illegal binary runs.
The printed adapter non-virtual class versus pure accept wording is a separate
interpretation boundary; a complete subtype does not resolve constructability.
Final tagged sources and supplementary order citations are remeasured without
changing fixture bodies, helpers or expectations.

Traversal declaration auditing adds 33 bilingual AI duties, partially
decomposing 14 previously unassessed identifiers. Seven individually read
assessments classify four grouping headings as structural and three overviews
as contextual, with explicit links to their actual declaration/method duties.
Annex F is 90 partial/23 assessed/24 unassessed, with 207 duties and 122 primary
tests (89 simulation/33 elaboration). F.5 has zero unassessed identifiers but
retains partial contracts, type-default differences and wording conflicts.
Global state is 1938 partial/404 assessed/165 unassessed (278 structural/126
contextual). Original scope, milestone targets and denominator review remain open.

All 3719 duties have direct tests; 2109 tests have direct links, 24 have only
controls and 79 have control links. Every new input has a direct duty; seven
also act as explicit legal controls. All 3686 prior duties, 397 assessments,
2100 indexed inputs/ordinary records and 88 prior compiler records remain
unchanged. Four new compiler records bring that set to 92. No human review,
approved scope/denominator or completed coverage is asserted.

Retained kirimasim/Ghost records were collected with fixed executable
snapshots and Ghost's seed-specific private profiles.

Commercial simulator results are excluded under the
[reporting policy](faq.md#commercial-simulator-and-issue-reporting-policy).

The earlier temporary kirimasim/Ghost executable/profile snapshots are no
longer available, so no guest rerun is claimed. Historical files retain 1085
records. Two current inputs differ: a command-enum citation and the corrected
Boolean rerandomization observation. Their stale records are excluded.
The compatible current subset has 1083 records: kirimasim 1074 unsupported/
nine missing-API failures; Ghost 207 pass/876 fail at each seed. The 1050
unmeasured inputs are 1048 additions and the two revised old inputs. The filtered
files and `out/thin-sixty-ninth-evidence-scope.json` retain the explicit exclusions
until authorized matching execution conditions are restored.

The fingerprints identify different inputs:

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
  their declared 1083-case subset; 1050 input IDs remain unmeasured.
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

The [draft ledger](requirements.md) has 3719 AI duties and 165 unassessed
identifiers: 1938 partial/404 assessed. Annex F is 90/23/24; F.5 retains partial
contracts despite zero unassessed identifiers. Direct links cover 2109 tests;
24 others have only controls. Guest records retain 1083 compatible inputs;
1050 (958 simulation/92 elaboration), including two revised original inputs,
are unmeasured. Scope/denominator and original targets remain open.

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
2133 metadata records and the draft ledger/index. Its 1831 tagged ordinary
Verilator checks comprise 1744 runtime cases at seeds 1/73 and 87 compiler
rejections without runtime seeds, plus seventeen
explicit command-line checks under their separate condition.
The previous unsharded [Check run](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/41976785278)
exceeded the configured 150-minute job limit. The current workflow partitions
the current 1831 tagged checks into 8 disjoint shards (229/229/229/229/229/229/229/228),
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
