# OpenCode 引き継ぎ

2026-11-25 の Ghost ライブラリ方式の調査は、固定版 Accellera UVM 2020.3.1 で全2,794件を7周と、8周目の一部まで実行して終了しました。確認したシミュレータ不具合4件は、修正後にシード1・73で再確認済みです。 [測定結果と再現コード](docs/history.ja.md#2026-11-25-ghostのライブラリ方式の再テスト) · [English record](docs/history.md#2026-11-25-ghost-library-mode-retest)

## 再開時に見るもの

- 同じ作業環境では `out/library-retest-20261125-16h/triage/STATUS.ja.md` に切り分けの記録、`out/library-retest-20261125-16h/triage/issues/index.json` に起票先と修正後の証拠があります。
- `out/library-retest-20261125-16h/rounds/` の各周回に `progress.json`、`changes.json`、シード別の結果JSONがあります。`finished.json` が全件完了を示す最後の周回は `07-20261125-175528` です。
- 別のチェックアウトでは履歴の再現コードと、引継ぎガイドの実行コマンドを使ってください。 [日本語の開発ハンドオフ](docs/handoff.ja.md#再開と基本確認) · [English handoff](docs/handoff.md#resume-and-verify)

## 残っている確認

1. オブジェクト設定の差分はシード73の反復で変動しました。同一ビルド・同一シードで個別に反復し、最初の出力差分を取ってください。 [対象テスト](tests/u05/test_object_set_local_virtual_extension_selects_named_resource_properties.sv)
2. メモリ割当ては修正後のシード231で一致し、ほかの測定シードで不一致でした。シード1と231を再現し、固定版UVMの挙動と照合してください。 [対象テスト](tests/u18/test_mam_greedy_fresh_low_history_89.sv)
3. バリアの `reset(0)` は、古いイベントの待機者2つを残し、新しい待機者3つを解除しました。固定版UVMのイベント再割当てを踏まえて、テストの期待値を見直せるか確認してください。 [対象テスト](tests/u10/test_barrier_reset_without_wakeup_rearms_count_and_releases_old_waiters_at_fresh_threshold.sv)

公開資料では Ghost の表記を使います。起票前に固定版UVM、期待値、既存Issueも照合し、再現条件を確認してください。 [測定設定](docs/testing.ja.md#ghost)
