# Known differences

[日本語](known-differences.ja.md) · [README](../README.md) · [FAQ](faq.md)

To locate a result's source, search this page for the filename portion of its test ID, then use [Trace a difference](reading-guide.md#trace-a-difference) to inspect its metadata, expected file and failure condition.

A difference belongs to a particular simulator/library/input condition, and [the status definitions](faq.md#q5-what-do-pass-fail-known-and-unsupported-mean) explain how it appears in runner output.

This describes the current 2731-test suite and the pinned Accellera UVM
2020.3.1 library. A mismatch is a test result; it does not by itself assign
the cause to the simulator, the library or the expectation.

For the size of a difference set, read [the measured breakdown](results.md#interpretation); use [library notes](known-differences.md#pinned-library-limitations), [the grouped source list](known-differences.md#spec-only-tests) and [simulator/library conditions](known-differences.md#simulator-and-library-combinations) to investigate a particular input.

Individual source links appear in the topic explanations and [grouped list](#spec-only-tests); [the test format guide](testing.md#test-format) explains how to read their metadata, expected observations and execution conditions.

The word `control` in a fixture name does not describe a runner status, so read [the direct/control distinction](requirements.md#citations-requirements-and-execution-evidence) before comparing its premise and result with the original case.

Eight new standard register-path views stop at missing get_slices; explicit member-view controls have seven matches and one mixed-default difference. Six physical inputs match both seeds separately and remain ordinary DPI-link knowns; see [the path FAQ](faq.md#register-hdl-paths-and-observation-premises).

- [test_reg_hdl_add_default_rtl_standard_view79](../tests/u18/test_reg_hdl_add_default_rtl_standard_view79.sv).
- [test_reg_hdl_add_default_rtl_member_view_control79](../tests/u18/test_reg_hdl_add_default_rtl_member_view_control79.sv).
- [test_reg_hdl_add_duplicates_copy_values_standard_view79](../tests/u18/test_reg_hdl_add_duplicates_copy_values_standard_view79.sv).
- [test_reg_hdl_add_duplicates_copy_values_member_view_control79](../tests/u18/test_reg_hdl_add_duplicates_copy_values_member_view_control79.sv).
- [test_reg_hdl_slice_defaults_append_standard_view79](../tests/u18/test_reg_hdl_slice_defaults_append_standard_view79.sv).
- [test_reg_hdl_slice_defaults_append_member_view_control79](../tests/u18/test_reg_hdl_slice_defaults_append_member_view_control79.sv).
- [test_reg_hdl_slice_first_starts_duplicate_standard_view79](../tests/u18/test_reg_hdl_slice_first_starts_duplicate_standard_view79.sv).
- [test_reg_hdl_slice_first_starts_duplicate_member_view_control79](../tests/u18/test_reg_hdl_slice_first_starts_duplicate_member_view_control79.sv).
- [test_reg_hdl_full_cartesian_default_standard_view79](../tests/u18/test_reg_hdl_full_cartesian_default_standard_view79.sv).
- [test_reg_hdl_full_cartesian_default_member_view_control79](../tests/u18/test_reg_hdl_full_cartesian_default_member_view_control79.sv).
- [test_reg_hdl_full_cartesian_custom_standard_view79](../tests/u18/test_reg_hdl_full_cartesian_custom_standard_view79.sv).
- [test_reg_hdl_full_cartesian_custom_member_view_control79](../tests/u18/test_reg_hdl_full_cartesian_custom_member_view_control79.sv).
- [test_reg_hdl_full_ancestor_defaults_standard_view79](../tests/u18/test_reg_hdl_full_ancestor_defaults_standard_view79.sv).
- [test_reg_hdl_full_ancestor_defaults_member_view_control79](../tests/u18/test_reg_hdl_full_ancestor_defaults_member_view_control79.sv).
- [test_reg_hdl_full_explicit_kind_standard_view79](../tests/u18/test_reg_hdl_full_explicit_kind_standard_view79.sv).
- [test_reg_hdl_full_explicit_kind_member_view_control79](../tests/u18/test_reg_hdl_full_explicit_kind_member_view_control79.sv).
- [test_reg_hdl_whole_vs_split_direct_read_16_79](../tests/u18/test_reg_hdl_whole_vs_split_direct_read_16_79.sv).
- [test_reg_hdl_whole_vs_split_peek_control_16_79](../tests/u18/test_reg_hdl_whole_vs_split_peek_control_16_79.sv).
- [test_reg_hdl_whole_vs_split_poke_16_79](../tests/u18/test_reg_hdl_whole_vs_split_poke_16_79.sv).
- [test_reg_hdl_whole_vs_split_direct_read_40_79](../tests/u18/test_reg_hdl_whole_vs_split_direct_read_40_79.sv).
- [test_reg_hdl_whole_vs_split_peek_control_40_79](../tests/u18/test_reg_hdl_whole_vs_split_peek_control_40_79.sv).
- [test_reg_hdl_whole_vs_split_poke_40_79](../tests/u18/test_reg_hdl_whole_vs_split_poke_40_79.sv).

Eight new positive-duration force_time inputs match both seeds under the separate HDL condition while retaining ordinary spec-only DPI-link failures; all 2283 previous ordinary records and twenty HDL records are unchanged, as explained in [the timing FAQ](faq.md#positive-duration-force_time-observations).

- [test_hdl_force_time_reg8_same_targets](../tests/u19/test_hdl_force_time_reg8_same_targets.sv).
- [test_hdl_force_time_reg8_distinct_targets](../tests/u19/test_hdl_force_time_reg8_distinct_targets.sv).
- [test_hdl_force_time_reg40_same_targets](../tests/u19/test_hdl_force_time_reg40_same_targets.sv).
- [test_hdl_force_time_reg40_distinct_targets](../tests/u19/test_hdl_force_time_reg40_distinct_targets.sv).
- [test_hdl_force_time_wire8_same_targets](../tests/u19/test_hdl_force_time_wire8_same_targets.sv).
- [test_hdl_force_time_wire8_distinct_targets](../tests/u19/test_hdl_force_time_wire8_distinct_targets.sv).
- [test_hdl_force_time_wire40_same_targets](../tests/u19/test_hdl_force_time_wire40_same_targets.sv).
- [test_hdl_force_time_wire40_distinct_targets](../tests/u19/test_hdl_force_time_wire40_distinct_targets.sv).

Nine new force/release inputs match both seeds only under the separate HDL condition and retain ordinary spec-only DPI-link failures; eleven older inputs are also remeasured after the backend change, as explained in [the HDL FAQ](faq.md#hdl-force-and-release-conditions).

- [test_hdl_force_release_reg8](../tests/u19/test_hdl_force_release_reg8.sv).
- [test_hdl_force_release_read_reg8](../tests/u19/test_hdl_force_release_read_reg8.sv).
- [test_hdl_force_release_wire8](../tests/u19/test_hdl_force_release_wire8.sv).
- [test_hdl_force_release_read_wire8](../tests/u19/test_hdl_force_release_read_wire8.sv).
- [test_hdl_force_release_reg40](../tests/u19/test_hdl_force_release_reg40.sv).
- [test_hdl_force_release_read_reg40](../tests/u19/test_hdl_force_release_read_reg40.sv).
- [test_hdl_force_release_wire40](../tests/u19/test_hdl_force_release_wire40.sv).
- [test_hdl_force_release_read_wire40](../tests/u19/test_hdl_force_release_read_wire40.sv).
- [test_hdl_force_release_failures_keep_independent_controls](../tests/u19/test_hdl_force_release_failures_keep_independent_controls.sv).

Eight new adapter parent-context inputs match both seeds while prior bus-value, callback and printer differences remain; [the parent-context FAQ](faq.md#adapter-sequence-contexts) records the explicit-caller and unspecified-do_clone boundaries.

Four tree/line default-peer inputs return type/size controls as zero instead of one; matching main visibility rows and separate explicit-peer controls do not pass those inputs. See [the emission FAQ](faq.md#printer-attributes-and-emission-controls).

- [test_printer_line_textual_columns_follow_controls_after_collection](../tests/u16/test_printer_line_textual_columns_follow_controls_after_collection.sv).
- [test_printer_line_textual_columns_follow_controls_before_collection](../tests/u16/test_printer_line_textual_columns_follow_controls_before_collection.sv).
- [test_printer_tree_textual_columns_follow_controls_after_collection](../tests/u16/test_printer_tree_textual_columns_follow_controls_after_collection.sv).
- [test_printer_tree_textual_columns_follow_controls_before_collection](../tests/u16/test_printer_tree_textual_columns_follow_controls_before_collection.sv).

Ten new policy-substitution inputs match both seeds while existing printer/copier configuration and recorder-link differences remain; [the policy FAQ](faq.md#policy-substitution-and-typed-object-streams) explains their selected conditions.

Canonical bus-operation auditing retains twelve big-endian value differences
at seed 1 without seed 73, across register/memory, read/write and three width
profiles. Single-word values show byte reversal; split profiles show zero
selected write portions or read values. Request counts and widths do not pass
a complete mismatching input. Twelve little-endian inputs match both seeds.
The original numeric-word adapter captures canonical requests before item
encoding; existing builtin TLM-byte differences remain unchanged. These results
do not assign a simulator/library cause or twelve independent defects; see
[the bus-operation FAQ](faq.md#canonical-bus-operations).

- [register read wide64](../tests/u19/test_busop_access_register_read_big_wide64.sv).
- [register read split64](../tests/u19/test_busop_access_register_read_big_split64.sv).
- [register read partial48](../tests/u19/test_busop_access_register_read_big_partial48.sv).
- [register write wide64](../tests/u19/test_busop_access_register_write_big_wide64.sv).
- [register write split64](../tests/u19/test_busop_access_register_write_big_split64.sv).
- [register write partial48](../tests/u19/test_busop_access_register_write_big_partial48.sv).
- [memory read wide64](../tests/u19/test_busop_access_memory_read_big_wide64.sv).
- [memory read split64](../tests/u19/test_busop_access_memory_read_big_split64.sv).
- [memory read partial48](../tests/u19/test_busop_access_memory_read_big_partial48.sv).
- [memory write wide64](../tests/u19/test_busop_access_memory_write_big_wide64.sv).
- [memory write split64](../tests/u19/test_busop_access_memory_write_big_split64.sv).
- [memory write partial48](../tests/u19/test_busop_access_memory_write_big_partial48.sv).

Recorder-link lifetime auditing retains six freed-endpoint runtime differences
at seed 1 without seed 73. Direct free, free after close, both endpoints freed,
open-recorder flush and owning-stream free remain separate conditions. A warning
does not satisfy ERROR/FATAL. Eight open/closed endpoint inputs match both seeds
without passing the freed-endpoint duties. No external database or post-error
recovery is inferred; see [the lifetime FAQ](faq.md#recorder-link-lifetime).

- [left recorder freed directly while right remains open](../tests/u16/test_recorder_link_window_freed_left_related.sv).
- [right recorder freed after close](../tests/u16/test_recorder_link_window_freed_closed_right_parent_child.sv).
- [both endpoints freed with retained object references](../tests/u16/test_recorder_link_window_both_freed_cause_effect.sv).
- [open left recorder freed by flush](../tests/u16/test_recorder_link_window_flushed_left_related.sv).
- [owning stream frees both endpoint recorders](../tests/u16/test_recorder_link_window_freed_stream_parent_child.sv).
- [right owning stream freed while the left stream remains open](../tests/u16/test_recorder_link_window_freed_other_stream_cause_effect.sv).

Here a qualified interpretation makes the test's reading of conflicting text explicit and leaves it open to review; [the lookup FAQ](faq.md#q281-does-dedicated-get_global-return-a-pool-or-an-item) gives an example of that limit.

Dedicated global-pool auditing retains two qualified build differences.
The printed get_global return types require pool receivers, while the prose
and generic method describe items. Item-typed existing-binding, alias/state
and bounded-wait inputs match separately; they do not pass the printed-type
premise or settle absent-key static semantics. Runtime markers in these two
declaration probes witness static admission only. No simulator/library cause
or unconditional independent defect count is assigned. See [the lookup FAQ](faq.md#dedicated-global-lookups-and-mapping-corrections).

- [event printed pool receiver](../tests/u10/test_pool_global_event_printed_pool_return_type.sv).
- [barrier printed pool receiver](../tests/u10/test_pool_global_barrier_printed_pool_return_type.sv).

Virtual-query auditing retains four differences: two qualified overview-base
builds without runtime, a narrow constructor/getter byte-width difference and
an unrelated-map missing ERROR at seed 1 without seed 73. Object-base and valid
map controls match separately. Constructor name and RW fallback observations
do not pass inputs with a differing width or missing diagnostic. The conflicting
overview/class wording and getter-chain cause remain unresolved, rather than
four independently established defects. See [the query FAQ](faq.md#virtual-register-queries-and-declaration-boundaries).

- [constructor narrow](../tests/u18/test_vreg_query_constructor_narrow.sv).
- [field overview literal base](../tests/u18/test_vreg_query_field_overview_literal_base.sv).
- [register overview literal base](../tests/u18/test_vreg_query_register_overview_literal_base.sv).
- [rights unrelated map error and rw fallback](../tests/u18/test_vreg_query_rights_unrelated_map_error_and_rw_fallback.sv).

Traversal declaration auditing retains five new differences: three
STRUCTURE-only dependent-VISITOR builds and two accepted concrete subtypes
omitting get_immediate_children or accept. None has a runtime seed result.
Explicit-type and complete-subtype controls match under distinct identities.
The pinned declarations express the standard's dependent default, so the build
diagnostics do not assign a cause. The non-virtual/pure-accept wording remains
separate. See [traversal declarations](faq.md#traversal-declarations-and-defaults).

- [Concrete adapter omitting accept](../tests/uF/test_traversal_decl_adapter_missing_accept_requires_compile_rejection.sv).
- [bottom_up with dependent VISITOR default](../tests/uF/test_traversal_decl_bottom_up_default_visitor_traverses_through_the_declared_base.sv).
- [by_level with dependent VISITOR default](../tests/uF/test_traversal_decl_by_level_default_visitor_traverses_through_the_declared_base.sv).
- [Concrete proxy omitting children](../tests/uF/test_traversal_decl_proxy_missing_children_requires_compile_rejection.sv).
- [top_down with dependent VISITOR default](../tests/uF/test_traversal_decl_top_down_default_visitor_traverses_through_the_declared_base.sv).

Recording/scalar-macro auditing adds eleven measured differences: six strict
three-argument attribute builds, one printed enum-unpack arity build, two
33-bit integer-hook runtime differences and two default-attribute runtime
differences. Runtime differences have seed 1 only; builds have no runtime.
Six extension-tolerant attribute controls, a printed enumN control and a direct
small-field API control match separately. The latter two also have direct duties.
The enum signature/prose conflict and TR_HANDLE/zero-argument accessor boundary
remain qualified interpretations; these eleven fixtures are not eleven proven
independent bugs. See [macro conditions](faq.md#recording-and-scalar-macro-conditions).

- [Typed dynamic array attribute (three arguments)](../tests/uB/test_record_macro_attribute_dynamic_array_preserves_the_original_type_and_handle.sv).
- [Default attribute on the selected recorder](../tests/uB/test_record_macro_attribute_handle_uses_the_declared_default_recorder_route.sv).
- [Typed packed struct attribute (three arguments)](../tests/uB/test_record_macro_attribute_packed_struct_preserves_the_original_type_and_handle.sv).
- [Default attribute with a peer handle](../tests/uB/test_record_macro_attribute_peer_uses_the_declared_default_recorder_route.sv).
- [Typed real attribute (three arguments)](../tests/uB/test_record_macro_attribute_real_preserves_the_original_type_and_handle.sv).
- [Typed string attribute (three arguments)](../tests/uB/test_record_macro_attribute_string_preserves_the_original_type_and_handle.sv).
- [Typed time attribute (three arguments)](../tests/uB/test_record_macro_attribute_time_preserves_the_original_type_and_handle.sv).
- [Typed wide integral attribute (three arguments)](../tests/uB/test_record_macro_attribute_wide_integral_preserves_the_original_type_and_handle.sv).
- [Small integer macro with explicit radix](../tests/uB/test_record_macro_int_33_explicit_radix_uses_the_declared_recorder_route.sv).
- [Small integer macro with omitted radix](../tests/uB/test_record_macro_int_default_radix_uses_the_declared_default_recorder_route.sv).
- [Printed one-argument enum unpack](../tests/uB/test_unpack_macro_enum_interoperates_with_an_independent_scalar_api.sv).

99 elaboration fixtures expect rejection: 36 direct abstract constructions and
63 pure-interface/const-reference/forbidden-member/type-context/non-public-constructor violations.
94 match. Subscriber/visitor/proxy/adapter omissions and direct construction
of the printed virtual builtin dispatcher remain accepted and spec-only without
runtime. These five compiler acceptances are separate from 453 known simulation
differences. Legal derived controls do not replace a required rejection.

Field-access auditing retains 5 new runtime differences at seed 1 without
seed 73. Register write/read pre hooks observe FDRC instead of the preserved
RCFD expectation; their separate crdf post observations match without passing
the complete inputs. Field pre-write/pre-read map changes still select original
provider A; explicit initial-map B controls match separately.

With physical B/D neighbors distinct from model A/3, a read-only write preserves
the selected 75 slice but changes B75D to A753. This retains a qualified
whole-word best-effort interpretation, not an unconditional neighbor guarantee.
The following poke starts from explicitly reset B75D and deposits B39D, as does
a standalone read-only poke. Corrected source telemetry is measured; a stale
initial seed-73 log belongs to its archived old fingerprint and is excluded.
These conditions do not establish an independent defect count.

- [1](../tests/u18/test_field_write_callbacks_follow_the_containing_register_and_reverse_post_hook_order.sv).
- [2](../tests/u18/test_field_read_callbacks_follow_the_containing_register_and_reverse_post_hook_order.sv).
- [3](../tests/u18/test_field_pre_write_map_propagates_through_a_real_selected_access.sv).
- [4](../tests/u18/test_field_pre_read_map_propagates_through_a_real_selected_access.sv).
- [5](../tests/u18/test_field_readonly_backdoor_write_is_protected_while_poke_deposits_as_is.sv).

Field-macro auditing retains four new differences. Three legal enum collection
inputs use collection typedef T as literally described by the printed prose;
their static/dynamic/queue builds fail without runtime. Element-enum T controls
keep the same collection properties and match, without resolving the wording
or passing the original inputs. The PACK-only input packs data but fails to
restore the selected value and count on unpack at seed 1; there is no seed 73
result. A separate explicit-UNPACK control matches the unchanged expectation.
Roundtrip and excluded-target retention do not establish all one-way packing
duties. These are measured conditions and qualified interpretations, not a
count of independently proven defects.

- [1](../tests/uB/test_field_macro_sarray_enum_copies_and_compares_values.sv).
- [2](../tests/uB/test_field_macro_array_enum_copies_and_compares_values.sv).
- [3](../tests/uB/test_field_macro_queue_enum_copies_and_compares_values.sv).
- [4](../tests/uB/test_field_macro_pack_flag_enables_unpack_and_nopack_suppresses_both_directions.sv).

Core-service auditing adds three retained differences. The listed-only complete
subclass is a legal simulation input, but its build requires the pinned
get_phase_hopper pure hook, absent from the twenty-six printed methods. The
extra-hook control matches all original dispatch observations and remains
control-only. All 26 negative omission inputs supply that hook, so each final
compiler rejection identifies only its selected printed-method omission.

The selected core limit stores seven/nine while the phase default and a new
node remain twenty. Real main readiness also repeats twenty times with the
core limit at three. These two seed-1 observations have no seed 73 run; they
are related conditions, not an asserted count of independent defects. Selected
seeding/RNG, default-constructor and live-root controls match separately.

- [1](../tests/uF/test_core_service_all_declared_methods_dispatch_through_the_abstract_base_view.sv).
- [2](../tests/uF/test_core_phase_default_limit_reaches_new_nodes_and_keeps_explicit_node_limits.sv).
- [3](../tests/uF/test_core_phase_default_limit_bounds_real_ready_to_end_reentry.sv).

Memory/FIFO auditing retains eighteen new runtime differences at seed 1,
without seed 73. Memory get_rights returns RW for an unrelated map but issues no
required warning; its other selected map-warning controls match independently.
Twelve listed-API constructor/configure-only FIFO inputs stop on null internal
field access. Diagnosis in the pinned Apache library identifies an additional
build initializer absent from the printed IEEE interface. This premise question
is qualified and remains explicit; it is not settled by a control pass.

Seven of twelve separately initialized controls match. Five retain direct-write,
external-observation, preload/repeated-update and matching-mirror differences.
Direct write produces no bus transfer despite updating abstract state. Preloaded
update duplicates two entries into four transfers; repeated update retains four
copies of its first entry. A matching public FIFO/DUT pair still reports a
comparison against internal zero. That public-queue interpretation requires
review; these eighteen inputs are not eighteen independently proven defects.
The final rejected-write control avoids a cascading empty-DUT read without
changing its expectation. All old known records remain unchanged.

- [1](../tests/u18/test_memory_rights_query_reports_a_warning_for_an_unrelated_map.sv).
- [2](../tests/u18/test_register_fifo_set_preloads_in_order_and_ignores_a_full_abstract_queue.sv).
- [3](../tests/u18/test_register_fifo_predict_updates_the_abstract_queue_for_selected_write_and_read_kinds.sv).
- [4](../tests/u18/test_register_fifo_auto_predicted_frontdoor_write_and_read_use_the_original_dut_queue.sv).
- [5](../tests/u18/test_register_fifo_external_predictor_adds_a_write_only_after_observation.sv).
- [6](../tests/u18/test_register_fifo_update_transfers_each_preloaded_value_without_duplicate_prediction.sv).
- [7](../tests/u18/test_register_fifo_repeated_update_writes_only_the_new_preload.sv).
- [8](../tests/u18/test_register_fifo_mirror_check_with_compare_enabled.sv).
- [9](../tests/u18/test_register_fifo_mirror_check_with_compare_disabled.sv).
- [10](../tests/u18/test_register_fifo_mirror_no_check_with_compare_enabled.sv).
- [11](../tests/u18/test_register_fifo_mirror_no_check_with_compare_disabled.sv).
- [12](../tests/u18/test_register_fifo_set_compare_omission_enables_checked_mismatch_reporting.sv).
- [13](../tests/u18/test_register_fifo_checked_matching_mirror_pops_the_predicted_front.sv).
- [14](../tests/u18/test_pinned_fifo_build_control_auto_predicted_transfer.sv).
- [15](../tests/u18/test_pinned_fifo_build_control_external_predictor_observation.sv).
- [16](../tests/u18/test_pinned_fifo_build_control_preloaded_update.sv).
- [17](../tests/u18/test_pinned_fifo_build_control_repeated_update.sv).
- [18](../tests/u18/test_pinned_fifo_build_control_matching_checked_mirror.sv).

Annex-C probes retain six new known inputs. Three legal mixed-type/tie/default
calls cannot find the printed typed resource-DB maximum helper. No runtime is
executed. Three runtime inputs stop at seed 1: the qualified recent-set sort
order, anchored regex alternation under no-DPI, and the printed virtual
regex/scope base calls differ. These are conditions, not six proven independent
defects. The probed equal-key list retains its original oldest-first order,
and both original regex/scope overrides receive zero calls through the base
view. Matching literal names, named/anonymous scope sets and distinct sorting
are separate fixtures; original overrides do not replace builtin algorithms.

- [typed maximum, mixed types](../tests/uC/test_resource_db_typed_highest_precedence_filters_higher_values_of_other_types.sv).
- [typed maximum, first tie](../tests/uC/test_resource_db_typed_highest_precedence_returns_the_first_matching_maximum.sv).
- [typed maximum, default object](../tests/uC/test_resource_db_default_type_selects_the_highest_object_container.sv).
- [recent-set sort](../tests/uC/test_resource_pool_sort_equal_precedence_uses_the_printed_recent_set_rule.sv).
- [regex alternation](../tests/uC/test_resource_pool_regex_alternation_filters_names_and_scopes_without_queue_order.sv).
- [virtual regex/scope dispatch](../tests/uC/test_resource_pool_regex_and_scope_methods_dispatch_through_a_base_handle.sv).

Chapter-5 probes retain seventeen new known inputs. Four legal active-policy
calls fail to build; omitted-secs decr requires an argument despite its printed
default. The twelve runtime inputs stop after seed 1: the time name is
uvm_tlm_time rather than uvm_time; generic type names are port/export/implementation
rather than their stated uvm_ forms; user_hook_enabled reports an error and zero
before first set and after flush. Recording default-on and initial-active
observations differ, four prohibited enable/disable calls generate no ERROR/FATAL,
and both recorder-route probes lack the subject callback while handle/lookup/free
controls match. Explicit-DEEP is observed as selected, so that premise is not
assumed. These are input differences, not seventeen independently proven bugs.
Corrected caller-unit scaling, explicit-seconds decrement and direct user-hook
controls are separate matches. The existing printer formal-name repair changes
one input and is remeasured with its original expected output.

- Object active-policy APIs: [1](../tests/u05/test_object_active_policy_get_uses_the_standard_public_interface.sv), [2](../tests/u05/test_object_active_policy_pop_uses_the_standard_public_interface.sv), [3](../tests/u05/test_object_active_policy_push_null_uses_the_standard_public_interface.sv), [4](../tests/u05/test_object_active_policy_lifo_uses_the_standard_public_interface.sv).
- Time decrement default: [1](../tests/u05/test_canonical_time_decrements_follow_declared_units_and_defaults.sv).
- Time default name: [1](../tests/u05/test_canonical_time_names_follow_declared_units_and_defaults.sv).
- Generic port names: [1](../tests/u05/test_port_base_declared_default_and_explicit_interface_types_preserve_hierarchy.sv).
- Initial transaction activity: [1](../tests/u05/test_transaction_disabled_recording_returns_zero_before_during_and_after_execution.sv).
- Recording default-on wording: [1](../tests/u05/test_transaction_recording_default_flag_follows_the_explicit_default_on_sentence.sv).
- Recording-control interval errors: [1](../tests/u05/test_transaction_enable_recording_reports_error_after_accept_before_end.sv), [2](../tests/u05/test_transaction_enable_recording_reports_error_after_begin_before_end.sv), [3](../tests/u05/test_transaction_disable_recording_reports_error_after_accept_before_end.sv), [4](../tests/u05/test_transaction_disable_recording_reports_error_after_begin_before_end.sv).
- Transaction subject recording: [1](../tests/u05/test_transaction_recording_handle_matches_the_open_recorder_and_clears_after_end.sv), [2](../tests/u05/test_transaction_explicit_deep_recording_links_the_selected_recorder_handle.sv).
- Field-operation hook default: [1](../tests/u05/test_field_operation_hook_enabled_before_first_set.sv), [2](../tests/u05/test_field_operation_hook_enabled_after_flush_before_next_set.sv).

The new [inherited-kind presence probe](../tests/u18/test_block_has_hdl_path_uses_nearest_explicit_ancestor_kind_without_changing_explicit_queries.sv)
retains a seed-1 difference without seed 73: child and descendant keep their
local RTL default rather than the explicitly selected nearest ancestor kind.
Explicit path-kind queries remain separate; the standard-derived inherited
oracle is unchanged. This metadata result does not establish physical HDL access.

Two new map-width fixtures stop at seed 1 without seed 73:
[empty hierarchy](../tests/u18/test_map_address_units_distinguish_bytes_and_the_printed_default_effective_word_width.sv)
and [populated hierarchy](../tests/u18/test_map_populated_word_addressing_separates_effective_bus_width_from_local_address_units.sv).
Both return local width eight instead of the root-path minimum two. They extend
applicability of the retained width difference, not an independent defect count.
The numeric word-unit expectation uses the qualified default get_n_bytes reading;
the width mismatch prevents isolating a separate unit defect. Flat-word and byte
controls remain observations within known fixtures, not whole-fixture passes.

New register conditions preserve two seed-1 runtime differences without seed 73:
[sole-map null/default selection](../tests/u18/test_register_local_map_null_uses_parent_default_even_with_one_registered_map.sv)
and [pre-lock named fields](../tests/u18/test_register_get_fields_orders_gapped_fields_by_bit_position_and_excludes_peer_handles.sv).
The ordered field list and locked control are selected observations, not whole
fixture passes. The [literal clone return probe](../tests/u18/test_map_clone_printed_implicit_return_type_supports_a_scalar_override_and_base_dispatch.sv)
cannot build: the printed implicit scalar return conflicts with the available map
return. This qualified legal-simulation declaration difference has no runtime;
it is not an expected illegal-design rejection. Public clone call/source
preservation matches, while new-map contents/rights remain partial.

Four phase simulations retain seed-1 differences without seed 73.
The domain registry's first query lacks the always-required common/uvm entries;
new custom-domain registration and retention of prior entries are separate
observations. No exactly-two-domains restriction is imposed. Premature ending
reaches the successor without a jump target but the original task keeps running.

The other two are qualified textual conflicts. get_imp's non-IMP-null sentence
contradicts its node-resolution sentence: the strict NODE-null probe differs,
while shared-implementation resolution matches. get_schedule prints a string
return yet describes a parent-node result. Its `$typename` observation is not
string even though a string receiver accepts the call. Receiver conversion is
not proof of the declared return type. Single-parent schedule-name controls
match without resolving nested hierarchy interpretation. These are reviewable
interpretation boundaries, not four independently proven library bugs.

Four new legal simulations retain type_id declaration builds without runtime.
The shared abstract-object matrix first encounters missing `uvm_transaction`
`type_id`; an independent `uvm_report_server` probe also cannot resolve it.
`uvm_subscriber` and parameterized `uvm_sequence` expose inherited base registry
specializations incompatible with the generic rule's own represented type.
The independent `uvm_sequence_base` probe matches; that does not pass the blocked
matrix or certify every builtin declaration. These four builds are not expected
compiler rejections of illegal inputs.

Two more fixtures return null for unknown object/component names and create
registered controls, but observe no required ERROR at seed 1. Seed 73 is not run.
The valid controls run before the invalid requests, so post-error registry state
is not assumed. Keep error severity and null return as separate obligations;
matching return values do not pass the whole fixtures. The active-global service control remains
a qualified reading of the single-instance overview, not a claim that only one
factory object can physically be allocated.

The [constructor-added measurement fixture](../tests/u18/test_reg_coverage_add_measurement_availability_80.sv) retains a seed-1 previous-mask
return difference without seed 73. Availability, enabled unions and absent-model
gates match, but both previous-mask flags are zero instead of one. This broadens
the earlier return-contract condition without identifying an independent defect;
[the coverage FAQ](faq.md#q312-does-a-correct-enabled-mask-pass-the-added-model-fixture)
distinguishes individual observations from a whole-case pass.

Two literal INFO equality inputs reach the execution hook and evaluate MSG at
seed 1 in both caller and explicit-context forms, with no seed 73 result. The
strict lower-than macro reading remains separate from the inclusive API rule;
this is reviewable interpretation evidence without a root-cause claim. See [the boundary FAQ](faq.md#q315-why-are-equal-verbosity-info-macro-cases-spec-only).

- [uvm_info literal INFO boundary](../tests/uB/test_report_macro_info_literal_info_boundary_81.sv).
- [uvm_info_context literal INFO boundary](../tests/uB/test_report_macro_info_context_literal_info_boundary_81.sv).

The unregistered-instance empty-delete input terminates with a null-reference
diagnostic and exit 1 at seed 1 before its post-call UT observation, without seed
73. Warning absence and root cause are not established; see [the observation limits](faq.md#q317-what-does-the-unregistered-instance-delete-difference-establish).

- [Unregistered-instance empty delete](../tests/uB/test_callback_macro_unregistered_delete_instance_82.sv).

Two size inputs retain simulation build differences without runtime: reserved+129
flag extension reports unsupported enum methods over 64 bits, and UVM_PACKER_MIN_BITS
is undefined. Reserved+17 and separate 32768-bit retention match without passing
those inputs; [the size FAQ](faq.md#size-defines-and-version-identification) separates their conditions.

- [field_flag_user_extension_129](../tests/uB/test_size_version_field_flag_user_extension_129_83.sv).
- [packer_minimum_define](../tests/uB/test_size_version_packer_minimum_define_83.sv).

Two new runtime inputs retain seed-1 differences with exit 0 and no seed 73.
The negative-ID limit filters the qualified literal NONE input; the literal kill
input matches STOPPED/kill/body rows but records zero post_body/post_start calls.
API-bound matches and existing kill differences remain distinct, without a cause
or independent-bug claim; see [the report/state FAQ](faq.md#report-enums-and-sequence-state).

- [none_negative_id_limit_literal](../tests/uF/test_enum_state_none_negative_id_limit_literal_84.sv).
- [sequence_kill_post_hooks_literal](../tests/uF/test_enum_state_sequence_kill_post_hooks_literal_84.sv).

Four actual virtual-register/field poke/peek inputs match both seeds under the
separate HDL condition while retaining ordinary unlinked-DPI build differences.
The twelve model matches do not pass those unlinked inputs; see [the backdoor FAQ](faq.md#virtual-register-backdoor-observations).

- [vreg_poke_word16](../tests/u18/test_vreg_backdoor_hdl_vreg_poke_word16_85.sv).
- [vreg_peek_word16](../tests/u18/test_vreg_backdoor_hdl_vreg_peek_word16_85.sv).
- [field_poke_word16](../tests/u18/test_vreg_backdoor_hdl_field_poke_word16_85.sv).
- [field_peek_word16](../tests/u18/test_vreg_backdoor_hdl_field_peek_word16_85.sv).

Two new qualified pre-read inputs retain seed-1 pre-order differences while
presence, data/status and post-order observations match; neither has seed 73.
The printed concrete register callback facade is rejected as abstract under the
pinned virtual declaration, without runtime; its legal subtype control matches.
The corrected standalone field input matches both seeds with coherent storage.
The initial independent-bank version is excluded as evidence of a post-status
defect, as explained in [the callback FAQ](faq.md#virtual-register-callback-contracts).

- [field_pre_read_method_order_literal](../tests/u18/test_vreg_callback_field_pre_read_method_order_literal_86.sv).
- [field_pre_read_cb_order_literal](../tests/u18/test_vreg_callback_field_pre_read_cb_order_literal_86.sv).
- [decl_register_concrete](../tests/u18/test_vreg_callback_decl_register_concrete_86.sv).

Four qualified null-setter exploratory inputs match their first five rows,
then stop at seed1 with exit1 and a null dereference; they have no seed73.
The setter does not explicitly define null-as-clear, so these are control-only
pending interpretation review, retaining original bodies/expectations. Separate
non-null matches do not pass those whole inputs or establish a mandatory removal
API or independent defect count; [Q334](faq.md#q334-does-a-null-getter-imply-that-set_frontdoornull-must-clear-it) explains the interpretation boundary.

- [reg_frontdoor_get_single_omitted](../tests/u18/test_reg_frontdoor_get_single_omitted_87.sv).
- [reg_frontdoor_get_single_explicit](../tests/u18/test_reg_frontdoor_get_single_explicit_87.sv).
- [reg_frontdoor_get_multiple_replace_first](../tests/u18/test_reg_frontdoor_get_multiple_replace_first_87.sv).
- [reg_frontdoor_get_multiple_replace_second](../tests/u18/test_reg_frontdoor_get_multiple_replace_second_87.sv).

Five original root inputs retain seed 1 exit 0 observations and their original
expectations, without seed 73. Four bare-packet inputs retain typed build refusals
without runtime. Separate positive-time, early-guard and registered-packet controls
match without passing original whole inputs or inventing an IEEE registration
prerequisite or independent defect count; see [the root/predictor FAQ](faq.md#root-completion-guards-and-predictor-checks).

- [root_finish_default_after_phases](../tests/uF/test_root_finish_default_after_phases_88.sv).
- [root_finish_reenabled_after_phases](../tests/uF/test_root_finish_reenabled_after_phases_88.sv).
- [root_guard_error_in_build](../tests/uF/test_root_guard_error_in_build_88.sv).
- [root_guard_error_in_end_of_elaboration](../tests/uF/test_root_guard_error_in_end_of_elaboration_88.sv).
- [root_extension_construction_requires_fatal](../tests/uF/test_root_extension_construction_requires_fatal_88.sv).
- [predictor_check_pending_little_1_registers](../tests/u19/test_predictor_check_pending_little_1_registers_88.sv).
- [predictor_check_pending_little_2_registers](../tests/u19/test_predictor_check_pending_little_2_registers_88.sv).
- [predictor_check_pending_big_1_registers](../tests/u19/test_predictor_check_pending_big_1_registers_88.sv).
- [predictor_check_pending_big_2_registers](../tests/u19/test_predictor_check_pending_big_2_registers_88.sv).

Five new MAM inputs retain only-preference differences at seed 1 with exit 0
and no seed 73; bounds, width, disjointness, held endpoints/membership and cleanup
match. GREEDY high-history, THRIFTY low/high and NEARBY one/two-region cases remain
separate. Lower-history GREEDY, explicit BROAD and configuration/rand-field matches
do not pass those whole inputs; [the enum/allocation FAQ](faq.md#enum-effects-and-allocation-preferences)
records the qualified history and distribution limits.

- [mam_greedy_fresh_high_history](../tests/u18/test_mam_greedy_fresh_high_history_89.sv).
- [mam_thrifty_reuse_low_history](../tests/u18/test_mam_thrifty_reuse_low_history_89.sv).
- [mam_thrifty_reuse_high_history](../tests/u18/test_mam_thrifty_reuse_high_history_89.sv).
- [mam_nearby_one_existing](../tests/u18/test_mam_nearby_one_existing_89.sv).
- [mam_nearby_two_existing](../tests/u18/test_mam_nearby_two_existing_89.sv).

Two [contradiction/repair inputs](faq.md#q342-do-policy-callback-counts-establish-a-retry-algorithm)
retain a failed-request post-hook predicate difference at seed 1 with exit 0,
without seed 73. Null, context, retained regions and later repair match.
The expected rows remain independent of observed output. Separate plain-class
diagnostics do not pass either original input or establish a default-MAM defect.

- [mam_policy_contradiction_then_repair_0](../tests/u18/test_mam_policy_contradiction_then_repair_0_90.sv).
- [mam_policy_contradiction_then_repair_1](../tests/u18/test_mam_policy_contradiction_then_repair_1_90.sv).

Three [typed-role inputs](faq.md#named-roles-wait-operators-and-topology-policies)
retain seed-1 exit-0 differences without seed 73. The shared-domain repeated-IMP
inputs fail the distinct-node/local-parent predicate under a qualified strict
local reading; separate prescoped inputs match without passing the originals. The
stable UNINITIALIZED case differs only for literal EQ/NE predicates. Scope,
state-mask meaning and unexecuted-IMP applicability remain review questions,
with no confirmed library/simulator defect attribution.

- [test_pkg_phase_kinds_0_91](../tests/uF/test_pkg_phase_kinds_0_91.sv).
- [test_pkg_phase_kinds_1_91](../tests/uF/test_pkg_phase_kinds_1_91.sv).
- [test_pkg_wait_operators_0_91](../tests/uF/test_pkg_wait_operators_0_91.sv).

Eight new standard sequence-library mode inputs retain missing setter/getter builds and no runtime result.
Six separate legacy-field controls and two default RAND inputs match both seeds without passing a standard API input.
Two original ONE_ACTIVE inputs keep first-window reports with one tracked participant and an active untracked outsider; separate no-outsider controls match.
Two explicit NO_HB_MODE inputs keep prior-mode readback and a later report under the qualified disabled interpretation; separate stop controls match, with no confirmed defect attribution or rewritten query oracle.
All four runtime differences use exit0 at seed1 and have no seed73 record; [the mode/window FAQ](faq.md#sequence-library-modes-and-heartbeat-windows) explains applicability and control roles.

- [test_heartbeat_no_hb_mode_0_92](../tests/uF/test_heartbeat_no_hb_mode_0_92.sv).
- [test_heartbeat_no_hb_mode_1_92](../tests/uF/test_heartbeat_no_hb_mode_1_92.sv).
- [test_heartbeat_one_active_0_92](../tests/uF/test_heartbeat_one_active_0_92.sv).
- [test_heartbeat_one_active_1_92](../tests/uF/test_heartbeat_one_active_1_92.sv).
- [test_library_standard_item_0_92](../tests/uF/test_library_standard_item_0_92.sv).
- [test_library_standard_item_1_92](../tests/uF/test_library_standard_item_1_92.sv).
- [test_library_standard_rand_0_92](../tests/uF/test_library_standard_rand_0_92.sv).
- [test_library_standard_rand_1_92](../tests/uF/test_library_standard_rand_1_92.sv).
- [test_library_standard_randc_0_92](../tests/uF/test_library_standard_randc_0_92.sv).
- [test_library_standard_randc_1_92](../tests/uF/test_library_standard_randc_1_92.sv).
- [test_library_standard_user_0_92](../tests/uF/test_library_standard_user_0_92.sv).
- [test_library_standard_user_1_92](../tests/uF/test_library_standard_user_1_92.sv).

Two typed real inputs retain seed-1 notation differences:the exponential fields lack an exponent, and the selected large general field also lacks it;their numeric-value predicates match.
Two separate literal-%u controls differ while the textual unsigned-decimal inputs match. This preserves both readings of the conflicting wording without passing an alternative input or assigning a confirmed defect.
All four exit 0 at seed 1 and have no seed 73 record. The original variable-format parser builds and wide-scanf false difference were observer/language conditions;current UVM inputs have fresh compatible records after neutral observer corrections, not relabeled failures.
[The radix/observer FAQ](faq.md#radix-meanings-and-observer-limits) explains those corrections and the raw-format/time/table limits.

- [test_radix_real_0_93](../tests/uF/test_radix_real_0_93.sv).
- [test_radix_real_1_93](../tests/uF/test_radix_real_1_93.sv).
- [test_radix_unsigned_literal_0_93](../tests/uF/test_radix_unsigned_literal_0_93.sv).
- [test_radix_unsigned_literal_1_93](../tests/uF/test_radix_unsigned_literal_1_93.sv).

Two bare-event macro inputs retain a seed-1 pre-copy-waiter wake with exit zero and no seed-73 record. Alias, negative-flag and other selected notification rows match, but do not pass either full case. The same wake occurs in an independent original no-UVM language probe; no library-only cause is assigned. Initial root/event helper build failures are excluded after fresh neutral corrections. See [the event-copy explanation](faq.md#q362-why-do-event-copy-inputs-remain-known-when-alias-and-flag-rows-match).

- [test_event_0_94](../tests/uB/test_event_0_94.sv).
- [test_event_1_94](../tests/uB/test_event_1_94.sv).

The collection increment adds no current known difference: thirty-two final inputs match both seeds under their declared profiles. Provisional flat/no-header dynamic/queue records were withdrawn as an overconstrained test oracle and archived; they are not UVM failures. All 418 previous known cases remain unchanged. [The collection explanation](faq.md#collection-macro-values-and-opaque-state) distinguishes this oracle correction from rewriting a valid normative expectation.



Four TLM namespace inputs retain seed-1 successful casts between same-name parameterized generated classes in different packages, where rejection is expected. Cross-suffix rejection and selected parent/routing/data observations match, but the complete cases remain known. Each exits zero and has no seed-73 record. The independent no-UVM parameterized-class probe reproduces the symptom while plain/different-name controls match; no library-only cause is assigned. [The nominal-type explanation](faq.md#q368-does-correct-routing-pass-the-nominal-type-case) records the qualification.

- [test_tlm_package_get_0_96](../tests/uB/test_tlm_package_get_0_96.sv).
- [test_tlm_package_get_1_96](../tests/uB/test_tlm_package_get_1_96.sv).
- [test_tlm_package_put_0_96](../tests/uB/test_tlm_package_put_0_96.sv).
- [test_tlm_package_put_1_96](../tests/uB/test_tlm_package_put_1_96.sv).

Two qualified component inherited-setter profiles retain seed-1 exit-0 differences after requested name changes. Initial observations, lifetime ID stability/distinctness and parent handles match; changed-name and documented full-name observations do not. Neither has a seed-73 record or fixed-release tag. The expected setter contract is not replaced by observed flags, and matching rows do not pass the whole case or establish a library-only cause. [The setter qualification](faq.md#q379-why-retain-the-component-setter-expectation-when-its-observations-differ) records the documented-override boundary.

- [test_inherited_api_component_0_99](../tests/u01/test_inherited_api_component_0_99.sv).
- [test_inherited_api_component_1_99](../tests/u01/test_inherited_api_component_1_99.sv).

The twelve new naming profiles add six whole-fixture known differences.
Four register/field traces miss the exact name before lock and match their
locked rows; field-order flags still match. Two sequence traces match earlier
paths, identities and detached path/parent-null flags, while their qualified
root-self/root-name flags differ. All six build and exit 0 at seed 1, with no
seed-73 results. These observations do not establish case folding, six distinct
bugs or a library-only cause. Expectations and prior 424 known cases are
retained; [Q388](faq.md#q388-do-the-new-profiles-prove-incorrect-case-folding)
and [Q389](faq.md#q389-how-is-the-detached-sequence-root-expectation-qualified)
explain the limits.

- [test_case_sensitive_field_0_101](../tests/u01/test_case_sensitive_field_0_101.sv).
- [test_case_sensitive_field_1_101](../tests/u01/test_case_sensitive_field_1_101.sv).
- [test_case_sensitive_register_0_101](../tests/u01/test_case_sensitive_register_0_101.sv).
- [test_case_sensitive_register_1_101](../tests/u01/test_case_sensitive_register_1_101.sv).
- [test_case_sensitive_sequence_0_101](../tests/u01/test_case_sensitive_sequence_0_101.sv).
- [test_case_sensitive_sequence_1_101](../tests/u01/test_case_sensitive_sequence_1_101.sv).

Two supporting callback-registry type controls retain simulation-build
failures at the typed assignment, without runtime. They select only a conditional
registry-below-callback interpretation; 1.4.3 permits intermediate classes in the
opposite direction too. Clarified comments replace an overbroad necessity claim,
and the current inputs are freshly built with unchanged expectations. These
failures establish neither mandatory ancestry nor a typo/contradiction or
library-only cause; [Q392](faq.md#q392-do-the-type-relation-controls-settle-the-b4-base-wording)
explains the qualification. Eight separate operational named-callback inputs
match both seeds, without passing these control-only premises.

- [test_callback_overview_base_relation_0_102](../tests/uB/test_callback_overview_base_relation_0_102.sv).
- [test_callback_overview_base_relation_1_102](../tests/uB/test_callback_overview_base_relation_1_102.sv).

Two forward static-iterator profiles retain nonnull returns after completed
additions to exhausted cursors, before the documented endpoint reset. They
build and exit 0 at seed 1; after_empty_add and after_exhausted_add differ,
while seventeen other rows match. The original null-until-reset oracle remains;
there is no seed-73 evidence or identification of the unexpected callback
handle, and no library-only cause is inferred. Six separate final tagged
endpoint/backward profiles match both seeds; [Q395](faq.md#q395-why-keep-null-after-an-exhausted-queue-grows)
and [Q396](faq.md#q396-do-seventeen-matching-rows-pass-the-forward-iterator-inputs)
explain the premise and whole-trace status.

- [test_callback_static_next_exhausted_growth_local_103](../tests/u10/test_callback_static_next_exhausted_growth_local_103.sv).
- [test_callback_static_next_exhausted_growth_typewide_103](../tests/u10/test_callback_static_next_exhausted_growth_typewide_103.sv).

Six new memory inputs retain seed-1 runtime differences with exit 0 and no
seed 73. Two sole-map access inputs return RW instead of selected RO/WO in
three rows each. Four relocation layouts retain nonzero location off/alt_off
values at the map start in ten rows each, while address/peer/unit fields
match. All original expectations remain. Four separate shared/ROM inputs
match both seeds; those matches do not clear either complete differing premise
or establish independent defect counts. The DIAG104 lookup rows are not
oracles; see [the access distinction](faq.md#q398-why-can-memory-rights-and-effective-access-differ)
and [the result limits](faq.md#q401-do-passing-shared-or-rom-controls-clear-the-other-differences).

- [test_memory_explicit_access_policy_0_104](../tests/u18/test_memory_explicit_access_policy_0_104.sv).
- [test_memory_explicit_access_policy_1_104](../tests/u18/test_memory_explicit_access_policy_1_104.sv).
- [test_memory_relocation_map_units_0_0_104](../tests/u18/test_memory_relocation_map_units_0_0_104.sv).
- [test_memory_relocation_map_units_0_1_104](../tests/u18/test_memory_relocation_map_units_0_1_104.sv).
- [test_memory_relocation_map_units_1_0_104](../tests/u18/test_memory_relocation_map_units_1_0_104.sv).
- [test_memory_relocation_map_units_1_1_104](../tests/u18/test_memory_relocation_map_units_1_1_104.sv).

Six new nested transport inputs match both seeds for additional input/ref conditions; [Q404](faq.md#q404-do-the-six-matching-profiles-complete-tlm-2-or-prove-concurrent-safety) explains why they do not clear the 440 older known inputs or socket differences.

Twelve new cancellation profiles match both seeds while the component printed-function input remains known; [Q407](faq.md#q407-do-the-task-gates-resolve-the-components-printed-function-declaration) explains that task/function boundary.

Sixteen direct-map inputs retain seed1 known differences in return width, entry stride and hierarchy conditions, including four hierarchy stops before later observations; [the direct-query FAQ](faq.md#q409-what-does-a-direct-map-query-add-beyond-register-address-queries) explains the scope. Empty/populated variants preserve the oracle and partial return widths remain investigative.

Four base-recording-disable inputs match both seeds with final tags but do not clear 458 known inputs, the printed base query-name difference or default push-recording interpretation; [the peer FAQ](faq.md#q414-why-are-peer-event-counts-diagnostic-only) distinguishes checked traffic from investigative event counts.

Four automatic-property inputs match both seeds with final tags under explicitly enabled recording storage. All 458 known inputs and the printed base query-name difference remain; [the property FAQ](faq.md#q416-what-do-the-property-profiles-add-beyond-transaction-marks) distinguishes recorded data from earlier event diagnostics.

Six event delta inputs match both seeds with final tags while all 458 known inputs remain. [The completion FAQ](faq.md#q421-do-the-six-matching-event-profiles-complete-the-clauses) explains why exact consecutive-#0 counts and delta applicability after an initially unsatisfied wait remain open.

Four cancellation/count inputs match both seeds with final tags while all 458 known inputs remain. [The reuse FAQ](faq.md#q423-why-check-onoff-waits-and-reuse-the-same-event) explains why mixed-wait and wakeup-reset differences remain under separate premises.

Two plain unpack inputs match both seeds with final tags; two observed inputs remain known at seed 1 with normal exit 0 and no seed 73. Ten other UT rows match, but both first-setter trace rows differ; [Q426](faq.md#q426-why-is-setter-order-qualified-when-field-values-match) records the qualified interpretation. All 456 old known inputs remain, giving 458 total.

- [observed empty](../tests/u12/test_payload_unpack_observed_empty_112.sv).
- [observed data](../tests/u12/test_payload_unpack_observed_data_112.sv).

## Pinned-library limitations

Pinned means the library version and content fixed by the lock file, and [the library guide](testing.md#the-uvm-library) explains how to obtain that same implementation when reproducing these limitations.

DPI connects SystemVerilog to external code, and enabling its flag does not supply a backend; see [Compiling](testing.md#compiling) when reading the missing-DPI entries.

A note marked qualified records an interpretation that still needs review; [Q18](faq.md#q18-how-should-i-report-or-correct-a-wrong-expectation) explains how to propose another reading with its clause basis.

The release's three notes are not an exhaustive list of this suite's differences; [the measured breakdown](results.md#interpretation) includes other build blockers and runtime mismatches under the recorded conditions.

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

- Two builtin constructor fixtures differ at seed 1 without seed 73:
  [single-memory access](../tests/uE/test_builtin_mem_single_access_seq_constructor_types_target.sv)
  and [single-memory walk](../tests/uE/test_builtin_mem_single_walk_seq_constructor_types_target.sv).
  Omitted names differ from the listed constructor defaults; explicit names,
  ancestry and target-storage observations are separate controls. The normative
  default strings remain unchanged. The observed names are
  `uam_mem_single_access_seq` and `uvm_mem_walk_seq`, respectively.
- [Direct builtin-dispatcher construction](../tests/uE/test_builtin_dispatcher_virtual_class_rejects_direct_construction.sv)
  is accepted despite the printed virtual declaration. No runtime is executed.
  Matching legal concrete extensions assess constructor/inheritance/model/mask
  conditions only and do not pass the rejection fixture.

- The [positive-time relevance-bound fixture](../tests/u15/test_sequencer_zero_time_relevance_limit_set_at_positive_time.sv)
  sets three at time three before its first zero-time relevance burst, but the
  notification arrives on callback five. The qualified oracle accepts three or
  four (the bound or first excess), without requiring exact severity/ID/text.
  All callbacks and the notification occur at time three; no fallback or grant
  occurs. Time-zero default/explicit/virtual-setter controls match independently.
  This is one seed-1 applicability difference without seed 73, not a proven
  private-counter defect or a recovery assertion.

- Eight new printer fixtures retain differences at seed 1 without seed 73.
  SHALLOW still visits descendants, disabled radix prefix text remains, and the
  root control defaults to zero instead of one. Table/tree indentation and
  tree/line separators keep their changed values after flush, despite the
  format-specific defaults stated for that condition. The entry-depth equality
  matrix is a qualified interpretation; a separate caller scope already above
  both tested bounds still recurses and avoids that boundary question.
  Correct intermediate observations do not make a whole fixture pass.
  - [SHALLOW recursion](../tests/u16/test_printer_recursion_modes_distinguish_deep_shallow_reference_and_default.sv)
  - [qualified entry-depth boundaries](../tests/u16/test_printer_max_depth_uses_reference_behavior_beyond_each_selected_boundary.sv)
  - [already-exceeded depth](../tests/u16/test_printer_depth_already_above_limit_uses_reference_without_touching_caller_stack.sv)
  - [disabled radix prefix](../tests/u16/test_printer_integral_values_use_selected_radix_prefix_and_honor_prefix_disabling.sv)
  - [root-name default](../tests/u16/test_printer_root_enabled_selects_full_name_or_leaf_before_policy_dispatch.sv)
  - [table indentation after flush](../tests/u16/test_printer_table_specific_controls_return_to_declared_defaults_after_flush.sv)
  - [tree controls after flush](../tests/u16/test_printer_tree_specific_controls_return_to_declared_defaults_after_flush.sv)
  - [line separators after flush](../tests/u16/test_printer_line_specific_controls_return_to_declared_defaults_after_flush.sv)

- A shared handler reset restores general/ID verbosity, action and file but
  retains the severity/ID verbosity threshold. Clause 6.3.8.3 requires default
  settings. The expected pair reset and subsequent boundary delivery stay
  unchanged; the fixture stops at seed 1 without seed 73. Its configured prefix
  matching is not a whole-fixture pass. See [shared threshold reset](../tests/u06/test_reporting_shared_reset_restores_all_threshold_keys_before_live_filtering.sv).
  Earlier severity-override reset differences remain separate inputs.

- Concrete subtypes omitting pure subscriber write or visitor visit compile
  successfully. The declarations in 13.9.3.2/F.5.1.2.3 and SystemVerilog 8.21
  require implementations for concrete construction. Both rejection oracles
  remain, with no runtime execution. The independently legal inherited
  subscriber control matches both seeds; it does not excuse an absent method.
  See [subscriber omission](../tests/u13/test_subscriber_concrete_subclass_must_implement_write.sv) and
  [visitor omission](../tests/uF/test_visitor_concrete_subclass_must_implement_visit.sv).

- Three new runtime differences retain qualified standard interpretations.
  Clauses 12.3.5.7.4/12.3.5.8.4 list nonblocking providers under blocking relay
  headings. Literal acceptance probes observe rejection for all three/two
  listed families, reporting six/four ERRORs. Separate blocking relay
  forwarding/reuse controls match. Do not silently replace the printed names
  with blocking names or treat the control as resolving the allowlists.
- A no-binding interpretation of the general same-kind terminator restriction
  expects no direct provider entry after an invalid connect. Both initiator
  kinds report ERROR yet retain an entry; target kinds report ERROR and leave
  none. A raw direct entry is distinct from a resolved executable binding.
  The standard does not explicitly define that invalid-call post-state, so
  retain this as a reviewable interpretation difference, not a proven defect.
  All three cases stop at their first difference at seed 1 without seed 73.
- Other partial wording includes the forward port described as a backward
  path and nonblocking connect signatures omitting P/parameter syntax. Exact
  class-default and custom-phase forwarding probes do not certify the literal
  printed signatures. Other abstract/invalid-derivation conditions, illegal
  user extension and full socket member ownership remain separate work.

- The bidirectional port summary in 12.2.3.3 declares RSP=int independently
  of REQ. The selected nine-family fixture overrides only REQ with string,
  then requires the exact string/int interface base. The pinned declarations
  use RSP=REQ, so the first typed argument fails to compile. All-int defaults
  and explicitly distinct packed-type transport controls match. This is one
  declaration-default build difference, not a missing API or runtime failure;
  neither seed has executed for that input. The retained oracle does not
  substitute an explicit RSP argument in the REQ-only test.

- With propagation mode zero, objection callbacks correctly skip intermediate
  components, but total queries for those ancestors return zero while their
  descendant still holds two, then one objection. Clause 10.5.1.3.2 specifies
  callback skipping; 10.5.1.5.4 still defines total as own plus descendant
  objections. Source/root totals and source/root callback routing match.
  The default-mode control matches intermediate totals, hook metadata and
  drain/callback propagation checks. The skipped-mode fixture retains its
  normative total expectation and first differs at seed 1, with no seed 73
  result. Correct routing is not counted as a whole-fixture pass.

- The raw event early/late case establishes the early call with a public
  count of one before triggering. At the next time slice that early caller
  has not resumed, although 10.1.1.2.4 requires it to return for that trigger.
  Both callers return on the second trigger; the same-slice late caller's
  fresh-trigger wait is a matching control. The combined simulator/library
  cause remains unassigned. No simulator implementation source is inspected.
- Default event reset leaves three raw/persistent/on-state callers blocked
  but reports zero waiters, contrary to the actual-process query in
  10.1.1.2.10. A later fresh trigger releases all three with the expected data.
  This is a count difference, not observed stranding. The barrier silent-reset
  control separately matches its specified zero-count/rearm behavior.
- Newly constructed event pools contain none of the begin/accept/end names
  required by 10.4.1. The fixture checks membership before get could lazily
  create them and does not require an exact pool size. Existing new-key
  growth tests remain independent of initial membership and unchanged.

- User-backdoor encode/decode callbacks run in the required order but their
  array transformations do not reach the next callback or final value path.
  Clauses 18.11.2.7/.8 require sequential propagation, reverse decoder order
  and clear data at post-read methods. A single encoder leaves stored values
  at 0x13/0x25 instead of 0x0c/0x3a; a single decoder returns encoded values
  0x0c/0x3a instead of clear 0x13/0x25. Two-callback cases additionally show
  lost intermediate values. All four first differ at seed 1, with no seed 73
  result. The
  [default callback control](../tests/u18/test_register_callback_default_encode_and_decode_leave_arrays_unchanged.sv)
  matches both seeds; it establishes only default no-change behavior. Original
  storage and two array elements are used without physical HDL or test-side
  array repair. Inspection of the pinned Apache helper explains the observed
  missing writeback; it does not supply the oracle.

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
  Clauses 14.4.4.1–14.4.4.4 require these APIs. Fourteen cases cannot build and keep
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

One sequence-reporting fixture retains the admission interpretation of
14.1.3.3: a false report-enabled query requires the four convenience methods
to return without processing. With a NONE reporter threshold, all four HIGH
queries return false, but the pinned sequence implementation admits WARNING,
ERROR and FATAL to the overridden processing method; INFO is filtered. An
at-limit control admits all four after the fixture counters are reset. No
server emission is involved. This is separate from the report-object rule
in 6.3.3.3, which ignores verbosity for non-INFO severities. The class-specific
contract and inherited behavior need review; no confirmed simulator bug is
assigned. The standard-derived sequence expectation remains spec-only.

Three additional concat cases retain standard APIs from 17.2.3.3.1–.4.
The named-constructor case supplies explicit and empty string arguments as
well as omission; the pinned concat class has no matching named constructor.
Two accessor cases check replacement, valid gaps, value-copy isolation, empty
arrays and append after replacement. Their first build failure is the missing
standard slice accessor. No legacy member or differently named method replaces
these APIs. All three are build evidence without runtime results.

Eighteen command-line fixtures explicitly request a separate VPI bridge and
pinned regex DPI. The ordinary runner does not link them and records eighteen
additional builds without runtime results. Under the separate command-line
condition seventeen match both seeds. One retains G.2.6's warning requirement
when user code tries to change a NO-locked quit limit. The limit correctly
remains seven, but the pinned server emits INFO and the warning probe sees no
warning. The YES control changes the limit to nine without a warning. This
is a diagnostic-severity difference, not failed limit enforcement. The older
two no-DPI argument cases remain unchanged ordinary runtime differences.

Memory backdoor lookup caches the inherited block handle; a later local-only
get_backdoor(0) therefore returns it under the retained local-selection oracle.
The direct user-storage access, rejection and retry controls still match within
that spec-only fixture. Coverage availability/enabling controls match, but the
memory setter returns the new mask rather than the required previous mask.
The public backdoor_read task is protected in the pinned library, so its legal
external task declaration fails to build; public backdoor_write compiles
independently. Neither declaration probe invokes a physical transfer. The three
actual-array fixtures use a separate VPI condition; ordinary builds lack DPI.
Derived inherited-task wrappers do not repair the public-read declaration.

Package reporting retains generic WARNING 200/ERROR 100 and helper WARNING
200 instead of the required NONE 0. Explicit fields and other default rows
match, but both whole fixtures remain spec-only. Callback deletion return
values match while later-handle removal changes delivery: the removed handle
still receives hooks and active-peer count predicates fail. The independent
no-deletion fixture isolates PRE_RUN: both pre hooks see INITIALIZED; post hooks
see POST_RUN. Abort has a separate matching direct-die control. No peer callback
order or missing F.2.10 post-run wording is invented for abort.

Resource name lookup omits the required warning when the default rpterr
finds no match; explicit suppression and successful filtering controls match.
Separate local/global pool cases observe assigned precedence 3/9 yet get the
first rather than maximum-precedence name match. Type queue priority matches;
those sub-observations do not pass either fixture. The local case retains its
constructor/singleton interpretation boundary independently of the global case.
A legal resource-base extension implementing the listed pure get_type_handle
cannot build because the pinned library also declares unlisted pure helpers.
The missing-standard-hook negative supplies original compatibility bodies only
to isolate the specified rejection. It does not repair that legal extension.

Across the suite, 2273 tests have the `verilator@5.052` oracle tag and 458
cases are spec-only. One of the spec-only cases checks 9.6: a child's pre-reset
task must be killed when that phase ends, but the pinned-library run on Verilator 5.052
lets the child perform its delayed write during a later phase. The cause of
this combined simulator/library difference remains unassigned.

A wakeup reset case establishes one trigger waiter and one persistent-trigger
waiter before calling `reset(1)`. Clause 10.1.1.2.8 requires both to wake
without callbacks. The pinned Verilator run reaches the blocked-state
observation, then its watchdog expires. This combined simulator/library
cause remains unassigned; the normative wakeup expectation is retained.

The 458 spec-only cases retain standard-derived expected output or compiler diagnostics.
Default Verilator runs and CI select 2273 tagged checks (2179 runtime, 94 compile rejection). `--all` includes
spec-only cases and records mismatches or build failures as `known`.
The ordinary runtime records for 318 cases establish their first difference
at seed 1, without seed 73 results.
The 135 simulation builds have no ordinary runtime, including 56 unlinked DPI
inputs (38 HDL and 18 command-line); [the measured breakdown](results.md#interpretation)
records the complete categories. Five illegal compiler acceptances remain a
separate no-runtime condition.

The separate HDL condition has thirty-seven both-seed matches in thirty-eight
inputs, including four virtual-register/field transfers, six register transfers, eight positive-duration force_time, nine primitive force/release
and three actual-array memory inputs, plus the
retained E.7 warning/no-transfer difference at seed 1. The separate command-line
condition retains seventeen matches and one quit-warning difference. These
overlapping conditions are not summed.

Seven policy fixtures first differ at seed 1 without seed 73: the copier's
omitted name is nonempty, comparer threshold/copy recursion/recorder radix do
not return to their specified defaults after flush, and pack_field above the
stream maximum does not report the required error. SHALLOW field-automation
cases compare distinct equal children as equal and copy an independent child,
under the retained combined policy/default-field-flag interpretation. These
are combined simulator/library observations, not assigned defect causes.
The invalid packer is never inspected or reused; a separate valid control is
used. Fifteen new runtime fixtures match both seeds and seven recorder illegal
declarations reject without runtime. Attribute override controls use an original
dummy token and establish no proprietary macro or backend compatibility.

Three new sequencer cases retain differences. The interface declaration's
default request is uvm_sequence_item; the pinned library declares uvm_object,
so the standard-typed base view cannot build. The printed base API
is_auto_enabled_recording_enabled is missing; the separately named interface
query is exercised independently. These two are builds without runtime seeds.
The wait_for_sequences probe returns before a producer exists at seed 1,
under the qualified literal-wait reading. Immediate try and override semantics
remain partial, and no confirmed defect cause is assigned. Seventeen new
runtime cases and the corrected rerandomization case match both seeds; two
abstract constructions reject without runtime execution.

## Printed report callback alias

Here “printed” means the literal declaration in the standard, whose wording may conflict with its heading; [the correction guide](faq.md#q18-how-should-i-report-or-correct-a-wrong-expectation) explains how to report an interpretation that needs review.

D.4.3 heads the entry as report_cb but prints the typedef name report_db.
The [literal declaration probe](../tests/uD/test_printed_report_callback_typedef_name_matches_the_declared_specialization.sv)
retains the printed uvm_report_db spelling; it is missing on the pinned
combination. This is build evidence without runtime seeds, a qualified name
conflict rather than a confirmed defect attribution. The working heading-name
callback paths and other exact aliases remain separate observations.

## Component lifetime and convenience interface observations

Dispatching a callback and completing a thread it starts are different observations; [the lifetime terms](glossary.md#component-lifetime-and-convenience-hooks) explain the processes whose survival is checked at phase boundaries.

Two lifetime probes retain writes and ticking descendants after common/runtime
phase end. The callback probe observes all three callback dispatches, but its
ready-to-end thread does not complete while start/end threads do. The exact
printed all_dropped function caller cannot build against the available task;
this is a qualified signature reading, with no runtime seed. Typed and named
convenience replace-zero conditions select the later type in subsequent
name-based creation. Preserve all five runtime expectations at seed 1 without
claiming seed 73 or a confirmed simulator/library cause.

WARNING verbosity is explicitly ignored by 6.3.3.3, so the hierarchical reporting
fixture expects three INFO and six WARNING deliveries. Pair configuration-query
boundaries are separate. The omitted-object-name fixture supplies an empty
original constructor default instead of constraining arbitrary user defaults.
The printed create_object equivalent call's extra this argument remains partial.

- [Runtime phase task/fork termination](../tests/u13/test_component_runtime_phase_kills_a_nonreturning_task_and_its_forked_descendant.sv)
- [Common run task/fork termination](../tests/u13/test_component_run_phase_kills_remaining_task_and_descendant_after_all_objections_drop.sv)
- [Callback thread survival](../tests/u13/test_component_phase_callback_threads_survive_their_runtime_phase_end.sv)
- [Printed all_dropped function](../tests/u13/test_component_printed_all_dropped_function_signature_dispatches_through_a_base_view.sv)
- [Typed convenience replace zero](../tests/uD/test_component_factory_typed_type_override_forwards_default_and_explicit_replace.sv)
- [Named convenience replace zero](../tests/uD/test_component_factory_named_type_override_forwards_default_and_explicit_replace.sv)

## Spec-only tests

A linked `.expected` file contains the required output, not the observed failing transcript; [Trace a difference](reading-guide.md#trace-a-difference) explains how to compare that requirement with a measured result and its reason.

Spec-only records the absence of an ordinary fixed-release oracle tag, so a match under a separate HDL or command-line backend still belongs to that separate condition; [the runner-selection guide](reading-guide.md#choose-an-execution-condition) explains which command to use.

A build-time API omission has no runtime observations to compare, so [the result interpretation](results.md#interpretation) separates it from a case that ran and printed a differing observation.

A compiler error in a `simulation` case leaves its runtime behavior unobserved, while an `elaboration` case requires the declared rejection; [the metadata guide](testing.md#metadata) explains how to distinguish them before investigating the sources below.

An explicit source path selects one listed fixture for investigation, and [the single-test command](faq.md#q3-how-can-i-run-one-test-first) shows how to request both runtime seeds.

Several listed inputs can stop at the same missing API, so their count is not a count of independent defects; [the measured breakdown](results.md#interpretation) separates build blockers from runtime observations.

Spec-only cases retain standard-derived expectations even without a fixed-release oracle tag; [Standards and expectations](glossary.md#standards-and-expectations) explains what that annotation means.

A control exercises a separate premise to help interpret a difference, and [the requirement-link guide](requirements.md#citations-requirements-and-execution-evidence) explains how its result relates to the original case.

The 458 current spec-only cases are linked in the explanatory notes and the
grouped list below. Several exercise the same limitation, so their count is
not a count of distinct bugs.



- [test_memory_explicit_access_policy_0_104](../tests/u18/test_memory_explicit_access_policy_0_104.sv).
- [test_memory_explicit_access_policy_1_104](../tests/u18/test_memory_explicit_access_policy_1_104.sv).
- [test_memory_relocation_map_units_0_0_104](../tests/u18/test_memory_relocation_map_units_0_0_104.sv).
- [test_memory_relocation_map_units_0_1_104](../tests/u18/test_memory_relocation_map_units_0_1_104.sv).
- [test_memory_relocation_map_units_1_0_104](../tests/u18/test_memory_relocation_map_units_1_0_104.sv).
- [test_memory_relocation_map_units_1_1_104](../tests/u18/test_memory_relocation_map_units_1_1_104.sv).

- [test_callback_static_next_exhausted_growth_local_103](../tests/u10/test_callback_static_next_exhausted_growth_local_103.sv).
- [test_callback_static_next_exhausted_growth_typewide_103](../tests/u10/test_callback_static_next_exhausted_growth_typewide_103.sv).

- [test_callback_overview_base_relation_0_102](../tests/uB/test_callback_overview_base_relation_0_102.sv).
- [test_callback_overview_base_relation_1_102](../tests/uB/test_callback_overview_base_relation_1_102.sv).

- [test_case_sensitive_field_0_101](../tests/u01/test_case_sensitive_field_0_101.sv).
- [test_case_sensitive_field_1_101](../tests/u01/test_case_sensitive_field_1_101.sv).
- [test_case_sensitive_register_0_101](../tests/u01/test_case_sensitive_register_0_101.sv).
- [test_case_sensitive_register_1_101](../tests/u01/test_case_sensitive_register_1_101.sv).
- [test_case_sensitive_sequence_0_101](../tests/u01/test_case_sensitive_sequence_0_101.sv).
- [test_case_sensitive_sequence_1_101](../tests/u01/test_case_sensitive_sequence_1_101.sv).

- [test_inherited_api_component_0_99](../tests/u01/test_inherited_api_component_0_99.sv).
- [test_inherited_api_component_1_99](../tests/u01/test_inherited_api_component_1_99.sv).

- [test_tlm_package_get_0_96](../tests/uB/test_tlm_package_get_0_96.sv).
- [test_tlm_package_get_1_96](../tests/uB/test_tlm_package_get_1_96.sv).
- [test_tlm_package_put_0_96](../tests/uB/test_tlm_package_put_0_96.sv).
- [test_tlm_package_put_1_96](../tests/uB/test_tlm_package_put_1_96.sv).

- [test_event_0_94](../tests/uB/test_event_0_94.sv).
- [test_event_1_94](../tests/uB/test_event_1_94.sv).

- [test_radix_real_0_93](../tests/uF/test_radix_real_0_93.sv).
- [test_radix_real_1_93](../tests/uF/test_radix_real_1_93.sv).
- [test_radix_unsigned_literal_0_93](../tests/uF/test_radix_unsigned_literal_0_93.sv).
- [test_radix_unsigned_literal_1_93](../tests/uF/test_radix_unsigned_literal_1_93.sv).

- [test_heartbeat_no_hb_mode_0_92](../tests/uF/test_heartbeat_no_hb_mode_0_92.sv).
- [test_heartbeat_no_hb_mode_1_92](../tests/uF/test_heartbeat_no_hb_mode_1_92.sv).
- [test_heartbeat_one_active_0_92](../tests/uF/test_heartbeat_one_active_0_92.sv).
- [test_heartbeat_one_active_1_92](../tests/uF/test_heartbeat_one_active_1_92.sv).
- [test_library_standard_item_0_92](../tests/uF/test_library_standard_item_0_92.sv).
- [test_library_standard_item_1_92](../tests/uF/test_library_standard_item_1_92.sv).
- [test_library_standard_rand_0_92](../tests/uF/test_library_standard_rand_0_92.sv).
- [test_library_standard_rand_1_92](../tests/uF/test_library_standard_rand_1_92.sv).
- [test_library_standard_randc_0_92](../tests/uF/test_library_standard_randc_0_92.sv).
- [test_library_standard_randc_1_92](../tests/uF/test_library_standard_randc_1_92.sv).
- [test_library_standard_user_0_92](../tests/uF/test_library_standard_user_0_92.sv).
- [test_library_standard_user_1_92](../tests/uF/test_library_standard_user_1_92.sv).

- [test_pkg_phase_kinds_0_91](../tests/uF/test_pkg_phase_kinds_0_91.sv).
- [test_pkg_phase_kinds_1_91](../tests/uF/test_pkg_phase_kinds_1_91.sv).
- [test_pkg_wait_operators_0_91](../tests/uF/test_pkg_wait_operators_0_91.sv).

- [mam_policy_contradiction_then_repair_0](../tests/u18/test_mam_policy_contradiction_then_repair_0_90.sv).
- [mam_policy_contradiction_then_repair_1](../tests/u18/test_mam_policy_contradiction_then_repair_1_90.sv).

- [mam_greedy_fresh_high_history](../tests/u18/test_mam_greedy_fresh_high_history_89.sv).
- [mam_thrifty_reuse_low_history](../tests/u18/test_mam_thrifty_reuse_low_history_89.sv).
- [mam_thrifty_reuse_high_history](../tests/u18/test_mam_thrifty_reuse_high_history_89.sv).
- [mam_nearby_one_existing](../tests/u18/test_mam_nearby_one_existing_89.sv).
- [mam_nearby_two_existing](../tests/u18/test_mam_nearby_two_existing_89.sv).

- [root_finish_default_after_phases](../tests/uF/test_root_finish_default_after_phases_88.sv).
- [root_finish_reenabled_after_phases](../tests/uF/test_root_finish_reenabled_after_phases_88.sv).
- [root_guard_error_in_build](../tests/uF/test_root_guard_error_in_build_88.sv).
- [root_guard_error_in_end_of_elaboration](../tests/uF/test_root_guard_error_in_end_of_elaboration_88.sv).
- [root_extension_construction_requires_fatal](../tests/uF/test_root_extension_construction_requires_fatal_88.sv).
- [predictor_check_pending_little_1_registers](../tests/u19/test_predictor_check_pending_little_1_registers_88.sv).
- [predictor_check_pending_little_2_registers](../tests/u19/test_predictor_check_pending_little_2_registers_88.sv).
- [predictor_check_pending_big_1_registers](../tests/u19/test_predictor_check_pending_big_1_registers_88.sv).
- [predictor_check_pending_big_2_registers](../tests/u19/test_predictor_check_pending_big_2_registers_88.sv).

- [reg_frontdoor_get_single_omitted](../tests/u18/test_reg_frontdoor_get_single_omitted_87.sv).
- [reg_frontdoor_get_single_explicit](../tests/u18/test_reg_frontdoor_get_single_explicit_87.sv).
- [reg_frontdoor_get_multiple_replace_first](../tests/u18/test_reg_frontdoor_get_multiple_replace_first_87.sv).
- [reg_frontdoor_get_multiple_replace_second](../tests/u18/test_reg_frontdoor_get_multiple_replace_second_87.sv).

- [field_pre_read_method_order_literal](../tests/u18/test_vreg_callback_field_pre_read_method_order_literal_86.sv).
- [field_pre_read_cb_order_literal](../tests/u18/test_vreg_callback_field_pre_read_cb_order_literal_86.sv).
- [decl_register_concrete](../tests/u18/test_vreg_callback_decl_register_concrete_86.sv).

- [vreg_poke_word16](../tests/u18/test_vreg_backdoor_hdl_vreg_poke_word16_85.sv).
- [vreg_peek_word16](../tests/u18/test_vreg_backdoor_hdl_vreg_peek_word16_85.sv).
- [field_poke_word16](../tests/u18/test_vreg_backdoor_hdl_field_poke_word16_85.sv).
- [field_peek_word16](../tests/u18/test_vreg_backdoor_hdl_field_peek_word16_85.sv).

- [uvm_info literal INFO boundary](../tests/uB/test_report_macro_info_literal_info_boundary_81.sv).
- [uvm_info_context literal INFO boundary](../tests/uB/test_report_macro_info_context_literal_info_boundary_81.sv).

- [none_negative_id_limit_literal](../tests/uF/test_enum_state_none_negative_id_limit_literal_84.sv).
- [sequence_kill_post_hooks_literal](../tests/uF/test_enum_state_sequence_kill_post_hooks_literal_84.sv).

- [field_flag_user_extension_129](../tests/uB/test_size_version_field_flag_user_extension_129_83.sv).
- [packer_minimum_define](../tests/uB/test_size_version_packer_minimum_define_83.sv).

- [Unregistered-instance empty delete](../tests/uB/test_callback_macro_unregistered_delete_instance_82.sv).

- [Constructor-added measurement returns the previous mask](../tests/u18/test_reg_coverage_add_measurement_availability_80.sv).

- [Inherited subscriber type_id specialization](../tests/u08/test_builtin_abstract_parameterized_components_type_id_uses_the_required_registry_specialization.sv).
- [Missing transaction type_id in the shared abstract-object matrix](../tests/u08/test_builtin_abstract_objects_type_id_uses_the_required_registry_specialization.sv).
- [Inherited parameterized-sequence type_id specialization](../tests/u08/test_builtin_abstract_parameterized_objects_type_id_uses_the_required_registry_specialization.sv).
- [Missing report-server type_id in an independent probe](../tests/u08/test_builtin_report_server_type_id_uses_its_own_named_abstract_registry.sv).
- [Required ERROR for an unknown object type name](../tests/u08/test_factory_unknown_object_name_reports_an_error_and_returns_null_with_a_registered_control.sv).
- [Required ERROR for an unknown component type name](../tests/u08/test_factory_unknown_component_name_reports_an_error_and_returns_null_with_a_registered_control.sv).

- [Premature phase ending and original task lifetime](../tests/u09/test_phase_end_prematurely_advances_without_a_jump_target_and_stops_original_task_threads.sv).
- [Qualified literal get_imp non-IMP-null rule](../tests/u09/test_phase_get_imp_literal_non_imp_null_rule_remains_separate_from_the_node_prose.sv).
- [Qualified printed get_schedule string return type](../tests/u09/test_phase_get_schedule_printed_string_return_is_accepted_by_a_typed_string_receiver.sv).
- [Always-present built-in domain entries before explicit initialization](../tests/u09/test_domain_listing_contains_required_builtin_domains_and_retains_new_named_instances.sv).

- [Printed provider acceptance for blocking initiator relay](../tests/u12/test_tlm2_blocking_passthrough_initiator_connect_accepts_its_spec_listed_provider_families.sv).
- [Printed provider acceptance for blocking target relay](../tests/u12/test_tlm2_blocking_passthrough_target_connect_accepts_its_spec_listed_provider_families.sv).
- [Qualified same-kind terminator direct-binding rejection](../tests/u12/test_tlm2_same_kind_terminator_socket_connections_leave_no_provider_bindings.sv).

- [Independent integer response default with REQ-only bidirectional ports](../tests/u12/test_tlm_bidirectional_request_only_parameter_keeps_declared_integer_response_default.sv).

- [Intermediate descendant totals with skipped callbacks](../tests/u10/test_objection_skipped_propagation_delivers_default_and_registered_hooks_with_context.sv).

- [Established early raw event wait](../tests/u10/test_event_raw_trigger_wait_distinguishes_early_and_same_slice_late_calls.sv).
- [Actual event waiter count after default reset](../tests/u10/test_event_default_reset_preserves_mixed_waiters_for_a_fresh_trigger.sv).
- [Required initial event-pool members](../tests/u10/test_event_pool_initial_membership_contains_begin_accept_and_end_without_lazy_get.sv).

- [Single encoder value propagation](../tests/u18/test_user_backdoor_encode_single_propagates_all_value_elements.sv).
- [Chained encoder value propagation](../tests/u18/test_user_backdoor_encode_chain_propagates_all_value_elements.sv).
- [Single decoder clear-data propagation](../tests/u18/test_user_backdoor_decode_single_propagates_all_value_elements.sv).
- [Reverse decoder chain propagation](../tests/u18/test_user_backdoor_decode_chain_propagates_all_value_elements.sv).

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
- Original six standard sequence-library API cases (all six cannot build):
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
  and [128 bits](../tests/u16/test_packer_integral_size_128_reports_error_before_independent_boundary_control.sv).
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

- [Sequence-report severity admission before virtual processing](../tests/u14/test_sequence_item_reporting_filters_each_severity_before_virtual_processing.sv).

- [Named concat construction](../tests/u17/test_hdl_concat_standard_constructor_accepts_explicit_and_empty_instance_names.sv).
- [Concat replacement and copy isolation](../tests/u17/test_hdl_concat_standard_set_slices_replaces_prior_gapped_description_without_aliases.sv).
- [Concat append after replacement](../tests/u17/test_hdl_concat_standard_add_slice_appends_after_replacement_and_preserves_peer.sv).

- [command vpi singleton and all arguments preserve supplied membership](../tests/uG/test_command_vpi_singleton_and_all_arguments_preserve_supplied_membership.sv).
- [command vpi plusargs exclude dash arguments and replace caller contents](../tests/uG/test_command_vpi_plusargs_exclude_dash_arguments_and_replace_caller_contents.sv).
- [command vpi uvm arguments accept mixed case keywords and both prefixes](../tests/uG/test_command_vpi_uvm_arguments_accept_mixed_case_keywords_and_both_prefixes.sv).
- [command vpi prefix matches replace queues and clear missing queries](../tests/uG/test_command_vpi_prefix_matches_replace_queues_and_clear_missing_queries.sv).
- [command vpi first value preserves the first suffix and counts all matches](../tests/uG/test_command_vpi_first_value_preserves_the_first_suffix_and_counts_all_matches.sv).
- [command vpi all values keep empty and comma suffixes without stale entries](../tests/uG/test_command_vpi_all_values_keep_empty_and_comma_suffixes_without_stale_entries.sv).
- [command vpi extended regex matches grouped alternatives and clears queries](../tests/uG/test_command_vpi_extended_regex_matches_grouped_alternatives_and_clears_queries.sv).
- [command testname creates the first registered test and warns for duplicates](../tests/uG/test_command_testname_creates_the_first_registered_test_and_warns_for_duplicates.sv).
- [command initial verbosity applies to components created in build](../tests/uG/test_command_initial_verbosity_applies_to_components_created_in_build.sv).
- [command timed verbosity updates the selected id and component only](../tests/uG/test_command_timed_verbosity_updates_the_selected_id_and_component_only.sv).
- [command action setting is scoped to the selected component and id](../tests/uG/test_command_action_setting_is_scoped_to_the_selected_component_and_id.sv).
- [command severity override changes the selected report and preserves controls](../tests/uG/test_command_severity_override_changes_the_selected_report_and_preserves_controls.sv).
- [command max quit count allows a later user setting](../tests/uG/test_command_max_quit_count_allows_a_later_user_setting.sv).
- [command max quit count rejects a later user setting](../tests/uG/test_command_max_quit_count_rejects_a_later_user_setting.sv).
- [command factory instance override precedes the type override for its target](../tests/uG/test_command_factory_instance_override_precedes_the_type_override_for_its_target.sv).
- [command configuration sets numeric bases and strings in the selected scope](../tests/uG/test_command_configuration_sets_numeric_bases_and_strings_in_the_selected_scope.sv).
- [command default sequence runs on the named sequencer and phase](../tests/uG/test_command_default_sequence_runs_on_the_named_sequencer_and_phase.sv).
- [command fresh processors populate independent argument snapshots at construction](../tests/uG/test_command_fresh_processors_populate_independent_argument_snapshots_at_construction.sv).

Two existing inputs have revised fingerprints: the command-enum citation and
the corrected Boolean rerandomization observation. Their historical guest
records are excluded. The compatible subset has 1081 records and 1650 inputs
are unmeasured, including both revised inputs. This filtering is evidence scope,
not a new guest failure, pass or simulator improvement.

- [Copier default name](../tests/u16/test_policy_comparer_packer_and_copier_constructors_preserve_names_types_and_policy_bases.sv)
- [Comparer threshold after flush](../tests/u16/test_comparer_threshold_default_updates_and_flush_restore_the_declared_boundary.sv)
- [Copier recursion after flush](../tests/u16/test_copier_recursion_default_updates_and_flush_restore_the_declared_policy.sv)
- [SHALLOW child comparison](../tests/u16/test_comparer_field_automation_distinguishes_nested_recursion_and_alias_conditions.sv)
- [SHALLOW child ownership](../tests/u16/test_copier_field_automation_distinguishes_deep_shallow_and_default_child_ownership.sv)
- [Wide pack oversize error](../tests/u16/test_packer_wide_oversize_reports_error_before_an_independent_maximum_width_control.sv)
- [Recorder radix after flush](../tests/u16/test_recorder_configuration_defaults_updates_and_flush_restore_the_declared_values.sv)

- [Interface request default](../tests/u15/test_sequencer_interface_defaults_and_selected_legal_subtypes_keep_exact_base_types.sv)
- [Printed base recording getter](../tests/u15/test_sequencer_base_printed_recording_query_reports_default_disable_and_peer_state.sv)
- [Qualified waiting interpretation](../tests/u15/test_sequencer_interface_wait_for_sequences_stays_blocked_until_a_producer_is_available.sv)

- [memory backdoor local and inherited selection drives access failure and retry](../tests/u18/test_memory_backdoor_local_and_inherited_selection_drives_access_failure_and_retry.sv).
- [memory derived constructor adds coverage models without enabling unavailable models](../tests/u18/test_memory_derived_constructor_adds_coverage_models_without_enabling_unavailable_models.sv).
- [memory builtin hdl backdoor tasks read and write selected array locations](../tests/u18/test_memory_builtin_hdl_backdoor_tasks_read_and_write_selected_array_locations.sv).
- [memory hdl split array paths assemble and deposit the declared bit slices](../tests/u18/test_memory_hdl_split_array_paths_assemble_and_deposit_the_declared_bit_slices.sv).
- [memory physical rom backdoor write and poke have distinct access effects](../tests/u18/test_memory_physical_rom_backdoor_write_and_poke_have_distinct_access_effects.sv).
- [memory backdoor read public call is a legal task declaration](../tests/u18/test_memory_backdoor_read_public_call_is_a_legal_task_declaration.sv).

- [package generic report defaults preserve severity specific verbosity and message fields](../tests/uF/test_package_generic_report_defaults_preserve_severity_specific_verbosity_and_message_fields.sv).
- [package report helpers forward default verbosity and explicit debug context](../tests/uF/test_package_report_helpers_forward_default_verbosity_and_explicit_debug_context.sv).
- [run test callbacks bracket real phasing and observe core lifecycle states](../tests/uF/test_run_test_callbacks_bracket_real_phasing_and_observe_core_lifecycle_states.sv).
- [run test callbacks without deletion observe each registered hook and core states](../tests/uF/test_run_test_callbacks_without_deletion_observe_each_registered_hook_and_core_states.sv).

- [resource base legal extensions preserve default explicit names virtual type handles](../tests/uC/test_resource_base_legal_extensions_preserve_default_explicit_names_virtual_type_handles.sv).
- [resource pool name lookup filters type and scope and respects missing report controls](../tests/uC/test_resource_pool_name_lookup_filters_type_and_scope_and_respects_missing_report_controls.sv).
- [resource pool precedence changes name selection but not type queue priority](../tests/uC/test_resource_pool_precedence_changes_name_selection_but_not_type_queue_priority.sv).
- [resource pool global precedence selects name maximum and keeps type priority](../tests/uC/test_resource_pool_global_precedence_selects_name_maximum_and_keeps_type_priority.sv).

Sixteen direct-map translation inputs:

- [test_map_direct_translation_flat_little_byte_empty_107](../tests/u18/test_map_direct_translation_flat_little_byte_empty_107.sv)
- [test_map_direct_translation_flat_big_byte_empty_107](../tests/u18/test_map_direct_translation_flat_big_byte_empty_107.sv)
- [test_map_direct_translation_flat_little_word_empty_107](../tests/u18/test_map_direct_translation_flat_little_word_empty_107.sv)
- [test_map_direct_translation_flat_big_word_empty_107](../tests/u18/test_map_direct_translation_flat_big_word_empty_107.sv)
- [test_map_direct_translation_child4_root2_empty_107](../tests/u18/test_map_direct_translation_child4_root2_empty_107.sv)
- [test_map_direct_translation_child2_root4_empty_107](../tests/u18/test_map_direct_translation_child2_root4_empty_107.sv)
- [test_map_direct_translation_little_fifo_empty_107](../tests/u18/test_map_direct_translation_little_fifo_empty_107.sv)
- [test_map_direct_translation_big_fifo_empty_107](../tests/u18/test_map_direct_translation_big_fifo_empty_107.sv)
- [test_map_direct_translation_flat_little_byte_populated_107](../tests/u18/test_map_direct_translation_flat_little_byte_populated_107.sv)
- [test_map_direct_translation_flat_big_byte_populated_107](../tests/u18/test_map_direct_translation_flat_big_byte_populated_107.sv)
- [test_map_direct_translation_flat_little_word_populated_107](../tests/u18/test_map_direct_translation_flat_little_word_populated_107.sv)
- [test_map_direct_translation_flat_big_word_populated_107](../tests/u18/test_map_direct_translation_flat_big_word_populated_107.sv)
- [test_map_direct_translation_child4_root2_populated_107](../tests/u18/test_map_direct_translation_child4_root2_populated_107.sv)
- [test_map_direct_translation_child2_root4_populated_107](../tests/u18/test_map_direct_translation_child2_root4_populated_107.sv)
- [test_map_direct_translation_little_fifo_populated_107](../tests/u18/test_map_direct_translation_little_fifo_populated_107.sv)
- [test_map_direct_translation_big_fifo_populated_107](../tests/u18/test_map_direct_translation_big_fifo_populated_107.sv)

## Simulator and library combinations

One shared build blocker can stop many tests before their UVM behavior runs; [Q9](faq.md#q9-why-does-a-green-check-not-mean-kirimasim-passes-uvm) explains what can be concluded about behavior beyond those compilation blockers.

A bundled library and the pinned library are different execution conditions, so compare records using [Current snapshot](results.md#current-snapshot).

The earlier field-configuration filter reduced 1083 compatible records to 1082. The subsequent reraise primary-citation filter reduced 1082 to 1081; this increment retains those records without another filter or guest run, and [the input-identity explanation](faq.md#q408-does-the-citation-repair-improve-guest-results-or-prove-clause-coverage) and [evidence assembly](results.md#evidence-assembly) distinguish the two stages.

The suite has 2731 cases, but the kirimasim/Ghost records below cover only
1081 unchanged current-input cases. The 1650 inputs are unmeasured
because prior temporary executable/profile snapshots are unavailable. Do
not treat this as a fresh full-suite guest result. See [results](results.md).

Ghost's bundled-library evidence has 206 matches and 875 failures with each
of seeds 1 and 73; the same tests fail at both seeds. The current executable
snapshot has no pinned-mode measurement. [Results and methodology](results.md)
describes the evidence assembly. Bundled results
cover the supplied library. Their mismatches do not distinguish a simulator
problem from a library problem or establish results for the locked library.
Private identity, profiles and diagnostics are not published.

The tested kirimasim executable reports `uvm_object_wrapper` as unsupported
on 1072 cases. Nine cases record `fail` earlier on missing library APIs: one time
setter, six sequence-library cases and two HDL slice cases. Neither result is a pass or evidence
of UVM execution beyond those compilation blockers.

See the [README results](../README.md#current-results) for execution scope
and the [history](history.md) for earlier measurements.
