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
