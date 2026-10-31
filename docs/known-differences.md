# Known differences

[日本語](known-differences.ja.md) · [README](../README.md) · [FAQ](faq.md)

This describes the current 637-test suite and the pinned Accellera UVM
2020.3.1 library. A mismatch is a test result; it does not by itself assign
the cause to the simulator, the library or the expectation.

## Pinned-library limitations

The library's own `DEVIATIONS.md` lists three differences at 18.2.3.4,
18.4.3.6 and 13.1.5.1. Current register queries use explicit map arguments.
A simple memory registered on two sibling-interface maps matches 18.2.3.4 in
the pinned release. The release's multiple-map note and shared-map hierarchies
require separate review; this case establishes only its two-interface setup.
See the [memory scope](faq.md#memory-prediction-and-map-controls).
The following thirty-four additional limitations were identified during M1, M2 and M3.
Where a test directly checks a required behavior that is missing, its
normative expectation is retained with `:oracle: spec`.

- With no override installed, `find_override_by_name` returns null even
  when creation can instantiate the original type. Clause 8.3.1.7.1
  describes the wrapper of the object that would be created. The
  lookup tests install overrides; alias tests inspect created objects.
- The default config_db implementation looks up field names literally,
  so a configured field-name glob does not select matching names as
  described by C.4.2.2.1. The glob cases exercise scope patterns with
  literal field names.
- A nested field copied by a field macro still gets a distinct object
  under UVM_SHALLOW, while 16.6.3 describes reference treatment of nested
  objects. Matching cases cover deep field-macro copying and the configured
  copier/active-object state visible to a user hook.
- `uvm_object::get_active_policy` from 5.3.14.3 is absent. The hook test
  observes the copier's active-object stack through the APIs of 16.1.3.
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
- `start_item` uses FATAL for a null item, a non-item sequence, or missing
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
- `finish_item` omits the null/non-item guards and uses FATAL without an
  immediate return for missing sequencer context. Three cases retain the
  ERROR and early return required by 14.2.6.3; the faulty paths terminate on
  invalid dereference before the expected observation.
- `uvm_reg::get_field_by_name` returns null for configured fields before model
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
single-map effective access.
Matching tests avoid the other library limitations.

Across the suite, 582 tests have the `verilator@5.052` oracle tag and fifty-five
cases are spec-only. One of the spec-only cases checks 9.6: a child's pre-reset
task must be killed when that phase ends, but the pinned-library run on Verilator 5.052
lets the child perform its delayed write during a later phase. The cause of
this combined simulator/library difference remains unassigned.

The fifty-five spec-only tests retain their normative expected files.
Default Verilator runs and CI select the 582 tagged cases. `--all` includes
spec-only cases and records mismatches or build failures as `known`.
The runtime records for 48 cases establish the first difference at seed 1,
without seed 73 results. Seven missing-API cases cannot build and have no
runtime seed result: one time API and six sequence-library cases.

## Spec-only tests

These are the fifty-five current spec-only cases. Several exercise the same
limitation, so their count is not a count of distinct bugs.

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
  [null item](../tests/u14/test_sequence_start_item_null_argument_reports_error_and_returns.sv),
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
  [null item](../tests/u14/test_sequence_finish_item_null_input_reports_error_before_mid_do.sv),
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

## Simulator and library combinations

Ghost's bundled-library runs have 134 matches and 503 failures with each of
seeds 1 and 73. All 637 cases were rerun after an executable fingerprint
change, using an executable/profile snapshot; the same tests fail at both
seeds. Earlier pinned-library smoke runs differed, including with
preprocessing enabled; the sampled build has no pinned-mode measurement.
Bundled results do not
establish whether the cause lies in the simulator or its supplied library,
and are not evidence for the locked library. Private identity, profiles and
diagnostics are not published.

The tested kirimasim executable reports `uvm_object_wrapper` as unsupported
on 630 cases. Seven cases fail earlier on missing library APIs: one time
setter and six sequence-library cases. Neither result is a pass or evidence
of UVM execution beyond those compilation blockers.

See the [README results](../README.md#current-results) for execution scope
and the [history](history.md) for earlier measurements.
