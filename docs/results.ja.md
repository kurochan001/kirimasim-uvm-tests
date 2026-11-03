# 現在の実行結果と測定方法

[English](results.md) · [README](../README.ja.md) · [既知差分](known-differences.ja.md)

## 現在のスナップショット

2026-11-03のVerilator記録は現在の1343件すべてを対象にします。他2系統は未変更1085件の記録で、
新規258件は未測定です。各記録は入力と実行条件を指紋で識別します。
21の章・付録directoryにM1 447件、M2 470件、M3 426件があります。
全件が`spec_check: ai`を記録し、人による照合やdeprecated APIの要求はありません。
1317件は`UVM_NO_DPI`を使い、8件はHDL DPIを明示要求し、別の18件はHDLを無効にしてcommand-line／regex DPIを有効にします。件数はレビュー済みカバレッジ率ではありません。

| シミュレータとライブラリ | 観測結果 | 実行範囲 |
| --- | --- | --- |
| Verilator 5.052・固定版UVM | `pass`が1180件、`known`が163件 | 一致ケースはseed 1・73で再現。実行時の差分はseed 1で停止 |
| Verilator 5.052・独自VPI HDL backend | `pass` 7件、`fail` 1件 | 重複する8件の別条件。一致はseed 1／73、差分はseed 1 |
| Verilator 5.052・独自command-line VPI bridge・固定regex DPI | `pass` 17件、`known` 1件 | 重複する18件の別条件。一致はseed 1／73、差分はseed 1 |
| kirimasim・固定版UVM | `unsupported`が1076件、`fail`が9件 | 未変更1085入力。新規258件は未測定 |
| Ghost・同梱UVM | `pass`が207件、`fail`が878件 | 各seedで未変更1085入力。失敗集合は同じ。新規258件は未測定 |
| Ghost・固定版UVM | 現在の実行ファイルの固定コピーでは未測定 | 現在の固定版modeの結果は示さない |

