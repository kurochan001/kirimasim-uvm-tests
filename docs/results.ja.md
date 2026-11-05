# 現在の実行結果と測定方法

[English](results.md) · [README](../README.ja.md) · [既知差分](known-differences.ja.md)

## 現在のスナップショット

runtime一致、compiler拒否、未測定入力は実行条件が異なるため、件数を併せて読む方法は[結果を読む](reading-guide.ja.md#結果を読む)を参照してください。

2026-11-05に集約したVerilator記録は現在の2100件すべてを対象にします。他2系統は未変更1083件の記録で、
1017入力は未測定です。各記録は入力と実行条件を指紋で識別します。
スイートは21 directoryの2100件で、simulation 2012件とelaboration 88件です。
milestoneはM1 887件（812／75）、M2 547件（542／5）、M3 666件（658／8）で、括弧内はruntime／elaborationです。
全件が`spec_check: ai`で、人のレビューは記録していません。DPIなし2071件のうち88件は不正elaboration検査であり、HDL-DPI 11件とcommand-line／regex-DPI runtime 18件は別です。

| シミュレータとライブラリ | 観測結果 | 実行範囲 |
| --- | --- | --- |
| Verilator 5.052・固定版UVM | `pass` 1803件：runtime 1718＋compile拒否85、`known` 297件 | runtime一致はseed 1／73。期待compiler拒否は実行時seedを実行しない |
| Verilator 5.052・独自VPI HDL backend | `pass` 10件、`fail` 1件 | 重複する11件の別条件。一致はseed 1／73、差分はseed 1 |
| Verilator 5.052・独自command-line VPI bridge・固定regex DPI | `pass` 17件、`known` 1件 | 重複する18件の別条件。一致はseed 1／73、差分はseed 1 |
| kirimasim・固定版UVM | `unsupported`が1074件、`fail`が9件 | 未変更1083入力。1017入力は未測定 |
| Ghost・同梱UVM | `pass`が207件、`fail`が876件 | 各seedで未変更1083入力。失敗集合は同じ。1017入力は未測定 |
| Ghost・固定版UVM | 現在の実行ファイルの固定コピーでは未測定 | 現在の固定版modeの結果は示さない |

固定ライブラリはAccellera UVM 2020.3.1、コミット`78c06547a2a0`で、326ファイルを
[lock](../third_party/uvm.lock)と照合します。Ghostの同梱実行は、lockのパッケージではなく供給されたライブラリを使います。
非公開シミュレータの識別情報、版、パス、profileの内容、診断は公開しません。
公開interfaceは[Ghostの設定](testing.ja.md#ghost)で説明します。Icarus VerilogはこのUVMスイートには使いません。

## 結果の解釈

ビルド失敗はシミュレーション開始前の停止、runtime差分はモデル実行中の不一致を表し、それぞれにどのseedの結果があるかは[Q14](faq.ja.md#q14-seedを2つ変えれば決定性や4値の動作も証明できますか)で説明しています。

正当なnegative期待85件は宣言したfixture／type／memberの診断によるcompiler拒否で一致します。
不正design 3件はsubscriberのwriteとvisitorのvisitの欠落、印字virtual builtin dispatcherの直接生成を受理し、拒否oracleを既知差分として保持します。
受理されてもruntimeは実行せず、simulationの予期しないbuild 76件は別です。passには宣言した期待との一致が必要です。

specのみの297件は規格由来の出力またはcompile診断期待を保持し、不正compiler受理3件とsimulation 294件です。
simulationのうち218件はseed 1で最初に異なり、seed 73結果はありません。API／型名欠落build 27件はtime API 1、sequence-library API 6、HDL slice 4、named-concat constructor 1、object active-policy API 5、catcher message-handle 3、印刷されたbase記録状態getter 1、印刷report callback typedef 1、built-in type_id 2、typed resource-DB helper 3です。

time減算build 1件は省略可と印刷されたsecs引数を要求します。
宣言build 2件は既定型の不一致で、別の2件は印刷all_dropped function／taskとclone暗黙scalar／map返却の食違いを保持します。
2件は継承したtype_id registry特殊化の非互換で、1件はmemory backdoor_readのprotected access差分で、2件は記載外pure hookを要求する合法resource-base／記載methodだけの完全core-service拡張です。ほか29件はDPI未linkでHDL 11・command-line 18です。
追加の合法build 3件は字面のenum-collection T解釈を使います。
ほか7 buildは厳密なattribute定義6件と印刷enum-unpackの引数を保持します。
simulation build 76件にはruntime結果がなく、別command-line条件は17一致とquit-warning差分1件を保持します。

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

指紋は再利用する記録の正確な入力を識別するため、変更後に古い一致を使えない理由は[実行と結果](glossary.ja.md#実行と結果)を参照してください。

snapshotは[e8a6d8e](https://github.com/kurochan001/kirimasim-uvm-tests/commit/e8a6d8e1b5a955baed158d3e2bbaaab861a713ef)の以前の通常2056入力／記録をすべて保持し、
recording／scalar macro追加を2026-11-05 JSTに測定します。

新しいM1の44入力は、runtime seed 1／73で33件一致、seed 73結果のないseed 1差分4件、合法入力のbuild差分7件です。
scalarのpack／unpack macroは反対方向に公開scalar APIを使い、7-bit末尾値で値・幅・残量を観測します。
integralの選択幅は1／33／97、enumは17 bit、stringは空／非空、realは負値／0を扱い、raw stream配置は固定しません。

recordingの検査は、実行中のtransaction handleで開いた独自recorder hookを使います。
既定のint／string／time／realとgeneric fieldの経路を、属性対応を有効にした型付きcaptureと分けます。
後者は正確なconst-ref型を使い、4301-bit値、packed struct、dynamic arrayを含みます。
印刷された3引数のattribute定義6件は、固定版macroが未記載の4番目のrecorder引数を渡すためbuild差分になります。
追加引数を許容する別のcontrol 6件は一致しますが、control専用で、元の期待値を保持します。

enum-unpackの印刷された1引数形式はTYPEなしではbuildできず、本文は型の指定を要求します。
別に印刷されたenumN形式は一致し、独自の直接義務とcontrol対応を持ちますが、元の文言は解決しません。
33-bit整数macro 2件は、記述されたfield hookの代わりに整数hookを使います。
直接のrecord_fieldによるcontrolは、既定BINと明示HEXで一致します。
既定attributeの元のstring配送とpeerの選択は、限定した解釈のruntime差分2件を保持します。
TR_HANDLEの本文と0引数accessorは明示的な解釈境界であり、無条件の独立した不具合とは認定しません。

初期のrecorder補助引用と省略radixの観測はIEEEと照合して修正しました。
設定した既定値はhookで解決され得ますが、記述されたfield経路の期待は保持します。
現在のrecorder入力と、補助引用を修正したものを含む最終sourceを再測定し、元の期待値fileはすべて保持します。

recording／scalar macroの監査は日英AI義務41件を追加し、以前の未評価21番号を部分分解します。
分類は追加せず、全397分類を保持します。付録Bは部分102／分類4／未評価38で、義務204件、主引用139テスト（simulation 138／elaboration 1）です。
第16章は義務263件と主引用152テストです。全体は部分1924／分類397／未評価186（構造274／文脈123）です。
collection macro、残るsize／error／lifecycle条件、元のmilestone目標は未完です。

全3686義務に直接テストがあり、直接対応2076テスト、control専用24テスト、control linkあり72テストです。
追加分は直接対応38入力とcontrol専用6入力です。以前の全3645義務、397分類、2056索引入力／通常記録、88 compiler記録は未変更です。
人のレビュー、範囲／分母承認、完全coverageは主張しません。

保持するkirimasim／Ghost記録は、固定した実行ファイルとseedごとの非公開profileで取得しました。

商用シミュレータの結果は[投稿方針](faq.ja.md#商用シミュレータとissueの投稿方針)に従って除外します。

以前のkirimasim／Ghostの一時的な実行ファイル／profile snapshotは失われているため、guest再実行は主張しません。
歴史的fileは1085記録を保持します。現在はcommand-enum引用と修正したBoolean rerandomization観測の2入力が異なり、そのstale記録を除外します。
互換な現在の部分集合は1083記録で、kirimasimはunsupported 1074／API欠落fail 9、Ghostは各seedでpass 207／fail 876です。
未測定1017入力は追加1015件と修正した既存2件です。filterしたfileと`out/thin-sixty-eighth-evidence-scope.json`に明示除外を保持し、許可された一致実行条件の復元を待ちます。

指紋ごとに、識別する入力が異なります。

| 識別子 | 識別する内容 | 使い方 |
| --- | --- | --- |
| `inputs_sha256` | テストsource、期待値file、収集したhelper／data、library lock | 各記録を現在のテスト入力と照合する |
| `runner_sha256` | 選択したrunner、`suite_results.py`、`uvm_common.py` | batch間で一致し、`runner_changed`がfalseであることを確認する |
| `ledger_inputs_sha256` | 正本の範囲、要求、分類、テスト索引、条項catalog | simulationの証拠と別に、生成したinventory／backlogを識別する |

[台帳の識別子](requirements.ja.md#生成レポートの識別)は、生成したレビュー資料のものです。
入力／runnerのhashが一致しても、実行記録を再利用する前にシミュレータ、configuration、libraryの同一性を確認します。

合算する前に、次を確認します。

- Verilator IDが現在の全件を覆い、guest IDは宣言した1083件の部分集合と一致すること。1017入力IDは未測定のままにすること。
- 各記録の`inputs_sha256`が、ランナーの集めた現在のソース、期待出力、関連入力、ライブラリのlockと一致すること。
- batch間でシミュレータの版、configuration、`runner_sha256`が一致し、`runner_changed`がfalseであること。
- このスナップショットでは、Verilatorタグ付きの全ケースが`pass`、現在のタグなしケースがすべて`known`であること。
- Ghostの2つのseedで、不一致になるテストの集合が同じであること。

これは現在の入力に対する互換な実行記録の合算であり、全件を単一のコマンドで再実行したという主張ではありません。
追加時の件数と測定、過去のスモーク、build変更の詳細は[開発履歴](history.ja.md)に残します。
更新した記録で以前の記録を置き換える場合も、現在の入力の指紋を先に確認します。

[要求台帳の案](requirements.ja.md)はAI義務3686件と未評価186番号、部分1924／分類397です。
付録Bは102／4／38で、新しいscalar観測の後もcollectionと追加の適用条件は部分的に残ります。
直接対応2076テスト、他の24テストはcontrol専用です。guest記録は互換1083入力を保持し、修正した元入力2件を含む1017（simulation 929／elaboration 88）は未測定です。
範囲／分母と元の目標は未承認／未完です。

## 再現と結果の保存

JSON出力は選択した実行のローカル記録であり、公開されるCheckバッジとの関係は[Q10](faq.ja.md#q10-nightlyや公開の結果ダッシュボードはどこにありますか)で説明しています。

コマンド、profileのmode、ライブラリの設定は[テストと開発のガイド](testing.ja.md#スイートの実行)で説明します。
`--json out/<name>.json`を指定すると、分類、理由、configuration、指紋を保存します。
`out/`はGitの対象外で、Checkはこのローカル記録を公開しません。
入力、ランナー、実行ファイル、profile、ライブラリが異なる結果は、別の実行条件です。

## 継続的インテグレーション

CI shardは既存テスト集合を期待値を変えずに分割するため、badgeやlocal測定との関係は[Q268. Checkをshardへ分割すると必要なテスト範囲は減りますか？](faq.ja.md#q268-checkをshardへ分割すると必要なテスト範囲は減りますか)を参照してください。

[Check](../.github/workflows/check.yml)は`main`へのpush、pull request、手動実行で動きます。
固定ライブラリの整合性、ツールの単体テスト110件、metadata 2100件、要求台帳の案／テスト索引、通常oracle付きVerilator 1803件（seed 1／73のruntime 1718・実行時seedなしのcompiler拒否85）と、別条件の明示command-line 17件を検査します。
以前の分割前[Check実行](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/41976785278)は、設定された150分のjob上限を超えました。
現在のworkflowは現在のタグ付き1803検査を重複しない8 shard（226／226／226／225／225／225／225／225）へ分け、同時shard jobは最大4です。
和集合の完全一致と重複なしをlocalで検証しました。command-line 17検査はshard 0で通常検査の前に1回だけ実行します。
seed 1／73、compiler拒否85件、固定依存関係、runner指紋は未変更です。従来のverilator gateは全shardの成功を要求します。shard分割は実行の構成であり、local検証でhosted workflowの成功は立証しません。

kirimasim、Ghost、specのみのケースは実行しません。READMEのバッジは現在のCIで、このローカル測定とは別の状態です。
Checkが成功しても、UVMの完全な適合性や全シミュレータの成功を示しません。Nightlyや結果の自動公開はありません。
