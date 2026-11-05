# 現在の実行結果と測定方法

[English](results.md) · [README](../README.ja.md) · [既知差分](known-differences.ja.md)

## 現在のスナップショット

runtime一致、compiler拒否、未測定入力は実行条件が異なるため、件数を併せて読む方法は[結果を読む](reading-guide.ja.md#結果を読む)を参照してください。

2026-11-05に集約したVerilator記録は現在の2133件すべてを対象にします。他2系統は未変更1083件の記録で、
1050入力は未測定です。各記録は入力と実行条件を指紋で識別します。
スイートは21 directoryの2133件で、simulation 2041件とelaboration 92件です。
milestoneはM1 920件（841／79）、M2 547件（542／5）、M3 666件（658／8）で、括弧内はruntime／elaborationです。
全件が`spec_check: ai`で、人のレビューは記録していません。DPIなし2104件のうち92件は不正elaboration検査であり、HDL-DPI 11件とcommand-line／regex-DPI runtime 18件は別です。

| シミュレータとライブラリ | 観測結果 | 実行範囲 |
| --- | --- | --- |
| Verilator 5.052・固定版UVM | `pass` 1831件：runtime 1744＋compile拒否87、`known` 302件 | runtime一致はseed 1／73。期待compiler拒否は実行時seedを実行しない |
| Verilator 5.052・独自VPI HDL backend | `pass` 10件、`fail` 1件 | 重複する11件の別条件。一致はseed 1／73、差分はseed 1 |
| Verilator 5.052・独自command-line VPI bridge・固定regex DPI | `pass` 17件、`known` 1件 | 重複する18件の別条件。一致はseed 1／73、差分はseed 1 |
| kirimasim・固定版UVM | `unsupported`が1074件、`fail`が9件 | 未変更1083入力。1050入力は未測定 |
| Ghost・同梱UVM | `pass`が207件、`fail`が876件 | 各seedで未変更1083入力。失敗集合は同じ。1050入力は未測定 |
| Ghost・固定版UVM | 現在の実行ファイルの固定コピーでは未測定 | 現在の固定版modeの結果は示さない |

固定ライブラリはAccellera UVM 2020.3.1、コミット`78c06547a2a0`で、326ファイルを
[lock](../third_party/uvm.lock)と照合します。Ghostの同梱実行は、lockのパッケージではなく供給されたライブラリを使います。
非公開シミュレータの識別情報、版、パス、profileの内容、診断は公開しません。
公開interfaceは[Ghostの設定](testing.ja.md#ghost)で説明します。Icarus VerilogはこのUVMスイートには使いません。

## 結果の解釈

ビルド失敗はシミュレーション開始前の停止、runtime差分はモデル実行中の不一致を表し、それぞれにどのseedの結果があるかは[Q14](faq.ja.md#q14-seedを2つ変えれば決定性や4値の動作も証明できますか)で説明しています。

正当なnegative期待87件は宣言したfixture／type／memberの診断によるcompiler拒否で一致します。
不正design 5件はsubscriberのwrite、visitorのvisit、proxyのget_immediate_children、adapterのacceptの欠落、印字virtual builtin dispatcherの直接生成を受理し、拒否oracleを既知差分として保持します。
受理されてもruntimeは実行せず、simulationの予期しないbuild 79件は別です。passには宣言した期待との一致が必要です。

specのみの302件は規格由来の出力またはcompile診断期待を保持し、不正compiler受理5件とsimulation 297件です。
simulationのうち218件はseed 1で最初に異なり、seed 73結果はありません。API／型名欠落build 27件はtime API 1、sequence-library API 6、HDL slice 4、named-concat constructor 1、object active-policy API 5、catcher message-handle 3、印刷されたbase記録状態getter 1、印刷report callback typedef 1、built-in type_id 2、typed resource-DB helper 3です。

time減算build 1件は省略可と印刷されたsecs引数を要求します。
宣言build 2件は既定型の不一致で、別の2件は印刷all_dropped function／taskとclone暗黙scalar／map返却の食違いを保持します。
2件は継承したtype_id registry特殊化の非互換で、1件はmemory backdoor_readのprotected access差分で、2件は記載外pure hookを要求する合法resource-base／記載methodだけの完全core-service拡張です。ほか29件はDPI未linkでHDL 11・command-line 18です。
追加の合法build 3件は字面のenum-collection T解釈を使います。
ほか7 buildは厳密なattribute定義6件と印刷enum-unpackの引数を保持します。
さらに3 buildは独自STRUCTUREの依存visitor既定値を保持します。
simulation build 79件にはruntime結果がなく、別command-line条件は17一致とquit-warning差分1件を保持します。

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

snapshotは[19c4d55](https://github.com/kurochan001/kirimasim-uvm-tests/commit/19c4d5513ad8137d0dc1f122c0bb0568adfaf743)の以前の通常2100入力／記録をすべて保持し、
走査の宣言追加を2026-11-05 JSTに測定します。

新しいM1の33入力はsimulation 29件とcompiler検査4件です。
simulation 26件がseed 1／73で一致し、印刷virtual基底2件はruntimeなしで期待どおり拒否されます。
合法なSTRUCTURE単独指定の特殊化3件はbuildできず、pure methodを省略した具象派生型2件は受理されますが、binaryは実行しません。
元の期待出力と診断期待はすべて保持します。

検査は正確な既定／明示のNODE・STRUCTURE型、object／基底handleの同一性、名前を省略／明示したconstructorを扱います。
独自の直接派生wrapperは、対象の引数形式で実際の基底constructorを呼びます。
継承したbegin／end hookで選択した独自状態の保持を確認し、別の独自pure method本体で型付き引数と参照queueのdispatchを観測します。
これらの本体で、未実装の組み込みalgorithmを認定しません。

実際のtop-down・bottom-up・by-level adapterが、供給したproxyで選択した非循環treeを走査します。
所属、規定された親／深さの部分順序、begin／endによる囲みを観測し、兄弟の順序は固定しません。
STRUCTURE単独指定は印刷された依存VISITOR既定値を保持し、VISITORを明示するcontrolは別に一致して独自の直接義務も持ちます。
固定版の宣言3件は期待値の導出後に確認し、規格どおりの依存既定値を記述していました。
componentとnode69のbuild診断から、シミュレータ／ライブラリの原因や独立した不具合3件を認定しません。

get_immediate_children／acceptを省略した入力はcompiler拒否の期待を保持し、合法な完全controlでpassにはせず、不正binaryも実行しません。
印刷adapterの非virtual classとpure acceptは別の解釈境界であり、完全派生型で直接生成の可否を解決しません。
最終tagと順序の補助引用を反映して再測定し、検査本体・helper・期待値は変更しません。

走査の宣言監査は日英AI義務33件を追加し、以前の未評価14番号を部分分解します。
個別に読んだ分類7件は、区切りの見出し4件を構造、overview 3件を文脈として扱い、実際の宣言／method義務へ明示対応します。
付録Fは部分90／分類23／未評価24で、義務207件、主引用122テスト（simulation 89／elaboration 33）です。
F.5の未評価番号はありませんが、部分契約・型既定値の差分・文言の食違いを保持します。
全体は部分1938／分類404／未評価165（構造278／文脈126）で、元の範囲・milestone目標・分母のレビューは未完です。

全3719義務に直接テストがあり、直接対応2109テスト、control専用24テスト、control linkあり79テストです。
新入力はすべて直接義務を持ち、うち7件は明示的な合法controlでもあります。
以前の全3686義務、397分類、2100索引入力／通常記録、以前の88 compiler記録は未変更です。
compiler記録4件を追加して全92件にします。人のレビュー、範囲／分母承認、完全coverageは主張しません。

保持するkirimasim／Ghost記録は、固定した実行ファイルとseedごとの非公開profileで取得しました。

商用シミュレータの結果は[投稿方針](faq.ja.md#商用シミュレータとissueの投稿方針)に従って除外します。

以前のkirimasim／Ghostの一時的な実行ファイル／profile snapshotは失われているため、guest再実行は主張しません。
歴史的fileは1085記録を保持します。現在はcommand-enum引用と修正したBoolean rerandomization観測の2入力が異なり、そのstale記録を除外します。
互換な現在の部分集合は1083記録で、kirimasimはunsupported 1074／API欠落fail 9、Ghostは各seedでpass 207／fail 876です。
未測定1050入力は追加1048件と修正した既存2件です。filterしたfileと`out/thin-sixty-ninth-evidence-scope.json`に明示除外を保持し、許可された一致実行条件の復元を待ちます。

指紋ごとに、識別する入力が異なります。

| 識別子 | 識別する内容 | 使い方 |
| --- | --- | --- |
| `inputs_sha256` | テストsource、期待値file、収集したhelper／data、library lock | 各記録を現在のテスト入力と照合する |
| `runner_sha256` | 選択したrunner、`suite_results.py`、`uvm_common.py` | batch間で一致し、`runner_changed`がfalseであることを確認する |
| `ledger_inputs_sha256` | 正本の範囲、要求、分類、テスト索引、条項catalog | simulationの証拠と別に、生成したinventory／backlogを識別する |

[台帳の識別子](requirements.ja.md#生成レポートの識別)は、生成したレビュー資料のものです。
入力／runnerのhashが一致しても、実行記録を再利用する前にシミュレータ、configuration、libraryの同一性を確認します。

合算する前に、次を確認します。

- Verilator IDが現在の全件を覆い、guest IDは宣言した1083件の部分集合と一致すること。1050入力IDは未測定のままにすること。
- 各記録の`inputs_sha256`が、ランナーの集めた現在のソース、期待出力、関連入力、ライブラリのlockと一致すること。
- batch間でシミュレータの版、configuration、`runner_sha256`が一致し、`runner_changed`がfalseであること。
- このスナップショットでは、Verilatorタグ付きの全ケースが`pass`、現在のタグなしケースがすべて`known`であること。
- Ghostの2つのseedで、不一致になるテストの集合が同じであること。

これは現在の入力に対する互換な実行記録の合算であり、全件を単一のコマンドで再実行したという主張ではありません。
追加時の件数と測定、過去のスモーク、build変更の詳細は[開発履歴](history.ja.md)に残します。
更新した記録で以前の記録を置き換える場合も、現在の入力の指紋を先に確認します。

[要求台帳の案](requirements.ja.md)はAI義務3719件と未評価165番号、部分1938／分類404です。
付録Fは90／23／24で、F.5は未評価番号0でも部分契約を保持します。
直接対応2109テスト、他の24テストはcontrol専用です。guest記録は互換1083入力を保持し、修正した元入力2件を含む1050（simulation 958／elaboration 92）は未測定です。
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
固定ライブラリの整合性、ツールの単体テスト110件、metadata 2133件、要求台帳の案／テスト索引、通常oracle付きVerilator 1831件（seed 1／73のruntime 1744・実行時seedなしのcompiler拒否87）と、別条件の明示command-line 17件を検査します。
以前の分割前[Check実行](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/41976785278)は、設定された150分のjob上限を超えました。
現在のworkflowは現在のタグ付き1831検査を重複しない8 shard（229／229／229／229／229／229／229／228）へ分け、同時shard jobは最大4です。
和集合の完全一致と重複なしをlocalで検証しました。command-line 17検査はshard 0で通常検査の前に1回だけ実行します。
seed 1／73、compiler拒否の判定規則、固定依存関係、runner指紋は未変更です。従来のverilator gateは全shardの成功を要求します。shard分割は実行の構成であり、local検証でhosted workflowの成功は立証しません。

kirimasim、Ghost、specのみのケースは実行しません。READMEのバッジは現在のCIで、このローカル測定とは別の状態です。
Checkが成功しても、UVMの完全な適合性や全シミュレータの成功を示しません。Nightlyや結果の自動公開はありません。
