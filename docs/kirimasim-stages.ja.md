# kirimasimの立ち上げ段階

[English](kirimasim-stages.md) · [README](../README.ja.md) · [実行結果](results.ja.md)

立ち上げ段階は、simulatorがlibraryを動かせるようになるまでに出会うUVMの部分を順に並べたものです。kirimasimの進み具合を段階ごとに測れるようにします。このページでは、各テストの段階の決め方、段階ごとの代表の短いセット、kirimasimの現在の記録の段階別の内訳、各段階で必要になるSystemVerilogの機能と、それに対応するkirimasim-testsのテストを説明します。

- [段階を設ける理由](#段階を設ける理由)
- [テストの段階の決め方](#テストの段階の決め方)
- [短いセット](#短いセット)
- [kirimasimの現在の記録の段階別の内訳](#kirimasimの現在の記録の段階別の内訳)
- [段階ごとのSystemVerilogの機能](#段階ごとのsystemverilogの機能)
- [段階を最新に保つ](#段階を最新に保つ)

## 段階を設ける理由

kirimasimの現在の記録1081件のうち1072件は`uvm_object_wrapper`をunsupportedと報告し、残る9件は先にlibraryのAPIの欠落に当たります。1682入力には現在の記録がありません（[現在の結果](results.ja.md#現在のスナップショット)）。測ったテストがすべて同じ所で止まるため、記録からはsimulatorがどこまで進んだかが分かりません。テストごとの段階と段階ごとの短いセットがあれば、短いセットを実行して最初に通らない段階が分かり、下の機能の表から次に見るべき言語のテストをたどれます。

段階は、開発が扱う機能の主題でテストをまとめるmilestone M1〜M4（[milestoneのまとめ方](glossary.ja.md#範囲とカバレッジ)）とは別のものです。段階は期待値を変えず、metadataの項目も足しません。記録は別のfileなので、入力の指紋は変わりません。

## テストの段階の決め方

記録は[`coverage/kirimasim_stages.json`](../coverage/kirimasim_stages.json)で、[`tools/kirimasim_stages.py`](../tools/kirimasim_stages.py)が検査します。Checkはpushのたびにこの検査を実行します。

段階2〜6は、それぞれのUVMの部分を使っていることを見つける正規表現（marker）を持ちます。toolは、テストと、テストが`tests/`の下から集めるfile（`:files:`と、そこからincludeするfile）を、commentとstring literalを除いてから探します。テストの段階は、markerが一致する最も高い段階で、どれも一致しなければ段階1です。analysis portにも書くdriverのように2つの段階のmarkerを持つテストは、simulatorが両方の部分を必要とするため、高い方の段階になります。

| 段階 | UVMの部分 | marker（例） | テスト | Verilator 5.052で記録済み | 短いセット |
| --- | --- | --- | --- | --- | --- |
| 0 | uvm_pkgだけ | なし。overrideで決める | 1 | 1 | 1 |
| 1 | 最小のrun_test | なし。既定の段階 | 1030 | 871 | 5 |
| 2 | factory | `::type_id`、`uvm_factory`、`uvm_object_wrapper`、override、`create_*_by_name`、`get_type()` | 95 | 85 | 5 |
| 3 | config_db | `uvm_config_db`、`uvm_resource*`、`apply_config_settings` | 111 | 91 | 5 |
| 4 | sequence | `uvm_sequence`、`uvm_sequencer`、`uvm_driver`、`start_item`、`` `uvm_do ``などのsequenceのmacro | 326 | 268 | 5 |
| 5 | TLM | port・export・imp、`uvm_analysis_*`、`uvm_tlm_*`、`` `uvm_*_imp_decl ``、`uvm_subscriber` | 250 | 224 | 5 |
| 6 | register層 | `uvm_reg*`、`uvm_mem*`、`uvm_vreg*`、`uvm_hdl_*`、register層のenum | 950 | 753 | 5 |
| 計 | | | 2763 | 2293 | 31 |

紛らわしいものは意図して除いています。sequence item（`uvm_sequence_item`）だけではテストは段階4にならず、`uvm_reg_data_t`などのtypedefだけでは段階6にならず、`` `uvm_do_callbacks ``はcallbackのmacroでsequenceのmacroではありません。toolの単体テストが、短いcodeの断片でこれらを確かめます。

markerで決められないテストの段階は、英語と日本語の理由を付けたoverrideで決めます。段階0になるのはこの方法だけです。[test_uvm_pkg_import_only_reaches_package_items](../tests/u01/test_uvm_pkg_import_only_reaches_package_items.sv)はuvm_pkgをimportし、1つのenum値をimportとpackage名の両方から名指しするだけで、UVM objectを作らず、run_testも呼びません。期待値は1.4.5とF.2.2.4から導き、Verilator 5.052のseed 1と73で一致します。

どの段階でもuvm_pkg全体をcompileします。そのため、library内のどこかにsimulatorがcompileできない構文があれば、すべての段階が止まります。現在の記録はこの状態です。段階が表すのは、テストがpackageそのものに加えてelaborateし実行するもの、つまり特殊化するparameter付きclassと、実行するlibraryのcodeです。

## 短いセット

各段階は10件までの代表を持ちます。現在のセットは段階1〜6に各5件、段階0に1件です。代表は`verilator@5.052`で記録済みの実行テストで、固定版libraryでseed 1と73の期待値が一致し、DPIやback-endの条件も実行時引数も要りません。同じ段階の中では、その段階の主な題材を扱う小さなテストを選んでいます。

| 段階 | テスト |
| --- | --- |
| 0 | [u01/test_uvm_pkg_import_only_reaches_package_items](../tests/u01/test_uvm_pkg_import_only_reaches_package_items.sv) |
| 1 | [u13/test_test_argument_selection_creates_the_registered_test_under_the_implicit_root](../tests/u13/test_test_argument_selection_creates_the_registered_test_under_the_implicit_root.sv)<br>[u09/test_common_phases_before_run_stay_at_zero_and_run_end_shares_the_final_time](../tests/u09/test_common_phases_before_run_stay_at_zero_and_run_end_shares_the_final_time.sv)<br>[u13/test_component_run_phase_return_does_not_end_an_objection_held_phase](../tests/u13/test_component_run_phase_return_does_not_end_an_objection_held_phase.sv)<br>[u06/test_report_server_counts_severity_and_id](../tests/u06/test_report_server_counts_severity_and_id.sv)<br>[u05/test_object_rename_updates_identity](../tests/u05/test_object_rename_updates_identity.sv) |
| 2 | [u08/test_factory_type_override_replaces_previous](../tests/u08/test_factory_type_override_replaces_previous.sv)<br>[u08/test_factory_instance_override_is_scoped](../tests/u08/test_factory_instance_override_is_scoped.sv)<br>[u08/test_factory_type_alias_creates_original_type](../tests/u08/test_factory_type_alias_creates_original_type.sv)<br>[u08/test_object_registry_create_uses_parent_context](../tests/u08/test_object_registry_create_uses_parent_context.sv)<br>[u05/test_object_wrapper_follows_dynamic_type](../tests/u05/test_object_wrapper_follows_dynamic_type.sv) |
| 3 | [uC/test_config_db_exists_checks_scope_and_field](../tests/uC/test_config_db_exists_checks_scope_and_field.sv)<br>[uC/test_config_db_omitted_type_matches_int_without_merging_string_settings](../tests/uC/test_config_db_omitted_type_matches_int_without_merging_string_settings.sv)<br>[uC/test_resource_pool_scope_collection_includes_an_unnamed_visible_resource](../tests/uC/test_resource_pool_scope_collection_includes_an_unnamed_visible_resource.sv)<br>[u13/test_component_default_automatic_config_calls_application_during_build](../tests/u13/test_component_default_automatic_config_calls_application_during_build.sv)<br>[uC/test_configuration_and_resources_remain_accessible_at_selected_positive_times](../tests/uC/test_configuration_and_resources_remain_accessible_at_selected_positive_times.sv) |
| 4 | [u14/test_sequence_start_orders_default_hooks](../tests/u14/test_sequence_start_orders_default_hooks.sv)<br>[u15/test_sequencer_execute_item_waits_for_driver_acknowledgement](../tests/u15/test_sequencer_execute_item_waits_for_driver_acknowledgement.sv)<br>[u14/test_sequence_lock_blocks_other_sequence_until_unlock](../tests/u14/test_sequence_lock_blocks_other_sequence_until_unlock.sv)<br>[u15/test_sequencer_try_next_item_returns_null_when_no_sequence_is_ready](../tests/u15/test_sequencer_try_next_item_returns_null_when_no_sequence_is_ready.sv)<br>[uB/test_sequence_macro_do_creates_randomizes_and_sends_item](../tests/uB/test_sequence_macro_do_creates_randomizes_and_sends_item.sv) |
| 5 | [u12/test_blocking_put_port_forwards_values_to_fifo](../tests/u12/test_blocking_put_port_forwards_values_to_fifo.sv)<br>[u12/test_tlm_fifo_blocking_get_waits_until_put](../tests/u12/test_tlm_fifo_blocking_get_waits_until_put.sv)<br>[u12/test_tlm_analysis_fifo_write_preserves_arrival_order](../tests/u12/test_tlm_analysis_fifo_write_preserves_arrival_order.sv)<br>[u12/test_tlm2_blocking_socket_forwards_payload_delay_and_read_result](../tests/u12/test_tlm2_blocking_socket_forwards_payload_delay_and_read_result.sv)<br>[uB/test_tlm_analysis_imp_decl_preserves_object_handles_and_selected_input](../tests/uB/test_tlm_analysis_imp_decl_preserves_object_handles_and_selected_input.sv) |
| 6 | [u18/test_reg_field_set_changes_desired_without_predicting_mirror](../tests/u18/test_reg_field_set_changes_desired_without_predicting_mirror.sv)<br>[u18/test_reg_field_hard_reset_restores_desired_and_mirror](../tests/u18/test_reg_field_hard_reset_restores_desired_and_mirror.sv)<br>[u18/test_reg_frontdoor_write_with_auto_predict_updates_bus_storage_and_mirror](../tests/u18/test_reg_frontdoor_write_with_auto_predict_updates_bus_storage_and_mirror.sv)<br>[u18/test_reg_frontdoor_read_with_auto_predict_returns_bus_data_and_updates_mirror](../tests/u18/test_reg_frontdoor_read_with_auto_predict_returns_bus_data_and_updates_mirror.sv)<br>[uE/test_hw_reset_sequence_detects_an_incorrect_storage_reset_value](../tests/uE/test_hw_reset_sequence_detects_an_incorrect_storage_reset_value.sv) |

短いセットは、[kirimasimのrunner](testing.ja.md#スイートの実行)にそのまま渡せるテストのpathとして出力されます。段階1までを実行し、結果を段階ごとにまとめる例です：

```sh
python3 tools/kirimasim_stages.py short --upto 1
python3 tools/run_kirimasim.py --json out/kirimasim-stages.json $(python3 tools/kirimasim_stages.py short --upto 1)
python3 tools/kirimasim_stages.py summary --results out/kirimasim-stages.json
```

kirimasimの測定には、このrepositoryに含まれない実行fileが必要です。このページはkirimasimの新しい測定を加えていません。

## kirimasimの現在の記録の段階別の内訳

kirimasimの現在の記録1081件（[保持するguestの記録](results.ja.md#記録の合算)）を、`tools/kirimasim_stages.py summary --results`で段階ごとに数えたものです：

| 段階 | テスト | `unsupported` | `fail` | 未測定 |
| --- | --- | --- | --- | --- |
| 0 | 1 | 0 | 0 | 1 |
| 1 | 1030 | 320 | 0 | 710 |
| 2 | 95 | 53 | 0 | 42 |
| 3 | 111 | 17 | 0 | 94 |
| 4 | 326 | 197 | 6 | 123 |
| 5 | 250 | 170 | 1 | 79 |
| 6 | 950 | 315 | 2 | 633 |
| 計 | 2763 | 1072 | 9 | 1682 |

最も多い理由はどの段階でも同じで、`uvm_object_wrapper`がまだ実装されていないことです。`fail`の9件は先にlibraryのAPIの欠落に当たります。sequence libraryのmethodが6件（段階4）、TLMの時刻のmethodが1件（段階5）、HDL pathのsliceのmethodが2件（段階6）です。短いセットの31件のうち23件に現在の記録があり、すべて`unsupported`です。段階0のテストは新しく、未測定です。

## 段階ごとのSystemVerilogの機能

各段階は、それより前の段階の機能も必要とします。表には、その段階で新たに加わるものを載せています。3列目は[固定版library](provenance.ja.md#ライブラリと規格)でその機能を使う箇所で、lockしたcommitへlinkしています。最後の列は、最初の1800-2023の条項がその機能の条項である[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests/tree/829671c22f7dcbcaced78b59b7fe14f721206c5b)のテストで、commit `829671c2`へlinkしています。それらのoracleはkirimasim-testsにあります。これらをkirimasimで実行すれば、どの言語機能が段階の通過を妨げているかが分かります。

### 段階0：uvm_pkgだけ

| 機能 | 1800-2023 | 固定版libraryで使う箇所 | kirimasim-tests |
| --- | --- | --- | --- |
| package、import、scope解決演算子 | 26.2, 26.3 | [`src/uvm_pkg.sv`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/uvm_pkg.sv): `package uvm_pkg` | [ch26/test_package_import_item_list](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch26/test_package_import_item_list.sv), [ch26/test_package_explicit_import_only_named](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch26/test_package_explicit_import_only_named.sv) |
| fileのinclude、引数付きmacro、条件付きcompile | 22.4, 22.5.1, 22.6 | [`src/uvm_macros.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/uvm_macros.svh): includeとifndefの指示子 | [ch22/test_include_nested](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch22/test_include_nested.sv), [ch22/test_macro_use_space_before_arguments](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch22/test_macro_use_space_before_arguments.sv), [ch22/test_ifdef_nested](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch22/test_ifdef_nested.sv) |
| 継承、virtual method、抽象class | 8.13, 8.20, 8.21 | [`src/base/uvm_object.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_object.svh): `virtual class uvm_object` | [ch8/test_class_inherit](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_class_inherit.sv), [ch8/test_virtual_method](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_virtual_method.sv), [ch8/test_abstract_class_basic](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_abstract_class_basic.sv) |
| class外の宣言、typedef class、localとprotectedのmember | 8.24, 8.27, 8.18 | [`src/base/uvm_component.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_component.svh): `extern`宣言117個 | [ch8/test_class_extern](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_class_extern.sv), [ch8/test_forward_class_typedef_parameterized](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_forward_class_typedef_parameterized.sv), [ch8/test_class_local_protected_access_and_modifier_order](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_class_local_protected_access_and_modifier_order.sv) |
| parameter付きclassと、特殊化ごとのstatic member | 8.25, 8.9, 8.10 | [`src/base/uvm_registry.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_registry.svh): `static this_type m_inst` | [ch8/test_parameterized_class_static_per_specialization](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_parameterized_class_static_per_specialization.sv), [ch8/test_class_static_method](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_class_static_method.sv) |
| initial procedureより前に実行するstaticの初期化 | 6.8, 6.21 | [`src/base/uvm_registry.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_registry.svh): `local static bit m__initialized=__deferred_init()` | [ch6/test_class_static_init_order](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch6/test_class_static_init_order.sv), [ch6/test_static_initializer_runs_once](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch6/test_static_initializer_runs_once.sv) |
| string、動的配列、queue、連想配列 | 6.16, 7.5, 7.10, 7.8 | [`src/base/uvm_globals.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_globals.svh): queueの`uvm_deferred_init` | [ch6/test_string_methods_3](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch6/test_string_methods_3.sv), [ch7/test_dynamic_array_ops](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch7/test_dynamic_array_ops.sv), [ch7/test_queue_push_pop](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch7/test_queue_push_pop.sv), [ch7/test_assoc_string_empty_and_reverse_order](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch7/test_assoc_string_empty_and_reverse_order.sv) |
| enumとそのmethod | 6.19 | [`src/base/uvm_globals.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_globals.svh): `uvm_enum_wrapper`の`first()`、`next()`、`name()` | [ch6/test_enum_named_constants](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch6/test_enum_named_constants.sv), [ch6/test_enum_first_last](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch6/test_enum_first_last.sv) |

### 段階1：最小のrun_test

| 機能 | 1800-2023 | 固定版libraryで使う箇所 | kirimasim-tests |
| --- | --- | --- | --- |
| join_noneのfork、wait fork、disable fork | 9.3.2, 9.6.1, 9.6.3 | [`src/base/uvm_phase_hopper.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_phase_hopper.svh): `fork`、`disable fork`; [`src/base/uvm_objection.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_objection.svh): `wait fork` | [ch9/test_join_none_children_start_after_parent_blocks](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch9/test_join_none_children_start_after_parent_blocks.sv), [ch9/test_wait_fork_ignores_grandchildren](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch9/test_wait_fork_ignores_grandchildren.sv), [ch9/test_disable_fork_ends_loops_and_class_tasks](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch9/test_disable_fork_ends_loops_and_class_tasks.sv) |
| processの制御：self、status、kill、await | 9.7 | [`src/base/uvm_phase.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_phase.svh): `kill()`; [`src/base/uvm_process_guard_base.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_process_guard_base.svh): `status()`、`kill()` | [ch9/test_process_self_status_kill](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch9/test_process_self_status_kill.sv), [ch9/test_process_class_control](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch9/test_process_class_control.sv) |
| 名前付きeventと、levelで待つwait | 15.5, 9.4.3 | [`src/base/uvm_event.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_event.svh): `->m_event`; [`src/base/uvm_objection.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_objection.svh): `wait (...)` | [ch15/test_event_triggered](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch15/test_event_triggered.sv), [ch15/test_event_wait_after_trigger](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch15/test_event_wait_after_trigger.sv), [ch9/test_ch9_extra_wait_forms](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch9/test_ch9_extra_wait_forms.sv) |
| parameter付きmailbox | 15.4 | [`src/base/uvm_phase.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_phase.svh): `mailbox #(uvm_phase) m_phase_hopper` | [ch15/test_mailbox_basic](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch15/test_mailbox_basic.sv), [ch15/test_mailbox_messages_between_processes](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch15/test_mailbox_messages_between_processes.sv) |
| class handle間の$cast | 8.16 | [`src/base/uvm_root.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_root.svh): `$cast` | [ch8/test_cast_class](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_cast_class.sv) |
| with節付きの配列の検索と並べ替えのmethod | 7.12.1, 7.12.2 | [`src/base/uvm_phase.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_phase.svh): `find_index(...) with (...)`; [`src/base/uvm_root.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_root.svh): `sort() with (...)` | [ch7/test_array_find_index](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch7/test_array_find_index.sv), [ch7/test_array_sort](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch7/test_array_sort.sv) |
| $value$plusargs | 21.6 | [`src/base/uvm_root.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_root.svh): `+UVM_TESTNAME`; [`src/base/uvm_cmdline_report.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_cmdline_report.svh): `+UVM_VERBOSITY` | [ch21/test_value_plusargs_first_match](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch21/test_value_plusargs_first_match.sv) |
| $sformatf、0の遅延、$finish | 21.3.3, 9.4.1, 20.2 | [`src/base/uvm_root.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_root.svh): `$sformatf`、`#0`、`$finish` | [ch21/test_sformatf](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch21/test_sformatf.sv), [ch9/test_fork_child_zero_delay](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch9/test_fork_child_zero_delay.sv), [ch20/test_finish_ends_simulation](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch20/test_finish_ends_simulation.sv) |

### 段階2：factory

| 機能 | 1800-2023 | 固定版libraryで使う箇所 | kirimasim-tests |
| --- | --- | --- | --- |
| parameter付きclassのclass scopeを通したstatic methodの呼出し | 8.23, 8.25.1 | [`src/base/uvm_registry.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_registry.svh): `type_id::create`が呼ぶ`static function T create` | [ch8/test_class_scope_nested_class_and_static_access](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_class_scope_nested_class_and_static_access.sv), [ch8/test_extern_method_class_scope_current_specialization](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_extern_method_class_scope_current_specialization.sv) |
| class handleとstringを添字とする連想配列 | 7.8.3, 7.8.2 | [`src/base/uvm_factory.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_factory.svh): `m_types[uvm_object_wrapper]` | [ch7/test_assoc_class_key_order_is_stable](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch7/test_assoc_class_key_order_is_stable.sv), [ch7/test_assoc_string_empty_and_reverse_order](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch7/test_assoc_string_empty_and_reverse_order.sv) |

### 段階3：config_db

| 機能 | 1800-2023 | 固定版libraryで使う箇所 | kirimasim-tests |
| --- | --- | --- | --- |
| 別のclassの特殊化を継承するparameter付きclassと、そのstatic member | 8.25, 8.9 | [`src/base/uvm_config_db.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_config_db.svh): `class uvm_config_db#(type T=int) extends uvm_resource_db#(T)` | [ch8/test_param_class_extends_param_class](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_param_class_extends_param_class.sv), [ch8/test_parameterized_class_static_per_specialization](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_parameterized_class_static_per_specialization.sv) |
| class propertyをlevelで待つwait | 9.4.3 | [`src/base/uvm_resource_base.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/base/uvm_resource_base.svh): `wait (modified == 1)` | [ch9/test_ch9_extra_wait_forms](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch9/test_ch9_extra_wait_forms.sv) |

### 段階4：sequence

| 機能 | 1800-2023 | 固定版libraryで使う箇所 | kirimasim-tests |
| --- | --- | --- | --- |
| inline制約付きのrandomize() | 18.7 | [`src/macros/uvm_sequence_defines.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/macros/uvm_sequence_defines.svh): sequenceのmacroの`randomize() with` | [ch18/test_randomize_call_argument_lists_and_with_forms](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch18/test_randomize_call_argument_lists_and_with_forms.sv) |
| random memberと制約block | 18.4, 18.5 | [`src/seq/uvm_sequence_library.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/seq/uvm_sequence_library.svh): `rand int unsigned sequence_count` | [ch18/test_rand_constraints_hold](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch18/test_rand_constraints_hold.sv), [ch18/test_constraint_block_all_forms](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch18/test_constraint_block_all_forms.sv) |
| semaphore | 15.3 | [`src/seq/uvm_sequence_base.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/seq/uvm_sequence_base.svh): `semaphore m_sequence_state_mutex` | [ch15/test_semaphore_basic](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch15/test_semaphore_basic.sv) |
| join_anyのforkと、その後のdisable fork | 9.3.2, 9.6.3 | [`src/seq/uvm_sequencer_base.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/seq/uvm_sequencer_base.svh): `join_any`、`disable fork` | [ch9/test_fork_join_block_timing](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch9/test_fork_join_block_timing.sv), [ch9/test_disable_fork_ends_loops_and_class_tasks](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch9/test_disable_fork_ends_loops_and_class_tasks.sv) |

### 段階5：TLM

| 機能 | 1800-2023 | 固定版libraryで使う箇所 | kirimasim-tests |
| --- | --- | --- | --- |
| 大きさを決めたmailboxと、そのnonblockingのmethod | 15.4 | [`src/tlm1/uvm_tlm_fifos.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/tlm1/uvm_tlm_fifos.svh): `local mailbox #(T) m` | [ch15/test_mailbox_bounded_methods](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch15/test_mailbox_bounded_methods.sv) |
| 型parameterを型とするhandleを通したmethodの呼出し | 8.25 | [`src/tlm1/uvm_analysis_port.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/tlm1/uvm_analysis_port.svh): `uvm_analysis_imp #(type T=int, type IMP=int)`の`m_imp.write (t)` | 見つからない。近いもの：[ch8/test_class_typed_param](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch8/test_class_typed_param.sv) |
| class名に接尾辞を連結するmacro | 22.5.1 | [`src/macros/uvm_tlm_defines.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/macros/uvm_tlm_defines.svh): `uvm_blocking_put_imp`に`SFX`を連結 | [ch22/test_macro_quotes_escapes_and_paste](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch22/test_macro_quotes_escapes_and_paste.sv) |
| 参照渡しの引数 | 13.5.2 | [`src/tlm2/uvm_tlm2_ifs.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/tlm2/uvm_tlm2_ifs.svh): `ref P p` | [ch13/test_ref_arg](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch13/test_ref_arg.sv) |

commit `829671c2`のkirimasim-testsには、classの型parameterを型とするmemberや引数を通してmethodを呼ぶ実行テストがありません。impはこの形でcomponentに届くため、kirimasim-testsに加える候補です。実行テストにあるparameter付きclassをすべて調べました。

### 段階6：register層

| 機能 | 1800-2023 | 固定版libraryで使う箇所 | kirimasim-tests |
| --- | --- | --- | --- |
| streaming演算子 | 11.4.14 | [`src/reg/uvm_reg_map.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/reg/uvm_reg_map.svh): `{ >> {...}} = { << byte {...}}` | [ch11/test_streaming_pack_unpack](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch11/test_streaming_pack_unpack.sv) |
| 添字付きのpart-select | 11.5.1 | [`src/reg/uvm_reg_map.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/reg/uvm_reg_map.svh): `values[idx][8*i+:8]` | [ch11/test_part_select_variable_base](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch11/test_part_select_variable_base.sv) |
| class handleを添字とする連想配列 | 7.8.3 | [`src/reg/uvm_reg_map.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/reg/uvm_reg_map.svh): `m_regs_info[uvm_reg]` | [ch7/test_assoc_class_null_and_alias_keys](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch7/test_assoc_class_null_and_alias_keys.sv) |
| 制約blockと、pre_randomize・post_randomize | 18.5, 18.6.2 | [`src/reg/uvm_reg_field.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/reg/uvm_reg_field.svh): `constraint uvm_reg_field_valid`、`pre_randomize()` | [ch18/test_constraint_block_all_forms](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch18/test_constraint_block_all_forms.sv), [ch18/test_pre_post_randomize](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch18/test_pre_post_randomize.sv) |
| read-modify-writeの間に保持するsemaphore | 15.3 | [`src/reg/uvm_reg.svh`](https://github.com/accellera-official/uvm-core/blob/78c06547a2a0a29b3dc9dcafae62b75b2ff61544/src/reg/uvm_reg.svh): `semaphore m_atomic` | [ch15/test_semaphore_keys_limit_concurrent_holders](https://github.com/kurochan001/kirimasim-tests/blob/829671c22f7dcbcaced78b59b7fe14f721206c5b/tests/ch15/test_semaphore_keys_limit_concurrent_holders.sv) |

HDL access（`uvm_hdl_*`）はDPIとVPIを必要とし、通常の実行ではlinkしません。[HDLの条件](testing.ja.md#verilatorのvpi-hdl部分集合)で別に測ります。

## 段階を最新に保つ

テストの追加や変更、helperの変更で、段階が変わることがあります。そのときは、記録を書き直すまでCheckが失敗します：

```sh
python3 tools/kirimasim_stages.py update
python3 tools/kirimasim_stages.py check
```

`update`は追加・削除・変更した項目を1件ずつ出力します。commitの前に変更を見直し、markerが誤った段階に置くテストには理由を付けたoverrideを加えてください。短いセットは、`verilator@5.052`で記録済みの、自分の段階のテストを保つ必要があります。
