# Current results and measurement methodology

[日本語](results.ja.md) · [README](../README.md) · [Known differences](known-differences.md)

## Current snapshot

The Verilator snapshot assembled on 2026-11-05 covers all 1972 current tests.
Guest records retain 1083 compatible current inputs; 889 inputs are
unmeasured, including two revised old inputs. Each record
fingerprints its inputs and conditions.
The suite has 1972 fixtures in 21 directories: 1884 simulation and 88
elaboration. Milestone totals are M1 843 (768/75), M2 547 (542/5) and M3 582
(574/8), with runtime/elaboration counts in parentheses. All use `spec_check: ai`;
none records human review. Of 1943 no-DPI fixtures, 88 are illegal elaboration
checks. The eleven HDL-DPI and eighteen command-line/regex-DPI runtime fixtures
remain separate.

Counts do not establish a reviewed coverage percentage.

| Simulator and library | Observation | Execution scope |
| --- | --- | --- |
| Verilator 5.052, pinned UVM | 1691 `pass`: 1606 runtime + 85 compile rejection; 281 `known` | Runtime matches use seeds 1/73; expected compiler rejections execute no runtime seed |
| Verilator 5.052, original VPI HDL backend | 10 `pass`; 1 `fail` | Separate overlapping 11-case condition; matches at seeds 1/73, difference at seed 1 |
| Verilator 5.052, original command-line VPI bridge and pinned regex DPI | 17 `pass`; 1 `known` | Separate overlapping 18-case condition; matches at seeds 1/73, difference at seed 1 |
| kirimasim, pinned UVM | 1074 `unsupported`; nine `fail` | 1083 unchanged inputs; 889 inputs unmeasured |
| Ghost, bundled UVM | 207 `pass`; 876 `fail` | 1083 unchanged inputs at each seed; identical failing sets; 889 inputs unmeasured |
| Ghost, pinned UVM | Not measured for the current executable snapshot | No current pinned-mode claim |

