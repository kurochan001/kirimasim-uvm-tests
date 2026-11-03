# Glossary

[日本語](glossary.ja.md) · [README](../README.md) · [FAQ](faq.md)

These are the meanings used in this repository's tests and reports. This
glossary is a reading guide; cited clauses in each test remain the basis of
its expected result.

## Standards and expectations

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

**Review / `:spec_check:`** — Who checked the expectation against the standard.
`ai` records AI review; `human` records human review. It is separate from
whether a simulator matches. All current tests record `ai`.

## UVM building blocks

**Object / component** — A UVM data or policy object / a node in the UVM
component hierarchy that participates in phases. Components include tests,
environments, drivers and sequencers.

**Factory / wrapper / registry** — The type-based creation and override
mechanism / a proxy describing a registered type / helpers that register and
create objects or components through the factory. A type name and an instance
path play different roles in override selection.

**Configuration database / resource** — Typed values selected by scope and
field name / the underlying configurable values and lookup mechanisms. The
suite checks scope, type, precedence and updates, while recording the pinned
library's field-name glob limitation.

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

**Nonblocking transport / `nb_transport`** — A request/response operation
that returns 1 for immediate completion or 0 when it cannot complete
immediately. A synchronous analysis callback can supply the response during
the call. A 0 does not establish a particular response output value or that
no partial request-side effect occurred.

**Failed-read sentinel** — A nondefault value or nonnull handle passed into an
unavailable nonblocking TLM read to observe its stated unchanged-output contract.
The UVM `output` formal and SystemVerilog copy-out semantics create a separate
interpretation issue; failure values for register/memory reads are not inferred.

**Response identity** — A response's sequence and transaction routing IDs,
usually copied from its request. Equal transaction IDs across live sequences
must still route separately; duplicate matches need not imply a tie order.

## Register model

**Register / field / block** — A model of a value accessed as one entity /
a contiguous set of bits with a shared policy / a container grouping registers,
maps and child blocks. Register byte width rounds up when its bit width is
not a whole number of bytes. Field enumeration follows increasing bit position.

**Desired / mirrored / `needs_update`** — The requested model value / the
value currently recorded by the model / a query for writable state needing
an update. `set` changes desired state under the access policy; direct
prediction synchronizes both views. Neither operation reads or writes a DUT.

**Access policy / map rights** — A field's read/write rules, such as RO, RW
or W1C / the register's access restriction through one map. Both participate
in effective field access. Model-only `set` also applies the field policy.

**Reset kind / model reset** — A named reset event, such as HARD or SOFT /
restoring desired and mirrored values for that event. An unconfigured kind
leaves the field unchanged. Resetting a block reaches its child blocks and
does not itself reset physical hardware.

**Address map / local offset / physical address** — A model of an interface's
address space / a register's position within it / an address visible through
the root interface. Address units can be bytes or bus words. Returned address
arrays follow data significance; submaps combine offsets and bus widths.

**Frontdoor / backdoor / predictor** — Access through a modeled bus path /
direct access to the design's storage / model updates derived from observed
transactions. M3 now exercises frontdoor paths with a testbench bus model and passive
prediction from supplied observations, plus user-defined storage backdoors.
RTL/HDL-path/DPI integration remains future work. See the
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

**Runner / metadata** — A `tools/run_*.py` script that builds, executes and
judges tests / the fields in the test's initial comment controlling that work.
The supported options and library mode are part of the execution conditions.

**`pass` / `fail`** — The expected output and specified exit/diagnostic checks
matched / a check failed, or the test could not build or run. One failing test
is not necessarily one distinct simulator bug.

**`known` / `unsupported`** — In this Verilator runner, an untagged test fails
validation, including a build failure / kirimasim explicitly reports a
construct as unsupported.
Neither is a pass. Ghost uses `pass`/`fail`; it does not relabel bundled-library
differences as `known`. See the [FAQ](faq.md) for command exit behavior.

**Seed / two-state / four-state** — An input controlling randomized execution
conditions / values without X and Z / values including X and Z. The fixed
Verilator oracle uses seeds 1 and 73 for X/Z-independent tests. Two passing
seeds do not prove correctness for every seed.

**DPI / `UVM_NO_DPI`** — The SystemVerilog interface to external code / a macro
disabling UVM's DPI-dependent implementation paths. Current tests use it.
Removing the macro does not itself provide or link the required C/C++ code.

**Pinned library / lock / bundled library** — The exact library identified by
`third_party/uvm.lock` / its version, commit, file count and content digest /
a library supplied through a simulator/profile. Bundled results do not establish
execution with the pinned library.

**Fingerprint / SHA-256 / combined evidence** — A content identity used to
compare inputs or tools / its digest algorithm / results from multiple batches
combined after checking input, runner and configuration identities. A matching
fingerprint supports reuse of recorded evidence; it is not a new execution.

**Watchdog** — A bounded timeout in a blocking test that turns a missing
completion into a visible failure. Positive delays let a test observe waiting
without relying on process order in the same simulation time slot.

## Scope and coverage

**M0–M4** — The [development stages](../README.md#plan): infrastructure, core
UVM, TLM/sequences/callbacks, register layer, then a reviewed requirement ledger.
Starting a later stage does not certify completion of the previous stage.

**Clause citation / requirement coverage / match count** — A reference in
metadata / evidence that defined requirements and conditions are exercised /
the number of tests matching in a specified execution. These have different
denominators. This repository has not approved a requirement-coverage denominator;
neither the test total nor the oracle count is such a percentage.

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
or backlog: a portable identity of validated scope, requirement data, test index
and catalog. JSON formatting is normalized; array order and catalog bytes are
retained. See [report identity](requirements.md#generated-report-identity).
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

**Phase implementation and node** — An implementation supplies a phase's
behavior; a schedule contains nodes referring to implementations. Different
nodes can refer to the same singleton without becoming the same handle.

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
