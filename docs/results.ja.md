# 現在の実行結果と測定方法

[English](results.md) · [README](../README.ja.md) · [既知差分](known-differences.ja.md)

## 現在のスナップショット

2026-11-04に集約したVerilator記録は現在の1472件すべてを対象にします。他2系統は未変更1084件の記録で、
388入力は未測定です。各記録は入力と実行条件を指紋で識別します。
スイートは21 directoryの1472件で、simulation 1447件とelaboration 25件です。
milestoneはM1 524件（507／17）、M2 516件（513／3）、M3 432件（427／5）で、括弧内はruntime／elaborationです。
全件が`spec_check: ai`で、人のレビューは記録していません。DPIなし1446件のうち25件は不正elaboration検査であり、HDL-DPI 8件とcommand-line／regex-DPI runtime 18件は別です。

| シミュレータとライブラリ | 観測結果 | 実行範囲 |
| --- | --- | --- |
| Verilator 5.052・固定版UVM | `pass` 1290件：runtime 1267＋compile拒否23、`known` 182件 | runtime一致はseed 1／73。期待compiler拒否は実行時seedを実行しない |
| Verilator 5.052・独自VPI HDL backend | `pass` 7件、`fail` 1件 | 重複する8件の別条件。一致はseed 1／73、差分はseed 1 |
| Verilator 5.052・独自command-line VPI bridge・固定regex DPI | `pass` 17件、`known` 1件 | 重複する18件の別条件。一致はseed 1／73、差分はseed 1 |
| kirimasim・固定版UVM | `unsupported`が1075件、`fail`が9件 | 未変更1084入力。388入力は未測定 |
| Ghost・同梱UVM | `pass`が207件、`fail`が877件 | 各seedで未変更1084入力。失敗集合は同じ。388入力は未測定 |
| Ghost・固定版UVM | 現在の実行ファイルの固定コピーでは未測定 | 現在の固定版modeの結果は示さない |