固定ライブラリはAccellera UVM 2020.3.1、コミット`78c06547a2a0`で、326ファイルを
[lock](../third_party/uvm.lock)と照合します。Ghostの同梱実行は、lockのパッケージではなく供給されたライブラリを使います。
非公開シミュレータの識別情報、版、パス、profileの内容、診断は公開しません。
公開interfaceは[Ghostの設定](testing.ja.md#ghost)で説明します。Icarus VerilogはこのUVMスイートには使いません。

## 結果の解釈

specのみの163件は、規格に基づく期待出力を保持します。通常条件では、121件がseed 1の実行時に最初に異なり、
seed 73の結果はありません。API欠落でビルドできない16件は、time 1件、sequence-library 6件、
HDL slice 4件、名前付きconcat constructor 1件、object active-policy 1件、catcher message-handle 3件です。別の26件（HDL 8件・command-line 18件）はDPIを要求しますが、通常runnerは対応backendをlinkしません。
この42 build記録には通常条件の実行時seed結果がありません。別command-line条件では17入力を再現し、quit警告の差分を保持します。以前のno-DPI引数検査2件は未変更の実行時差分です。

別のVPI条件は、独自backendでHDL検査系8件を実測し、7件がseed 1／73で一致します。
利用不能pathのsequenceは、warningに対してERRORを報告し、保持するE.7の転送なしの解釈に対してstorage readを試み、
seed 1で最初に異なります。利用可能pathの比較対象と、実際のHDL deposit／readは一致します。
backendの64 bit packed変数という範囲は、vendor overlay、配列、4値の動作を示しません。
重複するpass数を通常の合計へ加算しません。[HDL設定](testing.ja.md#verilatorのvpi-hdl部分集合)と
[既知差分](known-differences.ja.md)を参照してください。

kirimasimは1076件で`uvm_object_wrapper`未対応を報告し、残る9件はそれより先にライブラリAPI欠落を検出します。
いずれも、その障害より後のUVM動作を実行できた証拠ではありません。Ghostの同梱版の不一致だけでは、
シミュレータとライブラリのどちらが原因かは決まらず、固定版ライブラリでの結果も示しません。ゲストの付録Eの一致は、
[RO registerのskip](../tests/uE/test_single_register_access_sequence_skips_a_readonly_register.sv)、
[registerのbackdoorなしのskip](../tests/uE/test_single_register_access_sequence_skips_a_register_without_a_backdoor.sv)、
[memoryのbackdoorなしのskip](../tests/uE/test_single_memory_access_sequence_skips_a_memory_without_a_backdoor.sv)の条件だけを対象にします。
frontdoor／backdoorの転送動作の成功は示しません。

`known`・`unsupported`は成功に数えません。コマンドの終了コードだけではスイートの一致件数は分からないため、
[FAQ](faq.ja.md#結果の読み方)の分類と終了規則も確認します。2つのseedでは、決定性や4値の正しさは証明できません。

## 記録の合算

通常の記録は、[a00654e](https://github.com/kurochan001/kirimasim-uvm-tests/commit/a00654e6ec3364d36f2b9859b1b4052118f70480)
時点の未変更1326記録を保持し、現在の入力17件の実測を加えます。13件はseed 1・73で一致し、encode／decode伝播の4検査系はseed 1で最初に異なりseed 73の結果はありません。
追加は遅延task-readのhelper境界、既定callbackの比較対象、callback値pipeline、失敗／再試行を含む実際の直接／layered register translation、
sequence／frontdoorの型・名前、virtual model選択、macroから導くHDL幅parameterを扱います。

4差分は規格から導いた期待値を保持します。callbackの順序は一致しますが、変換配列は次のcallbackや最終の値経路へ届かず、既定の無変更動作が一致する比較対象とは別です。
検査codeがhelper配列を修復することはありません。no-DPI parameter probeは実装macroの数値既定値を固定せず、実際のHDL accessも認定しません。
全runner、以前の入力、catalog、両方の別VPI evidence条件は未変更で、重複する部分集合のpassを通常合計へ加えません。

保持するkirimasim／Ghost記録は、固定した実行ファイルとseedごとの非公開profileで取得しました。

商用シミュレータの結果は[投稿方針](faq.ja.md#商用シミュレータとissueの投稿方針)に従って除外します。

以前のkirimasim／Ghostの一時的な実行ファイル／profile snapshotは失われ、互換なlocal環境も見つかりませんでした。
新しいguest実行は主張しません。既存1085件は現在の入力と一致しますが、新規258 IDは明示的に未測定です。
localの対象範囲は`out/thin-thirty-third-evidence-scope.json`へ記録します。
許可された実行環境を復元するまで、この部分的な範囲を保持します。

指紋ごとに、識別する入力が異なります。

| 識別子 | 識別する内容 | 使い方 |
| --- | --- | --- |
| `inputs_sha256` | テストsource、期待値file、収集したhelper／data、library lock | 各記録を現在のテスト入力と照合する |
| `runner_sha256` | 選択したrunner、`suite_results.py`、`uvm_common.py` | batch間で一致し、`runner_changed`がfalseであることを確認する |
| `ledger_inputs_sha256` | 正本の範囲、要求、分類、テスト索引、条項catalog | simulationの証拠と別に、生成したinventory／backlogを識別する |

[台帳の識別子](requirements.ja.md#生成レポートの識別)は、生成したレビュー資料のものです。
入力／runnerのhashが一致しても、実行記録を再利用する前にシミュレータ、configuration、libraryの同一性を確認します。

合算する前に、次を確認します。

- Verilator IDが現在の全件を覆い、guest IDは宣言した1085件の部分集合と一致すること。新規258 IDは未測定のままにすること。
- 各記録の`inputs_sha256`が、ランナーの集めた現在のソース、期待出力、関連入力、ライブラリのlockと一致すること。
- batch間でシミュレータの版、configuration、`runner_sha256`が一致し、`runner_changed`がfalseであること。
- このスナップショットでは、Verilatorタグ付きの全ケースが`pass`、現在のタグなしケースがすべて`known`であること。
- Ghostの2つのseedで、不一致になるテストの集合が同じであること。

これは現在の入力に対する互換な実行記録の合算であり、全件を単一のコマンドで再実行したという主張ではありません。
追加時の件数と測定、過去のスモーク、build変更の詳細は[開発履歴](history.ja.md)に残します。
更新した記録で以前の記録を置き換える場合も、現在の入力の指紋を先に確認します。

[要求台帳の案](requirements.ja.md)は、spec-onlyの伝播4件を含む17検査系へAI要求案28件を追加し、以前の要求はすべて保持します。
個別の構造4件・文脈5件の分類で計113件となります。第19章は部分分解81番号・分類24番号・未評価6番号です。
M1〜M4の継続goalは有効で、未評価1,343番号・部分分解1,051番号が残ります。guest測定は追加しません。

新しい入力はVerilatorだけで測定し、guest実測は追加しません。既存の入力とrunnerの指紋はすべて互換性を保ちます。
未対応テスト0件でも、規範的な棚卸しの完了ではありません。
台帳のanchorは期待出力であり、追加測定した成功ではありません。

## 再現と結果の保存

コマンド、profileのmode、ライブラリの設定は[テストと開発のガイド](testing.ja.md#スイートの実行)で説明します。
`--json out/<name>.json`を指定すると、分類、理由、configuration、指紋を保存します。
`out/`はGitの対象外で、Checkはこのローカル記録を公開しません。
入力、ランナー、実行ファイル、profile、ライブラリが異なる結果は、別の実行条件です。

## 継続的インテグレーション

[Check](../.github/workflows/check.yml)は`main`へのpush、pull request、手動実行で動きます。
固定ライブラリの整合性、ツールの単体テスト101件、metadata 1343件、要求台帳の案／テスト索引、seed 1・73での通常oracle付きVerilator 1180件と、別条件の明示command-line 17件を検査します。
kirimasim、Ghost、specのみのケースは実行しません。READMEのバッジは現在のCIで、このローカル測定とは別の状態です。
Checkが成功しても、UVMの完全な適合性や全シミュレータの成功を示しません。Nightlyや結果の自動公開はありません。
