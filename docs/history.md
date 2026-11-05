# Development history

[日本語](history.ja.md) · [README](../README.md)

Counts on this page belong to the time of each change, so use [the current snapshot](results.md#current-snapshot) when you need the present suite size or execution scope.

These records cover M1, fifteen M2 increments, nine M3 increments,
three M4 increments and seventy cross-milestone thin-area expansions, including the
existing-test requirement-link backlog checkpoint (2176 tests: 2084 simulation and 92 elaboration). The earlier 349-test checkpoint is
[500f22e](https://github.com/kurochan001/kirimasim-uvm-tests/commit/500f22e10c3ce62a497df929232a562b78952fc5).
Counts, measurements and statements about missing tests describe each
increment at that time. Current scope and commands are in the README;
current library limitations are in [known differences](known-differences.md).

Use these entry points to trace why an area was added, and [the handoff priorities](handoff.md#remaining-work-and-suggested-order) to choose current work.

- [M1: core UVM](history.md#m1-increments)
- [M2: sequences and TLM](history.md#m2-increments)
- [M3: register model](history.md#m3-register-model-foundations-2026-11-01)
- [M4: requirement ledger](history.md#first-m4-increment)
- [Cross-milestone expansions](history.md#thin-area-expansion-across-m1m4)
- [Traversal declarations and defaults](history.md#sixty-ninth-thin-area-expansion-traversal-declarations-and-defaults)

## Ghost bundled-library measurements

A bundled run uses the simulator-supplied UVM library, and [Q11](faq.md#q11-what-does-the-ghost-result-cover-and-why-an-alias) explains the execution condition behind these historical counts.

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

## Seventh M3 increment: allocation, virtual callbacks and user backdoors (2026-11-01)

This increment adds 24 cases, bringing the suite to 757 and M3 to 168:
135 in chapter 18 and 33 in chapter 19. M1 remains at 229 and M2 at 360;
all three stages remain open.

- Eight virtual-allocation cases: supplied policy, region/array geometry and
  address, release/reuse, same-memory and cross-memory relocation,
  contradictory-policy and static rejection, and wide-memory units.
- Eight virtual callback cases: register data/status, field-slice changes,
  parent write-hook order and standalone field post-write order.
- Eight user backdoor cases: raw poke/peek, RO/W1C write and RC read effects,
  memory locations, block/local handler precedence and error/retry.

Twenty-two additions match Verilator 5.052 at seeds 1 and 73. The standalone
field post-write callback order retains its required `cM` result as spec-only;
the library runs `Mc`, while the parent-operation control matches. The RC user-
backdoor case also retains a zero post-read mirror with explicit auto-prediction;
the library instead mirrors the sampled value despite correctly clearing storage. Compatible
733-case baseline records at ac008b6 combine with fresh measurements to give
691 matches and 66 known differences: 59 runtime seed 1 differences and seven
missing-API builds without runtime seeds. The same fixed snapshots give the
project's guest Ghost 150 matches and 607 failures per seed with identical
failing sets, and kirimasim 750 unsupported cases plus seven missing-API
failures. Input, runner, version and configuration fingerprints are checked.

The allocation policies have one legal start and establish controlled
handoff rather than statistical allocation behavior. User backdoors model
storage with required pre/post helper calls and keep UVM_NO_DPI; they do not
exercise a vendor backend or HDL path. Failed-read data is unconstrained.

The reporting policy and bilingual Issue form follow kirimasim-tests:
commercial simulator execution/comparison and reuse of third-party outputs,
diagnostics or anonymized summaries are excluded. The form includes required
confirmation; blank issues are disabled for ordinary contributors. It is
not an automatic content filter. Guest Ghost publication and privacy remain
separate from commercial-product results; the alias is not a posting bypass.

README stays current-state only. Results, testing guide, FAQ, glossary,
known differences, provenance and this history are updated in both languages.
Tool tests, metadata, library integrity, evidence fingerprints, bilingual
structure, links and Issue-form YAML were checked. No commercial simulator
results were used. All tests retain spec_check: ai and no deprecated API.

## Eighth M3 increment: annex E register and memory test sequences (2026-11-01)

This increment adds the first 24 annex E cases in a new directory, bringing
M3 to 192 and the suite to 781 in 15 chapter/annex directories. Chapters 18
and 19 remain at 135 and 33 cases; annex E has 24. M1 remains at 229 and M2
at 360. All stages retain open targets.

Six cases each exercise hardware-reset checking, bit bash, register access
and memory walk. They cover selected single/block sequences, available maps,
hierarchy and exclusion resources. Register access shares storage between
custom frontdoors and user backdoors; other families use custom frontdoors.
All handlers use positive delays without RTL, HDL paths, DPI or vendor backends.
Reset storage is initialized before the sequence; physical DUT reset behavior
remains untested. Expected outputs constrain traffic, data consistency and
fault detection rather than internal patterns, order or diagnostic wording.

Each data-fault case has a clean run first: wrong reset value, a stuck
register bit, disagreement between access paths and a stuck memory bit.
Exact-scope exclusions include peer or directly selected controls. Observation
counters restart before each fault or direct control. The
block-scoped memory-walk exclusion remains spec-only: E.6.2 names
NO_MEM_WALK_TEST, while the pinned wrapper checks NO_MEM_ACCESS_TEST instead.
The direct single-memory control still works.

Twenty-three additions match Verilator 5.052 at seeds 1 and 73. Compatible
757-case baseline evidence at 4c7f452 combines with fresh final measurements
to give 714 matches and 67 known differences: 60 runtime seed 1 differences
and seven missing-API builds without runtime seeds. The same fixed snapshots
give guest Ghost 152 matches and 629 failures per seed with identical failing
sets, and kirimasim 774 unsupported cases plus seven missing-API failures.
The two annex E guest matches observe skip behavior without transfers.
Current input, runner, version and configuration fingerprints were checked.

README remains focused on current scope. Both languages of results, testing,
FAQ, glossary, known differences and this history are updated. A paired FAQ
table maps sequence families to their observations. Checks cover tool tests,
metadata, pinned-library integrity, bilingual structure, local links, public
privacy and staged whitespace. No commercial simulator results were used.
All cases retain spec_check: ai, UVM_NO_DPI and no deprecated API.

## Ninth M3 increment: memory/shared access and test selection (2026-11-01)

This increment adds 24 annex E cases, bringing M3 to 216 and the suite to
805 in 15 chapter/annex directories. Chapters 18 and 19 remain at 135 and 33;
annex E reaches 48. M1 remains at 229 and M2 at 360. All stage targets stay open.

Six cases each cover memory frontdoor/backdoor access, shared-register
access, shared-memory access and dispatcher selection. The fixtures check
four memory locations, two/three maps and directed writer/reader observations,
hierarchy, exact-scope exclusions and read-data faults after clean controls.
Observation windows clear counts, masks and last-writer metadata without
changing shared storage. Random payloads and internal access order/counts
are not printed as oracles. No RTL, HDL DPI or vendor backend is involved.

The dispatcher uses a subclass of the standard's virtual base. It checks the
default 64-bit all-tests mask without running all selections, zero selection
with a reset control, individual reset/register-access/memory-access flags,
and ORed bit-bash/memory-walk flags in the order specified by 17.2.2.10.
The combined access wrapper and HDL-path sequence remain open.

Twenty-three additions match Verilator 5.052 at seeds 1 and 73. One retains
E.5.1's NO_MEM_SHARED_ACCESS_TEST exclusion as spec-only; pinned UVM checks
NO_MEM_ACCESS_TEST instead. A separately scoped memory remains a successful
control. Compatible 781-case records at c253fc9 combine with final fresh
measurements to give 737 matches and 68 known differences: 61 runtime seed 1
differences and seven missing-API builds without runtime seeds. The same fixed
snapshots give guest Ghost 153 matches and 652 failures per seed with identical
failing sets, and kirimasim 798 unsupported cases plus seven missing-API failures.
Guest annex E matches cover only skip conditions. Current
input, runner, version and configuration fingerprints were checked.

Both languages of README, results, FAQ, glossary, known differences and
history are updated. The FAQ table covers all eight selected sequence groups;
remaining work and guest measurement scope are explicit. Checks include
41 tool tests, 805 metadata records, pinned-library integrity, bilingual
structure, local links, historical preservation, privacy and staged whitespace.
No commercial simulator results were used. All tests retain spec_check: ai,
UVM_NO_DPI and no deprecated API.

## First M4 increment

Start the [requirement ledger](requirements.md), retaining all M1–M3 targets
as incomplete. Index all 805 unchanged tests and the existing 2,504 clause
identifiers. Propose candidate roots 5–19/B–G (2,479 identifiers), context
roots 1–4 (16) and deferred deprecated annex H (9). This is a scope proposal,
not denominator approval. Normative decomposition remains incomplete and
no percentage is published.

Add 36 original bilingual AI-drafted obligations across core UVM, reporting,
factory, phases, objections, configuration, policies, callbacks, TLM,
sequences/sequencers, register models and annex E, plus unlinked candidates
for databases, pools, agents, HDL deposit, string splitting and command-line
arguments. Thirty requirements link directly to existing tests; one separate
parent-register test is a control, leaving 774 tests without requirement links.
Thirty-five clause identifiers have partial decompositions and 2,469 remain
unassessed. No entry is marked human-reviewed or complete.

The census distinguishes 356 primary-focus identifiers from 814 identifiers
with any UVM citation. For candidate identifiers it reports 2,123 with zero
primary tests, 157 with one and 199 with at least two. These placement counts
are not a normative denominator or a sufficiency judgment. Explicit oracle
anchors are not measured passes; direct links retain known differences.

Add validation, inventory and index-proposal commands. Reject malformed or
non-bilingual data, duplicate IDs/keys, unknown references, absent oracle
anchors, stale input fingerprints and unsupported approval claims. Preserve
linked snapshots during sync until reassessment; keep controls separate and
protect canonical inputs from generated outputs. Add the ledger check to CI
and update the paired guides, FAQ and glossary.

Validation passes 61 tool unit tests, 805 metadata records, the 36-entry ledger
and pinned-library integrity. Verify bilingual structure, local links,
historical preservation, canonical license, privacy and whitespace. Existing
805-case input/runner fingerprints still match the recorded Verilator,
kirimasim and guest evidence; simulation sources, expectations, runners and
library lock are unchanged. No new simulation or commercial result is used.

## Second M4 increment

Add 139 original bilingual AI-drafted obligations, bringing the ledger to
175. There are 163 requirements with direct links to 190 distinct tests,
12 without direct tests, one separate control test and 614 tests with no
requirement link. The 36 original entries retain their identities and text.
The scope remains proposed and the normative inventory incomplete: 115 clause
identifiers are partially decomposed and 2,389 unassessed. No denominator,
percentage, human review or stage completion is asserted.

Map all existing primary-focus tests in chapter 5 (42), annex B (54), annex C
(16), annex D (6) and annex E (48). Split object lifecycle time/event rules,
invalid field-operation accessors and callback traversal operations into
separate obligations. Use multiple fixtures where conditions differ and allow
several independent obligations to share one test. Distinguish each exclusion
resource's actual name and element/block scope. Preserve known library
expectations and B.5.11's conflicting-invocation interpretation for review.

Keep six new annex E obligations unlinked: register-access block exclusion,
the combined access wrapper, HDL-path accessibility, the walking-ones
algorithm and two unknown-policy skip rules. Existing location masks are
linked only to a necessary access property, not promoted to full algorithm
verification. An empty unmapped-test queue does not finish decomposition.

Add root totals and a backlog command with an optional exact-root filter.
Separate requirements without direct tests, tests without either role and
unassessed identifiers, retaining context/deferred scope. Assign requirement
roots by their own clauses and test roots by primary citation, including
cross-root links from chapter 17 to annex E. Validate the whole ledger before
filtering; protect generated-output destinations. Extend the regression suite
with eight checks for these distinctions and update the paired guides.

Validation passes 69 tool unit tests, 805 metadata checks, all 175 ledger
entries and pinned-library integrity. Check generated full/root reports,
root/global totals, local links, bilingual structure, history and privacy.
Simulation inputs, runners, expectations and lock are unchanged; recorded
Verilator, kirimasim and guest input/runner fingerprints still match all
805 cases. No new simulation run or commercial result is used.

## Third M4 increment

Add 180 original bilingual AI-drafted requirements for reporting, factory,
phasing, objections/callbacks and policies. The ledger now has 355 entries:
331 requirements directly linked to 374 tests, 24 without direct tests, one
separate control and 430 tests with neither link role. Partially decomposed
clause identifiers increase to 257, with 2,247 unassessed. Scope and denominator
remain unapproved and every requirement review remains AI-only.

Map all existing primary-focus tests in chapters 6 (28), 8 (32), 9 (19),
10 (36) and 16 (80), in addition to the five roots mapped previously. Refine
the existing callback-mode requirement's conditions/expectations and add an
out-of-range-argument fixture rather than duplicating its contract. Keep the
other 174 earlier entries unchanged. Cross-root links assign print/sprint
requirements to chapter 5, inheritance to annex B and phase-retry behavior
to chapter 13, without changing the tests' primary focus.

Separate configuration witnesses from behavior: report-statistic merging,
quit termination, ready-to-end cap enforcement, clear without dropped
callbacks, null active-object pushes, object-side active-policy synchronization,
comparer message caps, reference-mode copy errors, array/name output controls
and oversize integral rejection form 12 newly unlinked obligations. Getter
values, one retry, successful boundary tests and policy-side stacks are not
promoted to those claims. Retain a default-ready-accessor spelling conflict
as an explicit interpretation for review. Cross-check quit-action wording
against the declared UVM_COUNT and root termination clauses rather than
introducing an undeclared action. Repeated identical expected lines
are anchored once while the runner continues to check the full sequence.

Add ledger_inputs_sha256 to generated inventory/backlog JSON. Hash normalized
scope/ledger/index objects plus catalog identity, including existing test
fingerprints. Full and filtered views share the input identity; formatting,
Japanese escaping and repository location do not change it. Semantic edits,
review/link changes and accepted snapshot changes do. The identity approves
neither coverage nor execution success and is distinct from runtime evidence.

Validation passes 74 tool unit tests, including five new identity regressions,
805 metadata checks, 355 ledger entries and pinned-library integrity. Reconcile
root/global queues, generated identities, bilingual structure, local links,
history, privacy and whitespace. The 805 simulation inputs, expectations,
runners and lock are unchanged; recorded Verilator, kirimasim and guest
input/runner fingerprints still match. No simulator rerun or commercial result
is used. Update README, the paired guides, FAQ and glossary to this state.

## Thin-area expansion across M1–M4

Add 20 fixtures where draft requirements lacked direct tests or execution
conditions were thin. M1 adds ten cases for database connection hooks, distinct
pool-key counts, agent activity, string splitting and command-line suffix
queries, opening chapter/annex directories 7, 11, 13, F and G. M2 adds four
cases that stop established pending lock/grab waiters, check another waiter's
survival and complete fresh transfers. M3 adds six cases for the combined
register/memory access wrapper, register-access block exclusion and registered
custom-policy skips. Stage allocations become M1 239, M2 364 and M3 222;
there are 825 simulations in 20 directories.

Recheck the affected standard clauses before mapping expectations. Database
fixtures control connection hooks without streams or a real backend. Empty
string fields retain delimiter boundaries, and argument tests compare suffix
membership without imposing order. Queued ownership tests use positive delays,
public state and actual driver traffic, without private queue inspection.
Combined access fixtures share frontdoor/user-backdoor storage, including a
child hierarchy, and use location masks rather than exact randomized data.
Skip tests restart observation windows and retain independent working controls.

Map all 20 new cases and 24 selected existing FIFO fixtures, 23 of which
previously had no requirement link. Add 21 requirement drafts and supply direct
tests for nine formerly unlinked drafts. The ledger becomes 376 AI drafts:
361 directly linked requirements, 417 directly linked tests, 15 requirements
without direct tests, one separate control and 407 tests with neither link role.
The catalog has 274 partially decomposed and 2,230 unassessed identifiers;
363 have primary-focus tests and 840 have any citation. Candidate primary-focus
counts are 2,116 zero, 159 one and 204 at least two. Preserve all 805 existing
index snapshots and add only the 20 new input identities after reassessment.
Scope, inventory and M1–M4 remain incomplete; no denominator is approved.

Measure new final inputs with unchanged runners and fixed simulator snapshots.
Sixteen new cases match Verilator 5.052 at seeds 1 and 73. Two command-line
cases differ under the pinned library's empty no-DPI argument enumeration.
The combined wrapper's block exclusion still permits memory accesses, and
single bit bash accesses a registered custom-policy register; both keep the
standard skip expectation. Combined with the unchanged 805-case baseline at
[a7522cc](https://github.com/kurochan001/kirimasim-uvm-tests/commit/a7522cc1345dc80babca37d55c0b255f2df01350),
there are 753 matches and 72 known differences: 65 runtime seed-1 differences
and seven missing-API builds without runtime seeds. Do not weaken expectations
to match these differences.

New Ghost bundled runs have five matches and fifteen failures at each seed;
the failing sets agree. Combined results are 158 matches and 667 failures.
The new matches are one pool-count case, two agent cases and both argument
queries; no new annex E transfer claim is established. kirimasim adds twenty
unsupported results, for 818 unsupported and seven missing-API failures overall.
Input, runner, configuration, executable/profile identities are checked before
combining batches. Guest identity and raw diagnostics remain private; commercial
simulator results are not used.

Update all current paired guides, add four FAQs and four glossary terms
(84 FAQs and 96 terms), and preserve previous history. Validate 74 tool tests,
825 metadata records, 376 ledger entries, pinned-library integrity, bilingual
structure, local links, canonical license, evidence fingerprints and whitespace.

## Second thin-area expansion across M1–M4

Add twenty simulations: ten M1 cases for cumulative report-server statistics,
objection clear without dropped callbacks, null active-object pushes,
reference-mode copy errors and oversize integral-pack errors; four M2 cases
for unavailable FIFO get/peek output preservation with two-state values and
object handles; and six M3 cases for sub-byte/byte-aligned partial memory
transfers and failure/retry status. Stage totals become M1 249, M2 368 and
M3 228, with 845 simulations in the same twenty directories.

Each negative contract has independent working controls. Server setup uses
public message execution and explicit severity setters, without global server
replacement. Clear checks both method and registered callback probes, with
positive delays and normal partial drops. Null pushes observe stack depth,
top and real pops. Invalid copy operands/results and invalid packed state
remain uninspected; fresh objects or policies prove valid deep-copy/64-bit
boundary operation. Diagnostic IDs/text and undefined recovery are unconstrained.

FIFO cases retain the standard's unchanged-output postcondition, while flagging
the declared output formal and SystemVerilog 13.5 copy-out semantics as a
signature/prose interpretation issue. Successful get/peek controls still
check delivery and occupancy. For 20-bit memory on an 8-bit bus, separate
address, direction and data observations from the logical-bit width expectation
8, 8 and 4; the pinned run reports 8, 8 and 8. Keep the sub-byte interpretation
open for review, without assigning a confirmed library bug. The 24-bit/16-bit
bus controls expect and reproduce byte-aligned widths 16 and 8. They prepare
storage through public address lists rather than independently certifying
translation. Upper padding, failed-read data and general burst-array packing
remain unconstrained or unassessed.

Map all twenty new cases and thirty-four previously unlinked register/memory,
virtual-register/field and custom-frontdoor fixtures. Add thirty requirements
and provide direct tests for five previously unlinked drafts. The ledger has
406 AI drafts, 396 directly linked requirements, 471 directly linked tests,
ten requirements without direct tests, one separate control and 373 tests
with neither link role. There are 292 partial and 2,212 unassessed identifiers;
363 have primary-focus tests and 843 have any citation. Candidate primary-focus
counts are 2,116 zero, 156 one and 207 at least two. No stage, normative inventory,
review target, scope or denominator is declared complete/approved.

Correct three existing read fixtures whose primary citation and description
named the write clause. Their bodies and expected outputs stay unchanged;
reassess the index and rerun all three at both seeds. Preserve all other 822
baseline input snapshots. Compatible evidence combines those unchanged records
from [2100ad5](https://github.com/kurochan001/kirimasim-uvm-tests/commit/2100ad5315fe595c262be4f8040912cef82ebd55)
with measurements of twenty new and three citation-corrected final inputs,
using unchanged runners and fixed executable/profile snapshots.

Twelve new cases match Verilator 5.052 at seeds 1 and 73. Eight remain known:
two required oversize-pack errors are missing, four FIFO output cases retain
the signature/prose tension, and two sub-byte width cases retain the logical-bit
interpretation. The 24-bit controls match. Including the baseline, there are
765 matches and eighty known differences: 73 runtime differences at seed 1
and seven missing-API builds with no runtime seed. Standard-derived and explicitly stated
interpretation oracles are not replaced with backend output.

New Ghost bundled runs match the four FIFO sentinel cases and fail sixteen
other cases at each seed; the failing sets agree. The three citation-corrected
cases retain their previous two matches/one failure. Combined results are
162 matches and 683 failures; these do not identify simulator/library causes,
confirm the pinned library or establish new annex E transfers. kirimasim adds
twenty unsupported records, for 838 unsupported and seven missing-API failures.
Guest identity and raw diagnostics remain private; commercial results are unused.

Update current paired guides and retain all earlier historical records. Add
three FAQs and three glossary terms, reaching 87 questions and 99 terms.
Validate 74 tool tests, 845 metadata records, 406 ledger entries, library integrity,
609 local links, language-pair structure, canonical license, whitespace and all
current input/runner/configuration fingerprints before combining evidence.

## Third thin-area expansion across M1–M4

Add twenty cases: twelve M1 cases for printer field/array emission, comparison
message caps, no-override factory queries, finite quit limits and actual
ready-iteration caps; four M2 cases for targeted/empty/duplicate-ID response
retrieval and live sequence-route isolation; four M3 cases for interleaved
wide-register prediction and write/read byte enables. Stage totals become
M1 261, M2 372 and M3 232, with 865 simulations in twenty directories.

Printer membership checks use built-in table/line emitters, real field-macro
arrays, unique values and reuse controls. Finite-window middle omission remains
optional. Comparison probes count individual reports inside the hook, without
short-circuiting fields or counting later rollups; all mismatch results remain
visible and a cap-five control proves the report path. Factory lookup is
compared with real ordinary creation for object/component wrappers. The
no-override name query and zero comparer cap retain normative expectations.

Quit-limit cases use UVM_COUNT, actual pre_abort traversal and a delayed guard
against later-time continuation. They do not impose same-evaluation ordering
after a simulator finish request. Interpret the undeclared UVM_QUIT wording
using F.2.2.2/F.7.3.2; the actual component hook is 13.1.4.6, despite F.7.3.2's
printed reference to 13.1.4.1.6. Ready callbacks always pair their raise with a
delayed drop, which would keep re-arming without the configured cap. Limits
two/three bound the real callback count and reach phase_ended; permanent
undropped objections and sibling-phase conditions remain unassessed.

Response fixtures establish waits with positive delays and copy both routing
IDs from real acknowledged requests. Nonmatching arrivals do not complete a
targeted wait; duplicate matching IDs are checked by membership without a tie
order. Empty waits re-arm after consumption. Equal transaction IDs across two
live sequences still route separately. Predictor fixtures interleave two wide
registers on little/big-endian maps, including reversed address arrival, without
private pending-map access. Two byte-aligned fields exercise low/high/disabled
lanes for RW writes and RO reads, with active prediction off. Pending-check
reporting, sub-field masks, RTL timing and all protocol/policy combinations
remain open.

Add 31 draft requirements, map all twenty new cases and the remaining 23
unmapped existing chapter 19 tests, and provide direct links for six previously
unlinked core drafts. The ledger has 437 AI drafts: 433 directly linked
requirements, 514 directly linked tests, four requirements without direct tests,
one separate control and 350 tests with neither link role. Chapter 19's 37
primary-focus tests all have links, while its decomposition is still partial.
Value-array defaults/prefix/zero growth, adapter context and conversion,
prediction/publication and backdoor access/policies have explicit observations.

The catalog has 305 partial and 2,199 unassessed identifiers; 365 have primary
focus and 853 any citation. Candidate primary-focus counts are 2,114 zero,
156 one and 209 at least two. Preserve every existing test/index snapshot,
runner and library lock. Object-side policy synchronization, HDL deposit,
HDL-path accessibility and the full memory-walk algorithm remain without direct
tests. Scope, denominator, normative inventory and milestone targets stay open.

Seventeen new final inputs match Verilator 5.052 at seeds 1 and 73; three
retain known differences: two no-override name lookups and the zero comparer
cap. No expectation is copied from backend output. Combined with the unchanged
845-case baseline at [9112476](https://github.com/kurochan001/kirimasim-uvm-tests/commit/91124768db9f537c763d1ca67afc88feec66f65b),
there are 782 matches and 83 known differences: 76 runtime seed-1 records and
seven missing-API builds without runtime seeds. This is compatible evidence,
not a single rerun of all cases.

New Ghost bundled runs match both no-override queries and the duplicate-ID
response membership case, and fail seventeen others at each seed. Failing sets
agree, giving 165 matches and 700 failures overall. kirimasim adds twenty
unsupported cases, for 858 unsupported and seven missing-API failures.
Executable/profile/configuration and current input/runner identities are checked
before combining. Guest identity and raw diagnostics stay private; commercial
simulator results are not used.

Update paired guides, add four FAQs and four glossary terms (91 questions,
103 terms), and retain all earlier history. Validate 74 tool tests, 865 metadata
records, 437 ledger entries, pinned-library integrity, language-pair structure,
local links, canonical license, whitespace and current evidence fingerprints.

## Fourth thin-area expansion across M1–M4

This increment adds twenty simulations to the 865-case baseline at
[b77962b](https://github.com/kurochan001/kirimasim-uvm-tests/commit/b77962bb48072147a5b196e5afbf3401538cc1d8),
reaching 885 cases: 271 M1, 376 M2 and 238 M3. All prior test inputs remain
unchanged. M1 adds ten pool/queue fixtures for traversal endpoints/cursors,
global sharing, insertion boundaries, empty pops and repeatable waiting.
M2 adds four FIFO concurrency fixtures: flush with a blocked producer,
two consumers, two peeking observers and independent analysis-FIFO wakeups.
M3 adds six memory hook fixtures for data/offset/map changes, abort/retry,
post-read composition and post-write order/status.

Verilator 5.052 with pinned UVM matches sixteen new cases at seeds 1 and 73.
Four retain spec-only expectations: front/back empty-pop warnings, memory
pre-read map redirection and memory post-write callback order. The compatible
full snapshot has 798 matches and 87 known differences (80 runtime records
first differ at seed 1; seven missing-API builds have no runtime seed results).
Ghost bundled matches five additions and differs on fifteen at each seed;
the full set is 170 matches and 715 differences, with identical failing sets.
kirimasim marks all twenty additions unsupported, reaching 878 unsupported
and seven missing-API failures. Executable/profile snapshots and runner/library
fingerprints remain compatible; no new pinned-mode Ghost result is claimed.

M4 adds 53 AI drafts and maps all twenty additions plus 21 existing
memory/register-map query fixtures. The ledger has 490 drafts, 486 with direct
links to 555 tests, one additional control and 329 unmapped tests. Of 2,504
identifiers, 354 have partial decomposition and 2,150 remain unassessed.
There are 381 primary-focus identifiers and 874 with any citation. The 2,479
candidate identifiers have a primary-focus census of 2,098 zero, 170 one and
211 at least two. Four drafts still lack direct tests. Scope remains proposed;
no human review, denominator approval or conformance percentage is implied.

The update preserves all baseline input fingerprints, all runner/tool/library
inputs and earlier history. Validation includes 74 tool unit tests, 885 metadata
records, ledger/index integrity, current-input evidence binding and complete
English/Japanese guides. The glossary has 107 entries and the FAQ 94 answers.
README describes the current state; this section retains increment details.

## Fifth thin-area expansion across M1–M4

Twenty simulations extend the 885-case baseline at
[631c6a4](https://github.com/kurochan001/kirimasim-uvm-tests/commit/631c6a43977444e741ddb38ed17e8cbd515c3bc4)
to 905 cases: 279 M1, 380 M2 and 246 M3. All baseline test inputs remain
unchanged. M1 adds eight event/barrier cases for persistent on/off state,
fresh versus same-slice trigger data, default data, threshold rounds,
auto-reset, lowered thresholds and reset reuse. M2 adds four delayed TLM 2
socket histories: four phases, returned phase updates, backward completion
with reuse and reversed responses for two outstanding contexts. M3 adds eight
prediction histories across nine additional field policies, including
complementary zero-selected write/read effects and adjacent-field controls.

All twenty additions match Verilator 5.052 with pinned UVM at seeds 1 and 73.
The compatible full snapshot has 818 matches and the unchanged 87 known
differences: 80 runtime records first differ at seed 1 and seven missing-API
builds have no runtime seed results. Ghost bundled matches twelve additions
and differs on eight at each seed; the full set is 182 matches and 723
failures with identical failing sets. kirimasim reports all twenty additions
unsupported, reaching 898 unsupported and seven missing-API failures.
Executable/profile snapshots, library and runner identities remain compatible;
no pinned-mode Ghost result is added.

M4 adds 53 AI drafts and maps all twenty additions plus twenty existing
chapter 14 fixtures. The ledger contains 543 drafts, 539 with direct links
to 595 tests, one additional control and 309 unmapped tests. There are 386
partially decomposed and 2,118 unassessed clause identifiers, 389 primary-focus
identifiers and 892 with any citation. For 2,479 candidates, the primary-focus
census is 2,090 zero, 176 one and 213 at least two. Four drafts retain no
direct test. Scope remains proposed, reviews remain AI-only and no denominator
or percentage is approved.

Validation covers 74 tool unit tests, 905 metadata records, canonical
ledger/index integrity, final-input execution fingerprints and complete
English/Japanese guides. The glossary reaches 111 entries and the FAQ 97
answers, including a paired four-phase diagram. Control getters are separated
from their untested side effects, and explicit prediction from physical
traffic. README retains the current state; this section records the increment.

## Sixth thin-area expansion across M1–M4

Twenty simulations extend the 905-case baseline at
[8437db3](https://github.com/kurochan001/kirimasim-uvm-tests/commit/8437db393929aaa45d80a74f5021f68e1e8a1d0b)
to 925 cases in 21 directories: 287 M1, 384 M2 and 254 M3. All baseline test
inputs remain unchanged. M1 adds eight component-hierarchy cases for parent,
name/depth, child queues, direct membership, cursor boundaries and lookup.
M2 adds four indexed TLM 1 transfer cases, including a parent-port fanout.
M3 adds eight symbolic HDL-description cases: two standard concat APIs and
six kind/default/block-path cases. Chapter 17 now has its first two primary
fixtures; neither attempts HDL or DPI access.

Verilator 5.052 with pinned UVM matches seventeen additions at seeds 1 and 73.
Two concat API fixtures cannot build and one block-default inheritance case
retains a runtime difference at seed 1. The compatible full snapshot has
835 matches and 90 known differences: 81 runtime first differences at seed 1
and nine missing-API builds without runtime seed results. Ghost bundled
matches six additions and differs on fourteen at each seed; the full set is
188 matches and 737 failures with identical failing sets. kirimasim reports
18 additions unsupported and two missing-API failures, reaching 916 unsupported
and nine failures. Runner, executable/profile and library identities remain
compatible. No pinned-mode Ghost measurement is added.

M4 adds 61 AI drafts and maps all twenty additions plus 21 existing payload/
extension fixtures. The ledger contains 604 drafts, 600 with direct links to
636 tests, one additional control and 288 unmapped tests. Of 2,504 identifiers,
438 have partial decomposition and 2,066 remain unassessed; 402 have primary
focus and 931 any citation. The 2,479-candidate primary census is 2,077 zero,
186 one and 216 at least two. Four drafts still lack direct tests. Scope is
proposed, human review is absent and no denominator or percentage is approved.

Validation includes 74 tool unit tests, 925 metadata records, ledger/index
integrity, final-input evidence binding and complete English/Japanese guides.
The glossary has 115 entries and the FAQ 100 answers, including a parent-port
fanout diagram. Symbolic HDL paths remain distinct from backend accessibility;
payload/control state remains distinct from target execution. README records
the current state and this section preserves increment details.

## Seventh thin-area expansion across M1–M4

Twenty simulations extend the 925-case baseline at
[b392959](https://github.com/kurochan001/kirimasim-uvm-tests/commit/b392959c512df803680f5b2030d6d78ca0f97956)
to 945 cases in 21 directories: 295 M1, 388 M2 and 262 M3. All 925 baseline
inputs remain unchanged. M1 adds eight typed event callback, wakeup reset,
killed-waiter cancellation and dedicated event/barrier pool cases. M2 adds
four blocking TLM 2 cases for overlapping calls, independent socket channels,
error/reuse and a custom transaction through nested exports. M3 adds eight
register-model introspection cases for parent handles, local/recursive
membership and simple-name searches, including nested regfile placement.

Seventeen additions match Verilator 5.052 at seeds 1 and 73. Three retain
runtime differences at seed 1: disabled callback dispatch, wakeup reset and
block register-name lookup. Reset's simulator/library cause remains
unassigned. Ordinary post-lock register lookup works as a control; nested
regfile lookup still differs. The compatible full snapshot has 852 matches
and 93 known differences: 84 runtime first differences and nine missing-API
builds without runtime seed results. Ghost bundled matches 5 additions and
differs on 15 at each seed, reaching 193 matches and 752 failures with
identical failing sets. kirimasim reports all twenty additions unsupported,
reaching 936 unsupported and nine missing-API failures. Final measurements
follow corrections to virtual callback argument names; superseded input
records are not used. Runner/executable/profile/library identities remain
compatible, with no new pinned-mode Ghost claim.

M4 adds 47 AI drafts and maps all twenty additions plus twenty existing
sequencer controls, histories and pull/push transfer fixtures. The ledger
contains 651 drafts, 647 directly linked requirements and 676 directly linked
tests, one additional control and 268 unmapped tests. Of 2,504 identifiers,
480 are partially decomposed and 2,024 unassessed; 417 have primary focus and
954 any citation. The 2,479-candidate primary census is 2,062 zero, 201 one
and 216 at least two. Four drafts still lack direct tests. Chapter 15 retains
56 unmapped primary fixtures and 64 unassessed identifiers. All reviews are
AI, scope proposed and denominator/percentage unset.

Validation covers 74 tool unit tests, all 945 metadata records, ledger/index
integrity, final-input evidence fingerprints and complete English/Japanese
guides. The glossary has 119 entries and the FAQ 103 answers. Callback enable
state, reset wakeup, cancellation accounting, endpoint-defined blocking
behavior and model-only queries are distinguished from broader coverage.
README records current state; increment history is retained here.

## Eighth thin-area expansion across M1–M4

Twenty simulations extend the 945-case baseline at
[888203c](https://github.com/kurochan001/kirimasim-uvm-tests/commit/888203cdc404b75cc7a64abdf6cd004558da5894)
to 965 cases in 21 directories: 303 M1, 392 M2 and 270 M3. All 945 baseline
inputs remain unchanged. M1 adds eight recording stream/link cases using
local hooks, covering lifecycle, metadata, enumeration, handles, warnings and
endpoint dispatch. M2 adds four directional request/response blocking cases.
M3 adds eight field access, compare/volatility, reset metadata/state and
maximum-width cases, without physical resets or bus transfers.

Seventeen additions match Verilator 5.052 at seeds 1 and 73. Three retain
runtime differences at seed 1: implicit database opening, stream-count return
and pre-initialization warnings. The stream-count case is a queue-size prose
versus one-bit unsigned signature interpretation requiring review, not a
confirmed library/simulator bug. The compatible full snapshot has 869 matches
and 96 known differences: 87 runtime first differences and nine missing-API
builds without runtime seed results. Ghost bundled has 196 matches and
769 failures at each seed, with identical failing sets. kirimasim has
956 unsupported cases and nine missing-API failures. Measurements bind to
final inputs after the link fixture uses a concrete endpoint subtype; all
runner/executable/profile/library identities remain compatible. No current
pinned-mode Ghost claim is added.

M4 adds 54 AI drafts and maps all twenty additions plus twenty existing TLM 1
analysis, bound-port, split-imp and channel fixtures. The ledger contains
705 drafts, 701 directly linked requirements and 716 directly linked tests,
one additional control and 248 unmapped tests. Of 2,504 identifiers, 524 are
partially decomposed and 1,980 unassessed; 432 have primary focus and 985 any
citation. The 2,479-candidate census is 2,047 zero, 212 one and 220 at least
two. Four drafts still lack direct tests. Scope is proposed, all review is
AI and denominator/percentage remain unset.

Validation covers 74 tool unit tests, all 965 metadata records, ledger/index
integrity, final-input evidence fingerprints and complete English/Japanese
guides. The glossary has 123 entries and the FAQ 106 answers, including a
stream lifecycle diagram. Recorders, external database contents, physical
field effects and concurrent response matching remain outside these fixtures.
README contains current state; increment details remain here.

## Ninth thin-area expansion across M1–M4

Twenty simulations extend the 965-case baseline at
[8482f3f](https://github.com/kurochan001/kirimasim-uvm-tests/commit/8482f3f137671d1abbafdceda07f41151c671e8d)
to 985 cases in 21 directories: 311 M1, 396 M2 and 278 M3. All 965 baseline
inputs remain unchanged. M1 adds eight recorder admission, metadata,
close/free/handle, stream cascade and scalar-hook cases. M2 adds four socket
constructor and forbidden-target-connect cases. M3 adds eight equal-width
indirect-register cases for selected transfers, reselection, latest index,
independent pairs, error/retry and optional regfile placement. Recording is
local and modeled bus storage is separate from prediction; no RTL/DPI is used.

All twenty additions match Verilator 5.052 at seeds 1 and 73, adding no new
spec-only case. The compatible full snapshot has 889 matches and 96 known
differences: 87 runtime first differences at seed 1 and nine missing-API
builds without runtime seed results. Ghost bundled differs on all twenty
additions at both seeds, reaching 196 matches and 789 failures with identical
failing sets. kirimasim reports all twenty additions unsupported, reaching
976 unsupported and nine missing-API failures. The regfile placement fixture
supplies its required null regfile-parent argument before final measurement.
All runner/executable/profile/library identities remain compatible, and no
current pinned-mode Ghost measurement is added.

M4 adds 55 AI drafts and maps all twenty additions plus twenty existing
sequencer arbitration, ownership and availability fixtures. The ledger has
760 drafts, 756 directly linked requirements and 756 directly linked tests,
one additional control and 228 unmapped tests. Of 2,504 identifiers, 565 have
partial decomposition and 1,939 remain unassessed; 443 have primary focus and
1,020 any citation. The 2,479-candidate census is 2,036 zero, 220 one and 223
at least two. Four drafts still lack direct tests. Scope remains proposed,
all review is AI and denominator/percentage remain unset.

Validation covers 74 tool unit tests, all 985 metadata records, ledger/index
integrity, final-input evidence fingerprints and complete English/Japanese
guides. The glossary has 127 entries and the FAQ 109 answers, including an
indirect-access diagram. Earlier stream-only descriptions now distinguish
separate recorder coverage. Random selection is not statistical coverage;
constructor bounds are not resolved traffic. README keeps current state,
while increment details remain here.

## Tenth thin-area expansion across M1–M4

Twenty simulations extend the 985-case baseline at
[dcc6330](https://github.com/kurochan001/kirimasim-uvm-tests/commit/dcc6330034e652830fd05c4e50153d6c7017aac5)
to 1005 cases in 21 directories: 319 M1, 400 M2 and 286 M3. All 985 baseline
inputs remain unchanged. M1 adds eight local phase-graph metadata, identity,
lookup and ordering cases. M2 adds four custom-transaction socket cases:
blocking parent/explicit implementation delivery and nonblocking single
initiator/target pass-through forward/backward routing. M3 adds eight
coverage-control, sampling-order and recursive-value-hook cases. There are
no covergroups or functional coverage percentages, RTL accesses or DPI.

Sixteen additions match Verilator 5.052 at seeds 1 and 73. Four retain
normative spec-only differences: current-node find returns an implementation
instead of the node, and two coverage-control fixtures return new rather
than previous enabled masks. Memory sampling additionally visits an extra
location for each one-location access. The mask fixtures retain matching
availability, recursive control and peer observations. Four initial socket
fixtures are corrected to annotate canonical time using get_abstime/set_abstime;
final evidence uses those corrected calls. The compatible snapshot has
905 matches and 100 known differences: 91 runtime first differences at seed 1
and nine missing-API builds without runtime seed results. Ghost bundled
has 198 matches and 807 failures at each seed, with identical failing
sets. kirimasim has 996 unsupported cases and nine missing-API failures.
All runner/executable/profile/library identities remain compatible; no
current pinned-mode Ghost claim is added.

M4 adds 51 AI drafts and maps all twenty additions plus twenty existing
register/field set, reset, prediction and update fixtures. The ledger has
811 drafts, 807 directly linked requirements, 796 directly linked tests,
one additional control and 208 unmapped tests. Of 2,504 identifiers, 592 have
partial decomposition and 1,912 remain unassessed; 458 have primary focus and
1,046 any citation. The 2,479-candidate census is 2,021 zero, 232 one and 226
at least two. Four drafts still lack direct tests. Scope remains proposed,
all review is AI and denominator/percentage remain unset.

Validation covers 74 tool unit tests, all 1005 metadata records, ledger/index
integrity, final-input evidence fingerprints and complete English/Japanese
guides. The glossary has 131 entries and the FAQ 112 answers, including a
phase-graph diagram. Model state, bus masks and hook counters remain distinct
from physical DUT behavior. README keeps current state; increment details
remain here.

## Eleventh thin-area expansion across M1–M4

Twenty simulations extend the 1005-case baseline at
[34b4ba0](https://github.com/kurochan001/kirimasim-uvm-tests/commit/34b4ba002f28005aa38a8d56e686aa24febf4d75)
to 1025 cases in 21 directories: 327 M1, 404 M2 and 294 M3. All 1005 baseline
inputs remain unchanged. M1 adds eight component recording controls,
database/stream cache, null guards, timestamp/hooks and property-recording
lifecycle cases. M2 adds four sequence reporting-context, verbosity,
message-construction and handler-routing cases. M3 adds eight map check-on-read
cases for defaults, toggles, submaps, independent interfaces, field masks and
RC ordering. Local storage/hooks establish no external recording format,
component-event wakeup, passive predictor integration, RTL access or DPI.

Nineteen additions match Verilator 5.052 at seeds 1 and 73. One preserves
13.1.7.10's fresh-stream requirement: free_tr_stream uses the wrong type key
and the pinned release retains the old cache entry. The enabled-recording
fixture obtains its actual stream through the recorder handle supplied to
the component hook, avoiding an assumption about the internally chosen type.
The compatible snapshot, dated 2026-11-02, has 924 matches and 101 known
differences: 92 runtime first differences at seed 1 and nine missing-API
builds without runtime seed results. Ghost bundled has 199 matches and
826 failures at each seed, with identical failing sets. kirimasim has
1016 unsupported cases and nine missing-API failures. Runner, executable,
profile and library identities remain compatible; no current pinned-mode
Ghost claim is added.

M4 adds 54 AI drafts and maps all twenty additions plus twenty existing
sequence start/finish/grant/submission fixtures. The ledger has 865 drafts,
861 directly linked requirements, 836 directly linked tests, one additional
control and 188 unmapped tests. Of 2,504 identifiers, 612 have partial
decomposition and 1,892 remain unassessed; 470 have primary focus and 1,068
any citation. The 2,479-candidate census is 2,009 zero, 242 one and 228 at
least two. Four drafts still lack direct tests. Scope remains proposed,
all review is AI and denominator/percentage remain unset. Existing invalid-input
severity, finish virtual-dispatch and completion-ID differences are retained.

Validation covers 74 tool unit tests, all 1025 metadata records, ledger/index
integrity, final-input evidence fingerprints and complete English/Japanese
guides. The glossary has 135 entries and the FAQ 115 answers, including a
read-check/prediction diagram. Report construction probes remain distinct
from real handler execution. Discrepancy reports, returned data, predicted
mirror state and bus completion are separate observations. README contains
current state and this history retains the increment details.

## Twelfth thin-area expansion across M1–M4

Twenty simulations extend the 1025-case baseline at
[c731bc9](https://github.com/kurochan001/kirimasim-uvm-tests/commit/c731bc919f105ed8aa6c71ff19257a98b1aaf2c9)
to 1045 cases in 21 directories: 335 M1, 408 M2 and 302 M3. All 1025 baseline
inputs remain unchanged. M1 adds eight core-service policy/default-fallback,
service replacement/restoration and seed-immutability cases. M2 adds four
sequence-library wrapper-index, range, instance and removal cases. M3 adds
eight register transaction-order policy queries and bus integrations across
endiannesses, directions, interface isolation, replacement and clearing.

Seventeen additions match Verilator 5.052 at seeds 1 and 73. Three preserve
normative spec-only differences. The little-endian read follows the requested
bus order but reconstructs data in execution order. Big-endian write/read
also expose the existing full-width byte-swap limitation, with the read
combining both causes. Policy dispatch and requested geometry/order remain
separate from failed data preservation. The compatible snapshot has 941
matches and 104 known differences: 95 runtime first differences at seed 1
and nine missing-API builds without runtime seed results. Ghost bundled
has 203 matches and 842 failures at each seed, with identical failing sets.
kirimasim has 1036 unsupported cases and nine missing-API failures. Runner,
executable, profile and library identities remain compatible; no current
pinned-mode Ghost claim is added.

M4 adds 50 AI drafts and maps all twenty additions plus twenty existing
sequence-library registration, selection, bounds, counter and default-RAND
execution fixtures. The ledger has 915 drafts, 911 directly linked
requirements, 876 directly linked tests, one additional control and 168
unmapped tests. Of 2,504 identifiers, 645 have partial decomposition and
1,859 remain unassessed; 482 have primary focus and 1,084 any citation.
The 2,479-candidate census is 1,997 zero, 251 one and 231 at least two.
Four drafts still lack direct tests. Scope remains proposed, all review is
AI and denominator/percentage remain unset. Standard API omissions and
existing static-removal/warning differences remain explicit limitations.

Validation covers 74 tool unit tests, all 1045 metadata records, ledger/index
integrity, final-input evidence fingerprints and complete English/Japanese
guides. The glossary has 139 entries and the FAQ 118 answers, including an
order-policy diagram. Default handle selection, type lookup, physical
ordering and logical reconstruction are separate observations. No external
database, custom core initialization, memory burst, partial bus word or
arbitrary concurrent access is claimed. README retains current state and
this history preserves the increment.

## Thirteenth thin-area expansion across M1–M4

Twenty simulations extend the 1045-case baseline at
[fdfbd57](https://github.com/kurochan001/kirimasim-uvm-tests/commit/fdfbd57d235a9fc19ede9163f23f8e9b255f5e0a)
to 1065 cases in 21 directories: 343 M1, 412 M2 and 310 M3. All 1045 baseline
inputs remain unchanged. M1 adds eight visitor/proxy/traversal and core
visitor-selection cases. M2 adds four blocking transport channel cases.
M3 adds eight register-sequence convenience API cases, separating data
behavior from the implicit parent and explicit transaction metadata.

The compatible snapshot has 961 Verilator 5.052 matches at seeds 1/73
and 104 known differences: 95 runtime first differences at seed 1 and nine
missing-API builds without runtime seed results. Ghost bundled has 207
matches and 858 failures at each seed, with identical failing sets.
kirimasim has 1056 unsupported cases and nine missing-API failures.
Runner, executable, private profile and pinned library identities remain
compatible. No current pinned-mode Ghost result is inferred.

M4 adds 46 AI drafts and maps all twenty additions plus twenty existing
default-sequence resource selection and retired-response routing fixtures.
The ledger has 961 drafts, 957 directly linked requirements, 916 directly
linked tests, one additional control and 148 unmapped tests. Of 2,504
identifiers, 663 have partial decomposition and 1,841 remain unassessed;
496 have primary focus and 1,109 any citation. The 2,479-candidate census
is 1,983 zero, 263 one and 233 at least two. Four drafts still lack direct
tests. Scope is proposed, all review is AI and denominator/percentage are
unset. Existing invalid-wrapper severity differences remain spec-only.

Validation covers 74 tool unit tests, all 1065 metadata records, ledger/index
integrity, final-input evidence fingerprints and full English/Japanese
guides. The glossary has 143 entries and the FAQ 121 answers. Traversal
asserts required partial orders without sibling order. Blocking transport
uses one caller per channel, with sequential reuse, prequeued reply and
independent-channel controls. Register wrappers run as virtual sequences;
backdoors use modeled storage without HDL/DPI. No cyclic graph, same-channel
concurrent calls, arbitrary BASE specialization or translation body is
claimed. README retains current state; this history preserves the increment.

## Fourteenth thin-area expansion across M1–M4

Twenty simulations extend the 1065-case baseline at
[101405a](https://github.com/kurochan001/kirimasim-uvm-tests/commit/101405abac10d45544cb9c372548cacf22c1524e)
to 1085 in 21 directories: 351 M1, 416 M2 and 318 M3. All 1065 baseline
inputs remain unchanged. M1 adds four simplified-matching and four enum-name
conversion cases. M2 adds matching-ID waits and response queue clearing,
peer isolation and capacity/control retention. M3 adds eight descriptor
metadata, bulk array and invalid-index cases without physical DUT access.

Eighteen additions match Verilator 5.052 at seeds 1/73; simplified plus
and descriptor index handling retain two normative differences. The
compatible snapshot has 979 matches and 106 known differences: 97 first runtime differences at seed 1
and nine missing-API builds. Ghost bundled has 207 matches and 878 failures
at each seed, with identical failing sets. kirimasim has 1076 unsupported
and nine missing-API failures. Two fixture issues were corrected before
final evidence: enum name lookup uses a typed value, and extension tokens
use a concrete subclass. Final records match all current input hashes;
runner, executable, private profile and library identities are compatible.
No current pinned-mode Ghost or DPI-enabled matching result is inferred.

M4 adds 60 AI drafts and maps twenty new plus twenty existing stop/response
fixtures. The ledger has 1021 drafts, 1017 directly linked requirements,
956 directly linked tests, one additional control and 128 unmapped tests.
Of 2,504 identifiers, 684 are partially decomposed and 1,820 unassessed;
504 have primary focus and 1,114 any citation. The 2,479-candidate census
is 1,975 zero, 267 one and 237 at least two. Eighteen roots have no unmapped
primary fixtures, including chapter 15. Four drafts lack direct tests;
scope is proposed, all review is AI and denominator/percentage remain unset.
Existing singleton USER, automatic-objection and response-default differences
retain normative expectations. Shared anchors do not imply independent coverage.

Validation covers 74 tool unit tests, 1085 metadata records, ledger/index,
final-input evidence, 9 complete English/Japanese pairs and local links.
The glossary has 147 entries and FAQ 124 answers. README retains current
state; this history preserves the increment. Failed enum output, undefined
initial descriptor fields, POSIX/DPI behavior, duplicate-ID order and
concurrent clear/delivery races remain outside these fixtures.

## Fifteenth thin-area expansion across M1–M4

Twenty simulations extend the 1085-case baseline at
[e58bd5a](https://github.com/kurochan001/kirimasim-uvm-tests/commit/e58bd5afbe1d9cda33c7a9db3e065a8710eeca92)
to 1105 in 21 directories: 359 M1, 420 M2 and 326 M3. All baseline inputs
remain unchanged. M1 adds eight root component-search cases, M2 four
state-mask/wait cases, and M3 eight memory sequence poke/peek integrations.
All twenty additions reproduce with Verilator 5.052 at seeds 1/73. The
compatible snapshot has 999 pass and 106 known: 97 runtime first differences
at seed 1 and nine missing-API builds. No additional known case is added.

Temporary kirimasim/Ghost executable/profile snapshots and compatible local
replacements were unavailable. Prior records for 1085 unchanged current
inputs are retained: kirimasim has 1076 unsupported and nine fail; Ghost
bundled has 207 pass/878 fail at each seed, with identical failing sets.
The twenty new guest cases are explicitly unmeasured. No fresh full-suite
guest run, pinned-mode Ghost result or substitute configuration is claimed.
The evidence-scope JSON records missing IDs separately from measured results.

M4 adds 42 AI drafts and maps twenty new plus twenty existing chapter-14
fixtures. The ledger has 1063 drafts, 1059 directly linked requirements,
996 directly linked tests, one additional control and 108 unmapped tests.
Of 2,504 identifiers, 692 are partially decomposed and 1,812 unassessed;
507 have primary focus and 1,116 any citation. The 2,479-candidate census
is 1,972 zero, 266 one and 241 at least two. Nineteen roots have no unmapped
primary fixtures, including chapters 14/15. Remaining unmapped tests are
62 in chapter 18 and 46 in chapter 12. Four drafts lack direct tests;
all review is AI, scope is proposed and denominator/percentage remain null.

Validation covers 74 tool unit tests, all 1105 metadata records, ledger/index,
library integrity, final-input evidence and ten complete language pairs.
The glossary has 151 definitions and FAQ 127 answers. The handoff is refreshed
with the current backlog and partial guest scope. Chapter-18 prose totals
are corrected to the canonical 182 drafts. Fixture syntax and direct field
waits were corrected before final measurements, without changing expectations.
No sibling ordering, ambiguous multiple-match winner, failed-read data,
default backdoor-kind resolution or physical DUT access is inferred.

## Existing-test requirement-link backlog cleared

On 2026-11-03, all 108 remaining unlinked fixtures received explicit
requirement/expected-observation mappings: 46 in chapter 12 and 62 in
chapter 18. The original simulation inputs remain unchanged. TLM mappings
cover split implementations, nonblocking replies, exports/socket relays,
payload packing and canonical time. Register mappings cover metadata,
methods/callbacks, virtual-array allocation/lifecycle and memory regions.

One original policy/object synchronization fixture checks two nested policy
pushes and pops through the standard object-side getter. It directly links
the previously untested push-synchronization draft and a new pop-restoration
draft. The pinned library lacks the getter; the new case remains spec-only
with a known build failure. No legacy getter or policy-only substitute is used.

The suite has 1106 cases: M1 360, M2 420 and M3 326. Verilator 5.052 retains
999 matches at seeds 1/73 and has 107 known cases: 97 runtime first differences
at seed 1 and ten missing-API builds. All 1105 prior records match unchanged
current inputs. Guest execution snapshots remain unavailable; the previous
1085-case records are retained, with 21 current cases explicitly unmeasured.
Ghost bundled remains 207 pass/878 fail per seed; kirimasim remains 1076
unsupported/nine fail on that subset. No new guest result is claimed.

The ledger adds 100 AI drafts, reaching 1163: 1160 have direct links to 1105
tests and one additional test is a control. Unlinked tests decrease from
108 to zero across all 21 primary-focus roots. Three drafts still lack direct
tests: HDL deposit, HDL-path accessibility and the full memory-walk algorithm.
The catalog retains 2,504 identifiers, with 735 partially decomposed and
1,769 unassessed. Primary-focus identifiers remain 507, any-citation identifiers
are 1,119 and the candidate census remains zero 1,972 / one 266 / at least two 241.
Scope remains proposed; every review is AI and the denominator/percentage
remain null. This clears a mapping queue, not M1–M4 completion.

Current bilingual guides and the handoff are refreshed; repeated increment
narratives in the requirement guide give way to current totals and explicit
remaining observations. The FAQ has 128 answers, including the distinction
between zero unlinked tests and complete normative coverage; the glossary
retains 151 terms. Validation covers 74 tool unit tests, all metadata,
ledger/index, library integrity, final-input evidence and all ten language pairs.

## Sixteenth thin-area expansion across M1–M4

On 2026-11-03, nine original standard-derived fixtures add port-base names,
parents, roles/type names, default/explicit bounds, connection membership and
export fanout queries; export default-index selection/reselection; and actual
HDL deposit/read/path checks. A dedicated constructor omits base bounds so
the default probe observes the standard API rather than a wrapper default.
The suite reaches 1115 cases: M1 364, M2 421 and M3 330.

A separate original VPI HDL backend/runner accesses actual public 8/40-bit
variables without commercial results or simulator implementation source.
It supports check/read/deposit on packed variables up to 64 bits under the
standard 1024-bit UVM DPI ABI. Force/release, arrays, other types, four-state
values and fine-grained permissions remain outside scope. Nine regression
tests cover opt-in, ABI guards, backend fingerprints and seed judgments.
Ordinary runner inputs are unchanged, preserving all 1106 prior records.

The ordinary Verilator 5.052 snapshot has 1002 matches at seeds 1/73 and
113 known cases: 99 runtime first differences at seed 1, ten missing-API builds
and four unlinked-DPI builds. Generic type names omit the prescribed prefix,
and the tested export default-index setter does not redirect calls. The
separate VPI condition matches three cases at both seeds; E.7 instead reports
ERROR and attempts reads under the retained warning/no-transfer interpretation.
Its one failure stops at seed 1. The two overlapping conditions are not summed.
The unchanged 1085 guest records remain, with thirty current cases unmeasured.

Twenty AI drafts raise the ledger to 1183: 1182 requirements link directly to
1114 tests and one additional test is a control. Unlinked tests remain zero.
Actual-storage HDL fixtures reduce drafts without direct tests from three to
one: the full memory-walk algorithm. Of 2,504 identifiers, 751 are partially
decomposed and 1,753 unassessed. Primary focus reaches 515 identifiers, any
citation 1,135, and candidate counts are zero 1,964 / one 273 / at least two 242.
Scope remains proposed, all reviews AI and denominator/percentage null.

Current English/Japanese guides, handoff, FAQ and glossary are refreshed,
including separate evidence conditions and remaining limitations. There are
130 FAQ answers and 153 terms. Validation covers 83 tool unit tests, all
1115 metadata records, ledger/index and library integrity, final-input evidence,
all ten language pairs and local references. M1–M4 remain incomplete.

## Seventeenth thin-area expansion across M1–M4

On 2026-11-03, sixteen original fixtures add eight container cases, three
bidirectional export cases, four HDL representation/zero-time wrapper cases
and an instrumented memory-walk observer. The suite reaches 1131 cases:
M1 372, M2 424 and M3 335. All twelve new no-DPI cases match Verilator 5.052
at seeds 1/73. Four new HDL cases match under the unchanged VPI condition.

Container checks use explicit type aliases and receiver mutations to observe
default specializations and storage sharing, plus names, replacement, membership,
ordered insertion/removal, occupancy and valid/invalid retrieval. Numeric failure
values use a two-state bit-vector type; object failure values are null.
Nine bidirectional export constructors are queried concretely, avoiding an
invalid common-base cast across reversed slave interfaces. Delivery checks
separately use nested exports, custom request/response objects, blocking return,
nonblocking status, failure and reuse. Two unchanged mixed master/slave fixtures
receive explicit directional export links.

The final memory-walk gap receives a candidate direct test under the historical
interpretation documented in Q134. It checks address/data and ordering relations
on two maps, with independent observer code. This is not copied implementation
output, an IEEE amendment or approval of missing detail. Frontdoor protection
warnings are outside the algorithm oracle; ERROR and relationships remain checked.

Twenty-nine AI drafts bring the ledger to 1212, all with direct links to 1130
tests; one additional test is a control. Both unmapped-test and missing-direct-test
queues are zero. Of 2,504 identifiers, 768 are partially decomposed and 1,736
unassessed. Primary focus is 524 identifiers, any citation 1,142 and the candidate
census zero 1,955 / one 277 / at least two 247. Every review remains AI, scope
proposed and denominator/percentage null. Zero queues do not complete M1–M4.

Ordinary evidence retains all 1115 prior inputs and adds the sixteen final inputs:
1014 match both seeds and 117 are known (99 runtime first differences at seed 1,
ten missing-API builds, eight unlinked-DPI builds). The separate VPI record retains
four earlier inputs and adds four, reaching seven pass and one E.7 fail. These
conditions overlap and are not summed. Guest records remain on 1085 unchanged
inputs, with 46 current cases explicitly unmeasured.

All paired current guides and handoff are refreshed, with 134 FAQ answers and
155 glossary terms. Validation covers 83 tool unit tests, 1131 metadata records,
ledger/index, library integrity, compatible evidence, ten language pairs and
local links. Existing tests, runners and the VPI backend remain unchanged.

## Eighteenth thin-area expansion across M1–M4

Fourteen simulation fixtures add six component configuration conditions, four
TLM binding/report cases and four memory-policy cases. The suite is 1145:
M1 382, M2 424 and M3 339. Nine additions match Verilator 5.052 at seeds 1/73;
five retain normative runtime differences. Default configuration skips custom
resources; strict builds find them but omit the UVM_SET hook. A zero-valued
relationship resource still enables actionable warnings. Fixture corrections
used the public resource-pool insertion API and concrete component subclasses;
report probes exclude UVM_NO_ACTION. No expectation was copied from output.

The compatible ordinary snapshot retains all 1131 prior inputs and adds these
measurements: 1023 pass, 122 known. The latter are 104 runtime seed-1 differences,
ten missing-API and eight unlinked-DPI builds. The separate eight-case VPI
condition remains unchanged at seven pass/one fail. Guest evidence retains
1085 compatible inputs and sixty new cases remain unmeasured.

Twenty-three AI drafts bring the ledger to 1235, all directly linked to 1144
tests; one additional control leaves zero unlinked tests. A new canonical
assessment file records six individually read identifiers: five structural,
one contextual linked to existing requirements. Validations reject conflicting
requirements, unknown/duplicate references, missing bilingual rationale,
unreviewed application and output overwrite. Five meaningful tool tests were
added. Inventory/backlog schema is 2; canonical schemas remain 1 and the report
digest now binds classifications. There is no automatic heading classifier.

The catalog retains 2,504 identifiers: 776 partially decomposed, six explicitly
assessed and 1,722 unassessed. Primary-focus identifiers are 529, cited identifiers
1,148; the candidate census is 1,950 zero, 276 one and 253 at least two. Chapter
11 has no unassessed identifiers, but its requirements remain partial. Scope,
denominator, human review and complete M1–M4 coverage remain open.

All guides are paired, with 157 glossary terms and 136 FAQs. Validation includes
88 tool tests, all 1145 metadata records, ledger/classification/index checks,
library integrity, bilingual references and evidence fingerprints. Simulation
runners, existing tests, VPI backend and earlier history remain unchanged.

## Nineteenth thin-area expansion across M1–M4

Fourteen fixtures add four registry singleton/initialization conditions, four
sequencer-history cases and six register-block lock/search cases. The suite
reaches 1159: M1 386, M2 428 and M3 345. Registry tests distinguish per-type/name
proxies, constructor-free retrieval and initialization against a newly selected
factory. History tests combine zero/re-enabled capacity with actual handshakes,
exact handles and peer isolation. Block cases distinguish structural locks,
offset rebuilding, waits, root membership and absolute/relative glob searches.
Response fixtures run normal UVM build/connect before traffic. Waiter checks
are limited to registrations before completion because a new post-completion
wait is not explicitly specified by the cited clause.

All fourteen additions match Verilator 5.052 at seeds 1/73. Compatible ordinary evidence retains all 1145 prior inputs and adds
these measurements: 1037 pass, 122 known. The separate eight-case VPI evidence
is unchanged at seven pass/one fail. Guest evidence retains 1085 compatible inputs;
74 new cases remain unmeasured.

Twenty-six AI drafts bring the ledger to 1261, all directly linked to 1158 tests;
one additional control leaves zero unlinked tests. Eight individually read
structural headings bring classifications to fourteen (thirteen structural,
one contextual). No classifier, parent rollup, human approval or approved
denominator is introduced. Of 2,504 identifiers, 798 are partly decomposed,
fourteen classified and 1,692 unassessed, down thirty: twenty-two by new
requirement decomposition and eight by explicit structural assessment.
Primary-focus identifiers are 542 and cited identifiers 1,162. The candidate
census is 1,937 zero, 288 one and 254 at least two.

All guides are paired, with 160 glossary terms and 139 FAQs. Validation covers
88 tool tests, all 1159 metadata records, ledger/classification/index checks,
library integrity, bilingual links and evidence fingerprints. Existing simulation
inputs, runners, HDL backend, requirements and earlier history are preserved.
M1–M4 remain incomplete; zero mapping queues do not establish conformance.

## Twentieth thin-area expansion across M1–M4

Fifteen fixtures add seven abstract-registry conditions, two sequence ID/parent
cases and six block map/door/removal cases. The suite reaches 1174: M1 393,
M2 430 and M3 351. Virtual types exercise singleton/default names, selected
factory initialization, concrete/scoped overrides and unimplemented callbacks.
Two live sequences verify copied response routing and transaction values while
preserving payload/names. Reparenting checks current hierarchy after earlier
observations. Map cases check configuration, defaults, explicit doors, removal
of registers/memories/static overlays and same-named child preservation.

Thirteen additions match Verilator 5.052 at seeds 1/73. Two retain runtime
seed-1 differences: a parentless abstract-component diagnostic dereferences
null, and calculated sequence depth remains cached after parent changes.
The parent-present callback control matches. Compatible ordinary evidence
retains all 1159 earlier inputs and adds the fifteen measurements: 1050 pass,
124 known (106 runtime first differences, ten missing-API builds and eight
unlinked-DPI builds). The separate eight-case VPI condition stays seven pass/
one fail. Guest evidence retains 1085 compatible inputs with 89 unmeasured additions.

Forty AI drafts bring the ledger to 1301, all directly linked to 1173 tests;
one additional control leaves zero tests without links. Eight individually
read structural headings bring classifications to twenty-two (twenty-one
structural, one contextual). Of 2,504 identifiers, 827 have partial requirements,
twenty-two are classified and 1,655 unassessed. The decrease of thirty-seven is
twenty-nine new requirement decompositions plus eight explicit classifications.
Primary focus is 554 identifiers; any citation 1,186; candidate census 1,925 zero,
298 one and 256 at least two. Scope, human review and denominator remain open.

All guides are paired, with 163 glossary terms and 142 FAQs. Validation covers
88 tool tests, all 1174 metadata records, ledger/classification/index checks,
library integrity, bilingual links and evidence fingerprints. Existing simulation
inputs, runners, backend, earlier requirements/classifications and history are
preserved. Zero mapping queues do not complete M1–M4 or establish conformance.

## Twenty-first thin-area expansion across M1–M4

Fourteen fixtures add four recording callback/failure cases, four sequence
hook/phase reuse cases and six model hierarchy/map cases. The suite reaches
1188: M1 397, M2 434 and M3 357. Recording observes failure/retry, null-result
initialization gates, exact metadata and link identity. Sequence cases separate
optional body hooks from parent/start callbacks and change phase/objection
controls only between completed starts. Model cases check virtual-field
membership, simple-name scope and map content removal with exact peer identity.

Twelve additions match Verilator 5.052 at seeds 1/73. Two retain runtime
seed-1 differences: child-block map names not connected as local submaps are
missed, and a simple grandchild block name is missed from the root despite
direct-child controls. Only valid simple-name inputs define that oracle.
Compatible ordinary evidence retains all 1174 previous records and adds the
fourteen measurements: 1062 pass, 126 known (108 runtime first differences,
ten missing-API and eight unlinked-DPI builds). The separate eight-case VPI
condition stays seven pass/one fail. Guest evidence retains 1085 compatible
inputs with 103 additions explicitly unmeasured.

Fifty AI drafts bring the ledger to 1351, all directly linked to 1187 tests;
one additional control leaves zero unlinked tests. Four unchanged hook
fixtures gain seven explicit callback links without new execution evidence.
Fourteen individually read structural headings bring assessments to thirty-six
(thirty-five structural, one contextual). Of 2,504 identifiers, 853 are partly
decomposed, thirty-six assessed and 1,615 unassessed. The decrease of forty is
twenty-six new requirement decompositions and fourteen structural assessments.
Primary focus is 568, any citation 1,197; the candidate census is 1,911 zero,
312 one and 256 at least two. No human review or approved denominator is added.

All guides are paired, with 166 glossary terms and 145 FAQs. Validation covers
88 tool tests, all 1188 metadata records, ledger/assessment/index checks,
library integrity, bilingual references and evidence fingerprints. Existing
simulation inputs, runners, backend, earlier requirements/assessments and
history are preserved. Empty mapping queues do not complete M1–M4.

## Twenty-second thin-area expansion across M1–M4

Thirteen fixtures add four recording constructor/link cases, three sequence
constructor cases and six register-file cases. The suite reaches 1201:
M1 401, M2 437 and M3 363. Naming cases distinguish omitted base arguments,
explicit names and explicit empty names. Prefilled links retain specified
default names and independent handles. Register files add configuration,
local/full symbolic paths, multiple abstractions, clearing, nearest defaults,
Cartesian alternatives and flattened scopes without HDL/DPI transfers.

Eleven additions match Verilator 5.052 at seeds 1/73. Two retain runtime
seed-1 differences in register-file default inheritance and omitted-kind full
paths under a flattened parent. Explicit RTL/GATE and local override controls match.
Presence/local-path APIs are separately interpreted using the nearest enclosing
default, as the standard specifies. Compatible ordinary evidence retains all
1188 prior records and adds thirteen final measurements: 1073 pass, 128 known
(110 runtime first differences, ten missing-API and eight unlinked-DPI builds).
The separate VPI condition remains seven pass/one fail. Guest records cover
1085 unchanged inputs, with 116 current cases explicitly unmeasured.

Forty-four AI drafts bring the ledger to 1395, all directly linked to 1200
tests; one additional control leaves zero unlinked tests. Five unchanged M2
fixtures gain five explicit obligations without new measurements. Ten
individually read structural headings bring assessments to forty-six
(forty-five structural, one contextual). Of 2,504 identifiers, 874 are partly
decomposed and 1,584 unassessed. The decrease of thirty-one is twenty-one
new decompositions and ten structural assessments. Primary focus is 581,
any citation 1,212; the candidate census is 1,898 zero, 325 one and 256 at
least two. Human review and denominator approval remain open.

Paired guides retain the SVG diagrams and add API-specific explanations,
169 glossary terms and 148 FAQs. Validation covers 88 tool tests, all 1201
metadata records, ledger/assessment/index checks, library integrity,
documentation parity and evidence fingerprints. Existing simulation inputs,
runners, backend, previous ledger records and historical sections are preserved.
Empty mapping queues do not complete M1–M4.

## Twenty-third thin-area expansion across M1–M4

Thirteen fixtures add five heartbeat cases, three base-typed payload-accessor
cases and five abstract register-FIFO cases. The suite reaches 1214:
M1 406, M2 440 and M3 368. Heartbeats cover explicit mode selection/query,
missing/replaced/reused events and healthy ALL_ACTIVE participant changes.
Payload overrides observe fourteen selected virtual methods. FIFO cases cover
constructor dimensions, public queue views, non-popping get, debug arguments,
instance isolation and inline/subtype constraint conditions without DUT access.

Ten additions match Verilator 5.052 at seeds 1/73. Three retain seed-1 runtime
differences. A running omitted heartbeat event is dereferenced while forming
an error, after stopped/default and explicit same-event controls match. An
exact-capacity FIFO inline randomize succeeds with an empty queue; its
oversized inline request is correctly rejected. A declared exact-capacity
subtype matches, while a declared oversized subtype reports success. The FIFO
observations do not assign cause to simulator or library. Compatible ordinary
evidence retains 1201 prior records and adds thirteen final measurements:
1083 pass, 131 known (113 runtime first differences, ten missing-API and eight
unlinked-DPI builds). Separate VPI evidence remains seven pass/one fail.
Guest records cover 1085 unchanged inputs, with 129 current cases unmeasured.

Fifty-six AI drafts bring the ledger to 1451, all directly linked to 1213
tests; one additional control leaves zero unlinked tests. Seven unchanged
fixtures add six transaction hook/time obligations and eleven payload setter
obligations without fresh measurements. Seven structural classifications and
one contextual payload-member introduction bring assessments to fifty-four
(fifty-two structural, two contextual). Of 2,504 identifiers, 903 are partly
decomposed and 1,547 unassessed. The decrease of thirty-seven is twenty-nine
new decompositions and eight explicit classifications. Primary focus is 588,
any citation 1,225; the candidate census is 1,891 zero, 329 one and 259 at least
two. Human review and denominator approval remain open.

Paired guides retain all six SVG assets and add scoped explanations, a FIFO
constraint comparison, 172 glossary terms and 151 FAQs. Validation covers
88 tool tests, all 1214 metadata records, ledger/assessment/index checks,
library integrity, bilingual references and evidence fingerprints. Existing
simulation inputs, runners, backend, previous ledger records and historical
sections are preserved. FIFO transfer/compare/setup and broader heartbeat,
payload protocol and requirement-decomposition work remain open.

## Twenty-fourth thin-area expansion across M1–M4

Twelve original fixtures add five catcher helper/issue paths, three default
sequence req/rsp printing conditions and four separate adapter-response paths.
The suite reaches 1226 cases: M1 411, M2 443 and M3 372. Helper reports bypass
both catchers; current-message issue is distinguished from normal emission
through CAUGHT/THROW and changed IDs. Typed print hooks observe current,
replaced and cleared fields without formatted-text expectations. Fresh routed
responses override contradictory request state across write, repeated read,
failed-write retry and failed-memory-read recovery.

All twelve final-input measurements match seeds 1 and 73. Compatible ordinary
evidence retains all 1214 prior records: 1095 pass and 131 known, including
113 runtime first differences, ten missing-API builds and eight unlinked-DPI
builds. The overlapping VPI condition remains seven pass and one fail.
Guest evidence still covers 1085 unchanged inputs; 141 current cases are
unmeasured. No commercial simulator results or simulator implementation
sources are used.

Thirty-four AI drafts bring the ledger to 1485, all directly linked to 1225
tests, with one additional control test and zero tests without links. Four
individually read organizing headings bring classifications to fifty-eight:
fifty-six structural and two contextual. Of 2,504 identifiers, 914 are partially
decomposed and 1,532 unassessed. The decrease of fifteen is eleven newly
partially decomposed identifiers plus four explicit classifications. M4 stays
in progress; scope/denominator approval and human review remain open.

All ten guide pairs are refreshed; three FAQ answers and three glossary entries
bring totals to 154 and 175. Validation covers 88 tool unit tests, all 1226
metadata records, ledger/index/library checks, bilingual links and current-input
evidence fingerprints. Existing fixtures, runners, VPI backend, lock, scope,
licenses and six SVG assets remain unchanged.

## Twenty-fifth thin-area expansion across M1–M4

Twelve original fixtures add six catcher mutation/getter cases, three
sequence-side release cases and three individual/fallback field-access cases.
The suite reaches 1238: M1 417, M2 446 and M3 375. Catcher fields propagate to
later callbacks without leaking into a fresh explicit report. Sequence default
and explicit release targets, peer blocking and cross-release are distinct.

Ten final-input cases match seeds 1 and 73. Two retain seed-1 differences:
with byte-enable support and byte-isolated fields sharing a 16-bit bus word,
the pinned library rejects individual access and uses a full-word mask.
Low write changes the live high byte from 0xab to mirror 0x12; high read
updates the low mirror to 0xcd instead of retaining 0x34. Required byte-only
expectations remain spec-only. The no-byte-enable full-register fallback
matches both seeds, including use of a peer mirror after live storage changes.
Only permitted Apache UVM source was used to diagnose that bus-width grouping;
no simulator implementation source or commercial simulator results were used.

Compatible ordinary evidence retains all 1226 prior inputs and adds twelve
final measurements: 1105 pass, 133 known (115 runtime first differences,
ten missing-API builds and eight unlinked-DPI builds). The separate VPI condition
remains seven pass and one fail. Guest evidence covers 1085 unchanged inputs;
153 current cases are unmeasured.

Forty-four AI drafts bring the ledger to 1529, all directly linked to 1237
tests, plus one control test. Three unchanged kill-hook fixtures gain explicit
do_kill links without new measurements or changes to their post-hook results.
Four individually read methods headings bring assessments to sixty-two:
sixty structural, two contextual. Of 2,504 identifiers, 937 are partly
decomposed and 1,505 unassessed. The decrease of twenty-seven is twenty-three
newly decomposed identifiers plus four classifications. Primary-focus identifiers
are 606, any citation 1,247; the candidate census is 1,873 zero, 343 one and
263 at least two. Scope approval, human review and the denominator remain open.

All ten guide pairs are checked and current totals refreshed. Three FAQ answers
and three glossary entries bring totals to 157 and 178. Validation covers
88 tool unit tests, metadata for all 1238 tests, ledger/index/library checks,
bilingual references and current-input evidence. Existing simulation inputs,
runners, VPI backend, scope, lock, licenses and six SVG assets remain unchanged.

## Twenty-sixth thin-area expansion across M1–M4

Twelve fixtures add four preformed/admission reporting cases, four missing-default
sequence ownership API cases and four field-layout/endian cases. Totals are
1250 simulations: M1 421, M2 450 and M3 379. Eight final inputs match both seeds;
three cannot build because the standard catcher get_report_message is absent;
one first differs at seed 1 in narrow-bus big-endian field addresses/data.
Little-endian, shared-byte and byte-crossing controls match. Fatal probes use
their own intentional fatal sentinel, declared nonzero exit and unique fixture
diagnostic after observing the required severity. Earlier termination attempts
were fixture diagnostics, not retained conformance differences.

Compatible evidence retains 1238 previous records: 1113 pass, 137 known
(116 runtime differences, thirteen missing-API builds and eight unlinked-DPI
builds). The overlapping VPI condition stays seven pass and one fail. Guest
records cover 1085 unchanged inputs; 165 are unmeasured. Forty-six AI drafts
bring the ledger to 1575, directly linked to 1249 tests plus one control test.
Three unchanged priority/introspection fixtures gain explicit links without
remeasurement. Four individually read headings bring classifications to
sixty-six: sixty-four structural and two contextual. Of 2,504 identifiers,
951 are partially decomposed and 1,487 unassessed; the decrease of eighteen
is fourteen new decompositions plus four classifications. Primary focus is
609, any citation 1,250; candidate census is 1,870 zero, 341 one, 268 at least two.

Ten language pairs are checked, with 160 FAQ answers and 181 glossary entries.
Validation covers 88 tool tests, 1250 metadata records, canonical ledger/index,
library integrity, bilingual links and compatible evidence. Prior simulation
inputs, runners, VPI backend, scope, lock, licenses and six SVG assets are
unchanged. Scope/denominator approval and human review remain open.

## Twenty-seventh thin-area expansion across M1–M4

Eleven fixtures add four actual handler-dispatch cases, three multi-request or
restarted relevance cases and four standard TLM-adapter cases. All final inputs
match seeds 1 and 73. The suite reaches 1261: M1 425, M2 453 and M3 383.
Handler identity, source fields, sharing and replacement are checked through
public processing arguments without the missing catcher getter. Adapter cases
cover fresh payloads, five negative statuses, operation reuse and active
frontdoor reads with scoped context. Uniform bytes avoid imposing numeric byte
order. An unsupported inverse n_bits assertion was removed before final inputs;
valid-bit reconstruction remains open rather than copying an observed count.

Compatible ordinary evidence retains all 1250 previous inputs: 1124 pass,
137 known (116 runtime differences, thirteen missing-API builds, eight unlinked
DPI builds). Separate VPI remains seven pass/one fail. Guest records cover
1085 unchanged inputs; 176 current IDs are unmeasured. Fifty-one AI drafts
bring the ledger to 1626, all directly linked to 1260 tests plus one control.
Three unchanged configuration fixtures gain links without remeasurement.
Four individually read headings bring classifications to seventy: sixty-eight
structural, two contextual. Of 2,504 identifiers, 961 are partly decomposed and
1,473 unassessed; the decrease of fourteen is ten new decompositions plus four
classifications. Primary focus is 612, any citation 1,252; candidate census is
1,867 zero, 342 one and 270 at least two.

Ten guide pairs are checked, with 163 FAQ answers and 184 glossary entries.
Validation covers 88 tool tests, all 1261 metadata records, ledger/index/library
checks, bilingual links and current-input evidence. Prior simulation inputs,
runners, backend, scope, lock, licenses and six SVG assets remain unchanged.
Human review and scope/denominator approval remain open.

## Twenty-eighth thin-area expansion across M1–M4

Thirteen fixtures add four object type/name/printing cases, four sequence-report
cases, four nonuniform TLM-adapter cases and one hierarchical report-file case.
The annex D file case extends M1 reporting. The suite reaches 1274: M1 430,
M2 457 and M3 387. Twelve final inputs match seeds 1 and 73; one retains the
sequence-interface admission interpretation of 14.1.3.3. All explicit HIGH
enabled queries are false, but non-INFO calls reach virtual processing in the
pinned library. An at-limit control admits all four severities after a fixture
counter reset. This is separate from report-object 6.3.3.3. Roundtrips compare
nonuniform valid bits and masks without claiming independent one-way byte
order, padding or inverse n_bits. Hierarchical file ID selection is observed
before pair priority; a fixture ordering mistake was fixed before final input.

Compatible ordinary evidence retains all 1261 previous inputs: 1136 pass,
138 known (117 runtime differences, thirteen missing-API builds, eight unlinked
DPI builds). Separate VPI remains seven pass/one fail. Guest records cover
1085 unchanged inputs; 189 current IDs are unmeasured. Sixty-eight AI drafts
bring the ledger to 1694, all directly linked to 1273 tests plus one control.
Three unchanged object/printing fixtures gain links without remeasurement.
Three structural and one contextual record bring classifications to seventy-four:
seventy-one structural, three contextual. Manual standard checks restore three
missing catalog identifiers, B.2.1.2, B.2.1.3 and D.2.2.3. The catalog grows
from 2,504 to 2,507; the heading-shaped scan is not a completeness certificate.
There are 970 partly decomposed identifiers and 1,463 unassessed. The net
unassessed decrease of ten is three restored identifiers minus nine new
decompositions and four classifications. Primary focus is 616, any citation
1,257; candidate census is 1,866 zero, 343 one and 273 at least two.

Ten guide pairs are checked, with 167 FAQ answers and 188 glossary entries.
Validation covers 88 tool tests, all 1274 metadata records, ledger/index/library
checks, bilingual links and current-input evidence. Prior simulation inputs,
runners, backend, scope, lock, licenses and six SVG assets remain unchanged.
Human review and scope/denominator approval remain open.

## Twenty-ninth thin-area expansion across M1–M4

The user activates a persistent goal to eliminate M1–M4 gaps. The first
iteration focuses on the sparsely tested register-global chapter. Nine new
M3 fixtures bring the suite to 1283: M1 430, M2 457 and M3 396. They cover
default/configured typedef widths, enum symbols, coverage-set composition,
public slice fields and standard concat construction/replacement/append. Six
match final inputs at seeds 1 and 73. Three retain missing-API builds: one
named constructor and two standard slice-accessor cases. No legacy interface
substitutes for the standard. Declaration evidence does not establish X/Z
storage, downstream enum-controlled operations, invalid-input rejection,
stored-name observability or real HDL access.

Compatible evidence preserves all 1274 previous inputs: 1142 pass and 141
known (117 runtime first differences, sixteen missing-API builds, eight
unlinked-DPI builds). Separate VPI remains seven pass/one fail. Guest records
cover 1085 unchanged inputs; 198 current IDs are unmeasured. Forty-one AI
drafts bring the ledger to 1735, directly linked to 1282 tests plus one control.
Six individually read structural headings and two contextual records bring
assessments to eighty-two: seventy-seven structural and five contextual.
Chapter 17 now has 22 partial and eight assessed identifiers, with zero
unassessed. Four macro clauses also gain partial decomposition. Overall,
991 of 2,507 identifiers are partial, 82 assessed and 1,434 unassessed, a
decrease of 29 from activation. Primary focus is 624, any citation 1,272;
candidate census is 1,858 zero, 350 one and 274 at least two.

The goal remains active; zero unassessed chapter material is not completed
coverage. The handoff records the full completion audit. Ten guide pairs,
170 FAQ answers and 191 glossary entries are checked along with 88 tool tests,
all 1283 metadata records, ledger/index/library and current-input identities.
Previous simulation inputs, runners, catalog, backend, scope, lock, licenses,
Issue policy, six SVG assets and VPI records remain unchanged. Human review
and scope/denominator approval remain open.

## Thirtieth thin-area expansion across M1–M4

The second persistent-goal iteration adds eighteen command-line fixtures:
seventeen M1 cases and one actual phase-default-sequence M2 case despite its
annex G location. Totals are 1301: M1 447, M2 458 and M3 396. A new independent
runner uses an original VPI process-argument bridge and compiles pinned
Apache-2.0 UVM regex code through a wrapper and portable allocation header.
No simulator implementation, commercial overlay or implementation-derived
oracle is used. Selected observations cover construction/inheritance/singleton,
argument filters, literal/extended-regex matches, suffixes and all nine built-in
option clauses, including timed settings, scoped actions/severity, actual
factory types, numeric-base config values and default-sequence execution.

Seventeen final inputs match both seeds. One retains G.2.6's required WARNING
for a rejected non-overridable quit-count change; the pinned server correctly
keeps seven but emits INFO. The YES control accepts nine. A separate metadata
marker selects the seventeen reproduced cases for default checks and CI;
all-case execution keeps the difference as known. The ordinary runner does
not link the backend, so its eighteen new records are unlinked-DPI builds.
Compatible ordinary evidence preserves all 1283 previous inputs: 1142 pass,
159 known (117 runtime differences, sixteen missing-API builds, 26 unlinked-DPI
builds: eight HDL and eighteen command-line). Separate HDL VPI remains seven
pass/one fail. Guest records cover 1085 unchanged inputs; 216 current IDs are
unmeasured. No overlapping native pass count is added to the ordinary total.

Forty-four AI drafts bring the ledger to 1779, directly linked to 1300 tests
plus one control. Four individually read headings bring assessments to 86:
81 structural and five contextual. Annex G now has eighteen partial identifiers
and four structural assessments, zero unassessed. Its broader conditions remain
open. Overall, 1008 of 2,507 identifiers are partial, 86 assessed and 1,413
unassessed, 21 fewer this iteration and 50 fewer since goal activation. Primary
focus is 639, any citation 1,294; candidate census is 1,843 zero, 363 one and
276 at least two. The goal remains active without scope/denominator approval.

Validation includes 101 tool tests, all 1301 metadata records, ledger/index,
library integrity, bilingual guides and compatible evidence. Ten guide pairs,
173 FAQ answers and 194 glossary entries are checked. The ordinary, HDL and
guest runners, prior inputs, catalog, scope, lock, licenses, Issue policy,
six SVG assets and prior evidence remain unchanged. CI adds the seventeen
separate command-line checks and increases its timeout to 150 minutes.

## Thirty-first thin-area expansion across M1–M4

The third persistent-goal iteration adds twelve M2 fixtures: four inheritance/
type-parameter cases, two standard protected-counter cases, three cyclic-index
cases, two relevance-wait kills and one nested sequencer stop with fresh traffic.
All final inputs match seeds 1 and 73. The suite reaches 1313: M1 447, M2 470
and M3 396. Initial probe issues were corrected without changing expected
observations: fork-owned storage is static, inherited field randomization is
named inside a subtype method, and counter libraries use a real bound sequencer.
No public getter or mode API is substituted with a legacy field. Protected
counter probes observe zero, active-child exclusion, completed prefixes, final
ten-count and peer isolation. Randc probes observe width, legal indices, two
nonrepeating cycles, singleton reuse and a subtype-constrained subset without
fixing order. Kill/stop cleanup uses actual requests, gates, public states/hooks
and subsequent real driver completion; required post-hook differences remain.

Twenty-three AI drafts bring the ledger to 1802, directly linked to 1312 tests
plus one control. Six existing requirements gain nine direct links while
preserving all prior links; one limitation clarifies the earlier manual two-count
getter fixture versus the new default-ten protected-field probes. Three unchanged
RAND fixtures gain introduction-level mappings without remeasurement. Five
individually read introductions/example sections bring assessments to 91:
81 structural and ten contextual. Chapter 14 now has 89 partial identifiers,
17 assessments and zero unassessed. Overall, 1015 of 2,507 identifiers are
partial, 91 assessed and 1,401 unassessed: twelve fewer this iteration and
62 fewer since activation. Primary focus is 645, any citation 1,305; the
candidate census is 1,837 zero, 367 one and 278 at least two. All remain partial
review evidence, without scope/denominator or human approval.

Compatible ordinary records retain all 1301 prior inputs: 1154 pass and
159 known (117 runtime first differences, sixteen missing-API builds and
26 unlinked-DPI builds). Separate command-line evidence remains seventeen
pass/one known; HDL VPI remains seven pass/one fail. Guest records retain
1085 unchanged inputs with 228 current IDs unmeasured. Validation covers
101 tool tests, all 1313 metadata records, ledger/index/library identities,
compatible evidence and ten guide pairs with 176 FAQ answers and 197 glossary
entries. Previous inputs, all runners/tools, CI, catalog, backend, scope, lock,
licenses, Issue policy, six SVG assets and separate VPI records are unchanged.
The goal remains active, including the remaining partial obligations.

## Thirty-second thin-area expansion across M1–M4

The fourth persistent-goal iteration adds thirteen M3 fixtures: four item/
adapter name/type/conversion cases, one backdoor name/type case, three default
read/callback cases, two original write cases and three predictor type/config
cases. All final inputs match seeds 1 and 73. The suite reaches 1326: M1 447,
M2 470 and M3 409. The initial predictor packet setup lacked a correctly typed
factory registration; adding it fixes the pinned library type-name path
without changing expected observations. Default read invokes an original
function, with exact descriptor identity, pre/post order, current callback
registration and success/failure status. Write hooks pass transformed data
through protected helpers to original storage via a real register model.
Independent configured maps/decoders affect real mirror and publication values.

Twenty-six AI drafts bring the ledger to 1828, directly linked to 1325 tests
plus one control. All earlier drafts remain unchanged. Six structural and
seven contextual individual assessments bring the total to 104: 87 structural
and 17 contextual. Chapter 19 has 70 partial, 15 assessed and 26 unassessed
identifiers. Overall, 1038 of 2,507 identifiers are partial, 104 assessed and
1,365 unassessed: 36 fewer this iteration and 98 fewer since goal activation.
Primary focus is 653, any citation 1,318; the candidate census is 1,829 zero,
375 one and 278 at least two. Decomposition, milestone targets, scope and
human review remain incomplete; no percentage or approval is invented.

Compatible ordinary evidence retains all 1313 prior inputs: 1167 pass and
159 known (117 runtime first differences, sixteen missing-API builds and
26 unlinked-DPI builds). Separate command-line evidence remains 17 pass/
1 known and HDL VPI 7 pass/1 fail. Guest evidence retains 1085 unchanged
inputs; 241 current IDs are unmeasured. Validation covers 101 tool tests,
1326 metadata records, ledger/index/library identity, compatible execution
records and ten guide pairs with 179 FAQ answers and 200 glossary entries.
All runners/tools, prior simulation inputs, CI, catalog, scope, library lock,
licenses, Issue policy, six SVG assets and separate VPI records are unchanged.
The active goal retains task-read boundary conditions, encode/decode arrays,
default formatter completeness, printed write visibility/virtuality,
parent-sequence do_clone, predictor diagnostic severity and all remaining
partial obligations.

## Thirty-third thin-area expansion across M1–M4

The fifth persistent-goal iteration adds seventeen M3 fixtures: two delayed
task reads, five callback pipeline/default-control cases, three sequence/
frontdoor type/name cases, three direct/layered translation cases, a super-body
warning/nonreturn case, a virtual model-selection case and two HDL-parameter
cases. Thirteen match final inputs at seeds 1 and 73. Four encode/decode
propagation fixtures first differ at seed 1 with no seed 73 result. The suite
reaches 1343: M1 447, M2 470 and M3 426. Callback order matches while array
changes fail to reach later callbacks/final storage or returned values. The
normative transformed values are retained, using two noncommuting operations
and two memory values without test-side writeback repair. The actual default
callback no-change control passes. Real translation uses upstream and bus
sequencers, an original adapter and delayed driver, including write failure/
retry. A selected invalid super-body call warns and does not return before
cleanup. Parameter probes compare the macro-derived declared integer value,
without fixing its implementation numeric default or asserting HDL execution.

Twenty-eight AI drafts bring the ledger to 1856, directly linked to 1342 tests
plus one control. All earlier drafts remain unchanged. Four structural and
five contextual individual assessments bring the total to 113: 91 structural
and 22 contextual. Chapter 19 has 81 partial, 24 assessed and six unassessed
identifiers. Overall, 1051 of 2,507 identifiers are partial, 113 assessed and
1,343 unassessed: 22 fewer this iteration and 120 fewer since activation.
Primary focus is 664, any citation 1,327; the candidate census is 1,818 zero,
381 one and 283 at least two. Partial obligations, milestone targets, scope
and human review remain incomplete, with no invented percentage or approval.

Compatible ordinary evidence retains all 1326 prior inputs: 1180 pass and
163 known (121 runtime first differences, sixteen missing-API builds and
26 unlinked-DPI builds). Separate command-line evidence remains 17 pass/
1 known and HDL VPI 7 pass/1 fail. Guest evidence retains 1085 unchanged
inputs; 258 current IDs are unmeasured. Validation covers 101 tool tests,
1343 metadata records, ledger/index/library identity, compatible execution
records and ten guide pairs with 182 FAQ answers and 203 glossary entries.
All runners/tools, prior simulation inputs, CI, catalog, scope, library lock,
licenses, Issue policy, six SVG assets and separate VPI records are unchanged.
The active goal retains the four callback propagation differences and all
remaining applicability, partial-obligation and interpretation work.

## Thirty-fourth thin-area expansion across M1–M4

The sixth persistent-goal iteration adds fourteen M1 fixtures: five constructor/
type cases, initial event-pool membership, two raw wait cases, accepted time/
state, two data cases, mixed-waiter reset and two barrier cases. Eleven match
final inputs at seeds 1 and 73; three first differ at seed 1 with no seed 73
result. The suite reaches 1357: M1 461, M2 470 and M3 426. A public pre-trigger
query confirms an early raw waiter, but it resumes only on the second trigger
in the measured condition; the late caller correctly waits for a fresh one.
Default event reset reports zero waiters while three callers remain blocked;
a fresh trigger still releases all three. Required event-pool names are absent
before lazy get. Their normative expectations remain spec-only. Separate
persistent-wait, barrier threshold/reset, scalar-copy and live-object-alias
controls match. The barrier silent-reset case uses bounded observation and
cleanup so a stranded-process condition would not hide its public result.

Thirty-six AI drafts bring the ledger to 1892, directly linked to 1356 tests
plus one control. All earlier drafts remain unchanged. Seven structural and
seven contextual individual assessments bring the total to 127: 98 structural
and 29 contextual. Chapter 10 has 65 partial, 15 assessed and 36 unassessed
identifiers. Overall, 1072 of 2,507 identifiers are partial, 127 assessed and
1,308 unassessed: 35 fewer this iteration and 155 fewer since activation.
Primary focus is 676, any citation 1,339; the candidate census is 1,806 zero,
391 one and 285 at least two. Both pool get_global declaration/prose conflicts,
partial obligations, milestone targets, scope and human review remain open.

Compatible ordinary evidence retains all 1343 prior inputs: 1191 pass and
166 known (124 runtime first differences, sixteen missing-API builds and
26 unlinked-DPI builds). Separate command-line evidence remains 17 pass/
1 known and HDL VPI 7 pass/1 fail. Guest evidence retains 1085 unchanged
inputs; 272 current IDs are unmeasured. Validation covers 101 tool tests,
1357 metadata records, ledger/index/library identity, compatible execution
records and ten guide pairs with 185 FAQ answers and 206 glossary entries.
All runners/tools, prior simulation inputs, CI, catalog, scope, library lock,
licenses, Issue policy, six SVG assets and separate VPI records are unchanged.
The goal remains active, including the remaining partial obligations.

## Thirty-fifth thin-area expansion across M1–M4

The seventh persistent-goal iteration adds thirteen fixtures: nine M1 objection/
heartbeat cases and four M2 generic-callback cases. Twelve match final inputs
at seeds 1 and 73; one first differs at seed 1 with no seed 73 result. The
suite reaches 1370: M1 470, M2 474 and M3 426. Actual default objection hooks
reach component methods and explicitly enabled registered callbacks with the
original source/description/count. Positive drain precedes delayed source
hooks, root total remains held during each and reaches zero after completion.
Raised/draining mode changes produce ERROR and preserve mode, with later idle
success. Callback declarations, explicit enabled queries and optional-CB
add/delete have positive checks. The initial objection-callback constructor
setup was corrected to supply its explicit name without changing expected
identity/state output or claiming an omitted subtype constructor guarantee.
Mode zero routes callbacks correctly but omits intermediate descendant totals;
the two/one expectation remains spec-only. The omitted callback_mode default
conflict remains unresolved and explicit arguments are used throughout.

Twenty-eight AI drafts bring the ledger to 1920, directly linked to 1369 tests
plus one control. All earlier drafts remain unchanged. Seven structural and
seven contextual individual assessments bring the total to 141: 105 structural
and 36 contextual. Chapter 10 has 85 partial, 29 assessed and two unassessed
identifiers, both pool get_global declaration/prose conflicts. Overall, 1092
of 2,507 identifiers are partial, 141 assessed and 1,274 unassessed: 34 fewer
this iteration and 189 fewer since activation. Primary focus is 687, any
citation 1,354; the candidate census is 1,795 zero, 401 one and 286 at least
two. Partial obligations, milestone targets, scope and human review remain open.

Compatible ordinary evidence retains all 1357 prior inputs: 1203 pass and
167 known (125 runtime first differences, sixteen missing-API builds and
26 unlinked-DPI builds). Separate command-line evidence remains 17 pass/
1 known and HDL VPI 7 pass/1 fail. Guest evidence retains 1085 unchanged
inputs; 285 current IDs are unmeasured. Validation covers 101 tool tests,
1370 metadata records, ledger/index/library identity, compatible execution
records and ten guide pairs with 188 FAQ answers and 209 glossary entries.
All runners/tools, prior simulation inputs, CI, catalog, scope, library lock,
licenses, Issue policy, six SVG assets and separate VPI records are unchanged.
The goal remains active, including the remaining partial obligations.

## Thirty-sixth thin-area expansion across M1–M4

The eighth persistent-goal iteration adds thirteen M2 fixtures: interface
parameters/dispatch, FIFO-base construction, three port-default/constructor
cases and eight FIFO/transport/analysis cases. Twelve match final inputs at
seeds 1 and 73; one fails at build with no runtime seed evidence. The suite
reaches 1383: M1 470, M2 487 and M3 426. The REQ-only bidirectional fixture
retains the standard independent integer RSP default; pinned RSP=REQ fails
the exact string/int base argument check. All-int defaults and explicit packed
request/response transport controls match. This new declaration-default build
category is separate from missing APIs and unlinked DPI. FIFO state, object
head availability, public exports, blocking/nonblocking forwarding and analysis
broadcast are observed. Zero-capacity is_full and summary alias/imp-parameter
wording remain open. Constructor probes do not establish resolved binding.
Formatting/name adjustments precede final measurement without changing oracles.

Thirty-five AI drafts bring the ledger to 1955, directly linked to 1382 tests
plus one control. One unchanged indexed-imp fixture gains a direct requirement
mapping; its earlier source/evidence is retained. All earlier drafts remain
unchanged. Eleven structural and thirteen contextual individual assessments
bring the total to 165: 116 structural and 49 contextual. Chapter 12 has
108 partial, 28 assessed and 78 unassessed identifiers. Overall, 1113 of
2,507 identifiers are partial, 165 assessed and 1,229 unassessed: 45 fewer
this iteration and 234 fewer since activation. Primary focus is 699, any
citation 1,359; the candidate census is 1,783 zero, 412 one and 287 at least
two. Partial obligations, milestone targets, scope and human review remain open.

Compatible ordinary evidence retains all 1370 prior inputs: 1215 pass and
168 known (125 runtime first differences, sixteen missing-API builds, one
response-default declaration build and 26 unlinked-DPI builds). Separate
command-line evidence remains 17 pass/1 known and HDL VPI 7 pass/1 fail.
Guest evidence retains 1085 unchanged inputs; 298 current IDs are unmeasured.
Validation covers 101 tool tests, 1383 metadata records, ledger/index/library
identity, compatible execution records and ten guide pairs with 191 FAQ
answers and 212 glossary entries. All runners/tools, prior simulation inputs,
CI, catalog, scope, library lock, licenses, Issue policy, six SVG assets and
separate VPI records are unchanged. The goal remains active, including the
remaining partial obligations.

## Thirty-seventh thin-area expansion across M1–M4

Thirteen M2 fixtures add channel default/type inheritance and constructor
identity, omitted/fixed one-slot queue capacities, analysis type/constructor
metadata, direct imp delivery and nested export fanout. TLM 2 probes cover
exact default/custom interface types and virtual paths, inherited constrained
rand fields, payload names/sequence-item inheritance/initial incomplete status,
and virtual response queries for seven statuses. Original interface algorithms
are setup; no full bus target or complete protocol is certified.

All thirteen additions and one citation-revised command fixture match seeds
1 and 73. A predicate counter initially constrained internal OK-query calls
made by the error query; a guard now counts only external selected calls,
without changing normative output, and was remeasured. The ordinary snapshot
retains 1382 unchanged old records and reaches 1396: 1228 pass/168 known,
with M1 470, M2 500 and M3 426. Separate HDL and command-line conditions remain
7 pass/1 fail and 17 pass/1 known. All runners/library/other old inputs remain.

Forty-six drafts reach 2001; all 1955 prior requirements remain unchanged.
Six individual assessments are added. Re-reading 12.2.9.2 found distinct
fixed-capacity duties, so its prior contextual classification is removed and
two direct requirements replace it. There are 1141 partial, 170 assessed
(119 structural/51 contextual) and 1196 unassessed identifiers. Chapter 12 is
136/33/45. Persistent-goal iteration nine reduces unassessed by 33, or 267
since activation. TLM 1 has no unassessed identifier, while its partial
obligations and all milestone targets remain open.

One metadata-revised command input invalidates its old guest fingerprint.
The historical 1085-record files remain; current compatible copies retain
1084 inputs. Ghost is 207 pass/877 fail per seed; kirimasim 1075 unsupported/
nine fail. There are 312 unmeasured inputs, including 311 additions and the
revised old fixture. No guest run is claimed. All 101 tool tests, metadata,
ledger/library checks and bilingual documentation checks pass. Scope and
denominator remain unapproved; the goal stays active.

## Thirty-eighth thin-area expansion across M1–M4

Twelve M2 fixtures add legal/default extension construction, all eight socket
declarations, ordinary port/export/imp defaults, actual default imp binding,
explicit/parent socket implementation selection, custom-phase two-way relays,
blocking relay completion/reuse and selected legal/forbidden provider connects.
Nine match seeds 1 and 73. Three qualified interpretation probes first differ
at seed 1, without seed 73: printed nonblocking provider lists under blocking
headings are rejected; same-kind initiator connects report ERROR yet keep raw
direct entries. Targets leave none. These are reviewable interpretations,
not proven defects. Operational blocking controls match. Initial packed-string
label padding was corrected and both seeds rerun without changing the oracle.

All 1396 prior inputs/records, 2001 drafts and 170 assessments remain unchanged.
The suite reaches 1408: M1 470, M2 512, M3 426; ordinary 1237 pass/171 known,
including 128 runtime first differences and 43 build records. Separate HDL
and command-line evidence remains 7 pass/1 fail and 17 pass/1 known. The guest
subset remains 1084 compatible inputs: Ghost 207 pass/877 fail per seed,
kirimasim 1075 unsupported/nine fail. There are 324 unmeasured current inputs,
323 additions plus the earlier citation-revised command input. No guest run
is claimed; runners/library/schema/catalog are unchanged.

Eighty-three AI drafts reach 2084, and twelve individual structural
assessments reach 182 (131 structural/51 contextual). Normative overviews stay
partial rather than being excluded. Chapter 12 is 169 partial/45 assessed/
zero unassessed. Overall totals are 1174 partial, 182 assessed and 1151
unassessed. Goal iteration ten reduces unassessed by 45, or 312 since
activation. Zero unassessed in chapter 12 does not complete its remaining
obligations. All 101 tool tests, metadata, ledger/library, compatible evidence
and bilingual documentation checks pass. Scope and denominator stay
unapproved; the M1–M4 goal remains active.

## Thirty-ninth thin-area expansion across M1–M4

Ledger schema 2 adds compile-diagnostic links alongside unchanged output
anchors. A compile stage, exact valid declared regex and genuine illegal
elaboration metadata are required; runtime/mixed expectations are rejected.
Schema 1 remains readable. Nine new meaningful regressions bring the tool
suite to 110; reports add test-kind counts and explicit ledger schema version.
The counting unit, scope and existing stale-input protections stay unchanged.

Eight new elaboration fixtures check direct construction of virtual
transaction, report catcher, wrapper, component, TLM extension base, typed
sequence, frontdoor and backdoor classes. All reject with the targeted compiler
error and execute no binary/runtime seed. Eight unchanged concrete/proxy
runtime controls remain separate. All 1408 earlier fixture inputs and records,
2084 requirement objects and 182 assessments are preserved. Eight drafts
reach 2092. Four unassessed declarations become partial; four existing partial
clauses gain negative conditions. Totals: 1178 partial/182 assessed/1147
unassessed. Goal iteration eleven reduces unassessed by four, or 316 since
activation; the full M1–M4 goal stays active.

The suite is 1416 fixtures: 1408 simulation and eight elaboration. M1 is 474
(470/4), M2 514 (512/2), M3 428 (426/2), in runtime/elaboration order. Ordinary
Verilator has 1237 two-seed runtime matches plus eight expected compiler
rejections (1245 pass), and 171 known simulation differences. Guest evidence
stays at 1084 compatible runtime inputs; 332 inputs are unmeasured (324 runtime,
eight elaboration). Separate HDL and command-line evidence is unchanged.

All runner/library/catalog identities remain unchanged. Workflow comments
and the step label, both bilingual measurement diagrams and the guides now
distinguish compiler rejection from runtime execution. Four SVGs were rendered
and visually checked. All 110 tool tests, metadata, ledger/library, compatible
evidence and bilingual document checks pass. Scope and denominator remain
unapproved; no new human review or guest measurement is claimed.

## Fortieth thin-area expansion across M1–M4

Fourteen negative elaboration fixtures isolate each of four database hooks,
four link hooks, catcher catch, subscriber write, visitor visit, two adapter
converters and adapter const-reference mutation. Twelve reject with the
required diagnostic. The subscriber/visitor omissions compile successfully;
both remain spec-only with the rejection oracle unchanged. No illegal design
executes a binary/runtime seed. Initial regex escaping/category errors were
corrected before the final run, without changing the normative expectation.

Three positive fixtures inherit concrete implementations: recording hooks
through public wrappers, subscriber delivery through the typed analysis export,
and adapter converter signatures/reference effects. All match seeds 1/73.
Their original payload algorithms are setup, not prescribed library behavior.
All 1416 prior inputs/records, 2092 requirements and 182 assessments remain.
Twenty-nine bilingual AI drafts reach 2121; one individually read methods
heading is structural. Seven previously unassessed normative identifiers become
partial. Totals: 1185 partial/183 assessed/1139 unassessed. Goal iteration twelve
reduces unassessed by eight, or 324 since activation; the goal stays active.

The suite is 1433 fixtures: 1411 simulation/22 elaboration. M1 is 485 (471/14),
M2 516 (513/3), M3 432 (427/5). Ordinary Verilator is 1260 pass: 1240 two-seed
runtime matches and 20 compiler rejections; 173 known comprise 171 simulation
differences and two illegal compile acceptances. Guest evidence retains 1084
compatible runtime inputs, with 349 unmeasured (327 simulation/22 elaboration).
Separate HDL and command-line evidence remains unchanged. All 110 tool tests,
metadata, ledger/library, current-input evidence and bilingual docs pass.
Runner/library/catalog, schemas, workflow and SVGs are unchanged. No guest
run, human review or scope/denominator approval is claimed.

## Forty-first thin-area expansion across M1–M4

Thirteen M1 fixtures add reporting constructors/default configuration, shared
reset/filter interaction, catcher/compose/execute ordering, message database
handles, used-severity queues, global server statistic transfer, fatal/warning
helper bypass/default fields, actual file routes, summary destination/default
arguments and direct abstract-server construction. Eleven runtime fixtures
match seeds 1/73 and the abstract construction rejects with its targeted error,
without runtime. One shared reset retains severity/ID verbosity, first differing
at seed 1 without seed 73; its default-restoration oracle stays unchanged.
Initial constructor/global setup/startup-count fixture errors were corrected.
An extra original ID-count setter only satisfies the pinned pure interface,
without asserting a nonstandard API requirement. Custom hook bodies are setup.

All 1433 prior fixture input identities/records and earlier assessments remain.
Fifty-six bilingual AI drafts reach 2177. Three older entries retain their
original links and gain direct anchors/clarified limits. Seven grouping headings
and one contextual overview are individually assessed, preserving normative
overviews as partial. Overall totals are 1218 partial/191 assessed/1098
unassessed; chapter 6 is 96/19/2 with two do_print clauses and partial conditions
still open. Goal iteration thirteen reduces unassessed by 41, or 365 since
activation; M1–M4 completion remains unproven and the goal stays active.

The suite is 1446 fixtures: 1423 simulation/23 elaboration. M1 is 498 (483/15),
M2 516 (513/3), M3 432 (427/5). Ordinary Verilator has 1272 pass: 1251 two-seed
runtime matches and 21 compiler rejections; 174 known comprise 129 runtime
differences, 43 simulation build differences and two illegal compile acceptances.
Guest evidence retains 1084 compatible runtime inputs; 362 are unmeasured
(339 simulation/23 elaboration). Separate HDL/command-line evidence is unchanged.
All 110 tool tests, metadata, ledger/library, current evidence and bilingual
docs pass. Schema, runners/library/catalog, workflow and SVGs remain unchanged.
No guest run, human review or scope/denominator approval is claimed.

## Forty-second thin-area expansion across M1–M4

Twenty-six M1 fixtures add message/handler print observers, printer field/user
hook and history order, disabled hooks, recursion/depth, scalar/array structure,
radix controls/values, root-name selection, prefixes, constructors/base types,
default-instance recovery and format-specific flush/separator conditions.
Sixteen runtime cases match seeds 1/73 and two virtual constructions reject
with the targeted error without runtime. Eight printer cases first differ at
seed 1 without seed 73: SHALLOW, entry-depth boundaries, already-exceeded scope,
disabled radix prefix, root default and three format-control flush fixtures.
The equality reading stays qualified; the above-bound probe is independent.
Original observers accept raw integers and decimal generic values; no private
field name or default text layout becomes an oracle.

All 1446 earlier fixture input identities/records and assessments remain.
Ninety-seven bilingual AI drafts reach 2274, after removing two overlapping
drafts. One prior constructor entry gains a direct link, preserving previous
links and fields. Eleven grouping headings and two representational introductions
are individually assessed; contextual entries name concrete related duties.
Totals: 1273 partial/204 assessed/1030 unassessed. Chapter 6 is 98/19/0 and
chapter 16 is 132/13/63; 16.2.10 remains unassessed. Partial duties remain open.
Goal iteration fourteen reduces unassessed by 68, or 433 since activation;
the full M1–M4 goal stays active.

The suite reaches 1472: 1447 simulation/25 elaboration. M1 is 524 (507/17),
M2 516 (513/3), M3 432 (427/5). Ordinary Verilator has 1290 pass: 1267 two-seed
runtime and 23 compiler rejection matches; 182 known comprise 137 runtime,
43 simulation builds and two illegal compiler acceptances. Guest evidence stays
at 1084 compatible runtime inputs; 388 are unmeasured (363 simulation/25
elaboration). Separate HDL/command-line evidence remains unchanged. All 110 tool
tests, metadata, ledger/library, compatible evidence and bilingual docs pass.
The earlier packer link label is corrected to its actual 128-bit fixture width;
that fixture and its evidence are unchanged. Schema, runners/library/catalog,
workflow and SVGs remain unchanged. No new guest run, human review or scope/
denominator approval is claimed.

## Forty-third thin-area expansion across M1–M4

Twenty-nine M1 fixtures add comparer/copier/packer constructors, base/type
identity and default wrappers, wide comparison and packing, comparer messages
and thresholds, copy ownership, field/user/history order, recorder configuration,
open-record flush, default object hooks, attribute overrides and seven isolated
abstract/pure-hook declaration prohibitions. Fifteen runtime cases match seeds
1/73; seven compiler rejections match without runtime. Seven runtime cases
first differ at seed 1: copier naming, comparer/copy reset, SHALLOW child
compare/copy, wide-size error and recorder radix reset. The SHALLOW/default-field
flag reading stays qualified. Original observer errors were fixed before final
measurement; no mismatch replaces a normative expected value.

All 1472 prior inputs/records and 204 assessments remain unchanged. Seventy-four
new bilingual drafts reach 2348; eight older duties gain direct links with
their other fields and prior links retained. Thirteen structural and five
contextual assessments retain explicit rationales and related duties. Totals
are 1315 partial/222 assessed/970 unassessed. Chapter 16 is 174/31/3; remaining
chapter, table-format and recorder-lifecycle/link overviews are open. Goal
iteration 15 reduces unassessed by 60 this increment and by 493 since activation.

The suite is 1501 (1469 simulation/32 elaboration): M1 553 (529/24), M2 516
(513/3), M3 432 (427/5). Ordinary Verilator is 1312 pass (1282 two-seed runtime,
30 expected compiler rejections), 189 known (144 runtime, 43 simulation builds,
two illegal compile acceptances). Guest evidence retains 1084 compatible
runtime inputs with 417 unmeasured (385 simulation/32 elaboration). Separate
VPI evidence is unchanged. All 110 tool tests and metadata, ledger/library,
evidence and bilingual checks pass. Schema, runner/library/catalog, workflow
and SVGs are unchanged. No guest execution, human review, denominator approval
or goal completion is claimed.

## Forty-fourth thin-area expansion across M1–M4

Seventeen M3 runtime fixtures add memory-manager/memory identity, region
descriptor units and byte rounding, inclusive boundaries, persistent
reservation, invalid foreign/double release with independent controls,
iteration, configuration queries/shrink, repeated default-policy randomization,
failed requests and six transfer delegation methods. All match seeds 1/73
with final metadata. Original observer construction/signatures were corrected;
failed read data is not asserted. Transfer spies establish wrapper delegation,
not a physical storage/backend. The memory burst-write offset omission and
region burst-read output/ref discrepancy remain qualified.

All 1501 prior inputs/records and 222 assessments are retained. Forty-four
new bilingual AI drafts reach 2392; eight old duties gain direct links with
their other fields and prior links unchanged. Six structural and one contextual
assessment bring totals to 1337 partial/229 assessed/941 unassessed. Chapter 18
is 227/25/204. MAM has six unassessed identifiers, including mode/locality
semantics, textual state and region overview; all partial conditions stay open.
Goal iteration 16 reduces unassessed by 29, or 522 since activation.

The suite is 1518 (1486 simulation/32 elaboration): M1 553 (529/24), M2 516
(513/3), M3 449 (444/5). Ordinary Verilator is 1329 pass (1299 two-seed runtime,
30 compiler rejections), with 189 known unchanged (144 runtime, 43 simulation
builds, two illegal compile acceptances). Guest evidence retains 1084 current
runtime inputs with 434 unmeasured (402 simulation/32 elaboration). Separate
VPI records are unchanged. All 110 tool tests, metadata, ledger/library,
evidence and bilingual checks pass. Schema, runner/library/catalog, workflow
and SVGs are unchanged. No guest execution, human review, denominator approval
or goal completion is claimed.

## Forty-fifth thin-area expansion across M1–M4

Twenty-two M2 fixtures add sequencer types/names/parents, direct abstract
prohibitions, real typed pull connectors, virtual interface request/response
methods, recording disable across traffic, base grant/send/completion and
common queries. Seventeen runtime additions match seeds 1/73; two abstract
constructions reject without runtime. Two new builds retain the interface
request-default and printed-getter differences; a qualified wait_for_sequences
probe differs at seed 1 without seed 73. Observer capture was made explicit
without weakening the blocking contract before final measurement.

One existing rerandomization fixture now accepts at least one callback instead
of exactly one, with its stable ID/expected line retained. It is remeasured at
both seeds. Its old guest record is excluded; all other guest records remain.
The original 1085-record source files remain intact. Fifty-one new bilingual
drafts reach 2443 after removing two duplicate history proposals. Four older
duties gain links and the older rerandomization expectation/limitation is
corrected. All prior IDs remain. Seven structural and seven contextual
assessments reach 1366 partial/243 assessed/898 unassessed. Chapter 15 is
65/18/2, retaining the interface-introduction inconsistency and zero-time
relevance guard. Goal iteration 17 reduces unassessed by 43, or 565 since activation.

The suite is 1540 (1506 simulation/34 elaboration): M1 553 (529/24), M2 538
(533/5), M3 449 (444/5). Ordinary Verilator has 1348 pass (1316 two-seed runtime,
32 compiler rejections) and 192 known (145 runtime, 45 simulation builds,
two illegal compile acceptances). The 1517 unchanged older native records
remain, alongside the corrected input. Guests retain 1083 compatible inputs:
Ghost 207 pass/876 fail per seed, kirimasim 1074 unsupported/nine fail, with
457 unmeasured (423 simulation/34 elaboration). These changed subset totals
are filtering, not new execution or improvement. Separate VPI records remain.
All 110 tool tests and metadata, ledger/library, evidence and bilingual checks
pass. Schema, runners/library/catalog, workflow and SVGs remain unchanged.
No human review, denominator approval or goal completion is claimed.

## Forty-sixth thin-area expansion across M1–M4

Twenty M1 fixtures strengthen chapter 13 components: family constructors and
nominal types, five abstract direct constructions, environment defaults,
permitted names and duplicate errors, child printing, domain selection/definition,
user protocol dispatch, exact driver endpoints/default put, string agent
configuration, common/runtime phase callbacks and exit/pre_abort direction.
The error observers terminate themselves without assuming invalid-call recovery.
Phase chains are preconstructed; function direction is checked while concurrent
task entry order stays unspecified. Suspend/resume observes only user dispatch.

Fifteen runtime fixtures match Verilator 5.052 seeds 1/73 and five targeted
compiler rejections execute no runtime. All 1540 earlier fixtures/input hashes,
records, 2443 requirements and 243 assessments remain unchanged. Seventy-seven
new AI drafts reach 2520; seven structural and ten contextual assessments reach
260 (183/77). Chapter 13 is 80 partial/18 assessed/12 unassessed. Overall is
1416/260/831, reducing unassessed by 67 this increment and 632 across eighteen
goal iterations. All partial conditions and milestone targets remain open.

The suite is 1560 (1521 simulation/39 elaboration): M1 573 (544/29), M2 538
(533/5), M3 449 (444/5). Ordinary Verilator has 1368 pass (1331 two-seed runtime,
37 compiler rejections) and the unchanged 192 known. Compatible guest files
remain byte-identical with 1083 records; 477 inputs are unmeasured (438/39),
including both earlier revised inputs. Separate HDL and command-line evidence
remain unchanged at 7/1 and 17/1. No new guest run is claimed.

Validation covers 110 tool tests, metadata, ledger/index/library identities,
native raw results and compiler diagnostics, compatible retained evidence and
ten bilingual guide pairs with 239 glossary terms and 218 FAQs. Schema, runners,
library/catalog, workflow and six SVGs remain unchanged. Scope stays proposed,
inventory incomplete, denominator/percentage null, AI reviews and active goal.
No human approval or goal completion is claimed.

## Forty-seventh thin-area expansion across M1–M4

Seventeen M1 runtime fixtures strengthen phase task/fork and callback-thread
lifetimes, a printed all_dropped function declaration, named test selection,
six factory convenience methods, hierarchical verbosity/actions/maximum,
actual selected log files and virtual recording setters. Eleven match both
Verilator 5.052 seeds. Five runtime differences retain task termination,
ready-thread completion and typed/named replace-zero/name-creation expectations.
One printed function/task conflict cannot build and executes no runtime seed.
No confirmed cause is assigned. WARNING verbosity is ignored explicitly;
configuration-query and actual-report observations are separate. An original
empty constructor default avoids imposing a user fallback-name policy.

Fifty-one new AI drafts reach 2571. Three component objection-hook duties reuse
compatible existing propagation evidence without a new run. All 2520 older
requirements, 260 assessments, 1560 fixtures and prior native records remain
unchanged. Four contextual assessments reach 264 (183/81). Overall is 1434
partial/264 assessed/809 unassessed. Chapter 13 is 87/21/2, retaining error/event
recording identifiers; annex D is 18/1/28. Unassessed falls by 22, or 654 across
nineteen goal iterations. All partial conditions remain open.

The suite is 1577 (1538 simulation/39 elaboration): M1 590 (561/29), M2 538
(533/5), M3 449 (444/5). Ordinary evidence has 1379 pass (1342 runtime at both
seeds and 37 compiler rejections) and 198 known (150 runtime, 46 simulation
builds, two illegal acceptances). The new signature build is distinct from
17 missing APIs, two type-default builds and 26 unlinked-DPI builds.
Guest files remain byte-identical with 1083 records and 494 unmeasured inputs
(455/39), including both earlier revised inputs. Separate HDL/command-line
evidence stays 7/1 and 17/1. No new guest measurement is claimed.

Validation covers 110 tool tests, metadata, ledger/index/library identities,
raw native/compile evidence and ten bilingual guide pairs with 244 glossary
terms and 220 FAQs. Schema, runners/library/catalog, workflow and six SVGs
remain unchanged. Scope stays proposed, inventory incomplete, denominator/
percentage null and reviews AI. The persistent goal remains active.

## Forty-eighth thin-area expansion across M1–M4

Thirteen M1 fixtures add original error/event backend observations, direct
object.record null/delegation checks, abstract recording declarations, base
constructor/object views, same-name link role dispatch, exact callback aliases
and forbidden iterator type_id access. Eight runtime cases match both seeds;
four targeted compiler rejections execute no runtime. One printed report_db
alias is missing and stays a qualified build difference without runtime.
Timestamp interpretation is backend-qualified; returned tokens, strings and
keep-active handle use remain application-specific. Alias null values are
compile markers, and user-hook suppression maps to recorder 16.4.7.7.

Forty-two new AI drafts reach 2613. All 2571 prior IDs remain; only two default
constructor-name duties gain direct links. All 1577 old fixtures/native records
and 264 earlier assessments stay unchanged. Eleven contextual/four structural
assessments reach 279 (187/92). Totals are 1461 partial/279 assessed/767
unassessed, decreasing by 42 this increment and 696 across twenty goal iterations.
Chapters 7/13 are 50/20/0 and 89/21/0; annex D is 35/7/5. Zero unassessed does
not close partial conditions or the original milestone targets.

The suite is 1590 (1547 simulation/43 elaboration): M1 603 (570/33), M2 538
(533/5), M3 449 (444/5). Ordinary evidence has 1391 pass (1350 runtime at both
seeds and 41 compiler rejections), 199 known (150 runtime, 47 simulation builds,
two illegal acceptances). Missing API/type names are 18; the two default-type,
one printed signature and 26 unlinked-DPI builds stay separate. Guest files
remain byte-identical with 1083 records; 507 inputs are unmeasured (464/43),
including both earlier revised inputs. Separate HDL/command-line stays 7/1
and 17/1. No new guest result is claimed.

Validation covers 110 tool tests, all metadata, ledger/index/library identities,
native/raw compile evidence and ten language pairs with 249 glossary terms and
222 FAQs. Schema, runners/library/catalog, workflow and six SVGs are unchanged.
Scope remains proposed, inventory incomplete, denominator/percentage null,
reviews AI and the persistent goal active.

## Forty-ninth thin-area expansion across M1–M4

Nine M3 runtime fixtures add four named register/memory forwarding probes, two
actual frontdoor storage paths and three block aggregation checks. All nine
match both Verilator 5.052 seeds. Genuine configured lookup, default/explicit
arguments, blocking completion, selected data/status and debug-only functional
invariance are observed. Failed read data and exact debug text forwarding are
not prescribed. Block cases observe dirty/clean local and descendant state,
full-width minimum writes, clean no-write behavior and mirror refresh/checking
without assigning sibling order. No new known result is added.

Sixty-five new AI drafts reach 2678; all 2613 earlier requirements, 279
assessments and 1590 fixtures/native records remain unchanged. D.3 and its
18.1.5.7 cross-reference receive individual contextual assessments. Overall is
1468 partial/281 assessed/758 unassessed; annex D is 39/8/0 and chapter 18
230/26/200. Unassessed falls by nine, or 705 across twenty-one goal iterations.
All partial conditions and original milestone targets remain open.

The suite is 1599 (1556 simulation/43 elaboration): M1 603 (570/33), M2 538
(533/5), M3 458 (453/5). Six D.3 fixtures reside in uD by metadata convention
and count as register-layer M3; the other three reside in u18. Ordinary evidence
has 1400 pass (1359 runtime at both seeds, 41 compiler rejections) and the
unchanged 199 known. Guest files keep 1083 byte-identical records, with 516
unmeasured inputs (473/43), including both earlier revised inputs. Separate
HDL/command-line remains 7/1 and 17/1; no guest run is claimed.

Validation covers 110 tool tests, metadata, ledger/index/library identities,
native/raw compile evidence and ten language pairs with 254 glossary terms and
224 FAQs. An English no-DPI note is corrected from stale elaboration count 34
to 43. Schema, runners/library/catalog, workflow and six SVGs remain unchanged.
Scope stays proposed, inventory incomplete, denominator/percentage null,
reviews AI and the persistent goal active.

## Fiftieth thin-area expansion across M1–M4

Ten M3 runtime fixtures cover block constructors/object views, default and
explicit coverage availability, flattened HDL paths, exact-scope coverage
construction, constructor-only coverage unions, all-requested enabled queries,
backdoor inheritance/replacement and arbitrary HDL kind selection. Nine match
both Verilator 5.052 seeds. The inherited HDL-kind presence probe retains a
seed-1 difference without seed 73 and keeps its nearest-ancestor oracle.
Actual inherited register poke/peek selects original root/child/register-local
storage under debug and failure/retry controls. Metadata is not covergroup
measurement or physical HDL transport, and no initial enabled default is inferred.

Thirty-eight AI drafts reach 2716; all 2678 earlier requirements, 281 assessments
and 1599 fixtures/native records remain unchanged. 18.1 and 18.1.6 receive
individual contextual assessments. Overall is 1481 partial/283 assessed/743
unassessed; chapter 18 is 243/28/185. Subclause 18.1 has no unassessed identifier,
but partial conditions remain open. Unassessed falls by 15, or 720 across
twenty-two goal iterations; original M1–M4 targets remain open.

The suite is 1609 (1566 simulation/43 elaboration): M1 603 (570/33), M2 538
(533/5), M3 468 (463/5). Ordinary evidence has 1409 pass (1368 runtime at both
seeds, 41 compiler rejections) and 200 known (151 runtime/47 build/2 illegal
acceptances). Guest files keep 1083 byte-identical records, with 526 unmeasured
inputs (483/43), including both earlier revised inputs. Separate HDL/command-line
stays 7/1 and 17/1; no guest run is claimed.

Validation covers 110 tool tests, metadata, ledger/index/library identities,
native/raw compiler evidence and ten language pairs with 258 glossary terms and
226 FAQs. Schema, runners/library/catalog, workflow and six SVGs are unchanged.
Scope remains proposed, inventory incomplete, denominator/percentage null,
reviews AI and the persistent goal active.

## Fifty-first thin-area expansion across M1–M4

Fifteen M3 runtime fixtures add map names/object views and singleton identity,
local/system bus settings, actual nested sequencer/adapter replacement, six
map-specific enumeration families, byte/word memory lookup boundaries and
unmapped memory logical frontdoor access. Thirteen match both Verilator 5.052
seeds. Empty/populated map width cases keep seed-1 differences without seed 73:
local width eight is returned instead of root-path minimum two. They are
applicability fixtures, not two isolated defects. The word-unit interpretation
remains qualified and does not isolate a unit defect from this width mismatch.

Fifty-seven AI drafts reach 2773; all 2716 earlier requirements, 283 assessments
and 1609 fixtures/native records remain unchanged. 18.2 is individually assessed
as contextual and 18.2.5 as structural. Overall is 1498 partial/285 assessed/724
unassessed; chapter 18 is 260/30/166. 18.2.3.12 remains unassessed pending a
sound clone contents/rights observation route from its printed API. Unassessed
falls by 19, or 739 across twenty-three goal iterations; partial duties and
original M1–M4 targets remain open.

The suite is 1624 (1581 simulation/43 elaboration): M1 603 (570/33), M2 538
(533/5), M3 483 (478/5). Ordinary evidence has 1422 pass (1381 runtime at both
seeds, 41 compiler rejections) and 202 known (153 runtime/47 build/2 illegal
acceptances). Guest files keep 1083 byte-identical records, with 541 unmeasured
inputs (498/43), including both earlier revised inputs. Separate HDL/command-line
stays 7/1 and 17/1; no guest run is claimed.

Validation covers 110 tool tests, metadata, ledger/index/library identities,
native/raw compiler evidence and ten language pairs with 262 glossary terms and
228 FAQs. Schema, runners/library/catalog, workflow and six SVGs are unchanged.
Scope remains proposed, inventory incomplete, denominator/percentage null,
reviews AI and the persistent goal active.

The current known-build summary is corrected to eighteen missing API/type-name cases, two type-default declarations, one printed hook-signature case and 26 unlinked DPI cases. All 47 prior build records remain unchanged; separate HDL and command-line conditions remain 7/1 and 17/1.

## Fifty-second thin-area expansion across M1–M4

Sixteen M3 simulation fixtures add register constructor/placement, membership
and unregister views, local-map resolution, captured maximum widths, gapped
field order, reset-kind metadata, model-only getters, gated busy state and clone
call/declaration controls. Thirteen match both Verilator 5.052 seeds. Two retain
seed-1 differences without seed 73: sole-map null/default selection and pre-lock
field names. A qualified literal clone scalar-return override cannot build
against the available map return and has no runtime. Public clone call/source
preservation matches separately; new-map content/rights remain open.

Fifty-eight AI drafts reach 2831; all 2773 earlier requirements, 285 assessments
and 1624 fixtures/native records remain unchanged. Five individually read
assessments add two contextual and three structural entries. Overall is 1516
partial/290 assessed/701 unassessed; chapter 18 is 278/35/143. 18.2/18.3 have
no unassessed identifiers, without completing their partial duties. Unassessed
falls by 23, or 762 across twenty-four goal iterations; original targets remain open.

The suite is 1640 (1597 simulation/43 elaboration): M1 603 (570/33), M2 538
(533/5), M3 499 (494/5). Ordinary evidence has 1435 pass (1394 runtime at both
seeds, 41 compiler rejections) and 205 known (155 runtime/48 build/2 illegal
acceptances). The 48 builds retain 18 missing API/type names, two type defaults,
two qualified printed signatures and 26 unlinked DPI cases. Guest files keep
1083 byte-identical records, with 557 unmeasured inputs (514/43), including both
earlier revised inputs. Separate HDL/command-line stays 7/1 and 17/1; no guest run.

Validation covers 110 tool tests, metadata, ledger/index/library identities,
native/raw compiler evidence and ten language pairs with 266 glossary terms and
230 FAQs. Schema, runners/library/catalog, workflow and six SVGs are unchanged.
Scope remains proposed, inventory incomplete, denominator/percentage null,
reviews AI and the persistent goal active.

A stale Japanese summary of unexpected simulation builds is corrected from 45 to the current 48, and both language summaries now distinguish the two printed signature conflicts. This changes documentation only; every prior build record is preserved.

## Fifty-third thin-area expansion: phase state, domain and proxy contracts (2026-11-04)

Twenty-two M1 fixtures add nineteen simulations and three elaboration checks.
Fifteen simulations match seeds 1/73; three direct constructions of virtual
phase classes match their expected rejection without runtime. Four simulations
retain seed-1 differences without seed 73: required initial domain entries,
premature task lifetime and qualified literal get_imp/get_schedule statements.
The latter signature/prose conflicts remain explicit; a string receiver alone
was strengthened with `$typename` before the current measurement.

Initial fixture problems were corrected before assembling current evidence:
a reserved variable name in the registry probe, and standalone traversal
contexts without the applicable component domain. Their obsolete results are
excluded from the current snapshot. Domain-attached top-down/bottom-up traversal
matches, with ancestor order and no sibling-order assumption.

Other matching controls cover callback descriptors/scope/defaults, backward
jump run counts/targets, deferred target selection, constructor/base views,
single-parent names, duplicate-domain ERROR and runtime insertion, asynchronous
task proxy arguments and one twenty-one-row predefined getter matrix. The
matrix maps three generic 9.8 duties, not complete delegate coverage.

Fifty-six AI drafts reach 2887; twelve structural and six contextual assessments
reach 308 (203/105). Overall is 1556 partial/308 assessed/643 unassessed;
chapter 9 is 67/18/31 and annex F 33/0/104. All 2831 earlier requirements,
290 assessments and 1640 fixture inputs/native records remain unchanged.
The goal's twenty-fifth iteration reduces unassessed by 58, retaining partial
obligations and all original milestone targets.

Current totals are 1662 (1616 simulation/46 elaboration): M1 625 (589/36),
M2 538 (533/5), M3 499 (494/5). Ordinary native evidence is 1453 pass
(1409 runtime/44 compiler rejections) and 209 known (159 runtime/48 simulation
builds/two illegal acceptances). Guest 1083 records and separate HDL/command-line
conditions remain byte-identical; 579 inputs are unmeasured (533 simulation/46
elaboration), including two revised old inputs. No guest run is claimed.

Metadata, ledger/index, library integrity, 110 tool tests, current native/compiler
identities and paired documentation checks pass. All review remains AI; scope
is proposed, denominator/percentage unset and the persistent goal active.
Schema, runners/library/catalog, workflow and six SVGs are unchanged.

## Fifty-fourth thin-area expansion: delegates, timing and domain execution (2026-11-04)

Fifteen M1 simulations all match seeds 1/73. Two shared matrices exercise
selected virtual delegates for eight common function phases and thirteen task
phases, preserving context and distinguishing peers/other hooks. Direct task
proxies await delayed return; execute forking remains a separate contract.

Review strengthened the runtime concurrency fixture from an entry marker to
active run-node state and advancing original-task heartbeats, sampled two units
apart. The current remeasured input replaces the earlier weaker record.

Real-engine controls check pre-run time zero, run/final endpoint equality,
twelve-phase runtime order/nonoverlap and start/extract boundaries, and run
concurrency. Locked absolute timeout produces FATAL at its retained limit;
default-overridable calls permit a later limit. The actual timeout definition
F.7.3.3 is cited despite the run paragraph's F.7.2.3 cross-reference.

Task traversal covers STARTED/EXECUTING/READY_TO_END/ENDED with original delayed
proxies on a domain-attached subtree. Specialized component proxies preserve
per-type singleton identity and homogeneous phase views. Six domain fixtures
separate independence, same/different-phase synchronization, selected/all/explicit
removal and retained relationships. A parallel jump restarts both related active
branches while an independent peer completes once. No new known difference is added.

Forty-seven AI drafts reach 2934. Four contextual assessments reach 312
(203 structural/109 contextual). Overall is 1584 partial/312 assessed/611
unassessed; chapter 9 is 94/22/0 with 138 drafts; annex F is 34/0/103. All
2887 earlier requirements, 308 assessments and 1662 input/native records remain
unchanged. The goal's twenty-sixth iteration reduces unassessed by 32, without
certifying every partial condition or original milestone target.

Current totals are 1677 (1631 simulation/46 elaboration): M1 640 (604/36),
M2 538 (533/5), M3 499 (494/5). Ordinary evidence is 1468 pass (1424 runtime/
44 compiler rejection) and 209 known (159 runtime/48 simulation builds/two
illegal acceptances). Guest 1083 records and HDL/command-line conditions remain
byte-identical; 594 inputs are unmeasured (548 simulation/46 elaboration),
including two revised old inputs. No guest execution is claimed.

Metadata, ledger/index, library, 110 tool tests, native/compiler identities and
paired documentation checks pass. The duplicate phase-definition glossary entry
is consolidated and synchronization terminology added; total remains 268 terms.
All review is AI, scope proposed and denominator/percentage unset. The goal is
active. Schema, runners/library/catalog, workflow and six SVGs are unchanged.

## Fifty-fifth thin-area expansion: factory inventory and builtin registry contracts (2026-11-05)

Nineteen M1 factory fixtures add eighteen simulations and one elaboration.
Twelve simulations match seeds 1/73, and virtual uvm_factory construction matches
compiler rejection without runtime. Four legal simulations cannot build: missing
transaction/report-server type_id and incompatible inherited subscriber/sequence
registry specializations. Two unknown-name fixtures return null and create their
registered controls but observe no required ERROR at seed 1, without seed 73.
The independent sequence-base probe matches and does not borrow the blocked
matrix's result. Seven category fixtures plus two isolated probes select fourteen
unique builtin declarations, not all eight categories or every package type.
Review strengthens the declared-alias checks to static assignments in both
directions without a runtime cast; the current versions are remeasured.

Four print selections check zero/default/one/two without fixed table syntax.
Both stdout and stderr are independently framed and the runtime message regex
checks their union, including split content. UT markers alone cannot pass a
content omission. Fifty-two local predicate checks reject empty/missing/forbidden
content and names outside the frames. Original proxies observe registration
without represented construction and by-name/by-type dispatch, names and parents.
Valid unknown-name controls are moved before invalid requests to avoid an
unprescribed post-error registry-state oracle. ERROR/null expectations stay.
The default-factory extension matches after a reserved variable name in the
initial fixture is corrected; its obsolete build is excluded. The global active
view retains a qualified interpretation of the overview's one-instance wording.

Twenty-eight AI drafts reach 2962. Six structural and two contextual assessments
reach 320 (209/111). Overall is 1592 partial/320 assessed/595 unassessed;
chapter 8 is 60/12/0 with 83 drafts. All 2934 prior requirements, 312 assessments
and 1677 fixture inputs/native records remain unchanged. The goal's twenty-seventh
iteration reduces unassessed by sixteen; partial duties and original milestone
targets remain open.

Current totals are 1696 (1649 simulation/47 elaboration): M1 659 (622/37),
M2 538 (533/5), M3 499 (494/5). Ordinary evidence is 1481 pass (1436 runtime/
45 compiler rejection) and 215 known (161 runtime/52 simulation builds/two
illegal acceptances). Guest 1083 and separate HDL/command-line records remain
byte-identical; 613 inputs are unmeasured (566 simulation/47 elaboration),
including two revised old inputs. No guest execution is claimed.

Metadata, ledger/index, library, 110 tool tests, print predicate checks,
native/compiler identities and paired docs pass. All review is AI, scope proposed
and denominator/percentage unset. The goal remains active. Schema, runners/library/
catalog, workflow and six SVGs are unchanged.

## Fifty-sixth thin-area expansion: memory selection and actual HDL arrays (2026-11-05)

Seventeen M3 memory fixtures add concrete constructor/default checks, a captured
maximum-width baseline, public allocation-manager contiguous/vreg reservations,
exact local virtual-register/field enumeration and lookup isolation. Per-map
custom frontdoors retain independent storage under debug metadata, while
inherited/local user backdoors exercise actual modeled access, rejection and
retry. ROM modeled writes preserve storage while poke deposits directly.
Concat coordinates/duplicates, ancestor path cross products and hierarchical
coverage-resource selection are independent metadata probes.

Eleven ordinary fixtures match both seeds. Two first differ at seed 1 without
seed 73: a local-only lookup returns a previously inherited cached backdoor,
and coverage setters return the new rather than previous mask. One legal
public-read declaration build is blocked by protected accessibility; its task
body is never executed. The independent public-write declaration matches.
Three actual-array ordinary builds lack linked DPI and have no runtime result.

Those three physical fixtures separately match both seeds through the unchanged
original VPI backend: selected 16-bit memory words, 24-bit split banks and ROM
write versus poke/read/peek. Original derived wrappers reach inherited base
tasks without repairing the public-read contract. Earlier eight HDL records
remain unchanged, giving ten matches/one retained E.7 difference in eleven.
These narrow two-state array results do not imply general HDL support.

The initial maximum-width fixture used a reserved variable; an initial path setup
also included an empty ancestor path. Both setup issues were corrected and
remeasured before current inclusion. No valid expectation was replaced with
observed failing output. Current inputs are fingerprinted after oracle tagging.

Thirty-one bilingual AI drafts reach 2993; seven individually read structural
headings reach 327 assessments (216/111 structural/contextual). Chapter 18 is
298 partial/42 assessed/116 unassessed with 606 drafts. Overall is 1612/327/568.
The goal's twenty-eighth iteration reduces unassessed by 27, leaving original
milestone targets and all partial obligations open. All 2962 earlier requirements,
320 assessments and 1696 ordinary inputs/records remain unchanged.

Totals reach 1713 (1666 simulation/47 elaboration): M1 659 (622/37), M2 538
(533/5), M3 516 (511/5). Ordinary results are 1492 pass (1447 runtime/45 expected
compiler rejections) and 221 known (163 runtime/56 simulation builds/two illegal
compiler acceptances). Guest 1083 and command-line records remain byte-identical;
630 inputs are unmeasured (583 simulation/47 elaboration), including two revised
old inputs. No guest run is claimed.

All 110 tool tests, metadata, ledger/index, library, current-input/native/compiler
identities and paired docs pass. Guides add two FAQs and two terms: 237/271.
No human review, denominator approval or completion is claimed. Schema,
runners/library/catalog, backend, workflow and six SVGs are unchanged. Goal active.

## Fifty-seventh thin-area expansion: package contracts and run callbacks (2026-11-05)

Eighteen M1 package/run-test callback fixtures add thirteen two-seed runtime
matches, one expected compiler rejection and four seed-1 runtime differences
without seed 73. Generic reports use observed WARNING 200/ERROR 100 instead of
the required NONE 0; the warning helper also uses 200 instead of 0. Explicit
message/debug/context fields still match through the original root handler.

Callback membership return values match, but deleting a later handle produces
incorrect delivery counts and the removed handle still receives hooks. An
independent fixture without deletion receives both hooks yet observes
UVM_CORE_INITIALIZED in pre-run callbacks instead of UVM_CORE_PRE_RUN; its
post-run state matches. These are separate requirements and known inputs.
Abort notifications, component-before-callback ordering and final ABORTED state
match in a separate direct-die fixture. No peer callback order is prescribed.

Matching controls also cover macro-selected signed bitstreams, signed 64-bit
integrals, action one-hot/capacity, actual file/MCD storage, standard handles,
global reporter/enabled queries, prechecked and preformed report delegation,
subsequent initialization, constructor names and virtual-base rejection.
The signed-shift fixture was corrected to store the shift before unsigned
comparison context; its obsolete difference is excluded, not assigned to UVM.
Four-state preservation, first nonnull initialization, every registry hook and
full abort/report/termination combinations remain separate audits.

Package auditing adds 38 AI drafts for eighteen M1 fixtures. It separates
selected type/macro contracts, action-vector capacity, FD/MCD and standard
handles, global reporting defaults/delegation, repeated initialization,
callback membership versus actual delivery, run-state boundaries and abort.

The two report-default fixtures retain their parameter-value differences;
explicit fields do not pass those whole inputs. Membership return values do not
certify which callback was removed. A separate no-deletion fixture isolates the
pre-run state difference from that delivery defect. Direct die uses the explicit
F.7.3.2 sequence; F.2.10's ABORTED wording about post_run callbacks remains a
separate interpretation issue. No observed library implementation defines an oracle.

Thirteen individually read grouping headings are structural and the callback
introduction is contextual with related hook/registration duties. Annex F is
56 partial/14 assessed/67 unassessed with 91 drafts. B.6.2 gains two selected
macro duties; annex B is 39 partial/zero assessed/105 unassessed with 50 drafts.
Overall is 1635 partial/341 assessed/531 unassessed (229 structural/112
contextual). All 2993 earlier requirements and 327 assessments remain unchanged.
Type X/Z behavior, all enum semantics, first nonnull initialization, registry
hooks, callback mutation/reentrancy and complete run/abort paths remain open.
Current totals: 1731 (1683 simulation/48 elaboration), M1 677 (639/38), M2 538
(533/5), M3 516 (511/5). Ordinary evidence: 1506 pass (1460 runtime/46 compiler
rejections), 225 known (167 runtime/56 simulation builds/two illegal acceptances).
All 1713 earlier ordinary records, 2993 requirements and 327 assessments remain
unchanged; guest 1083/HDL 11/command-line 18 records are byte-identical. Guest
unmeasured is 648 (600 simulation/48 elaboration), including two revised inputs.

The goal's twenty-ninth iteration removes 37 unassessed identifiers, leaving 531
and all partial obligations open. All 110 tool tests, metadata/ledger/library,
evidence identities and paired docs pass. FAQ/terms reach 239/273. Schema,
runners/library/catalog/backend, workflow and six SVGs are unchanged. No guest
run, human review, denominator approval or completion is claimed. Goal active.

## Fifty-eighth thin-area expansion: resources, scopes and typed storage (2026-11-05)

Thirty-two M1 resource fixtures add twenty-four two-seed runtime matches,
four expected compiler rejections, three seed-1 runtime differences without
seed 73 and one legal extension build without runtime. Missing-name lookup
omits the required default warning. Both independently measured local and
global pool cases retain assigned precedence 3/9 but return the first resource
by name instead of the required maximum; type priority and its queue match.
The local public-constructor/singleton boundary remains explicitly qualified.

The original extensions declare separate direct base-constructor calls with an
explicit name and argument omission. They implement the standard-listed pure
type hook but cannot compile because the pinned library also requires unlisted pure helpers.
That legal declaration stays spec-only. A separate missing-type-hook negative
uses original compatibility bodies to isolate the required get_type_handle
rejection; it does not repair the legal extension. Other negative fixtures
reject direct virtual-base construction and incompatible typed read/write
contexts, each without a runtime seed and with independent legal controls.

Matching controls cover exact queue/DB aliases, default resource/DB types,
constructor names, static/polymorphic tokens, scalar/string/queue copying and
object-handle identity, read-only ERROR/storage, equal/rejected-write notification
suppression, all pending waiters on a changed write, scope replacement/deletion,
null insertion warnings, separate name/type/both priorities and overrides,
first-maximum queues, core-service pool/default selection, and DB values,
identity, failed-read sentinels and shared-scope writes.

Initial accessor setup mistakenly constructed abstract uvm_object directly.
Original concrete accessor classes now replace it and are remeasured; obsolete
setup builds are excluded rather than assigned to UVM. Expected outputs stay
standard-derived. Constructor prose/prototype differences, lookup_type's queue/
convenience-text conflict, type-priority versus broader lookup wording and the
type-write paragraph's name-based references remain explicit interpretations.
No successful-write return value is invented.

Resource auditing adds 63 AI duties for thirty-two M1 fixtures. Constructor
and declaration surfaces, exact aliases/type tokens, selected payloads and type
safety, read-only and notifications, pool ownership/scopes/maps/precedence,
core defaults and typed DB operations have independent conditions/observations.
Equal and rejected writes retain pending waiters; a changed write releases both.
Name/type/both priorities and overrides are six separate fixtures, not one row
borrowed from an obstructed shared matrix.

Three runtime differences and the unlisted-pure-hook legal build remain. The
pure-hook negative's extra original compatibility bodies isolate rejection of
the standard hook; they do not turn the unqualified extension into a pass.
The assigned numeric precedences are observed independently of name selection.
Global and local pool results are separate current inputs; interpretation
boundaries in the singleton/constructor and lookup/type/write prose remain.

Ten individually read headings are structural and two introductions are
contextual with related duties. Annex C is 52 partial/12 assessed/20 unassessed
with 68 drafts. Four core-service duties bring annex F to 60/14/63 with 95
drafts. Overall is 1687 partial/353 assessed/467 unassessed (239 structural/
114 contextual). All 3031 earlier requirements and 341 assessments are unchanged.
Remaining C work includes overview/printing contracts, sort ties, regex/scope
collections, typed highest-precedence filtering, static DB/config inheritance
and convenience aliases, invalid precedence arguments and every partial
lifecycle/concurrency condition. No number establishes complete conformance.
Totals: 1763 (1711 simulation/52 elaboration), M1 709 (667/42), M2 538 (533/5),
M3 516 (511/5). Ordinary results are 1534 pass (1484 runtime/50 compiler
rejections), 229 known (170 runtime/57 simulation builds/two illegal acceptances).
All 1731 prior ordinary records, 3031 requirements and 341 assessments remain
unchanged; guest 1083/HDL 11/command-line 18 records are byte-identical. Guest
unmeasured is 680 (628 simulation/52 elaboration), including two revised inputs.

The goal's thirtieth iteration reduces unassessed by 64 to 467; all partial
obligations and original targets remain open. All 110 tool tests, metadata,
ledger/library, evidence identities and paired docs pass. FAQs/terms reach
242/275. Schema, runners/library/catalog/backend, workflow and six SVGs are
unchanged. No guest run, human review, denominator approval or completion is
claimed. Goal active.

## Fifty-ninth thin-area expansion: sequencer bounds and transaction events (2026-11-05)

Nine M2 sequencer fixtures add eight two-seed runtime matches and one seed-1
runtime difference without seed 73. The relevance guard matches at time zero
with the omitted ten, explicit two and twelve, and a virtual base-view setter.
At time three, setting three before a fresh zero-time burst notifies only on
callback five. The retained qualified oracle permits notification at the bound
or first excess (three/four), so this remains spec-only. Raw callback/time
observations are separate from the boundary predicate; ERROR or FATAL is accepted
as the unspecified error notification, without an exact severity/ID/text rule.
No counter-reset, negative-limit or post-error recovery behavior is invented.

Real pull-port transfers match automatic named begin/end notifications and
timestamps, suppression after disabling before the first request, explicit
component recording that gates modeled pipelined completion, and separate
custom address/data events. Standard typed callbacks observe transaction-pool
entries; attaching them does not prove initial pool membership. No physical
DUT completion, recorder handle layout or database format is certified.
The interface overview's inheritance wording conflicts with the actual class
declarations and remains unresolved rather than becoming a new ancestry rule.

One new library-utils duty maps four unchanged macro fixtures. Each extension,
including the derived subtype, already invokes the required macro with its
own exact type. Their empty-static-membership differences remain unchanged;
no extra implementation initialization helper or new execution is claimed.

Sequencer auditing adds sixteen AI duties for nine M2 fixtures and four
unchanged library-macro inputs. Default/explicit/positive-time relevance bounds
and virtual dispatch have independent conditions. Actual pull traffic separates
automatic events/times, disable side effects, early acknowledgement versus
modeled completion, and custom address/data notification gates. The positive-time
bound difference remains a qualified result; all other new fixtures match both
seeds. No exact error identity or recovery policy is assumed.

B.3.2.2 now has a direct static-list duty linked to existing joint B.3.2.1/
B.3.2.2 observations. The derived type already includes its required macro.
Two individually read headings are structural and two introductions contextual;
the normative 15.2.1 overview remains partial, including its ancestry conflict.
Chapter 15 is 67 partial/18 assessed/0 unassessed with 131 drafts; annex B is
40/4/100 with 51 drafts. Zero unassessed chapter-15 identifiers does not complete
its remaining conditions. Overall is 1690 partial/357 assessed/460 unassessed
(241 structural/116 contextual). All 3094 earlier requirements and 353 assessments
remain unchanged. Original M1–M4 targets and every partial duty remain open.

Totals: 1772 (1720 simulation/52 elaboration), M1 709 (667/42), M2 547
(542/5), M3 516 (511/5). Ordinary results are 1542 pass (1492 runtime/50 compiler
rejections), 230 known (171 runtime/57 simulation builds/two illegal acceptances).
All 1763 prior ordinary records, 3094 requirements and 353 assessments remain
unchanged; guest 1083/HDL 11/command-line 18 records are byte-identical. Guest
unmeasured is 689 (637 simulation/52 elaboration), including two revised inputs.

The goal's thirty-first iteration reduces unassessed by seven to 460 (1003
since activation); all partial obligations and original targets remain open.
An initial report-catcher citation typo and generated indentation are corrected
before final-input remeasurement; no setup error is called a library difference.
All 110 tool tests, metadata, ledger/library, evidence identities and paired docs
pass. FAQs/terms reach 245/277. Schema, runners/library/catalog/backend, workflow
and six SVGs remain unchanged. No guest run, human review, denominator approval
or completion is claimed. Goal active.

## Sixtieth thin-area expansion: builtin sequence declarations and live child slots (2026-11-05)

Twenty-nine M3 fixtures add twenty-four two-seed runtime matches, two expected
protected-access rejections, two seed-1 constructor-name differences without
seed 73, and one accepted illegal direct construction without runtime.
The single-memory access/walk constructors retain their listed default-name
expectations; explicit nonempty/empty names and target controls are separate
observations. The printed virtual builtin dispatcher is accepted when directly
constructed. Legal concrete extensions do not replace that rejection duty.

Selected checks cover fifteen builtin constructor/declaration surfaces, exact
register-sequence ancestry, public model/register/memory target handles,
replacement/peer isolation, a 64-bit selection field, abstraction-queue storage,
and six exact protected child slots. External access is rejected in two selected
wrappers. Five live factory-child probes check the executing slot and selected
targets; their original child bodies certify routing only, without standing in
for builtin access/walking algorithms. Existing full-algorithm controls and
unchanged reset/dispatcher body records remain separate evidence.

An initial direct comparison between different concrete extension handle types
failed in generated C++ compilation. The control now uses common builtin-base
views for the same identity predicate and is remeasured. That obsolete build is
not counted as a UVM difference. Two access routing probes initially lacked
backdoor eligibility; original per-target storage backdoors now provide that
precondition and the corrected inputs are remeasured. Their initial skip is a
fixture setup issue, not a UVM difference. Initial citation/format preflight errors were
also corrected before measurement. No standard-derived expectation is replaced.
The req_seq headings versus reg_seq prototypes and the printed E.6.3 numbering
remain explicit; no extra public accessor, child default/retention rule or
allocation/sibling order is invented.

Annex-E auditing adds 62 AI duties for twenty-nine new M3 fixtures and
unchanged body/control inputs. Fifteen constructor/name and ancestry surfaces,
thirteen target variables, six protected child declarations, selected visibility
negatives, seven body duties, dispatcher selection/width and abstraction queues
have explicit conditions. Matching original delegation probes do not prove the
underlying builtin payload algorithms; uncited old algorithm fixtures are control
links only. Initial-name and virtual-declaration differences remain spec-only.

Sixteen headings are individually structural and four introductions contextual
with related duties. All 77 formerly unassessed E identifiers are addressed:
the annex is 74 partial/20 assessed/0 unassessed with 114 drafts and 88 primary
fixtures (85 simulation/3 elaboration). This does not complete the 74 partial
contracts, physical DUT reset/access, historical walking-ones interpretation,
skip/error/abort/concurrency combinations or original milestone targets.

Overall is 1747 partial/377 assessed/383 unassessed (257 structural/120 contextual).
All 3110 earlier requirements and 357 assessments remain unchanged. Scope remains
proposed with null denominator/percentage; no clause state means complete.

Totals: 1801 (1746 simulation/55 elaboration), M1 709 (667/42), M2 547
(542/5), M3 545 (537/8). Ordinary results are 1568 pass (1516 runtime/52 compiler
rejections), 233 known (173 runtime/57 simulation builds/three illegal acceptances).
All 1772 prior ordinary records, 3110 requirements and 357 assessments remain
unchanged; guest 1083/HDL 11/command-line 18 records are byte-identical. Guest
unmeasured is 718 (663 simulation/55 elaboration), including two revised inputs.

The goal's thirty-second iteration reduces unassessed by 77 to 383 (1080 since
activation); all partial obligations and original targets remain open. All 110
tool tests, metadata, ledger/library, evidence identities and paired docs pass.
FAQs/terms reach 248/279. Schema, runners/library/catalog/backend, workflow and
six SVGs remain unchanged. No guest run, human review, denominator approval or
completion is claimed. Goal active.

## Sixty-first thin-area expansion: base-class conditions

Based on [58ba1c5](https://github.com/kurochan001/kirimasim-uvm-tests/commit/58ba1c5782c0a47980539b0d8a7ca9501f2be296); 2026-11-05 JST. Thirty-six M1 fixtures add nineteen matches: fifteen runtime cases at seeds
1/73 and four expected compiler rejections. Seventeen retain known differences:
twelve runtime cases at seed 1 without seed 73 and five legal builds without
runtime. These cover object/void/port declarations, constructor omissions and
names, transaction recording controls/handles/events, object policy hooks and
active policies, canonical time units/defaults and field-operation lifecycle.

The five legal builds are four missing object active-policy API builds and the printed
optional secs argument of time decr, which the library requires. Explicit-seconds
decrement and caller-unit scaling controls match independently. Twelve runtime
cases retain initial transaction activity, recording default-on wording,
four illegal recording-control interval notifications, two record-object routes,
time/port default names and field-operation hook queries before set/after flush.
Matching handle/registry/free and hierarchy observations do not pass those cases.
The explicit-DEEP recorder confirms its selected recursion mode before checking
the subject callback. Error probes require ERROR/FATAL notification without
fixing diagnostic text, ID, count or unspecified recovery.

One existing printer fixture is repaired to use the standard virtual-argument
names value and size under SystemVerilog 8.20. Its unchanged expected output
matches both seeds on the revised input. Initial override-name and caller-unit
time setup errors are corrected before final measurement; their obsolete
results are not counted as current UVM differences. User-defined print/compare,
direct record and named-resource set_local probes check selected extension
routes, not all builtin formatting, automatic field configuration or macros.
The printed pure-method/default-body wording and transaction-constructor comma
conflict remain explicit interpretation boundaries.

Chapter-5 auditing adds 60 AI duties for thirty-six new M1 fixtures and
selected existing controls. Eight headings are individually structural; one
active-policy introduction is contextual with related push/pop/get duties.
All 48 formerly unassessed identifiers are addressed: chapter 5 is 99 partial,
12 assessed and zero unassessed, with 168 drafts and 92 primary fixtures
(87 simulation/5 elaboration). This does not complete its remaining conditions.

Object/void ancestry and construction, virtual extension routes, transaction
recording controls/handles/events, generic port defaults, canonical time units
and field-operation hook lifecycle have explicit conditions. Missing APIs,
the secs argument-default build and twelve runtime differences remain spec-only.
Existing initiator/ID and field-operation controls are mapped narrowly; initiator
print/record, automatic configuration and broader error/lifecycle combinations
remain partial. Pure-method/default-body and constructor punctuation conflicts
are retained rather than silently resolved by the library.

Overall is 1786 partial/386 assessed/335 unassessed (265 structural/121 contextual).
All 3172 earlier requirements and 377 assessments remain unchanged. There are
1836 directly linked tests, one control-only test and 42 tests with control
links. Scope is proposed with null denominator/percentage; no clause state means
complete. One existing printer input/index/record is deliberately refreshed after
correcting override argument names and remeasurement; its oracle is unchanged.

The final suite is 1837 (1778 simulation/59 elaboration): M1 745 (699/46),
M2 547 (542/5), M3 545 (537/8). Ordinary evidence is 1587 pass (1531 runtime
at both seeds/56 expected rejections) and 250 known (185 seed-1 runtime,
62 legal builds and three accepted illegal constructions). Other 1800 prior
ordinary records and all 55 prior compiler records remain unchanged. The 1083
guest records and separate eleven HDL/eighteen command-line records are unchanged;
754 guest inputs are unmeasured (695 simulation/59 elaboration), comprising
752 post-original additions and two revised original inputs. The printer was
already outside the guest subset. Initial time/override setup failures and the
premature generic-port tag are corrected; final fingerprints bind every new
or revised record. No GPL/LGPL simulator implementation or commercial result
is used. Library integrity, 110 tool tests, metadata, ledger/index, raw/evidence
and bilingual docs checks pass. The persistent goal stays active: iteration 33
reduces unassessed from 1463 to 335 (1128), with no completion or human approval.

## Sixty-second thin-area expansion: resource collection and config types

Based on [c9d01f3](https://github.com/kurochan001/kirimasim-uvm-tests/commit/c9d01f36f61881dd9c36750c5808cab4961e6b4e); 2026-11-05 JST. Twenty-one M1 resource/config fixtures add fifteen matches: fourteen runtime
cases at seeds 1/73 and one expected pool-to-object assignment rejection. Six
retain known differences: three runtime inputs at seed 1 without seed 73 and
three legal builds without runtime. The missing typed resource-DB maximum helper
is called directly for mixed types, first-maximum ties and its default object
specialization. An untyped pool helper or testbench filter cannot replace it.

Distinct-precedence sorting and resorting after a change match. Equal precedence
retains a difference under the explicit interpretation of most-recently-set as
observed insertion history; that interpretation requires review. It is distinct
from the first-maximum selection rule. Literal regex lookup, exact named sets,
named/unnamed scope collection and scope replacement match without imposing
traversal order. Anchored alternation differs under the ordinary no-DPI condition.
The printed virtual regex/scope calls through a base view also differ; original
overrides test dispatch only and cannot certify builtin collection algorithms.

Config default/inherited static interfaces and four exact aliases have selected
set/get checks, including high bitstream bits, empty strings, shared/replaced
object handles and factory proxy handles. Positive-time component requests use
an explicit get, not an automatic-configuration oracle. Typed virtual-interface
resources retain live original instances. The resource-base print probe assesses
only inherited virtual dispatch. One supporting bitstream citation is corrected,
and final tag/detail/named-membership changes are remeasured; no standard-derived
expectation is replaced. These conditions do not close all resource contracts.

Annex-C auditing adds 30 AI duties for twenty-one new M1 fixtures. Nineteen
formerly unassessed identifiers receive partial decomposition. The type-interface
introduction is individually contextual with its retained static/polymorphic
accessor duties. All twenty previously unassessed identifiers are addressed:
C is 71 partial/13 assessed/0 unassessed, with 98 drafts and 69 primary fixtures
(64 simulation/5 elaboration). Its partial conditions remain open.

Sort order/recency, mixed-type maximum selection, regex/scope collection,
virtual declarations, priority enum meanings, config inheritance/defaults and
four aliases, positive-time component access, virtual-interface values and
resource-base print dispatch have explicit selected observations. The three
missing typed-helper builds and three runtime differences stay spec-only.
Recent-set semantics and lookup_type/overview conflicts remain qualified.

Overall is 1805 partial/387 assessed/315 unassessed (265 structural/122 contextual).
All 3232 earlier requirements, 386 assessments, 1837 test snapshots and ordinary
execution records remain unchanged. There are 1857 directly linked tests, one
control-only test and 43 tests with control links. Scope is proposed with null
denominator/percentage; no state certifies completion of M1–M4.

The final suite is 1858 (1798 simulation/60 elaboration): M1 766 (719/47),
M2 547 (542/5), M3 545 (537/8). Ordinary evidence is 1602 pass (1545 runtime
at both seeds/57 expected rejections) and 256 known (188 seed-1 runtime,
65 legal builds and three accepted illegal constructions). All 1837 prior
ordinary inputs/records and 59 compiler records are unchanged. Guest 1083,
HDL eleven and command-line eighteen records are unchanged; 775 guest inputs
remain unmeasured (715 simulation/60 elaboration), comprising 773 additions
and two revised original inputs. Final sources preserve the standard oracles,
correct an initial supporting citation and remeasure every tag/detail change.
Library integrity, 110 tool tests, metadata, ledger/index, raw/evidence and
paired documentation checks pass. No GPL/LGPL simulator implementation or
commercial result is used. The goal remains active: iteration 34 reduces
unassessed from 1463 to 315 (1148), without human approval or completion.

## Sixty-third thin-area expansion: memory maps and special-register FIFOs

Based on [b95b8a8](https://github.com/kurochan001/kirimasim-uvm-tests/commit/b95b8a891128bdcf2c7639a820d1edd428873b2c); 2026-11-05 JST. Thirty-seven M3 inputs add nineteen two-seed runtime matches and eighteen
seed-1 runtime differences without seed 73. Twenty-five use the listed APIs,
including an independent ordinary-register bus control; twelve additional
control-only inputs explicitly initialize the pinned FIFO with its unlisted
build method. They have separately indexed fingerprints and expected observations.
Seven initialized controls match; five retain differences. No control result
passes the constructor/configure-only premise of a direct requirement.

Memory address defaults select the sole member or shared parent-default map.
Unrelated-map address/offset/address-array warnings match, including minus-one
and unchanged caller-array duties. The rights query returns RW but generates
no required warning. Original delayed backdoor reads see external adjacent-word
changes. Memory/indirect/FIFO builtin factory exceptions retain legal registered
extension controls; indirect omitted/explicit constructors and register-base
write/read routing match.

Twelve constructor/configure-only FIFO inputs stop on a null internal field
before completing set/predict, transfer/update or compare/mirror observations.
After expectations were fixed, diagnosis in the pinned Apache-2.0 UVM identified
its unlisted build initializer. This is an explicit premise/interpretation
boundary, not an invented IEEE prerequisite or proof of independent library bugs.
The separately initialized controls reach the selected algorithms: set/full,
write/read prediction, the four comparison gates and omitted compare default
match. Direct write is rejected with Needs Update despite no external FIFO set;
external observation then duplicates abstract state without a bus write. Update
duplicates the two preloads into four entries/transfers; repeated update also
retains four entries. A checked matching public FIFO/DUT pair pops both queues
but reports an internal zero-mirror mismatch. The public-queue expectation is
qualified and remains open for review.

The final write control returns after its rejected write, avoiding a cascading
empty-original-DUT read. Its standard-derived expectation remains unchanged.
Two isolated declared helper directories preserve the original 1858 input
identities. Source/metadata preflight corrections are fixture work, not UVM
differences. All other earlier ordinary/compiler/guest/backend records remain
unchanged; no guest rerun or completion is claimed.

Memory/indirect/FIFO auditing adds 45 AI duties and one individually read
structural Methods heading. The fifteen previously unassessed identifiers in
18.6–18.8 receive fourteen partial decompositions and that assessment. Chapter 18
is 312 partial/43 assessed/101 unassessed with 651 drafts and 369 primary tests.
These three subclauses have zero unassessed identifiers, with remaining contracts
and the original milestone targets still open.

Thirty-seven new inputs consist of 25 direct/reference probes and twelve
explicitly initialized, pinned-library control-only variants. Their control
links do not replace the listed-API premise. Across the suite, 1882 tests have
direct links, thirteen have only controls and 56 have control links. Separate
normal-register transfer, constructor-only FIFO stops and initialized algorithm
observations preserve their distinct evidence and applicability.

Overall is 1819 partial/388 assessed/300 unassessed (266 structural/122 contextual).
All 3262 earlier requirements, 387 assessments, 1858 indexed inputs/ordinary
records and 60 compiler records remain unchanged. No known difference is changed
to a pass through the build control, and no state approves the proposed scope,
denominator, human review or completion.

The final suite is 1895 (1835 simulation/60 elaboration): M1 766 (719/47),
M2 547 (542/5), M3 582 (574/8). Ordinary is 1621 pass (1564 runtime at both
seeds/57 expected compiler rejections) and 274 known (206 seed-1 runtime,
65 legal builds and three accepted illegal constructions). All prior 1858
ordinary inputs/records and 60 compiler records remain unchanged, as do 1083
guest, eleven HDL and eighteen command-line records. Guest-unmeasured is 812
(752 simulation/60 elaboration): 810 additions and two revised original inputs.
The twelve new initialized cases have only control links; thirteen total inputs
are control-only, with 56 control-linked tests. No input is left unlinked.
Library integrity, 110 tool tests, metadata/ledger/index, raw/evidence and paired
documentation checks pass. The active goal reaches iteration 35: 1463 initial
unassessed identifiers fall to 300, a decrease of 1163. No completion, human
review or denominator approval is claimed.

## Sixty-fourth thin-area expansion: core declarations, phase limits and seeding

Based on [89b06ab](https://github.com/kurochan001/kirimasim-uvm-tests/commit/89b06ab55ee9970712d61e628265960a2e6650c7); 2026-11-05 JST. Thirty-five M1 inputs add 27 expected compiler rejections and five two-seed
runtime matches. Three retain differences: two seed-1 runtime inputs and one
legal simulation build without runtime. The 26 omission probes each implement
all other printed pure methods plus the pinned release's extra phase-hopper
hook. Each final compiler diagnostic identifies exactly the selected missing
method. Direct construction of the virtual core-service base is also rejected.

The original service implementing all 26 printed methods is rejected because
the pinned library additionally requires get_phase_hopper. A separately indexed,
control-only variant supplies that hook; all 26 exact-signature methods then
dispatch once through the base view with original arguments and return handles.
That control does not pass the listed-only constructor premise, install a new
global service or certify any builtin facility algorithm. Expectations were
derived before Apache-source diagnosis; no extra IEEE requirement is invented.

Default core-service construction, legal extension and base ancestry match.
Selected core/root/report-object handles agree and retain a real concrete
child's live state. Core seeding starts enabled and shares changes with two
object classes. Core disable preserves two renamed object RNGs and the calling
process state; three later random payloads match independently seeded references.
No random number or serialized state format is prescribed.

Core ready-to-end maximum changes to seven/nine do not reach the phase default
or new node: they retain twenty. In real main phasing, a core-selected maximum
of three still gives twenty ready callbacks. Explicit per-node state remains
separate. The final delayed-drop count is diagnostic only. The root probe's
initial direct abstract-component construction is corrected to a concrete
extension, and all edited/tagged inputs are remeasured. Prior inputs and
ordinary/compiler/guest/backend records remain unchanged.

Core-service auditing adds 74 bilingual AI duties and two individually read
structural headings. Fourteen previously unassessed identifiers become twelve
partial decompositions and those two assessments. Annex F is 72 partial,
16 assessed and 49 unassessed, with 163 drafts and 89 primary tests (60 simulation,
29 elaboration). Global state is 1831 partial/390 assessed/286 unassessed
(268 structural/122 contextual). All original milestone targets remain open.

All 3381 duties have direct tests; 1916 tests have direct links, fourteen others
have only controls and 57 have control links. The new extra-hook control does
not certify the listed-only complete service or builtin algorithms. Each of the
26 negative inputs implements that hook solely to isolate its selected pure
declaration. No test or duty is left unlinked. All 3307 previous duties,
388 assessments and 1895 indexed inputs/ordinary records remain unchanged;
the previous 60 compiler records remain unchanged within the new 87-case set.
No scope/denominator approval, human review or completion is claimed.

The final suite is 1930 (1843 simulation/87 elaboration): M1 801 (727/74),
M2 547 (542/5), M3 582 (574/8). Ordinary evidence is 1653 pass (1569 runtime
at seeds 1/73 and 84 expected compiler rejections), 277 known (208 seed-1
runtime, 66 legal builds, three illegal acceptances). All 1895 prior ordinary
inputs/records and 60 compiler records are preserved, as are guest 1083,
HDL eleven and command-line eighteen records. Guest-unmeasured is 847
(760 simulation/87 elaboration): 845 additions and two revised original inputs.
One new input is control-only; the suite has fourteen control-only tests and
57 control-linked tests. Library integrity, 110 tool tests, metadata/ledger/index,
raw/evidence and paired-doc checks pass. Goal iteration 36 reduces unassessed
from the initial 1463 to 286, a decrease of 1177. Completion remains unproven.

## Sixty-fifth thin-area expansion: typed fields and operation flags

Based on [80a8bdf](https://github.com/kurochan001/kirimasim-uvm-tests/commit/80a8bdf631334668107f42328acd6af395d69fe7); 2026-11-05 JST. Forty-two M1 inputs add 37 two-seed runtime matches and one expected
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

The final suite is 1972 (1884 simulation/88 elaboration): M1 843 (768/75),
M2 547 (542/5), M3 582 (574/8). Ordinary evidence is 1691 pass (1606 runtime
at seeds 1/73 and 85 expected compiler rejections), 281 known (209 seed-1
runtime, 69 legal builds, three illegal acceptances). All 1930 prior ordinary
inputs/records and 87 compiler records are preserved, as are guest 1083,
HDL eleven and command-line eighteen records. Guest-unmeasured is 889
(801 simulation/88 elaboration): 887 additions and two revised original inputs.
Four new inputs are control-only; the suite has eighteen control-only tests
and 61 control-linked tests. Library integrity, 110 tool tests, metadata/ledger/
index, raw/evidence and paired-doc checks pass. Goal iteration 37 reduces
unassessed from the initial 1463 to 241, a decrease of 1222. Completion remains
unproven; no human review or denominator approval is invented.

## Sixty-sixth thin-area expansion: field access and callbacks

Based on [f827d1e](https://github.com/kurochan001/kirimasim-uvm-tests/commit/f827d1e9922e5b1cb4d58318a257370b617c8057); 2026-11-05 JST. 36 M3 inputs add 31 runtime matches at seeds 1/73 and 5 retained seed-1
differences without seed 73. They cover field/callback construction, constrained
public value, configured randomization modes, pending state, actual read/write
hooks, callback enable/delete, selected backdoor slices and mirror check gates.
The 2 explicit second-map controls and standalone read-only poke also have
direct duties; no new input is control-only.

Containing-register write/read traces expect RCFDBcrdf but observe FDRCBcrdf:
field pre hooks precede register pre hooks. Separate post observations match
crdf, while the complete inputs retain the order differences. Field pre-read
and pre-write map changes still use provider A; explicit initial map B controls
match. Independent original route buffers distinguish providers without
claiming physical map-alias coherence or RTL protocol evidence.

Original backdoor storage uses physical neighbor nibbles B/D distinct from
model A/3. Poke deposits B39D from B75D, peek preserves storage, and selected
failure/extension checks match. A read-only write preserves the selected 75
slice but produces A753. The whole-word expectation retains a qualified
best-effort interpretation; it is not an unconditional neighbor guarantee or
an independent defect count. The following poke explicitly resets physical
storage to B75D first and matches; a standalone read-only poke also matches.

The intended reset and slice telemetry initially missed insertion into the
history fixture. The corrected final source is remeasured. A superseded
initial seed-73 log used matching physical/model neighbors and remains
archived under its old input fingerprint; it is excluded from final evidence.
Final expected order and map outcomes remain standard-derived and unchanged.

Field-access auditing adds 69 bilingual AI duties and 5 individually read
assessments: 4 structural headings and 1 contextual type-forwarding clause.
Of 22 previously unassessed identifiers, 17 receive partial decompositions
and 5 explicit classifications. Chapter 18 is 329 partial/48 assessed/79
unassessed with 717 drafts and 405 primary tests. Field 18.5 has zero unassessed
identifiers but retains partial contracts. Global state is 1893 partial/395
assessed/219 unassessed (272 structural/123 contextual). Original targets remain open.

All 3575 duties have direct tests; 1990 tests have direct links, 18 have only
controls and 64 have control links. The 3 new controls also have their own
direct duties and never pass another input's original premise. All 3506 prior
duties, 390 assessments, 1972 indexed inputs/ordinary records and 88 compiler
records remain unchanged. Scope/denominator approval, human review and complete
coverage are not established.

Totals are 2008 (1920 simulation/88 elaboration): M1 843 (768/75), M2 547
(542/5), M3 618 (610/8). Ordinary pass is 1722 (1637 runtime/85 rejections);
known is 286 (214 runtime/69 builds/3 illegal acceptances). All 1972 prior
ordinary records, 3506 duties, 390 assessments and 88 compiler records remain
unchanged. Library integrity, 110 tool tests, metadata/ledger/index, current
evidence and paired docs pass. Guest/HDL/command-line records are unchanged;
925 guest inputs remain unmeasured. Human approval and completion remain unproven.

The 925 guest-unmeasured inputs are 923 additions and 2 revised originals
(837 simulation/88 elaboration). The 88 compiler records, 11 HDL records and
18 command-line records are preserved. No new input is control-only; 3 new
direct controls raise control-linked tests to 64, with control-only still 18.
Goal iteration 38 reduces the initial 1463 unassessed identifiers to 219,
a decrease of 1244. The goal remains active; completion is unproven.

## Sixty-seventh thin-area expansion: protection and prediction callbacks

Based on [81da564](https://github.com/kurochan001/kirimasim-uvm-tests/commit/81da564f14ea16b4fac16870a817abcd236e27d0); 2026-11-05 JST. 48 M3 inputs match at runtime seeds 1/73. Predefined read-only/write-only
callback probes cover concrete base views, direct rejecting hooks, registration
on a register and both byte fields, removal with unrelated handles retained,
peer isolation, independent guard families and removal/re-add histories.
Register and lower/upper field rejection each use frontdoor/backdoor conditions.
The expected ERROR, UVM_NOT_OK, zero provider transfers and unchanged original
storage are checked without prescribing exact message IDs, text or report counts.
Permitted-direction and post-removal accesses also reach their original providers.

Read/write post-predict probes forward the exact field, previous/latest data,
kind, door and map; replacement updates selected desired/mirrored state while
the peer and original storage remain unchanged. Explicit and omitted direct
prediction use the supplied value without read/write callback delivery.
Disabling or deleting the selected callback stops its later prediction effect.
These are original frontdoor/backdoor providers, not physical HDL or a claim
that callback guards replace field access policies.

14 initial fixtures incorrectly passed a packed concatenation as the display
format. Literal format arguments correct that observation defect, preserving
all expected files. Corrected probes and all final tagged inputs are remeasured.
All 2008 prior input/evidence records and the 286 known differences remain unchanged.

Protection-callback auditing adds 70 bilingual AI duties and 2 individually
read structural Methods headings. Of 12 previously unassessed identifiers,
10 receive partial decompositions and 2 explicit classifications. Chapter 18
is 339 partial/50 assessed/67 unassessed with 785 drafts and 453 primary tests.
Callback 18.11 has zero unassessed identifiers but retains partial contracts.
Global state is 1903 partial/397 assessed/207 unassessed (274 structural/123
contextual). All original milestone targets remain open.

All 3645 duties have direct tests; 2038 tests have direct links, 18 have only
controls and 64 have control links. Every new input has a direct duty, with
no new control-only input. All 3575 prior duties, 395 assessments, 2008 indexed
inputs/ordinary records and 88 compiler records remain unchanged. No human
review, approved scope/denominator or completed coverage is asserted.

Totals are 2056 (1968 simulation/88 elaboration): M1 843 (768/75), M2 547
(542/5), M3 666 (658/8). Ordinary pass is 1770 (1685 runtime/85 rejections);
known remains 286 (214 runtime/69 builds/3 illegal acceptances). All 2008 prior
ordinary records, 3575 duties, 395 assessments and 88 compiler records remain
unchanged. Library integrity, 110 tool tests, metadata/ledger/index, current
evidence and paired docs pass. Guest/HDL/command-line records are unchanged;
973 guest inputs remain unmeasured. Human approval and completion remain unproven.

The 973 guest-unmeasured inputs are 971 additions and 2 revised originals
(885 simulation/88 elaboration). All 88 compiler, 11 HDL and 18 command-line
records remain unchanged. No new input is control-only and no new known
simulator/library difference is claimed. Goal iteration 39 reduces the initial
1463 unassessed identifiers to 207, a decrease of 1256. The goal remains active.

The previous unsharded [Check run](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/41976785278)
exceeded the configured 150-minute job limit. The current workflow partitions
the same 1770 tagged checks into 8 disjoint shards (222/222/221/221/221/221/221/221),
with at most 4 concurrent shard jobs. The exact union and absence of duplicates are
verified locally. The 17 command-line checks run once, on shard 0 before
ordinary checks. Seeds 1/73, the 85 compiler rejections, pinned dependencies
and runner fingerprints are unchanged. The existing verilator gate requires
all shards to succeed. Sharding is orchestration; local
validation does not establish a successful hosted workflow result.

A subsequent documentation review adds the bilingual [reading guide](reading-guide.md)
and short explanation/link sentences at 34 reading points across the existing
guides. The README summarizes current scope, while readers can follow the
first run, result labels, evidence identity and requirement-count distinctions
where those questions arise. The prior historical records are preserved.

## Sixty-eighth thin-area expansion: recording and scalar I/O macros

Based on [e8a6d8e](https://github.com/kurochan001/kirimasim-uvm-tests/commit/e8a6d8e1b5a955baed158d3e2bbaaab861a713ef), this increment adds 44 M1 simulations and 41 original bilingual
AI duties. Scalar directions use independent public packer APIs and a seven-bit
trailer; selected widths, values and hook observations do not fix serialized
layout. Live transaction handles support original recorder observers. Six
three-argument typed-attribute inputs retain build differences; six explicit
fourth-argument controls match and remain control-only. EnumN and direct small
record_field controls also have distinct direct duties. The printed one-argument
enum signature and default-attribute handle interpretation remain qualified.

33 new inputs match seeds 1/73; four differ at seed 1 and seven cannot build.
The original expected files are preserved. Metadata support citations and an
omitted-radix observation were corrected from IEEE, then current and final
inputs were remeasured. The pinned Apache-2.0 recorder-macro header was used
only for diagnosis after independent expectations were written.

The suite becomes 2100 (2012 simulation/88 elaboration): M1 887 (812/75),
M2 547 (542/5), M3 666 (658/8). Ordinary pass is 1803 (1718 runtime/85 compiler
rejections), with 297 known (218 runtime/76 builds/3 illegal acceptances).
All 2056 prior ordinary inputs/records, 3645 duties, 397 assessments and 88
compiler records remain unchanged. Guest/backend records are unchanged;
1017 guest inputs are unmeasured. Twenty-one identifiers receive partial
decompositions without new classifications: global 1924/397/186; annex B
102/4/38. Scope, denominator, human review and original targets remain open.

Reader guidance in all eleven language pairs is preserved and expanded with
short contextual explanations and links. Library/tool/metadata/ledger checks,
current evidence, source preservation and exact eight-shard selection are
validated locally; this does not establish a successful hosted Check result.

## Sixty-ninth thin-area expansion: traversal declarations and defaults

Based on [19c4d55](https://github.com/kurochan001/kirimasim-uvm-tests/commit/19c4d5513ad8137d0dc1f122c0bb0568adfaf743), this increment adds 33 M1 inputs (29 simulation/4 elaboration)
and 33 independent bilingual AI duties. Exact declared type/default bindings,
base/object identity, actual base constructor argument forms, inherited empty
hooks and reference-queue dispatch are observed. Builtin adapters supply the
selected tree traversal; original interface bodies do not certify a base algorithm.

26 inputs match both runtime seeds; two virtual constructions are rejected.
Three STRUCTURE-only dependent-default inputs cannot build while explicit-type
controls match. The inspected pinned declarations match the standard's dependency;
no cause is assigned. Two pure-method omission inputs are accepted without
runtime. Original expectations and diagnostics remain; final tags and order
citations are remeasured without changing bodies or helpers.

Four grouping headings and three overviews are individually assessed; fourteen
identifiers receive partial decompositions. Global state is 1938/404/165
(278 structural/126 contextual); annex F is 90/23/24 with 207 duties and 122
primary tests. F.5 has zero unassessed identifiers but remains partial.
The suite is 2133 (2041 simulation/92 elaboration): M1 920 (841/79), M2 547
(542/5), M3 666 (658/8). Ordinary pass is 1831 (1744 runtime/87 rejections),
known 302 (218 runtime/79 builds/5 illegal acceptances). All 2100 prior ordinary
records, 3686 duties, 397 assessments and 88 prior compiler records are preserved.
Guest/backend records are unchanged; 1050 guest inputs are unmeasured.

The collection macros remain open: their short packing contracts do not license
inventing a raw stream layout. No standard text/algorithm, commercial result or
simulator implementation source supplies an oracle. Paired docs and reader
guidance are preserved; local evidence, library/tool/metadata/ledger checks and
the exact eight-shard selection are verified. Hosted CI success, human review,
scope/denominator approval and goal completion remain unproven.

## Seventieth thin-area expansion: virtual-register and field queries

Based on [13e6cce](https://github.com/kurochan001/kirimasim-uvm-tests/commit/13e6cce15f930f443629dcb8e7e023c417f62952); measurements dated 2026-11-05 and 2026-11-06 JST. The 43 new M3 inputs are model-only simulations. Thirty-nine match both
seeds 1/73. Two differ at runtime seed 1 without seed 73, and two qualified
overview-base inputs cannot build and have no runtime result.

The overview names uvm_reg/uvm_reg_field as virtual abstraction bases, while
the actual class declarations name uvm_object. Literal static-base inputs
retain this conflict; object-base controls match separately. The build results
do not resolve the wording or establish unconditional implementation defects.

The eight-bit constructor profile reports one byte instead of the retained
two-byte whole-memory-location expectation; the sixty-four-bit profile matches.
Name and width duties have separate expected rows. This observes the public
constructor/getter chain without assigning the difference to the constructor.
An unrelated rights map returns RW but produces no required ERROR. The fallback
and diagnostic are split duties; a matching row does not pass the whole input.

Region queries observe unimplemented/released null and identity with the sole
reserved descriptor. Explicit relocation, element count, complete-memory-location
count, spacing, word offsets, map membership and policies are checked separately.
Byte-addressed and two-byte-word maps produce external addresses in their own
units. Shared queries use explicit maps where required; default-map selection
is a separate condition. Invalid address queries require WARNING without fixing
the returned value. Map enumeration asserts membership without queue-order or
nonempty-queue append/clear assumptions.

Field configuration splits parent, width and LSB observations, including a
memory-location crossing. Getter and RO/WO/RW policy inputs remain distinct.
No actual HDL or memory storage transfer is performed or certified. Four controls
also have direct duties, without substituting for an original qualified premise.

The virtual-query audit adds 45 bilingual AI duties, partially decomposing
21 formerly unassessed identifiers. One individually read Introspection heading
is structural. Global state is 1959 partial/405 assessed/143 unassessed
(279 structural/126 contextual). Chapter 18 is 360 partial/51 assessed/45
unassessed, with 830 duties and 496 primary simulation tests. These partial
query contracts do not complete the register-layer milestone or its conditions.

All 3764 duties have direct tests; 2152 tests have direct links, 24 have only
controls and 83 have control links. Every new input has a direct duty; four also
provide controls. All 3719 prior duties, 404 assessments, 2133 indexed inputs/
ordinary records and 92 compiler records remain unchanged. No human review,
approved scope/denominator or completed coverage is asserted.

Totals are 2176 (2084 simulation/92 elaboration): M1 920 (841/79), M2 547
(542/5), M3 709 (701/8). Ordinary pass is 1870 (1783 runtime/87 rejections);
known is 306 (220 runtime/81 builds/5 illegal acceptances). All 2133 prior
ordinary records, 3719 duties, 404 assessments and 92 compiler records remain
unchanged. Guest/HDL/command-line records are unchanged; 1093 guest inputs
remain unmeasured. Human approval and completion remain unproven.

Initial expectations and original sources were frozen before measurement.
Only matching inputs receive the fixed-release tag and are remeasured at both
seeds; unchanged known inputs retain their exact compatible initial records.
Input/runner/library/configuration identities are checked before assembly.
The compile-evidence set and all prior ordinary/guest/backend records remain
unchanged. Local files use `out/thin-seventieth-`; no guest rerun is claimed.
Tool, metadata, ledger/index, source/evidence, paired documentation and exact
CI selection checks accompany the increment. The goal remains active.
