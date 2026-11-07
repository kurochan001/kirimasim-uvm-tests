# Glossary

[日本語](glossary.ja.md) · [README](../README.md) · [FAQ](faq.md)

For a path from these terms to a first run and its result, use [the reading guide](reading-guide.md).

These are the meanings used in this repository's tests and reports. This
glossary is a reading guide; cited clauses in each test remain the basis of
its expected result.

The main groups explain [expectations](#standards-and-expectations), [UVM components](#uvm-building-blocks), [transaction-level communication](#transaction-level-communication), [register models](#register-model), [execution records](#execution-and-result-records) and [coverage counts](#scope-and-coverage), so you can start with the terms used on the page you are reading.

API names retain their source spelling for in-page searches, and [the FAQ topic guide](faq.md#find-an-explanation) leads from a term to fixture conditions and examples.

## Standards and expectations

When an expected-output file does not explain a result by itself, [the metadata fields](testing.md#metadata) show whether a diagnostic or exit condition is also required.

**UVM / IEEE 1800.2-2020** — Universal Verification Methodology: the classes,
APIs and behavior checked by this suite. The pinned Accellera implementation
is a library used to exercise those requirements, rather than the source of
the expected results.

**SystemVerilog / IEEE 1800-2023** — The language that runs UVM. Language-only
reproductions belong in kirimasim-tests; this suite checks behavior while
running a UVM library.

**LRM / clause / `:lrm:`** — The reference manual, an identified part of the
standard, and the test metadata listing those parts. Here the UVM clauses
follow `1800.2-2020`; language clauses may follow `1800-2023`. A citation can
describe setup as well as the behavior being checked.

**Conformance test / observation** — A small design and expected result
derived from the standard / the value, count, order or state actually checked.
Calling an API without observing the required outcome is not complete evidence
for that behavior.

**Expected output / `.expected`** — The observed lines a test must reproduce.
Only lines beginning exactly with `UT: ` are selected, in their original order,
with their spaces and values preserved. Exit-code and diagnostic conditions
can be specified separately.

**Oracle / `:oracle:` / spec-only** — The recorded basis of an expectation.
`spec` means it follows the cited standard; `verilator@5.052` additionally
records reproduction with that fixed release. Spec-only means there is no
fixed-release oracle tag. A later match does not automatically change the tag.

For a simulation fixture, adding a fixed-release tag requires reproducing its expectation at both prescribed seeds; [Adding or correcting a test](testing.md#adding-or-correcting-a-test) describes that contribution step.

**Review / `:spec_check:`** — Who checked the expectation against the standard.
`ai` records AI review; `human` records human review. It is separate from
whether a simulator matches. All current tests record `ai`.

## UVM building blocks

These names describe roles inside a testbench; [the smoke test source](../tests/u09/test_common_phases_run_in_order.sv) shows a test class, phases and an objection, and [the test-format guide](testing.md#example) explains its header.

**Object / component** — A UVM data or policy object / a node in the UVM
component hierarchy that participates in phases. Components include tests,
environments, drivers and sequencers.

Two handles can refer to the same object, so passing a handle does not itself copy its data; [typed analysis inputs](faq.md#q40-can-a-generated-master-imp-use-separate-request-and-response-objects) provide an example of observing that identity across a connection.

**Factory / wrapper / registry** — The type-based creation and override
mechanism / a proxy describing a registered type / helpers that register and
create objects or components through the factory. A type name and an instance
path play different roles in override selection.

**Configuration database / resource** — Typed values selected by scope and
field name / the underlying configurable values and lookup mechanisms. The
suite checks scope, type, precedence and updates, while recording the pinned
library's field-name glob limitation.

A lookup depends on the requested scope, field name and type, and [the library limitations](known-differences.md#pinned-library-limitations) explain the retained field-name glob difference.

**Policy / copier / comparer / printer / packer** — Objects controlling copy,
comparison, printing and packing operations. Tests inspect defined values and
hooks; a library-specific printed layout or packed object encoding is not
automatically a required format.

**Phase / task phase** — A stage of UVM execution / a phase whose callbacks
are tasks and may consume simulation time. Traversal order and termination
rules differ by phase kind.

**Objection / drain time** — A counted indication that a phase or activity
should remain open / a configured delay during all-dropped processing.
An object's own count, the propagated total and the objector list are distinct
observations; one cannot stand in for all the others.

**Sequence item / sequence / sequencer / driver** — A transaction / the
stimulus-producing procedure / the component arbitrating and routing it /
the component consuming requests and returning completion or responses.
The suite connects their public ports and exports before testing traffic.

**Acknowledgement / response** — Completion notification for a request,
for example `item_done` / data returned to its sequence. `get` acknowledges
a request implicitly. Acknowledgement alone does not mean a separate response
was delivered.

**Grant / `send_request` / completion wait** — Permission to submit an item /
the low-level submission call / waiting for `item_done` or implicit `get`
acknowledgement. Submission follows a grant without a simulation-time delay.
A waiter for a specific transaction ID must start before its acknowledgement.

**`start_item` sequencer selection** — An explicit sequencer argument takes
precedence, followed by the item's sequencer and then the current sequence's
sequencer. A nonnegative item priority is used directly; a negative value
inherits the sequence priority. Invalid items or missing context require ERROR.

**Transaction ID / sequence ID / `set_id_info`** — The request/reply identifier
used for selective response retrieval / the sequence-routing identity / the
API copying the relevant IDs into a response. Tests print explicitly assigned
transaction IDs rather than implementation-assigned sequence ID numbers.

**Arbitration / priority / relevance** — Selection among requesting sequences /
a selection input / whether a sequence is currently eligible. USER mode
delegates selection to a callback; a relevance override supplies a matching
`wait_for_relevant` implementation.

**Lock / grab / unlock / ungrab** — Sequence ownership and its release.
Lock joins regular arbitration; grab goes to the front, while still waiting
for incompatible existing ownership. A child can acquire under its parent's
lock and temporarily block that parent. `has_lock` and `is_blocked` answer
different questions.

**Kill / `do_kill` / `stop_sequences`** — Termination of a sequence / its
termination hook / termination and queue cleanup for a sequencer's active
sequences. The required post-kill `post_body`/`post_start` hooks are separate
from `do_kill`; the pinned library's omission is retained as a known difference.
Automatic starting-phase objections must also drop on stop; the pinned root
stop path leaves them raised, unlike direct `kill`.

**Default phase sequence** — A sequence selected from a typed `default_sequence`
resource at a sequencer/phase scope. A wrapper requests factory creation; an
instance resource supplies the object directly. Selection uses precedence,
and a selected null disables the default. The sequence receives its sequencer
and starting phase, is randomized unless disabled, and is killed if still
running at phase end.

**Resource precedence / queue priority / type filtering** — The value ranking
matching resources / their order within the name or type queue / removal of
types not permitted by the default-sequence rule. Equal highest precedence
selects the first remaining entry. A typed sequence instance does not inherently
outrank a wrapper; a null of an unrelated resource type does not disable a default.

**Callback / typewide registration / iterator** — A registered extension hook /
registration applying to a callback type pairing rather than one instance /
an object that traverses the applicable enabled callbacks. Registration order,
inheritance and early-exit behavior are separate test subjects.

**Sequence library / registered wrapper** — A sequence that selects from a
collection of sequence types / a factory descriptor identifying one such
type. Instance registration is local; typewide additions affect future
instances. Enumeration appends to the caller's queue.

**Library selection mode / execution count** — The rule used to choose a
registered sequence / the number of completed children, excluding the active
child. The default user-selection hook visits indices zero through its
inclusive maximum and then wraps. Calling that hook directly does not execute
a child or establish a USER-mode run.

**Field `rand_mode` / child randomization enable** — Whether a particular
random field can change / whether a child sequence action calls `randomize`
at all. Disabling one field still permits randomization callbacks. The two
controls are tested separately.

**Static library member / subtype construction** — A sequence type registered
by `uvm_add_to_seq_lib` / constructing a library subtype with its utilities
macro and constructor. Registered members, including inherited members,
must be available through public enumeration. Instance additions are separate.

**`finish_item` delegation / completion ID** — The sequence's virtual send
and wait methods used by the convenience operation / the item's transaction
ID passed to that wait. Delivery alone does not establish that these required
calls and argument values were preserved.

**Extension type handle / type-handle name** — An opaque key identifying a
TLM 2 extension type / its identifying name. These identify a type rather
than one named instance. Payload lookup uses the handle, while tests compare
type-name relationships without prescribing a qualified-name format.

**Database connection hook** — A database extension's open/close implementation.
Connection-only fixtures count calls and control success without an external
backend. Separate in-memory stream hooks check lifecycle metadata; connection
state alone does not establish recording behavior.

**Unique-key count** — Pool occupancy counts distinct stored keys. Replacing a
value for an existing key does not add an entry; missing-key creation and
key deletion can change the count.

**Pending ownership cleanup** — Removing queued lock/grab requests when a
sequence is killed or a sequencer stops its sequences. A later successful
transfer and a surviving waiter distinguish cleanup from an idle stop.

**Cumulative statistics copy** — Report-server copying merges source statistics
into destination state: source entries replace matching counts while
destination-only IDs survive. A source zero count can overwrite a nonzero count.

**Emission membership** — Presence of a chosen field name or value in emitted
printer output. Distinct markers allow checks across name controls, negative
array bounds and reuse without prescribing layout.

**Comparison report window** — The interval inside a comparison hook during
which individual miscompare reports are counted. Later framework rollups are
outside that interval; the comparer result still counts every field failure.

## Transaction-level communication

TLM carries transactions between testbench components, and [Q25](faq.md#q25-does-a-tlm-delay-annotation-advance-simulation-time) explains why an annotated delay and an actual wait have different effects.

**Push sequencer / push driver** — A sequencer that calls a driver's blocking
`put` / a driver that receives those calls through `req_export`. Returning
from `put` completes that request. Responses can travel independently through
the driver's analysis `rsp_port` to the sequencer's `rsp_export`.

**Sequence action macros** — `uvm_create` creates and sets context;
`uvm_send` executes without randomization; `uvm_rand_send` randomizes and
executes; `uvm_do` combines creation with randomized execution. Child sequences
honor their randomization-enable bit and start with `call_pre_post` zero.

**Payload packing / active array length** — Serialization of the TLM 2 generic
payload's prescribed fields / the number of data or byte-enable bytes included
from a backing array. Extra bytes are omitted; an undersized backing array
requires a fatal report. Extensions are outside the default packed fields.

**TLM / port / export / implementation** — Transaction-level modeling /
a caller-side interface / a forwarding interface / the endpoint implementing
the interface. Normal elaboration resolves bindings before traffic is observed.

**Master / slave / split imp** — A TLM 1 interface that puts requests and reads
responses / one that reads requests and puts responses / an imp delegating
those directions to separate sibling components. The `req_imp` and `rsp_imp`
constructor arguments select instances independently of the parent.

**Ordinary TLM 2 export / type parameters** — A forwarding connection between
a port and an implementation / the transaction and nonblocking phase types
carried by that connection. Forward and backward paths are connected
separately. Generic type propagation is distinct from base-protocol coverage.

**FIFO / blocking / nonblocking** — An arrival-ordered queue / an operation
that can wait for data or space / an operation that reports availability or
success without that wait. A failed read's output argument is checked only
when the standard specifies it.

In a UVM TLM FIFO, a successful peek leaves the item queued while publishing a notification, and [Q36](faq.md#q36-does-peeking-at-a-fifo-publish-a-get_ap-notification) explains that distinction between storage and observation.

**Analysis port / analysis FIFO** — A write interface distributing a value to
subscribers / a FIFO accepting those writes. A write can distribute an object
handle; it does not necessarily clone that object. Tests avoid assuming an
unspecified order among subscribers.

**FIFO `put_ap` / `get_ap`** — Analysis notifications for accepted writes /
successful get and peek observations. A peek retains the queued item while
still requiring a notification. Availability queries and failed transfers do
not supply a transaction to publish.

**Explicit-object callback dispatch** — Calling registered callbacks for an
object passed to the macro, independently of the calling object's own
registration. Disabled entries are skipped; an exit-on macro stops on the
selected boolean result. Tests do not impose a no-match return policy.

**TLM 2 payload / extension / socket / phase / delay** — Transaction data /
additional typed information / a transport connection / protocol progress /
a timing annotation. A TLM 2 protocol phase is different from a UVM execution
phase. Accessor and connection tests do not establish full protocol or timing
coverage.

**Canonical time / `uvm_tlm_time` / annotation** — A delay represented
independently of a caller's time scale / the `uvm_time` typedef used by TLM 2 /
an offset carried with a transaction timing point. Changing an annotation
does not itself advance simulation time. Absolute APIs specify seconds per
unit; scaled APIs also require a corresponding nonzero time-literal value.

**Pass-through socket** — A hierarchical TLM 2 connection. A nonblocking
initiator pass-through is a forward port with a backward export; a target
pass-through is a forward export with a backward port. Socket `connect`
methods provide the reverse connections as well as the forward path.

**Callback integer iterator / facade** — An opaque integer position used by
`uvm_callbacks::get_first/get_next/get_last/get_prev` / the object interface
`uvm_callback_iter`. Exhausted static traversal stays null until restarted.
A null object context searches the typewide queue. Separate positions or
facades permit independent traversal.

**Imp declaration macro / suffix** — A macro creating a distinct TLM imp class
for an interface / the text appended to that class and its implementation
method names. Ordinary ports still call `put`, `get`, etc.; a generated imp
delegates to methods such as `put_left` on its bound implementation object.

**Implementation types / implementation handles** — Type parameters such as
`IMP`, `REQ_IMP` and `RSP_IMP` / constructor arguments selecting the actual
objects. A generated master imp can delegate requests and responses to two
siblings while its parent owns the imp without transfer methods.

**Typed analysis input** — An analysis connection whose transaction type may
be a class handle. A suffixed write handler receives that handle; selecting
another input does not itself clone or change the transaction.

**TLM 1 nonblocking transport / `nb_transport`** — A request/response operation
that returns 1 for immediate completion or 0 when it cannot complete
immediately. A synchronous analysis callback can supply the response during
the call. A 0 does not establish a particular response output value or that
no partial request-side effect occurred.

This TLM 1 result is a completion bit as described in [Q20](faq.md#q20-how-can-nonblocking-transport-return-a-response-immediately), while TLM 2's nonblocking `nb_transport_fw` and `nb_transport_bw` calls return a synchronization enum and carry a phase as illustrated in [Q96](faq.md#q96-are-the-new-tlm-2-tests-protocol-validators-or-simulator-schedulers).

**Failed-read sentinel** — A nondefault value or nonnull handle passed into an
unavailable nonblocking TLM read to observe its stated unchanged-output contract.
The UVM `output` formal and SystemVerilog copy-out semantics create a separate
interpretation issue; failure values for register/memory reads are not inferred.

**Response identity** — A response's sequence and transaction routing IDs,
usually copied from its request. Equal transaction IDs across live sequences
must still route separately; duplicate matches need not imply a tie order.

## Register model

A register model keeps software state separately from accessed storage; see [What this repository tests](reading-guide.md#what-this-repository-tests) before equating model updates with physical transfers.

**Register / field / block** — A model of a value accessed as one entity /
a contiguous set of bits with a shared policy / a container grouping registers,
maps and child blocks. Register byte width rounds up when its bit width is
not a whole number of bytes. Field enumeration follows increasing bit position.

**Desired / mirrored / `needs_update`** — The requested model value / the
value currently recorded by the model / a query for writable state needing
an update. `set` changes desired state under the access policy; direct
prediction synchronizes both views. Neither operation reads or writes a DUT.

For model-only operations, [Q45](faq.md#q45-do-set-predict-and-reset-access-the-dut) compares how desired and mirrored values change while accessed storage stays untouched.

**Access policy / map rights** — A field's read/write rules, such as RO, RW
or W1C / the register's access restriction through one map. Both participate
in effective field access. Model-only `set` also applies the field policy.

For memory, rights and effective access are separate query contracts, and [Q398](faq.md#q398-why-can-memory-rights-and-effective-access-differ) shows why an RO interface can have different answers to those queries.

**Reset kind / model reset** — A named reset event, such as HARD or SOFT /
restoring desired and mirrored values for that event. An unconfigured kind
leaves the field unchanged. Resetting a block reaches its child blocks and
does not itself reset physical hardware.

**Address map / local offset / physical address** — A model of an interface's
address space / a register's position within it / an address visible through
the root interface. Address units can be bytes or bus words. Returned address
arrays follow data significance; submaps combine offsets and bus widths.

Before interpreting a returned number as a byte address, use [Q46](faq.md#q46-are-map-addresses-bytes-and-why-can-the-returned-list-run-backwards) to check the configured address unit and the ordering of the returned words.

**Frontdoor / backdoor / predictor** — Access through a modeled bus path /
direct access to the design's storage / model updates derived from observed
transactions. M3 now exercises frontdoor paths with a testbench bus model and passive
prediction from supplied observations, plus user-defined storage backdoors.
The separate [VPI HDL subset](testing.md#verilator-vpi-hdl-subset) accesses actual public HDL storage; its results apply to that backend condition. See the
[register-model FAQ](faq.md#register-model-basics).

**Memory / location / location index** — A model of contiguous storage /
one stored word / the word selected within that memory. `uvm_mem` records
geometry without mirroring every location. Local offsets and external
addresses incorporate location stride. Frontdoor cases transfer data through
a testbench driver; that storage belongs to the fixture.

**READ / WRITE prediction** — Updating model state from a supplied observation
and its access-policy effects. RC/RS apply read effects; W1C/W1S/W1T and
W0C/W0S apply selected-bit write effects. Supplying the observation does not
execute a bus operation. A write-once field is rearmed by HARD reset.

**Map reset / relocation / directional lookup** — Restoring a map's register
models, with SOFT as the default kind / moving an element or submap's offset /
selecting a shared-address register by read/write direction. Mode getters and
address queries do not establish bus behavior. See the
[memory and prediction FAQ](faq.md#memory-prediction-and-map-controls).

**Register adapter / operation context** — Conversion between a generic bus
operation and a protocol-specific item / the read-only `get_item` reference
available inside `reg2bus`. Separate driver responses are selected by
`provides_responses`; context is absent outside the conversion callback.

**Predictor / reg_ap / pre_predict** — A component consuming bus observations /
its generic-operation publication port / a hook for value or target changes.
Wide operations accumulate bus words before publication. Memory observations
are excluded. The published observed value can differ from the post-policy mirror.

**Frontdoor bus model / auto-prediction** — Register or memory read/write traffic through
an adapter, sequencer and testbench driver / automatic register-mirror update after
that access when enabled. This tests UVM traffic without establishing an RTL
bus implementation. See the [path guide](faq.md#adapter-predictor-and-frontdoor-paths).

**Update / mirror / access status** — Writing desired register state when
needed / reading and optionally checking mirrored state / the operation's
success or failure. Update encodes the field policy into bus write data;
a failed read does not supply a portable data value.

**Register access hooks** — Inherited pre/post read/write methods that can
change a value or status, or reject an access before a bus request.
They are distinct from registering callback objects. See the
[access-hook FAQ](faq.md#memory-transfers-and-register-access-hooks).

**Custom frontdoor / rw_info** — A user access sequence associated with a
register or memory / its abstract operation descriptor. Current custom cases
model storage in that sequence, separately from adapter/driver handshakes.

**Registered register callback / post_predict** — A callback object attached
to a register or field / a hook that can change a successful READ/WRITE
prediction's result. This is separate from overriding the element's methods.

**Virtual register / virtual field / increment** — Logical fields overlaid
on memory / one bit slice of that logical register / the spacing of array
elements in memory words. The byte width is rounded to whole implementing
memory locations. Current tests include static layout, selected frontdoor
transfers and dynamic implementation/release. See the
[layout example](faq.md#custom-frontdoors-registered-callbacks-and-virtual-registers).

**Memory allocation manager / region / relative offset** — Exclusive
reservation of memory locations / a descriptor for a reserved range / a
location index within that range. Byte requests round to complete memory
locations. Virtual arrays use `implement`/`release_region` to manage their
backing reservation. The descriptor's owner query is a separate contract.
See the [transfer and lifecycle FAQ](faq.md#virtual-register-transfers-and-memory-regions).

**Virtual allocation / supplied policy** — Selecting a backing region through
`uvm_vreg::allocate` and a memory allocation manager. Current policy fixtures
fix one legal start; they do not establish statistical allocation behavior.

**Virtual write-hook order** — Field before virtual register on pre-write,
register before field on post-write; registered pre callbacks follow their
method and registered post callbacks precede it. The standalone field post
case retains a library difference. See the
[callback FAQ](faq.md#virtual-allocation-callbacks-and-user-backdoors).

**User backdoor / peek / poke** — A `uvm_reg_backdoor` implementation /
sampling storage / depositing raw data. The current subclasses use testbench
storage without HDL DPI, with required pre/post helper dispatch. Physical-style
`read`/`write` still apply register access policies.

**Annex E built-in test sequence** — A standardized register/memory test
such as `uvm_reg_hw_reset_seq`. The current fixtures cover reset, bit bash,
register access and memory walk through testbench storage. See the
[sequence FAQ](faq.md#annex-e-built-in-test-sequences).

**Exclusion resource / REG namespace** — A `uvm_resource_db#(bit)` entry in
`REG::` used by built-in sequences to omit a matched block, register or memory.
The current fixtures use exact scopes with independent positive controls.

**Fault injection / positive control** — Deliberately changing a known-working
fixture / a successful check that establishes the observation path works.
Annex E cases introduce data faults after a clean run and observe additional
diagnostics without requiring exact messages or internal test patterns.

**Memory access sequence** — `uvm_mem_single_access_seq` or
`uvm_mem_access_seq`, comparing frontdoor writes with backdoor reads and
then reversing the paths. Current fixtures cover four testbench locations.
See the [memory-access FAQ](faq.md#memory-access-shared-maps-and-test-selection).

**Cross-map visibility** — A write through one map becomes readable through
another map of the same register or memory. The fixtures record writer/reader
pairs per location, independently of map iteration order or random payloads.
See the [shared-map FAQ](faq.md#memory-access-shared-maps-and-test-selection).

**Built-in test selection mask** — The 64-bit `tests` property of
`uvm_reg_mem_built_in_seq`. Flags from `uvm_reg_mem_tests_e` select families;
bitwise OR combines selections in the order defined by 17.2.2.10. See the
[dispatcher FAQ](faq.md#memory-access-shared-maps-and-test-selection).

**Registered custom access policy** — A valid field-policy name introduced by
`uvm_reg_field::define_access`, whose behavior may still be unknown to a built-in
test sequence. Skip checks use a known-policy peer as a positive control.

**Partial physical beat** — A physical access carrying fewer valid model bits
than the bus width. A twenty-four-bit memory on a sixteen-bit bus expects
`n_bits` widths 16 and 8. A twenty-bit model introduces a sub-byte logical-width
versus rounded-byte interpretation requiring review. Unused data bits remain
unconstrained; burst-array element packing is separate.

**Partial prediction isolation** — Separate accumulation of observed bus words
for different wide registers. One completed register may publish while another
retains its prior mirror until its own final word arrives.

## Execution and result records

The result file stores the labels defined below for each selected test, and [the JSON-reading example](reading-guide.md#open-the-result-json) shows how to extract them from your own run.

A compile rejection can be the expected success of an illegal-design check; [Interpretation](results.md#interpretation) explains how that differs from a runtime failure.

**Runner / metadata** — A `tools/run_*.py` script that builds, executes and
judges tests / the fields in the test's initial comment controlling that work.
The supported options and library mode are part of the execution conditions.

**Fixture / helper** — The setup, stimulus and observers used by a test / supporting
code or data used to build that setup. A fixture may model storage in the testbench;
its name alone does not imply a physical DUT. Declared helpers are part of the
test's input fingerprint; see [the test-format examples](testing.md#example).

**`pass` / `fail`** — The expected output and specified exit/diagnostic checks
matched / a check failed, or the test could not build or run. One failing test
is not necessarily one distinct simulator bug.

**`known` / `unsupported`** — In this Verilator runner, an untagged test fails
validation, including a build failure / kirimasim explicitly reports a
construct as unsupported.
Neither is a pass. Ghost uses `pass`/`fail`; it does not relabel bundled-library
differences as `known`. [FAQ Q6](faq.md#q6-why-can-verilator-exit-successfully-with-known-results) explains why Verilator may exit successfully with known differences.

**Seed / two-state / four-state** — An input controlling randomized execution
conditions / values without X and Z / values including X and Z. The fixed
Verilator oracle uses seeds 1 and 73 for X/Z-independent tests. Two passing
seeds do not prove correctness for every seed.

**DPI / `UVM_NO_DPI`** — The SystemVerilog interface to external code / a macro
disabling UVM's DPI-dependent implementation paths. The ordinary runner uses it for tests that do not request DPI.
Removing the macro does not itself provide or link the required C/C++ code; [the library setup](testing.md#the-uvm-library) explains the ordinary, HDL and command-line conditions.

**Pinned library / lock / bundled library** — The exact library identified by
`third_party/uvm.lock` / its version, commit, file count and content digest /
a library supplied through a simulator/profile. Bundled results do not establish
execution with the pinned library.

**Fingerprint / SHA-256 / combined evidence** — A content identity used to
compare inputs or tools / its digest algorithm / results from multiple batches
combined after checking input, runner and configuration identities. A matching
fingerprint supports reuse of recorded evidence; it is not a new execution.

When reusing a result, compare the identities listed in [Evidence assembly](results.md#evidence-assembly) to check that the recorded inputs and execution conditions still apply.

**Watchdog** — A bounded timeout in a blocking test that turns a missing
completion into a visible failure. Positive delays let a test observe waiting
without relying on process order in the same simulation time slot.

## Scope and coverage

A clause citation locates a reference but does not establish a tested duty; [Citations, requirements and execution evidence](requirements.md#citations-requirements-and-execution-evidence) explains the additional requirement and observation links.

**M0–M4** — The [development stages](../README.md#plan): infrastructure, core
UVM, TLM/sequences/callbacks, register layer, then a reviewed requirement ledger.
Starting a later stage does not certify completion of the previous stage.

**Clause citation / requirement coverage / match count** — A reference in
metadata / evidence that defined requirements and conditions are exercised /
the number of tests matching in a specified execution. These have different
denominators. This repository has not approved a requirement-coverage denominator;
neither the test total nor the oracle count is such a percentage.

Register-model coverage APIs describe available measurement models and sampling hooks; [Q311](faq.md#q311-does-coverage-construction-measure-functional-coverage-bins) distinguishes those tests from functional-bin measurements, while [the counting guide](requirements.md#counting-unit-and-scope-proposal) defines M4's requirement-coverage unit.

**Check / Nightly** — This repository's validation workflow / the separate
scheduled reporting workflow used by kirimasim-tests. This repository currently
has Check only. Its badge does not report a full multi-simulator match rate.

**Requirement ledger / stable requirement ID** — A versioned decomposition
of normative behavior into observable obligations and conditions / a name
independent of test filenames. The [current ledger](requirements.md) is partial
and all entries are AI drafts; its length is not an approved denominator.

**Direct link / control link / expected observation** — An explicit test of
a requirement / a fixture or comparison control / an anchored line in expected
output. A control does not supply direct coverage, and an oracle anchor is
not measured execution evidence.

**Primary focus / supporting citation** — The first UVM clause in `:lrm:` /
a later UVM clause. The census counts these separately without automatically
creating requirements or aggregating child clauses into parent coverage.

**Proposed scope / approved denominator** — A reviewable candidate set and
counting rule / a frozen requirement set accepted after decomposition and
review. The latter remains unset; deferred deprecated APIs are not approved
exclusions. See the [M4 approval path](requirements.md#remaining-m4-work-and-approval).

**Review backlog / root total** — Generated work items needing requirement
mapping or decomposition / an inventory grouped by the first clause-number
segment. Requirements use their own clause and tests their primary citation.
The [backlog command](requirements.md#review-work-queue-and-root-totals) retains
control-only requirements and context/deferred identifiers; it does not turn
unassessed items into confirmed conformance failures.

**Ledger input identity** — The `ledger_inputs_sha256` of a generated inventory
or backlog: a portable identity of validated scope, requirement data, identifier
assessments, test index and catalog. JSON formatting is normalized; array order
and catalog bytes are retained. See [report identity](requirements.md#generated-report-identity).
The same identity across views does not approve coverage or identify measured
simulator execution.

## Container and memory-hook observations

**Container cursor** — The key passed by reference to pool endpoint/step
methods. An unsuccessful empty endpoint or terminal step preserves it.
Traversal tests check membership and uniqueness without prescribing an extra
ordering convention.

**Global container singleton** — The shared pool or queue returned by its
static global accessor for a specialization. Local instances remain independent;
keyed/indexed global retrieval observes the shared contents.

**Waiting consumers and observers** — Pending FIFO gets consume each arrival
once, while pending peeks may all observe one head without removal. The
concurrency fixtures leave the scheduler's choice of consumer unconstrained.

**Memory hook routing** — A memory pre-access callback can change the operation
descriptor before transfer, including its offset/map. Post-access callbacks and
methods compose return data/status after transfer. Each method/callback ordering
rule must be checked for `uvm_mem`; register behavior alone does not establish it.

## Synchronization and transport histories

**Event persistence** — The on-state persists until reset. A persistent trigger
wait instead recognizes a trigger only within its current time slice; a later
time slice needs a fresh trigger even while the on-state remains set.

**Barrier threshold** — The number of participants required at a synchronization
point. Default auto-reset requires a fresh group on reuse; disabling it keeps
the reached barrier open until reset. Release order is not part of these tests.

**Nonblocking transport history** — A testbench-driven series of forward and
backward phase calls separated by waits. Sockets forward the supplied phase,
payload/delay handles and enum results; the fixture owns outstanding state and
scheduling. Timing annotation is distinct from a simulation-time wait.

**Post-read prediction** — A READ prediction uses the supplied sampled value and
records any access-policy side effect in desired/mirrored state. A predicted
clear/set is not itself evidence of a physical read or its returned data.

## Hierarchy, binding and HDL descriptions

**Hierarchy name cursor** — The child name passed by reference to component
iteration methods. Empty or exhausted queries preserve it; it identifies a
position within the selected parent rather than a global component search.

**Resolved implementation** — A final TLM imp reached by following compatible
port/export connections. Post-elaboration size counts these destinations,
and indexed interface handles identify them without requiring a provider order.

**HDL path kind** — A symbolic design-abstraction selector such as RTL or GATE.
Element queries can use their parent block default; an explicit kind and a
default argument need not select the same abstraction.

**Absolute HDL path root** — A register-block path prefix that replaces
ancestor/incremental HDL paths for one kind. It is distinct from the implicit
UVM component root and does not establish that a named HDL object exists.

## Callback dispatch, cancellation and model introspection

**Pre-trigger veto** — A nonzero callback return that prevents one event
trigger and its post-trigger hooks. It does not remove the callback or cancel
a waiting process.

**Waiter cancellation** — Explicit removal of a blocked participant from an
event/barrier count after its process is disabled or otherwise activated.
Killing a process and calling cancel are distinct operations.

**Overlapping blocking calls** — Two task calls whose execution intervals
overlap. Each caller waits for its own callee; separate payload/delay objects
allow routing and completion to be checked without shared-object races.

**Model introspection** — Queries of a configured register model's parent
handles, contained objects or names. These describe the model hierarchy and
do not by themselves execute an address-map transfer or access HDL storage.

## Recording lifecycle and field metadata

**Recording stream** — A database-owned container for transaction recorders.
A local hook can supply an in-memory stream for lifecycle checks without an
external database or any recorded transaction contents.

**Stream handle** — An integer identifier resolved to a stream by a static
lookup. It remains valid through close and becomes invalid after free;
exact numeric values and future ID reuse are outside the fixtures.

**Reset metadata** — A field's reset values indexed by kind. Assigning or
removing this metadata is distinct from resetting live desired/mirrored state
and from asserting a physical reset signal.

**Field compare control** — The model setting selected by set_compare and
returned by get_compare. Observing this setting alone does not establish
that a mirror read performed or suppressed a comparison.

## Recorders and indirect access

**Recorder** — A record owned by a stream and a policy for recording its
fields. Local implementation hooks can retain lifecycle and scalar arguments
without producing an external database format.

**Socket declaration bounds** — The minimum and maximum connection counts
specified by a socket constructor. These differ from the resolved destination
count and do not establish that any transport has executed.

**Index/data register pair** — An address register that selects an array
element and a data register through which that element is accessed. The
fixtures complete an explicit index write before accessing the data port.

**Selected-array prediction** — Updating the array-register mirror selected
by an indirect index after an observed modeled transfer. Other array mirrors
retain their previous values; the testbench storage remains a separate state.

## Phase identity and coverage sampling

**Phase implementation and node** — An IMP supplies reusable phase behavior;
a schedule node carries individual graph context/state. Different nodes may
share the same singleton handle for behavior while retaining distinct node
handles. That sharing alone does not prove every concurrent state/lifetime
condition.

**Coverage model availability** — The measurement models declared by a
register, memory or block abstraction. Availability does not mean collection
is currently enabled or that any bins have been sampled.

**Coverage enable mask** — The available models whose measurements are
currently enabled. Changing this mask is distinct from querying availability;
the standard specifies that set_coverage returns its previous enabled mask.

**Sampling hook** — A user-overridable method that observes an access or
current model values for measurement. Counting hook calls can check dispatch
and timing without constructing covergroups or producing coverage percentages.

## Component streams, report context and read comparison

**Component recording** — Recording through a component's selected database
and streams. It has a separate enable control from a transaction's own
recording path and can invoke transaction property hooks at component end.

**Stream cache key** — The requested stream-name/type pair within one
component. Repeated requests preserve identity until the reference is released
or the stream is freed; another component has a different scope.

**Sequence report context** — A message context string, filled from the
sequence-parent path when empty. It is distinct from the sequencer or root
report object that supplies the handler and verbosity configuration.

**Check-on-read** — A map setting that compares sampled register/field data
against the existing mirror and reports discrepancies. Comparison control
and auto-prediction are separate settings; the fixtures enable prediction
explicitly and respect per-field compare masks.

## Core services, wrapper indices and ordered bus operations

**Core service** — The shared access point for central UVM services and
default policies. Selecting a service handle does not itself establish the
service's behavior or a custom initialization procedure.

**Implementation default policy** — The policy instance returned when no
explicit default is selected or after a null reset. Its concrete type and
identity are implementation choices; it differs from a per-call policy argument.

**Sequence wrapper index** — A position resolving to a registered sequence
type wrapper within one library. Looking up that wrapper does not execute
the sequence and does not impose a universal registration order.

**Register transaction-order policy** — A hook that permutes complete physical
bus-operation structs for one logical register read/write. Address/data binding
and logical read reconstruction must survive a change in execution order.

## Traversal and access wrappers

**Visitor** — An object receiving callbacks for nodes selected by a traversal
adapter. Its begin/end callbacks surround a traversal unless disabled.

**Structure proxy** — An adapter-facing object that enumerates a node's
immediate subelements, allowing a traversal strategy to work on different
structure types.

**Traversal partial order** — Required relations such as parent-before-child
or child-before-parent, leaving unrelated sibling order unconstrained.

**Register-sequence convenience method** — A wrapper for a register or memory
access that supplies the calling sequence as parent and forwards the other
specified access arguments.

## Matching and descriptor state

**Simplified matching notation** — Whole-string matching with star, plus and
question denoting zero-or-more, one-or-more and exactly-one characters.
Other tested nonmetacharacters retain their literal meaning.

**Enum name conversion** — Conversion of an exact, case-sensitive enumerator
name into its enum value. Failure is reported separately from the output value.

**Response queue clearing** — Removal of pending replies for one sequence.
It permits fresh replies to arrive and does not clear another sequence's queue.

**Register operation descriptor** — An abstract transaction object holding
element, access, data, map, status and origin metadata. Reading or updating
that object alone does not perform a physical register access.

## Search scope and state masks

**Root component search** — A public root lookup comparing component full
names with a pattern and returning matching handles.

**Search starting component** — The component from which a scoped search
descends, including that component when it matches. Patterns still use full names.

**Sequence-state mask** — A bitwise combination of accepted sequence states;
a wait returns when the receiver reaches any selected state.

**Memory convenience accessor** — A register-sequence poke/peek wrapper that
supplies its sequence as parent while accessing a selected memory location.

## HDL execution conditions

An HDL path names an object the backend must actually resolve in the simulator; [the HDL setup](testing.md#verilator-vpi-hdl-subset) explains the visibility and execution conditions needed to access it.

**VPI (Verification Procedural Interface)** — A public simulator API for
finding HDL objects and inspecting or changing supported values. A real
handle lookup differs from a fixture that maps path strings to local storage.

**HDL backend evidence condition** — The specific runner, linked DPI/backend,
HDL visibility and supported types used for a measurement. Results under an
original limited backend do not establish another backend's behavior.

## Representation selection and interpretation

**Abstraction list** — The selected HDL representation names for a path check.
A nonempty list chooses its entries; an empty list uses the block default.

**Historical algorithm interpretation** — A recorded reading of an underspecified
algorithm using an official earlier reference. It is reviewable context,
not a new normative amendment or automatic proof of current conformance.

## Identifier classification and configuration conditions

**Identifier assessment** — An explicit reviewed classification of one catalog
identifier as structural or contextual, with bilingual rationale. It is separate
from an observable requirement and never supplies a passing execution result.

**Strict configuration condition** — A pinned-library build setting that
changes resource selection for automatic configuration. Its measurements
remain distinct from default-mode results and retain the same normative oracle.

## Registry proxies, history and model locks

**Registry singleton** — The shared wrapper returned by get for one registry
specialization. It represents a type without constructing an instance of it.

**Sequencer history capacity** — The configured maximum retained request or
response history, independent of traffic delivery and lifetime traffic counters.

**Model lock state** — A register model's structural lock status. Building
address lookups with lock_model differs from changing flags with set_lock;
it does not denote sequencer ownership or a hardware bus lock.

## Abstract proxies, ID copying and map removal

**Abstract registry** — A proxy for a virtual object/component type that can be
registered without constructing it. Creation needs a concrete factory override.

**ID information copy** — Copying response-routing sequence and transaction
identifiers with set_id_info, independently of payload or name copying.

**Block map unregister** — Removing a selected map and its contained models
from a block's knowledge. Its scope is distinct from executing a bus access or
selecting a default map after removal.

## Recording callbacks and execution hierarchies

**Recording callback** — An overridden database/stream/recorder method that
handles backend work. A null stream/recorder result prevents initialization.

**Optional body hooks** — Sequence pre_body/post_body calls selected by
call_pre_post. Start hooks and parent callbacks follow separate contracts.

**Block hierarchy / map hierarchy** — Register-model block ancestry versus
address-map submap connections. A child block's map need not be a local map's
submap for logical block-name introspection.

## Constructor arguments and register-file paths

**Omitted name / explicitly empty name** — Calling a base constructor without
its name argument selects the base default; supplying an empty string is an
explicit argument. Concrete forwarding extensions keep these cases distinct.

**Register-file HDL contribution** — A local path component contributed by a
logical register file. Flattened files add no scope name; alternative parent/
local components can yield several full symbolic paths.

**Enclosing abstraction default** — The nearest enclosing register-file/block
default selected by a register file's local path/presence APIs. It differs from
querying the current file's own explicit default. See
[Q147](faq.md#q147-which-hdl-abstraction-default-does-a-register-file-query-use).

## Heartbeats, virtual accessors and FIFO models

**Heartbeat window** — An interval bounded by trigger events in which monitored
components participate through a synchronizing objection. The new healthy
window fixture explicitly selects ALL_ACTIVE; broader mode/failure conditions
remain separate.

Activity in this window means objection participation, and [the heartbeat questions](faq.md#heartbeats-payload-dispatch-and-abstract-fifos) explain the selected mode and when monitoring begins.

**Virtual accessor dispatch** — A base-typed payload handle invoking the
derived override of a virtual accessor. Counters and forwarded values observe
selected public calls, separately from transport or packing behavior.

**Abstract register FIFO** — The public queue and capacity of a register-layer
FIFO model. The selected get observes its front without popping; direct queue
mutation is fixture stimulus. Inline and subtype constraint conditions are
reported separately in [Q151](faq.md#q151-why-are-inline-and-subtype-declared-fifo-constraints-recorded-separately).

## Catcher emission and printed or returned objects

**Catcher helper emission** — A supplementary report generated inside a catcher
while bypassing the catching callbacks. It is distinct from emitting the current
message through issue. See [Q152](faq.md#q152-how-do-catcher-helper-reports-differ-from-issue-followed-by-throw).

**Typed sequence print visit** — A print-hook observation on the current request
or response item under deep, unlimited recursion. It identifies the reached
object without requiring the printer's formatted output.

**Separate response identity** — The exact fresh object returned by the driver,
with request routing IDs copied to it. Contradictory request state helps detect
an in-place path used when separate responses are selected.

## Current report state and selected ownership or bytes

**Catcher mutation scope** — A change to the current message seen by later
catchers. A fresh report supplies its own attributes. Catching the report before
emission keeps callback-state checks separate from server-output checks.

**Sequence release target** — The explicit sequencer supplied to unlock/ungrab,
or the assigned default when omitted. Releasing one target does not release
ownership held on a different sequencer.

**Live neighbor / mirrored neighbor** — An adjacent field's actual bus-model
value versus its model mirror. Individual byte writes preserve the live neighbor;
whole-register fallback writes use the mirrored neighbor in a best effort.
See [Q157](faq.md#q157-does-a-byte-enabled-field-access-preserve-its-neighbor).

## Shared messages and controlled fatal observations

**Preformed report message** — A caller-created message supplied directly to a
report object for processing. Current report-object binding and callback access
to that same object are separate observable obligations.

**Controlled fatal sentinel** — A testbench-owned termination after the required
original fatal severity is observed. Declared nonzero exit and its own diagnostic
make the fixture end explicit without requiring post-fatal continuation.

**Field width / physical bus width** — The logical field size versus the data
width of each physical transfer. Layout, byte sharing and endian ordering all
matter; individual eligibility alone does not establish correct transfer data.

## Public dispatch and repeated eligibility

**Handler processing argument** — The message supplied to an installed report
handler's public processing method. Capturing that argument checks delegation
without accessing catcher internals or formatting server output.

**Relevance wake-up** — A sequence's wait for eligibility returning so the
sequencer can arbitrate again. Multiple pending requests and restarted gates
exercise separate lifecycle conditions without fixing polling counts.

**Payload byte length / valid-bit extent** — Byte-array transfer length versus
how many abstract-value bits a generic bus operation transports. Partial final
bytes need explicit interpretation; this batch does not prescribe an inverse
mapping. See [Q163](faq.md#q163-does-payload-byte-length-uniquely-recover-a-partial-byte-valid-bit-count).

## Current type and reporting bindings

**Static proxy / dynamic type proxy** — A registered class's nominal wrapper
versus the wrapper returned by an object's virtual type query. Factory overrides
can change the created dynamic type without changing the base's static proxy.

**Sequence-report admission** — The sequence interface's decision to process a
report after its enabled check. Its retained class-specific interpretation is
separate from non-INFO verbosity behavior on report objects; see
[Q166](faq.md#q166-why-can-a-sequence-report-admission-case-differ-from-report-object-behavior).

**Nonuniform conversion roundtrip** — Converting an operation with differing
byte values or enabled lanes to a payload and back, then comparing valid
fields. It tests paired consistency, not independent one-way byte order.

**Hierarchical file association** — Applying a report file setting recursively
to one component subtree. Public effective-handle queries can check scope and
precedence without fixing numeric file descriptors; see
[Q167](faq.md#q167-how-are-recursive-report-file-settings-checked-without-fixed-file-numbers).

## Declaration evidence and open conditions

**Declaration evidence** — An observation that a public type, named alternative
or signature exists and has a selected extent. It does not establish every
operation using that declaration; see [Q168](faq.md#q168-do-logic-typedef-widths-and-the-unknown-status-symbol-prove-four-state-behavior).

**Valid slice description** — Most-to-least, nonoverlapping HDL metadata that
may contain gaps, or one whole-register slice with both numeric fields -1.
Supplying a valid description does not test rejection of invalid descriptions.

**Zero unassessed identifiers** — Every catalog identifier has a partial draft
or an explicit justified assessment. This is an inventory state, not completion
of all obligations or the persistent M1–M4 goal; see
[Q170](faq.md#q170-does-zero-unassessed-chapter-17-material-finish-the-persistent-goal).

## Command-line execution conditions

**Process argument bridge** — Original glue that reads the actual invocation
through standard VPI and supplies the pinned UVM command-line DPI interface.
It does not implement the UVM parser or derive expected results.

**Condition-specific oracle marker** — Metadata selecting a reproduced fixture
for one explicitly identified runner condition. Command-line fixtures use
`:uvm_cmdline_oracle: verilator@5.052`; this does not tag an ordinary-runner pass.

**Locked quit-limit diagnostic** — The required warning when user code attempts
to change a non-overridable command-line quit limit. Correct rejection and
correct diagnostic severity are separate observations; see
[Q172](faq.md#q172-why-is-the-locked-quit-limit-correct-while-the-test-still-differs).

## Sequence field and lifecycle observations

**Standard protected-member probe** — An original subtype observation of an
explicitly standardized protected field. It checks that field's contract,
not a missing public accessor; see
[Q174](faq.md#q174-does-observing-the-protected-execution-counter-replace-its-missing-getter).

**Cyclic-field observation** — Directly randomizing the standard cyclic index
and checking finite legal-domain cycles. It does not prove that a library's
mode-controlled execution selects children through that field.

**Relevance-wait cancellation** — Terminating a sequence while its pending
request is ineligible. Stopped state, start return, survivor preservation and
subsequent real traffic are distinct observations, not a complete proof of
all termination hooks.

## User-backdoor and predictor observations

**Default-read delegation** — The inherited backdoor read task calls a user
function for the peek step while retaining its pre/post processing. Observing
this route does not test a task-based read override's boundary placement.

**Backdoor hook trace** — An original testbench observation of user hooks,
registered callbacks and the storage operation, including descriptor identity
and selected value/status propagation. It does not describe private library
queues or establish encode/decode-array behavior.

**Pre-run predictor configuration** — Map and adapter selection completed
before the run phase, with effects checked through actual mirror updates and
analysis publication. It does not promise that changing configuration during
run is supported.

## Pipeline and translation evidence

**Callback value pipeline** — Registered transformations pass their resulting
array to the next callback and the final operation path. Invocation order and
value propagation are distinct observations; a trace alone cannot prove both.

**Layered register translation** — An upstream register sequencer supplies
abstract items to a translation sequence running on a bus sequencer. Its
configured adapter and actual driver handshake carry each selected operation.

**Parameter-only HDL check** — Inspecting a public sizing parameter and its
macro-derived value without invoking HDL support routines. It provides no
force/release, physical storage or backend ABI evidence.

## Synchronization observations

**Established waiter** — A pending wait confirmed before the release stimulus
using positive timing and public waiter counts. A delayed call alone is weaker
evidence when investigating an unexpected wakeup result.

**Waiter accounting** — Reporting currently blocked processes rather than
inferring progress from an internal count reset. Event and barrier reset
contracts differ; count and actual release need separate observations.

**Initial pool membership** — Keys present immediately after construction,
before a getter can lazily create them. New-key growth and constructor naming
do not prove required default entries or settle global-access signatures.

## Objection and typed-callback evidence

**Propagation-mode observation** — Separate checks of callback routing,
source/descendant query values and legal state transitions. Skipping a hook
does not by itself establish a different total-query definition.

**Objection hook context** — The selected objection, target/source objects,
description and count delivered to component or registered callback hooks.
Metadata identity and delayed completion are observed without fixing an
unspecified relative callback-body order.

**Optional callback parameter** — Omitting only CB in callback add/delete
while using a valid registered object/callback pair. Exact type checks and
typed dispatch do not resolve omitted mode defaults or invalid-pair diagnostics.

## TLM declaration and query evidence

**Independent response default** — A declared default response type that stays
fixed when the request type changes. It differs from a response parameter
whose default follows REQ, even when both agree for all-int specialization.

**Capacity versus occupancy** — A FIFO's configured maximum and its currently
stored entry count. Zero capacity denotes no limit; it is not an occupancy
measurement or a resolution of the empty unbounded is_full wording.

**Interface-view forwarding** — Calling actual standard ports or exports
through their public virtual interface base. It checks selected type/dispatch
and forwarding paths; an original backend algorithm is not a library oracle.

## Declaration defaults and compiler checks

These terms distinguish the declared API shape from runtime behavior; [the compiler-check FAQ](faq.md#compiler-rejection-and-legal-controls) explains how illegal inputs and legal controls are judged.

**Default type argument**: The declared type selected when a parameterized
class omits a type argument. REQ-dependent RSP defaults in channels do not
settle a separate regular-port declaration's independent integer default.

**Inherited rand member**: A randomized member inherited by a derived class.
Selected payload constraints fix every reported value before public accessor
observations; they do not implement a physical bus target.

**Classification reassessment**: Re-reading a previously classified clause
and replacing the classification when a distinct normative duty is found.
The original identifier remains in scope and gains direct requirements.

**Printed provider list**: Provider class names explicitly listed by a socket
connect clause. A blocking/nonblocking naming conflict remains a qualified
interpretation even when a separate operational path works.

**Direct provider entry**: A raw connection visible to a port's direct query.
An entry left after an invalid call is distinct from a resolved executable
binding and does not establish a legal runtime path.

**Custom phase type**: An explicitly selected phase type for a parameterized
nonblocking interface. Positive exact views and selected two-way forwarding
do not settle a printed connect signature that omits the phase parameter.

**Compile diagnostic anchor**: The exact declared error regex and compile
stage attached to an illegal-elaboration requirement link. It binds an expected
oracle; matching compiler evidence is measured separately.

**Expected compile rejection**: A successful negative test in which compilation
fails with the required targeted error. It executes no runtime binary or seed
and differs from an unexpected library/API/link build failure.

**Test-kind census**: Separate simulation/elaboration fixture counts. Total
fixtures, runtime two-seed matches and expected compiler rejections describe
different quantities and do not establish a coverage percentage.

**Pure-interface fulfillment**: A concrete subtype has implementations for
every inherited pure virtual method, either defined there or inherited from a
concrete parent. Selected incomplete classes are negative compile fixtures.

**Illegal compile acceptance**: Compilation succeeds for a fixture whose
standard-derived oracle requires rejection. This is a negative-test mismatch;
the runner does not execute the resulting binary or runtime seeds.

## Reporting and policy state

A printer can expose values through hooks or emit formatted text, and [the output FAQ](faq.md#output-limits-and-routed-observations) explains which observation each fixture checks.

**Report pipeline trace**: An original catcher and server overrides expose
the order in which catching, composition and execution occur. This observes
framework dispatch without prescribing a default formatter algorithm.

**Effective file route**: The actual logging destination selected from a
severity/ID pair, ID, severity or default file association. Identity queries
and real payload writes provide separate observations of that selection.

**Printer value observer**: An original policy that inspects selected values
supplied by print hooks without fixing private field names or a built-in layout.

**Print recursion state**: The NEVER, STARTED or FINISHED history exposed for
an object and recursion selection. Hook-stage observations distinguish it from
active-object stack membership.

**Printer depth boundary**: The point at which configured maximum depth turns
object printing into reference behavior. The entry-depth equality reading is
kept separate from a scope that already exceeds its maximum.

**Printer format defaults after flush**: Defaults explicitly specified after
flush for table/tree indentation and tree/line separators. They are distinct
from selected observations of other base printer controls.

**Policy hook stage**: A field, user or completion step in the standard policy
operation order. History can become FINISHED before the active object is popped.

**Independent post-error control**: A separately constructed valid policy used
after testing an invalid request, without relying on the invalid policy's state.

## Region, sequence and component boundaries

**Region location unit**: The address unit counted by region offsets and
length. Configured bytes per location convert a byte request into whole locations.

**Region delegation observer**: An original memory subtype that observes a
region's translated API inputs and supplies response data/status. It does not
establish physical storage or bus/HDL transfer behavior.

**Sequencer interface view**: A public typed sequence-driver interface obtained
through resolved pull connectors to a real sequencer implementation.

**Rerandomization Boolean observation**: A predicate that checks whether the
request was randomized at least once without fixing retry or callback counts.

**Component domain**: The selected public phase-domain handle assigned to a
component. A hierarchical assignment can propagate it to descendants; schedule
definition and actual asynchronous execution are separate conditions.

**Child print gate**: A component's print_enabled bit controls its automatic
printing as a child. It does not prohibit a caller from printing it directly
as a root with an explicitly selected printer policy.

**User protocol dispatch**: A component base view calls a user-supplied virtual
suspend/resume implementation. Its own state is an observer of dispatch, not
a generic library process-control algorithm.

**Terminal error observer**: An original report catcher that terminates its
own simulation after observing a required generic error. It avoids prescribing
invalid-call recovery, return behavior or post-error object state.

## Component lifetime and convenience hooks

**Phase-task descendant**: A process forked by a component's phase task.
Selected lifetime probes observe whether its later writes stop after that phase,
without depending on private process handles or exact tick counts.

**Callback-spawned thread**: A process created by a phase start, ready-to-end
or end callback. Its required persistence differs from the phase task lifetime.

**Hook signature conflict**: A printed API declaration and an available callable
shape disagree, such as function versus task. A qualified declaration probe
retains build evidence separately from runtime hook-dispatch observations.

**Severity verbosity exception**: Actual warning/error/fatal reporting ignores
verbosity under the explicit report rule. A severity-ID configuration query
can still report its threshold; that query is not the actual report path.

**Empty convenience name**: The empty default at a convenience creation API.
A selected original constructor also defaults empty; that fixture does not
impose an empty name on every application constructor's fallback behavior.

## Recording callbacks and register forwarding

**Selected recording backend**: An original database/stream/recorder implementation
used to observe public recording callbacks. Its timestamp interpretation does
not standardize application-specific token or string encodings.

**Zero-length error record**: An error transaction marked with the same selected
start and end time when keep_active is omitted or zero. Backend observation
is kept distinct from universal returned-handle interpretation.

**Bidirectional declaration probe**: A called generic function requires both
implicit class assignments between an alias and its declared exact specialization.
A null completion marker does not prove callback runtime behavior.

**Forbidden registry identifier**: A type_id reference attempted on a class
whose standard declaration forbids that registry typedef. A targeted compiler
rejection is measured separately from legal constructor or iterator execution.

**Printed alias conflict**: A heading and the actual typedef printed in its
clause name different aliases. The literal spelling is preserved with a
qualified expectation rather than silently replaced by a working name.

**Named model access**: A block-level convenience call finds a register or
memory by its simple name, then delegates the selected read/write operation.

**Forwarding observer**: An original target subtype records the public arguments
and supplies a selected response. It checks a wrapper boundary without replacing
the wrapper algorithm or certifying the target's physical transport.

**Block update write census**: Per-address write counts on a selected full-width
RW hierarchy. They check minimum changed-register writes without assigning a
sibling traversal order or assuming all field policies share that count.

**Mirror check mode**: NO_CHECK refreshes selected register mirrors without
reporting old-value mismatches; explicit CHECK adds mismatch reporting. Successful
bus read/refresh is distinct from the comparison outcome.

**Milestone grouping**: Tests are counted by their functional milestone subject,
while primary standard clauses govern chapter directories. D.3 named model
access belongs to M3 even though its files reside in uD. The F.2.3 port-role
inputs use M2 by their TLM subject even though their files reside in uF. F.2.4.3
sequence-library inputs also use M2 by their sequence subject.

The B.5 TLM declaration cases likewise count toward M2 while residing in `uB`; [the declaration-scope FAQ](faq.md#q367-why-declare-the-same-suffix-in-two-packages) explains their communication subject.

Model-return predicates in u01 count toward M3 despite primary clause 1.4.2; [Q376](faq.md#q376-why-do-these-u01-cases-count-toward-m3) distinguishes them from the RNG inputs in the same directory.

The u01 profiles with primary clause 1.4.3 span M1/M2/M3 by functional subject; [Q381](faq.md#q381-why-do-profiles-under-the-same-u01-directory-use-three-milestones) explains that relationship.

## Block and register query boundaries

A query can inspect model configuration without performing a transfer; [the query FAQ](faq.md#block-and-register-query-boundaries) explains the additional observations needed for access or coverage claims.

**Available coverage mask**: Models advertised by a selected abstraction class,
distinct from which models currently have measurement enabled.

**Coverage inclusion intersection**: The selected build_coverage result contains
requested models also included for the matching hierarchical instance scope.

**Inherited backdoor query**: A block with no local user-backdoor definition
consults its parent. A nearer explicit block or register definition takes priority.

**Flattened block path**: An intermediate block has no HDL segment to contribute;
its descendants still combine the surrounding configured path components.

**Map membership boundary**: Contents belong to a selected physical-interface
map. A different map in the same block is not automatically in that map's subtree.

**System bus association**: A hierarchical map query selects the top-level bus
sequencer/adapter; an explicit local query observes the map's own association.

**Unmapped logical frontdoor**: An original access sequence services logical
memory locations while the memory occupies no physical map addresses.

**Qualified address-unit relation**: A literal reading connects word units to
the default hierarchical get_n_bytes result. Local-width interpretations and
an observed effective-width difference remain separate review considerations.

**Captured maximum baseline**: Record the preexisting global maximum before
adding selected registers, rather than assuming no other model already exists.

**Reset-kind definition**: Model metadata gives each selected reset cause its
own value/presence; changing it is distinct from applying a reset to model values.

**Clone source control**: Observe the original map's rights and association after
requesting a clone without claiming the new instance's unobserved contents.

**Gated busy observation**: Hold an original driver response after request arrival
so another thread can observe is_busy during an actual pending register operation.

## Expression types and registry declarations

**Declared expression type / receiver conversion** — The type queried by
`$typename` and a possible conversion when passing an expression to an argument.
Acceptance by a typed receiver alone is insufficient to prove the expression's
original declared type.

**Phase synchronization / sync / unsync** — Relationships aligning the start
and end of selected phase nodes across domains. `sync` adds them and `unsync`
removes them; removing one relationship preserves others. These relationships
do not prescribe a sibling visitation order.

**type_id / registry specialization** — The declared factory proxy type for
a represented class and its name/parameters. Finding an inherited type_id member
is insufficient when that member represents a base class; the required registry
must be compatible with the class-specific specialization. Explicit exceptions
and all package types require separate review.

## Memory locations and callback delivery

**Memory HDL location / slice** — A location index selects one word in a physical
array; slice offset/size selects bits within that word. A path-string match alone
does not prove either physical selection or data assembly.

**Public declaration / inherited implementation** — Compile accessibility of a
printed public method is distinct from reaching its base implementation through
a legal derived wrapper. Each has its own evidence and remaining limitations.

**Callback membership / delivery** — Successful add/delete return values and
actual notification recipients are separate observations. A later-entry removal
must preserve active peers and suppress the selected removed handle.

**Saved signed shift** — Store arithmetic shift output into its signed type
before a comparison can propagate unsigned operand context into the shift.

## Resource and sequence ordering

Queue ordering, request release and transaction completion are different checkpoints; [the sequence FAQ](faq.md#sequence-relevance-and-transaction-completion) explains why observing one does not establish the others.

**Resource priority / precedence** — Priority moves a resource within selected
name/type queues. Numeric precedence determines the maximum name match under
the explicit type-lookup exception; the two controls require separate evidence.

**Resource modification notification** — A changed write releases pending
waiters. Equal-value and read-only rejected writes must not signal a modification
under the selected resource contract.

**Zero-time relevance bound** — The configurable maximum for repeated
wait_for_relevant callbacks without time advancing. Callback counts and actual
simulation time are observed separately from any private counter implementation.

**Pipelined transaction completion** — A modeled completion mark later than
the sequence-item acknowledgement. A sequence can wait on the item-pool end
event after finish_item returns.

**Builtin-sequence target slot** — The model, register or memory handle
that selects the target of a predefined register/memory test sequence. Storage
identity checks and actual target execution require distinct observations.

**Live child-sequence slot** — A wrapper's protected reference to the child
currently executing selected work. A routing probe can compare the live handle
without assuming its initial value, allocation count or post-body retention.

## Time units and constructor premises

A premise is a test's setup assumption, so an explicitly initialized control must be read under its own conditions; [the FIFO initialization example](faq.md#q255-why-retain-constructor-only-fifo-failures-after-a-build-control-matches) shows why its match cannot pass the original input.

**Caller-unit canonical time** — A real time quantity interpreted in the calling
scope's time units. Explicit scaled/secs arguments convert it to or from the
canonical representation; a nanosecond-based example cannot be reused unchanged
in a picosecond scope.

**Virtual override formal name** — An argument name that must match the base
virtual method under SystemVerilog 8.20. Matching argument types and accepted
compilation alone do not establish a valid override declaration.

**Typed resource maximum** — Selection of the first maximum-precedence resource
whose container specialization matches T. The typed DB API remains distinct
from untyped selection and an original testbench filter.

**Recent-set resource sort** — The separate equal-precedence sort rule whose
most-recently-set wording is interpreted explicitly by a probe. It does not
replace first-maximum tie selection or silently establish stable queue order.

**FIFO preload / DUT transfer** — set prepares the abstract FIFO; update
transfers newly preloaded data before intervening blocking statements. Direct
write/read and auto/external prediction are separate routes and observations.

**FIFO constructor premise / build control** — A listed-API input and a
separately indexed pinned-library initialization variant. A passing control
does not pass the original premise or turn an unlisted method into an IEEE duty.

**Core-service declaration control** — Original method bodies used to distinguish
legal base-view dispatch from missing pure implementations. An explicit pinned
extra-hook control does not certify builtin algorithms or the listed-only premise.

## Field-macro and callback controls

A field macro generates code for selected object operations, and [the macro FAQ](faq.md#field-macro-type-arguments-and-paired-operation-flags) explains how type arguments and flags change the premise being checked.

**Enum collection T premise** — A collection typedef passed literally from
the field-macro prose, separately from a control using its element enum type.
The control keeps storage unchanged and does not settle the original premise.

**Paired PACK flag** — The field-macro contract that PACK enables packing and
unpacking. An explicit-UNPACK control is separate evidence; a compatible
roundtrip does not independently prove every one-way packing condition.

**Callback map-mutation premise** — An access whose callback changes its map.
An explicit initial-map control has a different premise and cannot pass this
mutation duty, even when it directly demonstrates provider selection.

**Physical/model neighbor separation** — Distinct values in original backdoor
storage and the register model's adjacent fields, so substitution is visible.
Selected-slice protection and qualified whole-word preservation remain separate.

**Predefined protection callback** — A register callback that rejects a prohibited
access direction with ERROR and UVM_NOT_OK. Its register/field memberships and
removal history are separate from the field's access policy.

**Prediction callback context** — The field identity, previous/latest values,
prediction kind, door and map delivered to post-predict. Selected direct
prediction does not imply read/write callback delivery or physical access.

## Scalar-macro and traversal controls

A successful compatibility control uses its own stated premise; [the macro FAQ](faq.md#recording-and-scalar-macro-conditions) explains why it cannot replace a differing printed-form input.

**Independent scalar macro direction** — Macro packing followed by public API
decoding, or public API encoding followed by macro unpacking, with a separate
trailer observation; [Q269](faq.md#q269-why-use-public-scalar-apis-in-the-other-packing-direction) explains the boundary of this evidence.

**Printed macro arity control** — A separate input with an explicit additional
argument or another printed interface, used to interpret the original signature
premise; [Q270](faq.md#q270-do-passing-compatibility-controls-resolve-the-printed-macro-signatures) explains why a control match preserves the original difference.

**Dependent visitor default** — A VISITOR type default formed from the selected
STRUCTURE type; [Q274](faq.md#q274-do-the-dependent-visitor-build-differences-prove-a-wrong-library-declaration) distinguishes its original input from an explicit-type control.

**Inherited empty visitor hook** — A begin/end callback whose base body leaves
selected state unchanged while a subtype implements visit; [Q276](faq.md#q276-does-zero-unassessed-in-f5-complete-traversal-coverage) explains the limits of the selected observations.

## Virtual abstraction query premises

The same query can involve different units or static types; [the query FAQ](faq.md#virtual-register-queries-and-declaration-boundaries) explains the measured examples and their limits.

**Virtual abstraction base premise** — The overview's named uvm_reg/uvm_reg_field
base versus the explicit uvm_object declaration. Literal and declared-base inputs
retain separate identities; a control match does not resolve the conflicting text.

**Virtual query unit boundary** — Element offsets/increments count memory words,
byte width rounds to complete implementing-memory locations, and external addresses use
the selected map's address units. Model-query agreement does not establish a
physical storage transfer or universal packing layout.

## Global lookup and combined observations

The lookup and mapping examples keep different premises explicit; [the FAQ](faq.md#dedicated-global-lookups-and-mapping-corrections) explains how to read their results.

**Dedicated global lookup** — Static access to an item bound in the shared
event/barrier pool. Printed pool return types conflict with item-return prose;
the two typed premises retain separate tests and qualified expectations.

**Combined observation row** — One expected line containing several observed
columns, such as parent, width and LSB. Separate duties may bind their own
values in that row; it remains one test and its complete runner judgment.

## Recorder link lifetime

**Recorder link lifetime window** — The interval after open_recorder and before
free, during which a recorder can be a database link endpoint. Close ends the
transaction without ending this interval; flushing an open recorder or freeing
its owning stream can free it. The object reference may remain after free;
[the lifetime FAQ](faq.md#recorder-link-lifetime) explains why that does not keep
it linkable or define error recovery.

## Canonical bus observations

**Numeric-word bus fixture** — An original testbench protocol carrying a numeric
word per address through uvm_reg_bus_op fields. It isolates canonical map values
from a builtin TLM payload's byte encoding; [Q289](faq.md#q289-what-does-the-numeric-word-bus-fixture-measure)
explains its independent read setup and scope.

**Address-sorted observation** — A view that sorts completed observer copies by
address to compare word/bit relationships while leaving actual operation order
unchanged; [Q290](faq.md#q290-why-sort-the-observed-requests-by-address) explains
why this is separate from temporal ordering or RTL timing.

## Policy substitution and typed object streams

**Policy substitution** — Selecting another policy instance/subtype for an object
operation while retaining one object class definition; [Q294](faq.md#q294-what-does-alternating-policies-on-one-object-add)
explains the alternating operation observations.

**Typed wrapper-state handoff** — An object pack entry point retrieves state
through the matching bit/byte/int/longint getter after fields, and unpack assigns
it through the matching setter before fields; [Q295](faq.md#q295-do-the-typed-packunpack-cases-prescribe-a-common-stream-encoding)
explains the opaque-stream premise and independent order observations.

**Fresh recorder condition** — Opening a new recorder for each selected object
record operation so the fixture does not assume repeated recording ignores prior
processing history; [Q295](faq.md#q295-do-the-typed-packunpack-cases-prescribe-a-common-stream-encoding)
describes this limit separately from copier reuse.

## Printer attributes and emission controls

**Textual printer attributes** — The name, type, size and value strings accepted
by print_generic_element; [Q297](faq.md#q297-why-pass-textual-size-attributes-rather-than-match-printed-numbers)
explains how they separate visibility from numeric conversion and layout.

**Emission controls** — Name/type/size enable settings used when emit generates
text, including changes after field collection; [Q298](faq.md#q298-what-do-post-collection-controls-and-the-peer-differences-establish)
distinguishes that behavior from a fresh peer's omitted settings.

## Adapter sequence contexts

**Adapter parent_sequence** — The sequence-base context selected by an
adapter for a driver's bus items, distinct from a register item's originating
parent metadata; [Q299](faq.md#q299-which-parent-does-the-adapter-sequence-requirement-describe)
explains the driver observation.

**Original clone bridge** — Fixture-defined do_clone behavior invoked by a public
clone override, without inferring the unspecified do_clone prototype;
[Q300](faq.md#q300-does-the-fixture-define-a-standard-do_clone-signature)
explains its limited role and the omitted caller-parent condition.

## HDL force and release conditions

**Forceable target** — A selected public packed signal with explicit compiler
instrumentation enabling this backend condition; [Q302](faq.md#q302-what-does-forceable-mean-in-these-fixtures)
distinguishes that premise from a general UVM obligation.

**Immediate release/read value** — The HDL value returned at release: retained
force data for a procedurally assigned reg until a new assignment, or the
resolved driver value for a driven wire; [Q303](faq.md#q303-why-do-reg-and-wire-releaseread-return-different-values)
describes the selected observations and open conditions.

## Positive-duration force_time observations

**Positive force interval** — A selected integer period during which a timed
HDL force must hold despite opposing updates, with sequential 5/13-period cases
distinct from zero-time deposit; [Q305](faq.md#q305-does-a-timed-force_time-fixture-assert-its-return-value-or-return-time)
explains which task observations are asserted.

**Expiration observation window** — Interior samples before the period ends and
a positive-offset sample afterward, followed by a normal update, without
prescribing process order at the boundary; [Q306](faq.md#q306-why-use-sequential-same-target-and-distinct-target-histories)
explains reuse, isolation and open timing conditions.

## Register HDL paths and observation premises

**Standard concat view / member-view control** — Observation through the declared
get_slices API / an explicitly additional public-member premise, with separate
inputs and roles; [Q308](faq.md#q308-why-keep-standard-views-and-member-view-controls-separate)
explains why a control cannot pass a missing standard getter.

**Whole-variable path / split reference** — A -1/-1 descriptor for an entire
register variable / independently stored high/low variables with legal slices;
[Q309](faq.md#q309-what-do-the-six-physical-register-cases-establish)
distinguishes their real storage observations from symbolic paths.

## Coverage construction and sampling

**Coverage construction selection** — The models selected for an abstraction
instance by include_coverage and its protected builder, separately from models
made available by constructor add_coverage calls. These masks describe metadata;
they do not measure bins. [Q311](faq.md#q311-does-coverage-construction-measure-functional-coverage-bins) records the selected scope and interpretation limits.

**Field-value sampling observer** — An original sample_values override that
counts dispatch and captures current model values. It distinguishes user and
actual parent-block calls without supplying a builtin covergroup algorithm;
[Q313](faq.md#q313-what-do-sample_values-observers-establish) explains the routing evidence.

## Reporting macro observations

**Reporting context / RO** — The report object associated with a macro call /
the explicitly supplied report-object argument of a context form. Their settings
can differ, so routing and filtering are checked against the selected object;
[Q314](faq.md#q314-what-do-the-reporting-macro-observers-measure) explains the observation.

**MSG evaluation flag** — A boolean witness that a message expression was
evaluated or suppressed. Visible flags require a positive count; filtered INFO
requires zero. This does not prescribe an exact positive evaluation count;
[Q316](faq.md#q316-does-suppression-skip-msg-evaluation-for-every-severity) distinguishes severities.

## Callback macro premises

**Callback registration pair** — The caller type and callback type declared for
macro use; registration legality is distinct from queue membership or dispatch.
[Q318](faq.md#q318-why-use-typedefs-for-parameterized-callbacks) explains parameterized aliases.

**Implicit callback caller** — The current object whose applicable callbacks the
macro dispatches, distinguished from an explicit object argument.
[Q319](faq.md#q319-what-do-the-dispatch-traces-and-method-negatives-prove) describes the observations.

## Size and version premises

**Reserved flag region** — The implementation's lower field-flag bits, counted
by its public parameter; selected user tags start above that region.
[Q320](faq.md#q320-does-the-flag-test-prescribe-a-reserved-bit-count-or-layout) explains the legal extension premises.

**Packer minimum capacity** — The least bit storage required of the default
implementation, distinct from its maximum or opaque stream representation.
[Q321](faq.md#q321-does-retaining-32768-bits-pass-the-missing-packer-minimum-macro) separates retention and macro presence.

**Standard versus implementation version** — A standard-revision macro versus
the package's implementation-identifying string parameter.
[Q322](faq.md#q322-are-the-standard-version-and-implementation-version-the-same-value) explains the separate presence ladder.

## Report and sequence-state premises

**Effective verbosity bound** — The global, ID or severity-ID limit selected for
one report, independently of another reporter's settings.
[Q323](faq.md#q323-do-the-direct-info-matches-resolve-every-verbosity-interpretation) explains the qualified NONE boundary.

**One-hot sequence mask** — Distinct state bits combined with bitwise OR,
without requiring particular numeric positions.
[Q324](faq.md#q324-do-530-matching-state-masks-certify-all-sequence-timing) separates mask representation and live timing.

**Stopped state versus post-callback evidence** — Observing that a sequence
was forcibly stopped versus observing its required post callbacks.
[Q325](faq.md#q325-does-matching-stopped-and-reuse-pass-the-required-kill-post-hooks) explains why the observations stay separate.

## Virtual-register storage premises

**Layout-independent observation** — A necessary value/storage check that
does not choose a unique order for the implementing memory words.
[Q327](faq.md#q327-why-use-equal-halves-and-an-unordered-result-for-a-field-spanning-two-words) explains the equal-half and unordered-pair profiles.

**Raw-storage preservation** — Direct comparison of independently seeded
memory words before and after access, including nonselected bits, peers and padding.
[Q326](faq.md#q326-do-user-backdoor-matches-establish-actual-hdl-transfers) distinguishes modeled and actual HDL storage.

**Debug-argument invariance** — The same functional predicates hold with
omitted and different explicit filename/line-number arguments.
[Q328](faq.md#q328-what-do-the-debug-argument-variants-establish) records the selected successful-access scope.

## Virtual-register callback premises

**Read/write ordering window** — First/last callback observations restricted
to the selected operation kind, so internal RMW reads are not treated as write hooks.
[Q329](faq.md#q329-why-do-the-pre-read-ordering-probes-keep-different-expectations) explains the qualified ordering groups.

**Facade declaration / concrete subtype** — The listed interface-class form /
a constructible derived type used as a separate compatibility control.
[Q330](faq.md#q330-why-does-a-legal-facade-construction-input-stop-as-abstract) separates those declaration observations.

**Coherent frontdoor/backdoor storage** — Two active access paths refer to
the same modeled words when a partial write may read through either route.
[Q331](faq.md#q331-why-was-the-standalone-partial-write-fixture-corrected) explains the corrected RMW fixture.

## Access recovery and selected frontdoors

**Killed-access semaphore reset** — Explicitly restoring the virtual array's access serialization after its caller is killed unfinished.
[Q332](faq.md#q332-does-reset-after-a-killed-access-reset-memory-data-too) distinguishes the bounded recovery observation from data reset and waiter ordering.

**Map-scoped frontdoor handle** — The user-defined sequence currently associated with one register/map pair, or null when none is associated.
[Q333](faq.md#q333-when-must-get_frontdoor-specify-a-map) explains single-map omission and explicit multiple-map selection.

## Root termination and predictor-check premises

**Finish request / positive-time termination** — Requesting simulation shutdown / checking that a later positive-time activity is not reached.
[Q335](faq.md#q335-do-statements-after-run_test-prove-that-no-finish-was-requested) distinguishes these from same-time continuation.

**Early guard / late-child check placement** — Fatal handling of an already-recorded error / the interpretation that a child EOE error precedes the root's bottom-up check.
[Q336](faq.md#q336-does-an-early-root-fatal-require-the-child-eoe-callback-first) records the distinct premises.

**Registered-packet check control** — A separately indexed predictor fixture with explicit factory registration and real bottom-up check-phase observation.
[Q337](faq.md#q337-why-keep-bare-and-registered-packet-inputs-separate) separates this setup from a mandatory IEEE BUSTYPE constraint.

## Enum designators, history and random-field observations

**Enum designator / selected effect** — A named typed selection / its behavior in an actual API or algorithm.
[Q338](faq.md#q338-do-enum-names-and-configuration-readback-prove-the-algorithm) distinguishes state from behavior and new links from new executions.

**Historical fresh/reuse reading** — A qualified interpretation comparing never-reserved locations with an explicitly reserved/released block.
[Q339](faq.md#q339-what-historical-meaning-is-used-for-greedy-and-thrifty) records the selected history and remaining review.

**Permitted interior / sampling distribution** — Acceptance of a valid constrained location / frequencies of unconstrained choices.
[Q340](faq.md#q340-does-a-broad-explicit-policy-match-establish-a-random-distribution) explains why these are separate observations.

**Opposite-value randomization witness** — Preassigning the opposite value and requiring a successful constrained change, with an untouched peer.
[Q341](faq.md#q341-how-do-the-random-field-inputs-differ-from-assignment-checks) limits this evidence to the selected rand fields.

## Manager context and live-region descriptions

**Selected allocation policy** — The explicit request argument or current default_alloc object that chooses the region start; [Q342](faq.md#q342-do-policy-callback-counts-establish-a-retry-algorithm) explains the callback observations without an exact retry rule.

**Pre-randomization context** — The selected policy's location count, configured minimum/maximum and unordered already-allocated handles before solving; [the fixture guide](testing.md#example) explains the original observers and independent peer.

**Occupied-state description comparison** — A qualified check that selected nonempty descriptions change when allocated spans change, without prescribing their text; [Q343](faq.md#q343-how-can-a-description-be-checked-without-fixing-its-format) explains why this is partial evidence.

**Live-region descriptor** — A manager-produced handle describing a currently allocated span; [Q344](faq.md#q344-must-re-reserving-a-released-range-create-a-new-object) distinguishes simultaneous independence from object reuse after release.

**Printed register backdoor task** — The standard's base virtual write/watch interface exercised through an original override; [Q345](faq.md#q345-do-custom-register-backdoor-tasks-prove-default-dpi-or-watch-support) separates declaration/dispatch from default implementation behavior.

## Typed roles, state comparisons and topology policies

**Typed port role** — A named constructor selection identifying a requiring port, forwarding export or bound implementation; [Q346](faq.md#q346-do-port-role-matches-prove-every-tlm-protocol) separates role queries from actual analysis delivery and broader protocols.

**Phase kind and node context** — An implementation, node, schedule or domain category, and the particular graph node supplied to traversal; [Q347](faq.md#q347-do-phase-kind-matches-resolve-lookup-of-a-repeated-imp) distinguishes these observations from duplicate-IMP lookup selection.

**Literal phase-state comparison** — Applying a named relational wait operator to actual state values without imposing numeric encodings; [Q348](faq.md#q348-why-check-wait-operators-on-a-stable-uninitialized-phase) explains the qualified uninitialized-state boundary and pending false waits.

**Objection event completion** — Return of the selected raise, drop or all-dropped waiter after its observed callback work; [Q349](faq.md#q349-does-a-dropped-event-mean-all-objections-have-finished) distinguishes a partial drop from final completion.

**Topology printer selection** — Choosing the explicit argument or current default policy while visiting the selected component hierarchy; [Q350](faq.md#q350-how-is-the-topology-printer-checked-without-matching-its-text) explains the original hook/emitter observations without fixing layout.

## Mode setup and heartbeat participation

A comparison setup can differ from the standard API premise, so [the mode/window FAQ](faq.md#sequence-library-modes-and-heartbeat-windows) explains which original inputs each observation belongs to.

**Mode API / legacy-field control** — Printed selection setter/getter calls / a separate setup using a diagnosed implementation-specific field; control success does not establish the missing API contract.

**Constrained RAND / RANDC cycle** — A subtype-constrained valid random index / a permutation cycle of eligible indices; selected tests observe child identity and cycle membership rather than an arbitrary random trace.

**Tracked participant / outsider activity** — A component in the heartbeat watch list / a component outside that list using the same synchronizing objection; several raises/drops from one actor are still one participating component.

**NO_HB_MODE interpretation** — The qualified relationship between the enum's disabled description and the API's default query argument; a quiet explicit-stop control does not resolve that configuration question.

## Format selection and observer boundaries

A successful data path need not validate a final file format, so [the radix/observer FAQ](faq.md#radix-meanings-and-observer-limits) identifies the boundary of each result.

**Format selection / observed representation** — A named radix or macro flag / the actual public printer element value;typed metadata arriving at an application-specific recorder does not itself validate a binary renderer.

**Raw data / NUL-free string** — Unformatted binary output / SystemVerilog string storage, which cannot contain NUL;raw4 backend coverage cannot be inferred from a two-state text observer.

**Width-limited observer / positional parser** — A measurement helper that saturates while reading a wide correct value / original digit arithmetic used to avoid that unrelated scanner limit without changing the expected value.

**Tabular row association** — The qualified short-cell relation between a field's supplied name, type, size and value;it fixes neither a universal physical layout nor all wrapping rules.

## Package views and event-copy observations

These terms describe the selected fixture conditions, with their limits in [the package/root/macro FAQ](faq.md#package-access-root-views-and-low-level-macros).

**Qualified package view** — Access through an explicit package scope rather than relying on an import; [Q359](faq.md#q359-does-package-qualification-also-apply-to-uvm-macros) distinguishes selected language symbols from preprocessing macros.

**Qualified root base view** — Component/object access to the existing singleton under the contextual inheritance reading; [Q360](faq.md#q360-why-qualify-the-root-inheritance-reading) records the printed-spelling conflict.

**Registry lookup string** — The custom name S associated with class T by a low-level registration macro; [Q361](faq.md#q361-do-low-level-registry-macros-supply-all-utility-methods) distinguishes the observed registration from unpromised utility methods.

**Pre-copy event waiter** — A process already waiting on the target's original synchronization queue before an event field is copied; [Q362](faq.md#q362-why-do-event-copy-inputs-remain-known-when-alias-and-flag-rows-match) explains its retained difference.

## Collection macro observation profiles

These profiles keep value restoration separate from representation assumptions, as explained in [the collection FAQ](faq.md#collection-macro-values-and-opaque-state).

**Scalar-API collection probe** — A selected one-way static-array macro compared with an independent scalar API under an explicit interoperability reading; [Q364](faq.md#q364-do-matching-collection-pairs-independently-validate-each-direction) records its limits.

**Compatible macro pair** — Corresponding collection packing/unpacking macros using compatible policy state; [Q364](faq.md#q364-do-matching-collection-pairs-independently-validate-each-direction) explains why restoration alone cannot independently certify both directions.

**Opaque typed state transfer** — Passing a state getter's output unchanged to the identically typed setter of a compatible implementation; [Q366](faq.md#q366-does-opaque-state-transfer-mean-copying-a-fixed-bit-layout) describes the independent-policy observation.

**Pre-sized collection destination** — A nonempty target allocated before unpacking, without asserting empty-target or automatic-allocation behavior; [Q365](faq.md#q365-which-array-shapes-and-widths-are-exercised) lists the selected widths and shapes.

## Generated TLM class scope

These terms describe the selected declaration and cast checks, with their limits in [the scope FAQ](faq.md#tlm-declaration-scopes-and-callback-overview).

**Generated suffix class** — A class named by a concrete implementation-declaration macro and its supplied suffix; [Q367](faq.md#q367-why-declare-the-same-suffix-in-two-packages) distinguishes it from a generic family placeholder.

**Cross-package nominal cast** — A cast from an actual generated class instance to a distinct declaration with the same name in another package; [Q368](faq.md#q368-does-correct-routing-pass-the-nominal-type-case) explains the retained parameterized-class difference.

**Resolved implementation view** — The interface selected from an actually bound port, with default or explicit index; [Q368](faq.md#q368-does-correct-routing-pass-the-nominal-type-case) separates correct routing/identity rows from whole-case success.

**Callback registry/object distinction** — The management class and the callback type it manages, whose documented base roles must be read together; [Q370](faq.md#q370-why-leave-b4-unassessed-after-reading-its-callback-description) records the earlier unresolved overview wording.

## Random state and API applicability

**API random stability** — Preservation of the applicable caller or object random stream for selected calls without user-code execution, subject to explicit exceptions; [Q372](faq.md#q372-does-the-same-random-stability-guarantee-cover-user-callbacks-and-constructors) explains the qualified boundary.

**Opaque RNG-state replay** — Saving and restoring a state within the same implementation to compare future observations without interpreting its encoding; [Q371](faq.md#q371-do-these-tests-require-a-particular-random-sequence-or-state-string-format) describes the relative control.

**Cold and warmed call histories** — Measurements before any selected API call or after explicit setup calls, with the snapshot taken after setup; [Q373](faq.md#q373-why-are-the-random-stability-cases-under-u01) connects these new inputs to their primary clause and directory.

## Boolean return conventions and model context

**Implied opposite Boolean return** — The false/true counterpart supplied by the general return convention when a predicate describes one outcome; [Q374](faq.md#q374-how-is-the-false-return-inferred-when-an-api-describes-only-true) shows selected literal observations.

**Valid nonmember map** — An existing explicit map with no association to the queried model, rather than a missing or malformed handle; [Q375](faq.md#q375-is-a-valid-nonmember-map-the-same-as-a-null-or-invalid-map) explains the predicate boundary.

**Model-only predicate evidence** — Observations of lock state or configured associations without a physical access operation; [Q377](faq.md#q377-does-classifying-the-chapter-18-overview-complete-the-register-layer) separates that evidence from completed register-layer coverage.

## Inherited APIs and documented overrides

Here a view changes the static type used to refer to an object without copying it, and [Q378](faq.md#q378-what-do-the-inherited-api-profiles-check) shows which names, identities and API values the profiles compare.

**Ancestor view** — A base-typed handle to the same live derived object, whose identity does not change with the static view; [Q378](faq.md#q378-what-do-the-inherited-api-profiles-check) describes the selected observations.

**Documented derived override** — A derived API whose specified behavior replaces the corresponding base behavior, such as component full-name composition; [Q379](faq.md#q379-why-retain-the-component-setter-expectation-when-its-observations-differ) distinguishes it from assuming an undocumented setter exception.

**Qualified inherited-setter profile** — A test applying the inherited setter contract under explicitly stated conditions while retaining observed implementation differences; [Q380](faq.md#q380-do-the-callback-and-registry-base-descriptions-prove-a-contradiction) explains why this does not settle every inheritance question.

## Deprecation and current replacement APIs

Current API profiles use their own clauses as the oracle; [Q382](faq.md#q382-does-normative-annex-h-require-rejecting-deprecated-apis) explains how the normative deprecation notes supply context.

**Deprecation entry** — A record that an older construct was removed or is under consideration for removal from the standard; it does not by itself forbid an additional implementation member or approve scope exclusion.

**Unordered link endpoint pair** — The two exact objects connected by a typed relation, checked without assigning undocumented parent/child roles to lhs/rhs slots or fixing descriptor names/counts.

**Signed byte separator** — A byte argument whose high bit may be set, such as 0x80/0xff; the split profiles match the same byte in the string and retain empty fields without interpreting a regex or legacy alias.

## Name case, ordering and detached roots

These terms describe selected naming and ordering observations, and [Q388](faq.md#q388-do-the-new-profiles-prove-incorrect-case-folding) explains why a whole-fixture difference does not identify its cause.

**Names differing only in case** — Distinct supplied spellings such as item101/Item101, tested through the specified API; explicitly case-insensitive exceptions keep their own rules.

**Order of equivalent data** — The implementation's permitted choice within the specified semantics, which does not erase an API's explicit field-position order or require different runs to use different orders.

**Detached sequence root interpretation** — The qualified expectation that a sequence whose parent is cleared identifies itself as root; path, parent, root handle and root name are observed separately without asserting depth or execution behavior.

## Named callback lifecycle and conditional type relations

A callback can belong to several object queues while sharing one enabled state, and [the lifecycle FAQ](faq.md#q391-what-do-the-named-callback-lifecycle-profiles-check) shows how separate memberships are observed.

**Disabled deletion history** — Removing a callback's association while its execution is disabled, then enabling it again to distinguish deletion from temporary suppression; [Q391](faq.md#q391-what-do-the-named-callback-lifecycle-profiles-check) records the exact-root/glob controls.

**Conditional directional type control** — A supporting conversion probe under one explicitly selected ancestry interpretation; [Q392](faq.md#q392-do-the-type-relation-controls-settle-the-b4-base-wording) explains why it does not prove mandatory ancestry or exclude the opposite permitted chain.

**Zero-unassessed checkpoint** — Every catalog identifier has a partial decomposition or an individual assessment, with other obligations and completion gates still open; [Q390](faq.md#q390-does-zero-unassessed-identifiers-mean-zero-remaining-work) distinguishes this queue from complete coverage.

## Static callback boundaries and exhausted cursors

A static iterator uses the caller's integer as an opaque position, and [the boundary FAQ](faq.md#q394-which-static-callback-boundaries-are-checked) explains which public results are observed without fixing that representation.

**Eligible static callback** — An enabled callback belonging to the requested CB family in the selected object or typewide queue, with unrelated and disabled entries excluded; [Q394](faq.md#q394-which-static-callback-boundaries-are-checked) shows the endpoint controls.

**Exhausted cursor / endpoint reset** — A continuation that has returned null for no remaining callbacks / a new get_first or get_last that resets the corresponding direction; [Q395](faq.md#q395-why-keep-null-after-an-exhausted-queue-grows) explains the repeat-null condition.

**Completed growth after exhaustion** — Callback additions finish before another continuation on the exhausted cursor, with a separate explicit reset afterward; [Q396](faq.md#q396-do-seventeen-matching-rows-pass-the-forward-iterator-inputs) distinguishes matching reset rows from a complete passing trace.

## Memory access restrictions and relocation units

These terms distinguish an interface's restriction from the memory's intrinsic policy, with the observed examples in [the access FAQ](faq.md#q398-why-can-memory-rights-and-effective-access-differ).

**Memory policy / map rights** — Intrinsic RW/RO storage policy / RO/WO/RW interface restrictions, with distinct get_access and get_rights contracts; [Q398](faq.md#q398-why-can-memory-rights-and-effective-access-differ) explains the unshared rule and explicit shared-map requirement.

**Flat address unit / location stride** — Bytes in one map address unit / distance between memory-location starts in those units, tested with integral one/two-beat layouts; [Q399](faq.md#q399-which-address-units-and-relocation-conditions-are-checked) distinguishes model addresses from actual storage access.

**Diagnostic-only lookup coordinate** — A logged local/external lookup probe without an expected oracle or direct requirement link; [Q400](faq.md#q400-do-the-lookup-diagnostics-establish-address-lookup-conformance) explains why its result does not settle the standard's coordinate meaning.

## Nested transport arguments

**Input-handle rebinding** — Assigning another object handle to an input formal changes that local binding; mutating the referenced object can still be visible through the original caller handle, as explained in [Q402](faq.md#q402-does-a-delay-reference-mean-an-endpoint-can-replace-the-callers-handle).

**Live phase alias** — A phase ref argument addresses the caller's variable throughout the call, with changes visible before return; [Q403](faq.md#q403-why-read-the-callers-phase-before-the-transport-call-returns) shows why checking only a final value is weaker.

**Synchronous transport reentry** — A still-active endpoint calls the same resolved port again before returning, using another phase variable and shared or distinct objects; [Q404](faq.md#q404-do-the-six-matching-profiles-complete-tlm-2-or-prove-concurrent-safety) separates it from simultaneous-process safety and complete protocol coverage.

## Pending objection chains

**Pending zero-count chain** — Deferred propagation after a source reaches zero, while an ancestor still holds its pending counts; [Q405](faq.md#q405-what-is-added-beyond-re-raising-during-drain) explains the drain and all_dropped gates.

**Net propagation compensation** — Reducing a new raise R by a pending drop D before propagation, with public count state and hook amounts distinguished in [Q406](faq.md#q406-what-is-asserted-when-the-new-count-is-smaller-than-the-pending-drop).

**Selected task gate** — An original wait in the printed objection or registered callback task, used to observe cancellation while the task is active; [Q407](faq.md#q407-do-the-task-gates-resolve-the-components-printed-function-declaration) keeps it separate from the component's function declaration.

## Direct map translation

**Direct translator / memory-entry index** — Calling `get_physical_addresses` itself / selecting a memory entry through `mem_offset`, rather than adding that value as bytes or bus beats; [Q409](faq.md#q409-what-does-a-direct-map-query-add-beyond-register-address-queries) connects those arguments to the independent address arithmetic.

**Integral beat / partial-return diagnostic** — An access consisting entirely of full effective-width beats / a recorded return value without a normative oracle when one integer's meaning across unequal beat widths needs review; [Q411](faq.md#q411-why-is-the-partial-transfer-return-value-diagnostic-only) explains the retained boundary.

## Recording suppression in connected traffic

**Automatic suppression / explicit driver mark** — Disabling sequencer-generated item recording / the driver's own component begin/end calls, which remain available; [Q413](faq.md#q413-what-do-the-recording-disable-profiles-add-beyond-a-flag-query) connects them to transaction timestamps and named events.

**Per-driver observation gate / peer diagnostic** — A testbench barrier holding each original driver return until the intermediate observation / independently recorded peer event counts without an oracle; [Q414](faq.md#q414-why-are-peer-event-counts-diagnostic-only) explains the retained scope.

## Automatic property recording

**Custom record hook / recorder field hook** — The request object's `do_record` implementation / the backend's `do_record_field_int` receiving a declared property through the public recorder API; [Q416](faq.md#q416-what-do-the-property-profiles-add-beyond-transaction-marks) follows the actual library-driven path.

**Recording presence / recording count** — Evidence that the declared property reaches a recorder / the number of hook or lifecycle calls; [Q417](faq.md#q417-why-check-recording-presence-rather-than-exact-counts-or-times) explains why exact diagnostic totals do not define an oracle.
