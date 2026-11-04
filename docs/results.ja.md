# 現在の実行結果と測定方法

[English](results.md) · [README](../README.ja.md) · [既知差分](known-differences.ja.md)

## 現在のスナップショット

2026-11-05に集約したVerilator記録は現在の1696件すべてを対象にします。他2系統は未変更1083件の記録で、
613入力は未測定です。各記録は入力と実行条件を指紋で識別します。
スイートは21 directoryの1696件で、simulation 1649件とelaboration 47件です。
milestoneはM1 659件（622／37）、M2 538件（533／5）、M3 499件（494／5）で、括弧内はruntime／elaborationです。
全件が`spec_check: ai`で、人のレビューは記録していません。DPIなし1670件のうち47件は不正elaboration検査であり、HDL-DPI 8件とcommand-line／regex-DPI runtime 18件は別です。

| シミュレータとライブラリ | 観測結果 | 実行範囲 |
| --- | --- | --- |
| Verilator 5.052・固定版UVM | `pass` 1481件：runtime 1436＋compile拒否45、`known` 215件 | runtime一致はseed 1／73。期待compiler拒否は実行時seedを実行しない |
| Verilator 5.052・独自VPI HDL backend | `pass` 7件、`fail` 1件 | 重複する8件の別条件。一致はseed 1／73、差分はseed 1 |
| Verilator 5.052・独自command-line VPI bridge・固定regex DPI | `pass` 17件、`known` 1件 | 重複する18件の別条件。一致はseed 1／73、差分はseed 1 |
| kirimasim・固定版UVM | `unsupported`が1074件、`fail`が9件 | 未変更1083入力。613入力は未測定 |
| Ghost・同梱UVM | `pass`が207件、`fail`が876件 | 各seedで未変更1083入力。失敗集合は同じ。613入力は未測定 |
| Ghost・固定版UVM | 現在の実行ファイルの固定コピーでは未測定 | 現在の固定版modeの結果は示さない |

