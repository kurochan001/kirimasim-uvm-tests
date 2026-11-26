# OpenCode 引き継ぎ

[English](#english)

2026-11-26 更新。Ghost のライブラリ方式で、固定版 Accellera UVM 2020.3.1 を使った不具合調査の再開地点です。別の開発作業を再開する場合は、開発ハンドオフを参照してください。 [日本語](docs/handoff.ja.md#再開と基本確認) · [English](docs/handoff.md#resume-and-verify)

## 最初に確認すること

1. `out/library-retest-20261126/STATUS.ja.md` を開き、最新の起票、再現コード、修正後の確認、未判定の差分を確認します。`out/` はローカルに保存した測定資料です。
2. 修正ビルドで全2,794件をシード1・73で実行しています。下のコマンドで既存ジョブを確認します。`full-finished.json` が生成されたら、`full-progress.json` の `changes` とシード別 `library-full-1.json`・`library-full-73.json` を読みます。`full-attempts.jsonl` には各試行の判定と理由があります。
3. 比較元は `out/library-retest-20261125-16h/rounds/07-20261125-175528/` です。入力指紋が一致するケースの差分から、旧ビルドで通過し修正ビルドで失敗したケースを優先します。最初の観測差分、終了コード、実行条件を取り、固定版UVMの実装と適用可能な参照シミュレータで確認します。起票前に既存Issueを照合します。

```sh
cd "$(git rev-parse --show-toplevel)"
git status --short --branch
run=out/library-retest-20261126/candidate-2158
launchctl print "gui/$(id -u)/org.kirimasim.uvm-library-retest-20261126"
sed -n '1,60p' "$run/full-progress.json"
tail -n 10 "$run/full.err"
```

完了ファイルがなくジョブが停止している場合は、`full.err` と `full-attempts.jsonl` を確認し、既存のログを保存してから再実行します。実行中にランナー、固定版UVM、試験入力を変更すると、終了時の指紋検査に失敗します。

## 確認済みの結果と資料

- 11月25日は全件7周と8周目の一部を実行しました。起票した4件は修正後にシード1・73で確認しました。 [測定結果と再現コード](docs/history.ja.md#2026-11-25-ghostのライブラリ方式の再テスト) · [English record](docs/history.md#2026-11-25-ghost-library-mode-retest)
- 11月26日は、基底リソースを取る関数内の `$cast` が断続的に失敗するケースを起票しました。修正後はシード73で最小例と元のテストがそれぞれ16回通過し、Issueはクローズ済みです。起票先、最小例、ログは `out/library-retest-20261126/STATUS.ja.md` からたどれます。
- メモリ割当ての履歴依存の期待は参照シミュレータでも変動しました。バリアの `reset(0)` で古い待機者が残るのは、固定版UVMがイベントを作り直す実装と一致します。再現と判断の根拠は同じ `STATUS.ja.md` にあります。

別のチェックアウトでは、版管理下の再現コードとGhostの実行ガイドから再開できます。 [再現コード](docs/repro/2026-11-25/) · [ライブラリ方式の実行手順](docs/testing.ja.md#ghost)

## English

Updated November 26, 2026. This is the starting point for resuming the Ghost library-mode investigation with the pinned Accellera UVM 2020.3.1 library. For other development work, see the [development handoff](docs/handoff.md#resume-and-verify).

1. On the same workstation, read `out/library-retest-20261126/STATUS.ja.md` for the issue record, reproducers, verification after fixes and remaining differences.
2. Use the command block above to check the existing two-seed run for all 2,794 tests. When `full-finished.json` appears, inspect `changes` in `full-progress.json` and the seed-specific `library-full-1.json` and `library-full-73.json`. Each trial's verdict and reason are in `full-attempts.jsonl`.
3. Compare matching input hashes against `out/library-retest-20261125-16h/rounds/07-20261125-175528/`. Prioritize tests that passed on the older build and fail on the fixed build. Capture the first difference, exit status and execution conditions. Check the pinned library, an applicable reference simulator and existing issues before filing.

If the job stopped before writing its completion file, inspect `full.err` and preserve the existing logs before rerunning. The run verifies the runner, library and test input hashes before writing its final reports.

- On November 25, seven full rounds and part of an eighth were run. All four issues filed that day were verified after their fixes on seeds 1 and 73. [Measurements and reproducers](docs/history.md#2026-11-25-ghost-library-mode-retest)
- On November 26, an intermittent resource downcast failure was reported and closed after the fix. On seed 73, the minimal example and original test each passed 16 times on the fixed build. The issue and captures are in the local status file.
- The memory-allocation expectation about prior addresses also varied on the reference simulator. The pinned library replaces the event in `reset(0)`, leaving the old barrier waiters on their original event. The local status file records the evidence.

For other checkouts, start with the tracked reproducers and the documented runner. [Reproducers](docs/repro/2026-11-25/) · [Ghost testing guide](docs/testing.md#ghost)
