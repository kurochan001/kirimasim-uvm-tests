# kirimasim bring-up stages

[日本語](kirimasim-stages.ja.md) · [README](../README.md) · [Results](results.md)

The bring-up stages order the parts of UVM that a simulator meets while it learns to run the library, so that the progress of kirimasim can be measured stage by stage. This page explains how each test gets its stage, the short set of representatives for each stage, the current kirimasim records by stage, and the SystemVerilog features that each stage needs, with tests of kirimasim-tests for each feature.

- [Why stages](#why-stages)
- [How a test gets its stage](#how-a-test-gets-its-stage)
- [Short sets](#short-sets)
- [Current kirimasim records by stage](#current-kirimasim-records-by-stage)
- [SystemVerilog features by stage](#systemverilog-features-by-stage)
- [Keeping the stages current](#keeping-the-stages-current)

## Why stages

Of the 1081 current kirimasim records, 1072 report `uvm_object_wrapper` as unsupported and the other nine meet a missing library API first; 1682 inputs have no current record ([current results](results.md#current-snapshot)). Every measured test stops at the same place, so the records do not show how far the simulator has come. With a stage for each test and a short set for each stage, a run of the short sets shows the first stage that does not pass, and the features table below points to the language tests to look at next.

The stages are not the M1 to M4 milestones, which group tests by the functional subject that development covers ([milestone grouping](glossary.md#scope-and-coverage)). A stage changes no expectation and adds no metadata field: the record is a separate file, so no input fingerprint changes.

## How a test gets its stage

The record is [`coverage/kirimasim_stages.json`](../coverage/kirimasim_stages.json), and [`tools/kirimasim_stages.py`](../tools/kirimasim_stages.py) checks it; Check runs the check on every push.

Each of the stages 2 to 6 lists markers, regular expressions that find a use of its part of UVM. The tool searches the test and every file that it collects under `tests/` (`:files:` and the files they include), with comments and string literals removed. The stage of a test is the highest stage whose marker matches, or stage 1 when none does. A test with markers of two stages, such as a driver that also writes to an analysis port, takes the higher one, because the simulator needs both parts.

| Stage | Part of UVM | Markers (examples) | Tests | Recorded with Verilator 5.052 | Short set |
| --- | --- | --- | --- | --- | --- |
| 0 | uvm_pkg only | None; set by an override | 1 | 1 | 1 |
| 1 | minimal run_test | None; the default stage | 1030 | 871 | 5 |
| 2 | factory | `::type_id`, `uvm_factory`, `uvm_object_wrapper`, overrides, `create_*_by_name`, `get_type()` | 95 | 85 | 5 |
| 3 | config_db | `uvm_config_db`, `uvm_resource*`, `apply_config_settings` | 111 | 91 | 5 |
| 4 | sequence | `uvm_sequence`, `uvm_sequencer`, `uvm_driver`, `start_item`, the sequence macros such as `` `uvm_do `` | 326 | 268 | 5 |
| 5 | TLM | ports, exports and imps, `uvm_analysis_*`, `uvm_tlm_*`, `` `uvm_*_imp_decl ``, `uvm_subscriber` | 250 | 224 | 5 |
| 6 | register layer | `uvm_reg*`, `uvm_mem*`, `uvm_vreg*`, `uvm_hdl_*`, the register-layer enumerations | 950 | 753 | 5 |
| Total | | | 2763 | 2293 | 31 |

A few lookalikes are left out on purpose: a sequence item alone (`uvm_sequence_item`) does not place a test at stage 4, typedefs such as `uvm_reg_data_t` do not place it at stage 6, and `` `uvm_do_callbacks `` is a callback macro, not a sequence macro. The unit tests of the tool check these cases on short snippets.

An override sets the stage of a test that the markers cannot place, with a reason in English and Japanese. Stage 0 is reached only this way: [test_uvm_pkg_import_only_reaches_package_items](../tests/u01/test_uvm_pkg_import_only_reaches_package_items.sv) imports uvm_pkg and names one enumeration value, through the import and through the package name, without creating a UVM object or calling run_test. Its expectation follows from 1.4.5 and F.2.2.4, and it matches with Verilator 5.052 at seeds 1 and 73.

Every stage compiles the whole of uvm_pkg, so a construct that the simulator cannot compile anywhere in the library stops every stage; this is what the current records show. A stage names what the test elaborates and runs beyond the package itself: the parameterized classes that it specializes and the library code that it executes.

## Short sets

Each stage lists up to ten representatives; the current sets hold five tests for each of the stages 1 to 6 and the one stage-0 test. A representative is a simulation test recorded with `verilator@5.052`, so its expectation matches at seeds 1 and 73 with the pinned library, and it needs no DPI or back-end condition and no run-time argument. Within a stage, the sets prefer small tests of the stage's main subject.

| Stage | Tests |
| --- | --- |
| 0 | [u01/test_uvm_pkg_import_only_reaches_package_items](../tests/u01/test_uvm_pkg_import_only_reaches_package_items.sv) |
| 1 | [u13/test_test_argument_selection_creates_the_registered_test_under_the_implicit_root](../tests/u13/test_test_argument_selection_creates_the_registered_test_under_the_implicit_root.sv)<br>[u09/test_common_phases_before_run_stay_at_zero_and_run_end_shares_the_final_time](../tests/u09/test_common_phases_before_run_stay_at_zero_and_run_end_shares_the_final_time.sv)<br>[u13/test_component_run_phase_return_does_not_end_an_objection_held_phase](../tests/u13/test_component_run_phase_return_does_not_end_an_objection_held_phase.sv)<br>[u06/test_report_server_counts_severity_and_id](../tests/u06/test_report_server_counts_severity_and_id.sv)<br>[u05/test_object_rename_updates_identity](../tests/u05/test_object_rename_updates_identity.sv) |
| 2 | [u08/test_factory_type_override_replaces_previous](../tests/u08/test_factory_type_override_replaces_previous.sv)<br>[u08/test_factory_instance_override_is_scoped](../tests/u08/test_factory_instance_override_is_scoped.sv)<br>[u08/test_factory_type_alias_creates_original_type](../tests/u08/test_factory_type_alias_creates_original_type.sv)<br>[u08/test_object_registry_create_uses_parent_context](../tests/u08/test_object_registry_create_uses_parent_context.sv)<br>[u05/test_object_wrapper_follows_dynamic_type](../tests/u05/test_object_wrapper_follows_dynamic_type.sv) |
| 3 | [uC/test_config_db_exists_checks_scope_and_field](../tests/uC/test_config_db_exists_checks_scope_and_field.sv)<br>[uC/test_config_db_omitted_type_matches_int_without_merging_string_settings](../tests/uC/test_config_db_omitted_type_matches_int_without_merging_string_settings.sv)<br>[uC/test_resource_pool_scope_collection_includes_an_unnamed_visible_resource](../tests/uC/test_resource_pool_scope_collection_includes_an_unnamed_visible_resource.sv)<br>[u13/test_component_default_automatic_config_calls_application_during_build](../tests/u13/test_component_default_automatic_config_calls_application_during_build.sv)<br>[uC/test_configuration_and_resources_remain_accessible_at_selected_positive_times](../tests/uC/test_configuration_and_resources_remain_accessible_at_selected_positive_times.sv) |
| 4 | [u14/test_sequence_start_orders_default_hooks](../tests/u14/test_sequence_start_orders_default_hooks.sv)<br>[u15/test_sequencer_execute_item_waits_for_driver_acknowledgement](../tests/u15/test_sequencer_execute_item_waits_for_driver_acknowledgement.sv)<br>[u14/test_sequence_lock_blocks_other_sequence_until_unlock](../tests/u14/test_sequence_lock_blocks_other_sequence_until_unlock.sv)<br>[u15/test_sequencer_try_next_item_returns_null_when_no_sequence_is_ready](../tests/u15/test_sequencer_try_next_item_returns_null_when_no_sequence_is_ready.sv)<br>[uB/test_sequence_macro_do_creates_randomizes_and_sends_item](../tests/uB/test_sequence_macro_do_creates_randomizes_and_sends_item.sv) |
| 5 | [u12/test_blocking_put_port_forwards_values_to_fifo](../tests/u12/test_blocking_put_port_forwards_values_to_fifo.sv)<br>[u12/test_tlm_fifo_blocking_get_waits_until_put](../tests/u12/test_tlm_fifo_blocking_get_waits_until_put.sv)<br>[u12/test_tlm_analysis_fifo_write_preserves_arrival_order](../tests/u12/test_tlm_analysis_fifo_write_preserves_arrival_order.sv)<br>[u12/test_tlm2_blocking_socket_forwards_payload_delay_and_read_result](../tests/u12/test_tlm2_blocking_socket_forwards_payload_delay_and_read_result.sv)<br>[uB/test_tlm_analysis_imp_decl_preserves_object_handles_and_selected_input](../tests/uB/test_tlm_analysis_imp_decl_preserves_object_handles_and_selected_input.sv) |
| 6 | [u18/test_reg_field_set_changes_desired_without_predicting_mirror](../tests/u18/test_reg_field_set_changes_desired_without_predicting_mirror.sv)<br>[u18/test_reg_field_hard_reset_restores_desired_and_mirror](../tests/u18/test_reg_field_hard_reset_restores_desired_and_mirror.sv)<br>[u18/test_reg_frontdoor_write_with_auto_predict_updates_bus_storage_and_mirror](../tests/u18/test_reg_frontdoor_write_with_auto_predict_updates_bus_storage_and_mirror.sv)<br>[u18/test_reg_frontdoor_read_with_auto_predict_returns_bus_data_and_updates_mirror](../tests/u18/test_reg_frontdoor_read_with_auto_predict_returns_bus_data_and_updates_mirror.sv)<br>[uE/test_hw_reset_sequence_detects_an_incorrect_storage_reset_value](../tests/uE/test_hw_reset_sequence_detects_an_incorrect_storage_reset_value.sv) |

The short sets print as test paths that [the kirimasim runner](testing.md#running-the-suite) accepts. Running the stages up to 1 and summarizing the result by stage looks like this:

```sh
python3 tools/kirimasim_stages.py short --upto 1
python3 tools/run_kirimasim.py --json out/kirimasim-stages.json $(python3 tools/kirimasim_stages.py short --upto 1)
python3 tools/kirimasim_stages.py summary --results out/kirimasim-stages.json
```

Measuring kirimasim needs its executable, which is not part of this repository; this page adds no new kirimasim measurement.

## Current kirimasim records by stage

The 1081 current kirimasim records ([retained guest records](results.md#evidence-assembly)), counted by stage with `tools/kirimasim_stages.py summary --results`:

| Stage | Tests | `unsupported` | `fail` | Unmeasured |
| --- | --- | --- | --- | --- |
| 0 | 1 | 0 | 0 | 1 |
| 1 | 1030 | 320 | 0 | 710 |
| 2 | 95 | 53 | 0 | 42 |
| 3 | 111 | 17 | 0 | 94 |
| 4 | 326 | 197 | 6 | 123 |
| 5 | 250 | 170 | 1 | 79 |
| 6 | 950 | 315 | 2 | 633 |
| Total | 2763 | 1072 | 9 | 1682 |

The most common reason is the same in every stage: `uvm_object_wrapper` is not implemented yet. The nine `fail` records meet a missing library API first: six sequence-library methods (stage 4), one TLM time method (stage 5) and two HDL path slice methods (stage 6). Of the 31 short-set tests, 23 have a current record, all `unsupported`; the stage-0 test is new and unmeasured.

## SystemVerilog features by stage

Each stage needs the features of the earlier stages; the tables list what a stage adds. The third column names a place where [the pinned library](provenance.md#library-and-standards) uses the feature, linked at the locked commit. The last column links tests of [kirimasim-tests](https://github.com/kurochan001/kirimasim-tests/tree/829671c22f7dcbcaced78b59b7fe14f721206c5b) at commit `829671c2` whose first 1800-2023 clause is the feature's clause; their oracles are in kirimasim-tests. Running them with kirimasim shows which language feature keeps a stage from passing.

### Stage 0: uvm_pkg only

| Feature | 1800-2023 | Where the pinned library uses it | kirimasim-tests |
| --- | --- | --- | --- |
| Packages, import and the scope resolution operator | 26.2, 26.3 | [`src/uvm_pkg.sv`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/uvm_pkg.sv): `package uvm_pkg` | [ch26/test_package_import_item_list](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch26/test_package_import_item_list.sv), [ch26/test_package_explicit_import_only_named](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch26/test_package_explicit_import_only_named.sv) |
| Include files, macros with arguments and conditional compilation | 22.4, 22.5.1, 22.6 | [`src/uvm_macros.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/uvm_macros.svh): include and ifndef directives | [ch22/test_include_nested](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch22/test_include_nested.sv), [ch22/test_macro_use_space_before_arguments](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch22/test_macro_use_space_before_arguments.sv), [ch22/test_ifdef_nested](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch22/test_ifdef_nested.sv) |
| Inheritance, virtual methods and abstract classes | 8.13, 8.20, 8.21 | [`src/base/uvm_object.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_object.svh): `virtual class uvm_object` | [ch8/test_class_inherit](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_class_inherit.sv), [ch8/test_virtual_method](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_virtual_method.sv), [ch8/test_abstract_class_basic](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_abstract_class_basic.sv) |
| Out-of-block declarations, typedef class, local and protected members | 8.24, 8.27, 8.18 | [`src/base/uvm_component.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_component.svh): 117 `extern` declarations | [ch8/test_class_extern](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_class_extern.sv), [ch8/test_forward_class_typedef_parameterized](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_forward_class_typedef_parameterized.sv), [ch8/test_class_local_protected_access_and_modifier_order](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_class_local_protected_access_and_modifier_order.sv) |
| Parameterized classes, with static members for each specialization | 8.25, 8.9, 8.10 | [`src/base/uvm_registry.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_registry.svh): `static this_type m_inst` | [ch8/test_parameterized_class_static_per_specialization](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_parameterized_class_static_per_specialization.sv), [ch8/test_class_static_method](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_class_static_method.sv) |
| Static initializers that run before any initial procedure | 6.8, 6.21 | [`src/base/uvm_registry.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_registry.svh): `local static bit m__initialized=__deferred_init()` | [ch6/test_class_static_init_order](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch6/test_class_static_init_order.sv), [ch6/test_static_initializer_runs_once](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch6/test_static_initializer_runs_once.sv) |
| Strings, dynamic arrays, queues and associative arrays | 6.16, 7.5, 7.10, 7.8 | [`src/base/uvm_globals.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_globals.svh): the `uvm_deferred_init` queue | [ch6/test_string_methods_3](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch6/test_string_methods_3.sv), [ch7/test_dynamic_array_ops](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch7/test_dynamic_array_ops.sv), [ch7/test_queue_push_pop](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch7/test_queue_push_pop.sv), [ch7/test_assoc_string_empty_and_reverse_order](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch7/test_assoc_string_empty_and_reverse_order.sv) |
| Enumerations and their methods | 6.19 | [`src/base/uvm_globals.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_globals.svh): `first()`, `next()` and `name()` in `uvm_enum_wrapper` | [ch6/test_enum_named_constants](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch6/test_enum_named_constants.sv), [ch6/test_enum_first_last](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch6/test_enum_first_last.sv) |

### Stage 1: minimal run_test

| Feature | 1800-2023 | Where the pinned library uses it | kirimasim-tests |
| --- | --- | --- | --- |
| fork with join_none, wait fork and disable fork | 9.3.2, 9.6.1, 9.6.3 | [`src/base/uvm_phase_hopper.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_phase_hopper.svh): `fork`, `disable fork`; [`src/base/uvm_objection.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_objection.svh): `wait fork` | [ch9/test_join_none_children_start_after_parent_blocks](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch9/test_join_none_children_start_after_parent_blocks.sv), [ch9/test_wait_fork_ignores_grandchildren](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch9/test_wait_fork_ignores_grandchildren.sv), [ch9/test_disable_fork_ends_loops_and_class_tasks](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch9/test_disable_fork_ends_loops_and_class_tasks.sv) |
| Process control: self, status, kill and await | 9.7 | [`src/base/uvm_phase.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_phase.svh): `kill()`; [`src/base/uvm_process_guard_base.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_process_guard_base.svh): `status()`, `kill()` | [ch9/test_process_self_status_kill](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch9/test_process_self_status_kill.sv), [ch9/test_process_class_control](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch9/test_process_class_control.sv) |
| Named events and level-sensitive waits | 15.5, 9.4.3 | [`src/base/uvm_event.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_event.svh): `->m_event`; [`src/base/uvm_objection.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_objection.svh): `wait (...)` | [ch15/test_event_triggered](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch15/test_event_triggered.sv), [ch15/test_event_wait_after_trigger](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch15/test_event_wait_after_trigger.sv), [ch9/test_ch9_extra_wait_forms](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch9/test_ch9_extra_wait_forms.sv) |
| Parameterized mailboxes | 15.4 | [`src/base/uvm_phase.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_phase.svh): `mailbox #(uvm_phase) m_phase_hopper` | [ch15/test_mailbox_basic](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch15/test_mailbox_basic.sv), [ch15/test_mailbox_messages_between_processes](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch15/test_mailbox_messages_between_processes.sv) |
| $cast between class handles | 8.16 | [`src/base/uvm_root.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_root.svh): `$cast` | [ch8/test_cast_class](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_cast_class.sv) |
| Array locator and ordering methods with a with clause | 7.12.1, 7.12.2 | [`src/base/uvm_phase.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_phase.svh): `find_index(...) with (...)`; [`src/base/uvm_root.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_root.svh): `sort() with (...)` | [ch7/test_array_find_index](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch7/test_array_find_index.sv), [ch7/test_array_sort](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch7/test_array_sort.sv) |
| $value$plusargs | 21.6 | [`src/base/uvm_root.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_root.svh): `+UVM_TESTNAME`; [`src/base/uvm_cmdline_report.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_cmdline_report.svh): `+UVM_VERBOSITY` | [ch21/test_value_plusargs_first_match](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch21/test_value_plusargs_first_match.sv) |
| $sformatf, a zero delay and $finish | 21.3.3, 9.4.1, 20.2 | [`src/base/uvm_root.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_root.svh): `$sformatf`, `#0`, `$finish` | [ch21/test_sformatf](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch21/test_sformatf.sv), [ch9/test_fork_child_zero_delay](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch9/test_fork_child_zero_delay.sv), [ch20/test_finish_ends_simulation](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch20/test_finish_ends_simulation.sv) |

### Stage 2: factory

| Feature | 1800-2023 | Where the pinned library uses it | kirimasim-tests |
| --- | --- | --- | --- |
| Static methods called through the class scope of a parameterized class | 8.23, 8.25.1 | [`src/base/uvm_registry.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_registry.svh): `static function T create`, which `type_id::create` calls | [ch8/test_class_scope_nested_class_and_static_access](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_class_scope_nested_class_and_static_access.sv), [ch8/test_extern_method_class_scope_current_specialization](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_extern_method_class_scope_current_specialization.sv) |
| Associative arrays indexed by class handles and by strings | 7.8.3, 7.8.2 | [`src/base/uvm_factory.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_factory.svh): `m_types[uvm_object_wrapper]` | [ch7/test_assoc_class_key_order_is_stable](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch7/test_assoc_class_key_order_is_stable.sv), [ch7/test_assoc_string_empty_and_reverse_order](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch7/test_assoc_string_empty_and_reverse_order.sv) |

### Stage 3: config_db

| Feature | 1800-2023 | Where the pinned library uses it | kirimasim-tests |
| --- | --- | --- | --- |
| A parameterized class that extends a specialization of another, with its own static members | 8.25, 8.9 | [`src/base/uvm_config_db.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_config_db.svh): `class uvm_config_db#(type T=int) extends uvm_resource_db#(T)` | [ch8/test_param_class_extends_param_class](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_param_class_extends_param_class.sv), [ch8/test_parameterized_class_static_per_specialization](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_parameterized_class_static_per_specialization.sv) |
| A level-sensitive wait on a class property | 9.4.3 | [`src/base/uvm_resource_base.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_resource_base.svh): `wait (modified == 1)` | [ch9/test_ch9_extra_wait_forms](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch9/test_ch9_extra_wait_forms.sv) |

### Stage 4: sequence

| Feature | 1800-2023 | Where the pinned library uses it | kirimasim-tests |
| --- | --- | --- | --- |
| randomize() with inline constraints | 18.7 | [`src/macros/uvm_sequence_defines.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/macros/uvm_sequence_defines.svh): `randomize() with` in the sequence macros | [ch18/test_randomize_call_argument_lists_and_with_forms](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch18/test_randomize_call_argument_lists_and_with_forms.sv) |
| Random members and constraint blocks | 18.4, 18.5 | [`src/seq/uvm_sequence_library.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/seq/uvm_sequence_library.svh): `rand int unsigned sequence_count` | [ch18/test_rand_constraints_hold](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch18/test_rand_constraints_hold.sv), [ch18/test_constraint_block_all_forms](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch18/test_constraint_block_all_forms.sv) |
| Semaphores | 15.3 | [`src/seq/uvm_sequence_base.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/seq/uvm_sequence_base.svh): `semaphore m_sequence_state_mutex` | [ch15/test_semaphore_basic](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch15/test_semaphore_basic.sv) |
| fork with join_any, followed by disable fork | 9.3.2, 9.6.3 | [`src/seq/uvm_sequencer_base.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/seq/uvm_sequencer_base.svh): `join_any`, `disable fork` | [ch9/test_fork_join_block_timing](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch9/test_fork_join_block_timing.sv), [ch9/test_disable_fork_ends_loops_and_class_tasks](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch9/test_disable_fork_ends_loops_and_class_tasks.sv) |

### Stage 5: TLM

| Feature | 1800-2023 | Where the pinned library uses it | kirimasim-tests |
| --- | --- | --- | --- |
| Bounded mailboxes and their nonblocking methods | 15.4 | [`src/tlm1/uvm_tlm_fifos.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/tlm1/uvm_tlm_fifos.svh): `local mailbox #(T) m` | [ch15/test_mailbox_bounded_methods](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch15/test_mailbox_bounded_methods.sv) |
| Method calls through a handle whose type is a type parameter | 8.25 | [`src/tlm1/uvm_analysis_port.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/tlm1/uvm_analysis_port.svh): `m_imp.write (t)` in `uvm_analysis_imp #(type T=int, type IMP=int)` | None found; nearest: [ch8/test_class_typed_param](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_class_typed_param.sv) |
| Macros that paste a suffix into class names | 22.5.1 | [`src/macros/uvm_tlm_defines.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/macros/uvm_tlm_defines.svh): `uvm_blocking_put_imp` followed by the pasted `SFX` | [ch22/test_macro_quotes_escapes_and_paste](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch22/test_macro_quotes_escapes_and_paste.sv) |
| Arguments passed by reference | 13.5.2 | [`src/tlm2/uvm_tlm2_ifs.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/tlm2/uvm_tlm2_ifs.svh): `ref P p` | [ch13/test_ref_arg](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch13/test_ref_arg.sv) |

No simulation test of kirimasim-tests at `829671c2` calls a method through a member or argument whose type is a type parameter of its class, which is how an imp reaches its component; this is a candidate for kirimasim-tests. The search looked at every parameterized class in the simulation tests.

### Stage 6: register layer

| Feature | 1800-2023 | Where the pinned library uses it | kirimasim-tests |
| --- | --- | --- | --- |
| Streaming operators | 11.4.14 | [`src/reg/uvm_reg_map.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/reg/uvm_reg_map.svh): `{ >> {...}} = { << byte {...}}` | [ch11/test_streaming_pack_unpack](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch11/test_streaming_pack_unpack.sv) |
| Indexed part-selects | 11.5.1 | [`src/reg/uvm_reg_map.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/reg/uvm_reg_map.svh): `values[idx][8*i+:8]` | [ch11/test_part_select_variable_base](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch11/test_part_select_variable_base.sv) |
| Associative arrays indexed by class handles | 7.8.3 | [`src/reg/uvm_reg_map.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/reg/uvm_reg_map.svh): `m_regs_info[uvm_reg]` | [ch7/test_assoc_class_null_and_alias_keys](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch7/test_assoc_class_null_and_alias_keys.sv) |
| Constraint blocks with pre_randomize and post_randomize | 18.5, 18.6.2 | [`src/reg/uvm_reg_field.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/reg/uvm_reg_field.svh): `constraint uvm_reg_field_valid`, `pre_randomize()` | [ch18/test_constraint_block_all_forms](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch18/test_constraint_block_all_forms.sv), [ch18/test_pre_post_randomize](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch18/test_pre_post_randomize.sv) |
| Semaphores held across a read-modify-write | 15.3 | [`src/reg/uvm_reg.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/reg/uvm_reg.svh): `semaphore m_atomic` | [ch15/test_semaphore_keys_limit_concurrent_holders](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch15/test_semaphore_keys_limit_concurrent_holders.sv) |

HDL access (`uvm_hdl_*`) needs DPI and VPI, which the ordinary run does not link; [the HDL condition](testing.md#verilator-vpi-hdl-subset) measures it separately.

## Keeping the stages current

A new or changed test, or a changed helper, can change a stage. Check then fails until the record is rewritten:

```sh
python3 tools/kirimasim_stages.py update
python3 tools/kirimasim_stages.py check
```

`update` prints each added, removed or changed entry; review the change before committing it, and add an override with a reason when the markers place a test wrongly. A short set must keep tests of its own stage that are recorded with `verilator@5.052`.
