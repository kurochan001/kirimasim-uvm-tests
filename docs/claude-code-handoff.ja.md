# Claude Codeへのハンドオフ

[English](claude-code-handoff.md) · [README](../README.ja.md) · [詳細ハンドオフ](handoff.ja.md)

## 最初に読むこと

2026-11-07に更新しました。Claude Codeのsessionが前回のハンドオフを引き継ぎ、ユーザーはM1〜M4の継続goalの再開、CIの先行修正、mainへの公開を承認しました。このsessionは[a897c68](https://github.com/kurochan001/kirimasim-uvm-tests/commit/a897c6820b037b8fddecfbf7c72c7997bcd075f4)と[42d03ab](https://github.com/kurochan001/kirimasim-uvm-tests/commit/42d03abae20701f344697d13bdca83043c3710f1)でCIを分割し、[f94ba4a](https://github.com/kurochan001/kirimasim-uvm-tests/commit/f94ba4ab94a67d5e9eeb2fcaf7e19a57b4596cc4)で113回目の拡充を公開しました。その後、最初のRegressionでhostedのrunnerにz3制約solverがないことが分かり、準備用actionで導入して、[db06513](https://github.com/kurochan001/kirimasim-uvm-tests/commit/db06513ce8c467d7a2e87e972beae496ff73c828)で114回目の拡充を公開しました。その後、[eeda25d](https://github.com/kurochan001/kirimasim-uvm-tests/commit/eeda25d9b378773a2841076706f8e8029d87c08d)で115回目の拡充を公開しました。2026-11-08にユーザーは外部レビューを示し、その最初の項目であるRTLとの結合を、[c314982](https://github.com/kurochan001/kirimasim-uvm-tests/commit/c314982e5c42e5333790b7ba7bb00bbaef8da2f7)で116回目の拡充として公開し、2番目の項目である4値の経路を、この文面を含むcommitで117回目の拡充として公開しました。**goalは継続中で、完了していません。**

編集前に実際のbranchと作業ツリーを確認してください。117回目はnative測定のない4値の入力を追加し、116回目の測定は終了済みです。

最初に現在のworkspaceの指示を読みます。ユーザーのagent向け指示は`RTK.md`を参照するため、現在の環境で解決してください。非公開設定やユーザーの絶対パスを公開ファイルへ記載しません。

## 完了したことと残ること

生成する3つのキュー、つまり未対応テスト・直接テストのない要求・未評価の条項識別子は0件です。**実際の残作業が0件とは実証されていません。** 棚卸し2507識別子のうち2062件は一部分解、445件は分類済みです。範囲は提案段階、完全性はfalse、承認済み分母とcoverage率はnullで、人のレビューは未記録です。元のM1〜M4目標と規範的義務の適用条件は未完で、これらの異なる指標は[要求ガイド](requirements.ja.md)で説明しています。

- テスト：22 directoryに2747件 = simulation 2648 + elaboration 99。M1：1178（1097/81）、M2：627（620/7）、M3：942（931/11）。うち7件はVerilatorの記録のない4値（`:fourstate: yes`）のspecのみ入力です。
- AI要求：4127件すべてを2691テストへ直接対応。control専用は56テストです。人のレビューは主張しません。
- 通常のpass入力：2282件 = seed 1/73でruntime一致2188 + 期待したcompiler rejection 94。
- 既知差分：458件 = runtime差分318 + simulation build失敗135 + 不正入力のcompile受理5。最初のseedの失敗から次のseedの結果を推測しません。specのみは4値の7入力を含めて465件です。
- guest証拠：互換1081記録、未測定1666入力（追加1662 + 改訂した元入力4）。112〜117回目にguest測定はありません。以前の一時的な非公開executable／profileのsnapshotは失われているため、guest測定前に許可されたlocal設定を確保します。
- 候補の配置：primaryテスト0件が1168番号、1件が767番号、2件以上が547番号です。条項の網羅や独立した検査の成功を証明する件数ではありません。

HDL backendとcommand-lineの追加検査には別の実行条件があり、[実行結果](results.ja.md)と[テストガイド](testing.ja.md)を確認してください。範囲を確認せず通常の総数へ加算しません。

## CIの状態

hosted CIは2026-10-31以降、Verilatorの選択を一度も完了していませんでした。単一のCheckが`cancel-in-progress`付きでpushごとに全件を実行し、中断されなかった唯一の8 shard実行では全shardが150分の上限に達しました。置き換えた構成とsolverの修正は[CIの節](results.ja.md#継続的インテグレーション)で説明しています。

- [Check](../.github/workflows/check.yml)はtool・metadata・library・台帳の検査と、入力が変わったタグ付き検査、canary 1件を実行します（[選択ツール](../tools/ci_select.py)）。42d03ab（[run 42359747127](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42359747127)、canaryのみ）とf94ba4a（[run 42360326889](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42360326889)、113回目の4入力とcanary）で成功しました。どちらの選択も乱数化を行いません。
- [Regression](../.github/workflows/regression.yml)は手動と毎週、全タグ付き検査を20 shard（同時4、各360分）で、command-line 17件と合わせて実行します。最初の起動である42d03abの[run 42359747603](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42359747603)は、command-line job（成功）とshard 0・2・3（342件中334件一致）の完了後に取り消しました。8件の差分はすべて制約付き乱数化に依存し、imageのpathにSMT solverがありませんでした。localでz3を外すと、確かめた4件の差分を再現しました。このrunはどのcommitのRegression結果でもありません。
- [準備用action](../.github/actions/setup-verilator/action.yml)はすべてのjobでz3を導入し、その版を表示します。[db06513](https://github.com/kurochan001/kirimasim-uvm-tests/commit/db06513ce8c467d7a2e87e972beae496ff73c828)のCheck（[run 42371357208](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42371357208)）はz3 4.8.12を導入し、allocation policyを乱数化するrequest側の2 profileを含む選択5件が一致しました。
- Regressionはdb06513で[run 42372122368](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42372122368)として再度起動しました。20 shardでタグ付き検査2273件すべてがseed 1／73で一致し（各shard 113〜199分）、command-line jobも成功したため、その結果を確認してから115回目のcommitを公開しました。このrunの対象はdb06513で、115回目の4入力はCheckの変更入力jobとlocal測定で確認しています。116回目の入力はそのcommitのCheckとlocal測定で確認し、117回目の4値の入力はCheckもRegressionも選びません。後で全件のhosted結果が必要になればRegressionを再度起動し、shardがtimeoutまたは失敗した場合は、テストを追加公開する前に調べます。
- 同時10で起動したrunは、アカウント共有のhosted job枠を埋めて他のrepositoryを遅らせたため以前に取り消しました。Regressionの同時実行数は控えめに保ち、全件実行を重ねて起動しません。

## 外部レビュー

2026-11-08にユーザーは、kirimasimが実際のUVM testbenchを動かせるかを測るためにスイートを補強する、優先順位付きの8項目からなる外部の静的レビューを示しました。事実確認では件数をおおむね確認しましたが、乱数化については、sequence libraryを使う36ファイル、pre／post_randomizeを使う52ファイル、inline制約付き`uvm_do`の7ファイルがすでにあり、`uvm_do_with`は1800.2-2020に含まれません（B.3.1.4は`CONSTRAINTS`引数を使います）。各項目は個別にcommitし、次の項目を公開する前にmainのCheckで確認します。

- 項目1（RTLとの結合）：下記の116回目で実装しました。
- 項目2（4値の経路）：下記の117回目で実装しました。
- 項目3（乱数化の性質）、項目5（ユーザーpackage）：形式を変えずに進める計画です。
- 項目4（DPIの構成）、項目6（既知458入力の原因分類）、項目7（kirimasimの段階）：先に案を示し、ユーザーの確認を待ちます。項目6で固定版libraryがsourceから出すはずの値を保存することは出典方針の変更にあたり、ユーザーの明示的な判断が必要です。段階tagと原因の記録は、headerのfieldにすると全入力の指紋が変わるため、別の追跡ファイルとして提案します。
- 項目8（読みやすさ）：コメントとhelperの変更で大半の入力の指紋が変わります。各directoryで13時間の全件実行をしなくて済むよう、Regressionの手動起動にdirectoryで絞る入力を提案します。

## 維持する判断

- 独立した期待値はユーザー提供IEEE規格から導きます。Git対象外のlocal PDFは`IEEE_Std_1800.2-2020.pdf`と`IEEE_Std_1800-2023_SystemVerilog.pdf`で、新規cloneには含まれず、再配布しません。規格の本文・図・例をテストや資料へコピーしません。
- 商用シミュレータの結果・出力・診断を、匿名化や第三者経由を含めて利用しません。GPL／LGPLシミュレータの実装sourceを読みません。[出典方針](provenance.ja.md)と[投稿方針](faq.ja.md#商用シミュレータとissueの投稿方針)に従います。
- 固定したApache UVM sourceは、規格由来のoracleを凍結した後で差分の説明に使えますが、期待値を定義しません。有効なspec-only差分と限定した解釈を保持します。観測出力へ合わせるためだけに期待値を変更せず、tag付け前の改訂は明記して保管します。
- Ghostの実際の識別情報・版・executable／profileパス・profile内容・生の診断を非公開にします。PDF・取得したlibrary source・log・非公開設定・生成した一時ファイルをGitへ含めません。
- 完全な日英対を維持します。READMEは現状、[履歴](history.ja.md)は過去の追加を記録します。最近追加した読者向け説明とリンク、過去時点のFAQ、AI照合状態、既存証拠のidentityを保持します。
- `tools/run_verilator.py`、`tools/suite_results.py`、`tools/uvm_common.py`を安易に変更しません。これらはrunner指紋を構成し、変更すると保存済みの全記録が無効になります。`tools/ci_select.py`とworkflowのファイルは指紋の外にあります。

## 最新実装と限界

117回目ではuC、u12、u11、u16、uBに4値（`:fourstate: yes`）のspecのみ入力7件を追加しました。configurationの検索、型付きresource、TLM FIFO、poolの存在しないkeyとqueueの存在しない要素（1800-2023のTable 7-1により全X）、直接とfield macroによる記録、field macroのcopyとcloneを、case equalityで検査します。通常のVerilator runnerは2値の検査系だけを選ぶため記録はなく、2値でのbuildは診断に留め、Verilatorは多くのtristate構文を拒否しました。XとZのbitの比較、表示、packなど規定のない経路は[4値の節](testing.ja.md#4値の経路)に一覧しています。`UVM-FOURSTATE-*`の義務を9件追加しました。[4値のFAQ](faq.ja.md#q436-4値のprofileは何を検査しますか)を参照してください。

116回目ではuC、u14、u19、u12にRTL結合profile 5件を追加し、`tests/u19/helpers116_rtl/rf_rtl116.sv`（独自のregister-file designと、driverとmonitorのclocking blockを持つinterface）と`tests/u19/helpers116_rtl/rf_env116.svh`（driver、monitor、register model、adapter、任意のpredictor、collector、analysis FIFO経由のscoreboard）を共有します。検査するのは、configuration databaseによるvirtual interfaceの受渡し、clockに同期したrequestのtimingとfinish_itemの完了、auto-predictionを有効にしたadapter経由のfrontdoor access、明示predictionとそのregister item port、analysis FIFOの保持です。期待値はhelperのdesignの規則、引用したUVM条項、1800-2023のclocking blockのtimingを組み合わせて導き、runnerの変更は不要でした。最初の凍結はscoreboardの計数変数に予約語`matches`を使ったためbuildできず、変えたのはその識別子だけで、buildできなかった入力は`out/thin-one-hundred-sixteenth-before-identifier-fix/`に保管しています。5件ともtag付けの前後でseed 1／73が一致しました。`UVM-RTL-*`の義務を9件追加しました。[RTLのFAQ](faq.ja.md#q434-rtl結合profileは何を検査しますか)を参照してください。

115回目では`tests/u18/`へM3の4 profileを追加し、`tests/u18/helpers115_mam_reconfigure/reconfigure115.svh`を共有します。12〜15のregionを保持するmanagerを8〜23から4〜27へ、または4〜27から8〜23へreconfigureし、その後は新しい範囲の両端での予約または開始位置を固定した要求が正確な位置と長さで成功し、各端のすぐ外側では拒否される必要があります。request側はpre_randomizeで、min_offset、max_offset、lenが新しい範囲を示すことも検査します。最初の凍結はpolicyのhandle名に予約語`before`を使ったためbuildできず、変えたのは2つのhandle名だけで、buildできなかった入力は`out/thin-one-hundred-fifteenth-before-identifier-fix/`に保管しています。新しい義務は`UVM-MAM-AUDIT-RECONFIGURED-BOUNDS-RESERVE`、`-BOUNDS-REQUEST`、`-POLICY-MINIMUM`、`-POLICY-MAXIMUM`で、[reconfigureのFAQ](faq.ja.md#q432-reconfigure後の範囲のprofileは何を検査しますか)を参照してください。112回目のsetter順の義務の限界にはAI再照合を記録しました。12.3.4.2.6のNOTEはvirtual呼出しの読み方を支えますが参考情報のため、観測profile 2件は人の照合までknownのままです。

114回目では`tests/u18/`へM3の4 profileを追加し、`tests/u18/helpers114_mam_stale_source/stale_source114.svh`を共有します。古いdescriptorは、request_regionで得てmanagerまたはregion経由で解放したものか、動的なvirtual register配列を実装または割り当ててvirtual registerのmethodで解放したものです。各profileはpeerの予約を保ち、空いた範囲を再利用した後、保存したdescriptorをmanagerから解放します。18.12.5.3はerrorを求めます。virtual registerのregionでは、18.9.1.1.4と18.9.1.1.5がvirtual registerのmethodでの解放を定めているため、配列が未実装になった後にだけ古いdescriptorを解放し、これは明記した解釈です。検査するのはerrorの発生だけです。

最初の凍結では、virtual registerのsetup行でregion ownerの照会もassertしていました。virtual registerの2入力はその点だけが異なり、既存の18.12.7.2.7のowner既知差分を再現し、request側の2入力は一致しました。その照会はDIAG114行へ移し、getterのidentityはassertしたままで、期待ファイルは変えていません。最初の凍結の入力と測定は`out/thin-one-hundred-fourteenth-before-owner-split/`に保管しています。改訂した入力はtag付けの前後ともseed 1／73で一致しました。新しい義務は`UVM-MAM-AUDIT-STALE-REQUEST-DESCRIPTOR-RELEASE-ERROR`、`UVM-VREG-AUDIT-STALE-REGION-MANAGER-RELEASE-ERROR`、`UVM-VREG-AUDIT-RELEASE-KEEPS-PEER-RESERVATION`で、`UVM-MAM-AUDIT-REGION-RELEASE`にはrequest側のregion経由profileを追加しました。[取得元のFAQ](faq.ja.md#q430-古いdescriptorの取得元profileは何を追加しますか)を参照してください。

113回目の限界は残ります。18.12.7は同じ範囲を後で予約したときに新しいdescriptor instanceが返るかを述べていないため、その範囲を再び予約した状態では古いdescriptorを解放しません。virtual register配列を実装中のregionのmanagerからの解放は検査していません。112回目のunpackの解釈は限定したままです。列挙されたsetterが空配列を含む実際のvirtual訪問を要求するかは照合が必要で、観測profile 2件はknownのままです。他にも物理address変換、storage無効時や変更時の自動recording、event deltaの厳密な適用条件、別要因で起動済みまたは停止したwaiterのcancelなどが未完です。[詳細ハンドオフ](handoff.ja.md)に周辺条件と以前の有効な差分を残しています。

## ローカル資料

Git対象外の`out/`は補助的なlocal証拠であり、版管理する正本ではありません。clone先には存在しない場合があります。このhostでの117回目のファイルは次のとおりです。

```text
out/thin-one-hundred-seventeenth-freeze.json
out/thin-one-hundred-seventeenth-verilator-combined.json
out/thin-one-hundred-seventeenth-evidence-scope.json
out/thin-one-hundred-seventeenth-inventory.json
out/thin-one-hundred-seventeenth-backlog.json
out/thin-one-hundred-seventeenth-doc-contents-effective.json
out/thin-one-hundred-seventeenth-diag-two-state-build.txt
```

4値の入力にはpretag／finalのbatchがなく、2値のbuild logは診断で証拠ではありません。116回目のファイルは同じ名前の`sixteenth`版で、pretag／finalのbatchと`before-identifier-fix/`を含みます。115回目のファイルは同じ名前の`fifteenth`版です。114回目のファイルは同じ名前の`fourteenth`版で、他に`out/thin-one-hundred-fourteenth-regression-42359747603.json`と`out/thin-one-hundred-fourteenth-before-owner-split/`があります。

guest記録は[詳細ハンドオフ](handoff.ja.md#実測記録と直近の差分)に記載した112回目のファイルのままです。`out/thin-one-hundred-seventeenth-generator-used.py`、`-ledger-used.py`、`-docs-used.py`と、同じ形の114〜116回目のscriptは実際に使ったもので、guardが以前のcommitと資料本文を参照するため再実行しません。次の資料更新はeffective snapshotと現在の版管理ファイルから始めます。indexへの追記時は既存の順序を保持し、証拠を持ち越す前に入力・runner・library・simulatorのfingerprintを確認します。規則は[証拠の集約](results.ja.md#記録の合算)にあります。

## 次の候補

承認済みの範囲ではなく提案です。選ぶ前にbacklogを再生成します。

- 上記のレビュー計画に従い、外部レビューの次の項目（項目3）。
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
python3 tools/requirements.py inventory --json out/requirements-inventory.json
python3 tools/requirements.py backlog --json out/requirements-backlog.json --lang ja
python3 -m unittest discover -s tools -p 'test_*.py'
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 1 --json out/verilator-smoke.json tests/u09/test_common_phases_run_in_order.sv
gh run list --workflow regression.yml --limit 3
```

## 再開時にClaude Codeへ渡す文面

> 現在のworkspaceの指示、README、日英のClaude Codeハンドオフを読んでください。main・作業ツリー・最新のCheckと、最新のRegressionの結果を確認してください。ユーザーが許可した範囲で、継続中のM1〜M4のgoalを続けてください。生成する3キューは0ですが、部分分解2062番号と元のmilestone目標が残り、実際の未対応0件は未実証です。意味のある残る条件をlocal IEEE規格で監査し、既存テストとの重複を避けてください。独立した期待値、限定した既知差分、互換な証拠、runner指紋、商用結果の不使用、Ghostの非公開情報、完全な日英資料を維持してください。完了済みの一時scriptを再実行しないでください。最終入力を測定し、適切な検査を実施して限界を報告し、許可された範囲でmainへ公開してください。レビュー・範囲承認・pass・goal完了を捏造しないでください。
