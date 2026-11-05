# 現在の実行結果と測定方法

[English](results.md) · [README](../README.ja.md) · [既知差分](known-differences.ja.md)

## 現在のスナップショット

2026-11-05に集約したVerilator記録は現在の1972件すべてを対象にします。他2系統は未変更1083件の記録で、
889入力は未測定です。各記録は入力と実行条件を指紋で識別します。
スイートは21 directoryの1972件で、simulation 1884件とelaboration 88件です。
milestoneはM1 843件（768／75）、M2 547件（542／5）、M3 582件（574／8）で、括弧内はruntime／elaborationです。
全件が`spec_check: ai`で、人のレビューは記録していません。DPIなし1943件のうち88件は不正elaboration検査であり、HDL-DPI 11件とcommand-line／regex-DPI runtime 18件は別です。

| シミュレータとライブラリ | 観測結果 | 実行範囲 |
| --- | --- | --- |
| Verilator 5.052・固定版UVM | `pass` 1691件：runtime 1606＋compile拒否85、`known` 281件 | runtime一致はseed 1／73。期待compiler拒否は実行時seedを実行しない |
| Verilator 5.052・独自VPI HDL backend | `pass` 10件、`fail` 1件 | 重複する11件の別条件。一致はseed 1／73、差分はseed 1 |
| Verilator 5.052・独自command-line VPI bridge・固定regex DPI | `pass` 17件、`known` 1件 | 重複する18件の別条件。一致はseed 1／73、差分はseed 1 |
| kirimasim・固定版UVM | `unsupported`が1074件、`fail`が9件 | 未変更1083入力。889入力は未測定 |
| Ghost・同梱UVM | `pass`が207件、`fail`が876件 | 各seedで未変更1083入力。失敗集合は同じ。889入力は未測定 |
| Ghost・固定版UVM | 現在の実行ファイルの固定コピーでは未測定 | 現在の固定版modeの結果は示さない |

