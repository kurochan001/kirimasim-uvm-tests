# 開発ハンドオフ

[English](handoff.md) · [README](../README.ja.md) · [要求台帳](requirements.ja.md)

現在の引継ぎ：ユーザーが2026-11-07にgoalを再開し、外部レビューの7番目の項目である124回目の拡充を公開しました。8番目で最後の項目である125回目も、22のdirectoryすべてで公開しました。公開済みcheckpoint・次の案・再開手順は[Claude Code向けハンドオフ](claude-code-handoff.ja.md)から確認してください。

このページは開発の再開を支える資料なので、最初のテストを動かしたり理解したりしたい場合は[読み方ガイド](reading-guide.ja.md)から始めてください。

## 引継ぎ時点と目的

以下の基点コミットは記載した作業の出発点を示すため、保存済みの結果を現在のファイルの証拠にする前に未コミットの変更を確認し、互換性のレビューは[入力の更新手順](requirements.ja.md#テストや対応付けの更新)に従います。

2026-11-09に、`main`の[9601387](https://github.com/kurochan001/kirimasim-uvm-tests/commit/960138734ce23d521c36a645315044e070487cfa)
を基に、124回目の拡充へ更新しました。再開時に最新の公開commitと作業ツリーを確認してください。

IEEE 1800.2-2020のUVM適合を検査し、kirimasimを対象とするプロジェクトです。
SystemVerilog言語だけのreproducerは、
[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests)で扱います。
M1〜M4の薄い領域を引き続き補強します。M4は進行中で、未対応テスト0件は、どの段階の完了も意味しません。

| 領域 | 現在の状態 |
| --- | --- |
| M1 | 1188件（runtime 1107・elaboration 81）：core object、policy、reporting、階層、factory、phase、同期、recording、utility |
| M2 | 633件（runtime 626・elaboration 7）：sequence、sequencer、callback、TLM |
| M3 | 942件（runtime 931・elaboration 11）：register／memory layer、付録E |
| 全体 | 章・付録22 directoryに2763件（simulation 2664・elaboration 99）。照合はすべてAIで、人による照合は未記録 |
| M4 | AI要求案4151件。4151要求を2707テストへ直接対応。control専用56テスト。未対応テスト0件 |
| 規範的棚卸し | 2,507識別子のうち2062件を一部分解、445件を明示的に分類。0件は未評価。直接テストのない要求案0件 |

`scope_status`は提案、`normative_inventory_complete`はfalse、
`approved_denominator`／`coverage_percentage`はnullです。主引用テストがある22 rootすべてで未対応テスト0件ですが、
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
  [既知差分](known-differences.ja.md)：spec-only全470件。
- [要求ガイド](requirements.ja.md)、[範囲](../coverage/scope.json)、[台帳](../coverage/requirements.json)、[分類](../coverage/assessments.json)、
  [テスト索引](../coverage/test_index.json)：M4の正規の状態です。生成inventoryはレビューの補助資料で、
  版管理する入力の代わりではありません。
- [library lock](../third_party/uvm.lock)：Accellera UVM 2020.3.1、`78c06547a2a0`、326ファイル。
  版管理するtoolで取得し、library本体はコミットしません。2702検査系は`UVM_NO_DPI`を使い、38件は独自VPI HDL backendを明示要求します。
- ユーザーがrepository rootへ`IEEE_Std_1800.2-2020.pdf`と
  `IEEE_Std_1800-2023_SystemVerilog.pdf`を配置済みです。Git対象外のlocalファイルで、
  新規cloneにはなく、再配布しません。`out/`内の抽出済みtextはlocalでGit対象外です。`/tmp`は消える場合があります。
- `out/`の結果はGit対象外のlocal資料です。`out/thin-one-hundred-*-*.py`の一時helperは、
  あれば使える補助で、保守対象の入口ではありません。台帳／履歴へ追記するものがあり、無条件に再実行しません。
  不在なら版管理するtoolから必要な処理を組み立てます。

最初に動かす[スモークのコマンド](faq.ja.md#q3-まず1件だけ動かすにはどうしますか)は版管理した検査系と取得したライブラリを使い、ローカルPDFは規格の照合、Ghost設定はguest測定で使います。

## 再開と基本確認

作業ツリーに変更がある場合は未完の入力変更も含み得るため、保存済みの証拠を現在の結果として使う前に[入力と対応付けの更新手順](requirements.ja.md#テストや対応付けの更新)を確認してください。

以下の検証コマンドはツールと保守する入力を確認するもので、シミュレータのモデルを実行する検査との違いは[検査のガイド](testing.ja.md#検査)で確認できます。

Python 3.10以降を使います。Verilator実測は5.052固定で、C++ toolchain、make、path上のz3 solverが必要です。
repository rootで実行します。

```sh
git status --short --branch
python3 tools/fetch_uvm.py
python3 -m unittest discover -s tools -p 'test_*.py'
python3 tools/lint_metadata.py
python3 tools/requirements.py check
python3 tools/known_causes.py check
python3 tools/requirements.py inventory --json out/requirements-inventory.json
python3 tools/requirements.py backlog --json out/requirements-backlog.json --lang ja
```

この記録は、tool単体テスト140件、全2763件（simulation 2664件・elaboration 99件）のmetadata、台帳／索引、原因の記録、library整合性、現在の入力とevidenceの照合を
通過しています。資料だけの変更では、全シミュレーションを再buildせず、[ドキュメントの更新手順](testing.ja.md#ドキュメントの更新)に従って日英の対応とリンクを確認します。
全件evidenceはVerilatorだけで、他2系統は未変更1081件の記録、1682入力は未測定です。実行のsmoke確認は次のとおりです。

```sh
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 1 \
  --json out/verilator-smoke.json tests/u09/test_common_phases_run_in_order.sv
```

[以前のCheck実行](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/41561342697)は参照用です。
最新のworkflow結果はREADMEのbadgeで確認してください。後のcommitによって、このrunが置き換わる場合があります。
local検証だけでCI全体の成功とは扱いません。
Checkはtool、metadata、台帳、library、原因の記録と、入力が変わった通常oracle付きVerilator検査およびcanaryを検査します。Regressionは手動と毎週、全タグ付き通常検査、明示command-line 20件、regex-DPI変種26件を実行します。
どちらもGhost、kirimasim、spec-onlyの実行は含まず、結果の自動公開はありません。

## 実測記録と直近の差分

上のスモークのコマンドは手元でのケースごとの記録を保存し、このスナップショットと比較する前に中身を確認する方法は[結果JSONを開く](reading-guide.ja.md#結果jsonを開く)で説明しています。

以下の章別の3つの件数は部分分解・明示分類・未評価の順で、それぞれの状態は[root別の表](requirements.ja.md#レビュー用の未整理項目とroot別集計)で確認できます。

同じテストが通常条件とbackend条件の両方で測定される場合があり、合計を比較する前に[測定範囲](results.ja.md#現在のスナップショット)で行同士の重複を確認してください。

| シミュレータ／library | 記録した結果 |
| --- | --- |
| Verilator 5.052／固定UVM | runtime pass 2199件（seed 1／73）・期待compile拒否94件・known 463件 |
| Verilator 5.052／独自VPI HDL backend | 別条件の38件：37件が両seed pass、1件はseed 1でfail |
| Verilator 5.052／command-line VPI・固定regex DPI | 別条件の23件で20件は両seed一致、3件はseed 1の既知差分 |
| Verilator 5.052／regex DPIとcommand-line DPIで再実行する通常検査系 | 別条件の26件：すべて両seed pass |
| kirimasim／固定UVM | 未変更1081件で未対応1072件・API欠落fail 9件。1682入力は未測定 |
| Ghost／同梱UVM | 未変更1081件で各seed pass 206件・fail 875件。1682入力は未測定 |
| Ghost／固定UVM | 現在の実行ファイルsnapshotでは未測定 |

通常条件のknownは463件で、runtime初回差分318、simulation build 140、不正compiler受理5です。
buildはAPI／型名欠落43、time減算引数既定値1、型既定宣言2、依存visitor既定型3、印刷signature食違い2、継承type_id registry特殊化2、protected access 1、記載外pure-hook 2、DPI未link 61です。限定したvirtual抽象overview基底型のbuild 2件と、専用poolの印刷返却型build 2件も保持します。追加の合法build 3件はenum-collection T解釈です。ほか7 buildは厳密なattribute／enum-unpackの引数を保持します。印刷具象callback facadeの合法構築1件はabstractとして拒否されます。別HDL／command-line evidenceは独立に記録します。

残るsimulation build失敗6件は未登録packetのpredictor型名4件とサイズ／flag宣言2件で、規格に登録の前提条件を追加しない扱いと各実行条件は[結果の内訳](results.ja.md#結果の解釈)で説明しています。

125回目は、ユーザーが承認したとおりに8番目の項目である読みやすさを実装します。directoryごとに、helperを1行1文に整え、各テストに何を確かめるかと期待値をどの条項からどう導いたかのコメントを足し、動作は変えません。最初に基盤を用意します。`tools/code_identity.py`は編集がcodeを保つことを示して指紋を持ち越し、guestの記録はこの規則で持ち越し（G1）、手動のRegressionはdirectoryに絞れます。各directoryはVerilatorのseed 1／73で測り直し、絞ったRegressionで確かめてから次へ進みます。

読みやすさの進み具合：22のdirectoryのうち22つを終えました（u17（11入力）、u11（20入力）、uG（23入力）、uD（28入力）、u07（35入力）、u01（38入力）、u13（58入力）、u09（63入力）、u06（68入力）、u08（69入力）、uC（72入力）、uE（88入力）、u05（100入力）、u15（125入力）、u10（144入力）、u14（147入力）、u19（170入力）、u16（188入力）、u12（205入力）、uF（214入力）、uB（241入力）、u18（652入力））。終えたdirectoryの入力と、そのfileを集める他のdirectoryの入力は、seed 1／73で測り直してすべての状態が変わらず、指紋は`tools/code_identity.py`で持ち越し、guestの記録も持ち越しました。絞ったRegressionは、u17は[run 42619611363](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42619611363)でtag付き検査6件が一致、u11は[run 42663897873](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42663897873)で成功、uGは[run 42677380895](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42677380895)で成功、uDは[run 42686227804](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42686227804)で成功（11 directoryをまとめた1回のrun）、u07は[run 42686227804](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42686227804)で成功（11 directoryをまとめた1回のrun）、u01は[run 42686227804](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42686227804)で成功（11 directoryをまとめた1回のrun）、u13は[run 42686227804](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42686227804)で成功（11 directoryをまとめた1回のrun）、u09は[run 42686227804](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42686227804)で成功（11 directoryをまとめた1回のrun）、u06は[run 42686227804](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42686227804)で成功（11 directoryをまとめた1回のrun）、u08は[run 42686227804](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42686227804)で成功（11 directoryをまとめた1回のrun）、uCは[run 42686227804](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42686227804)で成功（11 directoryをまとめた1回のrun）、uEは[run 42686227804](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42686227804)で成功（11 directoryをまとめた1回のrun）、u05は[run 42686227804](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42686227804)で成功（11 directoryをまとめた1回のrun）、u15は[run 42686227804](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42686227804)で成功（11 directoryをまとめた1回のrun）、u10は[run 43024352324](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/43024352324)で成功、u14は[run 43055148276](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/43055148276)で成功、u19は[run 43076690673](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/43076690673)で成功、u16は[run 43099407618](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/43099407618)で成功、u12は[run 43119845864](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/43119845864)で成功（4 directoryをまとめた1回のrun）、uFは[run 43119845864](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/43119845864)で成功（4 directoryをまとめた1回のrun）、uBは[run 43119845864](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/43119845864)で成功（4 directoryをまとめた1回のrun）、u18は[run 43119845864](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/43119845864)で成功（4 directoryをまとめた1回のrun）です。残るdirectoryはありません。

項目8は完了しました。すべてのテストにコメントがあり、helperは1行1文です。例外は`` `__LINE__ ``を使うため行の配置を保った`tests/uB/helpers81/report_macros81.svh`だけです。前後の件数と2回のCI障害は[履歴](history.ja.md#125回目の拡充読みやすさ外部レビューの項目8)に記録しています。

124回目は、7番目の項目であるkirimasimの立ち上げ段階を実装します。各テストは`coverage/kirimasim_stages.json`に、テスト自身のsourceのmarkerで決まる0〜6の段階を持ち、各段階にはtag付きの代表の短いセットがあり、`tools/kirimasim_stages.py short`がkirimasimのrunnerに渡せる形で出力します。Checkは`tools/kirimasim_stages.py check`を実行します。新しい段階0の入力[`tests/u01/test_uvm_pkg_import_only_reaches_package_items.sv`](../tests/u01/test_uvm_pkg_import_only_reaches_package_items.sv)は、tag付けの前後でseed 1／73が一致しました。[段階のガイド](kirimasim-stages.ja.md)は各段階のSystemVerilogの機能をkirimasim-testsに対応付けます。段階5のTLMのimpが必要とする、型parameterを型とするhandleを通したmethodの呼出しを行う実行テストは、kirimasim-testsにありません。

123回目は、6番目の項目の3番目で最後のbatchです。保存したseed 1の出力の違う行をすべて確かめて、残るruntime差分264件（u05、u12、u14〜u16、u18、u19、uB、uC、uE、uF）を分類し、DPIの実行条件の下でも違いが残る4件は、それぞれのrunnerで実行して全出力を保存してから分類しました。library 214件、interpretation 41件、simulator 13件と、UVMを使わない再現例6つを加えました。記録は完成し、library 319、interpretation 60、simulator 27、condition 57、未分類0で、kirimasimの目標は測れる2384、固定版libraryのために期待値に届かない379です。テスト、期待値、保存した記録、義務はどれも変わりません。

122回目は、6番目の項目の2番目のbatchです。seed 1で診断用に実行して全出力を`out/`に保存し、runtime差分54件（u01、u06〜u11、u13、uD、uGのすべてと、uCとuEの3件ずつ）を分類しました。6件はsimulatorが原因で、UVMを使わない再現例を3つ加えました。kill()がforkした子processを動かし続ける例（phaseの終了の4入力）と、classのmemberのeventで起動が失われる2つの形（各1入力）です。39件はlibrary、9件はinterpretationです。合計はlibrary 105、interpretation 19、simulator 14、condition 57、未分類268で、kirimasimの目標は測れる2370、固定版libraryのために期待値に届かない124です。テスト、期待値、記録、義務はどれも変わりません。

121回目は、外部レビューの6番目の項目の最初のbatchです。ユーザーが案を承認し、libraryの出力値は記録しない（A1）と決めました。[原因の記録](../coverage/known_causes.json)は既知の463入力それぞれに1件ずつ、種別、DPIの実行条件、原因、根拠、説明を持ちます。`tools/known_causes.py`は、記録をテストと入力の指紋に照らして検査し、kirimasimの目標件数をまとめ、人による照合の候補を一覧にします。Checkはこの検査を実行し、simulatorが原因のものの再現例3つをbuildし直します。build 140件と不正designの受理5件を分類し、原因はlibrary 66件、interpretation 10件、simulator 8件、DPIの実行条件57件です。runtime差分318件と、DPIの実行条件の下でも違いが残る4件は未分類で、directoryごとに診断します。[既知差分の原因](known-differences.ja.md#既知差分の原因)を参照してください。テスト、期待値、記録、義務はどれも変わりません。

124回目は、外部レビューの7番目の項目であるkirimasimの立ち上げ段階を扱います。[`coverage/kirimasim_stages.json`](../coverage/kirimasim_stages.json)は、テスト自身のsourceにあるUVMの各部分のmarkerから、各テストに0（uvm_pkgだけ）から6（register層）までの段階を割り当て、段階ごとに代表の短いセットを持ちます。
`tools/kirimasim_stages.py`がCheckでこれを検査し、kirimasimのrunnerに渡す短いセットを出力します。段階ごとのテストは1、1030、95、111、326、250、950件で、kirimasimの現在の記録はどの段階でも同じ`uvm_object_wrapper`のunsupportedで止まっています。
規則、短いセット、各段階で必要なSystemVerilogの機能とkirimasim-testsのテストとの対応は[段階のガイド](kirimasim-stages.ja.md)で説明しています。テストのheaderは変えないため、入力の指紋は変わりません。

u01の新しい段階0の入力1件は、uvm_pkgをimportし、UVM_LOWをimportとpackage名の両方から名指しするだけで、UVM objectを作らず、run_testも呼びません。最初の凍結のまま、tag付けの前後でseed 1／73が一致し、新しい義務1件で扱います。
AI義務は4151件で、旧要求4150件と分類445件はすべて同一です。直接対応は2707テスト、control対応は158テスト、controlのみは56テストです。元の通常2755記録と旧既知463入力は全て維持します。新しい入力はM1に数えます。

全体は2763テスト（simulation 2664／elaboration 99）です。通常一致は2293件で、runtime両seed 2199入力とcompiler拒否94件です。
既知は463入力で、runtime seed 1差分318件、simulation build 140件、runtimeのない不正design受理5件です。specのみは4値の7入力を含めて470件です。
command-line条件は23検査系（pass 20、known 3）、regex-DPI変種の条件は26件（すべてpass）のままで、どちらも通常の総数へ加算しません。guestの再実行／filterは追加せず、互換1081記録をbyte単位で保持し、未測定は1682入力です。
追加1678件と修正した元入力4件で、simulation 1583／elaboration 99です。

主引用がある番号は1320で、candidateは0件1167／目標未満764／2件以上551です。
部分2062番号、実際に残る条件、元の段階目標、人の照合、範囲／分母承認は未完で、条件の一致で完了にならない理由は[進捗のガイド](reading-guide.ja.md#対応状況と進捗を読む)で説明しています。

全2763件（simulation 2664／elaboration 99）、M1 1188（1107／81）、M2 633（626／7）、M3 942（931／11）です。
通常passは2293（runtime 2199／拒否94）、knownは463（runtime 318／build 140／不正受理5）です。
guestは互換1081記録を保持し、未測定1682入力は追加1678件と修正した元入力4件です。

以前の単一Checkは、2026-10-31より後に全選択を完了していません。新しいpushで置き換えられなかった唯一の[実行](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42121591333)では、8 shardすべてが150分の上限に達しました。
現在のCheckは入力が変わったタグ付き検査とcanaryを実行し、[Regression](../.github/workflows/regression.yml)は全タグ付き2293検査を重複しない20 shardで、command-line 20検査、regex-DPI変種26件と合わせて実行します。上限は[CIの節](results.ja.md#継続的インテグレーション)で説明しています。
seed 1／73、compiler拒否の判定規則、固定依存関係、runner指紋は未変更です。Checkがcanaryだけと報告した変更の後はRegressionを手動実行し、現在のcommitの結果を確認します。local検証でhosted workflowの成功は立証しません。
最初の起動でhostedのimageに制約solverがないことが分かり、取り消したrunと修正は[CIの節](results.ja.md#継続的インテグレーション)に記録しています。修正後のdb06513でのRegression run 42372122368は、タグ付き検査とcommand-line検査がすべて一致しました。

集約した記録は、過去の未変更入力を保持し、再測定した記録だけを置換します。1回の呼出しで全件を再実行したものではありません。
現在のhostでは、互換なlocal記録は次にあります。

```text
out/thin-one-hundred-twenty-fifth-uG-verilator-combined.json
out/thin-one-hundred-twenty-fifth-uG-ghost-1.json
out/thin-one-hundred-twenty-fifth-uG-ghost-73.json
out/thin-one-hundred-twenty-fifth-uG-kirimasim.json
out/thin-one-hundred-twenty-fourth-inventory.json
out/thin-one-hundred-twenty-fourth-backlog.json
out/thin-one-hundred-twenty-fifth-uG-evidence-scope.json
out/thin-one-hundred-twenty-fifth-uE-hdl-combined.json
out/thin-one-hundred-twenty-fifth-uG-cmdline-combined.json
```

再利用前に、宣言した全件／部分の対象ごとのtest ID集合の完全一致、現在の`inputs_sha256`、simulatorの版／設定／libraryの同一性、
`runner_sha256`の一致、`runner_changed`がfalseであることを確認します。互換でない記録を合算しません。
Git対象外のファイルなので別hostにはない場合があり、許可された設定と版管理するrunnerで再測定します。
[記録の集約](results.ja.md#記録の合算)も参照してください。

以前のfield-configuration filterは互換1083記録を1082へ絞りました。その後のreraise主引用のfilterで1082件から1081件へ減りました。今回は新たなfilterやguest再実行をせず、その記録を保持します。[入力同一性の説明](faq.ja.md#q408-引用の修正でguestの結果が改善したり条項coverageを証明したりしますか)と[証拠の合算](results.ja.md#記録の合算)で両段階を区別します。

## 継続goalと完了監査

完了監査では残る義務と条件を元のM1〜M4目標に照らして確認し、生成した3つのqueueを空にすることが途中の確認にとどまる理由は[Q390](faq.ja.md#q390-未評価の識別子0件なら残作業も0件ですか)で説明しています。

未評価件数と部分的な義務は別の残作業を数えるため、件数が減るだけではgoalを完了できない理由は[対応状況と進捗を読む](reading-guide.ja.md#対応状況と進捗を読む)を参照してください。

ユーザーはM1〜M4の未対応0件まで続けるgoalを依頼しました。開始時は未評価1,463番号、未対応テスト0件、直接テストのない要求0件でした。
96反復目も未評価0を保持し、有効化以降の減少は1463です。ユーザーは2026-11-07に一時停止中のgoalを再開しました。113〜115反復目はCIを分割し、hostedのrunnerにないz3 solverを導入し、M3のmemory manager入力12件を追加しました。2026-11-08にユーザーは8項目の外部レビューを示し、116〜118反復目はRTL結合、4値、乱数化の性質の入力を追加し、119反復目はregex-DPI変種の条件と正規表現の5検査系を追加し、120反復目は両seedで一致するユーザーpackageの入力5件を追加し、121〜123反復目は既知差分の原因を3つのbatchで義務を変えずに記録し、124反復目はkirimasimの立ち上げ段階と、両seedで一致する段階0の入力1件を追加します。新規義務1件で4151義務となり、旧要求4150件はすべて同一です。元の通常2755記録、旧既知463入力、分類445件を保持します。guestは互換1081／未測定1682入力です。部分2062番号、適用条件、元の段階目標、人の照合、範囲／分母承認は未完で、goalは完了していません。

以前の12.2.9.2の再分類は未評価件数を減らしません。最終監査の前にgoalを完了扱いにせず、第12章の未評価0を部分分解169番号や明示milestone目標の完了へ置き換えません。
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
第18章の未評価は0ですが、部分393番号とmap／register-fileの適用条件は未完了です。
clone提供／source保持には直接観測ができましたが、新map内容／rightsと印刷scalar／map返却の食違いは未完了です。handle返却／登録契約を作って隠さないでください。
有効幅、限定word単位、単一mapのnull既定値、lock前field名の差分を保持します。register frontdoor／backdoor、coverage、field／memory宣言、adapter／predictor callback、寿命／並行アクセス条件を続けます。

次の候補は優先順位の提案で、承認済みの除外やカバレッジ率ではありません。
追加作業を選ぶ前に、backlogを再生成してください。

対応付けと未評価のqueueは全rootで空です。部分分解2062識別子を規格と照合し、
見出しと規範的義務を区別して残る適用条件を分解してから、新たなテストを選びます。
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
付録Bは未評価0で、部分135番号とB.4の未解決のcallback基底の記述を照合し、reporting、utility、field、I/O、TLM macroの全ての部分義務も継続します。

resourceの続き：付録Cの全部分71番号を監査し、recent-set sort解釈、空／重複／null queue、照合方言／backend別条件、
virtual regex／scope宣言、欠落typed-DB最大値helperを扱います。最初の最大値の同順位規則とrecent-set sort順を分け、
全precedence／lookup_type矛盾、既存のwarning欠落と記載外pure-hook buildを保持します。
選択alias、component get、interface handleで全型、自動configuration、並行履歴は認定しません。Cの未評価番号はなく、契約は部分的に残ります。

packageの次作業は、[現在のroot別集計](requirements.ja.md#レビュー用の未整理項目とroot別集計)を使い、付録Fの部分112番号に残る型、global service、callback変更、初期化、run／abort義務を監査することです。
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

memory／special-registerの次作業：第18章の未評価は0ですが部分393番号が残ります。18.6〜18.8は未評価0でも部分的に残ります。
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
printer 16.2節は16.2.10 table-format概要を限定した短rowの解釈で部分分解し、観測を未記載の普遍的な列／行構文へ置き換えません。第16章は未評価0でも部分176番号が残り、導入16は個別に文脈と分類し、recorder-link概要は部分分解のままです。
既定format意味、再帰履歴key、depth境界、循環graph、scope separator、4-state値、全radix／設定組合せ、caller所有を監査します。
限定したentry-depth matrixと、独立した上限超過済みの不一致は別々に保持します。

policy差し替えの監査は選択A／B／A scalar入力の先へ続け、入れ子object、alias、field操作によるhook無効化、追加設定の組合せ、同じrecorderの反復履歴を規格から確認します。章導入はこれらの部分義務へ対応する文脈であり、全組合せの認定ではありません。

次の候補はreport resetとfilterの相互作用、activeなlock／grab所有とrelevance、sequence-library mode実行とunbound適用可否、adapterの片方向lane／byte順の独立した義務、parent-sequence条件です。catcher API欠落とpartial-byte有効bitの逆再構築も別のレビュー作業として残ります。
parent_sequence条項はdo_cloneを指定しているため、objectのclone APIと同じ意味と仮定する前に記述を確認します。
未解決の義務はbacklogに残します。

memory-managerではallocation／locality enumと設定memberの意味、人が読める状態、region生成／所有概要が残ります。
代入だけからGREEDY／THRIFTYやBROAD／NEARBYの動作を認定せず、部分条件、再設定制約、実backend転送を監査します。
burst-write offsetとburst-read output／refの食違いは選択委譲観測と分けて保持します。
古いdescriptorは、一括解放、region経由の解放、request_regionで得たdescriptorの解放、virtual registerの解放の後の再解放errorに直接検査ができました。virtual register配列を実装中のregionのmanagerからの解放と、範囲を再び予約した状態の呼出しは残ります。reconfigure後の範囲には予約、要求、policyの範囲の直接検査ができましたが、範囲と同時のmode／localityの変更、他のbyte幅、非互換なreconfigureは残ります。RTLとの結合には直接のprofileが5件できましたが、他のprotocol、clock domain、byte enable、error応答、残りのレビュー項目は残ります。4値の経路にはVerilatorの記録のないspecのみのprofileが7件でき、規定のない経路はテストのガイドに一覧しています。macroによる乱数化には性質のprofileが5件できましたが、乱数分布の品質と乱数化に失敗した後の動作は残ります。正規表現にはregex-DPI変種の条件とcommand-lineのprofile 5件ができましたが、正規表現とHDL DPIの組合せなど、他のDPIに依存する動作は残ります。ユーザーpackageにはfactoryのprofile 5件ができましたが、compilation unitやlibraryの分割、package水準のparameter付きclassは残ります。

register連携の候補は、callbackのresize／無効化とoperation失敗条件、広いtranslation beat、独立した片方向payload検査、広いforce／release型と時間付きwrapperの相互作用です。
task-based read境界とcallback値pipelineには選択した検査系ができましたが、その存在だけで広い適用条件や保持する伝播4差分は解消しません。
診断severityの期待値を導く前に、印刷されたwrite宣言の矛盾と待機predictor検査の契約を確認します。

現在の要求案には、直接テストの未対応はありません。memory-walkの限定した歴史的解釈を含め、
直接対応のqueueを解消しますが、M1〜M4の完了ではありません。その解釈と残る部分義務を照合し、
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

`--root`はM1〜M4の段階やテストdirectoryではなく規格の章・付録を選ぶ値で、絞った表示でも台帳全体を先に検証する理由は[backlogのガイド](requirements.ja.md#レビュー用の未整理項目とroot別集計)で確認できます。

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

以下の文面は記録済みの基準状態を伝える例なので、作業ツリーに未完の変更があれば併せて伝え、手元の状態を先に確認する方法は[再開時の確認](#再開と基本確認)を参照してください。

> READMEと日英のハンドオフを読み、作業ツリーと最新Checkを確認して、要求backlogを再生成してください。
> ユーザーが配置したIEEE規格を使い、M1〜M4の薄い領域の補強を続けてください。
> 未評価の規範的義務とmemory-walk解釈の照合を優先候補にし、M1〜M3でも意味のある新しい動作を追加してください。
> 規格に基づく期待値、商用結果の除外、Ghostの非公開性、AI照合状態、完全な日英文書を維持してください。
> 最終入力を測定し、有効なspec-only差分を残して、完了した変更・検証・残る制約を報告してください。
