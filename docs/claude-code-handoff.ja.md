# Claude Codeへのハンドオフ

[English](claude-code-handoff.md) · [README](../README.ja.md) · [詳細ハンドオフ](handoff.ja.md)

## 最初に読むこと

利用枠の残りが1%となり、ユーザーから引継ぎ資料の作成・コミット・pushを依頼されたため、2026-11-07に作成しました。M1〜M4の継続goalは**ユーザーの依頼で一時停止中**です。この資料はgoalの再開や完了を意味しません。次のagentはユーザーから再開の依頼を受けて実装を続けてください。今回の公開はドキュメントだけの変更です。

最後の実装checkpointは、mainへ公開した112回目の拡充分の[ba28ff5](https://github.com/kurochan001/kirimasim-uvm-tests/commit/ba28ff5eb4abed79b6b0a1c752e0213a9b6a685f)です。今回の引継ぎcommitはその後に続きます。編集前に実際のbranchと作業ツリーを確認してください。112回目のnative測定はすべて終了済みで、113回目の測定は開始していません。

最初に現在のworkspaceの指示を読みます。ユーザーのagent向け指示は`RTK.md`を参照するため、現在の環境で解決してください。非公開設定やユーザーの絶対パスを公開ファイルへ記載しません。

## 完了したことと残ること

生成する3つのキュー、つまり未対応テスト・直接テストのない要求・未評価の条項識別子は0件です。**実際の残作業が0件とは実証されていません。** 棚卸し2507識別子のうち2062件は一部分解、445件は分類済みです。範囲は提案段階、完全性はfalse、承認済み分母とcoverage率はnullで、人のレビューは未記録です。元のM1〜M4目標と規範的義務の適用条件は未完で、これらの異なる指標は[要求ガイド](requirements.ja.md)で説明しています。

- テスト：22 directoryに2723件 = simulation 2624 + elaboration 99。M1：1171（1090/81）、M2：624（617/7）、M3：928（917/11）。
- AI要求：4101件すべてを2667テストへ直接対応。control専用は56テストです。人のレビューは主張しません。
- 通常のpass入力：2265件 = seed 1/73でruntime一致2171 + 期待したcompiler rejection 94。
- 既知差分：458件 = runtime差分318 + simulation build失敗135 + 不正入力のcompile受理5。最初のseedの失敗から次のseedの結果を推測しません。
- guest証拠：互換1081記録、未測定1642入力（追加1638 + 改訂した元入力4）。112回目に新たなguest測定はありません。以前の一時的な非公開executable／profileのsnapshotは失われているため、guest測定前に許可されたlocal設定を確保します。
- 候補の配置：primaryテスト0件が1170番号、1件が768番号、2件以上が544番号です。条項の網羅や独立した検査の成功を証明する件数ではありません。

HDL backendとcommand-lineの追加検査には別の実行条件があり、[実行結果](results.ja.md)と[テストガイド](testing.ja.md)を確認してください。範囲を確認せず通常の総数へ加算しません。

## 維持する判断

- 独立した期待値はユーザー提供IEEE規格から導きます。Git対象外のlocal PDFは`IEEE_Std_1800.2-2020.pdf`と`IEEE_Std_1800-2023_SystemVerilog.pdf`で、新規cloneには含まれず、再配布しません。規格の本文・図・例をテストや資料へコピーしません。
- 商用シミュレータの結果・出力・診断を、匿名化や第三者経由を含めて利用しません。GPL／LGPLシミュレータの実装sourceを読みません。[出典方針](provenance.ja.md)と[投稿方針](faq.ja.md#商用シミュレータとissueの投稿方針)に従います。
- 固定したApache UVM sourceは、規格由来のoracleを凍結した後で差分の説明に使えますが、期待値を定義しません。有効なspec-only差分と限定した解釈を保持します。観測出力へ合わせるためだけに期待値を変更しません。
- Ghostの実際の識別情報・版・executable／profileパス・profile内容・生の診断を非公開にします。PDF・取得したlibrary source・log・非公開設定・生成した一時ファイルをGitへ含めません。
- 完全な日英対を維持します。READMEは現状、[履歴](history.ja.md)は過去の追加を記録します。最近追加した読者向け説明とリンク、過去時点のFAQ、AI照合状態、既存証拠のidentityを保持します。

## 最新実装と限界

112回目では`tests/u12/`へM2の独立payload unpack 4 profileを追加し、`tests/u12/helpers112_unpack/payload_unpack112.svh`を共有します。通常targetの最終tag付き2件は両seed一致です。観測targetの2件はseed 1の既知差分、正常終了0のままで、seed 73は未実行です。異なるのは最初のsetter訪問traceのUT 6/12行だけで、他の10行は一致します。診断用の回数はoracleではありません。

公開された型付きpacker入力はpayloadのpack処理から独立しています。setterの直接呼出し確認と継承したunpackを分けます。列挙setterの実際のvirtual訪問を要求する解釈は、空配列も含めて限定したままです。検査対象は関連する直列化データのactive長で、未使用の保持capacityやcurrent-sizeという文言全体ではありません。空のIGNORE payloadは未送信の直列化で、長さ0の実際の転送を実証しません。[完了のFAQ](faq.ja.md#q427-unpack-profileでpayload条項は完了しますか)を参照してください。

期待値の凍結と測定終了後に、固定したApacheのpayload unpack本体とunpack macroを読みました。memberへの直接代入はsetter訪問が観測されないことと整合しますが、IEEEの解釈を確定しません。これを理由に既知差分をpassへ変更しません。

他にも物理address変換、storage無効時や変更時の自動recording、event deltaの厳密な適用条件、別要因で起動済みまたは停止したwaiterのcancelなどが未完です。[詳細ハンドオフ](handoff.ja.md)に周辺条件と以前の有効な差分を残しています。

## ローカル資料と未実行の案

Git対象外の`out/`は補助的なlocal証拠であり、版管理する正本ではありません。clone先には存在しない場合があります。このhostでは、証拠を再利用する前に112回目の次のファイルを確認してください。

```text
out/thin-one-hundred-twelfth-publication.json
out/thin-one-hundred-twelfth-resume-state.json
out/thin-one-hundred-twelfth-next-audit-observations.json
out/thin-one-hundred-twelfth-audit.json
out/thin-one-hundred-twelfth-evidence-scope.json
out/thin-one-hundred-twelfth-verilator-combined.json
out/thin-one-hundred-twelfth-post-measurement-library-diagnostic.json
out/thin-one-hundred-twelfth-doc-contents-effective.json
```

112回目の完了済みgenerator・台帳installer・assembler・資料更新script・公開前auditは再実行しません。guardと基点が以前のcheckpointを参照しています。次の資料更新では、後から手修正した内容を失うraw更新scriptを再実行せず、effective snapshotと現在の版管理ファイルを確認します。indexへの追記時は既存の順序を保持します。証拠を持ち越す前に入力・runner・library・simulatorのfingerprintを確認し、互換性の規則は[証拠の集約](results.ja.md#記録の合算)に従います。

次回用には`out/thin-one-hundred-thirteenth-generate.py`の下書きだけを作りました。**未実行・未検証**であり、113回目のテスト・期待値・台帳更新・測定は存在しません。承認済みのテスト内容とは扱わず、一時停止中に実行しません。

M3の案は、memory managerで一括解放またはregion facadeからの解放後に古いdescriptorをmanagerへ渡して再度解放する条件です。まずIEEE 18.12.5.3と周辺を読み、既存の二度目の解放・他managerのregion・一括解放・region解放の検査と比較して重複を避けます。4 profileの案は2つの解放経路とallocation呼出し順の最初／最後のhandleを組み合わせ、iterator順を固定しません。不正な呼出しの前に正常なtarget状態の観測を完了し、その後はtarget managerやdescriptorを調べたり再利用したりしません。後続の正常系は独立したmanagerで検査します。errorの発生を検査し、厳密なreport回数は診断に留めます。配置の件数を減らすためではなく、欠けている適用条件を補う案です。

## 確認と再開

ユーザーが再開を依頼したらbacklogを再生成し、実際に残る義務を規格で確認して、独立したoracleを凍結し、最終入力を測定し、互換な証拠と両言語を更新してから検証済みの追加を公開します。実際の残る義務と元のmilestone目標の監査が終わるまでgoalを完了扱いにしません。Claude Codeはこの会話のnative goal状態を自動継承しません。

Python 3.10以降を使います。native再現にはVerilator 5.052、C++ toolchain、makeが必要です。固定Accellera UVM 2020.3.1 libraryがなければ取得します。次のコマンドは再開用の確認手順であり、今回の資料だけの変更で再実行した検査ではありません。

```sh
git status --short --branch
git log -1 --oneline
python3 tools/fetch_uvm.py
python3 tools/fetch_uvm.py --check
python3 tools/lint_metadata.py
python3 tools/requirements.py check
python3 tools/requirements.py inventory --json out/requirements-inventory.json
python3 tools/requirements.py backlog --json out/requirements-backlog.json --lang ja
python3 -m unittest discover -s tools -p 'test_*.py'
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 1 --json out/verilator-smoke.json tests/u09/test_common_phases_run_in_order.sv
```

最後の実装公開時に[Check run 42355593581](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/42355593581)を2026-11-07 08:29:08 UTC時点でqueuedと記録しました。これは過去の観測であり成功の主張ではありません。実際の現在commitのrunを確認してください。通常検査は8 shard、最大4並列で集約gateへつなぎ、localの成功はhosted CIの成功を意味しません。

## 再開時にClaude Codeへ渡す文面

> 現在のworkspaceの指示、README、日英のClaude Codeハンドオフを読んでください。main・作業ツリー・最新CIを確認し、今回ユーザーが許可した範囲で一時停止中のM1〜M4を再開してください。生成する3キューは0ですが、部分分解2062番号と元のmilestone目標が残り、実際の未対応0件は未実証です。意味のある残る条件をlocal IEEE規格で監査し、未実行の古いdescriptor解放案も重複確認後に検討してください。独立した期待値、限定した既知差分、互換な証拠、商用結果の不使用、Ghostの非公開情報、完全な日英資料を維持してください。完了済みの一時更新scriptを再実行しないでください。最終入力を測定し、適切な検査を実施して限界を報告し、許可された範囲でmainへ公開してください。レビュー・範囲承認・pass・goal完了を捏造しないでください。
