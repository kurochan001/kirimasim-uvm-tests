# 開発ハンドオフ

[English](handoff.md) · [README](../README.ja.md) · [要求台帳](requirements.ja.md)

このページは開発の再開を支える資料なので、最初のテストを動かしたり理解したりしたい場合は[読み方ガイド](reading-guide.ja.md)から始めてください。

## 引継ぎ時点と目的

2026-11-06に、`main`の[4d60d44](https://github.com/kurochan001/kirimasim-uvm-tests/commit/4d60d443709903d46587fdb46fbf15e6a7186342)
を基に、薄い領域の82回目の拡充へ更新しました。再開時に最新の公開commitと作業ツリーを確認してください。

IEEE 1800.2-2020のUVM適合を検査し、kirimasimを対象とするプロジェクトです。
SystemVerilog言語だけのreproducerは、
[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests)で扱います。
M1〜M4の薄い領域を引き続き補強します。M4は進行中で、未対応テスト0件は、どの段階の完了も意味しません。

| 領域 | 現在の状態 |
| --- | --- |
| M1 | 1000件（runtime 921・elaboration 79）：core object、policy、reporting、階層、factory、phase、同期、recording、utility |
| M2 | 563件（runtime 556・elaboration 7）：sequence、sequencer、callback、TLM |
| M3 | 796件（runtime 786・elaboration 10）：register／memory layer、付録E |
| 全体 | 章・付録21 directoryに2359件（simulation 2263・elaboration 96）。照合はすべてAIで、人による照合は未記録 |
| M4 | AI要求案3887件。3887要求を2327テストへ直接対応。control専用32テスト。未対応テスト0件 |
| 規範的棚卸し | 2,507識別子のうち1986件を一部分解、409件を明示的に分類。112件は未評価。直接テストのない要求案0件 |

`scope_status`は提案、`normative_inventory_complete`はfalse、
`approved_denominator`／`coverage_percentage`はnullです。主引用テストがある21 rootすべてで未対応テスト0件ですが、
規範的な分解と人のレビューは未完です。

## 維持する方針

Ghostの設定が必要なのは非公開guestの測定を行う場合で、その設定を使わずに始めるときは[通常のrunnerのコマンド](testing.ja.md#スイートの実行)を参照してください。

- 最初に現在のworkspaceの指示を読みます。このsessionでユーザーが指定したagent向けの指示は
  `RTK.md`を参照しているため、現在の環境で解決してから続けます。
- 期待値は、ユーザーが配置したIEEE規格から定めます。独自の検査系と日英の言い換えを使い、規格の本文・図・例を
  コピーしません。固定Apache-2.0 UVMのsourceは差分の説明に使えますが、oracleは規格に基づきます。
  [出典](provenance.ja.md)を参照してください。
- GPL／LGPLシミュレータの実装sourceは読みません。許可された実行ファイルの実行とテスト出力の確認は可能です。
- 商用シミュレータの結果・出力・診断は、第三者経由や匿名化を含めて利用しません。
  [投稿方針](faq.ja.md#商用シミュレータとissueの投稿方針)と[Issueフォーム](../.github/ISSUE_TEMPLATE/report.yml)に従います。
- Ghostは公開aliasで扱う、許可された非公開guestです。実際の識別情報、版、実行ファイル／profileのパス、
  profile内容、生の診断を公開しません。許可されたlocal設定は別途確保し、版管理する資料には記載しません。
- 全ガイドを完全な日英両対応にします。READMEは現状、追加作業の経緯は[履歴](history.ja.md)へ記載します。
  実際の人による照合までは、`spec_check: ai`と要求のAI照合状態を維持します。
- 不一致時は、検査系と引用条項を先に見直します。検査系の誤りは修正し、有効な規範的期待はspec-onlyとして残して
  差分を記録します。観測出力をコピーして一致させません。

## ファイルとローカル資料

正本はGitで版管理して維持する入力、生成レポートはその入力を集計した資料であり、レビューや更新の対象となるファイルは[版管理するデータと生成する棚卸し](requirements.ja.md#版管理するデータと生成する棚卸し)で説明しています。

- [テストガイド](testing.ja.md)：metadata、コンパイル、runner option、変更時の方針。
  [実行結果](results.ja.md)：evidenceの解釈と集約方法。
  [既知差分](known-differences.ja.md)：spec-only全366件。
- [要求ガイド](requirements.ja.md)、[範囲](../coverage/scope.json)、[台帳](../coverage/requirements.json)、[分類](../coverage/assessments.json)、
  [テスト索引](../coverage/test_index.json)：M4の正規の状態です。生成inventoryはレビューの補助資料で、
  版管理する入力の代わりではありません。
- [library lock](../third_party/uvm.lock)：Accellera UVM 2020.3.1、`78c06547a2a0`、326ファイル。
  版管理するtoolで取得し、library本体はコミットしません。2307検査系は`UVM_NO_DPI`を使い、34件は独自VPI HDL backendを明示要求します。
- ユーザーがrepository rootへ`IEEE_Std_1800.2-2020.pdf`と
  `IEEE_Std_1800-2023_SystemVerilog.pdf`を配置済みです。Git対象外のlocalファイルで、
  新規cloneにはなく、再配布しません。`out/`内の抽出済みtextはlocalでGit対象外です。`/tmp`は消える場合があります。
- `out/`の結果はGit対象外のlocal資料です。`out/thin-eighty-second-*.py`の一時helperは、
  あれば使える補助で、保守対象の入口ではありません。台帳／履歴へ追記するものがあり、無条件に再実行しません。
  不在なら版管理するtoolから必要な処理を組み立てます。

## 再開と基本確認

作業ツリーに変更がある場合は未完の入力変更も含み得るため、保存済みの証拠を現在の結果として使う前に[入力と対応付けの更新手順](requirements.ja.md#テストや対応付けの更新)を確認してください。

以下の検証コマンドはツールと保守する入力を確認するもので、シミュレータのモデルを実行する検査との違いは[検査のガイド](testing.ja.md#検査)で確認できます。

Python 3.10以降を使います。Verilator実測は5.052固定で、C++ toolchainとmakeが必要です。
repository rootで実行します。

```sh
git status --short --branch
python3 tools/fetch_uvm.py
python3 -m unittest discover -s tools -p 'test_*.py'
python3 tools/lint_metadata.py
python3 tools/requirements.py check
python3 tools/requirements.py inventory --json out/requirements-inventory.json
python3 tools/requirements.py backlog --json out/requirements-backlog.json --lang ja
```

この記録は、tool単体テスト110件、全2359件のmetadata、台帳／索引、library整合性、現在の入力とevidenceの照合を
通過しています。資料だけの変更では、全シミュレーションの再buildは不要です。
全件evidenceはVerilatorだけで、他2系統は未変更1082件の記録、1277入力は未測定です。実行のsmoke確認は次のとおりです。

```sh
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 1 \
  --json out/verilator-smoke.json tests/u09/test_common_phases_run_in_order.sv
```

[以前のCheck実行](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/41561342697)は参照用です。
最新のworkflow結果はREADMEのbadgeで確認してください。後のcommitによって、このrunが置き換わる場合があります。
local検証だけでCI全体の成功とは扱いません。
Checkはtool、metadata、台帳、library、通常oracle付きVerilatorと明示command-line 17件を検査し、Ghost、kirimasim、spec-onlyの実行は含みません。
Nightly workflowや結果の自動公開はありません。

## 実測記録と直近の差分

同じテストが通常条件とbackend条件の両方で測定される場合があり、合計を比較する前に[測定範囲](results.ja.md#現在のスナップショット)で行同士の重複を確認してください。

| シミュレータ／library | 記録した結果 |
| --- | --- |
| Verilator 5.052／固定UVM | runtime pass 1902件（seed 1／73）・期待compile拒否91件・known 366件 |
| Verilator 5.052／独自VPI HDL backend | 別条件の34件：33件が両seed pass、1件はseed 1でfail |
| Verilator 5.052／command-line VPI・固定regex DPI | 別条件の18件で17件は両seed一致、1件はseed 1の既知差分 |
| kirimasim／固定UVM | 未変更1082件で未対応1073件・API欠落fail 9件。1277入力は未測定 |
| Ghost／同梱UVM | 未変更1082件で各seed pass 206件・fail 876件。1277入力は未測定 |
| Ghost／固定UVM | 現在の実行ファイルsnapshotでは未測定 |

通常条件のknownは366件で、runtime初回差分247、simulation build 114、不正compiler受理5です。
buildはAPI／型名欠落35、time減算引数既定値1、型既定宣言2、依存visitor既定型3、印刷signature食違い2、継承type_id registry特殊化2、protected access 1、記載外pure-hook 2、DPI未link 52です。限定したvirtual抽象overview基底型のbuild 2件と、専用poolの印刷返却型build 2件も保持します。追加の合法build 3件はenum-collection T解釈です。ほか7 buildは厳密なattribute／enum-unpackの引数を保持します。別HDL／command-line evidenceは独立に記録します。

M2の新規16検査系はcallback登録／dispatch macroを実行し、runtime 14件と不正なMETHOD signature 2件に分かれます。
runtime 13件はseed 1／73に一致し、compiler 2件は必要なhook82診断と共に拒否されruntimeを実行しません。
新しい未登録instanceへの空queue delete入力は、呼出し後のUT観測前にnull参照診断とexit 1でseed 1を終了し、seed 73結果はありません。
warningの不在やsimulator／libraryの根本原因は認定しません。

他の未登録呼出し3件はWARNINGの存在を観測し、text／ID／正確な件数を固定しません。
parameterized callbackのtypedef、暗黙caller同一性、参照引数の順序、明示enable状態、型付きvirtual dispatch、派生型のtypewide membership、
完了した呼出し間の登録変更、空callerの分離を観測します。affine値33／37とAB／BA traceは独自fixture codeの値です。
private登録bit、factory utilityの前提、反復中の変更、未指定のqueue間順序は仮定しません。

日英AI義務11件はB.4.1とB.4.3を部分分解します。以前の部分義務2件へ条件と直接linkを加え、元のstatementとlinkを保持し、
挿入profileの期待値と限界を拡張します。全409分類と範囲案は未変更です。B.4概要はcallback基底の本文が10.7.2.2.2と異なるため未評価に残します。
全体は部分1986／分類409／未評価112、付録Bは113／5／26、義務231件、主引用173検査系（simulation 170／elaboration 3）です。
全3887義務は2327テストへ直接対応し、他の32テストはcontrol専用、control linkあり121です。全ての部分義務と元のM1〜M4目標は未完です。

以前の通常2343記録、HDL 34記録、command-line 18記録、以前のcompiler 94記録、互換guest 1082記録の内容は保持します。
新しいguest実行／filterやbackend／runner変更はありません。guest未測定1277入力は追加1274件と修正した元入力3件（simulation 1181／elaboration 96）です。
人のレビューと範囲／分母承認は未完です。

全2359件（simulation 2263／elaboration 96）、M1 1000（921／79）、M2 563（556／7）、M3 796（786／10）です。
通常passは1993（runtime 1902／拒否91）、knownは366（runtime 247／build 114／不正受理5）です。
guestは互換1082記録を保持し、未測定1277入力は追加1274件と修正した元入力3件です。

以前の分割前[Check実行](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/41976785278)は、設定された150分のjob上限を超えました。
現在のworkflowは現在のタグ付き1993検査を重複しない8 shard（250／249／249／249／249／249／249／249）へ分け、同時shard jobは最大4です。
和集合の完全一致と重複なしをlocalで検証しました。command-line 17検査はshard 0で通常検査の前に1回だけ実行します。
seed 1／73、compiler拒否の判定規則、固定依存関係、runner指紋は未変更です。従来のverilator gateは全shardの成功を要求します。shard分割は実行の構成であり、local検証でhosted workflowの成功は立証しません。

集約した記録は、過去の未変更入力を保持し、再測定した記録だけを置換します。1回の呼出しで全件を再実行したものではありません。
現在のhostでは、互換なlocal記録は次にあります。

```text
out/thin-eighty-second-verilator-combined.json
out/thin-eighty-second-ghost-final-1.json
out/thin-eighty-second-ghost-final-73.json
out/thin-eighty-second-kirimasim-final.json
out/thin-eighty-second-inventory.json
out/thin-eighty-second-backlog-final.json
out/thin-eighty-second-evidence-scope.json
out/thin-eighty-second-hdl-combined.json
out/thin-eighty-second-cmdline-final.json
```

再利用前に、宣言した全件／部分の対象ごとのtest ID集合の完全一致、現在の`inputs_sha256`、simulatorの版／設定／libraryの同一性、
`runner_sha256`の一致、`runner_changed`がfalseであることを確認します。互換でない記録を合算しません。
Git対象外のファイルなので別hostにはない場合があり、許可された設定と版管理するrunnerで再測定します。
[記録の集約](results.ja.md#記録の合算)も参照してください。

今回のguest filterはfieldのconfigure引用を直した入力を除き、以前の互換1083記録を1082へ絞るもので、guestを新しく実行していません。正確な除外と件数は[証拠のガイド](results.ja.md#記録の合算)で説明しています。

## 継続goalと完了監査

未評価件数と部分的な義務は別の残作業を数えるため、件数が減るだけではgoalを完了できない理由は[対応状況と進捗を読む](reading-guide.ja.md#対応状況と進捗を読む)を参照してください。

ユーザーはM1〜M4の未対応0件まで続けるgoalを依頼しました。開始時は未評価1,463番号、未対応テスト0件、直接テストのない要求0件でした。
54反復で未評価112へ減らし、有効化以降の減少は1351です。B.4.1とB.4.3を部分分解し、以前の部分義務2件へ条件と直接linkを加えます。
付録Bは113／5／26です。runtime 13件は両seed一致、METHOD不正入力2件はruntimeなしで拒否されます。
新しい未登録instanceへの空queue deleteはseed 1で呼出し後の観測前にexit 1で終了します。
食違うB.4概要、残るmacro／RO条件、predictor check_phase、resource格納、広いHDL／時間条件、全ての部分義務と元の目標は未完です。第16章にも16.2.10が残り、既存の既知差分は未変更で、元のmilestoneはどれも未完です。

以前の12.2.9.2の再分類は未評価件数を減らしません。goalを有効に保ち、第12章の未評価0を部分分解169番号や明示milestone目標の完了へ置き換えません。
最終監査は元の範囲、実際の規範的義務、有意な条件、互換な実行evidenceを確認します。限定解釈、既知差分、guest未測定を保持し、架空の承認やpass化を行いません。

日英資料を維持し、検証した追加をmainへ反映します。goal本体の状態は会話が管理し、この記録はgoalを置き換えない引継ぎです。

## 残作業と優先候補

対応付けqueueが空でも一部分解した義務は残るため、[棚卸しの状態](requirements.ja.md#版管理するデータと生成する棚卸し)で、残るレビューとテストlinkの不足を区別してください。

第15章は未評価0番号・部分67番号です。選択relevance上限と実pull-port記録eventに直接検査ができましたが、正時刻上限とinterface継承の解釈は限定して残します。
新しい継承oracleを導く前にclass宣言を合わせて読み、wait_for_sequencesの待機動作は即時tryと分けます。
connectorの既定／不正型、priority、他の記録経路、phase／default連携、完全なprotocol履歴などの条件は残ります。

第7／13章の未評価はありませんが、部分50／89番号を監査します。recording活動／handle、event pool、transaction順序、設定、非同期domain、全error条件が残ります。
error／event backend timestampは限定解釈で、application全体へ1つのtoken／string encodingを課しません。
all_dropped function／task、create_object等価callの引数数、report_db／report_cb名の食違いを未解決に保持します。
付録Dの未評価はありませんが、部分39番号を保持します。名前wrapperには欠落名／path／mapや全status／protocol監査が残り、library結果から未規定のnull-target診断を導かないでください。
第18章には未評価35番号が残り、18.1〜18.3配下にはありませんがmap／register-fileの部分義務は未完了です。
clone提供／source保持には直接観測ができましたが、新map内容／rightsと印刷scalar／map返却の食違いは未完了です。handle返却／登録契約を作って隠さないでください。
有効幅、限定word単位、単一mapのnull既定値、lock前field名の差分を保持します。register frontdoor／backdoor、coverage、field／memory宣言、adapter／predictor callback、寿命／並行アクセス条件を続けます。

次の候補は優先順位の提案で、承認済みの除外やカバレッジ率ではありません。
追加作業を選ぶ前に、backlogを再生成してください。

既存テストの対応付けqueueは、すべてのrootで空です。未評価の識別子112件を規格と照合し、
見出しと規範的義務を区別して条件を分解し、新たなテストを選びます。
一部分解済みの領域でも、有意なdefault、失敗、独立性、順序、lifecycleの組合せを優先します。
oracleを導く前に、API欠落とsignature／本文の矛盾を確認します。

基底classの続き：第5章の全部分99番号を監査し、pure-method／既定bodyの文言、全virtual宣言条件、initiatorのprint／record、
transaction event／record順序、parent link、recording既定値／禁止区間error、handle保持を扱います。
全time単位、分解能／既定引数、field-operation再利用を見直し、active-policy欠落build 4件と引数既定値buildを保持します。
compiler受理を言語の妥当性へ置き換える前に、旧virtual overrideも規格のformal名で監査します。
選択した独自hook probeで全macro／自動configuration動作は立証しません。第5章の未評価番号はありませんが、契約と元のM1〜M4目標は未完です。

builtin-sequenceの続き：付録Eの全部分74番号を監査し、物理reset hook、選択childの実algorithm、model／child lifecycle、
中止／並行start、skip／error組合せ、全map／abstraction形状、歴史的walking-ones解釈を扱います。既定名差分2件、virtual dispatcherの受理、literalなprotected member名を保持します。
独自の実行中slot probeは委譲だけを認定します。Eの未評価番号はありませんが、それによって完了した契約はありません。

sequencerの続き：第15章の全部分67番号を監査し、独立して根拠付けるcounter意味でのburst途中の上限変更、
sequencer別状態、push／peek／getの自動記録条件、任意pipeline中止を扱います。正時刻上限の解釈と15.2.1の継承矛盾を保持します。
付録Bには未評価26番号が残り、report／object／field／pack macroを個別に読み、static-library差分を保持します。

resourceの続き：付録Cの全部分71番号を監査し、recent-set sort解釈、空／重複／null queue、照合方言／backend別条件、
virtual regex／scope宣言、欠落typed-DB最大値helperを扱います。最初の最大値の同順位規則とrecent-set sort順を分け、
全precedence／lookup_type矛盾、既存のwarning欠落と記載外pure-hook buildを保持します。
選択alias、component get、interface handleで全型、自動configuration、並行履歴は認定しません。Cの未評価番号はなく、契約は部分的に残ります。

packageの次作業は、[現在のroot別集計](requirements.ja.md#レビュー用の未整理項目とroot別集計)を使い、付録Fに残る未評価番号と全ての部分的な型、global service、callback変更、初期化、run／abort義務を監査することです。
返却値と実配送のevidenceを分け、分離したPRE_RUNとreport既定値の差分を保持します。

専用poolの続き：印刷pool返却と本文のitem返却の入力を区別します。明示したglobal束縛と有限の待機では、存在しないkeyの静的動作や全並行／寿命条件は決まりません。
既存fieldの引用修正、parentだけの安定義務、幅／LSBの別linkを保持し、結合期待行1つを3テストにしません。
metadata変更でguestの1記録が古くなるため、現在のsourceへ旧hashを付け直したり、Ghostの207から206へのfilterを再実行と説明したりしません。

virtual照会の続き：overviewとclass宣言の基底型の食違い、狭いconstructor／getterの幅の観測、無関係mapのERROR義務を保持します。
不正addressの戻り値やqueueの順序／追記を推測しません。唯一map／default／階層経路、配列index、regionの失敗／重複／再利用、callback／寿命、転送条件を別々に監査します。
getterやmodel内field配置から実際のstorageアクセスを認定しません。

走査の次作業：STRUCTURE単独指定の依存既定値3入力と明示VISITOR controlを分け、build診断から原因を断定しません。
pure method拒否の期待を保持し、受理された不正designは実行しません。追加のtree／graph形状、alias／循環、null、callback変更条件を監査します。
既定の空hookとconstructor形式は選択した証拠です。印刷された非virtual／pure acceptの食違いを照合し、F.5の未評価0を走査coverageの完了にしません。

recording／scalar macroの次作業：字面のenum signature、厳密な3引数attribute、別索引のcontrolを保持します。
collection macro、追加の正の幅、非定数／0／負のN条件を規格と照合してから拒否期待を追加します。
TR_HANDLEの解釈とgeneric変換を区別し、直接APIのcontrol成功で小整数macroの委譲や残るrecording lifecycleを完了にしません。

保護callbackの次作業：register／fieldとfrontdoor／backdoorの拒否条件、反対方向の対照、peer／familyの分離、削除履歴を分けて保持します。
独立したcallback順序、失敗／並行条件、post-predictとaccess policyの組合せへ続けます。選択guardの一致や18.11の未評価0で契約を完了にしません。

field-accessの次作業：registerがfieldに先行するpre-hook期待とcallback起点のmap変更2差分を、開始時mapを明示するcontrolと分けて保持します。
限定した全word best-effort RO条件を、選択sliceの保護や一致するpoke controlと分けます。部分的なaccess policy、callback／error履歴、map変更、prediction、副作用へ続け、
18.5の未評価0で完全性を立証しません。

field-macroの次作業：字面のcollection TとPACK単独の差分を、一致するcontrol 4件と分けて保持します。
event property、empty／null／alias／不正型の組合せ、独立した片方向pack／unpack、print／record／configuration、radix／recursionの組合せへ続けます。
選択two-stateのcopy／compare観測で全macro操作を認定しません。

core-serviceの次作業：記載methodだけの完全subclassは固定版の記載外phase-hopper hookをなお要求します。
build差分と別の追加hook controlを保持し、省略26入力は選択methodだけの理由で拒否されることを確認します。
実facility動作、初回custom service選択、enable seed決定性、global ready上限の伝播を監査し、独自override本体の成功でbuiltin algorithmを置換しません。

memory／special-registerの次作業：第18章の未評価は45番号です。18.6〜18.8は未評価0でも部分的に残ります。
FIFOのconstructor-only前提と明示初期化control条件を分け、直接write／update、公開abstractと内部mirrorの解釈、backdoor除外、幅／容量、失敗／並行履歴を監査します。
memory-rights warning欠落と、以前のlocal-only lookup、coverage返却、公開read、map既定値の差分も保持します。
独自driver queueは検査系modelで、実HDLの証拠は別条件です。field／virtual-register宣言、adapter／predictor、callback義務へ続けます。
初期化controlのpassで直接constructor／API義務を置換しません。

第8章の未評価は0ですが60番号が部分分解です。built-inの全type_id categoryと明示例外、全name／type／既定値／override組合せ、再帰loop復旧、wildcard context、alias、print状態、wrapper寿命、概要の単一instance限定解釈を監査します。
宣言buildはruntimeのない合法simulationであり、負のcompiler拒否とは別です。printレビューはUT markerだけでなく囲んだruntime regexも確認します。
ERROR／nullの義務を分け、実測差分を保持します。

第9章の未評価は0ですが94番号が部分分解です。各classの継承／宣言条件、全graph形状、active sync／unsync変更とtopology、
不正／無関係／前方jump、全callback遷移、task thread cleanupを監査します。8 functionと13 taskのmatrixは2つの直接delegate fixtureであり、全自動schedule動作を証明しません。
get_imp／get_schedule、default-iteration prototypeの矛盾と実際のtimeout見出しF.7.3.3を保持します。

以前のM4 negative-elaboration対応の不足は、台帳schema 2で解消しました。実際の不正elaboration metadataへstageと正確な宣言regexが対応する診断linkだけを追加します。
compile戻り値と一致errorを測定evidenceとして保持し、実行時seedとは分けます。他のvirtual／pure-method宣言、不正派生class／型、constructor可視性のnegative matrixは残ります。
選択した直接生成禁止で、全抽象型義務を完了したとは扱いません。

第12章に未評価番号はありませんが、部分義務の監査が必要です。印刷されたblocking／nonblocking providerの矛盾、同種接続の不正呼出し後の管理状態、connectのP signature、forward-port本文、他の抽象／不正派生条件、user派生制約、正確なmember所有関係、全互換／不正topologyとprotocol履歴は残ります。
限定解釈probeは照合資料として使い、不具合の証明とは扱いません。

TLMの候補は、広いchannel／analysis適用条件、nonblocking／binding互換性、TLM 2 protocol条件、独立RSP既定値の差分、容量0のis_full文言、概要alias／imp parameterです。
宣言失敗をAPI欠落／DPI未linkと区別し、REQだけ指定して失敗したbuildには実行時結果を付けません。

同期の候補は、pool get_globalのsignature／本文矛盾、callback_mode省略既定値の矛盾、不正callback組の条件、delta遅延wait option、広いreset／cancel／並行性のcoverageです。
既存テストはpool初期sizeを仮定しないため、その独立性を保ち、必要な初期所属を別のspec-only検査に保持します。mode 0のcallback経路が正しくても中間totalは解決しません。

第6章の未評価番号は0ですが、部分分解98番号が残ります。print probeは選択した共通／設定内容を観測し、全分類、既定文面、reporting全体は認定しません。
printer 16.2節には未評価の16.2.10 table-format概要が残り、解消のために印刷されていない列／行構文を規定しません。第16章全体ではtable-format概要の未評価1番号が残り、導入16は個別に文脈と分類し、recorder-link概要は部分分解のままです。
既定format意味、再帰履歴key、depth境界、循環graph、scope separator、4-state値、全radix／設定組合せ、caller所有を監査します。
限定したentry-depth matrixと、独立した上限超過済みの不一致は別々に保持します。

policy差し替えの監査は選択A／B／A scalar入力の先へ続け、入れ子object、alias、field操作によるhook無効化、追加設定の組合せ、同じrecorderの反復履歴を規格から確認します。章導入はこれらの部分義務へ対応する文脈であり、全組合せの認定ではありません。

次の候補はreport resetとfilterの相互作用、activeなlock／grab所有とrelevance、sequence-library mode実行とunbound適用可否、adapterの片方向lane／byte順の独立した義務、parent-sequence条件です。catcher API欠落とpartial-byte有効bitの逆再構築も別のレビュー作業として残ります。
parent_sequence条項はdo_cloneを指定しているため、objectのclone APIと同じ意味と仮定する前に記述を確認します。
未解決の義務はbacklogに残します。

memory-managerではallocation／locality enumと設定memberの意味、人が読める状態、region生成／所有概要が残ります。
代入だけからGREEDY／THRIFTYやBROAD／NEARBYの動作を認定せず、部分条件、再設定制約、実backend転送を監査します。
burst-write offsetとburst-read output／refの食違いは選択委譲観測と分けて保持します。

register連携の候補は、callbackのresize／無効化とoperation失敗条件、広いtranslation beat、独立した片方向payload検査、広いforce／release型と時間付きwrapperの相互作用です。
task-based read境界とcallback値pipelineには選択した検査系ができましたが、その存在だけで広い適用条件や保持する伝播4差分は解消しません。
診断severityの期待値を導く前に、印刷されたwrite宣言の矛盾と待機predictor検査の契約を確認します。

現在の要求案には、直接テストの未対応はありません。memory-walkの限定した歴史的解釈を含め、
直接対応のqueueを解消しますが、M1〜M4の完了ではありません。その解釈と残る識別子112件を照合し、
適用条件、失敗、lifecycle／並行性、独立した検査を拡充します。
第11章のmethod条項は部分的な分解のままで、概要と構造上の見出しにAIの明示的分類があります。
他の箇所も個別に読み、根拠を保持し、見出し名から分類を推測しません。
より広いHDL動作、E.7の解釈、人のレビュー、分母承認も未完です。

## 次の追加作業の進め方

一致するcontrolは異なる前提の評価を助けても直接義務を置換できないため、次の検査系を選ぶ際は[引用・要求・実行の証拠](requirements.ja.md#引用要求実行の証拠)を参照してください。

1. local規格の該当条項と関連検査系を読みます。実測前に独立した期待観測を定めます。
   公開APIと独自testbench modelを使い、検査系自身のalgorithmとUVMの動作を区別します。
2. runner開始前に、名前、整形、metadata、lifetimeを整えます。必要な手続きlocalの初期化ではlifetimeを明示します。
   virtual baseには具体的な派生クラスを使います。enum名は型付きenum値から取得します。
   displayのformatは文字列literalにします。
3. 最終入力をVerilator 5.052のseed 1／73と、許可されたguest設定で測定します。
   長時間jobは管理されたsessionで動かし、完了batchを保存します。測定中に入力を編集しません。
4. 検査系の誤りと規範的差分を区別します。fingerprintに影響するmetadata／commentの変更も含め、変更した入力だけを
   再測定します。有効なAPI欠落はspec-onlyに残し、要求された標準APIをlegacy fieldで代用しません。
5. 台帳へ日英の義務と正確な期待出力anchorを追加します。索引対象の追加／変更時は`sync`の提案を確認し、
   未変更の記録と要求IDの一意性を保ちます。同じ観測を複数義務で共有しても、独立したテストにはなりません。
6. 台帳／索引、現在のfingerprint、互換なevidenceを検証します。現在のREADME／実行結果／既知差分、日英ガイド、
   必要に応じてFAQ／用語集を更新し、追加作業の詳細は履歴へ記載します。
7. 両言語の見出し、事実、literal、command、表、図、local linkを確認します。stage後の空白を確認し、reviewした範囲を
   commitし、pushが許可されている場合はremoteとCIを確認します。local規格や非公開simulatorの設定／診断は公開しません。

測定入力にはヘッダー、期待値、収集したhelperも含むため、変更後に更新が必要な記録は[指紋の確認項目](results.ja.md#記録の合算)に沿って判断してください。

backlogと索引提案のコマンドです。

```sh
python3 tools/requirements.py backlog --root 14 --lang ja \
  --json out/requirements-backlog-14.json
python3 tools/requirements.py backlog --root 18 --lang ja \
  --json out/requirements-backlog-18.json
python3 tools/requirements.py backlog --root 12 --lang ja \
  --json out/requirements-backlog-12.json
python3 tools/requirements.py sync --output out/test-index-proposal.json
```

上の`sync`コマンドは対応付けのレビュー用に索引の案を書き出すもので、影響するリンクを確認して取り込む方法は[更新手順](requirements.ja.md#テストや対応付けの更新)で説明しています。

## 再開メッセージの例

次のメッセージは再開する作業の要約で、優先候補を使う前に現在の状態を確かめるコマンドは[再開と基本確認](#再開と基本確認)にあります。

> READMEと日英のハンドオフを読み、作業ツリーと最新Checkを確認して、要求backlogを再生成してください。
> ユーザーが配置したIEEE規格を使い、M1〜M4の薄い領域の補強を続けてください。
> 未評価の規範的義務とmemory-walk解釈の照合を優先候補にし、M1〜M3でも意味のある新しい動作を追加してください。
> 規格に基づく期待値、商用結果の除外、Ghostの非公開性、AI照合状態、完全な日英文書を維持してください。
> 最終入力を測定し、有効なspec-only差分を残して、完了した変更・検証・残る制約を報告してください。
