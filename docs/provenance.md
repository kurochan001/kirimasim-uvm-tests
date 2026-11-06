# Repository relationship and source provenance

[日本語](provenance.ja.md) · [README](../README.md) · [Testing guide](testing.md)

Provenance identifies where the code and expectations came from; [the contribution rules](testing.md#rights-and-sources) explain how to apply that distinction to a change.

This page records related-repository conventions, copied code and original
suite code. Current execution results are in [results](results.md), while
increment narratives are in [history](history.md).

## Relation to kirimasim-tests

The standard identifies the rule being checked, while a fixed-release oracle records reproduction by an implementation; [the expectation guide](testing.md#where-the-expected-outputs-come-from) explains their different roles in this table.

| | kirimasim-tests | kirimasim-uvm-tests |
| --- | --- | --- |
| Standard | IEEE 1800-2023 | IEEE 1800.2-2020, run by the language of 1800-2023 |
| External dependency | none (small, self-contained designs) | the UVM library, pinned by version and digest |
| Layout | `tests/chNN/`, chapters of 1800-2023 | `tests/uNN/`, chapters of 1800.2 |
| Fixed-release oracles | Icarus Verilog 13.0, Verilator 5.052 | Verilator 5.052 where it reproduces |
| Shared judgment/result JSON | the original | `suite_results.py` copied from a fixed commit; runners are original suite code ([`tools/UPSTREAM`](../tools/UPSTREAM)) |
| CI | its own | its own, as compiling UVM for every test is slow |

When a UVM test fails because of a language feature (classes, parameterized
classes, constraints, process control and so on), the minimal case goes to
kirimasim-tests as a language test. The UVM suite thus also finds what the
language tests are missing.

## Shared judgment and result code

Shared result code gives the two suites a common JSON format, and [the result definitions](faq.md#q5-what-do-pass-fail-known-and-unsupported-mean) explain how to interpret the statuses produced by this suite's runners.

`tools/suite_results.py` comes from
[kirimasim-tests at 19034b575e1b715c356660ac1422b45f25c15ab3](https://github.com/kurochan001/kirimasim-tests/blob/19034b575e1b715c356660ac1422b45f25c15ab3/tools/suite_results.py),
with these changes:

- `SIMULATORS` lists `kirimasim`, `verilator` and `ghost`.
- `input_files()` also hashes `third_party/uvm.lock`, which identifies the
  library compiled with each pinned-library test.
- `runner_digest()` hashes `tools/uvm_common.py` rather than
  `normalize_output.py`, which this suite does not use.
- The module docstring identifies the source.

The upstream commit identifies the exact source snapshot used for copied code, and [Rights and sources](testing.md#rights-and-sources) explains the contribution rules when modifying that material.

## Original suite tools

A runner builds and judges a test, while a backend connects selected calls to external code; [the HDL setup guide](testing.md#verilator-vpi-hdl-subset) shows how they work together under a specific execution condition.

The runners (`run_*.py`) and `lint_metadata.py` were written for this suite
using the kirimasim-tests tools as a model; they are not copies.
`sv_lifetimes.py` and its regression tests are also original suite code.
That helper lexically checks explicit lifetimes on initialized block locals;
it is not copied from a simulator parser or the language standard.

`requirements.py` and its regression tests are original suite code. The
[ledger data](requirements.md) uses original bilingual paraphrases of the
user-provided standard, with clause numbers and expected-output anchors.
It does not copy normative text or sample code, or import simulator results.

`run_verilator_hdl.py`, its regression tests and `uvm_hdl_vpi.cpp` are original
suite code. The runner follows the existing suite's compilation/judgment flow
under a distinct evidence identity. The limited backend uses standard DPI/VPI
interfaces and actual simulator handles; it is not copied from a commercial
overlay or a simulator implementation. Public [VPI documentation](https://verilator.org/guide/latest/connecting.html#verification-procedural-interface-vpi)
informs integration; the user-provided IEEE clauses define expected behavior.

The [command-line runner](../tools/run_verilator_cmdline.py) and
[VPI argument bridge](../tools/cmdline_backend/uvm_cmdline_vpi.cpp) are original
suite code. They use standard VPI process information and the public
[VPI interface documentation](https://verilator.org/guide/latest/connecting.html#verification-procedural-interface-vpi).
The [regex wrapper](../tools/cmdline_backend/uvm_cmdline_regex.cpp) compiles the
existing Apache-2.0 regex source from the [locked library](../third_party/uvm.lock);
it does not copy that implementation into tracked sources. The
[portable header](../tools/cmdline_backend/malloc.h) supplies standard allocation
declarations. Expectations remain independent IEEE-derived observations.
No simulator implementation or commercial overlay supplies the oracle.

The memory-walk oracle has an explicit AI interpretation using the
[official UVM 1.2 class reference, 27.7](https://accellera.org/images/downloads/standards/uvm/UVM_Class_Reference_Manual_1.2.pdf#page=739).
Its role and limits are recorded in [Q134](faq.md#q134-how-is-the-memory-walk-algorithm-interpreted).
The independently written observer is not copied pseudocode or an
implementation-derived oracle. Historical context does not amend IEEE 1800.2.

The reviewed historical PDF has SHA-256 `87117e30e17701a13434f785687d3776e710e13c74475b6ada4e7823244ea87a`.
Section 27.7 appears on printed page 730 / PDF page 739. The PDF and rendered
pages remain local and are not committed.

If the two repositories' judgment rules drift, a shared package is the
planned way to centralize them. [tools/UPSTREAM](../tools/UPSTREAM) is the
bilingual pointer to this source record.

## Library and standards

A clause citation points into a separately obtained standard rather than a bundled manual; [the local-material guide](handoff.md#files-and-local-material) identifies what a fresh clone supplies.

The dependency, standard and original suite code have distinct origins, and [Rights and sources](testing.md#rights-and-sources) gives the project rules for contributing material.

Use IEEE 1800.2 for UVM API behavior and IEEE 1800 for the SystemVerilog language rules it relies on; [the metadata guide](testing.md#metadata) shows how a test cites both standards.

The external Accellera UVM library is fetched and checked using
[uvm.lock](../third_party/uvm.lock), not committed. Its license is Apache-2.0;
its own `LICENSE.txt` and `NOTICE.txt` accompany it if the library is ever
committed. The repository's original license text is [LICENSE](../LICENSE),
with a complete [Japanese reference translation](../LICENSE.ja.md).

IEEE clauses are cited and described in our own words; standard text,
figures and example code are not copied into tests or documentation.
GPL/LGPL simulator implementation source is not read. Private simulator
identity, version, profile and paths are not published. The
[testing guide](testing.md#rights-and-sources) records these contribution rules.

FIFO expectations were written from IEEE before measurement. The locked
Apache-2.0 UVM was then read only to diagnose null-field stops and its additional
build initializer. Two original helper variants keep listed-API and explicitly
initialized conditions separate. The extra call supplies a control premise;
its implementation does not define any expected FIFO algorithm or replace a
direct duty. No GPL/LGPL simulator implementation source is used.

Core-service expectations were derived before measurement. Pinned Apache-2.0
source diagnosis identified its additional pure phase-hopper hook. The original
listed-only input remains unchanged; separate original control bodies supply
the hook. Each negative declaration also supplies it to isolate one printed
omission. No extra IEEE prerequisite or builtin oracle is derived from that
source. The initial root fixture's abstract construction is corrected separately.

Field expectations are original observations derived from the supplied IEEE
type/shape, flag, copy and comparison contracts. Literal collection-T inputs
remain separate from element-enum controls. Explicit-UNPACK control and the
unchanged PACK-only premise likewise retain distinct identities. Passing
roundtrips do not invent a universal stream layout or prove every direction.

Field-access expectations come from the supplied IEEE field/register/callback
contracts. Original delayed frontdoors and backdoor storage observe selected
effects without physical HDL, licensed simulator results or implementation-derived
oracles. Parent-before-field pre order is preserved despite measured differences.
The whole-word RO expectation explicitly qualifies the best-effort wording;
it is separate from selected-slice protection and independent poke controls.

Predefined protection and post-predict expectations are original observations
derived from supplied IEEE callback/field contracts. ERROR presence and exact
status are specified without copying implementation-specific report wording.
The two Methods headings were read individually as grouping clauses. Correcting
display formatting does not change the standard-derived expected observations.

Recording and scalar-macro expectations were derived independently from
supplied IEEE B.2.3–B.2.5 and recorder/packer contracts. The pinned Apache-2.0
recorder-macro header was read afterward to diagnose extra arguments, integer
hook selection and generic formatting; it did not define the oracle. Literal
printed inputs, extension-tolerant controls and qualified handle interpretations
remain distinct, as explained in [the macro FAQ](faq.md#recording-and-scalar-macro-conditions).

Traversal declaration expectations come from supplied IEEE F.5 and the
language's abstract-class, parameter-type and constructor rules. After the
oracles were written, the three Apache-2.0 pinned adapter declarations were
inspected for dependent defaults; they match the printed dependency. No
traversal algorithm or simulator implementation source defines the expected
ordering. Original interface bodies delegate to public adapters or expose
declared calls; see [the declaration FAQ](faq.md#traversal-declarations-and-defaults).

Virtual-register/field query expectations come from the supplied IEEE
18.9–18.10 contracts and memory/map address-unit rules. Original model setup
and report observers do not transfer HDL/storage data. The overview base names
conflict with explicit declarations and are retained as qualified inputs;
no library or simulator implementation supplies the oracle. See [the query
FAQ](faq.md#virtual-register-queries-and-declaration-boundaries).

Dedicated global-pool expectations come from supplied IEEE 10.4/11.2,
event/barrier and string-key contracts. Original seeded bindings and positive-time
waits observe the actual public API, without copying an implementation. Printed
pool-return versus item prose stays qualified. Virtual-field constructor captures
call the actual base through factory-created original subtypes. The legacy
configuration source and its stable parent duty move from constructor
18.10.2.1 to configure 18.10.2.2; two existing duties add width/LSB links.
See [the mapping FAQ](faq.md#dedicated-global-lookups-and-mapping-corrections).

Recorder-link expectations are derived before measurement from the supplied IEEE
16.4.4 and the close/free/flush, stream-lifecycle and database-link contracts.
Original in-memory callbacks and a terminating catcher expose the selected
behavior; an external database or observed warning does not define the oracle.
See [the lifetime FAQ](faq.md#recorder-link-lifetime).

Canonical bus expectations are derived before measurement from the supplied
IEEE 19.1.2, its field contracts and the address/endian/read/write clauses.
Original numeric-word callbacks observe descriptors and independently seeded
reads; builtin TLM byte conversion and observed simulator output do not define
the oracle. The earlier width duty's statement and qualifications remain;
see [the bus-operation FAQ](faq.md#canonical-bus-operations).

Supporting references were aligned with the actual setup/API calls, including
register write at 18.4.4.9 after an incorrect getter reference at 18.4.4.3.
Bodies, helpers, expected output and the tag partition stay unchanged. All 24
post-correction sources are freshly measured; earlier records keep their original
input identities and are archived rather than relabeled. See [Q293](faq.md#q293-why-remeasure-after-correcting-only-supporting-citations).

Policy-substitution expectations are independently derived from supplied IEEE
16, object wrapper/hook and typed state APIs. Original subtypes, callback ticks
and opaque-stream roundtrips assume neither recorder-history reset nor a shared
encoding. No new implementation source or commercial result is used; see
[the policy FAQ](faq.md#policy-substitution-and-typed-object-streams).

Printer-attribute expectations are derived before measurement from supplied
IEEE 16.2.3.4 and 16.2.5.1–16.2.5.3. Original strings isolate visibility from
numeric size rendering; omitted peer defaults and explicitly enabled controls
retain distinct premises. No new implementation source or commercial result is
used; see [the emission FAQ](faq.md#printer-attributes-and-emission-controls).

Adapter parent-context expectations are derived before measurement from supplied
IEEE 19.2.1.2.4, public clone/parent queries and register/memory frontdoor contracts.
An original typed protocol and preseeded read storage assume neither a standard
do_clone bridge signature nor clone count or completion order. No new
implementation source or commercial result is used; see [the parent-context FAQ](faq.md#adapter-sequence-contexts).

Force/release expectations are independently derived before measurement from
supplied IEEE 19.6.2.3/.5/.6, language 10.6.2 and VPI 38.34. The original backend
uses standard VPI flags and actual handles; [public extension documentation](https://verilator.org/guide/latest/extensions.html)
informs capability integration only. Original probes and all twenty final inputs
verify exactly 5.052 rather than inferring its behavior from latest documentation.
No GPL/LGPL implementation file is opened or used; no commercial result supplies
evidence. [The HDL FAQ](faq.md#hdl-force-and-release-conditions) distinguishes expectations,
backend premises and eleven refreshed input identities.

Positive-duration force_time expectations are independently derived before
measurement from supplied IEEE 19.6.2.4, force/release behavior and task-lifetime
rules. Original observers check interval interiors and after expiration, without
using task-return timing/results or internal call counts as an oracle. Apache-2.0
package/time-unit setup was inspected; backend/runners remain unchanged and no
simulator implementation source or commercial result is used. [The timing FAQ](faq.md#positive-duration-force_time-observations)
records shared compilation-default units and sequential-call premises.

Register-path expectations are derived before measurement from supplied IEEE
18.4.6,17.2.3.1, public-task visibility and by-value argument rules. Standard
get_slices and explicitly nonstandard public-slices member controls have distinct
premises; controls do not pass the standard API. Actual 16/40-bit whole variables
and legal split references use public APIs and the unchanged original VPI backend.
No simulator implementation source or commercial result is used. Fixture argument
directions and set_door naming are corrected; include-directory sibling hashes
require all twenty-two corrected inputs to be measured. [The path FAQ](faq.md#register-hdl-paths-and-observation-premises)
records old input/log retention and independent expectations.

Coverage-construction/sampling expectations are derived before measurement from
supplied IEEE18.4.7.1–.3/.8,18.1.4.1/.7,17.2.2.9 and protected/virtual rules.
The short register-builder prose is read with its inclusion API and explicit
block analogue; scope/requested-mask selection remains an AI interpretation with
resource storage conditions still open. Original helper/sampler bodies do not
define a bin algorithm; the actual inherited block method supplies routing.
No commercial result or new implementation-source reading is used. [The coverage FAQ](faq.md#register-coverage-construction-and-sampling)
records the partial contracts.

Report-macro expectations are derived before measurement from supplied IEEE B.1,
the eight basic/context clauses and report-object/message/server contracts.
Original observers receive actual macro delivery without defining default text
or fatal exit behavior. Strict INFO macro wording is kept distinct from API
equality. The initial unspecified exact-one visible-MSG predicate is corrected
to positivity; expected files/helper remain unchanged and all inputs are freshly
measured. No commercial result or simulator implementation source is used.
[The macro FAQ](faq.md#reporting-macros-and-info-boundaries) records excluded old inputs and interpretation limits.

Callback-macro expectations are derived before measurement from supplied IEEE
B.4.1/.3 and callback registration, iterator, type and METHOD contracts. Original
affine hooks expose order/reference arguments rather than defining UVM algorithms;
no private bit or factory utility is assumed. No new implementation source or
commercial result is used; [the callback FAQ](faq.md#callback-registration-and-dispatch-macros) records the early termination and unresolved B.4 overview.

Size/version expectations are derived before measurement from supplied IEEE
B.6/B.7, F.2.1.1/.2 and public packer, parameter and type contracts. Original
patterns supply stored data rather than UVM algorithms; reserved values/layout,
vendor version text and opaque encoding remain unfixed. After comment wrapping
and reproduction tags, all twelve final inputs are freshly measured with bodies
and expectations retained. No new implementation source or commercial result is
used; [the size FAQ](faq.md#size-defines-and-version-identification) records the observation limits.

Report/state expectations are derived before measurement from supplied IEEE
F.2.2.1/.4, F.2.4.2, F.3.4 and cited public APIs. Original observers receive actual
messages/hooks while keeping INFO equality, negative-limit NONE and state versus
kill post-callbacks separate. No numeric encoding or default fatal action is newly
fixed. No new implementation source or commercial result is used; eleven header
tags and the refined NONE observer/zero-limit control are freshly measured;
earlier observer variants are archived/excluded and the unchanged literal kill
pretag identity retained, as explained in [the report/state FAQ](faq.md#report-enums-and-sequence-state).

Virtual-register/field poke/peek expectations are independently derived before
measurement from supplied IEEE 18.9.1.3.3/.4, 18.10.4.3/.4 and the memory
deposit/sample contracts. Singleword mask/shift literals, equal halves and an
unordered result pair do not use an implementation's word order or internal
access algorithm as the oracle. Original user storage and actual HDL through the
unchanged VPI backend are measured separately, without new implementation-source
reading or commercial results; see [the backdoor FAQ](faq.md#virtual-register-backdoor-observations).

Callback expectations are independently derived before measurement from supplied
IEEE 18.9.1.4, 18.9.2, 18.10.5/.6, preserving incompatible pre-read groupings as
separate qualified inputs. After freezing construction expectations and observing
the refusal, the public declaration in the pinned Apache src/reg/uvm_vreg.svh is
inspected: uvm_vreg_cbs is virtual. That declaration does not replace the printed
IEEE class expectation; a legal subtype remains a separate control. The new
standalone RMW fixture is corrected to shared storage while preserving its original
expectations, archiving/excluding prior versions and freshly measuring every changed
input. No simulator implementation source or commercial result is used; see [the callback FAQ](faq.md#virtual-register-callback-contracts).

Killed-access recovery and frontdoor-query expectations are independently
derived before measurement from supplied IEEE 18.9.1.3.5, 18.4.5.1/.2 and the
SystemVerilog process-control rules. Original backdoor gates/storage and frontdoor
sequences provide observations; implementation bodies and commercial results do
not supply an oracle. Frozen bodies/expectations are retained when measured tags
are added and the resulting inputs are freshly remeasured; [the access FAQ](faq.md#killed-access-recovery-and-frontdoor-selection)
records applicability limits.

Root/predictor expectations are independently derived before measurement from
supplied IEEE F.7.2.1,F.7.3.4–.6,19.3.3.3 and SystemVerilog simulation control.
Only after bare-type build refusals, the license and one type-name function in
pinned Apache src/reg/uvm_reg_predictor.svh were inspected; BUSTYPE factory
creation is consistent with the diagnostic. That source supplies no prediction
algorithm or diagnostic-severity oracle. Registered packets remain separate
controls; all twelve initial bodies/expectations are retained, and tagged inputs
are freshly measured. No simulator implementation or commercial result is used;
see [the root/predictor FAQ](faq.md#root-completion-guards-and-predictor-checks).

Enum/manager expectations are derived before execution from supplied IEEE
F.2.1.7, F.2.7, 10.7.2.3.1 and 18.12 type/variable/allocation contracts, without
implementation bodies or commercial results. Callback traces are independently
constructed; two existing agent inputs retain bodies and measured identities
while gaining links. Only the MAM helper gains held-endpoint snapshots, and all
ten affected inputs are freshly measured without changing expected rows.
Separate rand-field sources constrain opposite-value changes; [the enum/allocation FAQ](faq.md#enum-effects-and-allocation-preferences)
records interpretation and evidence limits.

## Clause catalog maintenance

The catalog counts identifiers rather than normative duties, so [Counting unit and scope proposal](requirements.md#counting-unit-and-scope-proposal) explains why restoring an entry does not define a coverage denominator.

The identifier-only [clause catalog](../tools/clauses_1800_2.txt) now includes
B.2.1.2, B.2.1.3 and D.2.2.3. Their wrapped headings were missing from the
prior catalog and were checked manually against the user-provided IEEE
1800.2-2020 standard. Restoring them changes the census from 2,504 to 2,507
identifiers and adds three candidates before decomposition. A scan of
numbered-heading-shaped lines in the local extracted text found no further
unmatched identifiers in the selected roots. That scan is not a completeness
certificate: it does not find every normative obligation or assess unnumbered
content. No standard text is redistributed.

## Issue reporting policy and form

A reproducer is a small independent test that isolates the disputed observation; [Q18](faq.md#q18-how-should-i-report-or-correct-a-wrong-expectation) explains the expected behavior and evidence to include with it.

The commercial-result policy follows the FAQ and the bilingual reporting form
in [kirimasim-tests](https://github.com/kurochan001/kirimasim-tests). The
[upstream form](https://github.com/kurochan001/kirimasim-tests/blob/0ca2ff7c922a257b1db681e96352a169625ebb9b/.github/ISSUE_TEMPLATE/report.yml)
was adapted to IEEE 1800.2-2020, this repository's permitted runners and local
policy links. The required confirmation and disabled blank-issue chooser are
retained. See the [local policy](faq.md#commercial-simulator-and-issue-reporting-policy)
and [form](../.github/ISSUE_TEMPLATE/report.yml).