固定ライブラリはAccellera UVM 2020.3.1、コミット`78c06547a2a0`で、326ファイルを
[lock](../third_party/uvm.lock)と照合します。Ghostの同梱実行は、lockのパッケージではなく供給されたライブラリを使います。
非公開シミュレータの識別情報、版、パス、profileの内容、診断は公開しません。
公開interfaceは[Ghostの設定](testing.ja.md#ghost)で説明します。Icarus VerilogはこのUVMスイートには使いません。

## 結果の解釈

正当なnegative期待45件は、宣言したfixture／class／method／禁止memberまたはconst参照の診断によるcompile拒否で一致します。
別の不正design 2件はsubscriberのwriteとvisitorのvisitを未実装でも受理され、拒否期待を既知差分として保持します。
受理されたものを含め、不正designはruntimeを実行しません。simulationの予期しないbuild失敗52件は別です。`pass`には宣言した期待との一致が必要です。

specのみの215件は規格由来の出力またはcompile診断期待を保持し、不正compiler受理2件とsimulation 213件です。
simulationのうち161件はseed 1で最初に異なり、seed 73結果はありません。API／型名欠落build 20件はtime API 1、sequence-library API 6、HDL slice 4、named-concat constructor 1、object active-policy API 1、catcher message-handle 3、印刷されたbase記録状態getter 1、印刷report callback typedef 1、built-in type_id 2です。

宣言build 2件は既定型の不一致で、別の2件は印刷all_dropped function／taskとclone暗黙scalar／map返却の食違いを保持します。
さらに2件は継承したtype_id registry特殊化の非互換です。ほか26件はDPI未linkでHDL 8・command-line 18です。
simulation build 52件にはruntime結果がなく、別command-line条件は17一致とquit-warning差分1件を保持します。

共有handler resetではseverity／ID verbosity値が残り、general／ID値とaction／fileは既定へ戻ります。
期待するresetと後続の境界配送は変更せず、runtimeの既知fixtureが1件増えます。以前のseverity override reset差分も保持します。

別のVPI条件は、独自backendでHDL検査系8件を実測し、7件がseed 1／73で一致します。
利用不能pathのsequenceは、warningに対してERRORを報告し、保持するE.7の転送なしの解釈に対してstorage readを試み、
seed 1で最初に異なります。利用可能pathの比較対象と、実際のHDL deposit／readは一致します。
backendの64 bit packed変数という範囲は、vendor overlay、配列、4値の動作を示しません。
重複するpass数を通常の合計へ加算しません。[HDL設定](testing.ja.md#verilatorのvpi-hdl部分集合)と
[既知差分](known-differences.ja.md)を参照してください。

kirimasimは1074件で`uvm_object_wrapper`未対応を報告し、残る9件はそれより先にライブラリAPI欠落を検出します。
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
[8259f8c](https://github.com/kurochan001/kirimasim-uvm-tests/commit/8259f8c4a8c48a2a904d0c079ca9377a57fa7e9c)
の以前の全1677入力同一性／記録を保持し、2026-11-05 JSTに測定したM1 factory 19 fixture（simulation 18、elaboration 1）を追加します。
simulation 12件はseed 1／73に一致し、virtual uvm_factoryの直接生成はruntimeなしの期待compiler拒否に一致します。
simulation 2件はseed 1で初めて異なり、seed 73は実行しません。未知のobject／component要求はnullを返しますが、必要なERRORを観測しません。登録controlを不正要求より前に生成し、error後のregistry状態を仮定しません。

type_id probeはruntime castを使わず、宣言aliasと必要registryを静的に双方向代入し、getter返却の互換性だけでは判定しません。合法simulation probe 4件はbuildできません。非parameter化abstract object matrixは最初にuvm_transactionのtype_id欠落へ達し、独立report-server probeもtype_idを見つけられません。
subscriberとparameter化sequenceのprobeは、必要な自身の特殊化と非互換な継承基底registryへ解決します。runtimeのない宣言差分であり、不正testの期待拒否ではありません。
独立sequence-base probeは一致し、停止matrixの結果を流用しません。7 category fixtureと分離2 fixtureで固有built-in型14個を選択し、package全型や8.2.2の全8 categoryは検査しません。

print 4 fixtureは固有の登録名と除外を使い、all_typesの0／省略／1／2を検査します。両streamを別々のmarkerで囲み、宣言したruntime regexで和集合を調べるため、出力先や分割を許します。
UT begin／end markerだけではprint内容を証明しません。見出し、空白、report ID、登録順は規定しません。
local predicate検査52個も、空／欠落／禁止内容を拒否し、囲み外の名前を無視します。

一致controlは限定した単一active service view、独自の軽量proxy登録／委譲、要求名／parent、具象default-factory拡張を扱います。
active serviceとしての読み方は、単一instance概要の物理生成に関する字義を解決しません。初期拡張fixtureの予約語変数名は現在の測定前に修正し、古いbuildは除外します。

日英AI案28件と個別に読んだ分類8件を追加し、以前の全2934要求・312分類・1677 fixture入力／native記録を未変更で保持します。
schema、runner／library／catalog、workflow、SVGは未変更です。guest実行、人のレビュー、分母承認、完了は主張しません。

保持するkirimasim／Ghost記録は、固定した実行ファイルとseedごとの非公開profileで取得しました。

商用シミュレータの結果は[投稿方針](faq.ja.md#商用シミュレータとissueの投稿方針)に従って除外します。

以前のkirimasim／Ghostの一時的な実行ファイル／profile snapshotは失われているため、guest再実行は主張しません。
歴史的fileは1085記録を保持します。現在はcommand-enum引用と修正したBoolean rerandomization観測の2入力が異なり、そのstale記録を除外します。
互換な現在の部分集合は1083記録で、kirimasimはunsupported 1074／API欠落fail 9、Ghostは各seedでpass 207／fail 876です。
未測定613入力は追加611件と修正した既存2件です。filterしたfileと`out/thin-fifty-fifth-evidence-scope.json`に明示除外を保持し、許可された一致実行条件の復元を待ちます。

指紋ごとに、識別する入力が異なります。

| 識別子 | 識別する内容 | 使い方 |
| --- | --- | --- |
| `inputs_sha256` | テストsource、期待値file、収集したhelper／data、library lock | 各記録を現在のテスト入力と照合する |
| `runner_sha256` | 選択したrunner、`suite_results.py`、`uvm_common.py` | batch間で一致し、`runner_changed`がfalseであることを確認する |
| `ledger_inputs_sha256` | 正本の範囲、要求、分類、テスト索引、条項catalog | simulationの証拠と別に、生成したinventory／backlogを識別する |

[台帳の識別子](requirements.ja.md#生成レポートの識別)は、生成したレビュー資料のものです。
入力／runnerのhashが一致しても、実行記録を再利用する前にシミュレータ、configuration、libraryの同一性を確認します。

合算する前に、次を確認します。

- Verilator IDが現在の全件を覆い、guest IDは宣言した1083件の部分集合と一致すること。613入力IDは未測定のままにすること。
- 各記録の`inputs_sha256`が、ランナーの集めた現在のソース、期待出力、関連入力、ライブラリのlockと一致すること。
- batch間でシミュレータの版、configuration、`runner_sha256`が一致し、`runner_changed`がfalseであること。
- このスナップショットでは、Verilatorタグ付きの全ケースが`pass`、現在のタグなしケースがすべて`known`であること。
- Ghostの2つのseedで、不一致になるテストの集合が同じであること。

これは現在の入力に対する互換な実行記録の合算であり、全件を単一のコマンドで再実行したという主張ではありません。
追加時の件数と測定、過去のスモーク、build変更の詳細は[開発履歴](history.ja.md)に残します。
更新した記録で以前の記録を置き換える場合も、現在の入力の指紋を先に確認します。

[要求台帳の案](requirements.ja.md)はAI案2962件です。新28義務と個別分類8件で未評価は595番号となります。
第8章は部分60／分類12／未評価0、全体は部分1592／分類320です。正確なtype_id特殊化、print選択、wrapper生成と失敗は条件と差分を保持します。
単一active factoryの解釈と残る全ての部分義務には監査が必要です。

guest fileは互換1083記録をbyte単位で保持し、以前の修正2入力を含む未測定613（simulation 566／elaboration 47）を残します。新guest結果、人のレビュー、分母承認は主張しません。

## 再現と結果の保存

コマンド、profileのmode、ライブラリの設定は[テストと開発のガイド](testing.ja.md#スイートの実行)で説明します。
`--json out/<name>.json`を指定すると、分類、理由、configuration、指紋を保存します。
`out/`はGitの対象外で、Checkはこのローカル記録を公開しません。
入力、ランナー、実行ファイル、profile、ライブラリが異なる結果は、別の実行条件です。

## 継続的インテグレーション

[Check](../.github/workflows/check.yml)は`main`へのpush、pull request、手動実行で動きます。
固定ライブラリの整合性、ツールの単体テスト110件、metadata 1696件、要求台帳の案／テスト索引、通常oracle付きVerilator 1481件（seed 1／73のruntime 1436・実行時seedなしのcompiler拒否45）と、別条件の明示command-line 17件を検査します。
kirimasim、Ghost、specのみのケースは実行しません。READMEのバッジは現在のCIで、このローカル測定とは別の状態です。
Checkが成功しても、UVMの完全な適合性や全シミュレータの成功を示しません。Nightlyや結果の自動公開はありません。
