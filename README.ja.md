# kirimasim-uvm-tests

[English](README.md)

[![Check](https://github.com/kurochan001/kirimasim-uvm-tests/actions/workflows/check.yml/badge.svg)](https://github.com/kurochan001/kirimasim-uvm-tests/actions/workflows/check.yml)
[![License: Apache-2.0 WITH LLVM-exception](https://img.shields.io/badge/license-Apache--2.0%20WITH%20LLVM--exception-blue)](LICENSE)

Checkは自動検査の実行状態を示すバッジで、検査する対象は[CIの範囲](docs/results.ja.md#継続的インテグレーション)で確認できます。

IEEE 1800.2-2020のUniversal Verification Methodology（UVM）を対象にした、シミュレータ向け適合性テストです。
[kirimasim](https://github.com/kurochan001/kirimasim)を対象とし、IEEE 1800-2023のSystemVerilog言語を検査する
[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests)と対になります。

oracleは期待値の根拠を記録し、`spec`は規格、`verilator@5.052`は固定リリースでの再現も示します。
specのみの意味は[用語集の「規格と期待値」](docs/glossary.ja.md#規格と期待値)で説明しています。

> **状態：M4を進行中。** 21の章・付録directoryに全2313件（simulation 2221件・elaboration 92件）があります。
> oracle付きが1951件、specのみが362件です。
> 全件が`:spec_check: ai`で、人による照合は未記録です。M1〜M3の目標は未達です。
> M4はAI要求案3846件、直接対応テスト2281件と全2313件の索引があります。
> 未対応テスト0件、直接テストのない要求案0件で、memory-walkの歴史的解釈は照合が必要です。
> 未評価129番号、AI分類407番号があり、範囲と分母は未承認です。

## 目次

テスト件数、実行時の一致、レビュー状態は別のものを数えるため、関係は[読み方ガイド](docs/reading-guide.ja.md)で説明しています。

- [現在の対象範囲](#現在の対象範囲)
- [スイートの実行](#スイートの実行)
- [現在の実行結果](#現在の実行結果)
- [ドキュメント](#ドキュメント)
- [進め方](#進め方)・[変更や質問の報告](#変更質問の報告)・[ライセンス](#ライセンス)

## 現在の対象範囲

- **M1：982件（simulation 903・elaboration 79）。** objectとpolicy、reporting、factory、階層、phase、同期、configuration、
  recording、core service、型付きutility。
- **M2：547件（simulation 542・elaboration 5）。** sequenceとsequencer、request／responseのlifecycle、callback、
  TLM 1のchannel、一部のTLM 2 transport。
- **M3：784件（simulation 776・elaboration 8）。** register／field／block／memory／virtual registerのモデル、access path、prediction、
  callback、coverage、割り当て、組み込みtest sequence。uD内のD.3検査系はM3に数えます。

frontdoorとbackdoorはアクセス経路の名前で、それぞれの役割と実際のHDLアクセスとの違いは[レジスタの用語](docs/glossary.ja.md#レジスタモデル)で説明しています。
組み込みfrontdoorはテストベンチのadapter／sequencer／driverを接続します。
custom frontdoorはsequence本体で記憶域をモデル化し、passive predictorは別の検査系から観測値を入力します。
ユーザー定義backdoorは`uvm_reg_backdoor`の派生クラスでモデル化します。別のHDL検査系34件は、独自VPI backendを通じて実際の公開変数を使います。
command-line 18検査系は、別のVPI引数bridgeと固定UVM regex DPIを明示選択します。
17件が両seed一致、1件は診断severityの差分を保持し、通常runnerはそのbackendをlinkしません。

期待値は引用した規格に基づき、シミュレータとライブラリの組み合わせで差があっても、
規格の期待値を保持します。SystemVerilog言語そのものの検査はkirimasim-testsで扱います。

件数や条項の引用数は、レビュー済みの要求カバレッジの割合ではありません。
M4で主引用の棚卸しと明示的な要求の対応付けを始めましたが、規範的義務の分解と分母の承認は未完です。
[要求台帳のガイド](docs/requirements.ja.md)と[FAQ](docs/faq.ja.md)を参照してください。

## スイートの実行

まず1件で環境を確かめるため、必要な準備とseed指定は[最初の実行の案内](docs/reading-guide.ja.md#最初の実行の前に)を参照してください。

Python 3.10以降が必要です。固定版のoracleにはVerilator 5.052、C++ツールチェーン、makeを使います。
リポジトリのrootから実行します。

```sh
python3 tools/fetch_uvm.py
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 1 \
  --json out/verilator-smoke.json tests/u09/test_common_phases_run_in_order.sv
```

fetcherは固定したAccellera UVM 2020.3.1を取得して検査します。スモークのコマンドは1件だけを選びます。
oracle付き1951件（runtime 1864・compile拒否87）をすべて実行する場合は、次のコマンドを使います。

```sh
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 2 \
  --json out/verilator.json
```

`--all`を付けると、specのみの362件を含め、すべての2値テストを実行します。
`known`ではコマンドを失敗させず、oracleタグ付きの回帰では失敗させます。
`-j`は並行するテスト数、`--build-jobs`は各ビルド内のC++ジョブ数で、ビルドに時間がかかる理由は[Q13](docs/faq.ja.md#q13-ビルドが重い理由と2種類の並列数の違いは何ですか)で説明しています。
runtimeの各モデルは一度ビルドし、seedごとに新しいプロセスで実行します。

kirimasimの場合：

```sh
python3 tools/run_kirimasim.py --kirimasim /path/to/kirimasim -j 8 \
  --json out/kirimasim.json
```

kirimasimとGhostは既定で全件を選びます。ライブラリ／DPI設定、Ghostのprofile、テストのmetadata、判定規則、検査は
[テストと開発のガイド](docs/testing.ja.md#スイートの実行)を参照してください。
`out/`はGitの対象外で、結果は自動公開しません。

## 現在の実行結果

simulation一致とcompiler拒否は別の検査なので、以下のラベルと件数は[結果の読み方](docs/reading-guide.ja.md#結果を読む)を参照してください。

2026-11-06に集約したVerilator記録は、現在の2313件すべてを対象にします。
他2系統は互換な1082入力の記録で、1231入力は未測定です。Checkバッジとは別の結果です。

| シミュレータとライブラリ | 観測結果 |
| --- | --- |
| Verilator 5.052・固定版UVM・通常runner | runtime 1864件がseed 1／73一致、期待compile拒否87件、既知差分362件 |
| Verilator 5.052・独自VPI HDL backend | 別条件の部分集合34件で、33件が両seed一致、1件が差分 |
| Verilator 5.052・VPI command-line bridge・固定regex DPI | 別条件の18件で17件が両seed一致、1件は既知差分 |
| kirimasim・固定版UVM | 1082件で`unsupported` 1073件・API欠落`fail` 9件、1231入力は未測定 |
| Ghost・同梱UVM | 1082件で各seed一致206件・不一致876件、1231入力は未測定 |

通常runnerはseed 1のruntime差分243件、simulation build 114件、runtimeのない不正designの受理5件を記録します。
API／宣言、macro、DPIの内訳と限定した前提は[詳しい内訳](docs/results.ja.md#結果の解釈)で説明し、2種類のVPI部分集合は別条件に保ちます。

`known`・`unsupported`は成功に数えません。Ghostの同梱UVMの結果は、固定版ライブラリでの結果を示すものではありません。

詳しい実行条件と記録の範囲は[実行結果と測定方法](docs/results.ja.md)、ライブラリの制約とspecのみのケースは
[既知差分](docs/known-differences.ja.md)にあります。[Check](.github/workflows/check.yml)はツール・metadata・ライブラリ・
通常oracle付きVerilatorを8 shardへ分け、明示command-line 17件を検査し、kirimasimとGhostは実行しません。Nightlyや結果の自動公開はありません。

## ドキュメント

各ガイドに全文を対応させた英語版と日本語版を用意し、各ページから対になる言語へ移動できます。
コマンドやAPI識別子の表記は変えません。

| 資料 | English | 日本語 |
| --- | --- | --- |
| 初めて読むときの順序と説明 | [Reading guide](docs/reading-guide.md) | [読み方ガイド](docs/reading-guide.ja.md) |
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
| M1 | 基本クラス・policy・factory・phase・objection・設定・reporting | 982件。各条項2件以上という目標の棚卸しは未完 |
| M2 | sequence・sequencer・TLM・callback | 547件。目標は未達 |
| M3 | レジスタ層（17〜19、D.3、付録E） | 第17〜19章・D.3・付録Eに784件。目標は未達 |
| M4 | 要求台帳とカバレッジ | 進行中。AI要求案3846件、3846要求を2281テストへ直接対応。分母は未承認 |

D.3の名前アクセス検査系は規約に従いuDに置き、register層のM3へ数えます。M1〜M3は未完で、M4の開始が前段階の完了を意味しない理由は[段階の用語](docs/glossary.ja.md#範囲とカバレッジ)で説明しています。sequenceの所有／lifecycle、default resource、callback、TLM 2のprotocol／timing／socketの組合せ、
registerの割当／lifecycle、memory packing／端数beat、error／policy／map／prediction／frontdoor／callback／HDL／annex Eの組合せが残ります。
library注釈は規格との照合が必要で、RTL protocolとtimingのcoverageは別作業です。

## 変更・質問の報告

商用シミュレータの結果・出力・診断は利用も受け付けも行わず、第三者のもの、匿名化した要約、添付・リンクも対象です。
[投稿方針](docs/faq.ja.md#商用シミュレータとissueの投稿方針)と日英の[Issueフォーム](.github/ISSUE_TEMPLATE/report.yml)を使い、
IEEE 1800.2-2020の条項と独立した再現例で期待する動作を説明してください。

## ライセンス

Apache License 2.0 with LLVM Exceptions（`Apache-2.0 WITH LLVM-exception`）です。
[LICENSE](LICENSE)が原文で、[日本語参考訳](LICENSE.ja.md)は全文の非公式訳です。
ソースの由来と権利の扱いは[出典](docs/provenance.ja.md)と
[テストと開発のガイド](docs/testing.ja.md#権利と出典)を参照してください。
