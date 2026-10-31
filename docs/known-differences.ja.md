# 既知差分

[English](known-differences.md) · [README](../README.ja.md) · [FAQ](faq.ja.md)

現在の469件と、固定したAccellera UVM 2020.3.1についての記録です。
不一致はテストの結果であり、それだけではシミュレータ・ライブラリ・期待値のどれが原因かは決まりません。

## 固定版ライブラリの制約

ライブラリ自身の`DEVIATIONS.md`には18.2.3.4・18.4.3.6・13.1.5.1の3件が載っています。
現在、一致するテストはその分岐を避けています。それ以外に、M1とM2で次の20件の制約を確認しました。
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

これらの分岐は、固定版で再現したオラクルとしては扱いません。drop直後の一覧、transactionの
生成直後の状態、重大度・ID別のreset、無効なfield_opの操作名取得、応答数未満の深さ変更、
応答エラー報告の既定値、候補1件のUSER arbitration、lockの順序、kill後のhook、
不適合なdefault型のエラー、stop時の自動objection解除、時刻の既定名・API、
二段のinitiator socket接続、pushの連続転送は診断用に保持します。
残りのライブラリの制約は、一致するテストシナリオでは避けています。

スイート全体では、`verilator@5.052`を付けたテストは444件、specのみのテストは25件です。
specのみのうち1件は9.6を検証します。pre-resetフェーズ終了時に子タスクが停止する
はずですが、固定版UVMとVerilator 5.052の組み合わせでは、後のフェーズで子タスクの遅延書き込みが
実行されます。この差分の原因がシミュレータとライブラリのどちらかは未確定です。

specのみの25件も規格から導いた期待値を保持します。通常のVerilator実行とCIはoracle付き444件を選びます。
`--all`はspecのみも含め、不一致やビルド不可を`known`として記録します。
実行時の24件は最初の差分であるseed 1までの記録で、seed 73の結果はありません。
API欠落の1件はビルド段階で失敗し、どのseedも実行できていません。

## specのみのテスト

現在の25件は次のテストです。同じ制約を複数のテストで検査する場合があり、異なる不具合の個数ではありません。

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

## シミュレータとライブラリの組み合わせ

Ghostの同梱UVMはseed 1・73とも105件一致・364件不一致で、不一致になるテストも同じです。
固定版UVMのスモークテストは、前処理を有効にした場合も不一致でした。
同梱版の結果だけではシミュレータと同梱ライブラリのどちらが原因かは決められず、
固定版ライブラリの実行証拠にもなりません。非公開の識別情報・プロファイル・診断は公開しません。

確認したkirimasimの実行ファイルでは、468件が`uvm_object_wrapper`未実装です。
時刻設定APIのテスト1件は、その前に固定版ライブラリのAPI欠落を検出して`fail`になります。
いずれも成功ではなく、その先のUVM動作を実行できた証拠でもありません。

実行範囲は[READMEの現在の実行結果](../README.ja.md#現在の実行結果)、
過去の測定は[履歴](history.ja.md)を参照してください。
