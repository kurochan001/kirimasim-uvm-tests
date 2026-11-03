# 開発ハンドオフ

[English](handoff.md) · [README](../README.ja.md) · [要求台帳](requirements.ja.md)

## 引継ぎ時点と目的

2026-11-03に、`main`の[8e4aea1](https://github.com/kurochan001/kirimasim-uvm-tests/commit/8e4aea1d2b4ce3972e04bd254643581ab2738af9)
を基に、薄い領域の20回目の拡充へ更新しました。再開時に最新の公開commitと作業ツリーを確認してください。

IEEE 1800.2-2020のUVM適合を検査し、kirimasimを対象とするプロジェクトです。
SystemVerilog言語だけのreproducerは、
[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests)で扱います。
M1〜M4の薄い領域を引き続き補強します。M4は進行中で、未対応テスト0件は、どの段階の完了も意味しません。

| 領域 | 現在の状態 |
| --- | --- |
| M1 | 393件：core object、policy、reporting、階層、factory、phase、同期、recording、utility |
| M2 | 430件：sequence、sequencer、callback、TLM |
| M3 | 351件：register／memory layer、付録E |
| 全体 | 章・付録21 directoryに1174件。照合はすべてAIで、人による照合は未記録 |
| M4 | AI要求案1301件。1301要求を1173テストへ直接対応。追加control 1テスト。未対応テスト0件 |
| 規範的棚卸し | 2,504識別子のうち827件を一部分解、22件を明示的に分類。1,655件は未評価。直接テストのない要求案0件 |

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
  [既知差分](known-differences.ja.md)：spec-only全124件。
- [要求ガイド](requirements.ja.md)、[範囲](../coverage/scope.json)、[台帳](../coverage/requirements.json)、[分類](../coverage/assessments.json)、
  [テスト索引](../coverage/test_index.json)：M4の正規の状態です。生成inventoryはレビューの補助資料で、
  版管理する入力の代わりではありません。
- [library lock](../third_party/uvm.lock)：Accellera UVM 2020.3.1、`78c06547a2a0`、326ファイル。
  版管理するtoolで取得し、library本体はコミットしません。1166検査系は`UVM_NO_DPI`を使い、8件は独自VPI HDL backendを明示要求します。
- ユーザーがrepository rootへ`IEEE_Std_1800.2-2020.pdf`と
  `IEEE_Std_1800-2023_SystemVerilog.pdf`を配置済みです。Git対象外のlocalファイルで、
  新規cloneにはなく、再配布しません。`/tmp`内の抽出済みtextも一時資料です。
- `out/`の結果はGit対象外のlocal資料です。`/tmp/kirimasim-uvm-thin-twentieth-*.py`の一時helperは、
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

この記録は、tool単体テスト88件、全1174件のmetadata、台帳／索引、library整合性、現在の入力とevidenceの照合を
通過しています。資料だけの変更では、全シミュレーションの再buildは不要です。
全件evidenceはVerilatorだけで、他2系統は未変更1085件の記録、新規89件は未測定です。実行のsmoke確認は次のとおりです。

```sh
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 1 \
  --json out/verilator-smoke.json tests/u09/test_common_phases_run_in_order.sv
```

[対象コードのCheck](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/41559083571)は参照用です。
最新のworkflow結果はREADMEのbadgeで確認してください。後のcommitによって、このrunが置き換わる場合があります。
local検証だけでCI全体の成功とは扱いません。
Checkはtool、metadata、台帳、library、oracle付きVerilatorを検査し、Ghost、kirimasim、spec-onlyの実行は含みません。
Nightly workflowや結果の自動公開はありません。

## 実測記録と直近の差分

| シミュレータ／library | 記録した結果 |
| --- | --- |
| Verilator 5.052／固定UVM | seed 1・73でpass 1050件、known 124件 |
| Verilator 5.052／独自VPI HDL backend | 別条件の8件：7件が両seed pass、1件はseed 1でfail |
| kirimasim／固定UVM | 未変更1085件で未対応1076件・API欠落fail 9件。新規89件は未測定 |
| Ghost／同梱UVM | 未変更1085件で各seed pass 207件・fail 878件。新規89件は未測定 |
| Ghost／固定UVM | 現在の実行ファイルsnapshotでは未測定 |

通常条件のknown 124件は、seed 1の実行時差分106件、API欠落build 10件、HDL DPI未linkのbuild 8件です。
VPI条件は明示選択する8入力で、7件が両seed一致、1件はE.7のwarning／転送なしの差分を保持します。重複する条件を合計しません。

最新の15検査系は、abstract registry 7条件、sequence ID／parent変更2件、block map／door／解除6件です。
13件は両seedで一致します。parentなしのabstract component生成とparent変更後の計算depthは差分を保持し、parentありcallbackの対照検査は一致します。
guest実測は追加せず、現在の89件はguest条件で未測定です。
AI分類22件は、構造21件・文脈1件で別に保持します。inventory／backlogのschemaは2、正本のschemaは1のままです。

集約した記録は、過去の未変更入力を保持し、再測定した記録だけを置換します。1回の呼出しで全件を再実行したものではありません。
現在のhostでは、互換なlocal記録は次にあります。

```text
out/thin-twentieth-verilator-combined.json
out/thin-fourteenth-ghost-final-1.json
out/thin-fourteenth-ghost-final-73.json
out/thin-fourteenth-kirimasim-final.json
out/thin-twentieth-inventory.json
out/thin-twentieth-backlog-final.json
out/thin-twentieth-evidence-scope.json
out/thin-twentieth-hdl-combined.json
```

再利用前に、宣言した全件／部分の対象ごとのtest ID集合の完全一致、現在の`inputs_sha256`、simulatorの版／設定／libraryの同一性、
`runner_sha256`の一致、`runner_changed`がfalseであることを確認します。互換でない記録を合算しません。
Git対象外のファイルなので別hostにはない場合があり、許可された設定と版管理するrunnerで再測定します。
[記録の集約](results.ja.md#記録の合算)も参照してください。

## 残作業と優先候補

次の候補は優先順位の提案で、承認済みの除外やカバレッジ率ではありません。
追加作業を選ぶ前に、backlogを再生成してください。

既存テストの対応付けqueueは、すべてのrootで空です。未評価の識別子1,655件を規格と照合し、
見出しと規範的義務を区別して条件を分解し、新たなテストを選びます。
一部分解済みの領域でも、有意なdefault、失敗、独立性、順序、lifecycleの組合せを優先します。
oracleを導く前に、API欠落とsignature／本文の矛盾を確認します。

現在の要求案には、直接テストの未対応はありません。memory-walkの限定した歴史的解釈を含め、
直接対応のqueueを解消しますが、M1〜M4の完了ではありません。その解釈と残る識別子1,655件を照合し、
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
