# Known differences

[日本語](known-differences.ja.md) · [README](../README.md) · [FAQ](faq.md)

This describes the current 421-test suite and the pinned Accellera UVM
2020.3.1 library. A mismatch is a test result; it does not by itself assign
the cause to the simulator, the library or the expectation.

## Pinned-library limitations

The library's own `DEVIATIONS.md` lists three differences at 18.2.3.4,
18.4.3.6 and 13.1.5.1. Current matching scenarios avoid those branches.
The following sixteen additional limitations were identified during M1 and M2.
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

These branches are not treated as reproduced fixed-release oracles.
Spec-only diagnostics preserve the required post-drop objector membership,
initial transaction state, severity-ID reset, field-operation name errors,
response-depth errors, response-error defaults, single-candidate USER
arbitration, lock ordering, post-kill hooks, invalid-default errors and
automatic-objection drop on stop.
Matching tests avoid the other library limitations.

Across the suite, 402 tests have the `verilator@5.052` oracle tag and nineteen
cases are spec-only. One of the spec-only cases checks 9.6: a child's pre-reset
task must be killed when that phase ends, but the pinned-library run on Verilator 5.052
lets the child perform its delayed write during a later phase. The cause of
this combined simulator/library difference remains unassigned.

The nineteen spec-only tests retain their normative expected files.
Default Verilator runs and CI select the 402 tagged cases. An explicit run
with `--all` includes the nineteen spec-only cases and records them as `known`.
The runner stops each test at its first differing seed; their current
Verilator records establish seed 1 differences, without claiming a seed 73
result for those nineteen tests.

## Spec-only tests

These are the nineteen current spec-only cases. Several exercise the same
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

## Simulator and library combinations

Ghost's bundled-library runs have 98 matches and 323 failures with each of
seeds 1 and 73. The same tests fail at both seeds. Its pinned-library smoke
test differs, including with preprocessing enabled. Bundled results do not
establish whether the cause lies in the simulator or its supplied library,
and are not evidence for the locked library. Private identity, profiles and
diagnostics are not published.

The tested kirimasim executable reports `uvm_object_wrapper` as unsupported
on all 421 cases. These results are not passes or proof of later UVM behavior;
the common compilation dependency blocks those observations.

See the [README results](../README.md#current-results) for execution scope
and the [history](history.md) for earlier measurements.