The pinned library is Accellera UVM 2020.3.1, commit `78c06547a2a0`, with
326 files checked against [the lock](../third_party/uvm.lock). A Ghost bundled
run uses the supplied library rather than that lock's package. Private
simulator identity, version, paths, profile contents and diagnostics are
not published. [Ghost setup](testing.md#ghost) describes the public interface.
Icarus Verilog is not used for this UVM suite.

## Interpretation

85 valid negative expectations match by compiler rejection with the
declared fixture/type/member diagnostic. Three illegal designs remain accepted:
subscriber write and visitor visit omissions, and direct construction of the
printed virtual builtin dispatcher. They retain the rejection oracle as known
differences without runtime, even when accepted. The 69 unexpected simulation
builds remain separate. A pass requires the declared expectation.

The 281 spec-only cases retain standard-derived output or compile-diagnostic
expectations. Three are illegal compiler acceptances; 278 are simulation cases.
Of these, 209 first differ at runtime seed 1 without seed 73. Twenty-seven cannot build
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
unlinked DPI: eleven HDL and eighteen command-line cases. Three additional legal builds use the literal enum-collection T interpretation. These 69 simulation
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

The snapshot retains all 1930 prior ordinary inputs/records from [80a8bdf](https://github.com/kurochan001/kirimasim-uvm-tests/commit/80a8bdf631334668107f42328acd6af395d69fe7)
and measures the field-macro increment on 2026-11-05 JST.

Forty-two M1 inputs add 37 two-seed runtime matches and one expected
compiler rejection. Four retain differences: three legal simulation builds and
one seed-1 runtime input without seed 73. Four separately indexed controls match
but have only control links; they do not replace the original premises.

Thirty-three typed field probes cover scalar, static/dynamic array, queue and
string/integral-key associative properties. Selected copy and positive/negative
comparison observations preserve 72-bit data, signed/unsigned/high/wide keys,
collection sizes, removal of stale entries and unregistered peer isolation.
Six object-valued shapes explicitly select DEEP and retain distinct copied
handles and source state after target mutation. No user copy/compare hook
substitutes for field automation; no traversal order is imposed.

Enum collection probes use the collection typedef literally described by the
printed T prose. Their static/dynamic/queue builds fail; three separate controls
pass the element enum type while keeping collection storage unchanged. This
is an explicit interpretation boundary, not a proven count of library defects
or a resolution of the wording. The original expectations remain unchanged.

NOCOPY/NOCOMPARE precedence and omitted/DEFAULT/ALL_ON copy/compare observations
match. PACK alone fails the paired-unpack expectation; explicitly adding UNPACK
in a separate control matches. Compatible roundtrip and target-sentinel results
do not prove every independent one-way packing duty or a stream layout.
Manual field-utils create/type-name/clone observations match without automatic
factory registration. The const-ARG prohibition rejects with its declared
diagnostic and executes no runtime seed. Final tagged inputs are remeasured;
all earlier source/evidence records remain unchanged.

Field-macro auditing adds 125 bilingual AI duties without new identifier
classifications. Forty-five previously unassessed identifiers receive partial
decompositions: 41 in B and four in F. Annex B is 81 partial/4 assessed/59
unassessed with 164 drafts and 96 primary tests (95 simulation/one elaboration).
Annex F is 76/16/45 with 174 drafts. Global state is 1876 partial/390 assessed/
241 unassessed (268 structural/122 contextual). All original targets remain open.

All 3506 duties have direct tests; 1954 tests have direct links, eighteen have
only controls and 61 have control links. The new enum-type and explicit-UNPACK
controls do not pass the original premises. Copy and comparison duties sharing
one observation are not independent test counts. All 3381 prior duties,
390 assessments, 1930 indexed inputs/ordinary records and 87 compiler records
remain unchanged; the compiler set now has 88 inputs. No scope/denominator
approval, human review or completion is claimed.

Retained kirimasim/Ghost records were collected with fixed executable
snapshots and Ghost's seed-specific private profiles.

Commercial simulator results are excluded under the
[reporting policy](faq.md#commercial-simulator-and-issue-reporting-policy).

The earlier temporary kirimasim/Ghost executable/profile snapshots are no
longer available, so no guest rerun is claimed. Historical files retain 1085
records. Two current inputs differ: a command-enum citation and the corrected
Boolean rerandomization observation. Their stale records are excluded.
The compatible current subset has 1083 records: kirimasim 1074 unsupported/
nine missing-API failures; Ghost 207 pass/876 fail at each seed. The 889
unmeasured inputs are 887 additions and the two revised old inputs. The filtered
files and `out/thin-sixty-fifth-evidence-scope.json` retain the explicit exclusions
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
  their declared 1083-case subset; 889 input IDs remain unmeasured.
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

The [draft ledger](requirements.md) has 3506 AI duties and 241 unassessed
identifiers: 1876 partial/390 assessed. Annexes B and F are 81/4/59 and 76/16/45;
their macro/facility conditions remain partial. Direct links cover 1954 tests;
eighteen others have only controls. Guest records retain 1083 compatible inputs;
889 (801 simulation/88 elaboration), including two revised original inputs,
are unmeasured. Scope/denominator and original targets remain open.

## Reproducing and retaining results

The [testing guide](testing.md#running-the-suite) documents the commands,
profile modes and library settings. Request `--json out/<name>.json` to retain
statuses, reasons, configuration and fingerprints. `out/` is ignored by Git,
and Check does not publish these local evidence files. A result from different
inputs, a different runner, executable, profile or library is a separate condition.

## Continuous integration

[Check](../.github/workflows/check.yml) runs on pushes to `main`, pull requests
and manual dispatch. It checks pinned-library integrity, 110 tool unit tests,
1972 metadata records and the draft ledger/index. Its 1691 tagged ordinary
Verilator checks comprise 1606 runtime cases at seeds 1/73 and 85 compiler
rejections without runtime seeds, plus seventeen
explicit command-line checks under their separate condition.
It does not run kirimasim, Ghost or spec-only cases. The README's badge is the
live CI state, separate from these local measurements. A green Check does
not establish complete UVM conformance or a passing result for every simulator.
There is no Nightly workflow or automatic result publication.
