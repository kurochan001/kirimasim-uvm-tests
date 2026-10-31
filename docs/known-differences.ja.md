# 既知差分

[English](known-differences.md) · [README](../README.ja.md) · [FAQ](faq.ja.md)

現在の373件と、固定したAccellera UVM 2020.3.1についての記録です。
不一致はテストの結果であり、それだけではシミュレータ・ライブラリ・期待値のどれが原因かは決まりません。

## 固定版ライブラリの制約

ライブラリ自身の`DEVIATIONS.md`には18.2.3.4・18.4.3.6・13.1.5.1の3件が載っています。
現在、一致するテストはその分岐を避けています。それ以外に、M1とM2で次の12件の制約を確認しました。
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

これらの分岐は、固定版で再現したオラクルとしては扱いません。drop直後の一覧、transactionの
生成直後の状態、重大度・ID別のreset、無効なfield_opの操作名取得、応答数未満の深さ変更、
応答エラー報告の既定値、候補1件のUSER arbitrationは診断用に保持します。
残りのライブラリの制約は、一致するテストシナリオでは避けています。

スイート全体では、`verilator@5.052`を付けたテストは362件、specのみのテストは11件です。
specのみのうち1件は9.6を検証します。pre-resetフェーズ終了時に子タスクが停止する
はずですが、固定版UVMとVerilator 5.052の組み合わせでは、後のフェーズで子タスクの遅延書き込みが
実行されます。この差分の原因がシミュレータとライブラリのどちらかは未確定です。

specのみの11件も、規格から導いた期待値を保持します。通常のVerilator実行とCIはタグのある
362件を選びます。`--all`を明示するとspecのみの11件も実行し、`known`として記録します。
ランナーは各テストで最初に不一致になったseedで停止するため、この11件の現在のVerilator記録は
seed 1の不一致を示し、seed 73の実行結果は示しません。

## specのみのテスト

現在の11件は次のテストです。同じ制約を複数のテストで検査する場合があり、異なる不具合の個数ではありません。

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

## シミュレータとライブラリの組み合わせ

Ghostの同梱UVMはseed 1・73とも95件一致・278件不一致で、不一致になるテストも同じです。
固定版UVMのスモークテストは、前処理を有効にした場合も不一致でした。
同梱版の結果だけではシミュレータと同梱ライブラリのどちらが原因かは決められず、
固定版ライブラリの実行証拠にもなりません。非公開の識別情報・プロファイル・診断は公開しません。

確認したkirimasimの実行ファイルでは、373件とも`uvm_object_wrapper`が未実装です。
これは成功でも、その後のUVM動作を検査できた証拠でもありません。
全件が共通のコンパイル依存により先へ進めない状態です。

実行範囲は[READMEの現在の実行結果](../README.ja.md#現在の実行結果)、
過去の測定は[履歴](history.ja.md)を参照してください。
