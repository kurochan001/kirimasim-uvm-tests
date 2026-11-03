# Known differences

[日本語](known-differences.ja.md) · [README](../README.md) · [FAQ](faq.md)

This describes the current 1250-test suite and the pinned Accellera UVM
2020.3.1 library. A mismatch is a test result; it does not by itself assign
the cause to the simulator, the library or the expectation.

## Pinned-library limitations

The library's own `DEVIATIONS.md` lists three differences at 18.2.3.4,
18.4.3.6 and 13.1.5.1. Current register queries use explicit map arguments.
A simple memory registered on two sibling-interface maps matches 18.2.3.4 in
the pinned release. The release's multiple-map note and broader hierarchy
semantics still require review. Annex E additionally checks selected two/three-map
shared accesses and one child-block shape; see the
[memory scope](faq.md#memory-prediction-and-map-controls) and
[shared-access scope](faq.md#memory-access-shared-maps-and-test-selection).
Further limitations and observations were identified during M1, M2 and M3.
Where a test directly checks a required behavior that is missing, its
normative expectation is retained with `:oracle: spec`.

- The pinned catcher omits the standard get_report_message API (6.6.3.10).
  Three preformed-message identity/live-alias/reuse fixtures cannot build;
  their runtime expectations remain unmeasured. Private implementation fields
  are not used as substitutes.
- Individual fields on a one-byte big-endian bus are reported eligible, but
  the measured high write uses 0x21 instead of 0x20, and the low read uses
  0x20 instead of 0x21. Stored/returned data also differ. The separate
  little-endian peer matches both seeds. Configured byte-order expectations
  remain; this observation does not assign a simulator implementation cause.

- Two byte-isolated fields share a 16-bit physical word with adapter byte
  enables advertised. Clauses 18.5.5.9/.10 require individual access in this
  condition. The pinned eligibility check groups fields by the whole bus
  width, rejects both and falls back to a full-word mask. Low write replaces
  the live high byte 0xab with mirror 0x12; high read updates low mirror to
  0xcd instead of retaining 0x34. Selected return values and later writes
  still match, but those do not establish isolated access. The separate
  no-byte-enable fallback control matches both seeds. Expected individual
  access remains spec-only; no HDL DUT storage is involved.

- Heartbeat start with an omitted event while already running dereferences
  that null argument while forming a replacement-event error in the pinned
  implementation. Clause 10.6.2.6 selects the previously configured event.
  Stopped default-event reuse and an explicit same-event start both match
  before the running default call fails.
- In the Verilator/pinned condition, FIFO inline randomization reports success
  for an exact-capacity request but leaves the queue empty. Its separate
  oversized inline request is rejected as expected.
- In a separate FIFO subtype-constraint case, the exact-capacity subtype
  matches, while the subtype requesting four entries at capacity three
  reports randomization success instead of rejection. These two FIFO
  observations retain 18.8.2 expectations without assigning the cause to
  simulator or library; abstract queues establish no DUT FIFO transfer.

- Register-file get_default_hdl_path retains its initial RTL value after the
  enclosing block selects GATE and later CPU, despite no explicit file default.
  Clause 18.3.4.6 requires the nearest ancestor default in that condition.
  Explicit file overrides TLM/RTL match in the same fixture.
- A nested file's omitted-kind get_full_hdl_path query retains RTL instead of
  inheriting its flattened parent's GATE default. The retained 18.3.4.5/18.3.4.6
  expectation is net.cell; the pinned result follows dut.leaf. Explicit RTL and GATE
  flattening match. These are symbolic paths, with no HDL access claim.

- Block get_map_by_name misses the tested maps belonging to child blocks
  when they are not installed as submaps of a local map. Clause 18.1.3.13
  requires child-block search. Local name precedence and out-of-scope results
  match in the same locked fixture.
- Block get_block_by_name finds a direct child, and finds the grandchild
  when queried from that child, but misses the same simple grandchild name
  from the root. Clause 18.1.3.12 requires descendant search. The oracle uses
  only simple-name inputs, with missing/ancestor/peer controls.

- Abstract component creation with no override and a null parent dereferences
  that parent while formatting the required error. Clause 8.2.5.1.2 requires an
  error and null return; the expectation stays spec-only. The same callback
  with a concrete parent and the abstract-object case report ERROR and return
  null in separate matching controls.
- Sequence get_depth retains a previously calculated value after parent
  replacement/clearing. With no explicit set_depth call, 14.1.2.9 requires the
  current parent-chain depth. The fixture retains 3/2/1, while parent handles,
  root queries and paths update independently.

- Component automatic configuration skips custom resources in the pinned
  default name-filter mode. The explicit strict build finds them but calls
  set_local directly, without the 13.1.5.1 UVM_SET field operation. Hook order
  and suppression therefore still differ in strict mode. Expectations retain
  exact rhs dispatch and suppression; strict builds are separate conditions.
- Port relationship configuration treats a present zero-valued resource as
  enabled. Clause 5.5.2.14 requires zero to disable checking. Default absence
  and nonzero enabling match in separate observations. Only actionable reports
  are counted; a UVM_NO_ACTION report is excluded from warning emission.

- Generic `uvm_port_base::get_type_name` results omit the `uvm_` prefix
  prescribed by 5.5.2.5 for subtypes without an override.
- `set_default_index` records the index but does not redirect the tested
  blocking export calls after elaboration, contrary to 5.5.2.13.
- With the original VPI backend, the E.7 sequence reports ERROR for inaccessible
  paths and attempts HDL reads. The warning/no-transfer interpretation is
  retained; an accessible default-abstraction control matches separately.

- Register-item out-of-range value writes expand the value array rather than
  warning and ignoring the request, while out-of-range reads return zero
  without the required warning. Clause 19.1.1.2.4 requires both warnings and
  ignored writes. Separate read/write descriptors with count/count-plus-one
  indices keep erroneous allocations small and isolate missing read warnings
  from write expansion. Empty-array probes retain the same normative rules.

- The no-DPI matching fallback treats simplified-notation plus as a literal
  character. Clause F.3.3.1/Table F.1 requires one or more characters, so
  nodeXtail and nodeXYZtail must match node+tail. The normative case remains
  spec-only. Star, question and the tested literal characters match separately.
  This finding is limited to the tested no-DPI configuration; it does not
  establish POSIX-expression behavior or results with DPI enabled.

- A register order policy changes physical read order, but the pinned library
  assembles returned bytes in that execution order rather than their logical
  positions. Clause 18.4.2.4 permits reordering reads while 18.4.4.10 retains
  the register's logical value. A little-endian four-byte read observes the
  requested addresses and bytes but returns/predicts 78563412 instead of
  12345678 hex. The normative value remains spec-only.

- Component `free_tr_stream` deletes a cache entry using the stream object's
  class type name instead of the cached stream-type key. A later request
  for the same nonempty name/type pair returns the old stream. Clause
  13.1.7.10 requires a newly created stream after reference release. The
  fixture retains fresh identity and one new creation, with a separate
  cached pair left intact.

- Phase `find` returns the supplied implementation handle when the calling
  node already refers to that implementation. Clause 9.3.1.4.4 requires a
  phase-node handle. The fixture retains the exact node, with successful
  neighboring-node lookup and schedule-local missing-result controls.
- Register, memory and block `set_coverage` return the newly enabled mask.
  Clauses 18.4.7.6, 18.6.8.5 and 18.1.4.5 require the previously enabled mask.
  Two fixtures retain off-to-on, replacement and disabling return values.
  Availability filtering, peer isolation and block recursion are observed
  separately and match in the pinned run; no covergroups are measured.
- Memory sampling includes an extra location after each one-location access
  because its read/write sampling loops include the end boundary. Clause
  18.6.8.6 ties sampling to completed accesses. The fixture keeps one sample
  per one-location transfer, with separate map, direction, data and
  completion observations; it does not prescribe memory-offset geometry.

- Database `open_stream` calls `open_db` and can open a closed database
  implicitly. Clause 7.1.4.1 instead requires an ignored request and null
  unless the database is already open. The fixture keeps separate closed,
  failed-connection and successfully opened databases as independent controls.
- A fresh stream suppresses the warnings required for uninitialized
  `get_db`, `get_scope` and `get_stream_type_name` calls by 7.2.3.1–7.2.3.3.
  Its warning gate starts disabled. The fixture retains one warning for each
  query, with an initialized stream that returns valid metadata quietly.

- Event trigger dispatch calls disabled callback hooks as well as enabled
  hooks. Clause 10.7.1.2.2 disables callbacks with `callback_mode(0)`; the
  fixture preserves zero pre/post invocations while event data still updates.
- Block `get_reg_by_name` uses a full-name registry populated only by model
  locking, although 18.1.3.14 states no lock prerequisite. Ordinary local/deep
  names become available after locking, but a register nested in a regfile
  is still missed by its simple name. The fixture retains both pre/post-lock
  obligations, with successful ordinary post-lock lookups as controls.

- The required `uvm_hdl_path_concat::set_slices` and `get_slices` methods
  from 17.2.3.3.2/17.2.3.3.3 are absent. Two concat fixtures keep the
  standard calls and valid most-to-least-significant slice descriptions.
  Both cannot build with the pinned library.
- A block initializes a local RTL default instead of inheriting the nearest
  ancestor's explicitly configured HDL abstraction. The 18.1.6.9 fixture
  retains inherited GATE, a child-local RTL override and a separately
  inheriting sibling after the root changes to SYN. This is metadata
  inheritance; no HDL access is attempted.

- Empty `uvm_queue::pop_front` and `pop_back` delegate to native queue
  operations without issuing the warning required by 11.3.2.8/11.3.2.9.
  Both fixtures retain a warning per empty call, a two-state default result,
  successful refill/drain controls and a second empty call. They do not
  prescribe simulator diagnostic text.
- A memory `pre_read` callback can change the descriptor map, but the pinned
  library uses the original cached local map/frontdoor. The 18.11.2.4 fixture
  retains the selected alternate map and modified offset, with distinct
  storage in both maps and a callback-removal control.
- Memory `post_write` invokes the inherited method before registered callbacks,
  contrary to 18.6.9.2/18.11.2.3. The fixture retains callback-before-method
  order and the method's final status. Completed storage is checked separately
  from post-write descriptor edits; callback deletion restores the control.

- With no override installed, `find_override_by_name` returns `null` even
  when creation can instantiate the original type. Clause 8.3.1.7.1
  describes the wrapper of the object that would be created. The
  no-override object/component tests retain the required ordinary-creation
  wrapper; matching override-query and alias cases provide separate controls.
- The default config_db implementation looks up field names literally,
  so a configured field-name glob does not select matching names as
  described by C.4.2.2.1. The glob cases exercise scope patterns with
  literal field names.
- A nested field copied by a field macro still gets a distinct object
  under UVM_SHALLOW, while 16.6.3 describes reference treatment of nested
  objects. Matching cases cover deep field-macro copying and the configured
  copier/active-object state visible to a user hook.
- `uvm_object::get_active_policy` from 5.3.14.3 is absent. The earlier hook
  test observes the copier's active-object stack through 16.1.3. The new
  two-policy synchronization test calls the required object-side getter
  directly and retains a spec-only build difference; policy-side stack
  observations alone do not establish object-side synchronization.
- `uvm_field_op::user_hook_enabled` rejects calls before `set` and after
  `flush`, although 5.7.2.7 does not state that restriction. The field-operation
  reset test queries the bit after `set`, including after a flush/reuse cycle.
- `get_objectors` retains a source whose count has reached zero until drain
  cleanup, while 10.5.1.5.1 describes the current objecting sources. The
  immediate post-drop list case preserves the standard's expected membership
  as a spec-only test.
- `uvm_transaction::is_active` reports 1 immediately after construction,
  although 5.4.2.12 requires 0 before the first begin. The initial inactive
  state is retained as a spec-only test; matching lifecycle tests observe
  active state only after a begin or end.
- Report-handler reset leaves severity-ID overrides in place, although
  6.3.8.3 requires clearing changes made through the override methods of
  6.3.7. The count-based reset case preserves the required original
  severity as a spec-only expectation.
- `uvm_field_op::get_op_name` does not report an error before `set` or
  after `flush`, although 5.7.2.3 requires one. Both accessor-precondition
  cases keep the required error as spec-only; they also check the required
  errors from `get_op_type`, `get_policy` and `get_rhs`.
- `set_response_queue_depth` does not report an error when the new depth
  is below the queued response count, although 14.2.7.7 requires one. Two
  M2 cases retain the required error for shrinking two replies to depth one
  and one reply to depth zero. They do not assert the queue's post-error contents.
- The response-queue error-report enable bit defaults to 0, although
  14.2.7.4/14.2.7.5 require 1. Two M2 configuration cases retain the required
  default. Matching overflow cases explicitly enable or disable reporting.
- USER arbitration skips `user_priority_arbitration` when only one sequence
  is available, although 15.3.2.3 requires the callback in that case. An M2
  case retains the required invocation as a spec-only expectation.
- Lock requests overtake earlier FIFO item requests and are granted before an
  already granted item is acknowledged. Two cases retain the ordering and
  waiting required by 15.3.2.10/14.2.5.5 and FIFO mode in F.2.4.1.
- `sequence.kill` omits `post_body` and `post_start`, which 14.2.5.11 requires.
  Bound and unbound cases retain those hooks; `do_kill`, stopped state and
  interruption of the body are observed separately.
- A default wrapper that creates a non-sequence object produces only a warning,
  instead of the error required by 15.3.5. Object and sequence-item wrapper
  cases retain the required error and absence of a default sequence start.
- `stop_sequences` leaves the root sequence's automatic starting-phase
  objection raised. Stopping is defined through kill in 15.3.2.14, so the
  drop required by 14.2.4.3 still applies. Standalone and parent/child cases
  retain zero counts; in the nested case only the child's objection is dropped.
- The `uvm_time` constructor, also used by the `uvm_tlm_time` typedef,
  defaults to the legacy alias name rather than `uvm_time` required by
  5.6.2.1. The no-argument name case retains the canonical name.
- `uvm_time::set_default_time_resolution` from 5.6.2.2 is absent; the library
  provides only the legacy `set_time_resolution` spelling. The normative API
  case cannot build. Its call is not renamed to fit the library.
- Two nonblocking pass-through initiator sockets wire their backward exports
  in the wrong direction, leaving the outer export unbound. The nested case
  retains the automatic backward-routing requirement of 12.3.5.5.4.
- The push sequencer leaves the completed request in its request FIFO.
  The next request is rejected because that FIFO is still full, violating
  the continuous request delivery of 15.6.3.3. Three cases retain ordered
  delivery and the common request/response history requirements.
- The sequence-library methods `get_selection_mode`, `set_selection_mode`,
  `get_min_random_count`, `set_min_random_count`, `get_max_random_count`,
  `set_max_random_count` and `get_num_sequences_executed` are absent.
  Clauses 14.4.4.1–14.4.4.4 require these APIs. Six cases cannot build and keep
  the standard calls instead of substituting legacy fields.
- `uvm_sequence_library::remove_sequence` silently ignores an unregistered
  type instead of issuing the warning required by 14.4.5.5. The absent-type
  case retains the warning and unchanged registered membership.
- Removing a statically registered sequence type affects only the receiving
  library instance. Clause 14.4.5.5 requires updating all instances; a case
  observes a second existing instance through public enumeration.
- FIFO `get_ap` omits notifications for `peek` and successful `try_peek`,
  although 12.2.8.1.6 includes both. Two cases retain repeated notifications
  while separately observing that peeking leaves the item queued.
- `start_item` uses FATAL for a `null` item, a non-item sequence, or missing
  sequencer context. Clause 14.2.6.2 requires ERROR and an immediate return.
  Three cases count the original severity in a catcher without changing it.
- Library-subtype construction does not populate members registered with the
  sequence-library macros, including base-library members. Four cases use
  the constructor pattern of 14.4.2 and the macros of B.3.2, without adding
  the implementation-specific initialization call.
- `finish_item` bypasses the sequence's virtual `send_request` and
  `wait_for_item_done` methods, although 14.2.6.3 requires those calls.
  Two cases observe overrides that delegate to the normal implementations.
- `finish_item` passes -1 to the sequencer's completion wait instead of the
  item's transaction ID required by 14.2.6.3. One- and two-item cases retain
  the explicit IDs while acknowledging real requests normally.
- `finish_item` omits the `null`/non-item guards and uses FATAL without an
  immediate return for missing sequencer context. Three cases retain the
  ERROR and early return required by 14.2.6.3; the faulty paths terminate on
  invalid dereference before the expected observation.
- `uvm_reg::get_field_by_name` returns `null` for configured fields before model
  locking, although 18.4.3.12 gives no lock prerequisite. The library populates
  its full-name registry only during locking. A case retains the required
  pre-lock handles and also checks successful post-lock lookup.
- Before model locking, `uvm_reg_map::get_n_bytes(UVM_HIER)` returns zero
  for a configured root map. Clause 18.2.4.5 requires its bus width without
  a lock prerequisite. A case also verifies the correct width after locking.
- `get_physical_addresses` produces the addresses but returns zero instead
  of the transfer-byte count required by 18.2.4.16. Its missing return also
  makes address-map initialization retain the local width for a wider child
  bus. The child then reports four bytes instead of the required two-byte
  effective width in 18.2.4.5 and register-address return in 18.4.3.15.
  Word-addressed and hierarchical cases retain both required widths.
- `uvm_mem::get_offset` ignores its location argument and returns only the
  memory's starting map offset. Clause 18.6.4.15 requires the specified
  location's offset. A case retains distinct offsets for locations 0, 1 and 3,
  while separately observing their correct external addresses.
- `uvm_mem::get_access` returns intrinsic RW access for a single-map memory
  even when the specified map restricts it to RO. Clause 18.6.4.6 requires
  effective access to include that restriction. The case separately retains
  the RW rights query for unshared memory specified by 18.6.4.5.
- `uvm_reg_predictor::pre_predict` can redirect the item, but the predictor
  still updates the original register handle selected before the hook.
  Clause 19.3.3.2 permits target redirection. A case changes both public
  target and value and retains the required source/target mirror states.
- Big-endian frontdoor accesses byte-swap a narrow bus beat across the full
  register-data type width, losing active bits when the beat is masked.
  The existing two-word read preserves the reconstruction required by
  18.4.4.10 and 19.1.2.3, using repeated bytes to avoid intra-word ambiguity.
  New eight-bit-bus order-policy cases also retain the required write bytes
  from 18.4.4.9 and read value from 18.4.4.10. The read combines this byte-swap
  limitation with order-dependent reconstruction; it does not isolate both
  causes independently. Policy dispatch, geometry and requested address
  order are observed separately from failed data checks.

- Register pre-write and pre-read hooks run after the field hooks. Clauses
  18.4.8.1/.3 and 18.5.6.1/.3 require the register hooks first. Two cases
  retain the required `RF` order; the library produces `FR` during otherwise
  successful bus accesses. This concerns inherited method hooks, without
  registered callback objects.

- Memory burst accesses copy UVM_BURST_READ/UVM_BURST_WRITE into the
  physical bus descriptor instead of the READ/WRITE kinds required by
  19.1.2.1. Two full-width burst cases observe every physical beat's kind
  and retain the data transfers required by 18.6.5.3/.4. Their testbench
  driver accepts the prescribed physical READ/WRITE operations.

- `uvm_vreg::get_n_bytes` rounds the declared bit width to bytes but does
  not round to whole implementing memory locations as required by
  18.9.1.2.9. The case places a 16-bit virtual register in 32-bit memory,
  retaining four bytes rather than the library's two. Location count and
  increment remain one in both the required and observed results.

- `uvm_vreg::implement` rejects a `null` memory argument even for an already
  implemented dynamic array. Clause 18.9.1.1.3 permits resizing without that
  argument while preserving memory, offset and increment. The case keeps
  that resize result and placement as its required expectation.
- `uvm_mem_region::get_virtual_registers` returns `null` for a region backing
  a virtual array because that owner is not recorded. Clause 18.12.7.2.7
  requires the implementing virtual-array handle; the case also observes
  the correct memory and successful implementation as controls.

- Standalone `uvm_vreg_field::write` runs the inherited `post_write` method
  before registered callbacks, contrary to 18.10.6.2.2 and 18.10.5.2. The
  case expects `cM` and observes `Mc`. A full parent virtual-write case checks
  the callback-before-method order as a positive control.

- A user-backdoor RC register read samples and clears storage correctly, but
  predicts the sampled value instead of zero even with auto-prediction enabled.
  The required post-read mirror follows 18.4.4.10, 18.5.4.6, 18.2.5.2,
  18.4.4.15 and 18.5.5.17. Return data and cleared storage are positive controls.

- The block memory-walk wrapper checks `NO_MEM_ACCESS_TEST` instead of the
  `NO_MEM_WALK_TEST` exclusion required by E.6.2. The case retains the required
  idle wrapper traversal, with a directly selected memory as a working control.

- The individual-memory access sequence checks `NO_MEM_ACCESS_TEST` instead
  of `NO_MEM_SHARED_ACCESS_TEST` as named by E.5.1. The required skip is retained,
  with a separately scoped peer providing a working access-path control.

- The combined access wrapper checks `NO_MEM_ACCESS_TEST` for memory traversal
  even when the block matches `NO_REG_ACCESS_TEST`. Clause E.3.3 excludes that
  block from the combined check. A case retains an idle wrapper window and
  working direct register/memory controls.
- Single-register bit bash still accesses a register containing a registered
  custom field policy, although E.2.1 says unknown policies cannot be tested.
  The case retains no accesses, with a known-RW peer as a working control.

- `pack_field_int` accepts sizes 65 and 108 without the ERROR required by
  16.5.4.9. Two cases leave the invalid packed state uninspected and use a
  fresh packer for a working 64-bit round-trip control.

- A comparer configured with `set_show_max(0)` emits individual miscompare
  reports as if zero meant unlimited. Clauses 16.3.5.1 and 16.3.3.7 specify a
  maximum with no zero-as-unlimited exception. The zero-cap case retains no
  reports, counts all three mismatches and uses a visible cap-five control.

These branches are not treated as reproduced fixed-release oracles.
Spec-only diagnostics preserve the required post-drop objector membership,
initial transaction state, severity-ID reset, field-operation name errors,
response-depth errors, response-error defaults, single-candidate USER
arbitration, lock ordering, post-kill hooks, invalid-default errors,
automatic-objection drop on stop, canonical time name/API, nested
initiator-socket routing, repeated push delivery, sequence-library APIs/removal,
FIFO peek notifications, `start_item` error severity, library subtype
construction, `finish_item` dispatch, IDs and guards, pre-lock field lookup,
map width/translation results, location-specific memory offsets and
single-map effective access, predictor redirection, big-endian frontdoor data,
order-dependent read reconstruction, register/field pre-access hook order,
physical burst-beat kinds, virtual-register byte width, omitted-memory resize, region owner queries, standalone virtual-field
post-write order, user-backdoor read-clear prediction, the block memory-walk
exclusion resource and the individual-memory access exclusion.
Matching tests avoid the other library limitations.

Two command-line suffix-query cases additionally cannot observe their passed
arguments under the current `UVM_NO_DPI` setting: the pinned library's argument
enumeration stub supplies an empty list. Their expected matches and queue
replacement remain standard-derived; this records an execution-configuration
constraint, not a demonstrated failure of the suffix-matching algorithm.

Four FIFO failed-get/peek cases retain the unchanged-output postcondition of
12.2.4.2.6/.8. The pinned run replaces the caller sentinel, while the successful
control works. The declared `output` signature and SystemVerilog 13.5 copy-out
semantics are in tension with that prose; these remain interpretation work,
not assigned simulator bugs.

Two 20-bit memory cases retain a logical-model-bit interpretation of `n_bits`
in 19.1.2.4: widths 8, 8 and 4 on an 8-bit bus. The pinned run reports 8, 8 and 8;
address, direction and declared data checks still match. The 24-bit/16-bit-bus
controls report the expected byte-aligned widths 16 and 8. Sub-byte logical
width versus rounded physical-byte width needs review; no confirmed library
bug is assigned from these two cases. See [partial transfers](faq.md#error-contracts-and-partial-transfers).

The database stream-enumeration fixture retains the queue-size return
postcondition of 7.1.4.2. Two streams populate the returned queue correctly,
but the function returns zero; one stream returns one. The printed
`function unsigned` signature is an implicit one-bit logic return under
SystemVerilog 13.4, so it cannot represent a count of two. The expected two
preserves the prose interpretation. This signature/prose conflict requires
review and is not assigned as a confirmed simulator or library bug.

Across the suite, 1113 tests have the `verilator@5.052` oracle tag and 137
cases are spec-only. One of the spec-only cases checks 9.6: a child's pre-reset
task must be killed when that phase ends, but the pinned-library run on Verilator 5.052
lets the child perform its delayed write during a later phase. The cause of
this combined simulator/library difference remains unassigned.

A wakeup reset case establishes one trigger waiter and one persistent-trigger
waiter before calling `reset(1)`. Clause 10.1.1.2.8 requires both to wake
without callbacks. The pinned Verilator run reaches the blocked-state
observation, then its watchdog expires. This combined simulator/library
cause remains unassigned; the normative wakeup expectation is retained.

The 137 spec-only tests retain their normative expected files.
Default Verilator runs and CI select the 1113 tagged cases. `--all` includes
spec-only cases and records mismatches or build failures as `known`.
The ordinary runtime records for 116 cases establish their first difference
at seed 1, without seed 73 results. Thirteen missing-API builds have no ordinary
runtime seed result: one time API, six sequence-library cases, two HDL slice
cases, one object active-policy case and three catcher message-handle cases.
Eight HDL-DPI fixtures also cannot
link in the ordinary runner. Their separate VPI condition matches seven at
both seeds and fails the E.7 warning/no-transfer expectation at seed 1.
These overlapping configurations are not summed.

## Spec-only tests

These are the 137 current spec-only cases. Several exercise the same
limitation, so their count is not a count of distinct bugs.

- [Explicit HDL abstraction selection](../tests/uE/test_hdl_path_sequence_uses_an_explicit_abstraction_instead_of_the_invalid_default.sv).
- [Empty abstraction list uses the block default](../tests/uE/test_hdl_path_sequence_uses_the_block_default_abstraction_when_the_list_is_empty.sv).
- [Explicit zero force_time delegates to deposit](../tests/u19/test_hdl_force_time_explicit_zero_time_delegates_to_deposit_without_force_or_release.sv).
- [Default force_time delegates to deposit](../tests/u19/test_hdl_force_time_default_time_delegates_to_deposit_without_force_or_release.sv).

- [port base preserves names parents and each interface role](../tests/u05/test_port_base_preserves_names_parents_and_each_interface_role.sv).
- [blocking export default index switches the selected implementation after elaboration](../tests/u12/test_blocking_export_default_index_switches_the_selected_implementation_after_elaboration.sv).
- [hdl deposit sets only the selected variable and reports missing paths](../tests/u19/test_hdl_deposit_sets_only_the_selected_variable_and_reports_missing_paths.sv).
- [hdl path sequence warns for inaccessible register paths without storage access](../tests/uE/test_hdl_path_sequence_warns_for_inaccessible_register_paths_without_storage_access.sv).
- [hdl read returns actual wide storage without modifying either variable](../tests/u19/test_hdl_read_returns_actual_wide_storage_without_modifying_either_variable.sv).
- [hdl path sequence accepts an accessible default abstraction without advancing time](../tests/uE/test_hdl_path_sequence_accepts_an_accessible_default_abstraction_without_advancing_time.sv).

- [Policy/object active-policy push/pop synchronization](../tests/u16/test_policy_object_stack_tracks_nested_active_policy_push_and_pop.sv).

- [Register-item invalid value indices](../tests/u19/test_reg_item_invalid_value_indices_warn_without_changing_existing_data.sv).

- [Simplified plus one-or-more matching](../tests/uF/test_is_match_plus_requires_at_least_one_character.sv).

- [Reordered little-endian read reconstruction](../tests/u18/test_reg_order_policy_little_endian_read_uses_requested_bus_order.sv).
- [Big-endian ordered write bytes](../tests/u18/test_reg_order_policy_big_endian_write_uses_requested_bus_order.sv).
- [Big-endian ordered read value](../tests/u18/test_reg_order_policy_big_endian_read_uses_requested_bus_order.sv).

- [Component stream reference release creates a fresh stream](../tests/u13/test_component_free_recording_stream_invalidates_only_its_cached_pair.sv).

- [Phase implementation lookup returns a node](../tests/u09/test_phase_implementation_lookup_stays_within_each_local_schedule.sv).
- [Register/memory coverage previous-mask return](../tests/u18/test_coverage_register_and_memory_controls_return_the_previously_enabled_models.sv).
- [Block coverage previous-mask return](../tests/u18/test_coverage_block_control_recurses_through_nested_models_and_preserves_peer.sv).
- [Memory sampling per completed location](../tests/u18/test_coverage_memory_sampling_observes_completed_reads_and_writes_on_the_selected_map.sv).

- [Closed-database stream-open guard](../tests/u07/test_recording_database_ignores_stream_opens_until_connection_succeeds.sv).
- [Stream enumeration return count](../tests/u07/test_recording_database_stream_enumeration_is_local_and_excludes_failed_opens.sv),
  retaining the queue-size prose despite its one-bit signature conflict.
- [Uninitialized stream query warnings](../tests/u07/test_recording_uninitialized_stream_queries_each_report_a_warning.sv).

- [Disabled event callback dispatch](../tests/u10/test_event_disabled_callback_is_skipped_and_can_be_reenabled_for_later_triggers.sv).
- [Wakeup reset with both event wait styles](../tests/u10/test_event_reset_with_wakeup_releases_both_wait_styles_without_callback_dispatch.sv),
  whose simulator/library cause remains unassigned.
- [Block register simple-name lookup before/after model locking](../tests/u18/test_block_register_name_lookup_prefers_local_scope_and_finds_descendants.sv).

- Required HDL concat APIs:
  [set/readback](../tests/u17/test_hdl_concat_standard_set_slices_initializes_a_split_register_description.sv)
  and [append/readback](../tests/u17/test_hdl_concat_standard_get_slices_returns_the_appended_most_to_least_order.sv).
- [Nearest-ancestor default HDL abstraction](../tests/u18/test_block_hdl_default_abstraction_inherits_from_the_nearest_configured_ancestor.sv).

- Empty queue pop warnings:
  [front](../tests/u11/test_queue_empty_pop_front_warns_returns_default_and_allows_refill.sv)
  and [back](../tests/u11/test_queue_empty_pop_back_warns_returns_default_and_allows_refill.sv).
- [Memory pre-read map/offset redirection](../tests/u18/test_mem_registered_pre_read_callback_redirects_the_offset_and_map_before_transfer.sv).
- [Memory post-write callback order and final status](../tests/u18/test_mem_post_write_callback_precedes_final_status_hook_without_rewriting_storage.sv).

- Field-operation accessor errors:
  [before set](../tests/u05/test_field_op_accessors_report_errors_before_set.sv)
  and [after flush](../tests/u05/test_field_op_accessors_report_errors_after_flush.sv).
- [Transaction initially inactive](../tests/u05/test_transaction_is_inactive_before_first_begin.sv).
- [Report-handler severity-ID reset](../tests/u06/test_report_handler_reset_clears_pair_severity_override.sv).
- [Phase termination of a remaining child task](../tests/u09/test_task_phase_kills_remaining_child_task.sv),
  whose simulator/library cause remains unassigned.
- [Immediate removal from the objector list](../tests/u10/test_objection_objectors_list_removes_dropped_source.sv).
- Response-error enable defaults:
  [documented defaults](../tests/u14/test_sequence_response_controls_have_documented_defaults.sv)
  and [an untouched second instance](../tests/u14/test_sequence_response_control_updates_are_per_instance.sv).
- Response-depth shrink errors:
  [two replies to depth one](../tests/u14/test_sequence_response_depth_shrink_below_two_replies_reports_error.sv)
  and [one reply to depth zero](../tests/u14/test_sequence_response_depth_shrink_to_zero_with_one_reply_reports_error.sv).
- [USER arbitration with one candidate](../tests/u15/test_sequencer_user_arbitration_calls_override_with_one_candidate.sv).
- Lock grant ordering:
  [wait for the granted item](../tests/u15/test_sequencer_lock_waits_until_previously_granted_item_completes.sv)
  and [respect the earlier FIFO request](../tests/u15/test_sequencer_fifo_lock_does_not_overtake_earlier_pending_item.sv).
- Required post-kill hooks:
  [bound sequence](../tests/u14/test_sequence_kill_executes_required_post_hooks_when_bound.sv)
  and [unbound sequence](../tests/u14/test_sequence_kill_executes_required_post_hooks_when_unbound.sv).
- Invalid-default errors:
  [object wrapper](../tests/u15/test_default_sequence_rejects_object_wrapper_with_required_error.sv)
  and [sequence-item wrapper](../tests/u15/test_default_sequence_rejects_sequence_item_wrapper_with_required_error.sv).
- Automatic-objection drop on stop:
  [standalone sequence](../tests/u15/test_stop_sequences_drops_automatic_objection_for_active_sequence.sv)
  and [parent/child sequences](../tests/u15/test_stop_sequences_drops_automatic_objection_for_parent_and_child.sv).
- Canonical time name and API:
  [default name](../tests/u12/test_tlm2_time_default_constructor_uses_canonical_type_name.sv)
  and [default-resolution API](../tests/u12/test_tlm2_time_standard_default_resolution_api_constructs_delay.sv).
  The latter cannot build.
- [Nested pass-through initiator backward routing](../tests/u12/test_tlm2_nested_passthrough_initiators_route_both_directions.sv).
- Repeated push requests:
  [ordered delivery](../tests/u15/test_push_sequencer_delivers_each_request_once_in_sequence_order.sv),
  [request history](../tests/u15/test_push_sequencer_common_request_history_keeps_newest_handles.sv)
  and [response history](../tests/u15/test_push_sequencer_common_response_history_counts_analysis_replies.sv).
- Sequence-library removal:
  [absent-type warning](../tests/u14/test_sequence_library_remove_unregistered_type_reports_warning.sv)
  and [typewide propagation](../tests/u14/test_sequence_library_remove_static_type_updates_all_existing_instances.sv).
- Missing standard sequence-library APIs (all six cannot build):
  [default mode](../tests/u14/test_sequence_library_standard_selection_mode_defaults_to_rand.sv),
  [mode updates](../tests/u14/test_sequence_library_standard_selection_mode_updates_are_per_instance.sv),
  [default bounds](../tests/u14/test_sequence_library_standard_count_bounds_default_to_ten.sv),
  [count constraint](../tests/u14/test_sequence_library_standard_count_bounds_constrain_randomized_count.sv),
  [initial execution count](../tests/u14/test_sequence_library_standard_execution_counter_starts_at_zero.sv)
  and [active/completed counts](../tests/u14/test_sequence_library_standard_execution_counter_excludes_active_child.sv).
- FIFO peek notifications:
  [blocking peek](../tests/u12/test_tlm_fifo_blocking_peek_publishes_each_observation_without_consuming.sv)
  and [nonblocking peek](../tests/u12/test_tlm_fifo_nonblocking_peek_publishes_each_success_without_consuming.sv).
- Required `start_item` ERROR reports:
  [`null` item](../tests/u14/test_sequence_start_item_null_argument_reports_error_and_returns.sv),
  [sequence argument](../tests/u14/test_sequence_start_item_sequence_argument_reports_error_and_returns.sv)
  and [missing sequencer](../tests/u14/test_sequence_start_item_without_any_sequencer_reports_error_and_returns.sv).
- Static library construction:
  [two instances](../tests/uB/test_sequence_library_macros_populate_two_constructed_instances.sv),
  [two library types](../tests/uB/test_sequence_library_macro_registers_one_sequence_with_two_library_types.sv),
  [base membership](../tests/uB/test_sequence_library_macro_subtype_inherits_base_static_membership.sv)
  and [local addition](../tests/uB/test_sequence_library_macro_membership_combines_with_local_addition_only_on_one_instance.sv).
- Required finish-item virtual dispatch:
  [submission](../tests/u14/test_sequence_finish_item_invokes_sequence_send_request_override.sv)
  and [completion waiting](../tests/u14/test_sequence_finish_item_invokes_sequence_completion_wait_override.sv).
- Finish-item completion IDs:
  [one item](../tests/u14/test_sequence_finish_item_passes_explicit_transaction_id_to_completion_wait.sv)
  and [two items](../tests/u14/test_sequence_finish_item_keeps_each_transaction_id_in_two_completion_waits.sv).
- Required finish-item input guards:
  [`null` item](../tests/u14/test_sequence_finish_item_null_input_reports_error_before_mid_do.sv),
  [sequence argument](../tests/u14/test_sequence_finish_item_sequence_input_reports_error_before_mid_do.sv)
  and [missing sequencer](../tests/u14/test_sequence_finish_item_missing_sequencer_input_reports_error_before_mid_do.sv).
- Named field lookup before model locking:
  [configured fields](../tests/u18/test_reg_named_field_lookup_works_before_and_after_model_lock.sv).
- Map widths and translation return values:
  [pre-lock width](../tests/u18/test_reg_map_byte_addressing_reports_width_before_and_after_lock.sv),
  [word-address translation](../tests/u18/test_reg_map_word_addressing_translates_offsets_in_bus_units.sv)
  and [hierarchical width](../tests/u18/test_reg_submap_uses_root_base_and_narrowest_bus_width.sv).
- Location-specific memory offsets:
  [locations 0, 1 and 3](../tests/u18/test_mem_location_offsets_include_the_location_index_stride.sv).
- Single-map memory access restrictions:
  [intrinsic policy and restricted view](../tests/u18/test_mem_intrinsic_readonly_policy_and_map_rights_are_distinct.sv).
- Predictor target redirection:
  [modified target and value](../tests/u19/test_reg_predictor_pre_predict_redirects_the_target_and_modified_value.sv).
- Big-endian frontdoor read reconstruction:
  [two bus words](../tests/u18/test_reg_frontdoor_big_endian_wide_read_preserves_returned_bus_words.sv).

- Register hooks before field hooks:
  [pre-write](../tests/u18/test_reg_pre_write_hook_precedes_the_containing_fields_hook.sv)
  and [pre-read](../tests/u18/test_reg_pre_read_hook_precedes_the_containing_fields_hook.sv).

- Physical memory burst-beat kinds and transfers:
  [write](../tests/u18/test_mem_frontdoor_burst_write_advances_full_width_locations.sv)
  and [read](../tests/u18/test_mem_frontdoor_burst_read_fills_full_width_array_in_location_order.sv).

- Virtual-register width rounded to its implementing memory:
  [narrow virtual register in wider memory](../tests/u18/test_vreg_byte_width_rounds_up_to_the_implementing_memory_location_width.sv).

- Dynamic virtual resize without a memory argument:
  [preserved placement](../tests/u18/test_vreg_dynamic_resize_without_memory_preserves_placement.sv).
- Implementing region's virtual-array owner:
  [owner and memory handles](../tests/u18/test_vreg_implementation_region_identifies_its_virtual_register_array.sv).

- Standalone virtual-field post-write callback order:
  [callback before method](../tests/u18/test_vreg_field_standalone_post_write_callback_precedes_its_inherited_method.sv).

- User-backdoor read-clear prediction:
  [sample, clear and post-read mirror](../tests/u19/test_reg_user_backdoor_read_applies_read_clear_after_sampling.sv).

- Block-scoped memory-walk exclusion:
  [skip wrapper, run direct control](../tests/uE/test_memory_walk_sequence_honors_a_block_specific_walk_exclusion.sv).

- Individual-memory access exclusion:
  [specified shared-access resource and peer control](../tests/uE/test_single_memory_access_sequence_honors_its_shared_access_exclusion_resource.sv).

- Combined access block exclusion:
  [idle wrapper and direct register/memory controls](../tests/uE/test_combined_access_wrapper_honors_block_exclusion_with_direct_controls.sv).
- Unknown-policy bit-bash skip:
  [registered custom policy and known-RW peer](../tests/uE/test_single_bit_bash_sequence_skips_user_defined_unknown_policy.sv).
- Command-line suffix collection under `UVM_NO_DPI`:
  [multiple matching suffixes](../tests/uG/test_command_arg_values_collect_matching_suffixes_without_stale_entries.sv)
  and [missing/repeated queries](../tests/uG/test_command_arg_values_clear_on_no_match_and_repeat_without_appending.sv).

- Required oversize integral-pack ERROR:
  [65 bits](../tests/u16/test_packer_integral_size_65_reports_error_before_independent_boundary_control.sv)
  and [108 bits](../tests/u16/test_packer_integral_size_128_reports_error_before_independent_boundary_control.sv).
- Unavailable FIFO output preservation (signature/prose interpretation):
  [value get](../tests/u12/test_tlm_fifo_failed_try_get_preserves_two_state_value_before_success.sv),
  [handle get](../tests/u12/test_tlm_fifo_failed_try_get_preserves_object_handle_before_success.sv),
  [value peek](../tests/u12/test_tlm_fifo_failed_try_peek_preserves_two_state_value_before_success.sv)
  and [handle peek](../tests/u12/test_tlm_fifo_failed_try_peek_preserves_object_handle_before_success.sv).
- Sub-byte logical-width interpretation:
  [20-bit write](../tests/u18/test_mem_frontdoor_twenty_bit_write_preserves_location_boundaries_and_partial_width.sv)
  and [20-bit read](../tests/u18/test_mem_frontdoor_twenty_bit_read_assembles_declared_bits_and_partial_width.sv).

- No-override name lookup:
  [object](../tests/u08/test_factory_no_override_object_queries_agree_with_ordinary_creation.sv)
  and [component](../tests/u08/test_factory_no_override_component_queries_agree_with_ordinary_creation.sv).
- Comparer zero message cap:
  [individual reports and a visible control](../tests/u16/test_comparer_zero_message_limit_suppresses_reports_before_a_visible_control.sv).
  See [output and limits](faq.md#output-limits-and-routed-observations).

Additional configuration/relationship cases:

- [default resource dispatch](../tests/u13/test_component_config_application_matches_scope_and_passes_exact_resource.sv)
- [default hook suppression](../tests/u13/test_component_config_disabled_user_hook_skips_set_local_for_one_application.sv)
- [strict resource dispatch](../tests/u13/test_component_strict_config_application_matches_scope_and_passes_exact_resource.sv)
- [strict hook suppression](../tests/u13/test_component_strict_config_disabled_user_hook_skips_set_local_for_one_application.sv)
- [zero disables relationship checks](../tests/u05/test_port_relationship_checks_default_off_and_explicit_zero_allow_remote_providers.sv)

Additional abstract-registry and depth cases:

- [parentless abstract component error/null](../tests/u08/test_abstract_component_registry_without_override_reports_error_and_returns_null.sv)
- [automatic depth after parent changes](../tests/u14/test_sequence_parent_reassignment_updates_calculated_depth_root_and_path.sv)

Additional model descendant-name cases:

- [child-block map search](../tests/u18/test_block_map_name_lookup_selects_local_maps_then_unique_descendants.sv)
- [simple descendant block search](../tests/u18/test_block_name_lookup_uses_simple_descendant_names_and_excludes_external_roots.sv)

Additional register-file abstraction cases:

- [nearest ancestor default](../tests/u18/test_regfile_default_hdl_abstraction_follows_nearest_ancestor_and_local_override.sv)
- [flattened full path with inherited kind](../tests/u18/test_flattened_regfile_omits_its_name_from_full_paths_for_each_selected_abstraction.sv)

Additional heartbeat and FIFO cases:

- [running default-event reuse](../tests/u10/test_heartbeat_default_start_reuses_its_event_while_running_and_after_stop.sv)
- [inline FIFO constraint observations](../tests/u18/test_reg_fifo_randomization_accepts_capacity_and_rejects_an_oversized_queue.sv)
- [subtype-declared FIFO bounds](../tests/u18/test_reg_fifo_capacity_constraint_applies_to_subtype_declared_queue_sizes.sv)

Additional individual-field byte-enable cases:

- [isolated field writes](../tests/u18/test_field_byte_enable_write_selects_individual_or_whole_register_access.sv)
- [isolated field reads](../tests/u18/test_field_byte_enable_read_selects_individual_or_whole_register_access.sv)

Additional message-handle and endian cases:

- [preformed message identity](../tests/u06/test_report_catcher_exposes_the_supplied_preformed_message_and_current_origin.sv)
- [live message alias](../tests/u06/test_report_catcher_message_handle_mutations_are_live_in_tail_and_caller.sv)
- [preformed message reuse](../tests/u06/test_preformed_report_reuse_rebinds_origin_and_actions_for_each_reporter.sv)
- [individual big-endian field addresses](../tests/u18/test_field_access_big_endian_respects_layout_and_physical_bus_width.sv)

## Simulator and library combinations

The suite has 1250 cases, but the kirimasim/Ghost records below cover only
1085 unchanged current-input cases. The 165 new cases are unmeasured
because prior temporary executable/profile snapshots are unavailable. Do
not treat this as a fresh full-suite guest result. See [results](results.md).

Ghost's bundled-library evidence has 207 matches and 878 failures with each
of seeds 1 and 73; the same tests fail at both seeds. The current executable
snapshot has no pinned-mode measurement. [Results and methodology](results.md)
describes the evidence assembly. Bundled results
cover the supplied library. Their mismatches do not distinguish a simulator
problem from a library problem or establish results for the locked library.
Private identity, profiles and diagnostics are not published.

The tested kirimasim executable reports `uvm_object_wrapper` as unsupported
on 1076 cases. Nine cases record `fail` earlier on missing library APIs: one time
setter, six sequence-library cases and two HDL slice cases. Neither result is a pass or evidence
of UVM execution beyond those compilation blockers.

See the [README results](../README.md#current-results) for execution scope
and the [history](history.md) for earlier measurements.
