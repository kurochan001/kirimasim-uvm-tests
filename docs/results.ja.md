# 現在の実行結果と測定方法

[English](results.md) · [README](../README.ja.md) · [既知差分](known-differences.ja.md)

## 現在のスナップショット

2026-11-01のローカル記録は現在の905件を対象にし、各記録は入力と実行条件を指紋で識別します。
20の章・付録ディレクトリにM1が279件、M2が380件、M3が246件あります。全件が`spec_check: ai`を記録し、
`UVM_NO_DPI`を使い、deprecated APIを要求しません。人による照合の記録はありません。
件数は、レビュー済みの要求カバレッジの割合ではありません。

| シミュレータとライブラリ | 観測結果 | 実行範囲 |
| --- | --- | --- |
| Verilator 5.052・固定版UVM | `pass`が818件、`known`が87件 | 一致ケースはseed 1・73で再現。実行時の差分はseed 1で停止 |
| kirimasim・固定版UVM | `unsupported`が898件、`fail`が7件 | 固定した実行ファイルのbuildと現在の全入力 |
| Ghost・同梱UVM | `pass`が182件、`fail`が723件 | seed 1・73の各結果。不一致の集合も同じ |
| Ghost・固定版UVM | 現在の実行ファイルの固定コピーでは未測定 | 現在の固定版modeの結果は示さない |

固定ライブラリはAccellera UVM 2020.3.1、コミット`78c06547a2a0`で、326ファイルを
[lock](../third_party/uvm.lock)と照合します。Ghostの同梱実行は、lockのパッケージではなく供給されたライブラリを使います。
非公開シミュレータの識別情報、版、パス、profileの内容、診断は公開しません。
公開interfaceは[Ghostの設定](testing.ja.md#ghost)で説明します。Icarus VerilogはこのUVMスイートには使いません。

## 結果の解釈

specのみの87件は、規格に基づく期待出力を保持します。Verilatorの記録では、80件が実行時のseed 1で最初の差分になります。
ランナーはそのseedで停止するため、これらの記録にseed 73の結果はありません。
7件はライブラリAPIの欠落でビルドできません。時刻APIが1件、sequence libraryのAPIが6件で、実行時のseed結果はありません。
既知差分の資料は、specのみの全ケースへのリンクと、原因を割り当てていないシミュレータ／ライブラリの組み合わせの制約も記載します。

kirimasimは898件で`uvm_object_wrapper`未対応を報告し、残る7件はそれより先にライブラリAPI欠落を検出します。
いずれも、その障害より後のUVM動作を実行できた証拠ではありません。Ghostの同梱版の不一致だけでは、
シミュレータとライブラリのどちらが原因かは決まらず、固定版ライブラリでの結果も示しません。ゲストの付録Eの一致は、
[RO registerのskip](../tests/uE/test_single_register_access_sequence_skips_a_readonly_register.sv)、
[registerのbackdoorなしのskip](../tests/uE/test_single_register_access_sequence_skips_a_register_without_a_backdoor.sv)、
[memoryのbackdoorなしのskip](../tests/uE/test_single_memory_access_sequence_skips_a_memory_without_a_backdoor.sv)の条件だけを対象にします。
frontdoor／backdoorの転送動作の成功は示しません。

`known`・`unsupported`は成功に数えません。コマンドの終了コードだけではスイートの一致件数は分からないため、
[FAQ](faq.ja.md#結果の読み方)の分類と終了規則も確認します。2つのseedでは、決定性や4値の正しさは証明できません。

## 記録の合算

現在の記録は、[631c6a4](https://github.com/kurochan001/kirimasim-uvm-tests/commit/631c6a43977444e741ddb38ed17e8cbd515c3bc4)
時点の885件を変更せずすべて保持し、新規20件の最終入力の測定を加えます。今回、既存テストの本体、metadata、期待出力は変更しません。Verilatorは固定リリース、kirimasimと本プロジェクトのゲストGhostは
実行ファイルの固定コピーを使い、Ghostは各seedで既存記録と同じ非公開profileの固定コピーも使います。
商用シミュレータの結果は[投稿方針](faq.ja.md#商用シミュレータとissueの投稿方針)に従って除外します。

合算する前に、次を確認します。

- テストIDが現在の集合を過不足なく覆うこと。
- 各記録の`inputs_sha256`が、ランナーの集めた現在のソース、期待出力、関連入力、ライブラリのlockと一致すること。
- batch間でシミュレータの版、configuration、`runner_sha256`が一致し、`runner_changed`がfalseであること。
- このスナップショットでは、Verilatorタグ付きの全ケースが`pass`、現在のタグなしケースがすべて`known`であること。
- Ghostの2つのseedで、不一致になるテストの集合が同じであること。

これは現在の入力に対する互換な実行記録の合算であり、全件を単一のコマンドで再実行したという主張ではありません。
追加時の件数と測定、過去のスモーク、build変更の詳細は[開発履歴](history.ja.md)に残します。
更新した記録で以前の記録を置き換える場合も、現在の入力の指紋を先に確認します。

[要求台帳の案](requirements.ja.md)には、新規20検査系と、既存のsequence context・制御・lifecycleの20検査系を対応付けます。
新しいシミュレーション入力だけを新たに測定し、既存の入力とrunnerの指紋はすべて互換性を保ちます。
未対応テスト0件でも、規範的な棚卸しの完了ではありません。
台帳のanchorは期待出力であり、追加測定した成功ではありません。

## 再現と結果の保存

コマンド、profileのmode、ライブラリの設定は[テストと開発のガイド](testing.ja.md#スイートの実行)で説明します。
`--json out/<name>.json`を指定すると、分類、理由、configuration、指紋を保存します。
`out/`はGitの対象外で、Checkはこのローカル記録を公開しません。
入力、ランナー、実行ファイル、profile、ライブラリが異なる結果は、別の実行条件です。

## 継続的インテグレーション

[Check](../.github/workflows/check.yml)は`main`へのpush、pull request、手動実行で動きます。
固定ライブラリの整合性、ツールの単体テスト74件、metadata 905件、要求台帳の案／テスト索引、seed 1・73でのoracle付きVerilator 818件を検査します。
kirimasim、Ghost、specのみのケースは実行しません。READMEのバッジは現在のCIで、このローカル測定とは別の状態です。
Checkが成功しても、UVMの完全な適合性や全シミュレータの成功を示しません。Nightlyや結果の自動公開はありません。
