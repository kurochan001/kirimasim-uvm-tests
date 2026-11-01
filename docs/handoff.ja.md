# 開発ハンドオフ

[English](handoff.md) · [README](../README.ja.md) · [要求台帳](requirements.ja.md)

## 引継ぎ時点と目的

2026-11-02に、M1〜M4の14回目の拡充後の`main`、
[3329a52](https://github.com/kurochan001/kirimasim-uvm-tests/commit/3329a52addc6d09b4979c757af5af45dc87f5bf4)
を対象として作成しました。この資料の追加前は作業ツリーに差分がありませんでした。
今回は資料の追加で、シミュレーションや実測の追加はありません。再開時にbranchと作業ツリーを確認してください。

このプロジェクトは、kirimasimを対象にIEEE 1800.2-2020 UVMの適合性を検査します。
SystemVerilog言語だけの再現ケースは[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests)で扱います。
継続中の依頼は、M1〜M4の対応が薄い領域を補強することです。M4は進行中で、M1〜M3もそれぞれ未完です。

| 領域 | 現在の記録 |
| --- | --- |
| M1 | 351件：基本object、policy、report、階層、factory、phase、同期、記録、utility |
| M2 | 416件：sequence、sequencer、callback、TLM |
| M3 | 318件：register／memory層と付録E |
| 全体 | 章・付録21 directoryに1085件。照合はすべてAIで、人による照合は未記録 |
| M4 | AI要求案1021件。1017要求を956テストへ直接対応。別control 1件、未対応テスト128件 |
| 規範的な棚卸し | 2,504番号のうち684を一部分解、1,820は未評価。直接テストのない要求案4件 |

`scope_status`は提案、`normative_inventory_complete`はfalse、
`approved_denominator`／`coverage_percentage`はnullのままです。
条項の引用、条項あたり2テスト、未対応テスト0件という状態だけでは、完全な要求カバレッジになりません。
第15章を含む18 rootで既存主引用テストの未対応は0件ですが、規範的義務の分解は部分的です。

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
  [既知差分](known-differences.ja.md)：spec-only全106件。
- [要求ガイド](requirements.ja.md)、[範囲](../coverage/scope.json)、[台帳](../coverage/requirements.json)、
  [テスト索引](../coverage/test_index.json)：M4の正規の状態です。生成inventoryはレビューの補助資料で、
  版管理する入力の代わりではありません。
- [library lock](../third_party/uvm.lock)：Accellera UVM 2020.3.1、`78c06547a2a0`、326ファイル。
  版管理するtoolで取得し、library本体はコミットしません。現在の全検査系は`UVM_NO_DPI`を使います。
- ユーザーがrepository rootへ`IEEE_Std_1800.2-2020.pdf`と
  `IEEE_Std_1800-2023_SystemVerilog.pdf`を配置済みです。Git対象外のlocalファイルで、
  新規cloneにはなく、再配布しません。`/tmp`内の抽出済みtextも一時資料です。
- `out/`の結果はGit対象外のlocal資料です。`/tmp/kirimasim-uvm-thin-fourteenth-*.py`の一時helperは、
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

この記録は、tool単体テスト74件、全1085件のmetadata、台帳／索引、library整合性、現在の入力とevidenceの照合を
通過しています。資料だけの変更では、全シミュレーションの再buildは不要です。実行のsmoke確認は次のとおりです。

```sh
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 1 \
  --json out/verilator-smoke.json tests/u09/test_common_phases_run_in_order.sv
```

[対象コードのCheck](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/41351526515)は参照用です。
最新のworkflow結果はREADMEのbadgeで確認してください。後のcommitによって、このrunが置き換わる場合があります。
local検証だけでCI全体の成功とは扱いません。
Checkはtool、metadata、台帳、library、oracle付きVerilatorを検査し、Ghost、kirimasim、spec-onlyの実行は含みません。
Nightly workflowや結果の自動公開はありません。

## 実測記録と直近の差分

| シミュレータ／library | 記録した結果 |
| --- | --- |
| Verilator 5.052／固定UVM | seed 1・73でpass 979件、known 106件 |
| kirimasim／固定UVM | object-wrapper未対応1076件、それ以前のAPI欠落fail 9件 |
| Ghost／同梱UVM | 各seedでpass 207件、fail 878件。失敗集合は同じ |
| Ghost／固定UVM | 現在の実行ファイルsnapshotでは未測定 |

Verilatorのknown 106件は、seed 1で最初に異なる実行時97件と、API欠落build 9件です。
これらにはseed 73の実行時の証拠がありません。API欠落はtime 1件、sequence-library 6件、HDL-slice 2件です。
`known`と`unsupported`は成功ではなく、106ケースは独立した不具合106件という意味でもありません。
Ghost同梱の結果は固定libraryの動作を示さず、simulatorとlibraryの原因を切り分けません。

直近20件は、簡易照合／enum名変換、response待機／queue clear、register操作記述子です。
18件は両seedで一致し、2件は規範的なspec-only期待値を保持します。

- [簡易plus](../tests/uF/test_is_match_plus_requires_at_least_one_character.sv)：F.3.3.1／表F.1は1文字以上を要求しますが、
  実測したno-DPI fallbackはplusをliteralとして扱います。DPI有効時やPOSIX式の結果は主張しません。
- [記述子の不正index](../tests/u19/test_reg_item_invalid_value_indices_warn_without_changing_existing_data.sv)：19.1.1.2.4は
  warning、writeの無視、readの0を要求します。libraryはwriteを拡張し、warningを省きます。
  読取り／書込みで記述子を分け、個数／個数+1の小さなindexで誤った割当てを有限に保ちます。

集約した記録は、過去の未変更入力を保持し、再測定した記録だけを置換します。1回の呼出しで全件を再実行したものではありません。
現在のhostでは、互換なlocal記録は次にあります。

```text
out/thin-fourteenth-verilator-combined.json
out/thin-fourteenth-ghost-final-1.json
out/thin-fourteenth-ghost-final-73.json
out/thin-fourteenth-kirimasim-final.json
out/thin-fourteenth-inventory.json
out/thin-fourteenth-backlog-final.json
```

再利用前に、test ID集合の完全一致、現在の`inputs_sha256`、simulatorの版／設定／libraryの同一性、
`runner_sha256`の一致、`runner_changed`がfalseであることを確認します。互換でない記録を合算しません。
Git対象外のファイルなので別hostにはない場合があり、許可された設定と版管理するrunnerで再測定します。
[記録の集約](results.ja.md#記録の合算)も参照してください。

## 残作業と優先候補

以下は優先順の提案で、承認済みの対象除外やcoverage割合ではありません。次の追加を選ぶ前にbacklogを再生成してください。

| Root | 要求対応のない既存テスト | 優先候補 |
| --- | --- | --- |
| 14 | 20 | 残るresponse、lock／grab、kill、relevance、完了待機。有限の1 batchでこのrootの対応付けを完了可能 |
| 18 | 62 | register／virtual-register callback、動的割当て、region、model制御 |
| 12 | 46 | TLM 2の時刻、export／socket、payload packing、nonblocking transport |

既存テストの対応付けと並行して、M1・M2・M3で薄い規格上の動作を選びます。
件数だけを増やすのでなく、意味のある既定値、失敗、独立性、順序、lifecycleの組み合わせを優先します。
選択前に既知差分のAPI欠落やsignature／本文の矛盾を確認します。実測と資料更新まで完了できる量に区切り、
対応付けだけでmilestone完了とはしません。

直接テストのない要求案は4件です。

| 要求 | 条項 | 未観測の内容 |
| --- | --- | --- |
| `UVM-POLICY-ACTIVE-POLICY-SYNC` | 16.1.3.1 | object側のactive-policy管理。policy側のdepth／top検査だけでは不足 |
| `UVM-HDL-DEPOSIT` | 19.6.2.2 | HDL deposit。現在の検査系はHDL DPIを無効化 |
| `UVM-HDL-PATH-ACCESSIBILITY` | E.7 | 実際のHDL-path accessibility。現在のno-DPI検査系には未提供 |
| `UVM-MEMORY-WALK-ALGORITHM` | E.6.1 | walking-ones algorithm全体。location maskやstuck-bit故障だけでは不足 |

library／backendの制約で、これらの義務を提案範囲から除きません。
既存テストをすべて対応付けた領域にも、より広い未評価の棚卸しが残ります。

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
> 第14章の残る対応付けを優先候補にし、M1〜M3でも意味のある新しい動作を追加してください。
> 規格に基づく期待値、商用結果の除外、Ghostの非公開性、AI照合状態、完全な日英文書を維持してください。
> 最終入力を測定し、有効なspec-only差分を残して、完了した変更・検証・残る制約を報告してください。
