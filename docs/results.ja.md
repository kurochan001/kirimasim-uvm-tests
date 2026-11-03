# 現在の実行結果と測定方法

[English](results.md) · [README](../README.ja.md) · [既知差分](known-differences.ja.md)

## 現在のスナップショット

2026-11-04に集約したVerilator記録は現在の1518件すべてを対象にします。他2系統は未変更1084件の記録で、
434入力は未測定です。各記録は入力と実行条件を指紋で識別します。
スイートは21 directoryの1518件で、simulation 1486件とelaboration 32件です。
milestoneはM1 553件（529／24）、M2 516件（513／3）、M3 449件（444／5）で、括弧内はruntime／elaborationです。
全件が`spec_check: ai`で、人のレビューは記録していません。DPIなし1492件のうち32件は不正elaboration検査であり、HDL-DPI 8件とcommand-line／regex-DPI runtime 18件は別です。

| シミュレータとライブラリ | 観測結果 | 実行範囲 |
| --- | --- | --- |
| Verilator 5.052・固定版UVM | `pass` 1329件：runtime 1299＋compile拒否30、`known` 189件 | runtime一致はseed 1／73。期待compiler拒否は実行時seedを実行しない |
| Verilator 5.052・独自VPI HDL backend | `pass` 7件、`fail` 1件 | 重複する8件の別条件。一致はseed 1／73、差分はseed 1 |
| Verilator 5.052・独自command-line VPI bridge・固定regex DPI | `pass` 17件、`known` 1件 | 重複する18件の別条件。一致はseed 1／73、差分はseed 1 |
| kirimasim・固定版UVM | `unsupported`が1075件、`fail`が9件 | 未変更1084入力。434入力は未測定 |
| Ghost・同梱UVM | `pass`が207件、`fail`が877件 | 各seedで未変更1084入力。失敗集合は同じ。434入力は未測定 |
| Ghost・固定版UVM | 現在の実行ファイルの固定コピーでは未測定 | 現在の固定版modeの結果は示さない |