固定ライブラリはAccellera UVM 2020.3.1、コミット`78c06547a2a0`で、326ファイルを
[lock](../third_party/uvm.lock)と照合します。Ghostの同梱実行は、lockのパッケージではなく供給されたライブラリを使います。
非公開シミュレータの識別情報、版、パス、profileの内容、診断は公開しません。
公開interfaceは[Ghostの設定](testing.ja.md#ghost)で説明します。Icarus VerilogはこのUVMスイートには使いません。

## 結果の解釈

正当なnegative期待85件は宣言したfixture／type／memberの診断によるcompiler拒否で一致します。
不正design 3件はsubscriberのwriteとvisitorのvisitの欠落、印字virtual builtin dispatcherの直接生成を受理し、拒否oracleを既知差分として保持します。
受理されてもruntimeは実行せず、simulationの予期しないbuild 69件は別です。passには宣言した期待との一致が必要です。

specのみの281件は規格由来の出力またはcompile診断期待を保持し、不正compiler受理3件とsimulation 278件です。
simulationのうち209件はseed 1で最初に異なり、seed 73結果はありません。API／型名欠落build 27件はtime API 1、sequence-library API 6、HDL slice 4、named-concat constructor 1、object active-policy API 5、catcher message-handle 3、印刷されたbase記録状態getter 1、印刷report callback typedef 1、built-in type_id 2、typed resource-DB helper 3です。

time減算build 1件は省略可と印刷されたsecs引数を要求します。
宣言build 2件は既定型の不一致で、別の2件は印刷all_dropped function／taskとclone暗黙scalar／map返却の食違いを保持します。
2件は継承したtype_id registry特殊化の非互換で、1件はmemory backdoor_readのprotected access差分で、2件は記載外pure hookを要求する合法resource-base／記載methodだけの完全core-service拡張です。ほか29件はDPI未linkでHDL 11・command-line 18です。
追加の合法build 3件は字面のenum-collection T解釈を使います。
simulation build 69件にはruntime結果がなく、別command-line条件は17一致とquit-warning差分1件を保持します。

共有handler resetではseverity／ID verbosity値が残り、general／ID値とaction／fileは既定へ戻ります。
期待するresetと後続の境界配送は変更せず、runtimeの既知fixtureが1件増えます。以前のseverity override reset差分も保持します。

別のVPI条件はHDL fixture 11件で、10件がseed 1／73に一致します。memory 3 fixtureは実公開array cellへaccessし、継承基底taskのread／write、
8／16-bit分割bankによる24-bit word、ROM writeとpoke／read／peekの違いを検査します。未変更の独自backendで選択dataとneighbor cellを確認します。
派生wrapperは継承実装へ到達しますが、別途停止している公開read宣言を認定しません。

利用不能pathのsequenceは、warningに対してERRORを報告し、保持するE.7の転送なしの解釈に対してreadを試み、seed 1で最初に異なるままです。
以前のHDL 8入力同一性／記録は未変更で保持します。64 bitまでの選択packed cellとこれらのtwo-state array検査で、一般array／type、vendor overlay、force／release、four-state supportを示しません。
重複するpass数を通常合計へ加算しません。[HDL設定](testing.ja.md#verilatorのvpi-hdl部分集合)と[既知差分](known-differences.ja.md)を参照してください。

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

snapshotは[80a8bdf](https://github.com/kurochan001/kirimasim-uvm-tests/commit/80a8bdf631334668107f42328acd6af395d69fe7)の以前の通常1930入力／記録をすべて保持し、
field-macro追加を2026-11-05 JSTに測定します。

M1の42入力を追加し、両seed runtime一致37件と期待compiler拒否1件を得ました。
差分4件は合法simulation build 3件とseed 73結果のないseed 1 runtime 1件です。
別索引の対照4件は一致してもcontrol linkだけを持ち、元の前提を置換しません。

型別field probe 33個はscalar、静的／動的array、queue、string／integral keyの連想propertyを扱います。
選択copyと正／負比較は72-bit data、signed／unsigned／high／wide key、collection size、古いentryの除去、未登録peerの分離を確認します。
object値の6形状はDEEPを明示し、copy後の別handleとtarget変更後のsource状態を保持します。
user copy／compare hookでfield automationを置換せず、走査順も規定しません。

enum collection probeは印刷T本文が記述するcollection typedefを字面どおり使い、静的／動的／queueのbuildが失敗します。
別のcontrol 3件はcollection storageを保ったまま要素enum型を渡して一致します。
これは明示した解釈境界であり、library不具合数の証明や文言の解決ではありません。元の期待値は未変更です。

NOCOPY／NOCOMPAREの優先順位と、省略／DEFAULT／ALL_ONのcopy／compare観測は一致します。
PACKだけではpaired-unpack期待に失敗し、別のcontrolでUNPACKを明示追加すると一致します。
互換roundtripとtarget sentinelの結果で、全ての独立した片方向packing義務やstream配置は証明しません。
手動field-utilsのcreate／型名／clone観測は自動factory登録なしで一致します。const ARG禁止は宣言診断で拒否されruntime seedを実行しません。
最終tag入力を再測定し、以前の全source／evidence記録を保持します。

field-macro監査は日英AI義務125件を追加し、番号の新分類は行いません。以前の未評価45番号（Bの41件とFの4件）を部分分解します。
附属書Bは部分81／分類4／未評価59、案164件、主引用96テスト（simulation 95／elaboration 1）です。
附属書Fは76／16／45で案174件、全体は部分1876／分類390／未評価241（構造268／文脈122）です。元の目標はすべて未完です。

全3506義務に直接テストがあり、直接対応1954テスト、control専用18テスト、control linkあり61テストです。
新enum型／明示UNPACK controlで元の前提をpassにしません。同じ観測を共有するcopyと比較義務は独立テスト数ではありません。
以前の全3381義務、390分類、1930索引入力／通常記録、87 compiler記録は未変更で、compiler集合は現在88入力です。
範囲／分母承認、人のレビュー、完了は主張しません。

保持するkirimasim／Ghost記録は、固定した実行ファイルとseedごとの非公開profileで取得しました。

商用シミュレータの結果は[投稿方針](faq.ja.md#商用シミュレータとissueの投稿方針)に従って除外します。

以前のkirimasim／Ghostの一時的な実行ファイル／profile snapshotは失われているため、guest再実行は主張しません。
歴史的fileは1085記録を保持します。現在はcommand-enum引用と修正したBoolean rerandomization観測の2入力が異なり、そのstale記録を除外します。
互換な現在の部分集合は1083記録で、kirimasimはunsupported 1074／API欠落fail 9、Ghostは各seedでpass 207／fail 876です。
未測定889入力は追加887件と修正した既存2件です。filterしたfileと`out/thin-sixty-fifth-evidence-scope.json`に明示除外を保持し、許可された一致実行条件の復元を待ちます。

指紋ごとに、識別する入力が異なります。

| 識別子 | 識別する内容 | 使い方 |
| --- | --- | --- |
| `inputs_sha256` | テストsource、期待値file、収集したhelper／data、library lock | 各記録を現在のテスト入力と照合する |
| `runner_sha256` | 選択したrunner、`suite_results.py`、`uvm_common.py` | batch間で一致し、`runner_changed`がfalseであることを確認する |
| `ledger_inputs_sha256` | 正本の範囲、要求、分類、テスト索引、条項catalog | simulationの証拠と別に、生成したinventory／backlogを識別する |

[台帳の識別子](requirements.ja.md#生成レポートの識別)は、生成したレビュー資料のものです。
入力／runnerのhashが一致しても、実行記録を再利用する前にシミュレータ、configuration、libraryの同一性を確認します。

合算する前に、次を確認します。

- Verilator IDが現在の全件を覆い、guest IDは宣言した1083件の部分集合と一致すること。889入力IDは未測定のままにすること。
- 各記録の`inputs_sha256`が、ランナーの集めた現在のソース、期待出力、関連入力、ライブラリのlockと一致すること。
- batch間でシミュレータの版、configuration、`runner_sha256`が一致し、`runner_changed`がfalseであること。
- このスナップショットでは、Verilatorタグ付きの全ケースが`pass`、現在のタグなしケースがすべて`known`であること。
- Ghostの2つのseedで、不一致になるテストの集合が同じであること。

これは現在の入力に対する互換な実行記録の合算であり、全件を単一のコマンドで再実行したという主張ではありません。
追加時の件数と測定、過去のスモーク、build変更の詳細は[開発履歴](history.ja.md)に残します。
更新した記録で以前の記録を置き換える場合も、現在の入力の指紋を先に確認します。

[要求台帳の案](requirements.ja.md)はAI義務3506件と未評価241番号、部分1876／分類390です。
附属書BとFは81／4／59と76／16／45で、macro／facility条件は部分的に残ります。直接対応1954テスト、他の18テストはcontrol専用です。
guest記録は互換1083入力を保持し、修正した元入力2件を含む889（simulation 801／elaboration 88）は未測定です。
範囲／分母と元の目標は未承認／未完です。

## 再現と結果の保存

コマンド、profileのmode、ライブラリの設定は[テストと開発のガイド](testing.ja.md#スイートの実行)で説明します。
`--json out/<name>.json`を指定すると、分類、理由、configuration、指紋を保存します。
`out/`はGitの対象外で、Checkはこのローカル記録を公開しません。
入力、ランナー、実行ファイル、profile、ライブラリが異なる結果は、別の実行条件です。

## 継続的インテグレーション

[Check](../.github/workflows/check.yml)は`main`へのpush、pull request、手動実行で動きます。
固定ライブラリの整合性、ツールの単体テスト110件、metadata 1972件、要求台帳の案／テスト索引、通常oracle付きVerilator 1691件（seed 1／73のruntime 1606・実行時seedなしのcompiler拒否85）と、別条件の明示command-line 17件を検査します。
kirimasim、Ghost、specのみのケースは実行しません。READMEのバッジは現在のCIで、このローカル測定とは別の状態です。
Checkが成功しても、UVMの完全な適合性や全シミュレータの成功を示しません。Nightlyや結果の自動公開はありません。
