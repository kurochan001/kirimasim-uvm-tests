# Claude Codeへのハンドオフ

[English](claude-code-handoff.md) · [README](../README.ja.md) · [詳細ハンドオフ](handoff.ja.md)

## 最初に読むこと

2026-11-07に更新しました。Claude Codeのsessionが前回のハンドオフを引き継ぎ、ユーザーはM1〜M4の継続goalの再開、CIの先行修正、mainへの公開を承認しました。このsessionは[a897c68](https://github.com/kurochan001/kirimasim-uvm-tests/commit/a897c6820b037b8fddecfbf7c72c7997bcd075f4)と[42d03ab](https://github.com/kurochan001/kirimasim-uvm-tests/commit/42d03abae20701f344697d13bdca83043c3710f1)でCIを分割し、[f94ba4a](https://github.com/kurochan001/kirimasim-uvm-tests/commit/f94ba4ab94a67d5e9eeb2fcaf7e19a57b4596cc4)で113回目の拡充を公開しました。その後、最初のRegressionでhostedのrunnerにz3制約solverがないことが分かり、準備用actionで導入して、[db06513](https://github.com/kurochan001/kirimasim-uvm-tests/commit/db06513ce8c467d7a2e87e972beae496ff73c828)で114回目の拡充を公開しました。その後、[eeda25d](https://github.com/kurochan001/kirimasim-uvm-tests/commit/eeda25d9b378773a2841076706f8e8029d87c08d)で115回目の拡充を公開しました。2026-11-08にユーザーは外部レビューを示し、その最初の項目であるRTLとの結合を、[c314982](https://github.com/kurochan001/kirimasim-uvm-tests/commit/c314982e5c42e5333790b7ba7bb00bbaef8da2f7)で116回目の拡充として公開し、2番目の項目である4値の経路を[46e8106](https://github.com/kurochan001/kirimasim-uvm-tests/commit/46e81064f9d1a89764027b7ec8b02b7cdc0ce624)で117回目の拡充として公開し、3番目の項目である乱数化の性質を[8e056d1](https://github.com/kurochan001/kirimasim-uvm-tests/commit/8e056d11f8c9671dfe0197cf888e74fdb8e79bb8)で118回目の拡充として公開し、4番目の項目であるDPIの構成を[4a9f9e4](https://github.com/kurochan001/kirimasim-uvm-tests/commit/4a9f9e4d026a8c58a48c16447f8e43071d9ab047)で119回目の拡充として公開し、5番目の項目であるユーザーpackageを[9c57290](https://github.com/kurochan001/kirimasim-uvm-tests/commit/9c572904a247a92a4445c0d9bfe7b1208eeb975a)で120回目の拡充として公開し、6番目の項目である既知差分の原因の最初のbatchを[a578650](https://github.com/kurochan001/kirimasim-uvm-tests/commit/a5786504883a87b7928084098a7fada0a9f7efce)で121回目の拡充として、2番目のbatchを[e5bd032](https://github.com/kurochan001/kirimasim-uvm-tests/commit/e5bd032245789f643e9a45a65bbebd19b0a5efc0)で122回目の拡充として、3番目で最後のbatchを[9601387](https://github.com/kurochan001/kirimasim-uvm-tests/commit/960138734ce23d521c36a645315044e070487cfa)で123回目の拡充として公開し、7番目の項目であるkirimasimの立ち上げ段階を[235713d](https://github.com/kurochan001/kirimasim-uvm-tests/commit/235713d30d9940a06c591850218db6caaaf67ca6)で124回目の拡充として公開しました。8番目の項目である読みやすさは125回目の拡充で、この文面を含むcommitの基盤の後に、directoryごとに公開します。**goalは継続中で、完了していません。**

編集前に実際のbranchと作業ツリーを確認してください。121〜123回目は期待値の測定を追加せず（122回目はruntimeの既知入力をseed 1で診断用に実行し、123回目はDPIの実行条件の既知入力4件をそれぞれのrunnerで実行しました）、124回目のnative測定（段階0の入力を、tag付けの前後にseed 1／73で実行）はすべて終了済みで、117回目の4値の入力にはnative測定がありません。

最初に現在のworkspaceの指示を読みます。ユーザーのagent向け指示は`RTK.md`を参照するため、現在の環境で解決してください。非公開設定やユーザーの絶対パスを公開ファイルへ記載しません。

## 完了したことと残ること

生成する3つのキュー、つまり未対応テスト・直接テストのない要求・未評価の条項識別子は0件です。**実際の残作業が0件とは実証されていません。** 棚卸し2507識別子のうち2062件は一部分解、445件は分類済みです。範囲は提案段階、完全性はfalse、承認済み分母とcoverage率はnullで、人のレビューは未記録です。元のM1〜M4目標と規範的義務の適用条件は未完で、これらの異なる指標は[要求ガイド](requirements.ja.md)で説明しています。

- テスト：22 directoryに2763件 = simulation 2664 + elaboration 99。M1：1188（1107/81）、M2：633（626/7）、M3：942（931/11）。うち7件はVerilatorの記録のない4値（`:fourstate: yes`）のspecのみ入力です。
- AI要求：4151件すべてを2707テストへ直接対応。control専用は56テストです。人のレビューは主張しません。
- 通常のpass入力：2293件 = seed 1/73でruntime一致2199 + 期待したcompiler rejection 94。
- 既知差分：463件 = runtime差分318 + simulation build失敗140 + 不正入力のcompile受理5。最初のseedの失敗から次のseedの結果を推測しません。specのみは4値の7入力を含めて470件です。[原因の記録](../coverage/known_causes.json)は既知差分を、すべて、library 319、interpretation 60、simulator 27、DPIの実行条件57に分類し、未分類はありません。
- 別の条件：command-line 23検査系（20件がseed 1／73で一致、3件は既知）、regex-DPI変種26件（すべて一致）。
- guest証拠：互換1081記録、未測定1682入力（追加1678 + 改訂した元入力4）。112〜124回目にguest測定はありません。以前の一時的な非公開executable／profileのsnapshotは失われているため、guest測定前に許可されたlocal設定を確保します。
- 候補の配置：primaryテスト0件が1167番号、1件が764番号、2件以上が551番号です。条項の網羅や独立した検査の成功を証明する件数ではありません。

HDL backend、command-line、regex-DPI変種の追加検査には別の実行条件があり、[実行結果](results.ja.md)と[テストガイド](testing.ja.md)を確認してください。範囲を確認せず通常の総数へ加算しません。

## CIの状態

hosted CIは2026-10-31以降、Verilatorの選択を一度も完了していませんでした。単一のCheckが`cancel-in-progress`付きでpushごとに全件を実行し、中断されなかった唯一の8 shard実行では全shardが150分の上限に達しました。置き換えた構成とsolverの修正は[CIの節](results.ja.md#継続的インテグレーション)で説明しています。

- [Check](../.github/workflows/check.yml)はtool・metadata・library・台帳・原因の記録・立ち上げ段階の検査と、入力が変わったタグ付き検査、canary 1件（[選択ツール](../tools/ci_select.py)）、原因の記録の再現例のbuildを実行します。42d03ab（[run 42359747127](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42359747127)、canaryのみ）とf94ba4a（[run 42360326889](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42360326889)、113回目の4入力とcanary）で成功しました。どちらの選択も乱数化を行いません。
- [Regression](../.github/workflows/regression.yml)は手動と毎週、全タグ付き検査を20 shard（同時4、各360分）で、command-line 20件とregex-DPI変種26件をそれぞれ別jobで合わせて実行します。最初の起動である42d03abの[run 42359747603](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42359747603)は、command-line job（成功）とshard 0・2・3（342件中334件一致）の完了後に取り消しました。8件の差分はすべて制約付き乱数化に依存し、imageのpathにSMT solverがありませんでした。localでz3を外すと、確かめた4件の差分を再現しました。このrunはどのcommitのRegression結果でもありません。
- [準備用action](../.github/actions/setup-verilator/action.yml)はすべてのjobでz3を導入し、その版を表示します。[db06513](https://github.com/kurochan001/kirimasim-uvm-tests/commit/db06513ce8c467d7a2e87e972beae496ff73c828)のCheck（[run 42371357208](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42371357208)）はz3 4.8.12を導入し、allocation policyを乱数化するrequest側の2 profileを含む選択5件が一致しました。
- Regressionはdb06513で[run 42372122368](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42372122368)として再度起動しました。20 shardでタグ付き検査2273件すべてがseed 1／73で一致し（各shard 113〜199分）、command-line jobも成功したため、その結果を確認してから115回目のcommitを公開しました。このrunの対象はdb06513で、115回目の4入力はCheckの変更入力jobとlocal測定で確認しています。116回目の入力はそのcommitのCheckとlocal測定で確認し、117回目の4値の入力はCheckもRegressionも選ばず、118回目の入力はそのcommitのCheckとlocal測定で確認しています。119回目のcommand-line検査系とregex-DPI変種はlocal測定で確認し、Checkはそれらに対してcanaryだけを実行し、次のRegressionがcommand-lineとregexのjobで確認します。120回目の入力はそのcommitのCheckとlocal測定で確認しています。121回目はテストの入力を変えません。項目4と5をhostedで確認するため、項目6の最初のbatchの後にRegressionを1回起動することにユーザーが同意し、a578650で[run 42528773645](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42528773645)として起動し、2026-11-10に23 jobすべて（タグ付き2292件の20 shard、command-lineとregex-DPIのjob、gate）が成功しました。項目8の途中で、uGに絞ったRegressionの2回（[42668720148](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42668720148)と[42673134200](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42673134200)）はGitHub Actionsの障害で失敗しましたが、テストの失敗はなく、起動し直した[42677380895](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42677380895)は成功しました。その後、ユーザーの依頼でuD〜u15をまとめて公開し、絞った1回のrun [42686227804](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42686227804)で確かめました。後で全件のhosted結果が必要になればRegressionを再度起動し、shardがtimeoutまたは失敗した場合は、テストを追加公開する前に調べます。
- 同時10で起動したrunは、アカウント共有のhosted job枠を埋めて他のrepositoryを遅らせたため以前に取り消しました。Regressionの同時実行数は控えめに保ち、全件実行を重ねて起動しません。

## 外部レビュー

2026-11-08にユーザーは、kirimasimが実際のUVM testbenchを動かせるかを測るためにスイートを補強する、優先順位付きの8項目からなる外部の静的レビューを示しました。事実確認では件数をおおむね確認しましたが、乱数化については、sequence libraryを使う36ファイル、pre／post_randomizeを使う52ファイル、inline制約付き`uvm_do`の7ファイルがすでにあり、`uvm_do_with`は1800.2-2020に含まれません（B.3.1.4は`CONSTRAINTS`引数を使います）。各項目は個別にcommitし、次の項目を公開する前にmainのCheckで確認します。

- 項目1（RTLとの結合）：下記の116回目で実装しました。
- 項目2（4値の経路）：下記の117回目で実装しました。
- 項目3（乱数化の性質）：下記の118回目で実装しました。
- 項目4（DPIの構成）：ユーザーが案（別のregex-DPI runnerと変種の一覧、metadataのfieldは追加しない）を承認した後、下記の119回目で実装しました。
- 項目5（ユーザーpackage）：形式を変えずに、下記の120回目で実装しました。
- 項目6（既知入力の原因分類）：ユーザーが案（別の追跡ファイル`coverage/known_causes.json`とCheckでの検査）を承認し、libraryの出力値は記録しないA1を選びました。下記の121回目が最初のbatch（build、不正designの受理、DPIの実行条件）で、122回目と123回目がruntime差分をdirectoryごとに分類し、記録は完成しました。
- 項目7（kirimasimの立ち上げ段階）：ユーザーが案（別の追跡ファイル`coverage/kirimasim_stages.json`とCheckでの検査、既存のrunnerに渡す短いセット、段階0の入力1件、日英の言語機能の表）を承認し、下記の124回目で実装しました。
- 項目8（読みやすさ）：ユーザーが案（directoryごとに進める。台帳の義務から書くコメント、番号付きのfamilyの変種の説明、helperの1行1文。指紋を持ち越しguestの記録も持ち越すcodeの同一性のtool（G1）。Regressionをdirectoryに絞る入力）を承認しました。125回目はその基盤から始めます。

## 維持する判断

- 独立した期待値はユーザー提供IEEE規格から導きます。Git対象外のlocal PDFは`IEEE_Std_1800.2-2020.pdf`と`IEEE_Std_1800-2023_SystemVerilog.pdf`で、新規cloneには含まれず、再配布しません。規格の本文・図・例をテストや資料へコピーしません。
- 商用シミュレータの結果・出力・診断を、匿名化や第三者経由を含めて利用しません。GPL／LGPLシミュレータの実装sourceを読みません。[出典方針](provenance.ja.md)と[投稿方針](faq.ja.md#商用シミュレータとissueの投稿方針)に従います。
- 固定したApache UVM sourceは、規格由来のoracleを凍結した後で差分の説明に使えますが、期待値を定義しません。有効なspec-only差分と限定した解釈を保持します。観測出力へ合わせるためだけに期待値を変更せず、tag付け前の改訂は明記して保管します。
- Ghostの実際の識別情報・版・executable／profileパス・profile内容・生の診断を非公開にします。PDF・取得したlibrary source・log・非公開設定・生成した一時ファイルをGitへ含めません。
- 完全な日英対を維持します。READMEは現状、[履歴](history.ja.md)は過去の追加を記録します。最近追加した読者向け説明とリンク、過去時点のFAQ、AI照合状態、既存証拠のidentityを保持します。
- `tools/run_verilator.py`、`tools/suite_results.py`、`tools/uvm_common.py`を安易に変更しません。これらはrunner指紋を構成し、変更すると保存済みの全記録が無効になります。`tools/ci_select.py`とworkflowのファイルは指紋の外にあります。

## 最新実装と限界

読みやすさの進み具合：22のdirectoryのうち22つを終えました（u17（11入力）、u11（20入力）、uG（23入力）、uD（28入力）、u07（35入力）、u01（38入力）、u13（58入力）、u09（63入力）、u06（68入力）、u08（69入力）、uC（72入力）、uE（88入力）、u05（100入力）、u15（125入力）、u10（144入力）、u14（147入力）、u19（170入力）、u16（188入力）、u12（205入力）、uF（214入力）、uB（241入力）、u18（652入力））。終えたdirectoryの入力と、そのfileを集める他のdirectoryの入力は、seed 1／73で測り直してすべての状態が変わらず、指紋は`tools/code_identity.py`で持ち越し、guestの記録も持ち越しました。絞ったRegressionは、u17は[run 42619611363](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42619611363)でtag付き検査6件が一致、u11は[run 42663897873](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42663897873)で成功、uGは[run 42677380895](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42677380895)で成功、uDは[run 42686227804](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42686227804)で成功（11 directoryをまとめた1回のrun）、u07は[run 42686227804](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42686227804)で成功（11 directoryをまとめた1回のrun）、u01は[run 42686227804](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42686227804)で成功（11 directoryをまとめた1回のrun）、u13は[run 42686227804](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42686227804)で成功（11 directoryをまとめた1回のrun）、u09は[run 42686227804](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42686227804)で成功（11 directoryをまとめた1回のrun）、u06は[run 42686227804](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42686227804)で成功（11 directoryをまとめた1回のrun）、u08は[run 42686227804](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42686227804)で成功（11 directoryをまとめた1回のrun）、uCは[run 42686227804](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42686227804)で成功（11 directoryをまとめた1回のrun）、uEは[run 42686227804](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42686227804)で成功（11 directoryをまとめた1回のrun）、u05は[run 42686227804](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42686227804)で成功（11 directoryをまとめた1回のrun）、u15は[run 42686227804](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42686227804)で成功（11 directoryをまとめた1回のrun）です。残るdirectoryはありません。

124回目では、ユーザーが承認したとおりに項目7を実装しました。[段階の記録](../coverage/kirimasim_stages.json)は各テストに立ち上げ段階を与えます。段階は0（uvm_pkgだけ）、1（最小のrun_test）、2（factory）、3（config_db）、4（sequence）、5（TLM）、6（register層）で、テストと、テストが`tests/`の下から集めるfileを、commentとstringを除いて調べ、markerが一致する最も高い段階、どれも一致しなければ段階1になります。英語と日本語の理由を付けたoverrideが、新しい入力1件[`tests/u01/test_uvm_pkg_import_only_reaches_package_items.sv`](../tests/u01/test_uvm_pkg_import_only_reaches_package_items.sv)を段階0にします。この入力はuvm_pkgをimportし、UVM_LOWをimportとpackage名の両方から名指しし（1.4.5、F.2.2.4）、tag付けの前後でseed 1／73が一致しました。義務`UVM-PACKAGE-IMPORT-ONLY-STAGE0`の1件で扱います。段階ごとのテストは1、1030、95、111、326、250、950件です。各段階はtag付きの実行テストの短いセット（計31件）を持ち、`tools/kirimasim_stages.py short`が`tools/run_kirimasim.py`に渡せる形で出力し、`summary --results`はrunnerのJSONを段階ごとに数えます。kirimasimの現在の記録1081件は、どの段階でも同じ`uvm_object_wrapper`で止まっています。[段階のガイド](kirimasim-stages.ja.md)は各段階のSystemVerilogの機能を、固定版libraryの使用箇所と、`829671c2`のkirimasim-testsに対応付けます。TLMのimpが必要とする、型parameterを型とするhandleを通したmethodの呼出しを行う実行テストは、kirimasim-testsにありません。テストのheaderは変えないため入力の指紋は変わらず、単体テストを16件加えました。

123回目は項目6の3番目で最後のbatchです。保存したseed 1の出力の違う行をすべて確かめて、残るruntime差分264件（u05、u12、u14〜u16、u18、u19、uB、uC、uE、uF）を分類しました。DPIの実行条件の下でも違いが残る4件は、それぞれのrunnerで実行して全出力を`out/thin-one-hundred-twenty-third-diag-cond/`に保存してから分類し、4件とも原因はlibraryです。library 214件、interpretation 41件、simulator 13件を加えました。自分で結果を確かめる新しい再現例6つは、Verilatorが、2つのpackageの同じ名前のparameter付きclassの間の$castを通すこと、eventで待っているprocessをそのeventへの代入で解放すること、$finishの後に呼出し元を再開すること、classも大きさを制約するとinlineのqueueの大きさの制約を無視すること、packageの基底classが禁じる大きさを受け入れること、乱数化が失敗した後にpost_randomizeを呼ぶことを示します。nullのmapを渡すget_local_mapの入力は、DEVIATIONS.mdの2番目に当たります。記録のstatusはcompleteで、library 319、interpretation 60、simulator 27、condition 57、未分類0です。kirimasimの目標は測れる2384、固定版libraryのために届かない379で、人による照合の候補は406件です。

122回目は項目6の2番目のbatchです。runtimeの既知入力をseed 1で診断用に実行し、全出力とUT行の差分を`out/thin-one-hundred-twenty-first-diag/`に保存します。このbatchの入力はすべて済んでいるので、最初の行だけでなく違う行をすべて確かめています。runtime差分54件（u01、u06〜u11、u13、uD、uGのすべてと、uCとuEの3件ずつ）を分類し、library 39、interpretation 9、simulator 6です。新しい再現例は、Verilatorのkill()がforkした子processを動かし続けること（固定版のhopperは9.7のとおりphaseのprocessをkillします）と、classのmemberのeventの2つの形で起動が失われることを示し、自分で結果を確かめて$fatalを呼びます。apply_config_settingsの既定のmodeの2入力は、DEVIATIONS.mdの3番目に当たります。DPIの実行条件を選ばずにDPIを必要とする通常の検査系3件（command line 2、regex 1）は、UVM_NO_DPIの構成でのlibraryの原因として数えます。uCのprecedenceと検索の警告の3入力と、uEの除外の残り3入力は、さらに読む必要があるため未分類のままです。

121回目は、ユーザーが承認したとおりの項目6の最初のbatchです（A1：libraryの出力値は記録しない）。[原因の記録](../coverage/known_causes.json)は既知の入力それぞれに1件ずつ、種別（runtime、build、accepted-illegal）、DPIの実行条件、原因（library、interpretation、simulator、condition、unassigned）、根拠、日英の説明を持ち、reviewは`ai`です。libraryの根拠は引用した条項と固定版libraryのファイルと文字列を、interpretationの根拠は条項と2つの読み方（最初がテストの読み方）を挙げ、simulatorの根拠はUVMを使わない3つの再現例のいずれかを名指しします。再現例はCheckで`tools/known_causes.py reproduce`がbuildし直します。固定版libraryのsourceは凍結後のこの診断のためだけに読み、Verilatorのsourceは読んでいません。buildと不正designの受理の145件を分類し（library 66、interpretation 10、simulator 8、condition 57。DPIの実行条件の下でも違いが残る4件は未分類）、runtime差分318件は未分類のままです。`summary`はkirimasimの目標件数（測れる2364、固定版libraryのために期待値に届かない76、未分類322）を、`candidates`は照合の候補84件を示します。[既知差分の原因](known-differences.ja.md#既知差分の原因)を参照してください。詳細ハンドオフのbuildの内訳はDPI未linkを56件としていましたが、正しくは61件です。

120回目では、形式を変えずに項目5を実装しました。`tests/u08/helpers120_pkg/`の独自の4 package（agent、sequence、environment、extension）を、依存の順に並べた別々の`:files:`からcompileし、agentとsequenceのpackageはextensionのpackageをimportしません。u08とu15の5 profileは、どのcodeも名指ししない型のfactoryへの静的登録（run_testの前に問い合わせる）、名前による生成、packageで宣言したtest classのrun_test、type_id::createがpackageを越えて作る階層、type_idで設定する型と相対instanceのoverride、名前による生成と組み合わせた名前による型override、別のpackageのdefault sequenceのwrapperを一方のsequencerだけinstance overrideで置き換えることを検査します。5件とも最初の凍結のまま、tag付けの前後でseed 1／73が一致しました。8.3.1.4は名前によるoverrideを同じ文字列を使うcreate_*呼出しに結び付けるため、名前によるoverrideは名前による生成だけで確かめます。`UVM-USER-PACKAGE-*`の義務を9件追加しました（`UVM-PKG-*`はすでにuvm_pkgの列挙型の義務を指します）。[packageのFAQ](faq.ja.md#q442-ユーザーpackageのprofileは何を検査しますか)を参照してください。要求の表の15と18の行は116回目の義務を1件ずつ数え漏らしていたので訂正し、localの119回目のevidence scopeのbuild件数も135から140へ訂正しました。

119回目では、ユーザーが承認した形で項目4を実装しました。[regex-DPI runner](../tools/run_verilator_regex.py)は別の条件（`verilator_regex`）で、`coverage/regex_dpi_variants.txt`に一覧した2値の検査系をUVM_NO_DPIなしでbuildし直します。UVM_HDL_NO_DPIを定義し、固定版のregex wrapperと独自のcommand-line VPI bridgeをlinkします。検査系、期待ファイル、保存済みの記録は変えません。UVM_CMDLINE_NO_DPIを使った最初の構成では+UVM_TESTNAMEが届かなかった（RTLの5 profileでNOCOMP）ため、bridgeを有効にしています。一覧の26件はすべてseed 1／73で一致し、Regressionは`regex` jobで実行します。gateはcommand-line、regex、shardの各jobを要求します。command-line条件の新しいspecのみの5検査系は、F.3.3.1の表記、configurationとresourceの検索での正規表現とplusのscope（C.4.2.2.1、C.2.4.3）、component検索（F.7.4.1）、get_arg_matches（G.1.3.4）を検査します。3件は両seedで一致してtag付けし、2件はそれぞれ1行が既知差分のままです。oracleの凍結後にだけ読んだ固定版libraryのsourceが原因を説明します（`uvm_re_deglobbed`はslashのないcaretとdollar記号をanchorとして残し、既定の設定検索はfield名を完全一致で探します）。`UVM-REGEX-*`の義務を8件追加しました。[DPIのFAQ](faq.ja.md#q440-regex-dpi変種とprofileは何を検査しますか)と[正規表現の照合](known-differences.ja.md#正規表現の照合)を参照してください。

118回目ではuBに乱数化の性質profile 5件を追加し、`tests/uB/helpers118_rand/rand118.svh`（event log、driver、test base）を共有します。uvm_createの後のconstraint_mode、24個のuvm_do itemでのinline制約・1回だけの乱数化・start／乱数化／finishの順序、1つのitemを繰り返しuvm_rand_sendしたときのrandcの周期、pre_startより前にrand_modeで保つchild sequenceのfield、local::を使うinline制約の名前解決を検査します。判定は性質だけで行い、特定の値は使いません。空のinline制約はrandcの制約を変えないこと、macroのCONSTRAINTSはmacro呼出し位置で評価するinline制約であることの2つの読み方を明記しました。5件とも最初の凍結のまま、tag付けの前後でseed 1／73が一致しました。`UVM-RAND-PROPERTY-*`の義務を6件追加しました。[乱数化のFAQ](faq.ja.md#q438-乱数化の性質profileは何を検査しますか)を参照してください。

117回目ではuC、u12、u11、u16、uBに4値（`:fourstate: yes`）のspecのみ入力7件を追加しました。configurationの検索、型付きresource、TLM FIFO、poolの存在しないkeyとqueueの存在しない要素（1800-2023のTable 7-1により全X）、直接とfield macroによる記録、field macroのcopyとcloneを、case equalityで検査します。通常のVerilator runnerは2値の検査系だけを選ぶため記録はなく、2値でのbuildは診断に留め、Verilatorは多くのtristate構文を拒否しました。XとZのbitの比較、表示、packなど規定のない経路は[4値の節](testing.ja.md#4値の経路)に一覧しています。`UVM-FOURSTATE-*`の義務を9件追加しました。[4値のFAQ](faq.ja.md#q436-4値のprofileは何を検査しますか)を参照してください。

116回目ではuC、u14、u19、u12にRTL結合profile 5件を追加し、`tests/u19/helpers116_rtl/rf_rtl116.sv`（独自のregister-file designと、driverとmonitorのclocking blockを持つinterface）と`tests/u19/helpers116_rtl/rf_env116.svh`（driver、monitor、register model、adapter、任意のpredictor、collector、analysis FIFO経由のscoreboard）を共有します。検査するのは、configuration databaseによるvirtual interfaceの受渡し、clockに同期したrequestのtimingとfinish_itemの完了、auto-predictionを有効にしたadapter経由のfrontdoor access、明示predictionとそのregister item port、analysis FIFOの保持です。期待値はhelperのdesignの規則、引用したUVM条項、1800-2023のclocking blockのtimingを組み合わせて導き、runnerの変更は不要でした。最初の凍結はscoreboardの計数変数に予約語`matches`を使ったためbuildできず、変えたのはその識別子だけで、buildできなかった入力は`out/thin-one-hundred-sixteenth-before-identifier-fix/`に保管しています。5件ともtag付けの前後でseed 1／73が一致しました。`UVM-RTL-*`の義務を9件追加しました。[RTLのFAQ](faq.ja.md#q434-rtl結合profileは何を検査しますか)を参照してください。

115回目では`tests/u18/`へM3の4 profileを追加し、`tests/u18/helpers115_mam_reconfigure/reconfigure115.svh`を共有します。12〜15のregionを保持するmanagerを8〜23から4〜27へ、または4〜27から8〜23へreconfigureし、その後は新しい範囲の両端での予約または開始位置を固定した要求が正確な位置と長さで成功し、各端のすぐ外側では拒否される必要があります。request側はpre_randomizeで、min_offset、max_offset、lenが新しい範囲を示すことも検査します。最初の凍結はpolicyのhandle名に予約語`before`を使ったためbuildできず、変えたのは2つのhandle名だけで、buildできなかった入力は`out/thin-one-hundred-fifteenth-before-identifier-fix/`に保管しています。新しい義務は`UVM-MAM-AUDIT-RECONFIGURED-BOUNDS-RESERVE`、`-BOUNDS-REQUEST`、`-POLICY-MINIMUM`、`-POLICY-MAXIMUM`で、[reconfigureのFAQ](faq.ja.md#q432-reconfigure後の範囲のprofileは何を検査しますか)を参照してください。112回目のsetter順の義務の限界にはAI再照合を記録しました。12.3.4.2.6のNOTEはvirtual呼出しの読み方を支えますが参考情報のため、観測profile 2件は人の照合までknownのままです。

114回目では`tests/u18/`へM3の4 profileを追加し、`tests/u18/helpers114_mam_stale_source/stale_source114.svh`を共有します。古いdescriptorは、request_regionで得てmanagerまたはregion経由で解放したものか、動的なvirtual register配列を実装または割り当ててvirtual registerのmethodで解放したものです。各profileはpeerの予約を保ち、空いた範囲を再利用した後、保存したdescriptorをmanagerから解放します。18.12.5.3はerrorを求めます。virtual registerのregionでは、18.9.1.1.4と18.9.1.1.5がvirtual registerのmethodでの解放を定めているため、配列が未実装になった後にだけ古いdescriptorを解放し、これは明記した解釈です。検査するのはerrorの発生だけです。

最初の凍結では、virtual registerのsetup行でregion ownerの照会もassertしていました。virtual registerの2入力はその点だけが異なり、既存の18.12.7.2.7のowner既知差分を再現し、request側の2入力は一致しました。その照会はDIAG114行へ移し、getterのidentityはassertしたままで、期待ファイルは変えていません。最初の凍結の入力と測定は`out/thin-one-hundred-fourteenth-before-owner-split/`に保管しています。改訂した入力はtag付けの前後ともseed 1／73で一致しました。新しい義務は`UVM-MAM-AUDIT-STALE-REQUEST-DESCRIPTOR-RELEASE-ERROR`、`UVM-VREG-AUDIT-STALE-REGION-MANAGER-RELEASE-ERROR`、`UVM-VREG-AUDIT-RELEASE-KEEPS-PEER-RESERVATION`で、`UVM-MAM-AUDIT-REGION-RELEASE`にはrequest側のregion経由profileを追加しました。[取得元のFAQ](faq.ja.md#q430-古いdescriptorの取得元profileは何を追加しますか)を参照してください。

113回目の限界は残ります。18.12.7は同じ範囲を後で予約したときに新しいdescriptor instanceが返るかを述べていないため、その範囲を再び予約した状態では古いdescriptorを解放しません。virtual register配列を実装中のregionのmanagerからの解放は検査していません。112回目のunpackの解釈は限定したままです。列挙されたsetterが空配列を含む実際のvirtual訪問を要求するかは照合が必要で、観測profile 2件はknownのままです。他にも物理address変換、storage無効時や変更時の自動recording、event deltaの厳密な適用条件、別要因で起動済みまたは停止したwaiterのcancelなどが未完です。[詳細ハンドオフ](handoff.ja.md)に周辺条件と以前の有効な差分を残しています。

## ローカル資料

Git対象外の`out/`は補助的なlocal証拠であり、版管理する正本ではありません。clone先には存在しない場合があります。このhostでの124回目のファイルは次のとおりです。

```text
out/thin-one-hundred-twenty-fourth-start.json
out/thin-one-hundred-twenty-fourth-pretag.json
out/thin-one-hundred-twenty-fourth-final.json
out/thin-one-hundred-twenty-fourth-verilator-combined.json
out/thin-one-hundred-twenty-fourth-evidence-scope.json
out/thin-one-hundred-twenty-fourth-inventory.json
out/thin-one-hundred-twenty-fourth-backlog.json
out/thin-one-hundred-twenty-fourth-stage-summary.json
```

121回目は`out/thin-one-hundred-twenty-first-causes-generator-used.py`、`-docs-used.py`、`-summary.json`、`-candidates.json`、`-reproducers.txt`を、122回目は`out/thin-one-hundred-twenty-first-diag/`（seed 1の診断出力）、`out/thin-one-hundred-twenty-second-batch-used.py`、`-apply-used.py`、`-docs-used.py`、`-summary.json`、`-candidates.json`、`-reproducers.txt`を、123回目は`out/thin-one-hundred-twenty-third-diag-cond/`（DPIの実行条件の出力）、`out/thin-one-hundred-twenty-third-batch3-used.py`〜`-batch6-used.py`、`-diag-cond-used.py`、`-docs-used.py`、`-summary.json`、`-candidates.json`、`-reproducers.txt`を加えます。原因の記録そのものは`coverage/known_causes.json`で版管理します。

120回目のファイルは同じ名前の`twentieth`版で、`pretag-freeze.json`、`verilator-pretag.json`、`verilator-final.json`、`doc-contents-effective.json`を含みます。119回目のファイルは同じ名前の`nineteenth`版で、`cmdline-pretag.json`、`cmdline-final.json`、`cmdline-combined.json`、`regex-variants.json`、`diag-cmdline-known.txt`を含み、evidence scopeはlocalでbuild 140件へ訂正しました。118回目のファイルは同じ名前の`eighteenth`版で、`verilator-pretag.json`を含みます。117回目のファイルは同じ名前の`seventeenth`版で、4値の入力には`freeze.json`と2値の診断logだけがあり、batchはありません。116回目のファイルは同じ名前の`sixteenth`版で、pretag／finalのbatchと`before-identifier-fix/`を含みます。115回目のファイルは同じ名前の`fifteenth`版です。114回目のファイルは同じ名前の`fourteenth`版で、他に`out/thin-one-hundred-fourteenth-regression-42359747603.json`と`out/thin-one-hundred-fourteenth-before-owner-split/`があります。

125回目（項目8）の作業用script、状態、公開の待ち行列、再開の手引きは`out/thin-one-hundred-twenty-fifth-item8/`（`HANDOFF.md`）にあります。使う前に`origin/main`と最新のCheck、Regressionを確かめてください。guest記録は[詳細ハンドオフ](handoff.ja.md#実測記録と直近の差分)に記載した112回目のファイルのままです。`out/thin-one-hundred-twenty-fourth-ledger-used.py`、`-stages-used.py`、`-docs-used.py`と、120回目のgenerator、ledger、docsのscript、同じ形の114〜119回目のscriptは実際に使ったもので、guardが以前のcommitと資料本文を参照するため再実行しません。次の資料更新はeffective snapshotと現在の版管理ファイルから始めます。indexへの追記時は既存の順序を保持し、証拠を持ち越す前に入力・runner・library・simulatorのfingerprintを確認します。規則は[証拠の集約](results.ja.md#記録の合算)にあります。

## 次の候補

承認済みの範囲ではなく提案です。選ぶ前にbacklogを再生成します。

- 項目8（読みやすさ）：小さいdirectoryから順に、コメントと変種の説明を足し、helperを1行1文に整え、`tools/code_identity.py check`と`refresh`を実行し、そのdirectoryの入力をVerilatorのseed 1／73で測り直し、guestの記録を持ち越して公開し、そのdirectoryに絞ったRegressionの結果を待ってから次へ進みます。項目7は完了し、短いセットのkirimasimでの実行には許可された実行fileが必要で、段階0のテストと各段階に対応付けた言語のテストが、kirimasimの止まる所を示します。項目6は完了しました。照合の候補406件は人の照合を待っています。libraryの出力値を記録するか（A1では記録していません）と、UVM_NO_DPIのために測れない通常の検査系3件をDPIの実行条件の一覧に加えるかは、形式または構成の変更なので、案を示してから決めます。
- 18.12.4.2の、範囲と同時にmode／localityを変えるreconfigureや他のbyte幅。
- 112回目のunpackの列挙setterの問題：規格と照合し、library証拠を理由にknownをpassへ変更しません。
- 第18章の他の部分条件（部分393番号）と全体の部分2062番号を、元のM1〜M3目標と比べます。

## 確認と再開

各拡充の前にbacklogを再生成し、実際に残る義務を規格で確認して、独立したoracleを凍結し、最終入力を測定し、互換な証拠と両言語を更新してから公開します。実際の残る義務と元のmilestone目標の監査が終わるまでgoalを完了扱いにしません。Claude Codeは会話のnative goal状態を自動継承しません。

Python 3.10以降を使います。native再現にはVerilator 5.052、C++ toolchain、make、path上のz3 solverが必要です。固定Accellera UVM 2020.3.1 libraryがなければ取得します。再開時の確認手順です。

```sh
git status --short --branch
git log -1 --oneline
z3 --version
python3 tools/fetch_uvm.py
python3 tools/fetch_uvm.py --check
python3 tools/lint_metadata.py
python3 tools/requirements.py check
python3 tools/known_causes.py check
python3 tools/kirimasim_stages.py check
python3 tools/code_identity.py check --base HEAD
python3 tools/requirements.py inventory --json out/requirements-inventory.json
python3 tools/requirements.py backlog --json out/requirements-backlog.json --lang ja
python3 -m unittest discover -s tools -p 'test_*.py'
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 1 --json out/verilator-smoke.json tests/u09/test_common_phases_run_in_order.sv
gh run list --workflow regression.yml --limit 3
```

## 再開時にClaude Codeへ渡す文面

> 現在のworkspaceの指示、README、日英のClaude Codeハンドオフを読んでください。main・作業ツリー・最新のCheckと、最新のRegressionの結果を確認してください。ユーザーが許可した範囲で、継続中のM1〜M4のgoalを続けてください。生成する3キューは0ですが、部分分解2062番号と元のmilestone目標が残り、実際の未対応0件は未実証です。意味のある残る条件をlocal IEEE規格で監査し、既存テストとの重複を避けてください。独立した期待値、限定した既知差分、互換な証拠、runner指紋、商用結果の不使用、Ghostの非公開情報、完全な日英資料を維持してください。完了済みの一時scriptを再実行しないでください。最終入力を測定し、適切な検査を実施して限界を報告し、許可された範囲でmainへ公開してください。レビュー・範囲承認・pass・goal完了を捏造しないでください。
