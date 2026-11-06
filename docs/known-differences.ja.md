# 既知差分

[English](known-differences.md) · [README](../README.ja.md) · [FAQ](faq.ja.md)

結果に対応するソースはテストIDのファイル名部分でこのページを検索し、メタデータ・期待値ファイル・失敗条件の調べ方は[差分を調べる](reading-guide.ja.md#差分を調べる)の手順で確認できます。

差分は特定のシミュレータ／ライブラリ／入力の条件に対するもので、runner出力での表示は[statusの定義](faq.ja.md#q5-passfailknownunsupportedはどう違いますか)で説明しています。

現在の2470件と、固定したAccellera UVM 2020.3.1についての記録です。
不一致はテストの結果であり、それだけではシミュレータ・ライブラリ・期待値のどれが原因かは決まりません。

差分の件数は[実測の内訳](results.ja.md#結果の解釈)で確認し、個別の入力を調べるときは[ライブラリの注記](known-differences.ja.md#固定版ライブラリの制約)、[ソースの分類一覧](known-differences.ja.md#specのみのテスト)、[シミュレータとライブラリの条件](known-differences.ja.md#シミュレータとライブラリの組み合わせ)を使ってください。

個別のソースへのリンクは話題ごとの説明と[一覧](#specのみのテスト)にあり、メタデータから期待する観測と実行条件を確認する方法は[テスト形式の説明](testing.ja.md#テストの形式)で案内しています。

register pathの標準view 8入力はget_slices欠落でbuild停止し、別のmember-view controlは7件一致と祖先ごとの既定kind差分1件です。物理6件は別HDL条件で両seed一致し、通常ではDPI未linkを保持し、[pathのFAQ](faq.ja.md#register-hdl-pathと観測の前提)で条件を説明しています。

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

新規の正時間force_time 8入力は別HDL条件で両seed一致し、通常はDPI未linkのspec-onlyを保持します。既存2283通常記録と20 HDL記録は未変更で、[期間のFAQ](faq.ja.md#正時間force_timeの観測)で部分契約の補強を説明しています。

- [test_hdl_force_time_reg8_same_targets](../tests/u19/test_hdl_force_time_reg8_same_targets.sv).
- [test_hdl_force_time_reg8_distinct_targets](../tests/u19/test_hdl_force_time_reg8_distinct_targets.sv).
- [test_hdl_force_time_reg40_same_targets](../tests/u19/test_hdl_force_time_reg40_same_targets.sv).
- [test_hdl_force_time_reg40_distinct_targets](../tests/u19/test_hdl_force_time_reg40_distinct_targets.sv).
- [test_hdl_force_time_wire8_same_targets](../tests/u19/test_hdl_force_time_wire8_same_targets.sv).
- [test_hdl_force_time_wire8_distinct_targets](../tests/u19/test_hdl_force_time_wire8_distinct_targets.sv).
- [test_hdl_force_time_wire40_same_targets](../tests/u19/test_hdl_force_time_wire40_same_targets.sv).
- [test_hdl_force_time_wire40_distinct_targets](../tests/u19/test_hdl_force_time_wire40_distinct_targets.sv).

新規force／release 9件は別HDL条件で両seed一致し、通常runnerではDPI未linkのspec-onlyを保持します。既存11件もbackend変更後に再測定し、条件の区別は[HDLのFAQ](faq.ja.md#hdlのforceとreleaseの条件)で説明しています。

- [test_hdl_force_release_reg8](../tests/u19/test_hdl_force_release_reg8.sv).
- [test_hdl_force_release_read_reg8](../tests/u19/test_hdl_force_release_read_reg8.sv).
- [test_hdl_force_release_wire8](../tests/u19/test_hdl_force_release_wire8.sv).
- [test_hdl_force_release_read_wire8](../tests/u19/test_hdl_force_release_read_wire8.sv).
- [test_hdl_force_release_reg40](../tests/u19/test_hdl_force_release_reg40.sv).
- [test_hdl_force_release_read_reg40](../tests/u19/test_hdl_force_release_read_reg40.sv).
- [test_hdl_force_release_wire40](../tests/u19/test_hdl_force_release_wire40.sv).
- [test_hdl_force_release_read_wire40](../tests/u19/test_hdl_force_release_read_wire40.sv).
- [test_hdl_force_release_failures_keep_independent_controls](../tests/u19/test_hdl_force_release_failures_keep_independent_controls.sv).

新規adapter親context 8入力は両seed一致ですが、既存bus値・callback・printerの差分は保持し、明示caller-parentと未規定do_clone prototypeの範囲は[親contextのFAQ](faq.ja.md#adapterのsequence-context)で説明しています。

tree／lineの未設定peer 4入力では型名とsizeのgetterが必要な1に対して0を返します。本体の明示可視性行と別の明示peer controlは一致しても元入力をpassにはせず、[出力制御のFAQ](faq.ja.md#printerの属性と出力時の制御)で解釈を説明しています。

- [test_printer_line_textual_columns_follow_controls_after_collection](../tests/u16/test_printer_line_textual_columns_follow_controls_after_collection.sv).
- [test_printer_line_textual_columns_follow_controls_before_collection](../tests/u16/test_printer_line_textual_columns_follow_controls_before_collection.sv).
- [test_printer_tree_textual_columns_follow_controls_after_collection](../tests/u16/test_printer_tree_textual_columns_follow_controls_after_collection.sv).
- [test_printer_tree_textual_columns_follow_controls_before_collection](../tests/u16/test_printer_tree_textual_columns_follow_controls_before_collection.sv).

新規policy差し替え10入力は両seedで一致しますが、既存のprinter／copier設定やrecorder-linkの差分は保持し、[policyのFAQ](faq.ja.md#policy差し替えと型付きobject-stream)で選択条件を説明しています。

正準bus操作の監査は、register／memory、read／write、3種類の幅にわたるbig-endian 12入力の値の差分をseed 1で保持し、seed 73はありません。
単一wordではbyte反転、分割では選択write部分やread値の0を観測し、request件数と幅が正しくても全入力の不一致をpassにはしません。
little-endian 12入力は両seedで一致します。独自の数値word adapterはitem変換前の正準requestを記録し、既存の組み込みTLM-byte差分は未変更です。
simulator／libraryの原因や独立した不具合12件を割り当てず、[bus操作のFAQ](faq.ja.md#正準bus操作)で解釈を説明しています。

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

recorder-linkの期間では、free済み端点6入力がseed 1で必要なerrorを観測せず、seed 73はありません。
直接free、close後free、両端点free、open-recorder flush、所有stream freeを分けます。
警告はERROR／FATALの観測を満たしません。open／closed端点の8入力は両seedで一致しますが、free後の義務をpassにしません。
外部databaseやerror後の回復は推論せず、[期間のFAQ](faq.ja.md#recorderのlink可能期間)で範囲を説明しています。

- [左recorderを直接freeし右はopen](../tests/u16/test_recorder_link_window_freed_left_related.sv).
- [close後に右recorderをfree](../tests/u16/test_recorder_link_window_freed_closed_right_parent_child.sv).
- [object参照を保持したまま両端点をfree](../tests/u16/test_recorder_link_window_both_freed_cause_effect.sv).
- [openの左recorderをflushによってfree](../tests/u16/test_recorder_link_window_flushed_left_related.sv).
- [所有streamが両端点recorderをfree](../tests/u16/test_recorder_link_window_freed_stream_parent_child.sv).
- [右の所有streamをfreeし左streamはopen](../tests/u16/test_recorder_link_window_freed_other_stream_cause_effect.sv).

ここでの限定した解釈は、食い違う記述をテストがどう読むかを明示してレビューの余地を残すもので、その限界の例は[照会のFAQ](faq.ja.md#q281-専用get_globalはpoolとitemのどちらを返しますか)で確認できます。

専用global poolの監査は、限定したbuild差分2件を保持します。印刷get_global返却型はpool receiverを要求し、本文とgeneric methodはitemを指します。
item型の既存束縛、alias／状態、有限の待機は別に一致しても、印刷型の前提をpassにせず、存在しないkeyの静的動作も決めません。
宣言probe 2件のruntime markerは静的受理だけを示します。シミュレータ／libraryの原因や無条件の独立不具合数は認定しません。
[照会のFAQ](faq.ja.md#専用global照会と対応付けの修正)を参照してください。

- [eventの印刷pool receiver](../tests/u10/test_pool_global_event_printed_pool_return_type.sv)。
- [barrierの印刷pool receiver](../tests/u10/test_pool_global_barrier_printed_pool_return_type.sv)。

virtual照会の監査は差分4件を保持します。限定したoverview基底型のbuild 2件はruntimeがなく、狭いconstructor／getterのbyte幅と無関係mapのERROR欠落はseed 1で異なりseed 73結果がありません。
object基底と有効mapのcontrolは別に一致します。constructor名やRW fallbackの観測が一致しても、幅や必須診断が異なる入力をpassにしません。
overview／classの文言とgetter連鎖の原因は未解決で、独立した不具合4個とは認定しません。[照会のFAQ](faq.ja.md#virtual-registerの照会と宣言の境界)を参照してください。

- [狭いconstructor構成のmemory単位byte幅](../tests/u18/test_vreg_query_constructor_narrow.sv)。
- [overview記載のfield基底型](../tests/u18/test_vreg_query_field_overview_literal_base.sv)。
- [overview記載のregister基底型](../tests/u18/test_vreg_query_register_overview_literal_base.sv)。
- [無関係mapのrightsとERROR](../tests/u18/test_vreg_query_rights_unrelated_map_error_and_rw_fallback.sv)。

走査の宣言監査は新しい差分5件を保持します。STRUCTURE単独指定の依存VISITOR build 3件と、
get_immediate_children／acceptを省略した具象派生型の受理2件で、いずれもruntime seed結果はありません。
明示型と完全派生型のcontrolは別の入力同一性で一致します。固定宣言は規格どおりの依存既定値を記述しており、build診断から原因を断定しません。
非virtual／pure acceptの文言は別に残します。[走査の宣言](faq.ja.md#走査の宣言と既定値)を参照してください。

- [acceptを省略した具象adapter](../tests/uF/test_traversal_decl_adapter_missing_accept_requires_compile_rejection.sv)。
- [bottom_upの依存VISITOR既定値](../tests/uF/test_traversal_decl_bottom_up_default_visitor_traverses_through_the_declared_base.sv)。
- [by_levelの依存VISITOR既定値](../tests/uF/test_traversal_decl_by_level_default_visitor_traverses_through_the_declared_base.sv)。
- [childrenを省略した具象proxy](../tests/uF/test_traversal_decl_proxy_missing_children_requires_compile_rejection.sv)。
- [top_downの依存VISITOR既定値](../tests/uF/test_traversal_decl_top_down_default_visitor_traverses_through_the_declared_base.sv)。

recording／scalar macroの監査は測定差分11件を追加します。厳密な3引数attributeのbuild 6件、印刷enum-unpackの引数build 1件、
33-bit整数hookのruntime 2件、既定attributeのruntime 2件です。runtime差分はseed 1だけで、buildにはruntime結果がありません。
追加引数を許容するattribute control 6件、印刷enumN control、直接small-field API controlは別に一致し、後ろの2件は直接義務も持ちます。
enumのsignature／本文とTR_HANDLE／0引数accessorの境界は限定した解釈に残し、11入力を独立した不具合11個とは認定しません。
[macroの条件](faq.ja.md#recordingとscalar-macroの条件)を参照してください。

- [型付きdynamic arrayのattribute（3引数）](../tests/uB/test_record_macro_attribute_dynamic_array_preserves_the_original_type_and_handle.sv)。
- [選択したrecorderへの既定attribute](../tests/uB/test_record_macro_attribute_handle_uses_the_declared_default_recorder_route.sv)。
- [型付きpacked structのattribute（3引数）](../tests/uB/test_record_macro_attribute_packed_struct_preserves_the_original_type_and_handle.sv)。
- [peerのhandleを指定した既定attribute](../tests/uB/test_record_macro_attribute_peer_uses_the_declared_default_recorder_route.sv)。
- [型付きrealのattribute（3引数）](../tests/uB/test_record_macro_attribute_real_preserves_the_original_type_and_handle.sv)。
- [型付きstringのattribute（3引数）](../tests/uB/test_record_macro_attribute_string_preserves_the_original_type_and_handle.sv)。
- [型付きtimeのattribute（3引数）](../tests/uB/test_record_macro_attribute_time_preserves_the_original_type_and_handle.sv)。
- [型付きwide integralのattribute（3引数）](../tests/uB/test_record_macro_attribute_wide_integral_preserves_the_original_type_and_handle.sv)。
- [radixを明示した小整数macro](../tests/uB/test_record_macro_int_33_explicit_radix_uses_the_declared_recorder_route.sv)。
- [radixを省略した小整数macro](../tests/uB/test_record_macro_int_default_radix_uses_the_declared_default_recorder_route.sv)。
- [印刷された1引数のenum unpack](../tests/uB/test_unpack_macro_enum_interoperates_with_an_independent_scalar_api.sv)。

elaboration 99件は抽象class直接生成36件とpure interface／const参照／禁止member／型context／非公開constructor違反63件で拒否を期待し、94件が一致します。
subscriber／visitor／proxy／adapterの未実装と印字virtual builtin dispatcherの直接生成は受理され、runtimeなしでspec-onlyを保持します。
compiler受理5件は既知simulation差分390件と別です。合法な派生controlを必要な拒否の代わりにはしません。

field-access監査はseed 73結果のないseed 1 runtime差分5件を保持します。
register write／readのpre hookは保持するRCFD期待に対してFDRCを観測し、別のcrdf post観測が一致しても入力全体をpassにしません。
field pre-write／pre-readのmap変更は元のprovider Aを選び続け、開始時にmap Bを明示するcontrolは別に一致します。

物理隣接B／DをモデルA／3と変えたread-only writeでは、選択slice 75は保持しますがB75DがA753になります。
限定した全word best-effort解釈として保持し、無条件の周辺bit保証にはしません。続くpokeはB75Dへ明示resetしてからB39Dをdepositし、単独read-only pokeも一致します。
修正したsource観測を測定済みで、古い初期seed 73 logは保存した旧指紋に属するため除外します。これらで独立した不具合数は立証しません。

- [1](../tests/u18/test_field_write_callbacks_follow_the_containing_register_and_reverse_post_hook_order.sv).
- [2](../tests/u18/test_field_read_callbacks_follow_the_containing_register_and_reverse_post_hook_order.sv).
- [3](../tests/u18/test_field_pre_write_map_propagates_through_a_real_selected_access.sv).
- [4](../tests/u18/test_field_pre_read_map_propagates_through_a_real_selected_access.sv).
- [5](../tests/u18/test_field_readonly_backdoor_write_is_protected_while_poke_deposits_as_is.sv).

field-macro監査は新差分4件を保持します。合法なenum collection 3入力は印刷本文のTを字面どおりcollection typedefとして使い、
静的／動的／queueのbuildがruntimeなしで失敗します。要素enum Tのcontrolは同じcollection propertyで一致しても、文言を解決したり元入力をpassにしたりしません。
PACKだけの入力はdataをpackしても、seed 1のunpackで選択値とcountを復元せず、seed 73結果はありません。
別の明示UNPACK controlは元の期待に一致します。roundtripと除外targetの保持で全ての片方向packing義務は証明しません。
これらは測定条件と限定した解釈で、独立に証明した不具合数ではありません。

- [1](../tests/uB/test_field_macro_sarray_enum_copies_and_compares_values.sv).
- [2](../tests/uB/test_field_macro_array_enum_copies_and_compares_values.sv).
- [3](../tests/uB/test_field_macro_queue_enum_copies_and_compares_values.sv).
- [4](../tests/uB/test_field_macro_pack_flag_enables_unpack_and_nopack_suppresses_both_directions.sv).

core-service監査は差分3件を追加します。記載methodだけの完全subclassは合法simulation入力ですが、
buildは印刷method 26個にない固定版のpure hook get_phase_hopperを要求します。追加hook controlは独自dispatch観測すべてに一致してもcontrol専用です。
negative省略26入力もそのhookを補うため、最終compiler拒否は選択した印刷methodの欠落だけを示します。

選択core上限は7／9を保存してもphase既定値と新nodeは20のままです。実main readyもcore上限3に対して20回反復します。
このseed 1観測2件はseed 73を実行せず、関連条件として扱い独立不具合数を主張しません。選択seeding／RNG、既定constructor、生きたroot controlは別に一致します。

- [1](../tests/uF/test_core_service_all_declared_methods_dispatch_through_the_abstract_base_view.sv).
- [2](../tests/uF/test_core_phase_default_limit_reaches_new_nodes_and_keeps_explicit_node_limits.sv).
- [3](../tests/uF/test_core_phase_default_limit_bounds_real_ready_to_end_reentry.sv).

memory／FIFO監査は新しいruntime差分18件をseed 1に保持し、seed 73は実行しません。
memory get_rightsは無関係mapへRWを返しますが必要なwarningを出さず、他の選択map-warning controlは独立に一致します。
記載APIのconstructor／configureだけのFIFO 12入力は内部fieldのnull accessで停止します。固定Apache libraryの原因調査では、
印刷IEEE interfaceにない追加build初期化を確認しました。この前提問題は限定した解釈として明示して残し、controlのpassで解決しません。

別途初期化したcontrol 12件は7件一致し、5件に直接write、外部観測、preload／反復update、一致mirrorの差分を保持します。
直接writeはabstract状態を変えてもbus転送せず、preload updateは2 entryを4転送へ重複し、反復updateは最初のentryを4コピー保持します。
公開FIFO／DUTが一致するpairも内部0との比較を報告します。公開queueの解釈にはレビューが必要で、18入力を独立に証明した18不具合とは扱いません。
最終拒否write controlは期待を変えず後続の空DUT readを避け、以前の全known記録は未変更です。

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

付録C probeは新たなknown入力6件を保持します。合法な混合型／同順位／既定型呼出し3件は印刷typed resource-DB最大値helperが見つからず、runtimeを実行しません。
runtime 3入力はseed 1で停止し、限定したrecent-set sort順、no-DPIのanchor付きregex alternation、印刷virtualのregex／scope base呼出しが異なります。
これらは適用条件であり、独立に立証した6不具合ではありません。同順位listは元の古い順を保持し、base view経由で独自regex／scope overrideは両方0回の呼出しです。literal名、名前付き／匿名scope集合、異なるprecedenceのsortの一致は別fixtureで、独自overrideはbuiltin algorithmを置換しません。

- [typed最大値・混合型](../tests/uC/test_resource_db_typed_highest_precedence_filters_higher_values_of_other_types.sv).
- [typed最大値・最初の同順位](../tests/uC/test_resource_db_typed_highest_precedence_returns_the_first_matching_maximum.sv).
- [typed最大値・既定object](../tests/uC/test_resource_db_default_type_selects_the_highest_object_container.sv).
- [recent-set sort](../tests/uC/test_resource_pool_sort_equal_precedence_uses_the_printed_recent_set_rule.sv).
- [regex alternation](../tests/uC/test_resource_pool_regex_alternation_filters_names_and_scopes_without_queue_order.sv).
- [virtual regex／scope委譲](../tests/uC/test_resource_pool_regex_and_scope_methods_dispatch_through_a_base_handle.sv).

第5章probeは新たなknown入力17件を保持します。合法active-policy呼出し4件がbuildできず、secs省略decrは印刷既定値があっても引数を要求します。
runtime 12入力はseed 1だけです。time名はuvm_timeでなくuvm_tlm_time、generic型名は記載されたuvm_形でなくport／export／implementationです。
user_hook_enabledは最初のset前とflush後にerrorと0を返します。recording default-onと初期activeの観測が異なり、
禁止されたenable／disable呼出し4件はERROR／FATALを生成せず、両recorder経路probeはhandle／lookup／freeが一致してもsubject callbackがありません。
明示DEEPは選択済みであることを観測し、前提を推測しません。これは入力差分であり、独立に立証した17不具合ではありません。
修正したcaller単位の換算、明示seconds減算、直接user-hook controlは別の一致です。既存printerのformal名修正は1入力を変え、元の期待出力で再測定します。

- object active-policy API: [1](../tests/u05/test_object_active_policy_get_uses_the_standard_public_interface.sv), [2](../tests/u05/test_object_active_policy_pop_uses_the_standard_public_interface.sv), [3](../tests/u05/test_object_active_policy_push_null_uses_the_standard_public_interface.sv), [4](../tests/u05/test_object_active_policy_lifo_uses_the_standard_public_interface.sv).
- time減算既定値: [1](../tests/u05/test_canonical_time_decrements_follow_declared_units_and_defaults.sv).
- time既定名: [1](../tests/u05/test_canonical_time_names_follow_declared_units_and_defaults.sv).
- generic port名: [1](../tests/u05/test_port_base_declared_default_and_explicit_interface_types_preserve_hierarchy.sv).
- transaction初期active: [1](../tests/u05/test_transaction_disabled_recording_returns_zero_before_during_and_after_execution.sv).
- recording default-on文言: [1](../tests/u05/test_transaction_recording_default_flag_follows_the_explicit_default_on_sentence.sv).
- recording制御禁止区間error: [1](../tests/u05/test_transaction_enable_recording_reports_error_after_accept_before_end.sv), [2](../tests/u05/test_transaction_enable_recording_reports_error_after_begin_before_end.sv), [3](../tests/u05/test_transaction_disable_recording_reports_error_after_accept_before_end.sv), [4](../tests/u05/test_transaction_disable_recording_reports_error_after_begin_before_end.sv).
- transaction本体記録: [1](../tests/u05/test_transaction_recording_handle_matches_the_open_recorder_and_clears_after_end.sv), [2](../tests/u05/test_transaction_explicit_deep_recording_links_the_selected_recorder_handle.sv).
- field-operation hook既定値: [1](../tests/u05/test_field_operation_hook_enabled_before_first_set.sv), [2](../tests/u05/test_field_operation_hook_enabled_after_flush_before_next_set.sv).

新しい[継承kindの存在probe](../tests/u18/test_block_has_hdl_path_uses_nearest_explicit_ancestor_kind_without_changing_explicit_queries.sv)はseed 1で差分を保持しseed 73は実行しません。
childと子孫は、明示選択された最寄り祖先kindでなくlocalのRTL既定値を保持します。明示path-kind照会は別で、規格から導いた継承oracleは未変更です。
このmetadata結果で物理HDLアクセスを立証しません。

新しいmap幅2 fixture、[空階層](../tests/u18/test_map_address_units_distinguish_bytes_and_the_printed_default_effective_word_width.sv)と
[register配置済み階層](../tests/u18/test_map_populated_word_addressing_separates_effective_bus_width_from_local_address_units.sv)はseed 1で停止しseed 73は実行しません。
どちらもroot経路の最小幅2でなくlocal幅8を返し、保持する幅差分の適用範囲を広げるもので独立欠陥の件数ではありません。
数値のword単位期待値はget_n_bytes既定値の限定解釈を使い、有効幅不一致から別の単位の欠陥は特定しません。平坦word／byteのcontrol一致もknown fixture全体のpassにはしません。

新しいregister条件は[単一mapのnull／既定選択](../tests/u18/test_register_local_map_null_uses_parent_default_even_with_one_registered_map.sv)と
[lock前のfield名](../tests/u18/test_register_get_fields_orders_gapped_fields_by_bit_position_and_excludes_peer_handles.sv)のseed 1 runtime差分を保持し、seed 73は実行しません。
field順とlock後controlは選択観測で、fixture全体のpassではありません。[字面のclone返却probe](../tests/u18/test_map_clone_printed_implicit_return_type_supports_a_scalar_override_and_base_dispatch.sv)は、印刷暗黙scalar返却と利用できるmap返却が衝突してbuildできません。
限定した合法simulation宣言差分でruntimeはなく、不正designの期待拒否ではありません。公開clone call／source保持は一致し、新map内容／rightsは部分義務に残します。

phase simulation 4件はseed 1の差分を保持し、seed 73は実行しません。
domain registryの最初の照会には常在が必要なcommon／uvm entryがなく、新custom domainの登録と以前のentry保持は別観測です。
domain数を2だけに制限しません。早期終了はjump targetなしで後続へ到達しますが、元のtaskは動き続けます。

他2件は本文の矛盾に関する限定probeです。get_impのnon-IMP-null文はnode解決文と矛盾し、厳密なNODE-null probeは異なる一方、共有implementation解決は一致します。
get_scheduleはstring返却を印字しながら親nodeの返却を説明します。string receiverが呼出しを受理しても`$typename`観測はstringではありません。
receiver変換は宣言された返却型の証明ではありません。単一親schedule名controlは一致しますが、入れ子階層の解釈は解決しません。
これらは照合が必要な解釈の境界であり、独立に立証した4 library不具合ではありません。

新しい合法simulation 4件はruntimeのないtype_id宣言buildを保持します。共有abstract object matrixは最初に`uvm_transaction`の`type_id`欠落へ達し、独立した`uvm_report_server` probeも解決できません。
`uvm_subscriber`とparameter化`uvm_sequence`は、汎用規則が求める自身の表現型と非互換な継承基底registry特殊化を公開します。
独立`uvm_sequence_base` probeは一致しますが、停止matrixや全built-in宣言は認定しません。これら4 buildは不正入力の期待compiler拒否ではありません。

他2 fixtureは未知object／component名へnullを返し登録controlを生成しますが、seed 1で必要なERRORを観測せずseed 73は実行しません。
有効controlは不正要求より前に実行し、error後のregistry状態を仮定しません。error severityとnull返却を別の義務として保持し、返却値の一致でfixture全体をpassにはしません。active-global service controlは単一instance概要の限定解釈であり、物理的にfactory objectを1つしか生成できないという主張ではありません。

[constructorでmodelを追加した測定検査系](../tests/u18/test_reg_coverage_add_measurement_availability_80.sv)は、搭載、有効union、非搭載modelのgateが一致しても、以前のmaskを返すflagがseed 1で期待1に対して0です。
seed 73は実行せず、以前の戻り値差分の追加条件として保持し、独立した不具合とは認定しません。
[coverageのFAQ](faq.ja.md#q312-有効maskが正しければmodel追加の検査系はpassですか)で観測と全体判定を区別します。

字義的なINFO等値macro 2入力は、caller形式と明示context形式の両方で、seed 1において抑制せずMSGを評価して実行hookへ到達します。seed 73結果はありません。
厳密なlower-than解釈をAPIの等値を許す規則と分けた、根本原因を認定しないレビュー可能な差分で、[境界のFAQ](faq.ja.md#q315-等verbosityのinfo-macroをspec-onlyに残す理由は)を参照してください。

- [uvm_infoの字義的なINFO境界](../tests/uB/test_report_macro_info_literal_info_boundary_81.sv).
- [uvm_info_contextの字義的なINFO境界](../tests/uB/test_report_macro_info_context_literal_info_boundary_81.sv).

未登録instanceの空queue delete入力はseed 1でnull参照診断とexit 1により呼出し後のUT観測前に終了し、seed 73結果はありません。
WARNINGの不在や根本原因は認定せず、[観測の限界](faq.ja.md#q317-未登録instanceへのdelete差分は何を示しますか)を参照してください。

- [Unregistered-instance empty delete](../tests/uB/test_callback_macro_unregistered_delete_instance_82.sv).

size入力2件はruntimeなしのsimulation build差分です。reserved＋129のflag拡張は64 bitを超えるenum methodの未対応を報告し、UVM_PACKER_MIN_BITSは未定義です。
reserved＋17と別の32768-bit保持は一致してもこれらの入力を成功扱いにせず、[サイズのFAQ](faq.ja.md#サイズ定義とversion識別)で条件を分けます。

- [field_flag_user_extension_129](../tests/uB/test_size_version_field_flag_user_extension_129_83.sv).
- [packer_minimum_define](../tests/uB/test_size_version_packer_minimum_define_83.sv).

新しいruntime 2入力はseed 1でexit 0の差分を保持し、seed 73結果はありません。負のID閾値では字義的NONE期待に対して配送が0となり、
字義的kill入力はSTOPPED／kill／bodyが一致してもpost_body／post_startの呼出しが両方0です。
API境界と既存のkill差分を成功扱いにせず、根本原因や独立したbug件数を認定しない範囲は[report／stateのFAQ](faq.ja.md#reportの列挙型とsequence-state)にあります。

- [none_negative_id_limit_literal](../tests/uF/test_enum_state_none_negative_id_limit_literal_84.sv).
- [sequence_kill_post_hooks_literal](../tests/uF/test_enum_state_sequence_kill_post_hooks_literal_84.sv).

新規の実virtual register／fieldのpoke／peek 4入力は、別HDL条件で両seedに一致し、通常runnerではDPI未linkのbuild差分を保持します。
12 model入力の一致や補助条件で未link実行を成功扱いにしない範囲は[backdoorのFAQ](faq.ja.md#virtual-registerのbackdoor観測)にあります。

- [vreg_poke_word16](../tests/u18/test_vreg_backdoor_hdl_vreg_poke_word16_85.sv).
- [vreg_peek_word16](../tests/u18/test_vreg_backdoor_hdl_vreg_peek_word16_85.sv).
- [field_poke_word16](../tests/u18/test_vreg_backdoor_hdl_field_poke_word16_85.sv).
- [field_peek_word16](../tests/u18/test_vreg_backdoor_hdl_field_peek_word16_85.sv).

新規の限定したpre-read順序2入力は、存在、data／status、post順序が一致してもseed 1のpre順序差分を保持し、seed 73結果はありません。
印刷具象register callback facadeは固定版のvirtual宣言でabstractとして拒否されruntimeがなく、合法派生controlは別に一致します。
修正したfield単独入力は整合するfrontdoor／backdoorで両seedに一致し、初期の独立bank版を現在の差分やpost-status欠陥として扱わない理由は[callbackのFAQ](faq.ja.md#virtual-registerのcallback契約)にあります。

- [field_pre_read_method_order_literal](../tests/u18/test_vreg_callback_field_pre_read_method_order_literal_86.sv).
- [field_pre_read_cb_order_literal](../tests/u18/test_vreg_callback_field_pre_read_cb_order_literal_86.sv).
- [decl_register_concrete](../tests/u18/test_vreg_callback_decl_register_concrete_86.sv).

限定したnull-setter探索入力4件は最初の5行が一致した後、seed 1でexit 1のnull参照停止となり、seed 73結果はありません。
setterはnull-as-clearを明記せず、これらは解釈照合待ちのcontrol専用です。元の本体／期待値は保持し、別の非null入力の一致で元入力全体をpassにしません。
必須の解除APIや独立した不具合件数を断定しない理由は[Q334](faq.ja.md#q334-getterがnullを返せるならset_frontdoornullで必ず解除できますか)で説明しています。

- [reg_frontdoor_get_single_omitted](../tests/u18/test_reg_frontdoor_get_single_omitted_87.sv).
- [reg_frontdoor_get_single_explicit](../tests/u18/test_reg_frontdoor_get_single_explicit_87.sv).
- [reg_frontdoor_get_multiple_replace_first](../tests/u18/test_reg_frontdoor_get_multiple_replace_first_87.sv).
- [reg_frontdoor_get_multiple_replace_second](../tests/u18/test_reg_frontdoor_get_multiple_replace_second_87.sv).

rootの初期5入力はexit 0のseed 1観測と元の期待を保持し、seed 73結果はありません。未登録packet 4入力は型のbuild拒否でruntimeがありません。
正時間、早いguard、登録済みpacketの別controlが一致しても元入力全体はpassにせず、必須登録条件や独立不具合件数を導かない解釈は[root／predictorのFAQ](faq.ja.md#rootの終了guardとpredictorのcheck)に記録しています。

- [root_finish_default_after_phases](../tests/uF/test_root_finish_default_after_phases_88.sv).
- [root_finish_reenabled_after_phases](../tests/uF/test_root_finish_reenabled_after_phases_88.sv).
- [root_guard_error_in_build](../tests/uF/test_root_guard_error_in_build_88.sv).
- [root_guard_error_in_end_of_elaboration](../tests/uF/test_root_guard_error_in_end_of_elaboration_88.sv).
- [root_extension_construction_requires_fatal](../tests/uF/test_root_extension_construction_requires_fatal_88.sv).
- [predictor_check_pending_little_1_registers](../tests/u19/test_predictor_check_pending_little_1_registers_88.sv).
- [predictor_check_pending_little_2_registers](../tests/u19/test_predictor_check_pending_little_2_registers_88.sv).
- [predictor_check_pending_big_1_registers](../tests/u19/test_predictor_check_pending_big_1_registers_88.sv).
- [predictor_check_pending_big_2_registers](../tests/u19/test_predictor_check_pending_big_2_registers_88.sv).

新規MAMの5入力はseed 1で選好だけの差分を保持し、exit 0、seed 73なしです。境界、幅、非重複、保持端点／所属、cleanupは一致します。
GREEDY上位履歴、THRIFTY下位／上位、NEARBY 1／2 regionを分け、下位GREEDY、明示BROAD、configuration／rand-fieldの一致で全入力をpassにしません。限定した履歴や分布の扱いは[enum／allocationのFAQ](faq.ja.md#列挙型の効果とallocationの選好)にあります。

- [mam_greedy_fresh_high_history](../tests/u18/test_mam_greedy_fresh_high_history_89.sv).
- [mam_thrifty_reuse_low_history](../tests/u18/test_mam_thrifty_reuse_low_history_89.sv).
- [mam_thrifty_reuse_high_history](../tests/u18/test_mam_thrifty_reuse_high_history_89.sv).
- [mam_nearby_one_existing](../tests/u18/test_mam_nearby_one_existing_89.sv).
- [mam_nearby_two_existing](../tests/u18/test_mam_nearby_two_existing_89.sv).

## 固定版ライブラリの制約

固定版とはlock fileで版と内容を指定したライブラリで、これらの制約を再現するときに同じ実装を用意する方法は[ライブラリの案内](testing.ja.md#uvmライブラリ)にあります。

DPIはSystemVerilogと外部コードをつなぎ、有効化flagだけではbackendを供給しないため、DPI欠落の項目を読む際は[コンパイル](testing.ja.md#コンパイル)を参照してください。

「限定した解釈」などの注記はレビューが残る読み方を示し、別の解釈を条項の根拠とともに提案する方法は[Q18](faq.ja.md#q18-期待値の誤りはどう報告修正しますか)で説明しています。

ライブラリ自身の`DEVIATIONS.md`には18.2.3.4・18.4.3.6・13.1.5.1の3件が載っています。
現在のregister検索ではmap引数を明示します。memoryを2つの兄弟interfaceのmapに登録する単純なケースは、
固定版でも18.2.3.4の期待値に一致しました。配布物の複数mapの注記と、より広い階層の意味は別途照合が必要です。
付録Eでは選んだ2／3 mapのshared accessと1つの子blockの形も確認します。
[memoryの範囲](faq.ja.md#memorypredictionmapの制御)と
[shared accessの範囲](faq.ja.md#memory-accessshared-mapテストの選択)を参照してください。
M1・M2・M3で、追加の制約と観測を確認しました。
不足する必須動作を直接検査する場合は、規格の期待値を変えずに`:oracle: spec`で保持します。

- builtin constructor 2 fixtureはseed 1で差分となりseed 73は実行しません。
  [single-memory access](../tests/uE/test_builtin_mem_single_access_seq_constructor_types_target.sv)と
  [single-memory walk](../tests/uE/test_builtin_mem_single_walk_seq_constructor_types_target.sv)の省略名が記載constructor既定値と異なります。
  明示名、継承、対象storageは別のcontrolで、規範的な既定stringは未変更です。実測名はそれぞれ
  `uam_mem_single_access_seq`と`uvm_mem_walk_seq`です。
- [builtin dispatcherの直接生成](../tests/uE/test_builtin_dispatcher_virtual_class_rejects_direct_construction.sv)は
  印字virtual宣言にもかかわらず受理され、runtimeは実行しません。一致する合法具象拡張はconstructor／継承／model／mask条件を扱うだけで、拒否fixtureをpassにはしません。

- [正時刻relevance上限fixture](../tests/u15/test_sequencer_zero_time_relevance_limit_set_at_positive_time.sv)は
  時刻3に3を設定して初回zero-time relevance burstを始めますが、通知はcallback 5回目です。
  限定oracleは上限または最初の超過の3／4回を許容し、正確なseverity／ID／文面を要求しません。
  全callbackと通知は時刻3で、fallback／grantはありません。時刻0の既定／明示／virtual setter比較対象は独立に一致します。
  seed 73のない1件のseed 1適用条件差分で、private-counter欠陥の証明や復旧の主張ではありません。

- 新しいprinter 8検査系はseed 1の差分を保持し、seed 73は実行しません。SHALLOWでも子孫を訪問し、無効radix prefixが残り、root controlは既定1に対して0を返します。
  table／tree indentとtree／line separatorは、flush後の種類別既定値に対して変更値が残ります。
  entry-depth等号matrixは限定解釈です。一方、別のcaller scopeは測定した両上限を既に超えても再帰し、その境界問題を避けます。
  途中の正しい観測でfixture全体をpassにはしません。
  - [SHALLOW再帰](../tests/u16/test_printer_recursion_modes_distinguish_deep_shallow_reference_and_default.sv)
  - [限定entry-depth境界](../tests/u16/test_printer_max_depth_uses_reference_behavior_beyond_each_selected_boundary.sv)
  - [超過済みdepth](../tests/u16/test_printer_depth_already_above_limit_uses_reference_without_touching_caller_stack.sv)
  - [無効radix prefix](../tests/u16/test_printer_integral_values_use_selected_radix_prefix_and_honor_prefix_disabling.sv)
  - [root名既定値](../tests/u16/test_printer_root_enabled_selects_full_name_or_leaf_before_policy_dispatch.sv)
  - [flush後のtable indent](../tests/u16/test_printer_table_specific_controls_return_to_declared_defaults_after_flush.sv)
  - [flush後のtree control](../tests/u16/test_printer_tree_specific_controls_return_to_declared_defaults_after_flush.sv)
  - [flush後のline separator](../tests/u16/test_printer_line_specific_controls_return_to_declared_defaults_after_flush.sv)

- 共有handlerのresetはgeneral／ID verbosity、action、fileを復帰させてもseverity／ID verbosity閾値を保持します。
  6.3.8.3は既定設定への復帰を要求します。pairのresetと後続境界配送の期待を保持し、seed 1で停止してseed 73は実行しません。
  設定prefixの一致はfixture全体のpassではありません。[共有閾値のreset](../tests/u06/test_reporting_shared_reset_restores_all_threshold_keys_before_live_filtering.sv)を参照してください。
  以前のseverity-override reset差分は別入力として保持します。

- pureなsubscriberのwriteまたはvisitorのvisitを欠く具象subtypeがcompileに成功します。
  13.9.3.2／F.5.1.2.3の宣言とSystemVerilog 8.21は具象生成に実装を要求します。
  両拒否oracleを保持しruntimeは実行しません。独立した合法な継承subscriber controlは両seedで一致しますが、実装欠落を許す根拠にはしません。
  [subscriber欠落](../tests/u13/test_subscriber_concrete_subclass_must_implement_write.sv)と
  [visitor欠落](../tests/uF/test_visitor_concrete_subclass_must_implement_visit.sv)を参照してください。

- 新しい実行時差分3件は限定した規格解釈を保持します。12.3.5.7.4／12.3.5.8.4はblocking relay見出しでnonblocking providerを列挙します。
  逐語的な受理probeは列挙3／2 familyを全て拒否し、ERROR 6／4件を報告します。別のblocking relay転送／再利用の比較対象は一致します。
  印刷名を暗黙にblocking名へ置換せず、比較対象の一致で一覧が解決したとも扱いません。
- 同種terminatorの一般制約を「不正connect後に直接provider entryを残さない」と読む限定解釈では、両initiator種はERRORを報告してもentryを残し、target種はERRORを報告して残しません。
  rawな直接entryと解決済み実行bindingは異なります。規格は不正呼出し後の状態を明記しないため、不具合の証明ではなく照合可能な解釈差分として保持します。
  全3件はseed 1の最初の差分で停止し、seed 73結果はありません。
- forward portをbackward経路とする本文と、P／parameter構文を省略したnonblocking connect signatureも部分対応の文言として残ります。
  正確なclass既定値と独自phase転送probeは印刷signatureの逐語的正しさを認定しません。
  他の抽象／不正派生条件、不正user extension、全socket member所有関係も別作業です。

- 12.2.3.3のbidirectional port概要は、REQと独立にRSP=intを宣言します。選択した9 familyの検査系はREQだけstringへoverrideし、正確なstring／int interface基底を要求します。
  固定宣言はRSP=REQを使うため、最初の型付き引数でcompileに失敗します。全int既定と、異なるpacked型を明示したtransportの比較対象は一致します。
  これはAPI欠落や実行時失敗ではなく、宣言既定値build差分1件で、この入力は両seedとも未実行です。REQだけ指定する検査でRSPを明示する置換は行いません。

- propagation mode 0では、objection callbackは中間componentを正しく省略しますが、子が2、次に1 objectionを保持していても、その祖先のtotal照会は0を返します。
  10.5.1.3.2が指定するのはcallback省略であり、10.5.1.5.4のtotalは自身とdescendantのobjectionを含みます。source／root totalとcallback経路は一致します。
  既定modeの比較対象は中間total、hook metadata、drain／callback伝播の検査で一致します。省略modeの規範的total期待を保持し、seed 1で最初に異なりseed 73の結果はありません。
  経路の正しさを検査系全体のpassには数えません。

- raw eventの早い／遅い待機検査では、trigger前に公開count 1で早い呼出しを確立します。
  10.1.1.2.4はそのtriggerでの戻りを要求しますが、次のtime sliceでも早いcallerは戻らず、2回目のtriggerで両callerが戻ります。
  同じsliceで遅く呼ぶcallerの新trigger待ちは、一致する比較対象です。simulator／libraryを組み合わせた原因は未確定で、simulator実装sourceは調べません。
- 既定event resetはraw／persistent／on-stateの3 callerを待機させたまま、waiter 0を報告し、10.1.1.2.10の実process照会と異なります。
  後の新triggerでは3つとも期待dataで解放します。これは件数の差分で、取り残しの観測ではありません。
  barrierのsilent-reset比較対象は、規定の0 count／再待機で別に一致します。
- 新しいevent poolには、10.4.1が要求するbegin／accept／endの名前がありません。
  検査はgetのlazy生成より前に所属を調べ、正確なpool sizeは要求しません。既存の新key増分テストは初期所属と独立で、未変更です。

- user-backdoorのencode／decode callbackは必要な順序で呼ばれますが、配列変換が次のcallbackや最終の値経路へ届きません。
  18.11.2.7／.8は順次伝播、decoderの逆順、post-read methodでのclear dataを要求します。
  単一encoderは記憶値を期待0x0c／0x3aではなく0x13／0x25のままにし、単一decoderはclear値0x13／0x25ではなくencoded値0x0c／0x3aを返します。
  2 callbackの検査は中間値の喪失も示します。4件ともseed 1で最初に異なり、seed 73の結果はありません。
  [既定callbackの比較対象](../tests/u18/test_register_callback_default_encode_and_decode_leave_arrays_unchanged.sv)は両seedで一致し、既定の無変更動作だけを示します。
  物理HDLや検査側の配列修復を使わず、独自記憶域と2つの配列要素を使います。固定Apache helperの確認で観測した書戻し欠落を説明しますが、oracleには使いません。

- 固定catcherは、標準のget_report_message API（6.6.3.10）を持ちません。
  事前構成messageの同一性／live alias／再利用の3検査系はbuildできず、実行時の期待は未測定です。privateな実装fieldで代用しません。
- 1-byteのbig-endian busで個別fieldはアクセス可能を返しますが、実測high writeは0x20でなく0x21、low readは0x21でなく0x20へ向かい、
  格納／戻りdataも異なります。別のlittle-endian対照は両seedで一致します。設定したbyte順の期待を保持し、simulator実装の原因とは断定しません。

- adapterでbyte enable対応を示し、16-bitの物理word内で2 fieldが別々のbyteを占める条件です。
  18.5.5.9／.10は、この条件で個別アクセスを要求します。固定libraryの可否判定はbus幅全体でfieldをまとめ、両fieldを拒否して全wordのmaskへfallbackします。
  low writeは実際のhigh byte 0xabをmirrorの0x12へ置換し、high readはlow mirrorを0x34に保持せず0xcdへ更新します。
  選択した戻り値や後のwrite値の一致だけでは、独立したアクセスを示しません。byte-enable非対応の別fallback対照は両seedで一致します。
  個別アクセスの期待をspec-onlyで保持し、HDL DUT storageは使いません。

- heartbeatの動作中にeventを省略してstartすると、固定実装は置換eventのerrorを組み立てる際にnull引数を参照します。
  10.6.2.6は以前に設定したeventの選択を要求します。stop後の既定event再利用と明示same-eventのstartは、動作中の既定呼出しが失敗する前に一致します。
- Verilator／固定UVM条件のFIFO inline randomizeは、容量ちょうどの要求に成功を返しますが、queueが空のままです。
  別の過大inline要求は、期待どおり拒否します。
- 別のFIFO subtype制約の検査では、容量ちょうどのsubtypeは一致しますが、容量3に対して4 entryを要求するsubtypeも、拒否せずrandomize成功を返します。
  2つのFIFO観測は18.8.2の期待を保持し、simulator／libraryのどちらが原因かは決めません。abstract queueはDUT FIFOの転送を示しません。

- register fileのget_default_hdl_pathは、fileで明示的な既定を設定していなくても、包含blockをGATE、後でCPUにした後も初期値RTLを保持します。
  18.3.4.6は、この条件で最も近い祖先の既定値を要求します。同じ検査系の明示file override TLM／RTLは一致します。
- 入れ子fileのkind省略get_full_hdl_path照会は、flattenされた親のGATE既定を継承せずRTLを保持します。
  18.3.4.5／18.3.4.6に基づく期待はnet.cellで、固定版の結果はdut.leafに従います。明示RTL／GATEのflattenは一致します。
  symbolicなpathだけを扱い、HDL accessを示すものではありません。

- block get_map_by_nameは、local mapのsubmapにしていないchild blockのmapを、今回の検査で見つけません。
  18.1.3.13はchild blockの検索を要求します。同じlock済み検査系のlocal優先とscope外の結果は一致します。
- block get_block_by_nameは、直接childと、childから照会するgrandchildを見つけますが、rootから同じsimple grandchild名を見つけません。
  18.1.3.12は子孫検索を要求します。oracleはsimple name入力だけを使い、不在／ancestor／peerの対照を含めます。

- overrideのないabstract componentをparent nullで生成すると、必要なerrorの整形中にparentを参照して停止します。
  8.2.5.1.2はerrorとnull返却を要求するため、その期待をspec-onlyで保持します。
  具象parentを指定した同callbackとabstract objectの別条件は、ERRORとnullを返す対照検査として一致します。
- sequence get_depthは、parentの置換／解除後も以前に計算した値を保持します。明示set_depthがなければ、
  14.1.2.9は現在parent chainのdepthを要求します。検査系は3／2／1を保持し、parent handle、root照会、pathは別に更新します。

- componentの自動configurationは、固定libraryの既定name-filter modeでは独自resourceをskipします。
  明示strict buildではresourceを見つけますが、13.1.5.1のUVM_SET field operationなしにset_localを直接呼びます。
  そのためstrictでもhook順序と抑制が異なります。期待値は正確なrhs dispatchと抑制を保ち、strict buildを別条件とします。
- portのrelationship設定は、存在する値0のresourceを有効として扱います。5.5.2.14は0による無効化を要求します。
  設定なしの既定と非0による有効化は別の観測で一致します。actionのあるreportだけを数え、UVM_NO_ACTIONはwarning発行から除きます。

- overrideしないsubtypeの`uvm_port_base::get_type_name`は、5.5.2.5で規定する`uvm_`接頭辞を省きます。
- `set_default_index`はindexを記録しますが、5.5.2.13に反し、実測したblocking export呼出しをelaboration後に切り替えません。
- 独自VPI backendでのE.7 sequenceは、利用不能pathにERRORを報告し、HDL readを試みます。
  warning／転送なしの解釈を保持します。既定abstractionで利用可能なpathの比較対象は別に一致します。

- register-itemの範囲外value writeは、warningと無視でなくvalue配列を拡張し、
  範囲外readは必要なwarningなしに0を返します。19.1.1.2.4は、両warningとwriteの無視を要求します。
  読取り／書込みの記述子を分け、個数／個数+1のindexで誤った割当てを小さく保ち、
  readのwarning欠落をwriteの拡張から分離します。空配列の観測も同じ規範的規則を保持します。

- no-DPIの照合fallbackは、簡易表記のplusをliteral文字として扱います。
  F.3.3.1／表F.1は1文字以上を要求するため、nodeXtailとnodeXYZtailはnode+tailに一致する必要があります。
  規範的な検査はspec-onlyを保持します。star、question、検査したliteral文字は別に一致します。
  この知見は実測したno-DPI設定に限定し、POSIX式の動作やDPI有効時の結果は示しません。

- registerのorder policyは物理readの順序を変えますが、固定libraryは論理位置でなく実行順にbyteを合成します。
  18.4.2.4はreadの並べ替えを認め、18.4.4.10はregisterの論理値を保持します。
  little-endianの4 byte readは、要求addressとbyteを観測しても、12345678 hexでなく78563412を返し予測します。
  規範的な値はspec-onlyとして保持します。

- componentの`free_tr_stream`は、cacheしたstream型のkeyでなく、stream objectのclass型名でentryを削除します。
  同じ非空の名前／型pairを後で要求すると、元のstreamを返します。13.1.7.10は参照解放後に
  新しく生成したstreamを要求します。検査系は新しい同一性と生成1回を期待し、別のcache pairを保持します。

- Phaseの`find`は、呼出しnodeが指定implementationを参照する場合、渡したimplementation handleを返します。
  9.3.1.4.4はphase-node handleを要求します。検査系は正確なnodeを期待し、
  隣接nodeの成功lookupとschedule内で存在しない結果を比較対象にします。
- Register、memory、blockの`set_coverage`は、新たに有効化したmaskを返します。
  18.4.7.6、18.6.8.5、18.1.4.5は、直前に有効なmaskを要求します。
  2検査系はoffからon、置換、無効化の戻り値を保持します。搭載状況による制限、
  peerの独立性、blockの再帰は別に観測し、固定版実行で一致します。covergroupは測定しません。
- memory samplingは、read／writeのsampling loopが終端境界を含むため、1 locationのaccessごとに
  余分なlocationをsampleします。18.6.8.6は完了accessにsamplingを対応させます。
  検査系は1 locationの転送ごとにsample 1回を保持し、map、方向、data、完了は別に観測します。
  memory offsetのgeometryは規定しません。

- databaseの`open_stream`は`open_db`を呼び、閉じたdatabaseを暗黙に開く場合があります。
  7.1.4.1は、databaseが既に開いていなければ要求を無視してnullを返すことを要求します。
  検査系は、closed、接続失敗、open成功のdatabaseを別々にして独立した対照を保ちます。
- 新しいstreamは、7.2.3.1〜7.2.3.3が要求する未初期化の`get_db`、`get_scope`、
  `get_stream_type_name`でのwarningを抑止します。warning gateの初期値が無効です。
  検査系は、各照会のwarningを1つずつ保持し、初期化済みstreamが静かに有効metadataを返す対照を使います。

- eventのtrigger dispatchは、有効なhookだけでなく無効callbackのhookも呼びます。
  10.7.1.2.2は`callback_mode(0)`でcallbackを無効にします。検査系は、event dataの更新を観測しつつ、
  pre／postの呼出し0回を期待に保ちます。
- blockの`get_reg_by_name`は、model lock時だけに埋めるfull-name registryを使いますが、
  18.1.3.14はlockの前提を指定していません。通常のlocal／deep名はlock後に取得できても、
  regfile内に入れ子のregisterは単純名で取得できません。検査系はlock前後の両要求を保ち、
  通常のlock後の成功するlookupを対照にします。

- 17.2.3.3.2／17.2.3.3.3で要求される`uvm_hdl_path_concat::set_slices`と`get_slices`がありません。
  concatの2検査系は、標準の呼出しと、最上位から最下位へ並ぶ有効なsliceの記述を保ちます。
  両方とも固定ライブラリではビルドできません。
- blockは、最も近い祖先で明示したHDL abstractionを継承せず、localなRTLの既定値を初期化します。
  18.1.6.9の検査系は、継承するGATE、子のlocalなRTL override、rootをSYNへ変更後に別途継承する兄弟を
  期待値に保ちます。metadataの継承であり、HDLアクセスは試みません。

- 空queueの`uvm_queue::pop_front`と`pop_back`はnative queueの操作へ委譲し、
  11.3.2.8／11.3.2.9で要求されるwarningを出しません。両検査系は空の各呼出しでのwarning、
  2値の既定の戻り値、再設定／全取得の成功する比較対象、2回目の空の呼出しを期待値に保ちます。
  シミュレータの診断の文面は指定しません。
- memoryの`pre_read` callbackでdescriptorのmapを変更しても、固定ライブラリはcacheした
  元のlocal map／frontdoorを使います。18.11.2.4の検査系では別mapと変更後のoffsetを期待し、
  両mapで別々のstorageと、callbackを削除した比較対象を用意します。
- memoryの`post_write`は、18.6.9.2／18.11.2.3と逆に、登録callbackより先に継承methodを実行します。
  検査系はcallbackがmethodより先の順序と、methodの最後のstatusを期待値に保ちます。
  完了したstorageとpost-writeでのdescriptor変更を別々に観測し、callbackの削除で比較対象を戻します。

- `find_override_by_name`は、置換がない場合に`null`を返します。元の型を生成できる場合も
  同じです。8.3.1.7.1は生成されるオブジェクトのwrapperを返すAPIとして説明しています。
  overrideなしのobject／component検査では通常生成のwrapperを期待値に保ち、
  override照会とaliasの一致ケースは別の比較対象にします。
- config_dbの既定の実装はフィールド名を文字列の一致で検索するため、設定したフィールド名の
  globがC.4.2.2.1の説明どおりに名前を選択しません。globテストはフィールド名を固定し、
  スコープのパターンを確かめます。
- fieldマクロで入れ子をcopyすると、UVM_SHALLOWでも別のオブジェクトが作られます。
  16.6.3は入れ子を参照として扱う動作を説明しています。一致するテストではdeep copyと、copyフックから
  見えるcopierの設定・処理中のオブジェクトを確かめます。
- 5.3.14.3の`uvm_object::get_active_policy`がありません。以前のフックのテストは16.1.3のAPIで
  copier側の処理中オブジェクトのスタックを観測します。新しい2 policy同期テストは、必要なobject側getterを
  直接呼び、spec-onlyのbuild差分を保持します。policy側stackの観測だけでは、object側の同期は成立しません。
- `uvm_field_op::user_hook_enabled`は`set`前と`flush`直後の呼び出しを拒否します。
  5.7.2.7にはこの制限がありません。field_opの再利用テストは、flush後も含め、
  `set`した後で有効値を確認します。
- `get_objectors`は、件数がゼロになったソースもdrainの後処理まで一覧に残します。
  10.5.1.5.1は現在objectionを保持しているソースの一覧を説明しています。
  drop直後の一覧テストは、規格の期待値を変えずにspecのみのテストとして保持します。
- `uvm_transaction::is_active`は生成直後に1を返しますが、5.4.2.12は最初のbegin前を0と定めています。
  生成直後の非active状態をspecのみのテストとして保持します。一致するライフサイクルのテストは、
  begin・end後のactive状態を検査します。
- レポートhandlerのreset後も重大度・ID別の置換が残ります。6.3.8.3は6.3.7の置換設定を
  消す動作を定めています。件数によるreset検査は、元の重大度に戻る期待値をspecのみで保持します。
- `uvm_field_op::get_op_name`は、`set`前と`flush`後に5.7.2.3の必須エラーを出しません。
  getterの事前条件を検査する2件は、必須エラーの期待値をspecのみで保持します。
  `get_op_type`・`get_policy`・`get_rhs`による必須エラーも同時に検査します。
- `set_response_queue_depth`は、新しい深さがキュー内の応答数より小さい場合にも、
  14.2.7.7の必須エラーを出しません。M2の2件で、応答2件に対する深さ1への変更と、
  応答1件に対する深さ0への変更の必須エラーを保持します。エラー後のキュー内容は検査しません。
- 応答キューのエラー報告フラグの既定値が0ですが、14.2.7.4・14.2.7.5は1と定めています。
  M2の設定テスト2件は規格の既定値を保持します。一致するoverflowテストでは、
  エラー報告の有効・無効を明示的に設定します。
- USER arbitrationでは候補が1件の場合に`user_priority_arbitration`を呼びません。
  15.3.2.3はこの場合もcallbackを必須とします。M2の1件で、呼び出す期待値をspecのみで保持します。
- lockの要求を、先行するFIFO上のitem要求や取得済みitemの完了通知より先に付与します。
  15.3.2.10・14.2.5.5とFIFOのF.2.4.1に従う、2件の順序・待機の期待値をspecのみで保持します。
- `sequence.kill`は、14.2.5.11が要求する`post_body`・`post_start`を呼びません。
  sequencerあり・なしの2件で必須hookを保持します。`do_kill`、停止状態、bodyの中断は別に観測します。
- default sequenceのwrapperから生成したobjectがsequenceへcastできない場合、
  15.3.5の必須エラーではなくwarningだけを出します。通常のobjectとsequence itemを指定する
  2件で、エラーとdefault sequenceを開始しない期待値を保持します。
- `stop_sequences`はroot sequenceの自動starting-phase objectionを解除しません。
  15.3.2.14の停止はkillとして動作し、14.2.4.3のdropも必要です。単独と親子の2件で
  必須の件数0を保持します。親子では子のdropは実行されますが、親の件数が残ります。
- `uvm_tlm_time`がaliasする`uvm_time`の既定名が、5.6.2.1の`uvm_time`ではなく
  `uvm_tlm_time`です。引数なしの生成の名前をspecのみで保持します。
- 5.6.2.2の`uvm_time::set_default_time_resolution`がなく、旧名の`set_time_resolution`だけがあります。
  規格のAPIを呼ぶテストはビルド不可の既知差分です。コンパイルを通すためにAPI名を置き換えません。
- nonblocking pass-through initiatorを二段にするとbackward exportの接続方向が逆になります。
  外側exportが未接続となる差分を、12.3.5.5.4の自動backward接続の期待値として保持します。
- push sequencerは完了した要求を要求FIFOから取り除きません。そのため、次の要求を送ると
  FIFOが満杯のままで拒否され、15.6.3.3の連続転送を満たしません。3件で順序どおりの転送と、
  共通APIの要求・応答履歴を規格の期待値として保持します。
- sequence libraryに`get_selection_mode`・`set_selection_mode`、`get_min_random_count`・
  `set_min_random_count`、`get_max_random_count`・`set_max_random_count`、
  `get_num_sequences_executed`がありません。14.4.4.1〜14.4.4.4の必須APIを使う6件は
  ビルド不可です。旧来のfieldへ置き換えず、規格の呼び出しを保持します。
- `uvm_sequence_library::remove_sequence`は未登録の型を削除しても、14.4.5.5の必須warningを
  出しません。warningと登録済みの型を維持する期待値を保持します。
- static登録された型を削除しても、呼び出したlibrary instanceだけが変更されます。
  14.4.5.5は全instanceの更新を要求するため、別の既存instanceの一覧を公開APIで観測します。
- FIFOの`get_ap`は、12.2.8.1.6が含める`peek`と成功した`try_peek`の通知を省略します。
  2件で、peekがitemを残すことと、それでも毎回通知する規格の件数を別々に観測します。
- `start_item`は`null`のitem、itemではないsequence、sequencer不足をFATALで報告します。
  14.2.6.2はERRORと即時のreturnを要求するため、3件で重大度を変えずにcatcherで数えます。
- libraryのsubtypeの構築時に、sequence libraryマクロで登録した型やbaseの所属を取り込みません。
  4件で14.4.2のconstructorとB.3.2のマクロを使い、実装固有の追加の初期化呼び出しは加えません。
- `finish_item`は14.2.6.3が要求するsequenceのvirtualな`send_request`・`wait_for_item_done`を
  経由しません。2件で通常の実装へ委譲するoverrideを観測します。
- `finish_item`がsequencerの完了待ちへ渡すIDは、14.2.6.3のitemのtransaction IDではなく-1です。
  実際の要求へ通常どおり完了を通知し、1要求・2要求の明示IDを規格の期待値として保持します。
- `finish_item`は`null`・非itemの検査を省略し、sequencer不足でもFATALの後に即時returnしません。
  3件で14.2.6.3のERRORと早期returnを保持します。固定版の不正参照の経路は、期待する観測前に終了します。
- `uvm_reg::get_field_by_name`はlock前の構築済みfieldに`null`を返しますが、18.4.3.12はlockを前提にしていません。
  固定版はlock時に完全名の索引を作ります。1件でlock前の正しいhandleを期待値に保持し、lock後の検索成功も確認します。
- `uvm_reg_map::get_n_bytes(UVM_HIER)`はlock前のroot mapに0を返しますが、18.2.4.5はlockを前提にせずbus幅を返します。
  1件でlock前の幅を期待値に保持し、lock後の正しい幅も確認します。
- `get_physical_addresses`はアドレスを計算しても、18.2.4.16の転送byte数を返さず0になります。
  戻り値の欠落はmap初期化にも影響し、幅の広い子busではlocal幅が残ります。子mapの実効幅と
  18.4.3.15の戻り値が、18.2.4.5の最小幅2 byteに対して4 byteになります。
  word単位と階層mapの2件で、規格の転送幅を期待値に保持します。
- `uvm_mem::get_offset`はlocation引数を使わず、memory先頭のmap offsetだけを返します。
  18.6.4.15は指定locationのoffsetを返すため、location 0・1・3の異なる期待値を1件で保持します。
  同じケースで、外部アドレスが正しく進むことも別に観測します。
- `uvm_mem::get_access`は単一mapのmemoryで、そのmapがROに制限していても固有のRWを返します。
  18.6.4.6の実効accessには制限の反映が必要です。同じケースで、18.6.4.5が非共有memoryへ定める
  RWの権限問い合わせを別の観測として保持します。
- `uvm_reg_predictor::pre_predict`で公開itemの転送先を変更しても、hook前に選んだ元のregisterを更新します。
  19.3.3.2は転送先の変更を認めるため、転送先と値を変更する1件で、元と転送先のmirrorの期待値を保持します。
- big endianのfrontdoor accessは、狭いbusのデータをregister-data型全体の幅でbyte反転し、
  その後のmaskで有効bitを失います。既存の2 word readは、18.4.4.10・19.1.2.3の値の復元を保持し、
  word内のbyte順の曖昧さを避けるため同じbyteを使います。新しい8 bit busのorder-policy検査系は、
  18.4.4.9のwrite byteと18.4.4.10のread値も保持します。readは、このbyte反転制約と
  順序に依存する再合成を組み合わせ、両原因を独立して切り分けるものではありません。
  policyのdispatch、geometry、要求address順は、失敗するdata検査とは別に観測します。

- registerのpre-write／pre-read hookをfieldのhookより後で実行します。
  18.4.8.1／.3と18.5.6.1／.3はregisterを先としているため、2件で期待する`RF`の順序を保持します。
  busアクセス自体は成功しますが、固定版は`FR`になります。登録callback objectを使わない継承methodのhookです。

- memoryのburstを物理bus記述子へ変換するとき、19.1.2.1が定めるREAD／WRITEへ変えず、
  UVM_BURST_READ／UVM_BURST_WRITEを渡します。幅をそろえたburstの2件で各物理beatの種別と、
  18.6.5.3／.4のデータ転送の期待値を保持します。テストベンチdriverは規定の物理READ／WRITEを扱います。

- `uvm_vreg::get_n_bytes`は宣言したbit幅をbyteに切り上げますが、18.9.1.2.9が定める
  実装先memoryのlocation幅には切り上げません。16 bitのvirtual registerを32 bit memoryに置く1件で、
  固定版の2 byteに対し4 byteの期待値を保持します。location数と増分は期待値・観測値とも1です。

- `uvm_vreg::implement`は実装済みの動的配列でもmemoryの`null`引数を拒否します。
  18.9.1.1.3はmemoryを省略したresizeでmemory・offset・増分を保持するため、そのresize結果と配置を期待値にします。
- `uvm_mem_region::get_virtual_registers`は実装したvirtual配列の所有者を記録せず、`null`を返します。
  18.12.7.2.7はvirtual配列のhandleを返すとするため、その期待値を保持し、実装の成功とmemoryのhandleも観測します。

- field単独の`uvm_vreg_field::write`は登録callbackより先に継承`post_write`を呼びます。
  18.10.6.2.2と18.10.5.2はcallbackを先とするため、`cM`を期待し、`Mc`を観測する差分を保持します。
  親のvirtual write経路ではcallbackを先に呼ぶことを比較対象として確認します。

- ユーザー定義backdoorのRC registerのreadはsampleと記憶域のclearには成功しますが、
  自動予測を有効にしても、0の代わりにsampleした値をミラーに記録します。
  read後のミラーの期待値は18.4.4.10・18.5.4.6・18.2.5.2・18.4.4.15・18.5.5.17から導きます。
  返り値とclear後の記憶域は成功する比較対象です。

- blockのmemory-walk wrapperは、E.6.2が定める`NO_MEM_WALK_TEST`の代わりに
  `NO_MEM_ACCESS_TEST`を除外guardで調べます。wrapper経由でアクセスしないという期待値を保持し、
  memoryを直接選んだwalkは成功する比較対象として検査します。

- 個別memoryのaccess sequenceは、E.5.1が指定する`NO_MEM_SHARED_ACCESS_TEST`の代わりに
  `NO_MEM_ACCESS_TEST`を調べます。必要なskipを保持し、別scopeのmemoryへのアクセスを成功する比較対象にします。

- 統合access wrapperは、blockに`NO_REG_ACCESS_TEST`が一致しても、memoryの走査には`NO_MEM_ACCESS_TEST`を調べます。
  E.3.3ではそのblockを統合検査から除外します。wrapperの観測区間はアクセスなしを要求し、
  register／memoryを直接指定した比較対象が動作することも検査します。
- register単独のbit bashは、登録した独自field policyを含むregisterにもアクセスします。
  E.2.1は未知policyのregisterを検査できないとします。アクセスなしの期待値を保ち、
  既知RWの別対象が動作することを比較対象にします。

- `pack_field_int`はsize 65／108で、16.5.4.9が要求するERRORを出しません。
  2件とも不正packの状態は調べず、新しいpackerで64-bitの往復が動作することを比較対象にします。

- comparerの`set_show_max(0)`は、0を無制限として個別の不一致reportを出します。
  16.3.5.1／16.3.3.7は最大数を定義し、0を無制限とする例外はありません。上限0のreportなしを保持し、
  3不一致すべての記録と、reportが見える上限5の比較対象も検査します。

これらの分岐は、固定版で再現したオラクルとしては扱いません。drop直後の一覧、transactionの
生成直後の状態、重大度・ID別のreset、無効なfield_opの操作名取得、応答数未満の深さ変更、
応答エラー報告の既定値、候補1件のUSER arbitration、lockの順序、kill後のhook、
不適合なdefault型のエラー、stop時の自動objection解除、時刻の既定名・API、
二段のinitiator socket接続、pushの連続転送、sequence libraryのAPIと削除、FIFOのpeek通知、
start_itemの重大度、library subtypeの構築、finish_itemの委譲・ID・入力検査、lock前のfield名検索、mapの幅・変換結果、locationごとのmemory offsetと単一mapの実効access、predictorの転送先、big endianのfrontdoor data、順序を変更したreadの再合成は診断用に保持します。
残りのライブラリの制約は、一致するテストシナリオでは避けています。

さらにcommand-lineのsuffix照会2件では、現在の`UVM_NO_DPI`設定で渡した引数を観測できません。
固定ライブラリの引数列挙stubが空の一覧を返すためです。一致とqueue置換の期待値は規格から保持します。
これは実行設定の制約であり、suffixの照合algorithm自体の不具合を実証したものではありません。

FIFOの失敗get／peek 4件は、12.2.4.2.6／.8の出力保持の事後条件を維持します。固定版実行は呼出し側のsentinelを置き換え、
成功する比較対象は動作します。宣言する`output` signatureとSystemVerilog 13.5のreturn時の代入は本文と食い違い、
シミュレータの不具合とは断定せず、解釈の作業として残します。

20-bit memory 2件は、19.1.2.4の`n_bits`をlogical model bit数と解釈し、8-bit busで幅8・8・4を期待します。
固定版実行は8・8・8を返しますが、address、方向、宣言dataの検査は一致します。
24-bit memory／16-bit busの比較対象は、byteに整列する幅16・8と一致します。sub-byteのlogical幅と
byteへ丸める物理転送幅の違いは要レビューとし、この2件からライブラリの確定した不具合とは断定しません。
[端数転送](faq.ja.md#errorの契約と端数転送)も参照してください。

databaseのstream列挙の検査系は、7.1.4.2のqueue数を返す事後条件を保持します。
2 streamは返すqueueに正しく入りますが、関数は0を返し、1 streamでは1を返します。
記載された`function unsigned`のsignatureは、SystemVerilog 13.4では暗黙の1-bit logicの戻りとなり、2を表現できません。
期待値2は本文の解釈を保持します。このsignature／本文の矛盾は要レビューとし、確認済みのsimulator／library不具合には割り当てません。

sequence報告の1検査系は14.1.3.3のadmission解釈を保持し、report-enabled照会がfalseなら4つの簡易報告methodは処理せず戻ると期待します。
reporter閾値NONEでHIGHの4照会はいずれもfalseですが、固定sequence実装はWARNING・ERROR・FATALをoverrideした処理methodへ渡し、INFOだけを抑制します。
検査系counterをresetした閾値以内の比較対象は4つとも通ります。server出力は行いません。
これは、non-INFOのverbosityを無視する6.3.3.3のreport-object規則とは別です。class固有の契約と継承動作は要レビューで、
simulatorの確定した不具合には割り当てません。規格から導いたsequenceの期待をspecのみで保持します。

追加のconcat 3件は17.2.3.3.1〜.4の標準APIを保持します。名前付きconstructorの検査は明示文字列、空文字列、省略を使い、固定concat classには対応する名前付きconstructorがありません。
accessor 2検査系は置換、有効な隙間、値copyの独立性、空配列、置換後の追記を扱い、最初のbuild失敗は標準slice accessorの欠落です。
legacy memberや異なる名前のmethodへ置換しません。3件ともbuildの記録で、実行時結果はありません。

command-line 18検査系は別のVPI bridgeと固定regex DPIを明示要求し、通常runnerはlinkせず実行時結果のないbuild 18件として記録します。
別command-line条件では17件が両seed一致し、1件はNOでlockしたquit上限をuser codeが変える際のG.2.6の警告要求を保持します。
上限は正しく7のままですが、固定serverはINFOを発行し、警告probeはWARNINGを観測しません。YESの比較対象は警告なしで9へ変わります。
これは診断severityの差分で、上限の強制失敗ではありません。以前のno-DPI引数2件は未変更の通常実行時差分です。

memory backdoor照会は継承block handleをcacheするため、保持するlocal選択oracleに対して、後のlocal-only get_backdoor(0)もそのhandleを返します。
そのspec-only fixture内の独自storage access、拒否、retry controlは一致します。coverageの利用可能性／有効化controlも一致しますが、memory setterは必要な以前maskではなく新maskを返します。
固定libraryでは公開backdoor_read taskがprotectedのため合法な外部task宣言をbuildできず、公開backdoor_writeは独立にcompileできます。
どちらの宣言probeも物理transferを呼びません。実array 3 fixtureは別VPI条件を使い、通常buildはDPIを欠きます。派生継承task wrapperで公開read宣言を修復しません。

package reportingは必要なNONE 0に対しgeneric WARNING 200／ERROR 100とhelper WARNING 200を保持します。明示fieldと他の既定行は一致しますが、両fixture全体をspec-onlyにします。
callback削除の返却値は一致しても、後のhandleの削除は配送を変え、削除handleもhookを受け、active peerの回数predicateは失敗します。
独立した削除なしfixtureでPRE_RUNを分離し、両pre hookはINITIALIZED、post hookはPOST_RUNを観測します。abortは別の一致する直接die controlを持ちます。
abortについてpeer callback順序やF.2.10のpost-run記述を作り足しません。

resource name lookupは既定rpterrで不一致でも必要なwarningを出さず、明示抑制と成功filter controlは一致します。
独立したlocal／global pool caseは割当precedence 3／9を観測しますが、nameは最大precedenceでなく最初のmatchを返します。
type queue priorityの部分観測は一致しても両fixtureをpassにせず、localのconstructor／singleton解釈境界はglobal caseと独立に残します。
記載pure get_type_handleを実装する合法resource-base拡張は、固定libraryが記載外pure helperも宣言するためbuildできません。
規格hook欠落negativeの独自compatibility本体は指定拒否を分離するためだけに使い、その合法拡張を修復しません。

スイート全体では、`verilator@5.052`を付けたテストは2075件、specのみのテストは395件です。
specのみのうち1件は9.6を検証します。pre-resetフェーズ終了時に子タスクが停止する
はずですが、固定版UVMとVerilator 5.052の組み合わせでは、後のフェーズで子タスクの遅延書き込みが
実行されます。この差分の原因がシミュレータとライブラリのどちらかは未確定です。

wakeup resetの検査系は、trigger waiterとpersistent-trigger waiterを各1つ確立してから`reset(1)`を呼びます。
10.1.1.2.8は、callbackなしで両方が起動することを要求します。固定Verilatorの実行は、待機状態の観測に到達してから
watchdogが期限切れになります。simulator／libraryを組み合わせた原因は未確定のまま、規範的なwakeupの期待を保持します。

specのみの395件も、規格から導いた出力またはcompiler診断の期待を保持します。通常のVerilator実行とCIはoracle付き2075件（runtime 1981・compile拒否94）を選びます。
`--all`はspecのみも含め、不一致やビルド不可を`known`として記録します。
通常の実行時255件は最初の差分であるseed 1までの記録で、seed 73の結果はありません。
simulation build 125件には通常runtimeがなく、DPI未linkの56入力（HDL 38／command-line 18）を含み、全分類は[実測の内訳](results.ja.md#結果の解釈)にあります。
不正compiler受理5件は別のruntimeなし条件です。

別HDL条件は全38入力のうち、virtual register／field 4件、register 6件、正時間force_time 8件、primitive force／release 9件、実array memory 3件を含む37件が両seed一致し、保持するE.7 warning／転送なし差分1件はseed 1です。
別command-line条件は17一致とquit-warning差分1件を保持し、重複条件を合算しません。

policy 7 fixtureはseed 1で最初に異なり、seed 73結果はありません。copierの省略名は空でなく、comparer threshold／copier recursion／recorder radixはflush後の規定既定値へ戻りません。
stream最大超過のpack_fieldは要求errorをreportしません。SHALLOW field automationでは別handleの等値childを等値と比較し、copyで独立childを作ります。
policyと既定field flagを組み合わせた解釈は限定して保持します。これらはsimulator／libraryの組合せ観測で、原因を断定しません。
不正packerは検査も再利用もせず、別の有効controlを使います。新規runtime 15件は両seed一致、recorder不正宣言7件はruntimeを実行せず拒否されます。
attribute override controlは独自dummy tokenを使い、専用macro／backend互換性を立証しません。

sequencer新規3件は差分を保持します。interface宣言のrequest既定型はuvm_sequence_itemですが、固定libraryはuvm_objectを宣言し、標準型のbase viewをbuildできません。
印刷されたbase API is_auto_enabled_recording_enabledは欠落し、別名のinterface照会は独立に検査します。この2件はruntime seedのないbuildです。
wait_for_sequences probeは字義的な待機の限定解釈で、seed 1においてproducer登場前に返ります。即時tryとoverrideの意味は部分対応のまま、確定不具合原因は断定しません。
新規runtime 17件と訂正rerandomization 1件は両seed一致、抽象生成2件はruntimeを実行せず拒否されます。

## 印刷report callback alias

ここで「印刷された」とは規格に記載された宣言をそのまま使う意味で、見出しと矛盾する解釈のレビュー依頼は[期待値の修正の案内](faq.ja.md#q18-期待値の誤りはどう報告修正しますか)を参照してください。

D.4.3は見出しをreport_cb、印刷typedef名をreport_dbとします。
[字義的宣言probe](../tests/uD/test_printed_report_callback_typedef_name_matches_the_declared_specialization.sv)は印刷されたuvm_report_dbを保持し、固定組合せでは欠落します。
runtime seedのないbuild evidenceで、限定した名前の食違いとして保持し、確定不具合の原因を割り当てません。動作する見出し名のcallback経路と他のexact aliasは別観測です。

## component寿命と便宜interfaceの観測

callbackの呼出しと、その中で開始したthreadの完了は別の観測で、phaseの境界で存続を調べるprocessは[寿命の用語](glossary.ja.md#componentの寿命と便宜hook)で説明しています。

lifetime probe 2つはcommon／runtime phase終了後もwriteとtickする子孫を観測します。callback probeは3 callbackのdispatchを観測しますが、start／end threadが完了してもready-to-end threadは完了しません。
印刷どおりのall_dropped function callerは利用可能なtaskに対してbuildできず、限定したsignature解釈としてruntime seedを持ちません。
型／名前による便宜replace 0条件では、その後の名前生成で後からの型が選ばれます。runtime 5件の期待をseed 1で保持し、seed 73やsimulator／libraryの確定原因を主張しません。

WARNING verbosityは6.3.3.3で明示的に無視するため、階層report fixtureはINFO 3件とWARNING 6件の配送を期待します。pair設定照会の境界は別です。
object名省略fixtureは任意user既定値を制約せず、独自constructorの既定を空にします。印刷create_object等価callの余分なthis引数は部分対応に保持します。

- [runtime phaseのtask／fork終了](../tests/u13/test_component_runtime_phase_kills_a_nonreturning_task_and_its_forked_descendant.sv)
- [共通runのtask／fork終了](../tests/u13/test_component_run_phase_kills_remaining_task_and_descendant_after_all_objections_drop.sv)
- [callback threadの継続](../tests/u13/test_component_phase_callback_threads_survive_their_runtime_phase_end.sv)
- [印刷all_dropped function](../tests/u13/test_component_printed_all_dropped_function_signature_dispatches_through_a_base_view.sv)
- [型による便宜replace 0](../tests/uD/test_component_factory_typed_type_override_forwards_default_and_explicit_replace.sv)
- [名前による便宜replace 0](../tests/uD/test_component_factory_named_type_override_forwards_default_and_explicit_replace.sv)

## specのみのテスト

明示したソースのパスで一覧の検査系を1件選べるため、両runtime seedを指定する方法は[1件を実行するコマンド](faq.ja.md#q3-まず1件だけ動かすにはどうしますか)を参照してください。

複数の入力が同じAPIの欠落で停止する場合があるため、一覧の件数は独立した不具合数ではなく、build時の障害とruntimeの観測は[実測の内訳](results.ja.md#結果の解釈)で区別しています。

specのみのケースも固定版oracle tagなしに規格から導いた期待値を保持するため、その注記の意味は[規格と期待値](glossary.ja.md#規格と期待値)を参照してください。

controlは差分を解釈するために前提を変えて実行する補助検査であり、元のケースの結果との関係は[要求への対応付けの役割](requirements.ja.md#引用要求実行の証拠)で説明しています。

現在のspecのみの395件へのリンクは、個別の説明と以下の一覧にあります。同じ制約を複数のテストで検査する場合があり、異なる不具合の個数ではありません。

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

- [uvm_infoの字義的なINFO境界](../tests/uB/test_report_macro_info_literal_info_boundary_81.sv).
- [uvm_info_contextの字義的なINFO境界](../tests/uB/test_report_macro_info_context_literal_info_boundary_81.sv).

- [none_negative_id_limit_literal](../tests/uF/test_enum_state_none_negative_id_limit_literal_84.sv).
- [sequence_kill_post_hooks_literal](../tests/uF/test_enum_state_sequence_kill_post_hooks_literal_84.sv).

- [field_flag_user_extension_129](../tests/uB/test_size_version_field_flag_user_extension_129_83.sv).
- [packer_minimum_define](../tests/uB/test_size_version_packer_minimum_define_83.sv).

- [Unregistered-instance empty delete](../tests/uB/test_callback_macro_unregistered_delete_instance_82.sv).

- [constructorでmodelを追加した測定の以前のmask返却](../tests/u18/test_reg_coverage_add_measurement_availability_80.sv)。

- [継承subscriber type_id特殊化](../tests/u08/test_builtin_abstract_parameterized_components_type_id_uses_the_required_registry_specialization.sv).
- [共有abstract object matrixのtransaction type_id欠落](../tests/u08/test_builtin_abstract_objects_type_id_uses_the_required_registry_specialization.sv).
- [継承parameter化sequence type_id特殊化](../tests/u08/test_builtin_abstract_parameterized_objects_type_id_uses_the_required_registry_specialization.sv).
- [独立probeのreport-server type_id欠落](../tests/u08/test_builtin_report_server_type_id_uses_its_own_named_abstract_registry.sv).
- [未知object型名に必要なERROR](../tests/u08/test_factory_unknown_object_name_reports_an_error_and_returns_null_with_a_registered_control.sv).
- [未知component型名に必要なERROR](../tests/u08/test_factory_unknown_component_name_reports_an_error_and_returns_null_with_a_registered_control.sv).

- [phase早期終了と元taskの寿命](../tests/u09/test_phase_end_prematurely_advances_without_a_jump_target_and_stops_original_task_threads.sv).
- [限定した字義get_imp non-IMP-null規則](../tests/u09/test_phase_get_imp_literal_non_imp_null_rule_remains_separate_from_the_node_prose.sv).
- [限定した印字get_schedule string返却型](../tests/u09/test_phase_get_schedule_printed_string_return_is_accepted_by_a_typed_string_receiver.sv).
- [明示初期化前にも常在するbuilt-in domain entry](../tests/u09/test_domain_listing_contains_required_builtin_domains_and_retains_new_named_instances.sv).

- [blocking initiator relayの印刷provider受理](../tests/u12/test_tlm2_blocking_passthrough_initiator_connect_accepts_its_spec_listed_provider_families.sv).
- [blocking target relayの印刷provider受理](../tests/u12/test_tlm2_blocking_passthrough_target_connect_accepts_its_spec_listed_provider_families.sv).
- [同種terminatorの直接binding拒否の限定解釈](../tests/u12/test_tlm2_same_kind_terminator_socket_connections_leave_no_provider_bindings.sv).

- [REQだけ指定するbidirectional portの独立integer応答既定型](../tests/u12/test_tlm_bidirectional_request_only_parameter_keeps_declared_integer_response_default.sv).

- [callback省略時の中間descendant total](../tests/u10/test_objection_skipped_propagation_delivers_default_and_registered_hooks_with_context.sv).

- [確立した早いraw event待ち](../tests/u10/test_event_raw_trigger_wait_distinguishes_early_and_same_slice_late_calls.sv).
- [既定reset後の実event waiter件数](../tests/u10/test_event_default_reset_preserves_mixed_waiters_for_a_fresh_trigger.sv).
- [必要なevent-pool初期項目](../tests/u10/test_event_pool_initial_membership_contains_begin_accept_and_end_without_lazy_get.sv).

- [単一encoderの値伝播](../tests/u18/test_user_backdoor_encode_single_propagates_all_value_elements.sv).
- [encoder chainの値伝播](../tests/u18/test_user_backdoor_encode_chain_propagates_all_value_elements.sv).
- [単一decoderのclear-data伝播](../tests/u18/test_user_backdoor_decode_single_propagates_all_value_elements.sv).
- [逆順decoder chainの伝播](../tests/u18/test_user_backdoor_decode_chain_propagates_all_value_elements.sv).

- [明示HDL abstractionの選択](../tests/uE/test_hdl_path_sequence_uses_an_explicit_abstraction_instead_of_the_invalid_default.sv).
- [空abstraction listでblock既定を使用](../tests/uE/test_hdl_path_sequence_uses_the_block_default_abstraction_when_the_list_is_empty.sv).
- [明示force_time 0のdeposit委譲](../tests/u19/test_hdl_force_time_explicit_zero_time_delegates_to_deposit_without_force_or_release.sv).
- [既定force_timeのdeposit委譲](../tests/u19/test_hdl_force_time_default_time_delegates_to_deposit_without_force_or_release.sv).

- [port-baseの名前・parent・role・generic型名](../tests/u05/test_port_base_preserves_names_parents_and_each_interface_role.sv).
- [elaboration後のblocking exportのdefault index切替](../tests/u12/test_blocking_export_default_index_switches_the_selected_implementation_after_elaboration.sv).
- [HDL depositの対象選択と存在しないpathの失敗](../tests/u19/test_hdl_deposit_sets_only_the_selected_variable_and_reports_missing_paths.sv).
- [利用不能なregister pathへのwarningとstorage転送なし](../tests/uE/test_hdl_path_sequence_warns_for_inaccessible_register_paths_without_storage_access.sv).
- [HDL readの実際のwide値と両変数の保持](../tests/u19/test_hdl_read_returns_actual_wide_storage_without_modifying_either_variable.sv).
- [既定abstractionの利用可能pathと時刻不変](../tests/uE/test_hdl_path_sequence_accepts_an_accessible_default_abstraction_without_advancing_time.sv).

- [policy／objectのactive-policy push／pop同期](../tests/u16/test_policy_object_stack_tracks_nested_active_policy_push_and_pop.sv).

- [register-itemの不正value index](../tests/u19/test_reg_item_invalid_value_indices_warn_without_changing_existing_data.sv).

- [簡易表記plusの1文字以上の照合](../tests/uF/test_is_match_plus_requires_at_least_one_character.sv).

- [並べ替えたlittle-endian readの再合成](../tests/u18/test_reg_order_policy_little_endian_read_uses_requested_bus_order.sv).
- [big-endianの順序付きwrite byte](../tests/u18/test_reg_order_policy_big_endian_write_uses_requested_bus_order.sv).
- [big-endianの順序付きread値](../tests/u18/test_reg_order_policy_big_endian_read_uses_requested_bus_order.sv).

- [componentのstream参照解放後の新規生成](../tests/u13/test_component_free_recording_stream_invalidates_only_its_cached_pair.sv).

- [phase implementation lookupのnode戻り値](../tests/u09/test_phase_implementation_lookup_stays_within_each_local_schedule.sv).
- [register／memory coverageの直前mask戻り値](../tests/u18/test_coverage_register_and_memory_controls_return_the_previously_enabled_models.sv).
- [block coverageの直前mask戻り値](../tests/u18/test_coverage_block_control_recurses_through_nested_models_and_preserves_peer.sv).
- [memoryの完了locationごとのsampling](../tests/u18/test_coverage_memory_sampling_observes_completed_reads_and_writes_on_the_selected_map.sv).

- [closed databaseのstream-open guard](../tests/u07/test_recording_database_ignores_stream_opens_until_connection_succeeds.sv)。
- [stream列挙の戻り件数](../tests/u07/test_recording_database_stream_enumeration_is_local_and_excludes_failed_opens.sv)。
  1-bit signatureとの矛盾を残し、queue数の本文を保持します。
- [未初期化stream照会のwarning](../tests/u07/test_recording_uninitialized_stream_queries_each_report_a_warning.sv)。

- [無効event callbackのdispatch](../tests/u10/test_event_disabled_callback_is_skipped_and_can_be_reenabled_for_later_triggers.sv)。
- [両event待機方式のwakeup reset](../tests/u10/test_event_reset_with_wakeup_releases_both_wait_styles_without_callback_dispatch.sv)。
  simulator／libraryの原因は未確定です。
- [model lock前後でのblockのregister単純名検索](../tests/u18/test_block_register_name_lookup_prefers_local_scope_and_finds_descendants.sv)。

- 必須のHDL concat API：
  [設定／読戻し](../tests/u17/test_hdl_concat_standard_set_slices_initializes_a_split_register_description.sv)と
  [追加／読戻し](../tests/u17/test_hdl_concat_standard_get_slices_returns_the_appended_most_to_least_order.sv)。
- [最も近い祖先の既定HDL abstraction](../tests/u18/test_block_hdl_default_abstraction_inherits_from_the_nearest_configured_ancestor.sv)。

- 空queueのpopのwarning：
  [先頭](../tests/u11/test_queue_empty_pop_front_warns_returns_default_and_allows_refill.sv)と
  [末尾](../tests/u11/test_queue_empty_pop_back_warns_returns_default_and_allows_refill.sv)。
- [memoryのpre-readでのmap／offset変更](../tests/u18/test_mem_registered_pre_read_callback_redirects_the_offset_and_map_before_transfer.sv)。
- [memoryのpost-write callbackの順序と最後のstatus](../tests/u18/test_mem_post_write_callback_precedes_final_status_hook_without_rewriting_storage.sv)。

- field_opのaccessorの必須エラー：
  [set前](../tests/u05/test_field_op_accessors_report_errors_before_set.sv)と
  [flush後](../tests/u05/test_field_op_accessors_report_errors_after_flush.sv)。
- [transactionの生成直後の非active状態](../tests/u05/test_transaction_is_inactive_before_first_begin.sv)。
- [report handlerの重大度・ID別reset](../tests/u06/test_report_handler_reset_clears_pair_severity_override.sv)。
- [phase終了時の残った子タスクの停止](../tests/u09/test_task_phase_kills_remaining_child_task.sv)。
  シミュレータとライブラリのどちらが原因かは未確定です。
- [drop直後のobjector一覧からの削除](../tests/u10/test_objection_objectors_list_removes_dropped_source.sv)。
- 応答エラー報告の既定値：
  [生成直後の設定](../tests/u14/test_sequence_response_controls_have_documented_defaults.sv)と
  [変更しない別instanceの設定](../tests/u14/test_sequence_response_control_updates_are_per_instance.sv)。
- 応答数未満への深さ変更の必須エラー：
  [応答2件を深さ1へ](../tests/u14/test_sequence_response_depth_shrink_below_two_replies_reports_error.sv)と
  [応答1件を深さ0へ](../tests/u14/test_sequence_response_depth_shrink_to_zero_with_one_reply_reports_error.sv)。
- [候補1件のUSER arbitration](../tests/u15/test_sequencer_user_arbitration_calls_override_with_one_candidate.sv)。
- lockの付与順：
  [取得済みitemの完了通知を待つ](../tests/u15/test_sequencer_lock_waits_until_previously_granted_item_completes.sv)と
  [先にキューへ入ったFIFO要求を追い越さない](../tests/u15/test_sequencer_fifo_lock_does_not_overtake_earlier_pending_item.sv)。
- kill後の必須hook：
  [sequencerあり](../tests/u14/test_sequence_kill_executes_required_post_hooks_when_bound.sv)と
  [sequencerなし](../tests/u14/test_sequence_kill_executes_required_post_hooks_when_unbound.sv)。
- 不適合なdefault sequenceの必須エラー：
  [通常のobject](../tests/u15/test_default_sequence_rejects_object_wrapper_with_required_error.sv)と
  [sequence item](../tests/u15/test_default_sequence_rejects_sequence_item_wrapper_with_required_error.sv)。
- stop時の自動objection解除：
  [単独sequence](../tests/u15/test_stop_sequences_drops_automatic_objection_for_active_sequence.sv)と
  [親子sequence](../tests/u15/test_stop_sequences_drops_automatic_objection_for_parent_and_child.sv)。
- canonical timeの規格APIと既定名：
  [既定の名前](../tests/u12/test_tlm2_time_default_constructor_uses_canonical_type_name.sv)と
  [default-resolution設定API](../tests/u12/test_tlm2_time_standard_default_resolution_api_constructs_delay.sv)。
  後者はビルド不可です。
- [二段のpass-through initiatorのbackward接続](../tests/u12/test_tlm2_nested_passthrough_initiators_route_both_directions.sv)。
- push方式の複数要求：
  [転送順序](../tests/u15/test_push_sequencer_delivers_each_request_once_in_sequence_order.sv)、
  [要求履歴](../tests/u15/test_push_sequencer_common_request_history_keeps_newest_handles.sv)、
  [応答履歴](../tests/u15/test_push_sequencer_common_response_history_counts_analysis_replies.sv)。
- sequence libraryの削除：
  [未登録型のwarning](../tests/u14/test_sequence_library_remove_unregistered_type_reports_warning.sv)と
  [typewideの伝搬](../tests/u14/test_sequence_library_remove_static_type_updates_all_existing_instances.sv)。
- sequence libraryの規格API欠落（6件ともビルド不可）：
  [既定mode](../tests/u14/test_sequence_library_standard_selection_mode_defaults_to_rand.sv)、
  [mode更新](../tests/u14/test_sequence_library_standard_selection_mode_updates_are_per_instance.sv)、
  [既定の範囲](../tests/u14/test_sequence_library_standard_count_bounds_default_to_ten.sv)、
  [回数の制約](../tests/u14/test_sequence_library_standard_count_bounds_constrain_randomized_count.sv)、
  [実行前の回数](../tests/u14/test_sequence_library_standard_execution_counter_starts_at_zero.sv)、
  [実行中・完了後の回数](../tests/u14/test_sequence_library_standard_execution_counter_excludes_active_child.sv)。
- FIFOのpeek通知：
  [blocking peek](../tests/u12/test_tlm_fifo_blocking_peek_publishes_each_observation_without_consuming.sv)と
  [nonblocking peek](../tests/u12/test_tlm_fifo_nonblocking_peek_publishes_each_success_without_consuming.sv)。
- `start_item`の必須ERROR：
  [`null` item](../tests/u14/test_sequence_start_item_null_argument_reports_error_and_returns.sv)、
  [sequence引数](../tests/u14/test_sequence_start_item_sequence_argument_reports_error_and_returns.sv)、
  [sequencer不足](../tests/u14/test_sequence_start_item_without_any_sequencer_reports_error_and_returns.sv)。
- libraryのstatic所属の構築：
  [2つのinstance](../tests/uB/test_sequence_library_macros_populate_two_constructed_instances.sv)、
  [2種類のlibrary](../tests/uB/test_sequence_library_macro_registers_one_sequence_with_two_library_types.sv)、
  [baseの所属](../tests/uB/test_sequence_library_macro_subtype_inherits_base_static_membership.sv)、
  [instance内の追加](../tests/uB/test_sequence_library_macro_membership_combines_with_local_addition_only_on_one_instance.sv)。
- finish_itemの必須virtual呼び出し：
  [送信](../tests/u14/test_sequence_finish_item_invokes_sequence_send_request_override.sv)と
  [完了待ち](../tests/u14/test_sequence_finish_item_invokes_sequence_completion_wait_override.sv)。
- finish_itemの完了ID：
  [1要求](../tests/u14/test_sequence_finish_item_passes_explicit_transaction_id_to_completion_wait.sv)と
  [2要求](../tests/u14/test_sequence_finish_item_keeps_each_transaction_id_in_two_completion_waits.sv)。
- finish_itemの必須入力検査：
  [`null` item](../tests/u14/test_sequence_finish_item_null_input_reports_error_before_mid_do.sv)、
  [sequence引数](../tests/u14/test_sequence_finish_item_sequence_input_reports_error_before_mid_do.sv)、
  [sequencer不足](../tests/u14/test_sequence_finish_item_missing_sequencer_input_reports_error_before_mid_do.sv)。
- lock前のfield名の検索：
  [構築済みfield](../tests/u18/test_reg_named_field_lookup_works_before_and_after_model_lock.sv)。
- mapの幅と変換の戻り値：
  [lock前の幅](../tests/u18/test_reg_map_byte_addressing_reports_width_before_and_after_lock.sv)、
  [word単位の変換](../tests/u18/test_reg_map_word_addressing_translates_offsets_in_bus_units.sv)、
  [階層の実効幅](../tests/u18/test_reg_submap_uses_root_base_and_narrowest_bus_width.sv)。
- locationごとのmemory offset：
  [location 0・1・3](../tests/u18/test_mem_location_offsets_include_the_location_index_stride.sv)。
- 単一mapでのmemoryのアクセス制限：
  [固有policyと制限したview](../tests/u18/test_mem_intrinsic_readonly_policy_and_map_rights_are_distinct.sv)。
- predictorの転送先変更：
  [転送先と値の変更](../tests/u19/test_reg_predictor_pre_predict_redirects_the_target_and_modified_value.sv)。
- big endianのfrontdoor read：
  [2つのbus word](../tests/u18/test_reg_frontdoor_big_endian_wide_read_preserves_returned_bus_words.sv)。

- fieldより先のregister hook：
  [pre-write](../tests/u18/test_reg_pre_write_hook_precedes_the_containing_fields_hook.sv)と
  [pre-read](../tests/u18/test_reg_pre_read_hook_precedes_the_containing_fields_hook.sv)。

- memory burstの物理beatの種別と転送：
  [write](../tests/u18/test_mem_frontdoor_burst_write_advances_full_width_locations.sv)と
  [read](../tests/u18/test_mem_frontdoor_burst_read_fills_full_width_array_in_location_order.sv)。

- 実装先memoryの幅に切り上げたvirtual registerのbyte幅：
  [幅の広いmemoryでの実装](../tests/u18/test_vreg_byte_width_rounds_up_to_the_implementing_memory_location_width.sv)。

- memoryを省略したvirtual配列の動的resize：
  [配置の維持](../tests/u18/test_vreg_dynamic_resize_without_memory_preserves_placement.sv)。
- 実装したregionのvirtual配列の所有者：
  [所有者とmemoryのhandle](../tests/u18/test_vreg_implementation_region_identifies_its_virtual_register_array.sv)。

- field単独のvirtual post-write callback順序：
  [callbackがmethodより先](../tests/u18/test_vreg_field_standalone_post_write_callback_precedes_its_inherited_method.sv)。

- ユーザー定義backdoorのread-clear予測：
  [sample・clear・read後のミラー](../tests/u19/test_reg_user_backdoor_read_applies_read_clear_after_sampling.sv)。

- blockを指定したmemory-walkの除外：
  [wrapperはskip・直接の比較対象は実行](../tests/uE/test_memory_walk_sequence_honors_a_block_specific_walk_exclusion.sv)。

- 個別memoryのaccessの除外：
  [指定されたshared-accessのresourceと別の比較対象](../tests/uE/test_single_memory_access_sequence_honors_its_shared_access_exclusion_resource.sv)。

- 統合accessのblock除外：
  [アクセスなしのwrapperとregister／memoryを直接指定した比較対象](../tests/uE/test_combined_access_wrapper_honors_block_exclusion_with_direct_controls.sv)。
- bit-bashの未知policyのskip：
  [登録した独自policyと既知RWの別対象](../tests/uE/test_single_bit_bash_sequence_skips_user_defined_unknown_policy.sv)。
- `UVM_NO_DPI`でのcommand-lineのsuffix収集：
  [複数の一致suffix](../tests/uG/test_command_arg_values_collect_matching_suffixes_without_stale_entries.sv)、
  [欠落／繰り返しの照会](../tests/uG/test_command_arg_values_clear_on_no_match_and_repeat_without_appending.sv)。

- 上限を超える整数packで必要なERROR：
  [65 bit](../tests/u16/test_packer_integral_size_65_reports_error_before_independent_boundary_control.sv)、
  [128 bit](../tests/u16/test_packer_integral_size_128_reports_error_before_independent_boundary_control.sv)。
- 取得不可FIFOの出力保持（signature／本文の解釈）：
  [値のget](../tests/u12/test_tlm_fifo_failed_try_get_preserves_two_state_value_before_success.sv)、
  [handleのget](../tests/u12/test_tlm_fifo_failed_try_get_preserves_object_handle_before_success.sv)、
  [値のpeek](../tests/u12/test_tlm_fifo_failed_try_peek_preserves_two_state_value_before_success.sv)、
  [handleのpeek](../tests/u12/test_tlm_fifo_failed_try_peek_preserves_object_handle_before_success.sv)。
- sub-byteのlogical幅の解釈：
  [20-bit write](../tests/u18/test_mem_frontdoor_twenty_bit_write_preserves_location_boundaries_and_partial_width.sv)、
  [20-bit read](../tests/u18/test_mem_frontdoor_twenty_bit_read_assembles_declared_bits_and_partial_width.sv)。

- overrideなしの名前照会：
  [object](../tests/u08/test_factory_no_override_object_queries_agree_with_ordinary_creation.sv)、
  [component](../tests/u08/test_factory_no_override_component_queries_agree_with_ordinary_creation.sv)。
- comparerのmessage上限0：
  [個別reportと、reportが見える比較対象](../tests/u16/test_comparer_zero_message_limit_suppresses_reports_before_a_visible_control.sv)。
  [出力と上限](faq.ja.md#出力上限応答の観測)も参照してください。

追加のconfiguration／relationship検査系：

- [既定resource dispatch](../tests/u13/test_component_config_application_matches_scope_and_passes_exact_resource.sv)
- [既定hook抑制](../tests/u13/test_component_config_disabled_user_hook_skips_set_local_for_one_application.sv)
- [strict resource dispatch](../tests/u13/test_component_strict_config_application_matches_scope_and_passes_exact_resource.sv)
- [strict hook抑制](../tests/u13/test_component_strict_config_disabled_user_hook_skips_set_local_for_one_application.sv)
- [0によるrelationship check無効化](../tests/u05/test_port_relationship_checks_default_off_and_explicit_zero_allow_remote_providers.sv)

追加のabstract registry／depth検査系：

- [parentなしabstract componentのerror／null](../tests/u08/test_abstract_component_registry_without_override_reports_error_and_returns_null.sv)
- [parent変更後の自動depth](../tests/u14/test_sequence_parent_reassignment_updates_calculated_depth_root_and_path.sv)

追加のmodel子孫名検索検査系：

- [child blockのmap検索](../tests/u18/test_block_map_name_lookup_selects_local_maps_then_unique_descendants.sv)
- [simple nameによる子孫block検索](../tests/u18/test_block_name_lookup_uses_simple_descendant_names_and_excludes_external_roots.sv)

追加のregister file abstraction検査系：

- [最も近い祖先の既定値](../tests/u18/test_regfile_default_hdl_abstraction_follows_nearest_ancestor_and_local_override.sv)
- [継承kindによるflatten full path](../tests/u18/test_flattened_regfile_omits_its_name_from_full_paths_for_each_selected_abstraction.sv)

追加のheartbeat／FIFO検査系：

- [動作中の既定event再利用](../tests/u10/test_heartbeat_default_start_reuses_its_event_while_running_and_after_stop.sv)
- [FIFO inline制約の観測](../tests/u18/test_reg_fifo_randomization_accepts_capacity_and_rejects_an_oversized_queue.sv)
- [subtypeで宣言したFIFOの境界](../tests/u18/test_reg_fifo_capacity_constraint_applies_to_subtype_declared_queue_sizes.sv)

追加のfield個別byte-enable検査系：

- [独立したfield write](../tests/u18/test_field_byte_enable_write_selects_individual_or_whole_register_access.sv)
- [独立したfield read](../tests/u18/test_field_byte_enable_read_selects_individual_or_whole_register_access.sv)

追加のmessage-handle／endian検査系：

- [事前構成messageの同一性](../tests/u06/test_report_catcher_exposes_the_supplied_preformed_message_and_current_origin.sv)
- [messageのlive alias](../tests/u06/test_report_catcher_message_handle_mutations_are_live_in_tail_and_caller.sv)
- [事前構成messageの再利用](../tests/u06/test_preformed_report_reuse_rebinds_origin_and_actions_for_each_reporter.sv)
- [個別big-endian fieldのaddress](../tests/u18/test_field_access_big_endian_respects_layout_and_physical_bus_width.sv)

- [Virtual処理前のsequence報告のseverity admission](../tests/u14/test_sequence_item_reporting_filters_each_severity_before_virtual_processing.sv).

- [名前付きconcat生成](../tests/u17/test_hdl_concat_standard_constructor_accepts_explicit_and_empty_instance_names.sv).
- [Concatの置換とcopyの独立性](../tests/u17/test_hdl_concat_standard_set_slices_replaces_prior_gapped_description_without_aliases.sv).
- [置換後のconcat追記](../tests/u17/test_hdl_concat_standard_add_slice_appends_after_replacement_and_preserves_peer.sv).

- [実引数一覧とsingletonの同一性](../tests/uG/test_command_vpi_singleton_and_all_arguments_preserve_supplied_membership.sv).
- [Plus引数の選別とqueue置換](../tests/uG/test_command_vpi_plusargs_exclude_dash_arguments_and_replace_caller_contents.sv).
- [大小を混ぜたUVM引数の選別](../tests/uG/test_command_vpi_uvm_arguments_accept_mixed_case_keywords_and_both_prefixes.sv).
- [Prefix照合の置換と欠落照会](../tests/uG/test_command_vpi_prefix_matches_replace_queues_and_clear_missing_queries.sv).
- [最初のsuffixと全一致件数](../tests/uG/test_command_vpi_first_value_preserves_the_first_suffix_and_counts_all_matches.sv).
- [空／comma入りsuffixの全取得](../tests/uG/test_command_vpi_all_values_keep_empty_and_comma_suffixes_without_stale_entries.sv).
- [Extended-regexの選択肢と照会の消去](../tests/uG/test_command_vpi_extended_regex_matches_grouped_alternatives_and_clears_queries.sv).
- [最初のtest名選択と重複警告](../tests/uG/test_command_testname_creates_the_first_registered_test_and_warns_for_duplicates.sv).
- [生成したcomponentへの初期verbosity](../tests/uG/test_command_initial_verbosity_applies_to_components_created_in_build.sv).
- [選択ID／componentだけの時刻verbosity変更](../tests/uG/test_command_timed_verbosity_updates_the_selected_id_and_component_only.sv).
- [選択component／IDのaction設定](../tests/uG/test_command_action_setting_is_scoped_to_the_selected_component_and_id.sv).
- [Severity overrideと比較対象の保持](../tests/uG/test_command_severity_override_changes_the_selected_report_and_preserves_controls.sv).
- [Quit上限の後の変更を許可](../tests/uG/test_command_max_quit_count_allows_a_later_user_setting.sv).
- [Quit上限の後の変更を拒否](../tests/uG/test_command_max_quit_count_rejects_a_later_user_setting.sv).
- [Factoryのinstance overrideとtype override](../tests/uG/test_command_factory_instance_override_precedes_the_type_override_for_its_target.sv).
- [数値base／文字列configとscope分離](../tests/uG/test_command_configuration_sets_numeric_bases_and_strings_in_the_selected_scope.sv).
- [指定sequencer／phaseでのdefault sequence実行](../tests/uG/test_command_default_sequence_runs_on_the_named_sequencer_and_phase.sv).
- [生成時の独立した引数snapshot](../tests/uG/test_command_fresh_processors_populate_independent_argument_snapshots_at_construction.sv).

既存2入力はcommand-enum引用と、訂正したBoolean rerandomization観測で指紋が変わっています。
対応する歴史的guest記録を除外し、互換範囲は1082記録、未測定は修正2入力を含む1388件です。
これはevidence範囲のfilterで、新しいguest fail／passやsimulator改善ではありません。

- [copier既定名](../tests/u16/test_policy_comparer_packer_and_copier_constructors_preserve_names_types_and_policy_bases.sv)
- [flush後のcomparer threshold](../tests/u16/test_comparer_threshold_default_updates_and_flush_restore_the_declared_boundary.sv)
- [flush後のcopier recursion](../tests/u16/test_copier_recursion_default_updates_and_flush_restore_the_declared_policy.sv)
- [SHALLOW child比較](../tests/u16/test_comparer_field_automation_distinguishes_nested_recursion_and_alias_conditions.sv)
- [SHALLOW child所有関係](../tests/u16/test_copier_field_automation_distinguishes_deep_shallow_and_default_child_ownership.sv)
- [wide pack上限超過error](../tests/u16/test_packer_wide_oversize_reports_error_before_an_independent_maximum_width_control.sv)
- [flush後のrecorder radix](../tests/u16/test_recorder_configuration_defaults_updates_and_flush_restore_the_declared_values.sv)

- [interface request既定値](../tests/u15/test_sequencer_interface_defaults_and_selected_legal_subtypes_keep_exact_base_types.sv)
- [印刷されたbase記録getter](../tests/u15/test_sequencer_base_printed_recording_query_reports_default_disable_and_peer_state.sv)
- [限定した待機解釈](../tests/u15/test_sequencer_interface_wait_for_sequences_stays_blocked_until_a_producer_is_available.sv)

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

- [記載pure hookだけを持つresource-base合法拡張](../tests/uC/test_resource_base_legal_extensions_preserve_default_explicit_names_virtual_type_handles.sv).
- [resource名検索の型／scope filterと既定warning](../tests/uC/test_resource_pool_name_lookup_filters_type_and_scope_and_respects_missing_report_controls.sv).
- [local resource poolのname precedenceとtype priority](../tests/uC/test_resource_pool_precedence_changes_name_selection_but_not_type_queue_priority.sv).
- [global resource poolのname precedenceとtype priority](../tests/uC/test_resource_pool_global_precedence_selects_name_maximum_and_keeps_type_priority.sv).

## シミュレータとライブラリの組み合わせ

共通するビルド上の問題1つで多数のテストがUVMの動作を実行する前に停止することがあり、その状態で後続の動作について何が分かるかは[Q9](faq.ja.md#q9-checkが緑ならkirimasimでもuvmが成功したということですか)で説明しています。

同梱ライブラリと固定ライブラリは異なる実行条件なので、記録の比較には[現在のスナップショット](results.ja.md#現在のスナップショット)を使ってください。

今回のguest filterはfieldのconfigure引用を直した入力を除き、以前の互換1083記録を1082へ絞るもので、guestを新しく実行していません。正確な除外と件数は[証拠のガイド](results.ja.md#記録の合算)で説明しています。

スイートは2470件ですが、以下のkirimasim／Ghost記録は未変更の現在入力1082件だけを対象とします。
以前の一時実行ファイル／profile snapshotがないため、1388入力は未測定です。
新しい全件guest実測とは扱いません。[実行結果](results.ja.md)を参照してください。

Ghostの同梱UVMはseed 1・73とも206件一致・876件不一致で、不一致になるテストも同じです。
現在の実行ファイルの固定コピーでは固定版modeを測定していません。記録の合算は[実行結果と測定方法](results.ja.md)で説明します。
同梱版の結果が対象にするのは供給されたライブラリです。不一致だけでシミュレータとライブラリの原因を分けたり、
固定版ライブラリの結果を示したりはできません。非公開の識別情報・profile・診断は公開しません。

確認したkirimasimの実行ファイルでは、1073件が`uvm_object_wrapper`未実装です。
時刻設定APIの1件、sequence libraryの6件、HDL sliceの2件は、その前にAPI欠落を検出して`fail`になります。
いずれも成功ではなく、その先のUVM動作を実行できた証拠でもありません。

実行範囲は[READMEの現在の実行結果](../README.ja.md#現在の実行結果)、
過去の測定は[履歴](history.ja.md)を参照してください。
