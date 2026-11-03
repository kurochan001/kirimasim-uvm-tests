# 開発ハンドオフ

[English](handoff.md) · [README](../README.ja.md) · [要求台帳](requirements.ja.md)

## 引継ぎ時点と目的

2026-11-03に、`main`の[a00654e](https://github.com/kurochan001/kirimasim-uvm-tests/commit/a00654e6ec3364d36f2b9859b1b4052118f70480)
を基に、薄い領域の33回目の拡充へ更新しました。再開時に最新の公開commitと作業ツリーを確認してください。

IEEE 1800.2-2020のUVM適合を検査し、kirimasimを対象とするプロジェクトです。
SystemVerilog言語だけのreproducerは、
[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests)で扱います。
M1〜M4の薄い領域を引き続き補強します。M4は進行中で、未対応テスト0件は、どの段階の完了も意味しません。

| 領域 | 現在の状態 |
| --- | --- |
| M1 | 447件：core object、policy、reporting、階層、factory、phase、同期、recording、utility |
| M2 | 470件：sequence、sequencer、callback、TLM |
| M3 | 426件：register／memory layer、付録E |
| 全体 | 章・付録21 directoryに1343件。照合はすべてAIで、人による照合は未記録 |
| M4 | AI要求案1856件。1856要求を1342テストへ直接対応。追加control 1テスト。未対応テスト0件 |
| 規範的棚卸し | 2,507識別子のうち1051件を一部分解、113件を明示的に分類。1,343件は未評価。直接テストのない要求案0件 |

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
  [既知差分](known-differences.ja.md)：spec-only全163件。
- [要求ガイド](requirements.ja.md)、[範囲](../coverage/scope.json)、[台帳](../coverage/requirements.json)、[分類](../coverage/assessments.json)、
  [テスト索引](../coverage/test_index.json)：M4の正規の状態です。生成inventoryはレビューの補助資料で、
  版管理する入力の代わりではありません。
- [library lock](../third_party/uvm.lock)：Accellera UVM 2020.3.1、`78c06547a2a0`、326ファイル。
  版管理するtoolで取得し、library本体はコミットしません。1317検査系は`UVM_NO_DPI`を使い、8件は独自VPI HDL backendを明示要求します。
- ユーザーがrepository rootへ`IEEE_Std_1800.2-2020.pdf`と
  `IEEE_Std_1800-2023_SystemVerilog.pdf`を配置済みです。Git対象外のlocalファイルで、
  新規cloneにはなく、再配布しません。`/tmp`内の抽出済みtextも一時資料です。
- `out/`の結果はGit対象外のlocal資料です。`/tmp/kirimasim-uvm-thin-thirty-third-*.py`の一時helperは、
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

この記録は、tool単体テスト101件、全1343件のmetadata、台帳／索引、library整合性、現在の入力とevidenceの照合を
通過しています。資料だけの変更では、全シミュレーションの再buildは不要です。
全件evidenceはVerilatorだけで、他2系統は未変更1085件の記録、新規258件は未測定です。実行のsmoke確認は次のとおりです。

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
| Verilator 5.052／固定UVM | seed 1・73でpass 1180件、known 163件 |
| Verilator 5.052／独自VPI HDL backend | 別条件の8件：7件が両seed pass、1件はseed 1でfail |
| Verilator 5.052／command-line VPI・固定regex DPI | 別条件の18件で17件は両seed一致、1件はseed 1の既知差分 |
| kirimasim／固定UVM | 未変更1085件で未対応1076件・API欠落fail 9件。新規258件は未測定 |
| Ghost／同梱UVM | 未変更1085件で各seed pass 207件・fail 878件。新規258件は未測定 |
| Ghost／固定UVM | 現在の実行ファイルsnapshotでは未測定 |

通常条件のknown 163件は、seed 1の実行時差分121件、API欠落build 16件、DPI未link build 26件（HDL 8・command-line 18）です。
VPI条件は明示選択する8入力で、7件が両seed一致、1件はE.7のwarning／転送なしの差分を保持します。重複する条件を合計しません。

最新の17検査系はM3で、遅延task read 2件、callback pipeline／既定比較対象5件、sequence／frontdoorの型・名前3件、
直接／layered translation 3件、super-bodyの警告／戻らない検査1件、virtual model選択1件、HDL parameter 2件です。13件は両seedで一致します。
encode／decode 4件はseed 1で最初に異なり、呼出し順序は一致しますが変換値が後のcallback／最終値へ届きません。
規範的な期待fileを保持し、別の既定無変更比較対象は一致します。実際のtranslation検査は、実sequencer、独自protocol adapter、遅延する記憶driverを使い、1件は失敗後に再試行します。
parameter検査はmacroとの一致と宣言integer型を検査し、実装macroの数値既定値を固定せず、HDL実行も主張しません。
全体1343件、M1 447件、M2 470件、M3 426件です。新規28要求案で台帳1856件となり、以前の要求案は保持します。
分類は113件で構造91件・文脈22件、第19章は部分分解81番号・分類24番号・未評価6番号です。残る第19章の番号は、
wide-bus operation概要、parent_sequenceのdo_clone、待機predictor検査、force／release 3 routineです。部分分解した義務には広い条件と独立検査が必要です。
write宣言の曖昧さ、既定formatterの完全性、callbackのresize／無効化／失敗条件、物理HDL、必要なkill post-hookは未完です。
別command-line evidenceはpass 17／known 1、HDL VPIはpass 7／fail 1のままです。guest記録は未変更1085入力で258件は未測定です。
全runner、catalog、schema版、library、以前の入力は未変更です。

集約した記録は、過去の未変更入力を保持し、再測定した記録だけを置換します。1回の呼出しで全件を再実行したものではありません。
現在のhostでは、互換なlocal記録は次にあります。

```text
out/thin-thirty-third-verilator-combined.json
out/thin-fourteenth-ghost-final-1.json
out/thin-fourteenth-ghost-final-73.json
out/thin-fourteenth-kirimasim-final.json
out/thin-thirty-third-inventory.json
out/thin-thirty-third-backlog-final.json
out/thin-thirty-third-evidence-scope.json
out/thin-thirty-third-hdl-combined.json
out/thin-thirty-third-cmdline-final.json
```

再利用前に、宣言した全件／部分の対象ごとのtest ID集合の完全一致、現在の`inputs_sha256`、simulatorの版／設定／libraryの同一性、
`runner_sha256`の一致、`runner_changed`がfalseであることを確認します。互換でない記録を合算しません。
Git対象外のファイルなので別hostにはない場合があり、許可された設定と版管理するrunnerで再測定します。
[記録の集約](results.ja.md#記録の合算)も参照してください。

## 継続goalと完了監査

ユーザーは、M1〜M4の未対応が0件になるまで続けるgoalを依頼しました。有効化時点は未評価番号1,463件、未対応テスト0件、直接テストのない要求0件です。
5反復で未評価番号1,343件となり120件減りました。register-global 29番号、command-line 21番号、sequence 12番号、register連携36番号、
translation／callback／HDL parameter 22番号を個別に分解／分類しました。turnをまたいでgoalを有効に保ち、
未評価番号0を部分分解した義務や明示milestone目標の完了へ置き換えません。最終監査は元の範囲を規格、有意な検査条件、互換な実行evidenceで確認し、
未解決の解釈、API欠落、guest未測定を保持します。pass化や架空の承認を行わず、日英資料を維持して検証した追加をmainへ反映します。
goal本体の状態は会話が管理し、この記録はgoalを置き換えない引継ぎです。

## 残作業と優先候補

次の候補は優先順位の提案で、承認済みの除外やカバレッジ率ではありません。
追加作業を選ぶ前に、backlogを再生成してください。

既存テストの対応付けqueueは、すべてのrootで空です。未評価の識別子1,343件を規格と照合し、
見出しと規範的義務を区別して条件を分解し、新たなテストを選びます。
一部分解済みの領域でも、有意なdefault、失敗、独立性、順序、lifecycleの組合せを優先します。
oracleを導く前に、API欠落とsignature／本文の矛盾を確認します。

次の候補はreport resetとfilterの相互作用、activeなlock／grab所有とrelevance、sequence-library mode実行とunbound適用可否、adapterの片方向lane／byte順の独立した義務、parent-sequence条件です。catcher API欠落とpartial-byte有効bitの逆再構築も別のレビュー作業として残ります。
parent_sequence条項はdo_cloneを指定しているため、objectのclone APIと同じ意味と仮定する前に記述を確認します。
未解決の義務はbacklogに残します。

register連携の候補は、callbackのresize／無効化とoperation失敗条件、広いtranslation beat、独立した片方向payload検査、実際のforce／release対応です。
task-based read境界とcallback値pipelineには選択した検査系ができましたが、その存在だけで広い適用条件や保持する伝播4差分は解消しません。
診断severityの期待値を導く前に、印刷されたwrite宣言の矛盾と待機predictor検査の契約を確認します。

現在の要求案には、直接テストの未対応はありません。memory-walkの限定した歴史的解釈を含め、
直接対応のqueueを解消しますが、M1〜M4の完了ではありません。その解釈と残る識別子1,343件を照合し、
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
