# 現在の実行結果と測定方法

[English](results.md) · [README](../README.ja.md) · [既知差分](known-differences.ja.md)

## 現在のスナップショット

runtime一致、compiler拒否、未測定入力は実行条件が異なるため、件数を併せて読む方法は[結果を読む](reading-guide.ja.md#結果を読む)を参照してください。

2026-11-06に集約したVerilator記録は現在の2283件すべてを対象にします。他2系統は未変更1082件の記録で、
1201入力は未測定です。各記録は入力と実行条件を指紋で識別します。
スイートは21 directoryの2283件で、simulation 2191件とelaboration 92件です。
milestoneはM1 982件（903／79）、M2 547件（542／5）、M3 754件（746／8）で、括弧内はruntime／elaborationです。
全件が`spec_check: ai`で、人のレビューは記録していません。DPIなし2245件のうち92件は不正elaboration検査であり、HDL-DPI 20件とcommand-line／regex-DPI runtime 18件は別です。

backendの行は通常条件にも含まれる入力を条件を変えて測定した記録であり、結果を別に数える理由は[実行環境の説明](testing.ja.md#uvmライブラリ)で確認できます。

| シミュレータとライブラリ | 観測結果 | 実行範囲 |
| --- | --- | --- |
| Verilator 5.052・固定版UVM | `pass` 1944件：runtime 1857＋compile拒否87、`known` 339件 | runtime一致はseed 1／73。期待compiler拒否は実行時seedを実行しない |
| Verilator 5.052・独自VPI HDL backend | `pass` 19件、`fail` 1件 | 重複する20件の別条件。一致はseed 1／73、差分はseed 1 |
| Verilator 5.052・独自command-line VPI bridge・固定regex DPI | `pass` 17件、`known` 1件 | 重複する18件の別条件。一致はseed 1／73、差分はseed 1 |
| kirimasim・固定版UVM | `unsupported`が1073件、`fail`が9件 | 未変更1082入力。1201入力は未測定 |
| Ghost・同梱UVM | `pass`が206件、`fail`が876件 | 各seedで未変更1082入力。失敗集合は同じ。1201入力は未測定 |
| Ghost・固定版UVM | 現在の実行ファイルの固定コピーでは未測定 | 現在の固定版modeの結果は示さない |

固定ライブラリはAccellera UVM 2020.3.1、コミット`78c06547a2a0`で、326ファイルを
[lock](../third_party/uvm.lock)と照合します。Ghostの同梱実行は、lockのパッケージではなく供給されたライブラリを使います。
非公開シミュレータの識別情報、版、パス、profileの内容、診断は公開しません。
公開interfaceは[Ghostの設定](testing.ja.md#ghost)で説明します。Icarus VerilogはこのUVMスイートには使いません。

## 結果の解釈

1つのテストに複数の観測がある場合、他の行が一致しても必須の観測に差分があれば全体の成功にはならず、その分類は[判定規則](faq.ja.md#q5-passfailknownunsupportedはどう違いますか)で確認できます。

ビルド失敗はシミュレーション開始前の停止、runtime差分はモデル実行中の不一致を表し、それぞれにどのseedの結果があるかは[Q14](faq.ja.md#q14-seedを2つ変えれば決定性や4値の動作も証明できますか)で説明しています。

正当なnegative期待87件は宣言したfixture／type／memberの診断によるcompiler拒否で一致します。
不正design 5件はsubscriberのwrite、visitorのvisit、proxyのget_immediate_children、adapterのacceptの欠落、印字virtual builtin dispatcherの直接生成を受理し、拒否oracleを既知差分として保持します。
受理されてもruntimeは実行せず、simulationの予期しないbuild 92件は別です。passには宣言した期待との一致が必要です。

specのみの339件は規格由来の出力またはcompile診断期待を保持し、不正compiler受理5件とsimulation 334件です。
simulationのうち242件はseed 1で最初に異なり、seed 73結果はありません。API／型名欠落build 27件はtime API 1、sequence-library API 6、HDL slice 4、named-concat constructor 1、object active-policy API 5、catcher message-handle 3、印刷されたbase記録状態getter 1、印刷report callback typedef 1、built-in type_id 2、typed resource-DB helper 3です。

time減算build 1件は省略可と印刷されたsecs引数を要求します。
宣言build 2件は既定型の不一致で、別の2件は印刷all_dropped function／taskとclone暗黙scalar／map返却の食違いを保持します。
2件は継承したtype_id registry特殊化の非互換で、1件はmemory backdoor_readのprotected access差分で、2件は記載外pure hookを要求する合法resource-base／記載methodだけの完全core-service拡張です。ほか38件はDPI未linkでHDL 20・command-line 18です。
追加の合法build 3件は字面のenum-collection T解釈を使います。
ほか7 buildは厳密なattribute定義6件と印刷enum-unpackの引数を保持します。
さらに3 buildは独自STRUCTUREの依存visitor既定値を保持します。
限定したvirtual抽象overview基底型の2入力は文言の食違いを保持し、明示class基底のcontrolは別に一致します。
ほか2件は専用poolの印刷返却型を使い、pool／itemの食違いを保持します。
これらのsimulation build 92件にはruntime結果がなく、別command-line条件は17一致とquit-warning差分1件を保持します。

共有handler resetではseverity／ID verbosity値が残り、general／ID値とaction／fileは既定へ戻ります。
期待するresetと後続の境界配送は変更せず、runtimeの既知fixtureが1件増えます。以前のseverity override reset差分も保持します。

別VPI条件はHDL 20検査系で、19件がseed 1／73に一致します。
実公開array cellのmemory 3検査系は、継承基底taskのread／write、24-bit wordを構成する8／16-bit分割bank、ROM writeとpoke／read／peekを扱います。
独自wrapperは継承するprotected-read実装へ到達しますが、別に保持する公開read宣言の差分をpassにはしません。

force／release 9入力は、実公開forceableの8／40-bit regとwire、即時release/read値、後続の代入／driver更新、存在しない／未instrument targetの失敗controlを追加します。
既存11件のsource／oracleは同じですが、宣言backendとHDL runnerの同一性が変わり、全20通常／HDL入力を新たに測定します。

利用できないpathのsequenceは、保持するE.7の転送なし解釈のもとでwarningではなくERRORを報告しreadを試み、最初のseed 1差分を保持します。
一般array／select／型、正時間force_time、vendor overlay、four-state動作は未完です。
重複する一致を通常合計へ加えず、[HDLの準備](testing.ja.md#verilatorのvpi-hdl部分集合)と[既知差分](known-differences.ja.md)を参照してください。

kirimasimは1073件で`uvm_object_wrapper`未対応を報告し、残る9件はそれより先にライブラリAPI欠落を検出します。
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

ここでの未測定入力は、以前の版を実行していても現在と互換な記録がない入力を指し、再利用前の確認は[Q15](faq.ja.md#q15-過去の結果を現在も使えるかどう確認しますか)で説明しています。

snapshotは[27159dc](https://github.com/kurochan001/kirimasim-uvm-tests/commit/27159dc60e2bf932a2a17faebe843d01fa4b3f80)を基に、影響しない通常2263記録を保持し、2026-11-06 JSTに既存11入力を再測定、新規simulation 9件を追加します。

以下のcontrol入力は意図的に別の前提を使うため、その一致で元の入力の差分は解消せず、direct／controlの区別は[要求対応のガイド](requirements.ja.md#引用要求実行の証拠)で説明しています。

新規HDL force／release 9検査系は、別のVPI条件でseed 1／73に一致します。
公開forceableの8／40-bit regとwireへforceし、反対の手続き代入／driver更新、通常release、即時release/readを観測します。
regは新しい手続き代入まで値を保持し、連続駆動wireは即時にdriverの解決値を返します。
独立した未force peerと存在しない／未instrument pathで、有効呼出しと宣言したbackend失敗を区別します。
独自backendは標準VPI force／release flagと文書化された公開capability markerを使い、path／valueの模擬やsimulator sourceの複製はありません。

宣言したbackendの変更で、sourceと期待値が同じ既存11入力も指紋が変わります。
11件の対応を再照合し、全20通常／HDL入力を新たに測定します。別HDL条件は19件が両seed一致、
保持するE.7 warning／転送なしの差分1件はseed 1で、seed 73の結果はありません。
通常20入力はDPIのlinkに失敗してspec-onlyのbuild knownを保持し、backendの一致を通常runnerのpassにはしません。

新規日英AI義務7件で19.6.2.3／.5／.6を部分分解します。zero-time force_timeの以前の2義務は、
制限の歴史的な記述を保持して現在backend／runnerの同一性更新を追記し、source／oracleとdepositだけの前提は未変更です。
他の以前の3821義務、全406分類、範囲案は未変更です。全体は部分1967／分類406／未評価134です。
第19章は86／24／1、義務196件、主引用149検査系（simulation 144／elaboration 5）で、predictor check_phaseは未評価です。
正時間force_time、広いHDL型、全ての部分義務は未完です。

全3830義務が2259テストへ直接対応し、他の24テストはcontrol専用、control linkあり103テストです。
影響しない通常2263記録、compiler全92記録、command-line 18記録、互換guest 1082記録を保持します。
新しいguest実行／filterはありません。範囲、分母、人のレビュー、元のM1〜M4目標は未承認／未完です。

kirimasim／Ghost記録は、固定した実行ファイルとseedごとの非公開profileで取得しました。

商用シミュレータの結果は[投稿方針](faq.ja.md#商用シミュレータとissueの投稿方針)に従って除外します。

以前のkirimasim／Ghostの一時的な実行ファイル／profile snapshotは失われており、guest再実行は主張しません。
歴史的な元fileは1085記録を保持し、以前のfilterでcommand-enum引用、Boolean rerandomization、virtual-field configure引用の修正した元入力3件を除外します。
今回は同じ互換1082記録をbyte単位で保持し、未測定入力9件を追加します。
Ghostは各seedでpass 206／fail 876、kirimasimはunsupported 1073／API欠落fail 9のままです。
未測定1201入力は追加1198件と修正した元入力3件で、guestの改善／回帰を実測したものではありません。
以前のfilterの出典は`out/thin-seventy-first-guest-exclusions.json`、現在の入力範囲は`out/thin-seventy-seventh-evidence-scope.json`にあります。

指紋ごとに、識別する入力が異なります。

SHA-256は記録した内容から計算する識別値であり、1つの識別値の一致だけでは実行条件の同一性を示さない理由は[指紋の用語説明](glossary.ja.md#実行と結果)で確認できます。

要求文だけの編集では棚卸しを再生成し、テストのヘッダーの編集ではテスト入力の指紋が変わり互換な実行の証拠が必要になるため、両方の手順は[更新方法](requirements.ja.md#テストや対応付けの更新)を参照してください。

| 識別子 | 識別する内容 | 使い方 |
| --- | --- | --- |
| `inputs_sha256` | テストsource、期待値file、収集したhelper／data、library lock | 各記録を現在のテスト入力と照合する |
| `runner_sha256` | 選択したrunner、`suite_results.py`、`uvm_common.py` | batch間で一致し、`runner_changed`がfalseであることを確認する |
| `ledger_inputs_sha256` | 正本の範囲、要求、分類、テスト索引、条項catalog | simulationの証拠と別に、生成したinventory／backlogを識別する |

[台帳の識別子](requirements.ja.md#生成レポートの識別)は、生成したレビュー資料のものです。
入力／runnerのhashが一致しても、実行記録を再利用する前にシミュレータ、configuration、libraryの同一性を確認します。

合算する前に、次を確認します。

- Verilator IDが現在の全件を覆い、guest IDは宣言した1082件の部分集合と一致すること。1201入力IDは未測定のままにすること。
- 各記録の`inputs_sha256`が、ランナーの集めた現在のソース、期待出力、関連入力、ライブラリのlockと一致すること。
- batch間でシミュレータの版、configuration、`runner_sha256`が一致し、`runner_changed`がfalseであること。
- このスナップショットでは、Verilatorタグ付きの全ケースが`pass`、現在のタグなしケースがすべて`known`であること。
- Ghostの2つのseedで、不一致になるテストの集合が同じであること。

これは現在の入力に対する互換な実行記録の合算であり、全件を単一のコマンドで再実行したという主張ではありません。
追加時の件数と測定、過去のスモーク、build変更の詳細は[開発履歴](history.ja.md)に残します。
更新した記録で以前の記録を置き換える場合も、現在の入力の指紋を先に確認します。

[要求台帳の案](requirements.ja.md)はAI義務3830件と未評価134番号、部分1967／分類406です。
第10章は87／29／0、第18章は360／51／45で、部分契約と元の目標は未完です。
直接対応2259テスト、他の24テストはcontrol専用です。guestは互換1082入力を保持し、修正した元入力3件を含む1201（simulation 1109／elaboration 92）は未測定です。
範囲と分母は未承認です。

## 再現と結果の保存

一覧の差分を1件だけ調べるときは、記録と同じライブラリ／backend条件を保ち、[1件を実行するコマンド](faq.ja.md#q3-まず1件だけ動かすにはどうしますか)にそのソースのパスを指定します。

JSON出力は選択した実行のローカル記録であり、公開されるCheckバッジとの関係は[Q10](faq.ja.md#q10-nightlyや公開の結果ダッシュボードはどこにありますか)で説明しています。

過去の`out/`ファイルは新規cloneに含まれない場合があるため、[ローカル資料の案内](handoff.ja.md#ファイルとローカル資料)で、再現に使う版管理されたコマンドと任意の測定資料を区別しています。

コマンド、profileのmode、ライブラリの設定は[テストと開発のガイド](testing.ja.md#スイートの実行)で説明します。
`--json out/<name>.json`を指定すると、分類、理由、configuration、指紋を保存します。
`out/`はGitの対象外で、Checkはこのローカル記録を公開しません。
入力、ランナー、実行ファイル、profile、ライブラリが異なる結果は、別の実行条件です。

## 継続的インテグレーション

CI shardは既存テスト集合を期待値を変えずに分割するため、badgeやlocal測定との関係は[Q268. Checkをshardへ分割すると必要なテスト範囲は減りますか？](faq.ja.md#q268-checkをshardへ分割すると必要なテスト範囲は減りますか)を参照してください。

[Check](../.github/workflows/check.yml)は`main`へのpush、pull request、手動実行で動きます。
固定ライブラリの整合性、ツールの単体テスト110件、metadata 2283件、要求台帳の案／テスト索引、通常oracle付きVerilator 1944件（seed 1／73のruntime 1857・実行時seedなしのcompiler拒否87）と、別条件の明示command-line 17件を検査します。
以前の分割前[Check実行](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/41976785278)は、設定された150分のjob上限を超えました。
現在のworkflowは現在のタグ付き1944検査を重複しない8 shard（243／243／243／243／243／243／243／243）へ分け、同時shard jobは最大4です。
和集合の完全一致と重複なしをlocalで検証しました。command-line 17検査はshard 0で通常検査の前に1回だけ実行します。
seed 1／73、compiler拒否の判定規則、固定依存関係、runner指紋は未変更です。従来のverilator gateは全shardの成功を要求します。shard分割は実行の構成であり、local検証でhosted workflowの成功は立証しません。

kirimasim、Ghost、specのみのケースは実行しません。READMEのバッジは現在のCIで、このローカル測定とは別の状態です。
Checkが成功しても、UVMの完全な適合性や全シミュレータの成功を示しません。Nightlyや結果の自動公開はありません。
