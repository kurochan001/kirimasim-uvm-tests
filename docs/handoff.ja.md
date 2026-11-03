# 開発ハンドオフ

[English](handoff.md) · [README](../README.ja.md) · [要求台帳](requirements.ja.md)

## 引継ぎ時点と目的

2026-11-04に、`main`の[e3244d7](https://github.com/kurochan001/kirimasim-uvm-tests/commit/e3244d7d4875b2019c898252344845df1e7868fa)
を基に、薄い領域の41回目の拡充へ更新しました。再開時に最新の公開commitと作業ツリーを確認してください。

IEEE 1800.2-2020のUVM適合を検査し、kirimasimを対象とするプロジェクトです。
SystemVerilog言語だけのreproducerは、
[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests)で扱います。
M1〜M4の薄い領域を引き続き補強します。M4は進行中で、未対応テスト0件は、どの段階の完了も意味しません。

| 領域 | 現在の状態 |
| --- | --- |
| M1 | 498件（runtime 483・elaboration 15）：core object、policy、reporting、階層、factory、phase、同期、recording、utility |
| M2 | 516件（runtime 513・elaboration 3）：sequence、sequencer、callback、TLM |
| M3 | 432件（runtime 427・elaboration 5）：register／memory layer、付録E |
| 全体 | 章・付録21 directoryに1446件（simulation 1423・elaboration 23）。照合はすべてAIで、人による照合は未記録 |
| M4 | AI要求案2177件。2177要求を1445テストへ直接対応。追加control 1テスト。未対応テスト0件 |
| 規範的棚卸し | 2,507識別子のうち1218件を一部分解、191件を明示的に分類。1,098件は未評価。直接テストのない要求案0件 |

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
  [既知差分](known-differences.ja.md)：spec-only全174件。
- [要求ガイド](requirements.ja.md)、[範囲](../coverage/scope.json)、[台帳](../coverage/requirements.json)、[分類](../coverage/assessments.json)、
  [テスト索引](../coverage/test_index.json)：M4の正規の状態です。生成inventoryはレビューの補助資料で、
  版管理する入力の代わりではありません。
- [library lock](../third_party/uvm.lock)：Accellera UVM 2020.3.1、`78c06547a2a0`、326ファイル。
  版管理するtoolで取得し、library本体はコミットしません。1420検査系は`UVM_NO_DPI`を使い、8件は独自VPI HDL backendを明示要求します。
- ユーザーがrepository rootへ`IEEE_Std_1800.2-2020.pdf`と
  `IEEE_Std_1800-2023_SystemVerilog.pdf`を配置済みです。Git対象外のlocalファイルで、
  新規cloneにはなく、再配布しません。`/tmp`内の抽出済みtextも一時資料です。
- `out/`の結果はGit対象外のlocal資料です。`/tmp/kirimasim-uvm-thin-forty-first-*.py`の一時helperは、
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

この記録は、tool単体テスト110件、全1446件のmetadata、台帳／索引、library整合性、現在の入力とevidenceの照合を
通過しています。資料だけの変更では、全シミュレーションの再buildは不要です。
全件evidenceはVerilatorだけで、他2系統は未変更1084件の記録、362入力は未測定です。実行のsmoke確認は次のとおりです。

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
| Verilator 5.052／固定UVM | runtime pass 1251件（seed 1／73）・期待compile拒否21件・known 174件 |
| Verilator 5.052／独自VPI HDL backend | 別条件の8件：7件が両seed pass、1件はseed 1でfail |
| Verilator 5.052／command-line VPI・固定regex DPI | 別条件の18件で17件は両seed一致、1件はseed 1の既知差分 |
| kirimasim／固定UVM | 未変更1084件で未対応1075件・API欠落fail 9件。362入力は未測定 |
| Ghost／同梱UVM | 未変更1084件で各seed pass 207件・fail 877件。362入力は未測定 |
| Ghost／固定UVM | 現在の実行ファイルsnapshotでは未測定 |

通常条件の既知差分は174件で、seed 1のruntime初回差分129件、simulation build差分43件（API欠落16・response既定1・未link DPI 26）、不正elaboration受理2件です。
別のHDL／command-line条件は7 pass／1 fail、17 pass／1 knownを保持します。

最新のM1 13検査系はruntime 12件とreport-server抽象生成1件です。runtime 11件は両seed一致、共有reset 1件はseverity／ID verbosityが残りseed 1で最初に異なりseed 73結果はありません。
compilerは直接抽象生成を一致診断で拒否し、runtime seedは実行しません。既定設定、実file出力、pipeline順序、正確なmessage／name引数、server／database置換、severity queue、helper迂回、選択summary出力を確認します。
独自formatter／action overrideと完全server stubは準備であり、動作全体は認定しません。

M1 498（runtime 483／elaboration 15）、M2 516（513／3）、M3 432（427／5）です。通常`pass`は1272件で、runtime両seed一致1251件とcompiler拒否21件です。
以前の1433入力同一性／記録と全分類を保持します。新規要求案56件で2177件とし、既存3項目は以前のlinkを保持して直接linkと制限注記を追加／改訂します。
個別に読んだ分類8件で191件（構造139／文脈52）とし、全体は部分分解1218・分類191・未評価1098です。
第6章は96／19／2で、printing 2条項と全ての部分条件は残ります。第12章は169／45／0を保持します。

tool test 110件、metadata、台帳／library、evidence、日英資料の検査は成功します。schema、runner／library／catalog、workflow、SVGは未変更です。
guest evidenceは互換なruntime 1084入力を保持し、未測定362件（simulation 339／elaboration 23）です。guest実行、人のレビュー、承認は主張しません。

集約した記録は、過去の未変更入力を保持し、再測定した記録だけを置換します。1回の呼出しで全件を再実行したものではありません。
現在のhostでは、互換なlocal記録は次にあります。

```text
out/thin-forty-first-verilator-combined.json
out/thin-forty-first-ghost-final-1.json
out/thin-forty-first-ghost-final-73.json
out/thin-forty-first-kirimasim-final.json
out/thin-forty-first-inventory.json
out/thin-forty-first-backlog-final.json
out/thin-forty-first-evidence-scope.json
out/thin-forty-first-hdl-combined.json
out/thin-forty-first-cmdline-final.json
```

再利用前に、宣言した全件／部分の対象ごとのtest ID集合の完全一致、現在の`inputs_sha256`、simulatorの版／設定／libraryの同一性、
`runner_sha256`の一致、`runner_changed`がfalseであることを確認します。互換でない記録を合算しません。
Git対象外のファイルなので別hostにはない場合があり、許可された設定と版管理するrunnerで再測定します。
[記録の集約](results.ja.md#記録の合算)も参照してください。

## 継続goalと完了監査

ユーザーは、M1〜M4の未対応が0件になるまで続けるgoalを依頼しました。有効化時点は未評価1,463番号、未対応テスト0件、直接テストのない要求0件です。
13反復で未評価1,098番号となり365番号減りました。register-global 29、command-line 21、sequence 12、register連携36、translation／callback／HDL parameter 22、同期35、objection／callback 34、TLM 1の45、channel／analysis／TLM 2の33、TLM 2 socket／extension／port／impの45番号と抽象宣言4番号、pure interface／subscriber 8番号とreporting 41番号を個別に分解／分類しました。
以前の12.2.9.2の再分類は未評価件数を減らしません。goalを有効に保ち、第12章の未評価0を部分分解169番号や明示milestone目標の完了へ置き換えません。
最終監査は元の範囲、実際の規範的義務、有意な条件、互換な実行evidenceを確認します。限定解釈、既知差分、guest未測定を保持し、架空の承認やpass化を行いません。

日英資料を維持し、検証した追加をmainへ反映します。goal本体の状態は会話が管理し、この記録はgoalを置き換えない引継ぎです。

## 残作業と優先候補

次の候補は優先順位の提案で、承認済みの除外やカバレッジ率ではありません。
追加作業を選ぶ前に、backlogを再生成してください。

既存テストの対応付けqueueは、すべてのrootで空です。未評価の識別子1,098件を規格と照合し、
見出しと規範的義務を区別して条件を分解し、新たなテストを選びます。
一部分解済みの領域でも、有意なdefault、失敗、独立性、順序、lifecycleの組合せを優先します。
oracleを導く前に、API欠落とsignature／本文の矛盾を確認します。

以前のM4 negative-elaboration対応の不足は、台帳schema 2で解消しました。実際の不正elaboration metadataへstageと正確な宣言regexが対応する診断linkだけを追加します。
compile戻り値と一致errorを測定evidenceとして保持し、実行時seedとは分けます。他のvirtual／pure-method宣言、不正派生class／型、constructor可視性のnegative matrixは残ります。
選択した直接生成禁止8件で、全抽象型義務を完了したとは扱いません。

第12章に未評価番号はありませんが、部分義務の監査が必要です。印刷されたblocking／nonblocking providerの矛盾、同種接続の不正呼出し後の管理状態、connectのP signature、forward-port本文、他の抽象／不正派生条件、user派生制約、正確なmember所有関係、全互換／不正topologyとprotocol履歴は残ります。
限定解釈probeは照合資料として使い、不具合の証明とは扱いません。

TLMの候補は、広いchannel／analysis適用条件、nonblocking／binding互換性、TLM 2 protocol条件、独立RSP既定値の差分、容量0のis_full文言、概要alias／imp parameterです。
宣言失敗をAPI欠落／DPI未linkと区別し、REQだけ指定して失敗したbuildには実行時結果を付けません。

同期の候補は、pool get_globalのsignature／本文矛盾、callback_mode省略既定値の矛盾、不正callback組の条件、delta遅延wait option、広いreset／cancel／並行性のcoverageです。
既存テストはpool初期sizeを仮定しないため、その独立性を保ち、必要な初期所属を別のspec-only検査に保持します。mode 0のcallback経路が正しくても中間totalは解決しません。

第6章には未評価のprinting 2条項（6.2.2.3／6.4.2.2）が残ります。実装field名や既定文面をコピーせず、printerに基づく観測を確認します。
部分分解96番号では未使用severity部分集合、広いreset／override key、全action組合せ、message記録、全summary統計、formatting名置換も監査します。
選択file出力とcustom hookのcontrolだけでは、これらの義務は完了しません。

次の候補はreport resetとfilterの相互作用、activeなlock／grab所有とrelevance、sequence-library mode実行とunbound適用可否、adapterの片方向lane／byte順の独立した義務、parent-sequence条件です。catcher API欠落とpartial-byte有効bitの逆再構築も別のレビュー作業として残ります。
parent_sequence条項はdo_cloneを指定しているため、objectのclone APIと同じ意味と仮定する前に記述を確認します。
未解決の義務はbacklogに残します。

register連携の候補は、callbackのresize／無効化とoperation失敗条件、広いtranslation beat、独立した片方向payload検査、実際のforce／release対応です。
task-based read境界とcallback値pipelineには選択した検査系ができましたが、その存在だけで広い適用条件や保持する伝播4差分は解消しません。
診断severityの期待値を導く前に、印刷されたwrite宣言の矛盾と待機predictor検査の契約を確認します。

現在の要求案には、直接テストの未対応はありません。memory-walkの限定した歴史的解釈を含め、
直接対応のqueueを解消しますが、M1〜M4の完了ではありません。その解釈と残る識別子1,098件を照合し、
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