固定ライブラリはAccellera UVM 2020.3.1、コミット`78c06547a2a0`で、326ファイルを
[lock](../third_party/uvm.lock)と照合します。Ghostの同梱実行は、lockのパッケージではなく供給されたライブラリを使います。
非公開シミュレータの識別情報、版、パス、profileの内容、診断は公開しません。
公開interfaceは[Ghostの設定](testing.ja.md#ghost)で説明します。Icarus VerilogはこのUVMスイートには使いません。

## 結果の解釈

正当なnegative期待23件は、宣言したfixture／class／methodまたはconst参照の診断によるcompile拒否で一致します。
別の不正design 2件はsubscriberのwriteとvisitorのvisitを未実装でも受理され、拒否期待を既知差分として保持します。
受理されたものを含め、不正designはruntimeを実行しません。simulationの予期しないbuild失敗43件は別です。`pass`には宣言した期待との一致が必要です。

specのみ182件は、規格から導いた出力またはcompile診断の期待を保持します。不正compile受理2件とsimulation差分180件です。通常条件では、137件がseed 1の実行時に最初に異なり、
seed 73の結果はありません。API欠落でビルドできない16件は、time 1件、sequence-library 6件、
HDL slice 4件、名前付きconcat constructor 1件、object active-policy 1件、catcher message-handle 3件です。別の26件（HDL 8件・command-line 18件）はDPIを要求しますが、通常runnerは対応backendをlinkしません。
別の1件はbidirectionalの応答既定型が宣言された独立integer型と異なりbuildできません。計43 build記録には通常条件の実行時seed結果はありません。別command-line条件では17入力を再現し、quit警告の差分を保持します。以前のno-DPI引数検査2件は未変更の実行時差分です。

共有handler resetではseverity／ID verbosity値が残り、general／ID値とaction／fileは既定へ戻ります。
期待するresetと後続の境界配送は変更せず、runtimeの既知fixtureが1件増えます。以前のseverity override reset差分も保持します。

別のVPI条件は、独自backendでHDL検査系8件を実測し、7件がseed 1／73で一致します。
利用不能pathのsequenceは、warningに対してERRORを報告し、保持するE.7の転送なしの解釈に対してstorage readを試み、
seed 1で最初に異なります。利用可能pathの比較対象と、実際のHDL deposit／readは一致します。
backendの64 bit packed変数という範囲は、vendor overlay、配列、4値の動作を示しません。
重複するpass数を通常の合計へ加算しません。[HDL設定](testing.ja.md#verilatorのvpi-hdl部分集合)と
[既知差分](known-differences.ja.md)を参照してください。

kirimasimは1075件で`uvm_object_wrapper`未対応を報告し、残る9件はそれより先にライブラリAPI欠落を検出します。
いずれも、その障害より後のUVM動作を実行できた証拠ではありません。Ghostの同梱版の不一致だけでは、
シミュレータとライブラリのどちらが原因かは決まらず、固定版ライブラリでの結果も示しません。ゲストの付録Eの一致は、
[RO registerのskip](../tests/uE/test_single_register_access_sequence_skips_a_readonly_register.sv)、
[registerのbackdoorなしのskip](../tests/uE/test_single_register_access_sequence_skips_a_register_without_a_backdoor.sv)、
[memoryのbackdoorなしのskip](../tests/uE/test_single_memory_access_sequence_skips_a_memory_without_a_backdoor.sv)の条件だけを対象にします。
frontdoor／backdoorの転送動作の成功は示しません。

`known`・`unsupported`は成功に数えません。コマンドの終了コードだけではスイートの一致件数は分からないため、
[FAQ](faq.ja.md#結果の読み方)の分類と終了規則も確認します。2つのseedでは、決定性や4値の正しさは証明できません。

## 記録の合算

通常snapshotは
[a8258fb](https://github.com/kurochan001/kirimasim-uvm-tests/commit/a8258fb2f84e5cbcaab824e49d21a8bf211aed30)
の未変更1446入力記録を保持し、2026-11-04 JSTに測定した26入力を追加します。新規runtime 16件はseed 1／73で一致し、virtual policy／printer生成2件は宣言診断で拒否されruntime seedは実行しません。
新しいprinter 8検査系はseed 1で最初に異なり、seed 73結果はありません。以前の既知記録は全て未変更です。

差分はSHALLOW再帰、entry-depth境界解釈、独立した上限超過済みscope、無効radix prefix、root control既定値、flush後のtable／tree／line controlです。
境界解釈は限定したまま保持し、上限超過probeはactive entry 2つとlimit 0／1で等号を避けます。前の行が一致してもfixture全体をpassにしません。
測定不一致を規範的期待の置換には使いません。

初回observerをraw整数に加えてdecimal generic値も受け付けるよう修正しました。最終source hashは一致ケースだけに付けたtagを含みます。
以前の2177要求IDとlinkを保持し、constructor 1項目に直接linkを加えます。日英案97件と個別に読んだ分類13件を追加します。
当初重複していた要求案2件は、既存義務を二重化せず削除しました。以前の全fixture入力／記録、分類、runner／library／catalog、schema、workflow、SVGは未変更です。

保持するkirimasim／Ghost記録は、固定した実行ファイルとseedごとの非公開profileで取得しました。

商用シミュレータの結果は[投稿方針](faq.ja.md#商用シミュレータとissueの投稿方針)に従って除外します。

以前のkirimasim／Ghostの一時的な実行ファイル／profile snapshotは失われており、新しいguest実行は主張しません。
歴史的なfileには1085記録がありますが、command 1検査系の引用／指紋が変わったため、その記録を除外します。
現在と互換な部分集合は1084記録で、kirimasimはunsupported 1075件／API欠落fail 9件、Ghostは各seedでpass 207件／fail 877件です。
現在の未測定388入力は、当時以降の追加387件と引用を変更したcommand 1件です。
filterしたfileと`out/thin-forty-second-evidence-scope.json`に区別を保持し、許可された実行環境の復元を待ちます。

指紋ごとに、識別する入力が異なります。

| 識別子 | 識別する内容 | 使い方 |
| --- | --- | --- |
| `inputs_sha256` | テストsource、期待値file、収集したhelper／data、library lock | 各記録を現在のテスト入力と照合する |
| `runner_sha256` | 選択したrunner、`suite_results.py`、`uvm_common.py` | batch間で一致し、`runner_changed`がfalseであることを確認する |
| `ledger_inputs_sha256` | 正本の範囲、要求、分類、テスト索引、条項catalog | simulationの証拠と別に、生成したinventory／backlogを識別する |

[台帳の識別子](requirements.ja.md#生成レポートの識別)は、生成したレビュー資料のものです。
入力／runnerのhashが一致しても、実行記録を再利用する前にシミュレータ、configuration、libraryの同一性を確認します。

合算する前に、次を確認します。

- Verilator IDが現在の全件を覆い、guest IDは宣言した1084件の部分集合と一致すること。388入力IDは未測定のままにすること。
- 各記録の`inputs_sha256`が、ランナーの集めた現在のソース、期待出力、関連入力、ライブラリのlockと一致すること。
- batch間でシミュレータの版、configuration、`runner_sha256`が一致し、`runner_changed`がfalseであること。
- このスナップショットでは、Verilatorタグ付きの全ケースが`pass`、現在のタグなしケースがすべて`known`であること。
- Ghostの2つのseedで、不一致になるテストの集合が同じであること。

これは現在の入力に対する互換な実行記録の合算であり、全件を単一のコマンドで再実行したという主張ではありません。
追加時の件数と測定、過去のスモーク、build変更の詳細は[開発履歴](history.ja.md)に残します。
更新した記録で以前の記録を置き換える場合も、現在の入力の指紋を先に確認します。

[要求台帳の案](requirements.ja.md)はAI案2274件です。新規97件は選択message／handler印字内容、printer hook／履歴、再帰、element／array構造、radix control、root名、prefix、constructor／base型、default-instance lifecycleを扱います。
整理見出し11件と表現を説明する導入2件を分類し、文脈分類には具体的関連要求を示します。合計は部分分解1273・分類204・未評価1,030です。
第6章は98／19／0で全ての部分条件が残り、第16章は132／13／63です。printer 16.2節ではtable-format概要1件が未評価です。

互換なguest runtime 1084記録は全て保持し、388入力（simulation 363／elaboration 25）は未測定です。guest実行は主張しません。
1章の未評価0、構造／marker観測、直接link queue 0件は、全formatting、規範的coverage、分母承認を認定しません。

## 再現と結果の保存

コマンド、profileのmode、ライブラリの設定は[テストと開発のガイド](testing.ja.md#スイートの実行)で説明します。
`--json out/<name>.json`を指定すると、分類、理由、configuration、指紋を保存します。
`out/`はGitの対象外で、Checkはこのローカル記録を公開しません。
入力、ランナー、実行ファイル、profile、ライブラリが異なる結果は、別の実行条件です。

## 継続的インテグレーション

[Check](../.github/workflows/check.yml)は`main`へのpush、pull request、手動実行で動きます。
固定ライブラリの整合性、ツールの単体テスト110件、metadata 1472件、要求台帳の案／テスト索引、通常oracle付きVerilator 1290件（seed 1／73のruntime 1267・実行時seedなしのcompiler拒否23）と、別条件の明示command-line 17件を検査します。
kirimasim、Ghost、specのみのケースは実行しません。READMEのバッジは現在のCIで、このローカル測定とは別の状態です。
Checkが成功しても、UVMの完全な適合性や全シミュレータの成功を示しません。Nightlyや結果の自動公開はありません。