固定ライブラリはAccellera UVM 2020.3.1、コミット`78c06547a2a0`で、326ファイルを
[lock](../third_party/uvm.lock)と照合します。Ghostの同梱実行は、lockのパッケージではなく供給されたライブラリを使います。
非公開シミュレータの識別情報、版、パス、profileの内容、診断は公開しません。
公開interfaceは[Ghostの設定](testing.ja.md#ghost)で説明します。Icarus VerilogはこのUVMスイートには使いません。

## 結果の解釈

正当なnegative期待30件は、宣言したfixture／class／methodまたはconst参照の診断によるcompile拒否で一致します。
別の不正design 2件はsubscriberのwriteとvisitorのvisitを未実装でも受理され、拒否期待を既知差分として保持します。
受理されたものを含め、不正designはruntimeを実行しません。simulationの予期しないbuild失敗43件は別です。`pass`には宣言した期待との一致が必要です。

specのみ189件は、規格から導いた出力またはcompile診断の期待を保持します。不正compile受理2件とsimulation差分187件です。通常条件では、144件がseed 1の実行時に最初に異なり、
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
[151c21a](https://github.com/kurochan001/kirimasim-uvm-tests/commit/151c21af022244e7718b487d19d3da54da1c0ce0)
の未変更1501入力記録を保持し、2026-11-04 JSTに測定したM3 runtime 17入力を追加します。全17件は最終metadataでseed 1／73に一致します。
以前のknown 189記録とcompile-only 32件は未変更で、新しい差分やcompiler検査は追加しません。

新規検査はmanager／memory同一性、全location単位のdescriptor、包含境界、予約lifetime、独立control付き不正解放、反復、互換再設定、default-policy反復randomize、割当失敗、region転送6 methodです。
転送observerは独自memory subtypeで、物理storageやbus modelではありません。relative addressの委譲、context、成功data、成功／失敗statusを確認し、失敗read dataは検査しません。
default-policy counterは要求ごとの増加だけを求め、randomize試行の正確な回数やretry方式は固定しません。

burst要素幅を観測memoryの1location幅に揃え、両方の選択burstを4-location領域内に収めます。
memory burst-write宣言は本文が規定するoffsetを省略し、region burst-read宣言はmemory APIがrefを使う位置にoutputを使います。
これらは限定した読み方を保ち、全burst長の規則は主張しません。初回observerの生成／signatureの問題は最終測定前に修正しました。
AI案44件と個別に読んだ分類7件を追加し、以前の義務8件へ直接linkを追加します。以前の2348 ID、他field、元linkを保持します。
以前の全fixture入力／記録、分類、schema、runner／library／catalog、workflow、SVGは未変更です。

保持するkirimasim／Ghost記録は、固定した実行ファイルとseedごとの非公開profileで取得しました。

商用シミュレータの結果は[投稿方針](faq.ja.md#商用シミュレータとissueの投稿方針)に従って除外します。

以前のkirimasim／Ghostの一時的な実行ファイル／profile snapshotは失われており、新しいguest実行は主張しません。
歴史的なfileには1085記録がありますが、command 1検査系の引用／指紋が変わったため、その記録を除外します。
現在と互換な部分集合は1084記録で、kirimasimはunsupported 1075件／API欠落fail 9件、Ghostは各seedでpass 207件／fail 877件です。
現在の未測定434入力は、当時以降の追加433件と引用を変更したcommand 1件です。
filterしたfileと`out/thin-forty-fourth-evidence-scope.json`に区別を保持し、許可された実行環境の復元を待ちます。

指紋ごとに、識別する入力が異なります。

| 識別子 | 識別する内容 | 使い方 |
| --- | --- | --- |
| `inputs_sha256` | テストsource、期待値file、収集したhelper／data、library lock | 各記録を現在のテスト入力と照合する |
| `runner_sha256` | 選択したrunner、`suite_results.py`、`uvm_common.py` | batch間で一致し、`runner_changed`がfalseであることを確認する |
| `ledger_inputs_sha256` | 正本の範囲、要求、分類、テスト索引、条項catalog | simulationの証拠と別に、生成したinventory／backlogを識別する |

[台帳の識別子](requirements.ja.md#生成レポートの識別)は、生成したレビュー資料のものです。
入力／runnerのhashが一致しても、実行記録を再利用する前にシミュレータ、configuration、libraryの同一性を確認します。

合算する前に、次を確認します。

- Verilator IDが現在の全件を覆い、guest IDは宣言した1084件の部分集合と一致すること。434入力IDは未測定のままにすること。
- 各記録の`inputs_sha256`が、ランナーの集めた現在のソース、期待出力、関連入力、ライブラリのlockと一致すること。
- batch間でシミュレータの版、configuration、`runner_sha256`が一致し、`runner_changed`がfalseであること。
- このスナップショットでは、Verilatorタグ付きの全ケースが`pass`、現在のタグなしケースがすべて`known`であること。
- Ghostの2つのseedで、不一致になるテストの集合が同じであること。

これは現在の入力に対する互換な実行記録の合算であり、全件を単一のコマンドで再実行したという主張ではありません。
追加時の件数と測定、過去のスモーク、build変更の詳細は[開発履歴](history.ja.md)に残します。
更新した記録で以前の記録を置き換える場合も、現在の入力の指紋を先に確認します。

[要求台帳の案](requirements.ja.md)はAI案2392件です。
新規44件は選択memory-manager class／configuration、region属性／lifetime、割当失敗、policy選択、転送委譲を分解します。
整理見出し6件とconfiguration導入1件を個別分類し、全体は部分分解1337・分類229・未評価941です。第18章は227／25／204です。
18.12節の未評価は6番号で、allocation／locality enum、状態文面、region概要、configurationのmode／locality member 2つです。
enum定数の代入だけから動作上の意味を認定せず、部分分解した全条件も未完了に保持します。

互換なguest runtime 1084記録は全て保持し、434入力（simulation 402／elaboration 32）は未測定です。guest実行は主張しません。
選択した委譲観測、link queue 0件、概要分類は、完全な規範的coverageや分母承認を示しません。

## 再現と結果の保存

コマンド、profileのmode、ライブラリの設定は[テストと開発のガイド](testing.ja.md#スイートの実行)で説明します。
`--json out/<name>.json`を指定すると、分類、理由、configuration、指紋を保存します。
`out/`はGitの対象外で、Checkはこのローカル記録を公開しません。
入力、ランナー、実行ファイル、profile、ライブラリが異なる結果は、別の実行条件です。

## 継続的インテグレーション

[Check](../.github/workflows/check.yml)は`main`へのpush、pull request、手動実行で動きます。
固定ライブラリの整合性、ツールの単体テスト110件、metadata 1518件、要求台帳の案／テスト索引、通常oracle付きVerilator 1329件（seed 1／73のruntime 1299・実行時seedなしのcompiler拒否30）と、別条件の明示command-line 17件を検査します。
kirimasim、Ghost、specのみのケースは実行しません。READMEのバッジは現在のCIで、このローカル測定とは別の状態です。
Checkが成功しても、UVMの完全な適合性や全シミュレータの成功を示しません。Nightlyや結果の自動公開はありません。
