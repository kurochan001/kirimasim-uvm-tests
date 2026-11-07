# 現在の実行結果と測定方法

[English](results.md) · [README](../README.ja.md) · [既知差分](known-differences.ja.md)

## 現在のスナップショット

runtime一致、compiler拒否、未測定入力は実行条件が異なるため、件数を併せて読む方法は[結果を読む](reading-guide.ja.md#結果を読む)を参照してください。

2026-11-07に集約したVerilator記録は現在の2685件すべてを対象にします。他2系統は未変更1081件の記録で、
1604入力は未測定です。各記録は入力と実行条件を指紋で識別します。
スイートは22 directoryの2685件で、simulation 2586件とelaboration 99件です。
milestoneはM1 1161件（1080／81）、M2 612件（605／7）、M3 912件（901／11）で、括弧内はruntime／elaborationです。
全件が`spec_check: ai`で、人のレビューは記録していません。DPIなし2629件のうち99件は不正elaboration検査であり、HDL-DPI 38件とcommand-line／regex-DPI runtime 18件は別です。

backendの行は通常条件にも含まれる入力を条件を変えて測定した記録であり、結果を別に数える理由は[実行環境の説明](testing.ja.md#uvmライブラリ)で確認できます。

| シミュレータとライブラリ | 観測結果 | 実行範囲 |
| --- | --- | --- |
| Verilator 5.052・固定版UVM | `pass` 2245件：runtime 2151＋compile拒否94、`known` 440件 | runtime一致はseed 1／73。期待compiler拒否は実行時seedを実行しない |
| Verilator 5.052・独自VPI HDL backend | `pass` 37件、`fail` 1件 | 重複する38件の別条件。一致はseed 1／73、差分はseed 1 |
| Verilator 5.052・独自command-line VPI bridge・固定regex DPI | `pass` 17件、`known` 1件 | 重複する18件の別条件。一致はseed 1／73、差分はseed 1 |
| kirimasim・固定版UVM | `unsupported`が1072件、`fail`が9件 | 未変更1081入力。1604入力は未測定 |
| Ghost・同梱UVM | `pass`が206件、`fail`が875件 | 各seedで未変更1081入力。失敗集合は同じ。1604入力は未測定 |
| Ghost・固定版UVM | 現在の実行ファイルの固定コピーでは未測定 | 現在の固定版modeの結果は示さない |

固定ライブラリはAccellera UVM 2020.3.1、コミット`78c06547a2a0`で、326ファイルを
[lock](../third_party/uvm.lock)と照合します。Ghostの同梱実行は、lockのパッケージではなく供給されたライブラリを使います。
非公開シミュレータの識別情報、版、パス、profileの内容、診断は公開しません。
公開interfaceは[Ghostの設定](testing.ja.md#ghost)で説明します。Icarus VerilogはこのUVMスイートには使いません。

## 結果の解釈

1つのテストに複数の観測がある場合、他の行が一致しても必須の観測に差分があれば全体の成功にはならず、その分類は[判定規則](faq.ja.md#q5-passfailknownunsupportedはどう違いますか)で確認できます。

個別の記録を調べるときは、[差分を調べる](reading-guide.ja.md#差分を調べる)の手順で、結果JSONからソース、期待する観測、runnerの条件を辿れます。

識別子に不慣れな場合は、結果ID、ソースのfile名、UVMクラス、要求IDの関係を[スモークテストの具体例](reading-guide.ja.md#1件のテストをファイルで辿る)で確認できます。

runtimeの出力差分では`reason`が最初に異なる選択行を示すため、指定した期待行の列との比較方法は[観測の規則](testing.ja.md#何を観測するか)で確認してください。

ビルド失敗はシミュレーション開始前の停止、runtime差分はモデル実行中の不一致を表し、それぞれにどのseedの結果があるかは[Q14](faq.ja.md#q14-seedを2つ変えれば決定性や4値の動作も証明できますか)で説明しています。

正当なnegative期待94件は宣言したfixture／type／memberの診断によるcompiler拒否で一致します。
不正design 5件はsubscriberのwrite、visitorのvisit、proxyのget_immediate_children、adapterのacceptの欠落、印字virtual builtin dispatcherの直接生成を受理し、拒否oracleを既知差分として保持します。
受理されてもruntimeは実行せず、simulationの予期しないbuild 135件は別です。passには宣言した期待との一致が必要です。

specのみの440件は規格由来の出力またはcompile診断期待を保持し、不正compiler受理5件とsimulation 435件です。
simulationのうち300件はseed 1で最初に異なり、seed 73結果はありません。API／型名欠落build 43件はtime API 1、sequence-library API 14、HDL slice-view 12、named-concat constructor 1、object active-policy API 5、catcher message-handle 3、印刷されたbase記録状態getter 1、印刷report callback typedef 1、built-in type_id 2、typed resource-DB helper 3です。

time減算build 1件は省略可と印刷されたsecs引数を要求します。
宣言build 2件は既定型の不一致で、別の2件は印刷all_dropped function／taskとclone暗黙scalar／map返却の食違いを保持します。
2件は継承したtype_id registry特殊化の非互換で、1件はmemory backdoor_readのprotected access差分で、2件は記載外pure hookを要求する合法resource-base／記載methodだけの完全core-service拡張です。ほか56件はDPI未linkでHDL 38・command-line 18です。
追加の合法build 3件は字面のenum-collection T解釈を使います。
ほか7 buildは厳密なattribute定義6件と印刷enum-unpackの引数を保持します。
さらに3 buildは独自STRUCTUREの依存visitor既定値を保持します。
限定したvirtual抽象overview基底型の2入力は文言の食違いを保持し、明示class基底のcontrolは別に一致します。
ほか2件は専用poolの印刷返却型を使い、pool／itemの食違いを保持します。
これらのsimulation build 135件にはruntime結果がなく、別command-line条件は17一致とquit-warning差分1件を保持します。

印刷上は具象のuvm_vreg_cbsの合法構築1入力は、固定版のvirtual宣言でabstractとして拒否され、期待を保持してruntimeはありません。

追加の未登録packetのsimulation build 4件は、predictor型名生成に使うfactory返却型で停止し、runtimeの証拠はありません。IEEEの必須登録前提は作りません。

追加のsimulation build 2件は、大きいflag拡張でのenum method未対応とUVM_PACKER_MIN_BITS未定義であり、runtime結果はありません。

共有handler resetではseverity／ID verbosity値が残り、general／ID値とaction／fileは既定へ戻ります。
期待するresetと後続の境界配送は変更せず、runtimeの既知fixtureが1件増えます。以前のseverity override reset差分も保持します。

別VPI条件は38検査系で、37件が両seed一致です。memory 3入力は実array cellの継承task、分割bank、ROM writeとpokeを扱い、wrapperは別の公開read宣言の制限を保持します。
primitive force／release 9入力は実公開8／40-bit reg／wireと即時release/read動作を検査します。

新規の正時間force_time 8入力は期間5／13、期間内のforce保持、満了後のreg／wire状態、後続更新、未使用target／peer分離を観測します。
共通コンパイル既定時間単位で逐次呼出し、満了瞬間の順序、復帰時刻／戻り値、重なる引数の動作は主張しません。
backendと両runnerは未変更です。実register 6入力は16／40-bit whole変数と合法な2変数split referenceで公開backdoor_read、peek、pokeを観測します。現在のHDL 38記録は今回も未変更で保持します。

E.7の利用できないpathのsequenceは、保持するwarning／転送なし期待に対しseed 1でERRORとread試行の差分を保持し、seed 73結果はありません。
一般型／select／array、時間単位の変換／丸め、重なる時間付き呼出し、失敗／中止、4値は未完です。
重複する一致を通常合計へ加えず、[HDLの準備](testing.ja.md#verilatorのvpi-hdl部分集合)と[既知差分](known-differences.ja.md)を参照してください。

kirimasimは1072件で`uvm_object_wrapper`未対応を報告し、残る9件はそれより先にライブラリAPI欠落を検出します。
いずれも、その障害より後のUVM動作を実行できた証拠ではありません。Ghostの同梱版の不一致だけでは、
シミュレータとライブラリのどちらが原因かは決まらず、固定版ライブラリでの結果も示しません。ゲストの付録Eの一致は、
[RO registerのskip](../tests/uE/test_single_register_access_sequence_skips_a_readonly_register.sv)、
[registerのbackdoorなしのskip](../tests/uE/test_single_register_access_sequence_skips_a_register_without_a_backdoor.sv)、
[memoryのbackdoorなしのskip](../tests/uE/test_single_memory_access_sequence_skips_a_memory_without_a_backdoor.sv)の条件だけを対象にします。
frontdoor／backdoorの転送動作の成功は示しません。

`known`・`unsupported`は成功に数えません。コマンドの終了コードだけではスイートの一致件数は分からないため、
[FAQ](faq.ja.md#結果の読み方)の分類と終了規則も確認します。2つのseedでは、決定性や4値の正しさは証明できません。

追加のsimulation build 2件はB.4の方向を限定した型controlで、代入箇所の型不一致とruntimeなしを保持し、必須継承やlibraryだけの原因を主張しない理由は[Q392](faq.ja.md#q392-型関係のcontrolでb4の基底の記述は解決しますか)で説明しています。

## 記録の合算

この節は既存記録を合算してスナップショットの根拠にする条件を説明するもので、初めて手元で測定する場合は[1件を実行するコマンド](faq.ja.md#q3-まず1件だけ動かすにはどうしますか)と[JSONを読む具体例](reading-guide.ja.md#結果jsonを開く)から始められます。

指紋は再利用する記録の正確な入力を識別するため、変更後に古い一致を使えない理由は[実行と結果](glossary.ja.md#実行と結果)を参照してください。

ここでの未測定入力は、以前の版を実行していても現在と互換な記録がない入力を指し、再利用前の確認は[Q15](faq.ja.md#q15-過去の結果を現在も使えるかどう確認しますか)で説明しています。

snapshotは[afd85a8](https://github.com/kurochan001/kirimasim-uvm-tests/commit/afd85a861559eee11f9a39f753e7c3af1ed7fb57)から通常2672記録を保持し、引用を直した元入力1件を再測定し、2026-11-07 JSTにM1 simulation入力12件を追加します。

以下のprofileは記載した条件だけを検査し、別の前提の一致で元の差分を成功へ読み替えない理由と台帳のdirect／controlの役割は[要求対応のガイド](requirements.ja.md#引用要求実行の証拠)で説明しています。

106回目の拡充はM1の保留objection profileを12件追加し、元の引用1件を見直します。
新しいcaseはdrain／callback段階、同じobject／子孫からのraise、保留dropと同数／多い／少ない新件数を組み合わせます。
逐次2roundでgate／leaf／祖先の階層、4件を保持する別のpeer分岐、7件を保持する独立objectionを使います。
選択した待機は印刷されたobjectionまたは登録callbackのtaskに置き、all_dropped実行中の取消しが別条件になる理由は[取消しのFAQ](faq.ja.md#q405-drain中の再raiseから何を追加しましたか)で説明しています。

最終tag付きの新規12入力は全てseed 1／73で一致し、改訂した元の入力も本体と期待2行を保って両seedで一致します。
取り消されたgateの解放後も件数を保持し、最後のdropで新しいcycleを完了します。非負の補正では祖先へのraise量はR-Dで、負の補正では公開totalをoracleにし、DIAG106は各seedでhook 8行を調査専用に記録し、oracleや要求対応を持ちません。
状態の義務と未規定の補正hook詳細の違いは[差分件数のFAQ](faq.ja.md#q406-新しい件数が保留dropより少ない場合は何をassertしますか)で確認できます。

待機するtaskはobjectionのall_droppedと登録all_droppedであり、遅延するcomponent taskではありません。
別に保持した13.1.6.3の印刷function入力はbuildの既知差分を保持し、その食違いは[宣言のFAQ](faq.ja.md#q407-taskのgateでcomponentの印刷function宣言も解決しますか)で説明しています。
private process／counter、callback末尾のkill、正確なdelta順序、並行raise、mode zero全体やobjection protocol全体は推定しません。

net伝播の1義務を追加し、安定した取消し義務の元の全本文と対応を保持して適用範囲を広げます。他の元の要求object 4093件と分類445件は未変更です。
元のreraise検査系のdescription／主引用は、呼び出さないget_drain_timeからdrop_objectionへ修正します。元入力を保管し、他の通常／index 2672記録を保持して改訂入力を新たに測定します。
以前の既知440入力は全て保持し、scope、catalog、runner、backend、workflowは未変更です。

台帳はAI義務4095件、直接対応テスト2629件、control専用56件、control対応156件です。
guestは改訂した元入力を除いて互換1081記録を保持し、現在の1604入力は未測定です。Ghostは各seedでpass 206／fail 875、kirimasimはunsupported 1072／fail 9を保持します。
guestの件数減少は互換性のfilterで新測定や改善ではなく、入力同一性の変更は[引用のFAQ](faq.ja.md#q408-引用の修正でguestの結果が改善したり条項coverageを証明したりしますか)で説明しています。
主引用の棚卸しは0件1173番号、1件771番号、2件以上538番号であり、主引用で独立した検査や義務全体のcoverageを証明しません。
空の3queueで部分2062識別子、適用条件、元のM1〜M4目標を完了にはせず、人の照合と範囲／分母承認は記録していません。

kirimasim／Ghost記録は、固定した実行ファイルとseedごとの非公開profileで取得しました。

商用シミュレータの結果は[投稿方針](faq.ja.md#商用シミュレータとissueの投稿方針)に従って除外します。

以前のkirimasim／Ghostの一時的な実行ファイル／profile snapshotは失われており、guest再実行は主張しません。
歴史的な元fileは1085記録を保持します。以前のfilterでcommand-enum引用、Boolean rerandomization、virtual-field configure引用の3つの修正入力を除外し、今回はreraiseの主引用を直した元入力1件をさらに除きます。
他の互換1081記録は各行をbyte単位で保持します。新規12件と改訂1件によって未測定は1604入力（追加1600件・修正した元入力4件）となります。
保持するGhostは各seedでpass 206／fail 875、kirimasimはunsupported 1072／API欠落fail 9で、件数減少はfilterによるものです。
以前の出典は`out/thin-seventy-first-guest-exclusions.json`、今回の除外は`out/thin-one-hundred-sixth-guest-exclusions.json`、現在の範囲は`out/thin-one-hundred-sixth-evidence-scope.json`に記録します。

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

- Verilator IDが現在の全件を覆い、guest IDは宣言した1081件の部分集合と一致すること。1604入力IDは未測定のままにすること。
- 各記録の`inputs_sha256`が、ランナーの集めた現在のソース、期待出力、関連入力、ライブラリのlockと一致すること。
- batch間でシミュレータの版、configuration、`runner_sha256`が一致し、`runner_changed`がfalseであること。
- このスナップショットでは、Verilatorタグ付きの全ケースが`pass`、現在のタグなしケースがすべて`known`であること。
- Ghostの2つのseedで、不一致になるテストの集合が同じであること。

これは現在の入力に対する互換な実行記録の合算であり、全件を単一のコマンドで再実行したという主張ではありません。
追加時の件数と測定、過去のスモーク、build変更の詳細は[開発履歴](history.ja.md)に残します。
更新した記録で以前の記録を置き換える場合も、現在の入力の指紋を先に確認します。

[要求台帳の案](requirements.ja.md)はAI義務4095件と未評価0番号、部分2062／分類445です。
第10章は87／29／0、第18章は393／63／0で、部分契約と元の目標は未完です。
直接対応2629テスト、他の56テストはcontrol専用です。guestは互換1081入力を保持し、修正した元入力4件を含む1604（simulation 1505／elaboration 99）は未測定です。
範囲と分母は未承認です。

## 再現と結果の保存

同じ`--json`のパスを指定するとそのファイルを上書きするため、[実行コマンド](testing.ja.md#スイートの実行)を使って以前の実行も残す場合は別のファイル名を選びます。

ケースを再実行すると手元の新しい測定が得られ、実行ごとの保存先JSONの指定は[結果を保存するガイド](testing.ja.md#スイートの実行)で確認できます。

1つのJSONに項目がないケースはそのファイルから判定できないため、判定の場所と選択した入力の確認方法は[JSONを読む具体例](reading-guide.ja.md#結果jsonを開く)で説明しています。

一覧の差分を1件だけ調べるときは、記録と同じライブラリ／backend条件を保ち、[1件を実行するコマンド](faq.ja.md#q3-まず1件だけ動かすにはどうしますか)にそのソースのパスを指定します。

JSON出力は選択した実行のローカル記録であり、公開されるCheckバッジとの関係は[Q10](faq.ja.md#q10-nightlyや公開の結果ダッシュボードはどこにありますか)で説明しています。

過去の`out/`ファイルは新規cloneに含まれない場合があるため、[ローカル資料の案内](handoff.ja.md#ファイルとローカル資料)で、再現に使う版管理されたコマンドと任意の測定資料を区別しています。

結果のテストIDは`tests/`より下のパスから`.sv`を除いた形なので、JSONの項目からソースとその期待値ファイルを探すときは[配置の案内](testing.ja.md#ディレクトリ構成)を参照してください。

コマンド、profileのmode、ライブラリの設定は[テストと開発のガイド](testing.ja.md#スイートの実行)で説明します。
`--json out/<name>.json`を指定すると、分類、理由、configuration、指紋を保存します。
`out/`はGitの対象外で、Checkはこのローカル記録を公開しません。
入力、ランナー、実行ファイル、profile、ライブラリが異なる結果は、別の実行条件です。

## 継続的インテグレーション

コミットはリポジトリの版を識別するため、リンク先のworkflow実行を手元のファイルと比べる前に対象コミットを確認し、作業の基点を確かめる方法は[引継ぎ時点の説明](handoff.ja.md#引継ぎ時点と目的)を参照してください。

shardは選んだテストを重複なく分担する単位で、最後のgateは全shardの成功を要求し、検査範囲との関係は[Q268](faq.ja.md#q268-checkをshardへ分割すると必要なテスト範囲は減りますか)で説明しています。

[Check](../.github/workflows/check.yml)は`main`へのpush、pull request、手動実行で動きます。
固定ライブラリの整合性、ツールの単体テスト110件、metadata 2685件、要求台帳の案／テスト索引、通常oracle付きVerilator 2245件（seed 1／73のruntime 2151・実行時seedなしのcompiler拒否94）と、別条件の明示command-line 17件を検査します。
以前の分割前[Check実行](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/41976785278)は、設定された150分のjob上限を超えました。
現在のworkflowは現在のタグ付き2245検査を重複しない8 shard（281／281／281／281／281／280／280／280）へ分け、同時shard jobは最大4です。
和集合の完全一致と重複なしをlocalで検証しました。command-line 17検査はshard 0で通常検査の前に1回だけ実行します。
seed 1／73、compiler拒否の判定規則、固定依存関係、runner指紋は未変更です。従来のverilator gateは全shardの成功を要求します。shard分割は実行の構成であり、local検証でhosted workflowの成功は立証しません。

kirimasim、Ghost、specのみのケースは実行しません。READMEのバッジは現在のCIで、このローカル測定とは別の状態です。
Checkが成功しても、UVMの完全な適合性や全シミュレータの成功を示しません。Nightlyや結果の自動公開はありません。
