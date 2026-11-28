# OpenCode 引き継ぎ

[English](#english)

**テストスイートの開発**。関連性を待つ子を取り消しても親のロックが残ることを、M2の追加テストで確認しました。 [追加内容と検証結果](docs/history.ja.md#2026-11-28-シーケンサの所有権を持つ子の取消) · [残作業と優先候補](docs/handoff.ja.md#残作業と優先候補)

**Ghostのライブラリ方式**。11月28日に43件の修正を確認しました。定期回帰の比較基準は、入力指紋を照合した合算で各シード2,314件通過、482件不一致です。 [修正後の確認と基準](docs/ghost-dual-handoff.ja.md#修正後の確認)

以下は11月26日のライブラリ方式の再測定記録です。

2026-11-27 更新。Ghost のライブラリ方式と通常の SystemVerilog で見つかった不具合の調査を、ここから再開できます。UVM は固定版 Accellera UVM 2020.3.1 を使います。ほかの開発作業の再開手順もあります。 [日本語の開発ハンドオフ](docs/handoff.ja.md#再開と基本確認) · [English development handoff](docs/handoff.md#resume-and-verify)

## 最初に確認すること

1. 測定に使った作業ディレクトリで `out/library-retest-20261126/STATUS.ja.md` の「再開時に優先する確認」を開きます。起票先、再現コード、ログ、判定根拠は同じディレクトリの `triage-index.json` にも記録しています。このページの `out/` へのリンクは、同じ作業環境に保存された測定資料を指します。
2. 固定ビルド `candidate-2158` の全2,794件、シード1・73の計5,588試行が完了しました。両シードとも2,311件通過、483件失敗でした。11月25日の第7周と入力指紋が全件一致し、判定・理由の変化は0件でした。 [全件比較](out/library-retest-20261126/candidate-2158/baseline-comparison.json)
3. 比較元は `out/library-retest-20261125-16h/rounds/07-20261125-175528/` です。次回も入力指紋が一致するケースを照合し、旧ビルドで通過し新ビルドで失敗したケースを優先します。最初の観測差分、終了コード、実行条件を取り、固定版UVMの実装と適用可能な参照シミュレータで確認します。起票前に既存Issueを照合します。
4. 新しい固定ビルド `b7abb6b0569f` では、#3857〜#3865 の最小例が通常・厳格モードと、固定版UVMライブラリ方式の通常・厳格モードでシード1・73の全72試行に一致しました。GitHubでは9件ともクローズ済みです。関連するバックドア4例の最終値はVerilatorと一致し、3例では呼出し履歴の差分が残ります。 [試行別結果](out/library-retest-20261126/build-b7abb6b0569f/targeted/summary.json) · [バックドアの比較](out/library-retest-20261126/STATUS.ja.md#既存台帳を使った差分確認)
5. 失敗483件の原因判定を記録しました。`b7abb6b0569f` で全件を再実行し、両シードの966試行を保存しました。バックドア3件の履歴およびモジュール変数の更新欠落は sukimasim #3866 にまとめて起票しました。`1c879c613` で修正され、元の3件は両シードで Verilator と全観測行が一致しました。 [検証台帳](out/library-retest-20261126/triage-483/findings.json) · [監査結果](out/library-retest-20261126/triage-483/audit-status.json) · [sukimasim #3866](https://github.com/kurochan001/sukimasim/issues/3866)

```sh
cd "$(git rev-parse --show-toplevel)"
git status --short --branch
run=out/library-retest-20261126/candidate-2158
launchctl print "gui/$(id -u)/org.kirimasim.uvm-library-retest-20261126"
cat "$run/full-finished.json" "$run/baseline-comparison.json"
tail -n 10 "$run/full.err"
```

完了ファイルがなくジョブが停止している場合は、`full.err` と `full-attempts.jsonl` を確認し、既存のログを保存してから再実行します。実行中にランナー、固定版UVM、試験入力を変更すると、終了時の指紋検査に失敗します。

## 確認済みの結果と資料

- 11月25日は全件7周と8周目の一部を実行しました。起票した4件は修正後にシード1・73で確認しました。 [測定結果と再現コード](docs/history.ja.md#2026-11-25-ghostのライブラリ方式の再テスト) · [English record](docs/history.md#2026-11-25-ghost-library-mode-retest)
- 11月26日は10件を起票しました。基底リソースを取る関数内の `$cast` は修正後にシード73で最小例と元のテストがそれぞれ16回通過し、Issueはクローズ済みです。残る9件は、クラスメンバーと仮想タスク、配列、関数結果の添字、整数遅延、非ブロッキング代入に関する差分です。起票先と再現コードはローカルの詳細記録からたどれます。
- 過去に失敗した通常のSystemVerilog 137件は、固定ビルド `b7abb6b0569f` で両シードとも15件通過、122件差分でした。最初の追試で通過した6件に加え、#3859〜#3864 に関係する9件が通過しました。 [シード別の比較](out/library-retest-20261126/build-b7abb6b0569f/ordinary-sv/comparison.json)
- FIFO の `update()` と読み出しは、独自frontdoorの対照で Ghost と Verilator 5.054 の両シードが一致しました。2件の `set()` に対して4回書き込む結果は、`write()` が仮想 `set()` を呼ぶ固定版UVMの実装と一致します。 [再現コード](out/library-retest-20261126/repro/inspect_fifo_update_read_frontdoor.sv)
- メモリ割当ての履歴依存の期待は参照シミュレータでも変動しました。バリアの `reset(0)` で古い待機者が残るのは、固定版UVMがイベントを作り直す実装と一致します。再現と判断の根拠は同じ `STATUS.ja.md` にあります。

別のチェックアウトでは、版管理下の再現コードとGhostの実行ガイドから再開できます。 [再現コード](docs/repro/2026-11-25/) · [ライブラリ方式の実行手順](docs/testing.ja.md#ghost)

## English

**Test-suite development.** The latest M2 test checks that canceling a child during its relevance wait preserves the parent's lock. [New test and verification](docs/history.md#2026-11-28-killing-a-child-sequencer-owner) · [Remaining work](docs/handoff.md#remaining-work-and-suggested-order)

**Ghost library mode.** On November 28, the Ghost retest verified all 43 fixes. The assembled library-mode baseline for routine runs is 2,314 passes and 482 failures per seed. [Verification results and baseline](docs/ghost-dual-handoff.md#verification-after-the-fixes)

The notes below cover the November 26 library-mode retest.

Updated November 27, 2026. Resume the Ghost investigation here for both ordinary SystemVerilog and library mode with pinned Accellera UVM 2020.3.1. For other work, see the [development handoff](docs/handoff.md#resume-and-verify).

1. On the same workstation, start at the top of `out/library-retest-20261126/STATUS.ja.md`. The same directory's `triage-index.json` records issue URLs, reproducers, captures and findings. Links under `out/` refer to artifacts saved in that local workspace.
2. Snapshot `candidate-2158` completed all 5,588 trials across 2,794 tests on seeds 1 and 73. Each seed had 2,311 passes and 483 failures. Every input hash matched round 7 from November 25, and there were no changes in verdict or reason. [Full comparison](out/library-retest-20261126/candidate-2158/baseline-comparison.json)
3. For the next full run, compare matching input hashes against `out/library-retest-20261125-16h/rounds/07-20261125-175528/`. Prioritize tests that passed on the older build and fail on the newer build. Capture the first difference, exit status and execution conditions. Check the pinned library, an applicable reference simulator and existing issues before filing.
4. On snapshot `b7abb6b0569f`, the minimal reproducers for #3857–#3865 matched in all 72 trials on seeds 1 and 73, covering default and strict settings in both ordinary SystemVerilog and pinned UVM library mode. All nine issues are closed upstream. The four related backdoor tests matched Verilator on final values, with call-trace differences in three. [Trial results](out/library-retest-20261126/build-b7abb6b0569f/targeted/summary.json) · [Backdoor comparison](out/library-retest-20261126/STATUS.ja.md#既存台帳を使った差分確認)
5. The findings cover all 483 failures, with captures for 966 trials on snapshot `b7abb6b0569f`. Three backdoor cases exposed lost updates to module variables and were filed as sukimasim #3866. After fix `1c879c613`, all three cases matched Verilator on both seeds. [Findings](out/library-retest-20261126/triage-483/findings.json) · [Audit](out/library-retest-20261126/triage-483/audit-status.json) · [sukimasim #3866](https://github.com/kurochan001/sukimasim/issues/3866)

If the job stopped before writing its completion file, inspect `full.err` and preserve the existing logs before rerunning. The run verifies the runner, library and test input hashes before writing its final reports.

- On November 25, seven full rounds and part of an eighth were run. All four issues filed that day were verified after their fixes on seeds 1 and 73. [Measurements and reproducers](docs/history.md#2026-11-25-ghost-library-mode-retest)
- Ten issues were filed on November 26. The intermittent resource downcast was fixed and closed. Its minimal example and original test each passed 16 times on seed 73. The nine other issues cover class members and virtual tasks, arrays, selections on function results, integral delays and nonblocking assignments.
- Of 137 ordinary SystemVerilog cases selected from earlier failures, 15 passed and 122 differed on both seeds on snapshot `b7abb6b0569f`. Nine tests related to #3859–#3864 joined the six that passed in the first retest. [Seed-by-seed comparison](out/library-retest-20261126/build-b7abb6b0569f/ordinary-sv/comparison.json)
- Ghost and Verilator 5.054 agreed on both seeds in the FIFO `update()` and read control with a custom frontdoor. Two calls to `set()` produced four writes, consistent with the pinned UVM implementation calling virtual `set()` inside `write()`. [Reproducer](out/library-retest-20261126/repro/inspect_fifo_update_read_frontdoor.sv)
- The memory-allocation expectation about prior addresses also varied on the reference simulator. The pinned library replaces the event in `reset(0)`, leaving the old barrier waiters on their original event. The local status file records the evidence.

For other checkouts, start with the tracked reproducers and the documented runner. [Reproducers](docs/repro/2026-11-25/) · [Ghost testing guide](docs/testing.md#ghost)
