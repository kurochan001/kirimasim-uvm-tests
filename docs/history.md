# Development history

[日本語](history.ja.md) · [README](../README.md)

These records cover M1, fifteen M2 increments and six M3 increments
(733 tests). The earlier 349-test checkpoint is
[500f22e](https://github.com/kurochan001/kirimasim-uvm-tests/commit/500f22e10c3ce62a497df929232a562b78952fc5).
Counts, measurements and statements about missing tests describe each
increment at that time. Current scope and commands are in the README;
current library limitations are in [known differences](known-differences.md).

## Ghost bundled-library measurements

The initial M1 bundled-library runs match 18 of 27 tests with both seeds 1
and 73; the same nine cases differ. The pinned-library smoke test does not
match on that private executable, including with preprocessing enabled.
These differences are recorded as failures. They do not change expectations
or establish whether the cause is the simulator or its bundled library.
With the second M1 increment, bundled runs match 31 of 61 tests with both
seeds; the same 30 cases differ. The third increment matches 41 of 101
tests with both seeds, with the same 60 differences. After the fourth
increment, both seeds match 45 of 133 tests, with the same 88 differences. The sixth
increment matches 49 of 157 tests with both seeds, with the same 108 differences.
The seventh increment matches 53 of 181 tests with both seeds, with the same
128 differences. The eighth increment matches 54 of 205 tests with both
seeds, with the same 151 differences. The ninth increment matches 57 of 229
tests with both seeds, with the same 172 differences. The first M2
increment matches 73 of 253 tests with both seeds, with the same 180
differences. The second M2 increment matches 79 of 277 tests with both
seeds, with the same 198 differences. The third M2 increment matches
82 of 301 tests with both seeds, with the same 219 differences. The fourth
M2 increment matches 92 of 325 tests with both seeds, with the same 233
differences. The fifth M2 increment matches 93 of 349 tests with both seeds,
with the same 256 differences.

## M1 increments

The first increment adds 26 independent tests to the original phase smoke
test. Expected observations are written before running the simulator:

- Object names, renaming, cloning and independence of cloned data: four tests.
- Factory type-override replacement and instance-override scope/priority:
  four tests.
- Build traversal and bottom-up connect traversal: two tests, in addition to
  the original common-phase test.
- Objection counts, partial drops and propagation to a parent: two tests.
- Configuration lookup scope, types, build precedence and runtime writes:
  four tests.
- Report severity/ID counts and verbosity filtering: two tests.
- Copier, comparer, printer and packer policies: two tests each. Printer
  tests capture policy inputs rather than built-in formatting; packer tests
  check values and sizes rather than an implementation-specific byte layout.

The second increment added another 34 tests, bringing the suite to 61:

- Object ID lifetime, static/dynamic wrappers, copy policy selection and
  comparison hook/results: eight tests.
- Report action and verbosity precedence, including NO_ACTION suppression:
  four tests.
- Factory type/instance aliases and override/registration queries: six tests.
- Common-phase lookup and ordering: two tests.
- Objection drain time and re-raising during drain: two tests.
- Configuration scope globs and blocked `wait_modified` notifications:
  four tests, with watchdogs for the blocking cases.
- String comparison/reset, string packing boundaries, nested deep copying
  and copier-hook state, and printer controls: two tests each.

The clause-number inventory also includes the previously omitted 6.3.5.2,
verified against the standard. ID tests compare identity relationships,
not particular numeric IDs; string packer tests check round trips without
prescribing an implementation's stream representation.

The third increment added 40 tests, bringing the suite to 101:

- Object pack/unpack through bit, byte, int and longint streams, including
  policy reuse and default selection, plus field-operation state and hook
  suppression: eight tests.
- Report-server severity counters, independent server state, quit limits
  and current-count updates: four tests.
- Object/component registry creation with parent and explicit contexts:
  four tests.
- Task-phase thread termination and completion while an objection is held:
  two tests.
- Objection source listing, zero-count removal and global clearing:
  four tests.
- Policy-side active-object stacks, comparer type/reference controls,
  printer file/default selection, and array/time/real packing: fourteen tests.
- Configuration presence, diagnostic spell checking and independent updates
  by field and scope: four tests.

Array packer tests use bit counts for explicit sizes and compare decoded
values. The empty-array unpack explicitly requests zero bits. Printer file
checks use a custom emission string; they do not prescribe a built-in layout.
Task-phase checks hold objections for positive delays and inspect child
state after the child would otherwise have resumed.

The fourth increment added 32 tests, bringing the suite to 133:

- Transaction lifecycle timestamps, hooks, identifiers, initiators and named
  events, including the normative initial inactive state: six tests.
- Report file selection and independent updates, severity-override precedence
  and replacement, and shared/replaced handlers: six tests.
- Registry convenience methods for relative instance overrides and type
  override replacement: four tests.
- Phase callback states, ready-to-end objections, iteration limits and state
  waiters: four tests.
- Objection event waiters for raised, dropped and all-dropped events, with
  callback/drain timing and target-object isolation: four tests.
- Real comparisons, ordered copy/compare histories, history reset and
  integer-array packing boundaries: eight tests.

Transaction cases disable recording before acceptance, keeping their
observations independent of recording backends. Blocking phase/objection
cases have watchdogs and positive delays before producer events. The phase
state observer holds a run objection until it has observed main ending.
Initialized procedural locals in this increment use automatic lifetime,
following SystemVerilog 6.21, so their initialization executes at block entry.
The phase-limit test samples its class default in an executable statement
after static initialization.

The fifth increment completes the initialized-local lifetime audit of all
133 cases. Across 84 earlier tests, 202 declarations now use `automatic`.
Four initialized variables in the two guarded-fork configuration tests
instead use static storage with separate block-entry assignments, keeping
shared state alive across the branches. All 206 initializations therefore
execute at block entry, including constructor and getter calls. The static
storage also avoids Verilator's rejection of potentially escaping automatic
references in those two cases. The tests cite SystemVerilog 1800-2023 6.21.
No expected file changes.
The other cases already use explicit lifetime, use automatic class methods,
or have no initialized procedural locals. The two module-level helper
functions are explicitly automatic.

The metadata check now uses `tools/sv_lifetimes.py` to catch the same implicit
lifetime pattern in initial/always begin/fork blocks. Its regression cases
cover nested scopes, parameterized/scoped types, arrays, comments, strings,
and explicit automatic/static declarations. It is a lexical source check;
it does not expand macros, parse subroutine lifetime, or inspect the pinned
library. Compiler execution remains part of validation.

The fifth increment kept 133 UVM tests and increased tool unit tests from
30 to 41. Changed cases were rebuilt with both Verilator seeds. Unchanged
execution evidence is reused only when input and runner fingerprints match.

The sixth increment adds 24 tests, bringing the suite to 157:

- Policy extension insertion, dynamic type keys, replacement, individual/all
  deletion, policy isolation, flush preservation, and use by copy/compare
  hooks: twelve tests.
- Configured object handle identity, class-type specializations, null values
  and replacement while old handles remain valid: four tests.
- Local phase schedule append, constrained insertion, parallel branches and
  adjacent-node queries: four tests, without executing the local schedules.
- Report-handler reset, report ID sets, and independent statistics snapshots:
  four tests. The severity-ID reset expectation is retained as spec-only.

Extension tests observe registered wrapper keys and handle relationships,
without depending on storage layout. Hook code handles absent extensions
explicitly. Report ID and graph-neighbor checks compare membership rather
than iteration order. Counter snapshots are populated through report calls,
without implementation-only ID counter setters.

The seventh increment adds 24 tests, bringing the suite to 181:

- Shared UVM seeding controls, disabled-reseed RNG state preservation,
  virtual object creation and default/custom string conversion: eight tests.
- Packer state transfer through bit, byte, int and longint snapshots,
  comparer reporting controls, printer array windows and element-stack
  push/pop/flush behavior: twelve tests.
- Task-phase objection forwarding and independent node counts, plus errors
  for invalid objection operations on function phases: four tests.

RNG state is compared only for equality on the same object; its encoding and
random values are not prescribed. Packer snapshots come from the matching
getter on a compatible implementation, without inspecting stream layout.
Printer stack accessors are exposed by a test subclass. Old element handles
are not inspected after flush, as they may be recycled. Function-phase error
cases discard invalid return values and check reports without fixing their
wording or identifiers. The local schedules are not executed.

The eighth increment adds 24 tests, bringing the suite to 205:

- Report-message common fields, independent action/file updates,
  infrastructure references, message isolation and calling-thread RNG
  preservation by the creation helper: eight tests.
- Field-operation names and types, accessor preconditions, repeated set
  calls and invalid combinations of operation flags: eight tests. The two
  accessor-precondition cases retain the required errors as spec-only.
- Factory registration and wrapper lookup, exact type/name queries,
  independent factory instances and selection through the core service:
  eight tests.

Message tests inspect assigned fields and handle identities without emitting
those messages or depending on descriptor values. RNG state is observed from
an initial process as an opaque equality comparison. Field-operation error
cases discard invalid return values and flush before reuse. Local factories
keep registration checks independent of globally registered built-in types;
selection tests restore the saved global factory handle.

The ninth increment selects previously untested API clauses before adding
24 tests, bringing the suite to 229:

- Wrapper object/component creation and represented type names: six tests,
  two each for 8.3.2.2.1, 8.3.2.2.2 and 8.3.2.2.3. The `test_wrapper_*`
  cases in `tests/u08/` call through the common proxy handle.
- Packer object round trips, non-consuming null queries, incompatible null
  targets, operation/hook order, active-object state and hook suppression:
  eight tests for 16.5.4.2, 16.5.4.3 and 16.5.4.4, with at least two
  focused cases for each clause.
- Printer element construction and field updates, plus immediate-child
  queries, queue-prefix preservation, leaves and repeated appends: ten
  tests. These cover 16.2.8.2.1 through 16.2.8.2.6 and 16.2.9.2.1 through
  16.2.9.2.2, with at least two focused cases for each clause.

These 14 reviewed API clauses now meet the two-test target. This is a
focused mapping, not a complete M1 requirement inventory. Other clauses
still need review: metadata citations can describe setup or structural
clauses, so citation counts alone do not establish requirement coverage
or an exact remaining test count.

Object streams come from the same packer implementation; marker widths and
encodings are not prescribed. After an incompatible null-target error, no
further unpack operation is attempted. Child relationships are constructed
through standard printer stack operations. Proxy cases compare membership
and preserved queue entries without assuming sibling order or using
implementation-specific child mutation APIs. They do not inspect handles
after printer flush. Virtual overrides use the base declaration's argument
names, including `op` for `do_execute_op`.

## M2 increments

M2 starts with 24 TLM 1 tests in `tests/u12/`, bringing the suite to 253:

- Bounded/unbounded FIFO capacity, occupancy and availability, arrival order,
  non-consuming peeks, rejected writes, flush and independent storage:
  eight tests, centered on 12.2.8.2 and the methods of 12.2.4.2.
- Blocking FIFO get/put wait until data/space becomes available: two tests.
- Analysis FIFO write order, unbounded capacity, interleaved reads/writes,
  peeks, flush and independent instances: six tests for 12.2.8.3.
- Analysis-port broadcast to two receivers, object-handle preservation,
  zero-subscriber writes and forwarding through an analysis export:
  four tests for 12.2.10.
- Blocking/nonblocking put and combined get-peek ports connected to FIFO
  exports: four tests for 12.2.5.1 and 12.2.8.1.3/12.2.8.1.4.

Port tests run normal UVM elaboration before observing resolved bindings.
Analysis receivers are inspected after write returns; no subscriber-call
order is prescribed and subscribers do not mutate transaction objects.
Blocking tests hold objections, use positive delays to observe the waiting
state, keep shared values in the test object and include watchdogs. Stateful
operations execute in separate statements before their results are printed.
Unavailable-read cases observe return status and queue state; they do not
claim to cover the required preservation of output arguments on failure.

The first 24 M2 cases match Verilator 5.052 with seeds 1 and 73.

The second M2 increment adds 24 cases in `tests/u14/` and `tests/u15/`,
bringing the suite to 277:

- Sequence-item context assignment/replacement, parent/depth/root/path
  queries, sequence-info flags, inactive sequencer references and virtual
  item/sequence classification: eight tests for 14.1.2.
- Sequence execution hooks and states, optional pre/post-body suppression,
  parent hooks, priorities, restart, state waiters, randomization-enable
  controls and starting-phase/automatic-objection controls: eight tests
  for 14.2.
- Sequencer arbitration and request/response-buffer size controls, explicit
  item acknowledgements, peek/get consumption, two-item transfers and
  response routing via item_done/put: eight tests for 15.3 and 15.5.

The 24 new cases also match Verilator 5.052 with both seeds. Handshake cases
connect the driver's pull port to the sequencer export during normal UVM
elaboration and exercise it in run phase, with automatic item recording
disabled. Shared request/response handles live in the test object. Positive delays make pending acknowledgements
observable and let response waiters settle; watchdogs bound blocking cases.
Responses copy routing IDs with set_id_info. Only explicitly assigned
transaction IDs are printed, never allocated sequence IDs. Counters are
initialized explicitly, and the standalone state-wait test uses a module
handle with a positive body delay.

Control-setting cases do not claim to cover automatic randomization,
automatic phase objections, arbitration among competing sequences or buffer
contents.

The third M2 increment adds 24 cases, bringing the suite to 301:

- Callback enable transitions, ignored mode values, append/prepend execution
  order, instance-local registration/deletion, required duplicate/removal
  warnings, typewide registration/deletion and get_all membership: twelve
  tests for 10.7, with type-pair and execution macros from B.4.
- Forward/reverse callback traversal, disabled-entry filtering, current
  callback identity, independent iterator positions and object contexts:
  four tests for D.1.
- Request/response channel FIFO order, independent bounds, non-consuming
  peeks, unbounded queues, accepted-write analysis notifications, combined
  master/slave interfaces and blocking transport waits/reuse: eight tests
  for 12.2.9, using int requests and string responses.

These 24 cases also match Verilator 5.052 with both seeds. Callback enable
values are assigned explicitly. Execution checks use documented
append/prepend order, while get_all checks compare membership and preserved
queue prefixes. The fixture type is named user_callback to avoid collision
with the macro-local cb identifier; expected values do not depend on that
type name. Iterators are not used to mutate callback registrations.

Channel tests use public typed ports/exports after normal elaboration,
without inspecting the protected FIFOs. Analysis monitors are read after
accepted writes. Transport tests keep shared values in the test object,
use positive delays to observe waiting and include watchdogs. That increment
did not cover TLM 1 nonblocking transport or callback name-based
registration/inheritance.

The fourth M2 increment adds 24 cases, bringing the suite to 325:

- TLM 2 generic-payload command/address accessors, unsigned data and
  byte-enable array copies/replacement, response predicates, streaming width
  and DMI hint settings: eight tests for 12.3.4.2.
- Generic-payload extension keys, handle retrieval, replacement, selective
  removal, payload isolation and clear/reuse: four tests for 12.3.4.2 and
  12.3.4.5.
- Blocking sockets with read completion and payload reuse, nonblocking
  forward completion, and an accepted forward request completed through a
  backward response with a phase-reference update: four TLM 2 transport
  tests for 12.3.2 and 12.3.5/12.3.6/12.3.8.
- Exact/glob callback registration and deletion within a search root,
  superclass typewide callback inheritance/deletion, and early exit on
  true/false callback results: eight tests for 10.7 and B.4.

These 24 cases match Verilator 5.052 with both seeds. Payload array and
length settings are kept consistent; mismatched independent lengths are not
covered. Data and byte-enable checks use accessor values rather than member
layout. DMI and streaming cases inspect settings without claiming actual DMI
access or target streaming behavior. Extension keys are compared through
base handles without prescribing numeric IDs.

Transport tests run after normal elaboration and compare transaction/delay
handle identity, result status and phase updates. Blocking targets fill
explicit two-byte READ requests. Nonblocking cases use IGNORE transactions
and complete one request either immediately or through a backward response.
Delay annotations are passed through without asserting their numeric
resolution or time-conversion behavior. Watchdogs bound the phase tests.

Name-based callback cases match full component paths and include matching
objects outside the chosen root. Inheritance uses the standard superclass
registration macro; early-exit cases verify that later callbacks are not
called. No expected result depends on hierarchy search enumeration order.

The fifth M2 increment adds 24 cases, bringing the suite to 349:

- Response-handler and queue defaults, per-instance controls, FIFO and
  transaction-ID retrieval, handler delivery and switching back to queues,
  clear/reuse, enabled/suppressed overflow errors, unbounded storage and
  undersized depth changes: 12 tests for 14.2.7 and 14.3.3.3.
- Sequence/sequencer current-item lifetimes through `item_done` and `get`,
  request/response history, response analysis-port routing, `execute_item`,
  idle `try_next_item`, single-candidate USER arbitration and child ancestry:
  eight tests for 14.3.3.2 and 15.3/15.4/15.5.
- Automatic starting-phase objections enabled/disabled, inherited child
  priority and a relevance gate that blocks the driver's request: four tests
  for 14.2.3/14.2.4/14.2.5.

Of these 24 cases, 19 match Verilator 5.052 with both seeds. The other five
retain the required response-error default, depth-change errors and USER
arbitration callback as spec-only expectations, with known seed 1 differences.
Expectations come from the standard; the pinned library differs at these points.

Response tests complete real driver requests and copy their IDs into replies.
Queued responses arrive before retrieval is allowed, making FIFO, selective
retrieval and handler switching deterministic without internal queue access.
Overflow tests observe the error control without prescribing which reply is
retained. History tests inspect values and explicit transaction IDs without
assuming snapshots or handle identity. The out-of-range history index is
strictly greater than the configured size.

Current-item and direct-execution tests observe the pending request before
acknowledgement. The relevance test uses a positive delay before opening the
gate; phase objections are checked on an isolated task-phase node inside
sequence callbacks and after natural completion. Waiting tests have watchdogs.

Current simulator totals combine fresh runs of these 24 cases with the
unchanged 325-case baseline after verifying test inputs, runner fingerprints
and simulator configurations.

M1's six spec-only cases and remaining clause coverage are retained;
starting M2 does not mark M1 complete. More sequence/sequencer and callback
behavior, TLM 1 nonblocking transport and broader TLM 2 timing/protocol
coverage remain M2 work. M2 is not complete.

### Sixth M2 increment

This increment adds 24 tests, bringing the suite to 373:

- Eight competing-sequence arbitration cases: FIFO request arrival with
  unequal priorities, reversed arrival order, STRICT_FIFO priority and
  equal-priority arrival, STRICT_RANDOM unique highest priority, USER selection
  of either lower-priority candidate, and RANDOM delivery membership.
  They cover 15.3.2.19, F.2.4.1 and the USER APIs of 15.3.2.3/15.3.2.4.
- Eight lock/grab cases: sequence APIs, sequencer APIs and cross-release,
  nested parent/child ownership and restoration, and blocked acquisitions
  that transfer after unlock. They cover 14.2.5.5–14.2.5.10 and
  15.3.2.8–15.3.2.13/15.3.2.15/15.3.2.16.
- Eight TLM 1 nonblocking transport cases: absent immediate response,
  full request storage, nonblocking and combined transport ports, slot reuse,
  independent channels, recovery after retiring a failed call, and request/reply
  object handles. They cover 12.2.9.2.2 and 12.2.4.2.11 through public interfaces.

All 24 match Verilator 5.052 with seeds 1 and 73. No new spec-only cases are
added; the suite has 362 tagged matches and eleven retained seed 1 differences.
Combined Ghost bundled runs have 95 matches and 278 failures with each seed;
the same tests fail at both seeds. kirimasim reports all 373 unsupported at
`uvm_object_wrapper`. Totals combine fresh runs of these 24 tests with the
fingerprint-verified unchanged 349-case baseline.

Arbitration request arrivals are separated by a positive delay before the
driver starts, so candidates are already pending. RANDOM output checks both requests
occur exactly once, without fixing their order or claiming a distribution test.
USER cases require a callback with two candidates; the single-candidate
requirement remains a separate spec-only case.

Lock queries use explicitly associated sequence objects on an idle sequencer.
Nested cases check the child can acquire under a parent lock, blocks its
parent while owning, then restores parent eligibility. Waiting acquisitions
are observed after a positive delay and before a delayed release. These are
ownership and blocking-API tests, not queued lock-versus-item ordering tests.

Immediate transport responses are computed synchronously from accepted-request
analysis and sent through the public response put port. Successful requests
are retired through the public request get interface, allowing slot reuse.
Failure cases do not prescribe the response output argument or partial queue
effects; recovery drains any residual request without asserting whether one
was queued. Object cases compare typed handle values and payloads. Blocking
tests retain watchdogs; no protected FIFO or arbitration queue is accessed.

### Seventh M2 increment

This increment adds 24 cases, bringing the suite to 397:

- Eight item-exclusion and availability cases: owner streams under lock/grab,
  lock waiting for an already granted item, FIFO lock ordering, child traffic
  under a parent lock, parent blocking under a child grab, and
  `has_do_available` transitions for lock and relevance gates.
- Eight termination cases: bound/unbound kill, lock cleanup, stopping two
  active bodies, flushing a driver-held request and accepting a fresh one,
  required post-kill hooks, and automatic-objection drop on kill.
- Eight default phase sequence cases: instance identity with randomization
  disabled, wrapper creation and randomization hooks, factory instance-override
  context, separate phase resources, higher-precedence null disabling,
  kill at phase end and two invalid wrapper types requiring errors.

Eighteen new cases match Verilator 5.052 with seeds 1 and 73. Six retain known
seed 1 differences: two lock-ordering cases, two missing post-kill-hook cases
and two invalid-default error cases. Their normative expected files remain
unchanged. Together with the fingerprint-verified 373-case baseline, totals
are 380 matches and seventeen known differences. Ghost bundled runs have
96 matches and 301 failures with each seed, with identical failing sets;
kirimasim reports all 397 unsupported at `uvm_object_wrapper`.

The driver acknowledges only live requests. After `stop_sequences` flushes
a held request, the test retrieves a fresh item before calling `item_done`.
Kill tests sample stopped state and start return after settling, then retain
an objection beyond the original delayed body action to expose surviving work.
Automatic objections are observed on an isolated task-phase node.

Default sequences run in the real runtime schedule. Phase objections leave
time for natural completion; a longer run objection also exposes a missing
phase-end kill. Randomization is checked through pre/post hooks, without
printing random values. Factory override paths follow the required sequencer
context and wrapper type name. Null-disabling uses build-time root versus
test precedence, not insertion-order assumptions. Invalid-type cases count
errors without prescribing diagnostic text.

M1 and M2 remain open. Queued ownership interactions, hierarchical stop and
response cleanup, further default-resource selection and broader callback/TLM
protocol coverage still need review and tests.

### Eighth M2 increment

This increment adds 24 cases, bringing the suite to 421:

- Eight stop cases: parent/child, siblings and a three-level tree; parent lock
  plus child grab cleanup; independence of another sequencer; automatic
  objections on standalone and nested sequences; and cancellation of an
  active `get_response` wait.
- Eight response-route cases: queue and handler rejection after natural
  finish, kill or stop; a live route surviving another sequence's kill; and
  a fresh route rejecting an old reply with the same explicit transaction ID.
- Eight default-resource cases: a nonmatching name; higher-precedence wrong
  types, including an unrelated null object; wrapper/instance precedence in
  both directions; null-wrapper disabling; and both equal-precedence queue
  orders with an interposed wrong-type entry.

Twenty-two match Verilator 5.052 at seeds 1 and 73. Two retain required
automatic-objection drop as spec-only seed 1 differences. The pinned stop
path leaves the root count raised; nested child kill drops only the child.
After observing counts, the tests clear the isolated objection. With the
fingerprint-verified 397-case baseline, totals are 402 matches and nineteen
known differences. Ghost bundled runs have 98 matches and 323 failures at
each seed, with the same failing sets. kirimasim reports all 421 unsupported
at `uvm_object_wrapper`.

Hierarchy probes inspect state and per-object hooks without assuming sibling
termination order. Independent work is allowed to finish normally after the
selected sequencer is stopped. Delayed body flags are sampled beyond their
original deadlines. The automatic-objection node is isolated from the phase
schedule, allowing its required count to be checked even on the known path.

Late responses copy routing IDs from real acknowledged requests. The warning
is checked through the severity counter. Queue probes wait for a bounded time
and cancel their own reader; handler probes inspect call counts. A stale
response must not contaminate a fresh route that reuses its transaction ID.
These cases do not claim that every already-delivered response queue is
cleared by stop.

Default resources are exercised in the real main phase. Root/test build
contexts establish distinct precedence. Equal-precedence cases use separate
resources and the public low-priority pool insertion API; filtering must
preserve the first valid entry's position. Constructor markers and identity
checks distinguish wrapper creation from an instance. Randomization checks
use hook counts rather than random values. M1 and M2 remain open.

### Ninth M2 increment (2026-11-01)

This increment adds 24 cases, bringing the suite to 445:

- Eight canonical-time cases: explicit and default names, the standard
  default-resolution API, absolute-unit conversion and replacement, reset
  across resolutions, scaled increment/decrement, alias mutation and a
  blocking annotation update with no simulation-time advance.
- Eight nonblocking socket cases: pass-through initiator and target paths,
  paired paths and nested paths, immediate completion and accepted requests
  with automatic backward completion or an updated phase.
- Eight callback iterator cases: static forward/backward exhaustion and
  reset, typewide context, independent integer positions and object contexts,
  and facade restart with valid current-callback observations.

Twenty-one new cases match Verilator 5.052 at seeds 1 and 73. Three retain
spec-only expectations: the constructor name differs at seed 1, the standard
time setter is missing at build time, and nested initiator backward routing
fails at seed 1. The suite has 423 matches and 22 known differences after
combining the fresh increment with the fingerprint-verified 421-case baseline.
Of the known records, 21 are runtime seed 1 differences and one is a build
failure without a runtime seed. Ghost bundled results have 103 matches and
342 failures with each seed; kirimasim has 444 unsupported and one missing-API
failure. The failing Ghost sets match across seeds.

Time comparisons use real tolerances and explicit unit conversions. The
scaled-operation case uses a 100-second scale literal so it is nonzero at
every legal time unit; it does not wait for that interval. Values stay within
canonical range and do not test sub-resolution rounding or negative times.
The standard setter is kept under its normative name rather than replaced
with the library's legacy API.

Socket cases use normal elaboration and parent-port/child-export hierarchy.
Connect methods supply the backward wiring; a manual workaround would hide
the nested initiator difference. Payload and delay identities, annotations,
phase references and statuses are observed, not internal port storage.
These cases do not establish full TLM 2 protocol or timing coverage.

Iterator positions stay opaque. Registration is completed before traversal;
disabled entries and instance-only entries are excluded where required.
Facade `get_cb` is observed after valid accesses, without prescribing its
value after exhaustion. M1 and M2 remain open.

### Tenth M2 increment (2026-11-01)

This increment adds 24 cases, bringing the suite to 469:

- Eight push-sequencer/driver cases: typed connections and hierarchy,
  blocking completion, ordered repeated requests, response routing and IDs,
  common request/response histories, response handlers and handle mutation.
- Eight sequence-action macro cases: item and child creation/context,
  unrandomized sends, randomized item and child sends, disabled child
  randomization, and combined item creation/randomization/execution.
- Eight generic-payload packing cases: public decoding in prescribed field
  order, scalar round trips, active data and byte-enable prefixes, fatal
  reports for short arrays, omitted source extensions and preserved
  destination extensions.

Twenty-one new cases match Verilator 5.052 at seeds 1 and 73. Three retain
spec-only expectations for repeated push delivery and its request/response
histories. The library leaves a completed request in its FIFO, so sending the
next request is rejected. No manual FIFO drain or pull acknowledgement is
added to make the push tests pass.

The suite has 444 matches and 25 known differences after combining the fresh
increment with the fingerprint-verified 445-case baseline. Of the known
records, 24 are runtime seed 1 differences and one is a build failure without
a runtime seed. Ghost bundled results have 105 matches and 364 failures with
each seed, with the same failing sets. kirimasim has 468 unsupported cases at
`uvm_object_wrapper` and one missing-time-API failure.

Push timing checks sample inside a positive blocking delay. Responses use
real request IDs and distinct request/response types. Macro randomization
uses singleton constraints and callback counts; item sends also check the
driver's received handle. Child hook checks distinguish `body` from the
optional pre/post hooks. Payload tests use public packer operations rather
than raw stream encodings or object markers. Fatal probes request termination
inside the report catcher and do not prescribe post-fatal payload contents.
README, glossary, FAQ and known-difference pages are updated in both
languages. M1 and M2 remain open.

### Eleventh M2 increment (2026-11-01)

This increment adds 24 cases, bringing the suite to 493:

- Eight library-registration cases: single/bulk duplicate suppression,
  enumeration after a caller prefix, local removal, absent-type warnings,
  typewide additions for future instances and static removal propagation.
- Eight library-selection/control cases: direct default-selector wrap and
  independent positions; standard mode defaults/updates, count-bound
  defaults/constraints, and initial/active/completed execution counts.
- Eight macro cases: combined child actions and alternate context, item and
  child factory overrides, randomized/unrandomized item hook order, field
  `rand_mode` after creation and typed-sequencer variable declaration.

Sixteen new cases match Verilator 5.052 at seeds 1 and 73. Two spec-only
removal cases differ at seed 1: absent removal does not warn, and static
removal does not update another existing instance. Six further spec-only
cases cannot build because seven standard sequence-library methods are
absent. Required calls are not replaced with legacy fields.

The suite has 460 matches and 33 known differences after combining the fresh
increment with the fingerprint-verified 469-case baseline. Known records
comprise 26 runtime seed 1 differences and seven build failures with no
runtime seed. Ghost bundled results have 107 matches and 386 failures with
each seed and identical failing sets. kirimasim has 486 unsupported cases at
`uvm_object_wrapper` and seven missing-API failures: one time setter and six
sequence-library cases.

Registration probes use public enumeration and membership counts without
assuming insertion order. Typewide additions are tested before and after
construction; removal checks distinguish local from static registration.
Selector calls store results in separate statements. Direct hook calls do
not establish a USER-mode execution result, and missing API cases do not
claim an executed counter observation.

Macro constraints have one legal result. Hook traces distinguish parent
`pre_do`/`mid_do`/`post_do`, randomization callbacks and driver receipt.
Factory probes inspect the created subtype and context; field-disabled
randomization still checks its callback. The typed declaration probe uses an
explicit cast before subtype access. Both README languages, glossary, FAQ
and known differences are updated. M1 and M2 remain open.

### Twelfth M2 increment (2026-11-01)

This increment adds 24 cases, bringing the suite to 517:

- Eight TLM 1 cases: blocking/nonblocking and combined master/slave imps
  delegate to distinct request/response siblings; combined exports preserve
  that routing. Integer requests and string responses exercise capacity,
  availability, peek retention and storage reuse.
- Eight low-level sequence cases: waiting for driver demand, default send
  without rerandomization, explicit rerandomization, delayed acknowledgement,
  selective transaction completion, implicit completion through `get`, a
  grant lock request and forwarding priority/origin to the current sequencer.
- Eight TLM 2 cases: blocking export completion, nested zero-wait annotation,
  repeated payloads, nonblocking forward/backward phase updates, a round trip
  with both paths explicitly connected, and nested exports carrying custom
  transaction/phase types in each direction.

All 24 new cases match Verilator 5.052 at seeds 1 and 73. After combining the
fresh increment with the fingerprint-verified 493-case baseline, the suite
has 484 matches and 33 known differences. The known records remain 26 runtime
seed 1 differences and seven missing-API build failures with no runtime seed.
Ghost bundled results have 107 matches and 410 failures at each seed, with
identical failing sets. kirimasim has 510 unsupported cases at
`uvm_object_wrapper` and seven missing-API failures.

The split imp's parent supplies no transfer implementation: its constructor
selects sibling FIFO components for the two directions. Failed reads do not
assert unspecified output arguments. Low-level send follows grant without
consuming time; explicit-ID waits start before the corresponding completion.
Positive acknowledgement delays expose the waiting state, and the grant
observer delegates to real sequencer arbitration.

Ordinary TLM 2 exports use normal parent-to-child hierarchy. The round trip
connects forward and backward paths separately. Targets expose shared handle
identity and canonical annotations, while the blocking test samples inside
a positive target delay. Custom phase types test generic propagation rather
than claiming a base-protocol exchange. Both README languages, glossary, FAQ
and current result counts are updated. M1 and M2 remain open.

### Thirteenth M2 increment (2026-11-01)

This increment adds 24 cases, bringing the suite to 541:

- Eight FIFO-analysis cases: blocking/nonblocking put and get fanout,
  blocking/nonblocking peek notifications, rejected puts and availability
  queries, and object-handle identity on both analysis paths.
- Eight `start_item` cases: explicit/item/parent sequencer precedence,
  nonnegative and negative priority selection, plus required ERROR and early
  return for null items, non-item sequences and missing sequencer context.
- Eight explicit-object callback macro cases: context switching, dispatcher
  exclusion, disable/reenable, typewide plus local membership, true/false
  early exit, traversal without a match and an empty external context.

Nineteen new cases match Verilator 5.052 at seeds 1 and 73. Five retain
spec-only expectations at seed 1: the library omits two kinds of FIFO peek
notification and emits FATAL instead of ERROR for three invalid `start_item`
inputs. The suite has 503 matches and 38 known differences after combining
the fresh increment with the fingerprint-verified 517-case baseline.
Known records comprise 31 runtime seed 1 differences and seven missing-API
build failures without runtime seeds. Ghost bundled results have 108 matches
and 433 failures at each seed, with identical failing sets. kirimasim has
534 unsupported cases at `uvm_object_wrapper` and seven missing-API failures.

FIFO observers keep separate histories, without assuming an order among
subscribers. Peek tests check retained occupancy independently from required
notification counts. Failed-read output arguments are ignored, and rejection
or availability queries do not add transactions to observer histories.

Sequencer-selection probes use real requests on three separately connected
drivers and observe normal arbitration and pre/mid/post hooks. Invalid-input
probes count the original report severity in a catcher without rewriting it,
then inspect the early return and absence of `pre_do`.

Callback macros receive stable external contexts and function callbacks.
Boolean matches stop before later callbacks. No-match and empty-context
cases inspect invocation counts without prescribing a return or fallthrough
policy. Both README languages, glossary, FAQ and known differences are
updated. M1 and M2 remain open.

### Fourteenth M2 increment (2026-11-01)

This increment adds 24 cases, bringing the suite to 565:

- Twelve put/get/peek/get-peek declaration families: blocking, nonblocking
  and combined interfaces route to two independently suffixed handlers.
- Six master/slave declaration families: integer requests and string
  responses retain the selected suffix in both directions.
- Three transport declaration families and the analysis declaration:
  request/response pairs and per-input histories reach their selected methods.
- Two additional cases preserve class handles on generated analysis inputs
  and bind generated master imps to separate request/response siblings.

All 24 new cases match Verilator 5.052 at seeds 1 and 73. Combined master,
slave and split-master cases also exercise successful nonblocking writes
after rejection and storage reuse, plus readiness before and after reads.
Their final sources were rerun on every runner. After combining this evidence
with the fingerprint-verified 541-case baseline, the suite has 527 matches
and 38 known differences: 31 runtime seed 1 differences and seven missing-API
build failures without runtime seeds. Ghost bundled results have 110 matches
and 455 failures at each seed, with identical failing sets. kirimasim has
558 unsupported cases at `uvm_object_wrapper` and seven missing-API failures.

Each generated imp is exercised through an ordinary port. Implementations
provide suffixed methods without unsuffixed transfer methods. Different lane
data and availability expose routing mistakes; delayed blocking handlers
verify completion before the call returns. Failed outputs are ignored.
The split case puts no transfer methods on the imp's parent and supplies
the request/response implementation handles explicitly.

B.5.11 has a heading and class description for nonblocking get/peek, while
its displayed invocation uses the peek-only spelling. That case explicitly
follows the heading and described class. The source comment and FAQ retain
this interpretation as a review item; fixed-release reproduction alone does
not resolve the spelling discrepancy. All tests remain `spec_check: ai`.
Both README languages, glossary, FAQ and current results are updated.
M1 and M2 remain open.

### Fifteenth M2 increment (2026-11-01)

This increment adds 24 cases, bringing the suite to 589:

- Eight library cases: static registration on two instances or two types,
  inherited membership and local additions, plus default RAND execution
  with one/two eligible types and singleton constraints on either type.
- Eight extension cases: polymorphic type-key/name identity, renaming,
  insertion/replacement/clearing through keys, and shared payload state
  through the `uvm_tlm_gp` alias.
- Eight finish-item cases: explicit completion IDs, virtual submission/wait
  dispatch, ordered mid-do mutation and post-do acknowledgement, and three
  required invalid-input guards.

Thirteen new cases match Verilator 5.052 at seeds 1 and 73. Eleven preserve
normative expectations at seed 1: four static-library construction cases,
two virtual-dispatch cases, two completion-ID cases and three input guards.
The guard paths terminate before their expected normal return. Combined
with the fingerprint-verified 565-case baseline, the suite has 540 matches
and 49 known differences: 42 runtime seed 1 differences and seven build
failures without runtime seeds. Ghost bundled results have 112 matches and
477 failures per seed with identical failing sets. kirimasim has 582
unsupported cases at `uvm_object_wrapper` and seven missing-API failures.

Library construction uses the standard subtype constructor pattern and
required macros without an extra implementation-specific initialization
call. Positive execution probes use instance registration and retain the
legal default count of ten. Forced choices find indices by public enumeration
and constrain the standard selection variable; unforced execution checks
only the total, without a distribution or order requirement. These probes
do not call or replace the missing standard control/counter APIs.

Finish-item observers delegate to real sequence/sequencer APIs and
acknowledge actual driver requests after positive delays. Required method
calls and transaction IDs are observed separately from successful data
transfer. The matching hook case snapshots mutation at submission and
checks post-do after acknowledgement. Invalid guards require ERROR and
return before mid-do; no post-fatal continuation is prescribed.

Extension probes dispatch through common base handles and compare type
identity without numeric IDs or literal qualified-name formatting. Names
of instances and types remain distinct concepts. Both README languages,
glossary, FAQ and known differences are updated. M1 and M2 remain open.

## M3: register model foundations (2026-11-01)

The first M3 increment adds 24 chapter 18 cases, bringing the suite to 613.
M1 remains at 229 cases and M2 at 360. Both retain open clause targets.

- Eight field cases: configured identity/layout and volatility, desired versus
  mirrored values, direct prediction of RO state, RO and W1C set policies,
  HARD/SOFT reset values and deletion of one reset kind.
- Eight register/block cases: rounded byte width and parent identity,
  LSB-ordered fields, desired-value slicing, aggregate prediction and reset,
  update need, recursive block reset, default-map selection and model locking.
- Eight map cases: byte/word units, little/big-endian address arrays,
  local/external addresses, independent map rights, base relocation, and
  hierarchical offsets with the narrowest bus width.

Twenty new cases match Verilator 5.052 at seeds 1 and 73. Four retain
spec-only differences at seed 1: pre-lock field lookup, pre-lock bus width,
the physical-address translation byte count, and hierarchical width/byte counts.
Pre-lock probes also observe the corresponding successful lookup/width after
locking; address arrays are checked separately from returned transfer widths.
Combined with the fingerprint-verified 589-case baseline, there are 560 matches
and 53 known differences: 46 runtime differences at seed 1 and seven
missing-API build failures without runtime seeds. Ghost bundled results have
116 matches and 497 failures per seed with identical failing sets. kirimasim has 606
unsupported cases at `uvm_object_wrapper` and seven missing-API failures.

The model-only operations do not read, write or reset a DUT. Direct prediction
ignores access policy, whereas set applies it. Physical address arrays follow
least-significant data order, including descending numbers for the big-endian
case. Multi-map register checks specify their map arguments; the library's
declared memory multi-mapping and null-map resolution deviations remain
outside the matching scenarios. No deprecated API or DPI is requested.

Both README languages now describe M3 as started. The glossary and FAQ explain
model values, map units and the remaining interaction work, and known
differences retain their normative expectations. Tool tests, metadata,
library integrity, evidence fingerprints and documentation links were checked.
All tests remain `spec_check: ai`; M1, M2 and M3 remain open.

## Second M3 increment: memory, prediction and map controls (2026-11-01)

This increment adds 24 cases, bringing the suite to 637 and M3 to 48.
M1 remains at 229 and M2 at 360; all three stages retain open targets.

- Eight memory cases: dimensions, map membership, indexed offsets and
  addresses, wide big-endian and word-addressed locations, relocation,
  effective access and registration on two independent interface maps.
- Eight field prediction cases: RC/RS reads, W1C/W1S/W1T and W0C/W0S writes,
  and write-once protection across SOFT versus HARD reset.
- Eight map cases: register/submap relocation, scoped default SOFT reset,
  preserved address arrays on rejection, shared RO/WO addresses, invalid
  submap lookup, conflicting permissions and independent auto-predict flags.

Twenty-two additions match Verilator 5.052 at seeds 1 and 73. Two retain
normative memory expectations at seed 1: location-specific offsets and
single-map effective access. The first ignores the location despite correct
external addresses; the second omits the map's RO access restriction.
Combined with the fingerprint-verified 613-case baseline, there are 582 matches
and 55 known differences: 48 runtime differences at seed 1 and seven missing-API
build failures without runtime seeds. Ghost bundled results have 134 matches
and 503 failures per seed with identical failing sets. kirimasim has 630
unsupported cases and seven missing-API failures.

The executable fingerprint for Ghost changed since the baseline. All 637
cases were therefore rerun at both seeds for its bundled library. A first
attempt discarded results when execution inputs changed again. The accepted
run uses a private snapshot of the executable and profiles. Its older
pinned-library smoke result is historical; the sampled build has no
pinned-mode measurement. Verilator and kirimasim retain compatible baseline
conditions.

The rights/access case follows 18.6.4.5's unshared-memory RW rights contract
separately from 18.6.4.6's effective map access. The two-interface memory case
matches the cited add_mem rule with no error.
That narrow setup does not resolve the release's multiple-map note or establish
shared-map hierarchy behavior. Memory tests do not store mirrors or access
DUT data. READ/WRITE predictions use synthetic observations, and auto-predict
flags do not establish automatic prediction during real traffic. Lookup
relocation cases use zero root bases; original report severity and required
return/output preservation are observed for the negative paths.

Both README languages, glossary, FAQ and known differences are updated.
Tool tests, metadata, pinned-library integrity, evidence fingerprints and
local documentation links were checked. All cases use UVM_NO_DPI, retain
spec_check: ai and request no deprecated API. M1, M2 and M3 remain open.

## Third M3 increment: adapters, predictors and frontdoor (2026-11-01)

This increment adds 24 cases, bringing the suite to 661 and M3 to 72 across
chapters 18–19. M1 remains at 229 and M2 at 360; all three stages remain open.

- Seven TLM adapter cases and one operation-descriptor array case: command,
  address, byte length/enables, allocation, response conversion, callback
  scope and prescribed array resize behavior.
- Eight predictor cases: metadata publication, RW/RO and RC/W1C policies,
  complete wide-word accumulation in both endian modes, ignored observations
  and target/value redirection.
- Eight frontdoor paths: read/write auto-prediction settings, a separate
  response, wide writes, big-endian read reconstruction and adapter context.

Twenty-two additions match Verilator 5.052 at seeds 1 and 73. Two retain
runtime differences at seed 1: predictor target redirection and big-endian
frontdoor read reconstruction. Combined with the verified 637-case baseline,
there are 604 matches and 57 known differences: 50 runtime seed 1 differences
and seven missing-API builds without runtime seeds. Ghost uses the same
executable/profile snapshot as the baseline; combined results have 140
matches and 521 failures per seed with identical failing sets. kirimasim
was measured over the whole suite on a newly frozen build, with corrected
cases refreshed, giving 654 unsupported cases and seven missing-API failures.

Frontdoor fixtures use real sequencer/driver handshakes and positive-delay
acknowledgements against testbench storage. Passive predictor fixtures use
separately supplied observations. They do not claim RTL or integrated bus
monitor coverage. Uniform TLM data bytes avoid a numeric byte-order mapping;
failed-read data and unspecified transfer order are left unconstrained.
The big-endian frontdoor read uses the standard TLM adapter and repeated payload bytes.
Virtual overrides match base argument names and extensions use a concrete token.

Both README languages, glossary, FAQ and known differences are updated, with
a diagram distinguishing active and passive fixtures. Tool tests, metadata,
pinned-library integrity, current input/runner/configuration fingerprints,
documentation links and diagram rendering were checked. All cases retain
spec_check: ai, UVM_NO_DPI and no deprecated API.

## Fourth M3 increment: memory transfers and register access hooks (2026-11-01)

This increment adds 24 chapter 18 cases, bringing the suite to 685 and M3
to 96: 79 in chapter 18 and 17 in chapter 19. M1 remains at 229 and M2 at
360; all three stages remain open.

- Eight memory frontdoor paths: nonzero location selection, separate
  responses, little-endian wide reads/writes, word addressing and full-width
  burst reads/writes.
- Eight register cases: clean/dirty update, W1C/W1S update commands, mirror
  checking and disabled comparison, and read/write bus-error propagation
  followed by successful retry.
- Eight access-hook cases: pre-write value replacement, pre-access rejection,
  post-read data and post-access status replacement, and register/field
  pre-read/pre-write order.

Twenty additions match Verilator 5.052 at seeds 1 and 73. Four retain
spec-only expectations: two for register hooks preceding field hooks and
two for physical memory burst beats using READ/WRITE kinds. Fixed UVM
reverses the hook order and passes abstract burst kinds to the adapter. Combined with the unchanged 661-case baseline
at 256d873, there are 624 matches and 61 known differences: 54 runtime seed 1
differences and seven missing-API builds without runtime seeds. The same
fixed executable/profile snapshots give Ghost 145 matches and 540 failures
per seed, with identical failing sets, and kirimasim 678 unsupported cases
plus seven missing-API failures. Input, runner, version and configuration
fingerprints were checked before combining evidence.

The memory burst fixtures align memory, bus and data-array element widths
at 64 bits; they do not establish narrow-memory packing or partial-beat
behavior. Failed-read data and the failed-operation mirror boundary are
unconstrained. The storage driver is not an RTL DUT or UVM memory mirror.
Access-hook cases override inherited methods without registering callback
objects. Broader memory/error/policy conditions and integrated prediction
remain open.

Both README languages, glossary, FAQ and known differences are updated.
Tool tests, metadata, pinned-library integrity, evidence fingerprints and
local documentation links were checked. All cases retain spec_check: ai,
UVM_NO_DPI and no deprecated API.

## Fifth M3 increment: custom frontdoors, callbacks and virtual layout (2026-11-01)

This increment adds 24 cases, bringing the suite to 709 and M3 to 120:
95 in chapter 18 and 25 in chapter 19. M1 remains at 229 and M2 at 360;
all three stages remain open.

- Eight custom frontdoor cases: register/memory data and status, an unmapped
  register, operation and sequencer context, and map-specific replacement.
- Eight registered callback cases: value/status changes, early rejection,
  removal, same-register method/callback order and field post-prediction.
- Eight virtual-register/field foundations: parent/unimplemented state,
  static packing/stride, map/address queries, field layout/order/name lookup
  and byte width rounded to the implementing memory.

Twenty-three additions match Verilator 5.052 at seeds 1 and 73. One retains
the memory-rounded byte width required by 18.9.1.2.9 as spec-only. Combined
with the unchanged 685-case baseline at 7206861, there are 647 matches and
62 known differences: 55 runtime seed 1 differences and seven missing-API
builds without runtime seeds. The same fixed executable/profile snapshots
give Ghost 149 matches and 560 failures per seed with identical failing sets,
and kirimasim 702 unsupported cases plus seven missing-API failures. Input,
runner, version and configuration fingerprints were checked before merging.

The custom sequence models storage in its body; it does not exercise the
adapter/driver path. Registered callback cases distinguish inherited methods
from registration and supply one field prediction without bus traffic.
Virtual-register cases query static model layout without data transfers,
dynamic allocation or reservation-ownership checks. A bilingual FAQ table
explains memory-word stride and external-address calculation.

Both README languages, glossary, FAQ and known differences are updated.
Tool tests, metadata, pinned-library integrity, evidence fingerprints and
local documentation links were checked. All cases retain spec_check: ai,
UVM_NO_DPI and no deprecated API.

## Sixth M3 increment: virtual transfers and memory regions (2026-11-01)

This increment adds 24 chapter 18 cases, bringing the suite to 733 and M3
to 144: 119 in chapter 18 and 25 in chapter 19. M1 remains at 229 and M2 at
360; all three stages remain open.

- Eight frontdoor cases: packed/padded virtual array access, partial-field
  preservation and cross-location reads, wide memory over a narrow bus,
  region-relative read/write and virtual-read error/retry.
- Eight virtual implementation cases: region geometry, movement within and
  between memories, release/reuse, static release rejection, overlap
  rejection, omitted-memory resize and region-owner lookup.
- Eight memory-manager cases: rounded reservation geometry, overlap/bounds,
  individual/all release, order-independent iteration/reset, compatible
  reconfiguration and a singleton allocation policy.

Twenty-two additions match Verilator 5.052 at seeds 1 and 73. Two retain
required results as spec-only: resizing without a memory argument and the
region's implementing virtual-array owner. Combined with the unchanged
709-case baseline at 92ee613, there are 669 matches and 64 known differences:
57 runtime seed 1 differences and seven missing-API builds without runtime
seeds. The same fixed executable/profile snapshots give Ghost 150 matches
and 583 failures per seed with identical failing sets, and kirimasim 726
unsupported cases plus seven missing-API failures. Input, runner, version
and configuration fingerprints were checked before merging.

Transfers use the adapter, sequencer and positive-delay testbench driver,
without an RTL DUT or virtual-register mirror. Failed-read data is left
unconstrained. Dynamic cases release through the virtual register; direct
manager release protection and virtual-register random allocation remain
open. Iteration does not prescribe address order, reconfiguration checks
values, and the request policy has one legal start location. A bilingual
FAQ diagram distinguishes dynamic and static implementation lifecycles.

Both README languages, glossary, FAQ and known differences are updated.
Tool tests, metadata, pinned-library integrity, evidence fingerprints,
local documentation links and the new diagram rendering were checked.
All cases retain spec_check: ai, UVM_NO_DPI and no deprecated API.

## Documentation organization (2026-11-01)

Both README files now describe current scope, prerequisites, commands,
results and open work. Increment narratives remain in this history.
Detailed test/development instructions, current evidence methodology and
source provenance have paired guides. All guides have corresponding English
and Japanese content, and glossary entries use the same order. The original
LICENSE is unchanged; a complete, non-authoritative Japanese translation is
available. tools/UPSTREAM points to the paired provenance guides in both
languages. This changes documentation only: 733 tests, 669 tagged oracles,
64 spec-only cases and the recorded measurements remain unchanged.
