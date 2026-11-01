# 既知差分

[English](known-differences.md) · [README](../README.ja.md) · [FAQ](faq.ja.md)

現在の733件と、固定したAccellera UVM 2020.3.1についての記録です。
不一致はテストの結果であり、それだけではシミュレータ・ライブラリ・期待値のどれが原因かは決まりません。

## 固定版ライブラリの制約

ライブラリ自身の`DEVIATIONS.md`には18.2.3.4・18.4.3.6・13.1.5.1の3件が載っています。
現在のregister検索ではmap引数を明示します。memoryを2つの兄弟interfaceのmapに登録する単純なケースは、
固定版でも18.2.3.4の期待値に一致しました。配布物の複数mapに関する注記と、mapを共有する階層は別途照合が必要です。
このケースが示すのは2つのinterfaceの構成です。[memoryの範囲](faq.ja.md#memorypredictionmapの制御)も参照してください。
それ以外に、M1・M2・M3で次の41件の制約を確認しました。
不足する必須動作を直接検査する場合は、規格の期待値を変えずに`:oracle: spec`で保持します。

- `find_override_by_name`は、置換がない場合に`null`を返します。元の型を生成できる場合も
  同じです。8.3.1.7.1は生成されるオブジェクトのwrapperを返すAPIとして説明しています。
  検索テストでは置換を明示し、別名テストでは生成されたオブジェクトの型を検査します。
- config_dbの既定の実装はフィールド名を文字列の一致で検索するため、設定したフィールド名の
  globがC.4.2.2.1の説明どおりに名前を選択しません。globテストはフィールド名を固定し、
  スコープのパターンを確かめます。
- fieldマクロで入れ子をcopyすると、UVM_SHALLOWでも別のオブジェクトが作られます。
  16.6.3は入れ子を参照として扱う動作を説明しています。一致するテストではdeep copyと、copyフックから
  見えるcopierの設定・処理中のオブジェクトを確かめます。
- 5.3.14.3の`uvm_object::get_active_policy`がありません。フックのテストは16.1.3のAPIで
  copier側の処理中オブジェクトのスタックを観測します。
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
- big endianのfrontdoor readは、狭いbusのデータをregister-data型全体の幅でbyte反転し、
  その後のmaskで戻り値のbitを失います。2 wordのケースは標準TLM adapterを使い、18.4.4.10・19.1.2.3の値の復元を保持し、
  word内のbyte順の曖昧さを避けるため同じbyteを使います。

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

これらの分岐は、固定版で再現したオラクルとしては扱いません。drop直後の一覧、transactionの
生成直後の状態、重大度・ID別のreset、無効なfield_opの操作名取得、応答数未満の深さ変更、
応答エラー報告の既定値、候補1件のUSER arbitration、lockの順序、kill後のhook、
不適合なdefault型のエラー、stop時の自動objection解除、時刻の既定名・API、
二段のinitiator socket接続、pushの連続転送、sequence libraryのAPIと削除、FIFOのpeek通知、
start_itemの重大度、library subtypeの構築、finish_itemの委譲・ID・入力検査、lock前のfield名検索、mapの幅・変換結果、locationごとのmemory offsetと単一mapの実効access、predictorの転送先、big endianのfrontdoor readは診断用に保持します。
残りのライブラリの制約は、一致するテストシナリオでは避けています。

スイート全体では、`verilator@5.052`を付けたテストは669件、specのみのテストは64件です。
specのみのうち1件は9.6を検証します。pre-resetフェーズ終了時に子タスクが停止する
はずですが、固定版UVMとVerilator 5.052の組み合わせでは、後のフェーズで子タスクの遅延書き込みが
実行されます。この差分の原因がシミュレータとライブラリのどちらかは未確定です。

specのみの64件も規格から導いた期待値を保持します。通常のVerilator実行とCIはoracle付き669件を選びます。
`--all`はspecのみも含め、不一致やビルド不可を`known`として記録します。
実行時の57件は最初の差分であるseed 1までの記録で、seed 73の結果はありません。
API欠落の7件（時刻APIの1件とsequence libraryの6件）はビルド段階で失敗し、どのseedも実行できていません。

## specのみのテスト

現在の64件は次のテストです。同じ制約を複数のテストで検査する場合があり、異なる不具合の個数ではありません。

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

## シミュレータとライブラリの組み合わせ

Ghostの同梱UVMはseed 1・73とも150件一致・583件不一致で、不一致になるテストも同じです。
現在の実行ファイルの固定コピーでは固定版modeを測定していません。記録の合算は[実行結果と測定方法](results.ja.md)で説明します。
同梱版の結果が対象にするのは供給されたライブラリです。不一致だけでシミュレータとライブラリの原因を分けたり、
固定版ライブラリの結果を示したりはできません。非公開の識別情報・profile・診断は公開しません。

確認したkirimasimの実行ファイルでは、726件が`uvm_object_wrapper`未実装です。
時刻設定APIの1件とsequence libraryの6件は、その前にAPI欠落を検出して`fail`になります。
いずれも成功ではなく、その先のUVM動作を実行できた証拠でもありません。

実行範囲は[READMEの現在の実行結果](../README.ja.md#現在の実行結果)、
過去の測定は[履歴](history.ja.md)を参照してください。
