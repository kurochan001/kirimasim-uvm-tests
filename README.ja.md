# kirimasim-uvm-tests

[English](README.md)

[![Check](https://github.com/kurochan001/kirimasim-uvm-tests/actions/workflows/check.yml/badge.svg)](https://github.com/kurochan001/kirimasim-uvm-tests/actions/workflows/check.yml)
[![License: Apache-2.0 WITH LLVM-exception](https://img.shields.io/badge/license-Apache--2.0%20WITH%20LLVM--exception-blue)](LICENSE)

Checkは自動検査の実行状態を示すバッジで、検査する対象は[CIの範囲](docs/results.ja.md#継続的インテグレーション)で確認できます。

IEEE 1800.2-2020のUniversal Verification Methodology（UVM）を対象にした、シミュレータ向け適合性テストです。
[kirimasim](https://github.com/kurochan001/kirimasim)を対象とし、IEEE 1800-2023のSystemVerilog言語を検査する
[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests)と対になります。

UVMに不慣れな場合は、以下の件数を読む前に[読み方ガイド](docs/reading-guide.ja.md#このリポジトリが検査すること)でシミュレータ・ライブラリ・テストの関係を確認できます。

oracleは期待値の根拠を記録し、`spec`は規格、`verilator@5.052`は固定リリースでの再現も示します。
specのみの意味は[用語集の「規格と期待値」](docs/glossary.ja.md#規格と期待値)で説明しています。

> **状態：M4を進行中。** 22の章・付録directoryに全2723件（simulation 2624件・elaboration 99件）があります。
> oracle付きが2265件、specのみが458件です。
> 全件が`:spec_check: ai`で、AIによる照合を記録する意味は[照合の用語](docs/glossary.ja.md#規格と期待値)で説明しています。人による照合は未記録で、M1〜M3の目標は未達です。
> M4はAIが照合した[観測可能な義務の案](docs/requirements.ja.md#計数単位と対象範囲の案)4101件、直接対応テスト2667件と全2723件の索引があります。
> 未対応テスト0件、直接テストのない要求案0件で、[memory-walkの歴史的解釈](docs/faq.ja.md#q134-memory-walk-algorithmをどう解釈していますか)は照合が必要です。
> 未評価0番号・部分2062番号・AI分類445番号で、[未評価0は完了を意味せず](docs/faq.ja.md#q390-未評価の識別子0件なら残作業も0件ですか)、範囲と分母は未承認です。

## 目次

`unassessed`は条項の評価が未記録の件数、`known`は実測した差分を表し、2種類の残作業の意味は[進捗のガイド](docs/reading-guide.ja.md#対応状況と進捗を読む)と[結果の定義](docs/faq.ja.md#q5-passfailknownunsupportedはどう違いますか)で確認できます。

- [現在の対象範囲](#現在の対象範囲)
- [スイートの実行](#スイートの実行)
- [現在の実行結果](#現在の実行結果)
- [ドキュメント](#ドキュメント)
- [進め方](#進め方)・[変更や質問の報告](#変更質問の報告)・[ライセンス](#ライセンス)

## 現在の対象範囲

factoryはオブジェクトの生成、phaseは実行段階、TLMはcomponent間のtransactionの受け渡しを扱い、以下の対象一覧に出てくる語は[UVMの構成要素](docs/glossary.ja.md#uvmの構成要素)と[TLMの用語](docs/glossary.ja.md#transaction単位の通信)で確認できます。

- **M1：1171件（simulation 1090・elaboration 81）。** objectとpolicy、reporting、factory、階層、phase、同期、configuration、
  recording、core service、[static callback iteratorを含む型付きutility](docs/faq.ja.md#q397-主引用の追加でiterator条項は完了しますか)、[objectionの取消し](docs/faq.ja.md#q405-drain中の再raiseから何を追加しましたか)と[eventのdelta待機](docs/faq.ja.md#q419-eventのdelta-profileは何を追加しますか)・[取消しと再利用](docs/faq.ja.md#q422-4件の取消しprofileは何を追加しますか)。
- **M2：624件（simulation 617・elaboration 7）。** sequenceとsequencer、request／responseのlifecycle、callback、[記録の制御](docs/faq.ja.md#q413-recording無効化profileはflag-queryに何を追加しますか)、[propertyの記録](docs/faq.ja.md#q416-property-profileはtransaction-markに何を追加しますか)、[payloadのunpack](docs/faq.ja.md#q425-独立したunpack-streamは何を検査しますか)、
  TLM 1のchannel、[入れ子のinput／ref経路](docs/faq.ja.md#q402-delayのreferenceはendpointがcallerのhandleを置換できる意味ですか)を含む一部のTLM 2 transport。uFのF.2.3 port役割、F.2.4.2 state、F.2.4.3 sequence-library検査系は[段階の分類](docs/glossary.ja.md#範囲とカバレッジ)ではM2に数えます。
- **M3：928件（simulation 917・elaboration 11）。** register／field／block／memory／virtual registerのモデル、access path、prediction、
  callback、coverage、割り当て、組み込みtest sequence。uD内のD.3とu01内のmodel API profileは[機能対象の分類](docs/faq.ja.md#q381-同じu01-directory内のprofileを3つのmilestoneへ数える理由は)でM3に数えます。

frontdoorとbackdoorはアクセス経路の名前で、それぞれの役割と実際のHDLアクセスとの違いは[レジスタの用語](docs/glossary.ja.md#レジスタモデル)で説明しています。
組み込みfrontdoorはテストベンチのadapter／sequencer／driverを接続します。
custom frontdoorはsequence本体で記憶域をモデル化し、passive predictorは別の検査系から観測値を入力します。
ユーザー定義backdoorは`uvm_reg_backdoor`の派生クラスでモデル化します。別のHDL検査系38件は独自VPI backendを通じて実際の公開変数を使い、必要な実装のlinkは[HDLの準備](docs/testing.ja.md#verilatorのvpi-hdl部分集合)で説明しています。
command-line 18検査系は、別のVPI引数bridgeと固定UVM regex DPIを明示選択します。
17件が両seed一致、1件は診断severityの差分を保持し、bridgeを供給する[command-line runner](docs/testing.ja.md#verilatorのcommand-line部分集合)と、linkしない通常runnerは別の条件です。

期待値は引用した規格に基づき、シミュレータとライブラリの組み合わせで差があっても、
規格の期待値を保持します。SystemVerilog言語そのものの検査はkirimasim-testsで扱います。

件数や条項の引用数は、レビュー済みの要求カバレッジの割合ではありません。
M4で主引用の棚卸しと明示的な要求の対応付けを始めましたが、規範的義務の分解と分母の承認は未完です。
[要求台帳のガイド](docs/requirements.ja.md)と[FAQ](docs/faq.ja.md)を参照してください。

## スイートの実行

まず通常runnerで1件を動かして環境を確認し、前提条件とseed指定は[初回実行の案内](docs/reading-guide.ja.md#最初の実行の前に)、別backendが必要な場合は[実行条件の選び方](docs/reading-guide.ja.md#実行条件を選ぶ)を参照してください。

Python 3.10以降が必要です。固定版のoracleにはVerilator 5.052、C++ツールチェーン、makeを使います。
リポジトリのrootから実行します。

```sh
python3 tools/fetch_uvm.py
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 1 \
  --json out/verilator-smoke.json tests/u09/test_common_phases_run_in_order.sv
```

fetcherは固定したAccellera UVM 2020.3.1を取得して検査するもので、シミュレータとビルド用ツールは[環境のFAQ](docs/faq.ja.md#q2-必要な環境とuvmの取得元は何ですか)に従って別途用意します。スモークのコマンドは1件だけを選びます。
その1件が何を確かめるかは、ソースから期待出力、要求へ辿る[具体例](docs/reading-guide.ja.md#1件のテストをファイルで辿る)で確認できます。
保存したJSONにはケースごとの判定があり、読み方は[ファイルを開く具体例](docs/reading-guide.ja.md#結果jsonを開く)で確認できます。差分を報告した場合は、[差分を調べる](docs/reading-guide.ja.md#差分を調べる)の手順で、検査した期待値と実行条件を確認できます。

oracle付き2265件（runtime 2171・compile拒否94）をすべて実行する場合は、次のコマンドを使います。

```sh
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 2 \
  --json out/verilator.json
```

`--all`を付けると、specのみの458件を含め、すべての2値テストを実行します。
`known`ではコマンドを失敗させず、oracleタグ付きの回帰では失敗させます。
`-j`は並行するテスト数、`--build-jobs`は各ビルド内のC++ジョブ数で、ビルドに時間がかかる理由は[Q13](docs/faq.ja.md#q13-ビルドが重い理由と2種類の並列数の違いは何ですか)で説明しています。
runtimeの各モデルは一度ビルドし、seedごとに新しいプロセスで実行します。

kirimasimでは`/path/to/kirimasim`をインストール済みの実行ファイルのパスに置き換え、検査対象の選択と結果ファイルの扱いは[runnerのガイド](docs/testing.ja.md#スイートの実行)を参照してください。

```sh
python3 tools/run_kirimasim.py --kirimasim /path/to/kirimasim -j 8 \
  --json out/kirimasim.json
```

kirimasimとGhostは既定で全件を選びます。ライブラリ／DPI設定、Ghostのprofile、テストのmetadata、判定規則、検査は
[テストと開発のガイド](docs/testing.ja.md#スイートの実行)を参照してください。
`out/`はGitの対象外で、結果は自動公開しません。

## 現在の実行結果

simulation一致とcompiler拒否は別の検査なので、以下のラベルと件数は[結果の読み方](docs/reading-guide.ja.md#結果を読む)を参照してください。

2026-11-07に集約したVerilator記録は、現在の2723件すべてを対象にします。
他2系統は互換な1081入力の記録で、1642入力は[証拠の再利用規則](docs/results.ja.md#記録の合算)を満たす現在の記録がないため未測定です。

| シミュレータとライブラリ | 観測結果 |
| --- | --- |
| Verilator 5.052・固定版UVM・通常runner | runtime 2171件がseed 1／73一致、期待compile拒否94件、既知差分458件 |
| Verilator 5.052・独自VPI HDL backend | 別条件の部分集合38件で、37件が両seed一致、1件が差分 |
| Verilator 5.052・VPI command-line bridge・固定regex DPI | 別条件の18件で17件が両seed一致、1件は既知差分 |
| kirimasim・固定版UVM | 1081件で`unsupported` 1072件・API欠落`fail` 9件、1642入力は未測定 |
| Ghost・同梱UVM | 1081件で各seed一致206件・不一致875件、1642入力は未測定 |

通常runnerはseed 1のruntime差分318件、simulation build 135件、runtimeのない不正designの受理5件を記録します。
API／宣言、macro、DPIの内訳と限定した前提は[詳しい内訳](docs/results.ja.md#結果の解釈)で説明し、VPIの行は通常条件にも含まれるケースを別条件で測定したもので、スイート総数へ加算しない理由は[測定範囲](docs/results.ja.md#現在のスナップショット)で確認できます。

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
| 作業の再開と残課題 | [Handoff](docs/handoff.md) · [Claude Code](docs/claude-code-handoff.md) | [ハンドオフ](docs/handoff.ja.md) · [Claude Code](docs/claude-code-handoff.ja.md) |
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
| M1 | 基本クラス・policy・factory・phase・objection・設定・reporting | 1171件。各条項2件以上という目標の棚卸しは未完 |
| M2 | sequence・sequencer・TLM・callback | 624件。目標は未達 |
| M3 | レジスタ層（17〜19、D.3、付録E）と共通のAPI規則 | 1.4.2／1.4.3のmodel API profileを含め928件。目標は未達 |
| M4 | 要求台帳とカバレッジ | 進行中。AI要求案4101件、4101要求を2667テストへ直接対応。分母は未承認 |

M1〜M3はUVMのテスト領域、M4は要求の対応付けを扱い、[段階の定義](docs/glossary.ja.md#範囲とカバレッジ)で役割を確認できます。各条項2件という目標の進捗は主引用ごとの棚卸しで追い、必須動作の独立した検査を確認するための追加レビューは[計数の説明](docs/requirements.ja.md#引用要求実行の証拠)で説明しています。

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
