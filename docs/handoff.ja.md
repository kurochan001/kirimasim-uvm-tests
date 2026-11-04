# 開発ハンドオフ

[English](handoff.md) · [README](../README.ja.md) · [要求台帳](requirements.ja.md)

## 引継ぎ時点と目的

2026-11-05に、`main`の[66c6075](https://github.com/kurochan001/kirimasim-uvm-tests/commit/66c6075b396f7b2ae0ba39a87e1be15f3d00e25c)
を基に、薄い領域の59回目の拡充へ更新しました。再開時に最新の公開commitと作業ツリーを確認してください。

IEEE 1800.2-2020のUVM適合を検査し、kirimasimを対象とするプロジェクトです。
SystemVerilog言語だけのreproducerは、
[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests)で扱います。
M1〜M4の薄い領域を引き続き補強します。M4は進行中で、未対応テスト0件は、どの段階の完了も意味しません。

| 領域 | 現在の状態 |
| --- | --- |
| M1 | 709件（runtime 667・elaboration 42）：core object、policy、reporting、階層、factory、phase、同期、recording、utility |
| M2 | 547件（runtime 542・elaboration 5）：sequence、sequencer、callback、TLM |
| M3 | 516件（runtime 511・elaboration 5）：register／memory layer、付録E |
| 全体 | 章・付録21 directoryに1772件（simulation 1720・elaboration 52）。照合はすべてAIで、人による照合は未記録 |
| M4 | AI要求案3110件。3110要求を1771テストへ直接対応。追加control 1テスト。未対応テスト0件 |
| 規範的棚卸し | 2,507識別子のうち1690件を一部分解、357件を明示的に分類。460件は未評価。直接テストのない要求案0件 |

`scope_status`は提案、`normative_inventory_complete`はfalse、
`approved_denominator`／`coverage_percentage`はnullです。主引用テストがある21 rootすべてで未対応テスト0件ですが、
規範的な分解と人のレビューは未完です。

## 維持する方針

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

- [テストガイド](testing.ja.md)：metadata、コンパイル、runner option、変更時の方針。
  [実行結果](results.ja.md)：evidenceの解釈と集約方法。
  [既知差分](known-differences.ja.md)：spec-only全230件。
- [要求ガイド](requirements.ja.md)、[範囲](../coverage/scope.json)、[台帳](../coverage/requirements.json)、[分類](../coverage/assessments.json)、
  [テスト索引](../coverage/test_index.json)：M4の正規の状態です。生成inventoryはレビューの補助資料で、
  版管理する入力の代わりではありません。
- [library lock](../third_party/uvm.lock)：Accellera UVM 2020.3.1、`78c06547a2a0`、326ファイル。
  版管理するtoolで取得し、library本体はコミットしません。1743検査系は`UVM_NO_DPI`を使い、11件は独自VPI HDL backendを明示要求します。
- ユーザーがrepository rootへ`IEEE_Std_1800.2-2020.pdf`と
  `IEEE_Std_1800-2023_SystemVerilog.pdf`を配置済みです。Git対象外のlocalファイルで、
  新規cloneにはなく、再配布しません。`out/`内の抽出済みtextはlocalでGit対象外です。`/tmp`は消える場合があります。
- `out/`の結果はGit対象外のlocal資料です。`out/thin-fifty-ninth-scratch-*.py`の一時helperは、
  あれば使える補助で、保守対象の入口ではありません。台帳／履歴へ追記するものがあり、無条件に再実行しません。
  不在なら版管理するtoolから必要な処理を組み立てます。

## 再開と基本確認

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

この記録は、tool単体テスト110件、全1772件のmetadata、台帳／索引、library整合性、現在の入力とevidenceの照合を
通過しています。資料だけの変更では、全シミュレーションの再buildは不要です。
全件evidenceはVerilatorだけで、他2系統は未変更1083件の記録、689入力は未測定です。実行のsmoke確認は次のとおりです。

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

| シミュレータ／library | 記録した結果 |
| --- | --- |
| Verilator 5.052／固定UVM | runtime pass 1492件（seed 1／73）・期待compile拒否50件・known 230件 |
| Verilator 5.052／独自VPI HDL backend | 別条件の11件：10件が両seed pass、1件はseed 1でfail |
| Verilator 5.052／command-line VPI・固定regex DPI | 別条件の18件で17件は両seed一致、1件はseed 1の既知差分 |
| kirimasim／固定UVM | 未変更1083件で未対応1074件・API欠落fail 9件。689入力は未測定 |
| Ghost／同梱UVM | 未変更1083件で各seed pass 207件・fail 876件。689入力は未測定 |
| Ghost／固定UVM | 現在の実行ファイルsnapshotでは未測定 |

通常条件のknownは230件で、runtime初回差分171、simulation build 57、不正compiler受理2です。
buildはAPI／型名欠落20、型既定宣言2、印刷signature食違い2、継承type_id registry特殊化2、protected access 1、記載外pure-hook 1、DPI未link 29です。別HDL／command-line evidenceは独立に記録します。

M2 sequencer 9 fixtureを追加し、8件が両seed runtime一致、1件がseed 1 runtime差分でseed 73なしです。
relevance guardは時刻0で省略時10、明示2／12、base view経由のvirtual setterに一致します。
時刻3に3を設定して新しいzero-time burstを始めると、通知はcallback 5回目となります。
保持する限定oracleは上限または最初の超過（3／4回）での通知を許すため、spec-onlyに残します。
生のcallback回数／時刻は境界predicateと分け、未指定のerror通知としてERROR／FATALを許容し、正確なseverity／ID／文面規則は作りません。
counter reset、負上限、error後の復旧動作も作りません。

実pull-port転送は自動の指定begin／end通知とtimestamp、初回要求前の無効化による抑止、モデル化したpipeline完了を制御する明示component recording、
独立した独自address／data eventに一致します。規格typed callbackはtransaction-pool entryを観測し、登録は初期pool所属の証明ではありません。
物理DUT完了、recorder handle配置、DB形式は認定しません。interface overviewの継承記述と実class宣言の矛盾は未解決に残し、新たな継承規則にはしません。

新しいlibrary-utils義務1件を未変更macro fixture 4件へ対応付けます。派生subtypeを含む各拡張は既に自身の正確な型で必要macroを呼んでいます。
空のstatic membership差分は未変更で保持し、追加の実装init helperや新たな実行は主張しません。

以前の全1763通常入力／記録・3094要求・353分類は未変更です。全1772（simulation 1720／elaboration 52）、M1 709（667／42）、M2 547（542／5）、M3 516（511／5）です。
通常passは1542（runtime 1492／拒否50）、knownは230（runtime 171／build 57／不正受理2）です。tool test 110件、metadata／台帳／library、現在入力evidence、日英資料検査は成功します。
guest／HDL／command-line記録は未変更で、guest未測定は689入力です。人の承認やgoal完了は主張しません。

集約した記録は、過去の未変更入力を保持し、再測定した記録だけを置換します。1回の呼出しで全件を再実行したものではありません。
現在のhostでは、互換なlocal記録は次にあります。

```text
out/thin-fifty-ninth-verilator-combined.json
out/thin-fifty-ninth-ghost-final-1.json
out/thin-fifty-ninth-ghost-final-73.json
out/thin-fifty-ninth-kirimasim-final.json
out/thin-fifty-ninth-inventory.json
out/thin-fifty-ninth-backlog-final.json
out/thin-fifty-ninth-evidence-scope.json
out/thin-fifty-ninth-hdl-combined.json
out/thin-fifty-ninth-cmdline-final.json
```

再利用前に、宣言した全件／部分の対象ごとのtest ID集合の完全一致、現在の`inputs_sha256`、simulatorの版／設定／libraryの同一性、
`runner_sha256`の一致、`runner_changed`がfalseであることを確認します。互換でない記録を合算しません。
Git対象外のファイルなので別hostにはない場合があり、許可された設定と版管理するrunnerで再測定します。
[記録の集約](results.ja.md#記録の合算)も参照してください。

## 継続goalと完了監査

ユーザーはM1〜M4の未対応0件まで続けるgoalを依頼しました。開始時は未評価1,463番号、未対応テスト0件、直接テストのない要求0件でした。
31反復で未評価460へ1003減らしました。直近のsequencer追加では7番号を個別に分解／分類し、以前の追加は開発履歴へ残します。
第15章は未評価0・部分67となりましたが、残る条件や元のmilestone目標の完了ではありません。

以前の12.2.9.2の再分類は未評価件数を減らしません。goalを有効に保ち、第12章の未評価0を部分分解169番号や明示milestone目標の完了へ置き換えません。
最終監査は元の範囲、実際の規範的義務、有意な条件、互換な実行evidenceを確認します。限定解釈、既知差分、guest未測定を保持し、架空の承認やpass化を行いません。

日英資料を維持し、検証した追加をmainへ反映します。goal本体の状態は会話が管理し、この記録はgoalを置き換えない引継ぎです。

## 残作業と優先候補

第15章は未評価0番号・部分67番号です。選択relevance上限と実pull-port記録eventに直接検査ができましたが、正時刻上限とinterface継承の解釈は限定して残します。
新しい継承oracleを導く前にclass宣言を合わせて読み、wait_for_sequencesの待機動作は即時tryと分けます。
connectorの既定／不正型、priority、他の記録経路、phase／default連携、完全なprotocol履歴などの条件は残ります。

第7／13章の未評価はありませんが、部分50／89番号を監査します。recording活動／handle、event pool、transaction順序、設定、非同期domain、全error条件が残ります。
error／event backend timestampは限定解釈で、application全体へ1つのtoken／string encodingを課しません。
all_dropped function／task、create_object等価callの引数数、report_db／report_cb名の食違いを未解決に保持します。
付録Dの未評価はありませんが、部分39番号を保持します。名前wrapperには欠落名／path／mapや全status／protocol監査が残り、library結果から未規定のnull-target診断を導かないでください。
第18章には未評価116番号が残り、18.1〜18.3配下にはありませんがmap／register-fileの部分義務は未完了です。
clone提供／source保持には直接観測ができましたが、新map内容／rightsと印刷scalar／map返却の食違いは未完了です。handle返却／登録契約を作って隠さないでください。
有効幅、限定word単位、単一mapのnull既定値、lock前field名の差分を保持します。register frontdoor／backdoor、coverage、field／memory宣言、adapter／predictor callback、寿命／並行アクセス条件を続けます。

次の候補は優先順位の提案で、承認済みの除外やカバレッジ率ではありません。
追加作業を選ぶ前に、backlogを再生成してください。

既存テストの対応付けqueueは、すべてのrootで空です。未評価の識別子460件を規格と照合し、
見出しと規範的義務を区別して条件を分解し、新たなテストを選びます。
一部分解済みの領域でも、有意なdefault、失敗、独立性、順序、lifecycleの組合せを優先します。
oracleを導く前に、API欠落とsignature／本文の矛盾を確認します。

sequencerの続き：第15章の全部分67番号を監査し、独立して根拠付けるcounter意味でのburst途中の上限変更、
sequencer別状態、push／peek／getの自動記録条件、任意pipeline中止を扱います。正時刻上限の解釈と15.2.1の継承矛盾を保持します。
付録Bには未評価100番号が残り、report／object／field／pack macroを個別に読み、static-library差分を保持します。

resourceの次作業は付録Cの残る未評価20番号と部分52番号の監査です。sort／regex／scope collectionと型付き最大値を規格から導き、
食い違う文を限定し、既定／static config／DB宣言とalias、不正引数、lifecycle条件を拡張します。local／global双方のname-precedence差分、lookup warning欠落、
記載外pure-hookの合法buildを保持し、compatibility本体や一致する既定返却値でその義務を代用しません。

packageの次作業は付録Fの未評価63番号と全ての部分的な型、global service、callback変更、初期化、run／abort義務の監査です。
返却値と実配送のevidenceを分け、分離したPRE_RUNとreport既定値の差分を保持します。

memoryの次作業は第18章の残る未評価116番号と部分的なconstructor／既定／map／burst／policy／lifecycle組合せの監査です。
local-only照会の履歴、以前mask返却、公開read access差分を保持します。派生wrapperのHDL結果と公開宣言契約を分け、
制限backendが全type／操作を支えると仮定せず、実array、重複path、失敗動作を拡張します。

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
printer 16.2節には未評価の16.2.10 table-format概要が残り、解消のために印刷されていない列／行構文を規定しません。第16章全体では章導入、table-format概要、transaction-recorder lifecycle／link概要の未評価3番号が残ります。
既定format意味、再帰履歴key、depth境界、循環graph、scope separator、4-state値、全radix／設定組合せ、caller所有を監査します。
限定したentry-depth matrixと、独立した上限超過済みの不一致は別々に保持します。

次の候補はreport resetとfilterの相互作用、activeなlock／grab所有とrelevance、sequence-library mode実行とunbound適用可否、adapterの片方向lane／byte順の独立した義務、parent-sequence条件です。catcher API欠落とpartial-byte有効bitの逆再構築も別のレビュー作業として残ります。
parent_sequence条項はdo_cloneを指定しているため、objectのclone APIと同じ意味と仮定する前に記述を確認します。
未解決の義務はbacklogに残します。

memory-managerではallocation／locality enumと設定memberの意味、人が読める状態、region生成／所有概要が残ります。
代入だけからGREEDY／THRIFTYやBROAD／NEARBYの動作を認定せず、部分条件、再設定制約、実backend転送を監査します。
burst-write offsetとburst-read output／refの食違いは選択委譲観測と分けて保持します。

register連携の候補は、callbackのresize／無効化とoperation失敗条件、広いtranslation beat、独立した片方向payload検査、実際のforce／release対応です。
task-based read境界とcallback値pipelineには選択した検査系ができましたが、その存在だけで広い適用条件や保持する伝播4差分は解消しません。
診断severityの期待値を導く前に、印刷されたwrite宣言の矛盾と待機predictor検査の契約を確認します。

現在の要求案には、直接テストの未対応はありません。memory-walkの限定した歴史的解釈を含め、
直接対応のqueueを解消しますが、M1〜M4の完了ではありません。その解釈と残る識別子460件を照合し、
適用条件、失敗、lifecycle／並行性、独立した検査を拡充します。
第11章のmethod条項は部分的な分解のままで、概要と構造上の見出しにAIの明示的分類があります。
他の箇所も個別に読み、根拠を保持し、見出し名から分類を推測しません。
より広いHDL動作、E.7の解釈、人のレビュー、分母承認も未完です。

## 次の追加作業の進め方

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

## 再開メッセージの例

> READMEと日英のハンドオフを読み、作業ツリーと最新Checkを確認して、要求backlogを再生成してください。
> ユーザーが配置したIEEE規格を使い、M1〜M4の薄い領域の補強を続けてください。
> 未評価の規範的義務とmemory-walk解釈の照合を優先候補にし、M1〜M3でも意味のある新しい動作を追加してください。
> 規格に基づく期待値、商用結果の除外、Ghostの非公開性、AI照合状態、完全な日英文書を維持してください。
> 最終入力を測定し、有効なspec-only差分を残して、完了した変更・検証・残る制約を報告してください。
