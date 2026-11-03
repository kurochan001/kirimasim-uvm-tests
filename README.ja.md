# kirimasim-uvm-tests

[English](README.md)

[![Check](https://github.com/kurochan001/kirimasim-uvm-tests/actions/workflows/check.yml/badge.svg)](https://github.com/kurochan001/kirimasim-uvm-tests/actions/workflows/check.yml)
[![License: Apache-2.0 WITH LLVM-exception](https://img.shields.io/badge/license-Apache--2.0%20WITH%20LLVM--exception-blue)](LICENSE)

IEEE 1800.2-2020のUniversal Verification Methodology（UVM）を対象にした、シミュレータ向け適合性テストです。
[kirimasim](https://github.com/kurochan001/kirimasim)を対象とし、IEEE 1800-2023のSystemVerilog言語を検査する
[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests)と対になります。

> **状態：M4を進行中。** 21の章・付録ディレクトリにシミュレーションテスト1188件があります。
> `verilator@5.052`のoracle付きが1062件、specのみが126件です。
> 全件が`:spec_check: ai`で、人による照合の記録はまだありません。
> M1・M2・M3はいずれも、要求カバレッジの目標が未達です。
> M4は要求案1351件、直接対応するテスト1187件と全1188件の索引があります。
> 未対応テスト0件、直接テストのない要求案0件です。memory-walkは歴史的解釈を明示しています。
> 未評価の識別子1,615件が残り、別の36件をAIで明示的に分類しました。対象範囲は未承認です。

## 目次

- [現在の対象範囲](#現在の対象範囲)
- [スイートの実行](#スイートの実行)
- [現在の実行結果](#現在の実行結果)
- [ドキュメント](#ドキュメント)
- [進め方](#進め方)・[変更や質問の報告](#変更質問の報告)・[ライセンス](#ライセンス)

## 現在の対象範囲

- **M1：397件。** object・transaction、copy／compare／print／packのpolicy、reporting、
  component階層、factory、phaseとgraph、objection、eventとそのcallback、barrier、configuration、databaseの接続・stream・link・recorder・componentの記録、core service・visitor・component検索、pool、queue、agent、文字列の分割／照合、enum名の変換、command-line引数の照会。
- **M2：434件。** TLM 1のFIFO・analysis・request／response・blocking transport channel、TLM 2のpayload・拡張・
  一部のsocket transport、sequence・sequence library・状態待機、response queue／handler、sequenceのreport、操作マクロ、pull／push sequencer、callback。
- **M3：357件。** register／field／block・memoryのモデル、階層の照会、fieldの制御、操作記述子、map・readの照合・transaction-order policy・sequence便利API、adapter、predictor、HDL pathの記述、組み込み／custom frontdoor、
  register／memory callback、coverage制御・sampling hook、間接register、virtual registerの配置・転送・割り当てpolicy・callback、ユーザー定義backdoor、
  動的な実装、memory領域の管理、端数幅のmemory転送、失敗／再試行のstatus、付録Eのreset／bit-bash／register・memory access／shared access／memory walk、
  統合access wrapper、未知policyのskip、テストの選択mask。

組み込みfrontdoorはテストベンチのadapter／sequencer／driverを接続します。
custom frontdoorはsequence本体で記憶域をモデル化し、passive predictorは別の検査系から観測値を入力します。
`uvm_reg_backdoor`の派生クラスでモデル化します。別のHDL検査系8件は、独自VPI backendを通じて実際の公開変数を使います。
期待値は引用した規格に基づき、シミュレータとライブラリの組み合わせで差があっても、
規格の期待値を保持します。SystemVerilog言語そのものの検査はkirimasim-testsで扱います。

件数や条項の引用数は、レビュー済みの要求カバレッジの割合ではありません。
M4で主引用の棚卸しと明示的な要求の対応付けを始めましたが、規範的義務の分解と分母の承認は未完です。
[要求台帳のガイド](docs/requirements.ja.md)と[FAQ](docs/faq.ja.md)を参照してください。

## スイートの実行

Python 3.10以降が必要です。固定版のoracleにはVerilator 5.052、C++ツールチェーン、makeを使います。
リポジトリのrootから実行します。

```sh
python3 tools/fetch_uvm.py
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 1 \
  --json out/verilator-smoke.json tests/u09/test_common_phases_run_in_order.sv
```

fetcherは固定したAccellera UVM 2020.3.1を取得して検査します。スモークのコマンドは1件だけを選びます。
oracle付き1062件をすべて実行する場合は、次のコマンドを使います。

```sh
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 2 \
  --json out/verilator.json
```

`--all`を付けると、specのみの126件を含め、すべての2値テストを実行します。
`known`ではコマンドを失敗させず、oracleタグ付きの回帰では失敗させます。
`-j`は並行するテスト数、`--build-jobs`は各ビルド内のC++ジョブ数です。
各モデルは一度ビルドし、seedごとに新しいプロセスで実行します。

kirimasimの場合：

```sh
python3 tools/run_kirimasim.py --kirimasim /path/to/kirimasim -j 8 \
  --json out/kirimasim.json
```

kirimasimとGhostは既定で全件を選びます。ライブラリ／DPI設定、Ghostのprofile、テストのmetadata、判定規則、検査は
[テストと開発のガイド](docs/testing.ja.md#スイートの実行)を参照してください。
`out/`はGitの対象外で、結果は自動公開しません。

## 現在の実行結果

2026-11-03のVerilator記録は、現在の1188件すべてを対象にします。
他2系統は未変更1085件の記録で、新規103件は未測定です。Checkバッジとは別の結果です。

| シミュレータとライブラリ | 観測結果 |
| --- | --- |
| Verilator 5.052・固定版UVM・通常runner | 1062件がseed 1・73で一致、既知差分126件 |
| Verilator 5.052・独自VPI HDL backend | 別条件の部分集合8件で、7件が両seed一致、1件が差分 |
| kirimasim・固定版UVM | 1085件で`unsupported` 1076件・API欠落`fail` 9件、新規103件は未測定 |
| Ghost・同梱UVM | 1085件で各seed一致207件・不一致878件、新規103件は未測定 |

通常runnerの126件は、seed 1の実行時差分108件、API欠落build 10件、DPI未linkのbuild 8件です。VPI部分集合は別条件です。
`known`・`unsupported`は成功に数えません。Ghostの同梱UVMの結果は、固定版ライブラリでの結果を示すものではありません。

詳しい実行条件と記録の範囲は[実行結果と測定方法](docs/results.ja.md)、ライブラリの制約とspecのみのケースは
[既知差分](docs/known-differences.ja.md)にあります。[Check](.github/workflows/check.yml)はツール・metadata・ライブラリ・
oracle付きVerilatorを検査し、kirimasimとGhostは実行しません。Nightlyや結果の自動公開はありません。

## ドキュメント

各ガイドに全文を対応させた英語版と日本語版を用意し、各ページから対になる言語へ移動できます。
コマンドやAPI識別子の表記は変えません。

| 資料 | English | 日本語 |
| --- | --- | --- |
| 作業の再開と残課題 | [Handoff](docs/handoff.md) | [ハンドオフ](docs/handoff.ja.md) |
| テスト形式・実行・変更時の規則 | [Testing guide](docs/testing.md) | [テストと開発のガイド](docs/testing.ja.md) |
| 現在の測定と測定方法 | [Results](docs/results.md) | [実行結果](docs/results.ja.md) |
| 対象範囲の案・要求の対応・カバレッジの棚卸し | [Requirement ledger](docs/requirements.md) | [要求台帳](docs/requirements.ja.md) |
| 用語 | [Glossary](docs/glossary.md) | [用語集](docs/glossary.ja.md) |
| 動作と検査系の範囲 | [FAQ](docs/faq.md) | [FAQ](docs/faq.ja.md) |
| ライブラリの制約とspecのみのケース | [Known differences](docs/known-differences.md) | [既知差分](docs/known-differences.ja.md) |
| 開発・測定の経緯 | [History](docs/history.md) | [開発履歴](docs/history.ja.md) |
| 関連リポジトリとソースの由来 | [Provenance](docs/provenance.md) | [出典](docs/provenance.ja.md) |

## 進め方

| 段階 | 範囲 | 現在の状態・目標 |
| --- | --- | --- |
| M0 | 取得・実行・metadataとツールの検査、Check、スモークテスト | 基盤を実装済み |
| M1 | 基本クラス・policy・factory・phase・objection・設定・reporting | 397件。各条項2件以上という目標の棚卸しは未完 |
| M2 | sequence・sequencer・TLM・callback | 434件。目標は未達 |
| M3 | レジスタ層（17〜19、付録E） | 第17〜19章・付録Eに357件。目標は未達 |
| M4 | 要求台帳とカバレッジ | 進行中。AI要求案1351件、1351要求を1187テストへ直接対応。分母は未承認 |

M1・M2・M3はいずれも独立した未完の段階です。M2にはキュー上の所有・停止・default resourceの条件、
callback、TLM 2のより広いprotocol・timing・socketの組み合わせが残っています。
M3には追加の割り当てpolicyと実装・転送条件、memoryのpacking／部分beat、エラー／policy／mapの条件、
predictorの統合、frontdoor／callbackの組み合わせ、HDL path／DPI、
付録Eの追加policy／エラー／mask条件が残っています。
ライブラリの条項注記は棚卸しの手がかりになりますが、規格との照合が必要です。
RTLのprotocolやtimingの検査は別の作業です。

## 変更・質問の報告

商用シミュレータの結果・出力・診断は利用も受け付けも行わず、第三者のもの、匿名化した要約、添付・リンクも対象です。
[投稿方針](docs/faq.ja.md#商用シミュレータとissueの投稿方針)と日英の[Issueフォーム](.github/ISSUE_TEMPLATE/report.yml)を使い、
IEEE 1800.2-2020の条項と独立した再現例で期待する動作を説明してください。

## ライセンス

Apache License 2.0 with LLVM Exceptions（`Apache-2.0 WITH LLVM-exception`）です。
[LICENSE](LICENSE)が原文で、[日本語参考訳](LICENSE.ja.md)は全文の非公式訳です。
ソースの由来と権利の扱いは[出典](docs/provenance.ja.md)と
[テストと開発のガイド](docs/testing.ja.md#権利と出典)を参照してください。
