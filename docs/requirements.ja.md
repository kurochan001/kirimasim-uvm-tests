# 要求台帳の案とカバレッジの棚卸し

[English](requirements.md) · [README](../README.ja.md) · [テストと開発のガイド](testing.ja.md)

## 現在の状態

対応付けqueueの0はテストと義務のlinkを記録した状態で、全動作のcoverageではないため、合計を解釈する前に[対応状況と進捗を読む](reading-guide.ja.md#対応状況と進捗を読む)を参照してください。

M4を進めています。[対象範囲の案](../coverage/scope.json)、[要求台帳](../coverage/requirements.json)、
[番号の分類](../coverage/assessments.json)、[テスト索引](../coverage/test_index.json)を版管理します。AI要求案4151件は、すべて2707テストへ直接対応し、
追加の56テストはcontrol専用です。全2763テストに要求の対応付けがあります。
直接テストとテスト対応付けのqueueは両方0件です。memory-walkのoracleは、レビューが必要な歴史的解釈を明示し、
IEEE全体のcoverageを認定しません。人による照合記録はありません。

control専用テストは補助的な前提を検査するもので、その一致が欠落する標準APIの契約を立証しない理由は[HDL viewの例](faq.ja.md#q308-標準viewとmember-view-controlを分ける理由は)で確認できます。

条項catalogの番号は2,507件です。2062件は要求を一部分解し、445件はAIで明示的に分類（構造296件・文脈149件）、未評価は0件です。
いずれも完了を示しません。M4の開始は、範囲や分母の承認、M1〜M3の完了を意味しません。
`approved_denominator`と`coverage_percentage`は`null`のままです。

ここでの`null`は承認待ちで分母と割合が未設定であることを表し、計算までに必要な判断は[Q77](faq.ja.md#q77-m4を始めたのにカバレッジ率がないのはなぜですか)で説明しています。

## 計数単位と対象範囲の案

文脈のrootにも継承APIのような動作規則が含まれる場合があり、範囲の区分を変えずに義務を分解する具体例は[Q378](faq.ja.md#q378-継承apiのprofileは何を検査しますか)で確認できます。

1つのテストがある義務にはdirect、別の義務にはcontrolとして対応する場合は両方の役割の件数に含まれ、そのリンクの読み方は[対応付けの例](#引用要求実行の証拠)で説明しています。

分母は合意した適用対象の義務集合を指し、要求カバレッジの割合を公開する前にその集合を確定する手順は[残作業と承認](#m4の残作業と承認)にあります。

義務とは、特定の条件で規格が要求する1つの動作を指し、条項番号やテスト件数との違いは[カバレッジの用語](glossary.ja.md#範囲とカバレッジ)で説明しています。

適用条件を伴う、観測可能な規範的義務を1要求とする案です。methodの1条項にも、成功、失敗、default引数、
順序、副作用など、複数の要求が必要な場合があります。見出し自体は義務ではありません。
4151件の要求案は複数領域にわたりますが、その条項内の全義務を列挙したものではありません。

既存の番号catalogのすべてのrootを、1つずつ次に割り当てます。

| 区分 | Root | 番号の件数 | 意味 |
| --- | --- | --- | --- |
| 対象候補 | 5〜19、B〜G | 2,482 | 規範的な動作を読んで要求に分解する |
| 文脈 | 1〜4 | 16 | 範囲、参照、定義、略語。解釈には引き続き使う |
| 保留 | H | 9 | 非推奨APIの範囲は別途決定。除外の承認ではない |

これは要求数ではなく番号の件数です。付録Aは参考情報で、このcatalogにはありません。
この棚卸し自体はcatalogの完全性を独立に保証しません。規範／非規範の区別には規格を読む必要があります。
ライブラリの欠落、既知差分、未実装のHDL／DPI、backendの利用可否によって対象候補の義務を暗黙に削除しません。
SystemVerilog言語自体の要求はkirimasim-testsで扱い、言語やHDL機能に依存するUVMの要求は候補に残します。

分解にはユーザー提供のIEEE 1800.2-2020を使います。要求文は条項番号を伴う独自の日英の要約であり、
規格本文の転載や実装から導いた期待値ではありません。商用シミュレータの結果は
[投稿方針](faq.ja.md#商用シミュレータとissueの投稿方針)に従って引き続き除外します。
台帳のツールはシミュレータの実行結果を読み込みません。

## 引用・要求・実行の証拠

directとcontrolは、義務を直接検査するか、準備や条件の評価を助けるかというテストの役割を記録するもので、以下の例に出る役割は[範囲とカバレッジ](glossary.ja.md#範囲とカバレッジ)で説明しています。

次の図では、条項の引用、レビューした要求の対応付け、測定結果の関係を示します。
台帳は期待出力への対応を検査し、実行記録は測定したstatusと条件を保持します。

![条項の引用、明示的な要求の対応付け、別途測定する実行の証拠の関係。](images/requirement-evidence.ja.svg)

テストの最初のUVM `:lrm:`参照を**主引用**、後続のUVM参照を**補助引用**と呼びます。
catalogのうち主引用がある番号は1320件、どちらかの引用がある番号は2,096件です。
補助引用は準備に使うAPIの場合もあります。引用から要求の対応付けを自動生成せず、子条項の参照を親条項へ自動集約もしません。

対象候補2,482件について、従来の「各条項2テスト」の主引用の棚卸しは、0件が1,167、1件が764、2件以上が551です。
これはテストの配置を測るだけで、2つの独立した検査があること、規範的な義務を分解したこと、実行が成功したことを示しません。
承認された要求の分母ではなく、主引用0件の全条項が不足だと宣言するものでもありません。

検査系を辿るには[要求台帳](../coverage/requirements.json)の`test_links`でテストIDを探し、その要求の条件と限界を読み、対応付けと照合するソースの条項引用は[ヘッダーの案内](testing.ja.md#メタデータ)で確認してください。

`UVM-CLONE-DISTINCT`などの要求IDは、テストのfilenameとは独立した安定した名前です。
5.3.5.2の2つの要求は同じ条項を使い、別handleの生成と、後続のscalar変更の独立性を別々に検査できます。
callbackの要求`UVM-VREG-FIELD-POST-WRITE-ORDER`は、field単独のテストを直接、親virtual registerのwriteをcontrolとして対応付けます。
controlは検査系を評価する助けになりますが、その要求の直接の対応には数えません。

実際のIDで辿る場合は、`UVM-PHASE-COMMON-ORDER`とソース、期待出力ファイルの関係を[スモークテストの例](reading-guide.ja.md#1件のテストをファイルで辿る)で確認できます。

runtimeの対応には、汎用の期待出力にある正確な`UT: `行を登録します。この**期待する観測**は期待値への対応であり、
実行成功の観測ではありません。1行に別の義務の観測が含まれていても、この要求がすべてを検査する意味にはなりません。
checkerは参照、field、期待行の存在、入力の同一性を検査しますが、実際に要求を実行することやassertionの十分性は証明しません。
テスト、構成、規格のレビューが必要です。期待出力の順序はrunnerが検査し、台帳で行の存在を確認するだけでは順序や反復回数を保証しません。
同じ期待行の繰り返しはanchorに1回だけ登録し、runnerは引き続き期待する全行の並びを比較します。

[実行の証拠](results.ja.md)は別に扱い、入力、runner、ライブラリ、設定の同一性が必要です。
直接の対応先にもspecのみの既知差分があり得ます。対応自体は成功や適合性の主張ではありません。
現在の2763件には新たに測定した検査系を含みます。変更していない既存テストの対応付け自体は、追加の実行結果ではありません。

## 版管理するデータと生成する棚卸し

schemaの版はJSONの項目構成を識別するもので、UVMライブラリの版とは別に管理し、実行用の版を固定するlockは[ライブラリの準備](testing.ja.md#uvmライブラリ)で説明しています。

各要求の`conditions`は義務が適用される条件、`expected`は観測すべき結果、`limitations`は現在の主張の限界を示し、1つのAPIに複数の要求が必要な理由は[計数単位](#計数単位と対象範囲の案)で説明しています。

正本は保守する元データ、inventoryとbacklogはそこから生成する表示であり、新規cloneで利用できる資料の範囲は[引継ぎ資料のファイル案内](handoff.ja.md#ファイルとローカル資料)で確認できます。

正本JSONはUTF-8で、scope／分類／test indexはschema 1、要求台帳はschema 2です。checkerは出力対応だけのschema 1台帳も読めます。生成inventory／backlogはschema 2のまま、`ledger_schema_version`を別に記録します。未知のfield、重複key、重複する要求ID、未知の条項／テストを拒否します。

- `coverage/scope.json`は、日英の計数単位、rootの区分、従来の主引用の目標を記録します。
  schema 1で表せるのは、承認済み分母のない未完の範囲案だけです。
- `coverage/requirements.json`は、安定したID、条項、日英の`statement`、`conditions`、`expected`、`limitations`、
  `review`、`test_links`を記録します。対応にはtest IDと`direct`／`control`の役割を持たせ、runtimeの`expected_observations`またはschema-2の`expected_diagnostic`という期待形式を正確に1つ指定します。
  直接の対応先は要求の条項を引用する必要があり、レビューで対応を確認すれば補助引用でも構いません。
- `coverage/assessments.json`は、個別に読んだ構造／文脈の番号について、日英の`rationale`、
  `related_requirements`、`review`を記録します。`structural`は独立した動作のないAPIの区切りで、関連要求を持ちません。
  `contextual`は他で分解した動作の説明で、既存要求を必ず指定します。
  同じ条項に分類記録と要求entryを併置できません。分類を適用できるレビューは`ai`／`human`だけで、
  `unreviewed`のまま未評価queueから除去できません。見出しの自動分類は行いません。
- `coverage/test_index.json`は、全テストの`primary_clause`と`inputs_sha256`を記録します。
  指紋は既存runnerの収集処理を使い、source、宣言したhelper／include／data、期待値file、UVM lockを含めます。
  索引は棚卸しであり、2763件のレビュー済み要求対応ではありません。

compile診断の対応には`stage: compile`、検査系の`:expected_stderr_regex:`と完全一致する空でない有効regex、`:type: elaboration`、空でない`:should_fail_because:`が必要です。
その検査系にruntime出力／終了の期待は持たせません。未知／混在field、不正stage、不正／古いpattern、未対応schema版を拒否します。
schema 1の出力対応の契約は保持します。構造は次のとおりです。

以下の`<exact :expected_stderr_regex: value>`はテストのヘッダーにある実際の診断patternを入れるための仮の値であり、patternの指定方法は[メタデータのガイド](testing.ja.md#メタデータ)で説明しています。

```json
{
  "test": "u12/test_uvm_tlm_extension_base_abstract_declaration_rejects_direct_construction",
  "role": "direct",
  "expected_diagnostic": {
    "stage": "compile",
    "regex": "<exact :expected_stderr_regex: value>"
  }
}
```

patternは期待oracleであり、検証はcompiler logを読まず、成功も証明しません。実際の拒否と一致errorはrunnerで測定します。
[拒否検査系](../tests/u12/test_uvm_tlm_extension_base_abstract_declaration_rejects_direct_construction.sv)と、未変更の[合法runtime control](../tests/u12/test_tlm2_extension_defaults_and_legal_subclasses_preserve_names_and_object_views.sv)を比較してください。
control対応は要求の直接対応には数えません。

レポートにはsimulation／elaboration件数の`test_types`と、rootごとの`primary_test_types`を追加します。
主引用の合計は引き続き検査系を数え、規範的な計数単位と範囲は変えません。tag付きcompile拒否の一致は実行時seed結果ではありません。
既存runtime anchor、古い入力の検出、以前の要求objectは全て保持します。

照合状態は`ai`、`unreviewed`、`human`です。humanには識別可能な`reviewer`と、`reviewed_at`のISO日付が必要です。
他の状態では両方を`null`にします。照合したという記録であり、checkerが本人性を認証するものではありません。
要求を変更しても、人が再照合したことにはなりません。

リポジトリのrootから実行します。

```sh
python3 tools/requirements.py check
python3 tools/requirements.py inventory --json out/requirements-inventory.json --lang ja
python3 tools/requirements.py sync --output out/test-index-proposal.json
```

`sync`は既存の対応済み記録を保持してレビュー用の案を出力し、テスト変更後に古くなった索引を直す方法は[Q78](faq.ja.md#q78-テスト索引が古くなったらどう直しますか)で説明しています。

これらのコマンドはシミュレータを実行せずに要求の対応付けを調べるもので、測定したテストの判定を得るには[runnerのコマンド](testing.ja.md#スイートの実行)を使います。

`check`は正本の入力を検査して概要を表示します。`inventory`はさらに、全番号の区分、分解状態、主引用／補助引用、
要求の対応、照合／oracleのmetadata、指紋、root別の集計を出力します。
各番号には、次の分解状態を1つ割り当てます。

| 状態 | 記録している内容 | 残るレビュー |
| --- | --- | --- |
| `partial` | この番号について1件以上の要求がある | 残る義務と適用条件を確認する |
| `assessed` | 根拠を伴う構造／文脈の明示的な分類がある | 分類と、文脈の場合は関連要求をレビューする |
| `unassessed` | 要求も明示的な分類もない | 条項を読み、義務を分解するか根拠を伴う分類を記録する |

`partial`の識別子は`unassessed_identifiers`に出なくても残る義務の確認が必要であり、解決すべき作業は[残作業の案内](#m4の残作業と承認)で確認できます。

いずれの状態も完了や網羅を意味しません。生成する分母と割合は`null`を保ちます。
`--lang en`／`--lang ja`は概要の表示言語を選び、JSONのkeyと安定した識別子は変えません。
`out/`の生成物はGit対象外で、生成出力は4つの正本を上書きできません。

## レビュー用の未整理項目とroot別集計

`backlog`の3つのqueueは`partial`識別子の残る条件を網羅しないため、次のテストを選ぶ前に`inventory`を再生成して該当条項を読み、そのレビューが必要な理由は[Q390](faq.ja.md#q390-未評価の識別子0件なら残作業も0件ですか)で確認できます。

rootは識別子をまとめる最上位の章または付録なので、各行の件数とcoverage割合の違いは[範囲とカバレッジ](glossary.ja.md#範囲とカバレッジ)を参照してください。

`backlog`で台帳を編集せずに作業項目を取り出します。

```sh
python3 tools/requirements.py backlog --json out/requirements-backlog.json --lang ja
python3 tools/requirements.py backlog --root E --json out/requirements-backlog-E.json --lang ja
```

`--root`は`backlog`だけで使え、`5`、`17`、`E`のようにcatalogの正確なrootを指定します。
未知のroot、子条項、`u05`のようなdirectory名は拒否します。取り出しの前に正本の台帳／索引全体を検査するため、
別rootの古い対応をfilterで隠すことはできません。

JSONは、`requirements_without_direct_tests`（controlのみも含む日英の要求案全文）、
`tests_without_requirement_links`（どちらの役割の対応もないテストのmetadataと指紋）、
`unassessed_identifiers`（要求も明示的な分類もないcatalogの番号）を分けます。
`identifier_assessments`には、選択した分類の根拠、関連要求、レビューを含む全記録を別に保持します。
レビューの作業一覧であり、確定した適合性の不足ではありません。文脈／保留の番号も区分付きで残し、分母と割合は未設定のままにします。

`inventory`と`backlog`には`roots`の集計があります。要求は自身の条項のroot、テストは主引用のrootに属します。
そのため、第17章の要求から付録Eのテストへ対応付けても、そのテストを第17章の主引用数へ移しません。
子条項の件数を親要求の認定へ集約しません。複数の要求が1テストを共有でき、1要求に複数のテストを対応付けることもできますが、
共有する期待出力の1行にある全anchorで独立した網羅を示す意味にはなりません。

主引用テストのある次の22個のrootの既存主引用テストをすべて対応付けましたが、規範的義務の分解は部分的なままです。

各行は要求をその条項、テストを主引用の番号で数えるため、対応するテストが別のrootに属する場合の読み方は[Q79](faq.ja.md#q79-次にレビューするm4の項目はどう取り出しますか)で説明しています。

1つのテストが複数の義務、1つの義務が複数のテストに対応するため、主引用テスト数を要求案の数で割ってcoverageを計算できないことは[対応付けの例](#引用要求実行の証拠)で確認できます。

表には文脈・保留を含む全catalog rootを残し、文脈root 1のnamespace、乱数状態、真偽返却、継承、名前のcaseの義務はそれぞれ主引用F.1、1.4.6、1.4.2、1.4.3、1.4のテストで、段階0のimportの義務は主引用1.4.5のテストで検査するため、要求件数と主引用テスト件数が異なる理由は[対応付けの説明](#引用要求実行の証拠)で確認できます。

| Root | 要求案 | 主引用テスト | 対応のないテスト | 分類済みの番号 | 未評価の番号 |
| --- | --- | --- | --- | --- | --- |
| 1 | 21 | 39 | 0 | 6 | 0 |
| 2 | 0 | 0 | 0 | 1 | 0 |
| 3 | 0 | 0 | 0 | 3 | 0 |
| 4 | 0 | 0 | 0 | 1 | 0 |
| 5 | 181 | 100 | 0 | 12 | 0 |
| 6 | 170 | 68 | 0 | 19 | 0 |
| 7 | 91 | 35 | 0 | 20 | 0 |
| 8 | 90 | 69 | 0 | 12 | 0 |
| 9 | 141 | 63 | 0 | 22 | 0 |
| 10 | 169 | 144 | 0 | 29 | 0 |
| 11 | 38 | 22 | 0 | 4 | 0 |
| 12 | 330 | 206 | 0 | 45 | 0 |
| 13 | 153 | 58 | 0 | 21 | 0 |
| 14 | 230 | 147 | 0 | 17 | 0 |
| 15 | 134 | 125 | 0 | 18 | 0 |
| 16 | 281 | 189 | 0 | 32 | 0 |
| 17 | 42 | 11 | 0 | 8 | 0 |
| 18 | 942 | 652 | 0 | 63 | 0 |
| 19 | 203 | 167 | 0 | 24 | 0 |
| B | 266 | 241 | 0 | 9 | 0 |
| C | 104 | 74 | 0 | 13 | 0 |
| D | 120 | 28 | 0 | 8 | 0 |
| E | 114 | 88 | 0 | 20 | 0 |
| F | 284 | 214 | 0 | 25 | 0 |
| G | 47 | 23 | 0 | 4 | 0 |
| H | 0 | 0 | 0 | 9 | 0 |

この表は主引用テストがないものも含むcatalogの全26rootを示し、文脈・保留の行も未評価合計に残す理由は[範囲の用語](glossary.ja.md#範囲とカバレッジ)で確認できます。

未対応テスト0件と直接テストのない要求案0件は、完全な要求coverageを示しません。
部分2062識別子は残る義務と適用条件を[完了条件](#m4の残作業と承認)に従って確認する必要があります。
範囲は提案、4151件のレビューはすべて`ai`、分母は未承認です。

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

TLM 1要求案は、選択interface／port既定値、FIFO照会、公開export method、channel継承／既定値／constructorとqueue容量を扱います。
実analysis impと多段exportは、選択subscriberへの配送、subscriberごとの順序、live handleを保持します。
要求／応答channelは両queueを既定1枠とし、結合transport channelは両方を1枠に固定します。
12.2.9.2の再読で独立した容量義務が判明したため、以前の文脈分類を削除し、直接要求2件へ置き換えます。
概要を除外とせず、元の範囲を保つための修正です。

TLM 2要求案は、extensionの既定値／合法継承／名前の受渡し、8種全socket宣言、通常port／exportとimpの既定値、選択した正確なtransaction／phase基底viewを扱います。
実port／exportはimplementationを明示名で指定したimpへ委譲します。実socket 2組で、明示workerと省略時の互換親を両方向で区別します。
独自phaseを両nonblocking relay familyに通し、blocking relayは独自targetの完了まで待ち再利用できます。
これらの実装は設定であり、規定data algorithmや完全な物理bus／base protocolではありません。

新規83要求案を新規12検査系へ対応し、以前の要求と検査入力は全て保持します。個別に読んだmethods／整理見出し12件を構造分類します。
規範的なsocket／extension概要は部分分解に残し、IS-A／HAS-A、適用条件、bindingの残る義務を保持します。
第12章は部分分解169番号・分類45番号・未評価0番号ですが、324要求案とM1〜M4全体のgoalは未完です。未評価番号0は完全な規範的coverageではありません。

12.3.5.7.4／12.3.5.8.4のblocking pass-through connect見出しに印刷されたnonblocking provider型を逐語的に使う受理probe 2件はseed 1で拒否されます。
実動blocking比較対象は一致しますが、矛盾する型一覧は解決しません。
別の限定probeは同種terminator制約を「直接provider entryを残さない」と解釈します。initiator呼出しはERRORを報告しながらraw entryを保持し、target呼出しは残しません。
規格は不正呼出し後の一覧状態を明記しないため、実装不具合の証明ではなく、照合が必要な解釈差分として残します。全3件の期待出力を保持し、seed 73結果はありません。

P／parameter構文を省略した印刷connect signature、forward portのbackward経路の本文、他の抽象／pure-method条件、不正user extension、名目的IMP=int、全member所有関係、全protocol／timing組合せ、bus規則は別の部分分解義務に残ります。
以前のpayload rand／constructor／virtual照会probeは有効で、response-stringのvirtual委譲から基底text形式は規定しません。

通常portの独立RSP=int宣言build差分は残り、channelのRSP既定値は明示的にREQへ従います。
constructor専用probeは実行時bindingを証明しません。概要alias／imp parameter、容量0のis_full文言、payload長さ不一致の文言、response-string表現、target／interconnectのbus義務、広い並行互換性／protocol組合せは未完です。

objection／callback要求案は、選択したconstructor／基底／型宣言、propagation-mode照会、idle時の合法変更、raised／drain中変更のERRORを扱います。
実際の既定objection hookは、source／description／count metadataを伴い、独自component methodと明示enableした登録callbackを呼びます。
正のdrainとcallback body遅延で、source hookがdrain後に実行され、root伝播が待機していることを検査します。local countとdescendant totalは別々に観測します。
CB省略のadd／deleteは有効な登録組、型付き列挙、実際の型付き委譲を使います。

以前の13検査系の監査では、M1のobjection／heartbeat 9件とM2のgeneric callback 4件へ、objection／callback要求案28件を追加しました。
その構造7件・文脈7件の分類は保持します。get_globalの2番号を分解した現在の第10章は、部分87・分類29・未評価0です。
返却型の食違い2件は限定した前提に残し、[照会のFAQ](faq.ja.md#専用global照会と対応付けの修正)で説明しています。
callback_modeの省略引数にも宣言／本文の値の矛盾があるため、新しい状態検査ではすべて明示引数を使います。mode 0の選択callback経路は一致しますが、
中間total照会は、照会定義が要求するdescendant件数ではなく0を返します。その検査系全体をspec-onlyに保持し、経路の正しさを完全なpassにはしません。

同期要求案は、選択したconstructor／型宣言、raw／persistent trigger待ち、受理triggerの時刻・状態・data、live objectとscalar payloadの違い、
実際のwaiter計数、barrier threshold引上げ、wakeupなしresetを扱います。event-pool初期所属は、lazy getで名前付き項目が生成される前に調べます。
選択した検査系はconstructor、待機／状態／data、barrierの狭い条件を扱い、各条項の義務や適用条件を尽くしたものではありません。

rawの早い／遅い待機検査は、trigger前に最初のwaiterを確立します。保持する差分は早いcallerに関するもので、遅いcallerは新triggerまで待機します。
wakeupなしevent resetでは3 processが待機を保持しますが、固定版のwaiter照会は0を返し、後の新triggerでは3つとも再開します。
barrierのsilent-reset／新threshold比較対象は一致し、固定版event poolには必要な初期3名がありません。pool get_globalの戻り型宣言はitemを返す本文と矛盾し、現在は両識別子を部分分解して、その食違いを[専用照会のFAQ](faq.ja.md#専用global照会と対応付けの修正)で保持します。
delta遅延option、任意並行性、callback mode、より広いreset／中止条件は別に残します。

register連携の要求案は、選択したitem／adapter／backdoorの名前と継承、virtual subtype formatter、既定function-based read、
最初／最後にprotected helperを置く遅延task-based read、callback pipeline、実際のregister translation、run前のpredictor設定を扱います。
直接／layered translation検査系は実際のupstream／bus sequencerと遅延する独自driverを使い、失敗／再試行の検査は戻るstatus／dataを保持します。
既定BASEのvirtual sequenceはmodel propertyから独立した2 blockへ実際の便利accessを行います。constructor／型とno-DPI HDL parameterの別probeには狭い制限を保持します。
第19章の現在値は部分分解87番号・分類24番号・未評価0番号です。以前の9分類は個別の根拠を保持し、現在の追加と制限2件の改訂は上記に記録しています。

callback encode／decode要求案は呼出し順序と値の伝播を区別します。2要素のuser-backdoor 4検査系は固定libraryの差分があっても、規格から導いた変換値を保持し、
既定callbackの無変更動作を別の一致する比較対象にします。選択したtask-read境界条件には直接検査系ができましたが、
広い中止／並行性、write宣言の曖昧さ、既定formatterの完全性、parent_sequenceのdo_clone、待機predictorの診断severity、広いforce／release条件は未完です。
新規検査系は物理DUT trafficや任意protocolを認定しません。

sequence要求案は、宣言されたitem／base／generic／libraryの継承、request／response型の既定値、標準protected実行counter field、
選択した巡回selectorのbound／cycle／部分集合、relevance待ちの中止を扱います。protected fieldの直接probeは欠落した公開getterを認定せず、
selectorの直接randomizeも欠落mode APIを通すRANDC mode実行を認定しません。counter 2検査系はbound sequencerを使い、driver itemなしで合法な既定10子回数を使います。
個別に読んだ導入／例5件は関連要求のある文脈として分類し、第14章は部分分解89番号・分類17番号で未評価0件です。
既存6要求へ直接link 9件を追加し、以前のlinkとsimulation入力を保持してcounterの制限注記を明確化します。
未変更の既定RAND 3検査系には導入の対応付けを加えます。引用やlinkの追加だけで、独立した完全な2検査を認定しません。

command-line要求案は、明示した実process VPI条件を使い、生成時snapshot、report-object継承、singleton同一性、
全引数／plus／UVMのfilter、literalと選択したextended-regex照合、suffix件数／値、組込みoption全9条項を扱います。
選択条件で実際のfactory生成、報告設定／override、時刻変更、quit-count lock、configの数値base／文字列、phase default sequenceを動かします。
annex Gは部分分解18番号・個別に読んだ構造分類4番号で、未評価0件です。regex suffix抽出、広い式、重複optionの各条件、
wildcard／ALLの組合せ、追加phase／resource条件は残ります。native 1件は、固定serverがINFOを発行するquit変更に対し必要なWARNINGを保持します。
通常の未link buildと別native結果は区別し、coverageの完了にはしません。

register-global要求案は、既定／設定変更時の型幅、記載されたenum symbol、coverage選択の組合せ、公開slice field、標準concat constructor／accessorを分けます。
宣言検査は4-state保持やenum選択の操作上の意味を認定しません。第17章は部分分解22番号・明示分類8番号で、未評価番号0件です。
X／Z保持、enumで制御する後段の操作、application／user coverage割当、保持名の観測は残る条件です。
concat 3検査系はAPI欠落buildを保持します。個別に読んだ整理用見出し6件を構造、既存義務を指定した2件を文脈とし、macro 4条項も一部分解します。
M1〜M4の全未対応を解消するgoalは継続中で、この件数は完了を認定しません。

object要求案はstatic／dynamic proxy、現在の型名による既定照会、factory contextと独立したleaf名、直接のvirtual印字hookを分けます。
sequence報告の要求案は現在handler、reporter生成元、生成／再利用context、severity admissionを追跡し、最後の条件はclass固有の解釈差分を保持します。
非一様TLM-adapter要求案は往復変換の有効bit、mask、status、独立したpayload配列を検査し、片方向の絶対byte順や有効bitの逆再構築は認定しません。
階層file要求案は4設定の再帰、優先順位、狭めたsubtree、外側peerを検査します。未変更のobject／印字検査系3件にも対応付けます。
個別に読んだ見出し3件を構造、sequence報告の導入を関連要求のある文脈として分類します。
手動照合した3番号をcatalogへ復元したことは[出典](provenance.ja.md#条項カタログの保守)を参照してください。

handler要求案は、実際の公開委譲、指定／生成したfield、handler共有、置換後のroutingを観測します。
relevance要求案は、全員待機、実行可能なpeer、再開後のgateを扱い、正確なpoll回数は固定しません。
標準TLM-adapter要求案は、新規payload、5 error status、表現できるoperation fieldの再利用、contextを限定したactive frontdoorを扱います。
byte長からsub-byteの有効bit範囲への逆対応は未整理とし、特定のn_bits再構築は要求しません。
未変更の設定検査系3件に対応付け、個別に読んだ見出し4件を構造として分類します。

事前構成messageの要求案は、現在handleの同一性、公開setterのlive変更、生成元の再設定、reporterのactionを扱います。
該当3検査系は標準API欠落を保持し、実行時結果はありません。報告の受付はINFOの上限と他severityを分けます。
既定sequencerのないlock／grab／unlock／ungrabは、検査系の制御した終了で必須fatal severityを観測します。
field要求案はbyte共有、byte境界をまたぐ配置、narrow busのendian条件を加えます。未変更の3検査系にpriorityとfield照会の要求を対応付け、新測定は加えません。
個別に読んだ整理用見出し4件を構造として分類します。

追加のcatcher要求案は、6 fieldの変更、変更後のgetter、次の報告の状態、明示したfile名／行番号を分けます。
sequenceの解放要求案は、既定／明示対象、peerのblocking、lock／grabの相互解放を分けます。
未変更の3検査系に、直接killとsequencer stopに対するdo_killの直接対応を加えます。追加測定ではなく、別hookの結果は保持します。
field要求案は個別アクセスの可否、byte lane選択、隣接する実際の値／mirrorの独立性、全registerへのfallbackを区別します。
個別fieldの選択条件2件は、固定libraryと差があっても有効な期待出力を保持します。個別に読んだmethod見出し4件を構造として分類します。

catcher要求案はhelperの迂回、severity／IDの発行、reporter identity、外側報告の続行、現在IDの変更、
即時issue後のCAUGHT／THROWを分けます。sequence要求案は、明示したdeep印字でreq／rspの初回、置換、null化を区別します。
adapter要求案はregister write、反復read、失敗writeの再試行、memory readの復帰について、別responseのidentity、status、
変化する値、response変換中のcontextを追跡します。個別に本文を読んだ整理用の見出し4件を構造として分類します。
選択した義務であり、各APIの網羅的な分解ではありません。

heartbeat要求案は、mode選択、不在／置換／再利用するevent、stop、参加者変更を含む正常なALL_ACTIVE windowを区別します。
payload要求案はmethod別のvirtual-dispatch義務14件と、既存setter観測11件の明示対応を加えます。
transactionのhook／時刻照会の要求6件は、未変更の1検査系を使います。FIFO要求案は公開abstract queue、容量、popしないget、
debug引数の非機能性、選択したinline／subtype制約を扱います。FIFOのbus access、compare、そのための初期化は未完です。
payload memberの導入は文脈として分類し、下位のattribute所有規則とtarget／transportの義務は、残る適用条件を別にレビューする必要があります。

constructor要求案は、recording database／stream／link、sequence型、register fileの名前省略・明示・明示的な空文字を分けます。
prefilled linkでは既定名とinstanceの独立性を追加します。未変更M2検査系5件へ、setter、randomization gate、handler照会、
current-itemの義務を明示対応し、新しい実行は主張しません。register file要求案は、configure、symbolicなlocal／full path、
abstractionの分離、clear、flatten scope、近い既定値の選択を扱います。存在／local pathの照会は包含先の既定値を使い、
full path／defaultの照会はそれぞれの契約に従います。継承する既定値の期待2件は固定libraryとの差分を保持します。

recording要求案は、close失敗／再試行、stream／recorderのnull結果gate、正確なcallback metadata、
link dispatch、close済み・free前endpointを追加します。未変更のhook検査系4件にもbackend／endpoint hookの明示対応を加え、
その追加実行は主張しません。sequence要求案は、optional body hookと必須start hook／parent callbackを区別し、
完了start間のphase／automatic objection変更を検査します。model要求案は、virtual-fieldのlocal／既定／明示再帰、
simple nameのscope、map内容の解除を区別します。block／mapの子孫名検索は、固定libraryの実測差分を保持し、
論理block階層とaddress-mapのsubmap階層を分けます。

abstract registry要求案は、virtual型proxy、明示／既定名、現在factoryへの初期化、具象型／instanceのoverride、
error／null callbackを区別します。component要求はparentあり／なしを別条件にし、parentなしcallbackのnull参照結果を保持します。
IDコピー要求案は、非公開sequence ID accessorを使わず、2つのlive response経路、transaction値のコピー、payload／名前の保持を検査します。
parent変更の要求案は、固定libraryのcacheが古くても現在chainのdepthを要求します。
map要求案は、生成引数、local一覧／default、明示doorの置換、register／memory／static virtual overlayの解除、
同名child内容の保持を扱います。

registry要求案は、specializationごとのsingleton同一性、明示／既定型名、represented instanceを生成しない取得、
新しく選択したfactoryへの登録と、factoryを通したcallback生成を区別します。
履歴要求案は、容量0でも実際の転送を行い、再有効化、新しい順の保持、正確なhandle共有、peer分離を検査します。
block要求案は、再帰lock／offset検索、lock状態の照会、mode伝播、構造変更のためのunlock／再構築、
lock待機、絶対／相対のblock検索を区別します。method／queryの見出しは個別に読んでから分類し、
新たなpassや、条項を網羅的に分解したという主張を加えません。

configuration要求案は、既定／無効のbuild dispatch、scope照合、正確なresource／UVM_SET dispatch、
hook順序、抑制と再利用を観測します。resource 4検査系は、既定／明示strict buildの差分を保持します。
port要求案は、resourceで制御する階層check、不正な出力role、cardinality診断を追加します。
memory policy要求案は、address単位の長さ、bound、制約／手続きstart、既定の選択、正確なin-use handleを観測します。

個別に読んだ445番号の根拠とAI状態を、[分類file](../coverage/assessments.json)に保持します。
第11章に未評価番号はありませんが、動作条項の分解はすべて部分的で、coverageの完了ではありません。
自動分類、親への集約、承認済み分母は導入しません。

[memory-walk検査系](../tests/uE/test_memory_walk_address_data_relations_follow_the_documented_historical_interpretation.sv)は、
記録した歴史的解釈の下で、algorithm固有の観測を追加します。
[Q134](faq.ja.md#q134-memory-walk-algorithmをどう解釈していますか)を参照してください。
location maskや固定bit故障をalgorithmの証明へ昇格せず、解釈はIEEEの改訂や人の承認ではありません。

container要求案は、名前／既定specialization、参照共有、key置換／所属、queueのsize／順序、
合法／不正な取得、空でないpop、index指定／既定の削除を区別します。
第11章の各method条項に部分的な分解があり、章／methodの見出しは構造、概要は文脈として分類します。
すべての条件や、要求ごとに独立した2検査を認定するものではありません。

双方向export要求案は、9種類の具象constructor、入れ子blocking／nonblockingの独自型、status伝播、再利用を扱います。
未変更のmaster／slave検査系2件にも、方向を明示するexportの対応を加えます。
HDL要求案は、明示／既定abstraction選択、zero-time force_timeの委譲を扱います。
現在は別HDL条件で選択した正時間の観測も測定し、その範囲とtask戻り値を規定しない理由は[期間のFAQ](faq.ja.md#正時間force_timeの観測)で説明しています。

port-base要求案は、省略したconstructor bounds、最小／最大の照会、無制限状態、leaf／完全名、
正確なparent、role predicate、generic型名、provider／client所属、export fanout解決を区別します。
exportのdefault-index要求案は、初期選択とelaboration後の再選択を分けて観測し、providerのindex順は指定しません。

HDL depositと利用可否には、[明示的なVPI条件](testing.ja.md#verilatorのvpi-hdl部分集合)で実際の公開変数を使う直接検査系を追加しました。
追加の対応は、pathの存在、40 bitの非破壊read、存在しないpathのread失敗、既定abstractionで利用可能なpathの比較対象です。
与えたbackendの実測で、vendor overlayやguestの結果ではありません。
E.7のwarning／転送なしの解釈は、固定sequenceがERRORを報告してreadを試みる差分を保持します。
これらの対応は、実行結果を成功へ変換せずに、直接テストの未対応2件を解消します。

最後の既存テストの対応付けは、TLM 1の分離implementation、nonblocking request／replyの結果と再利用、
TLM 2のblocking／nonblocking export、socketの戻り経路、passthrough中継、payload packing、
canonical time APIを区別します。endpointの計算とresponse生成は検査系のcodeです。
transport失敗時の部分request作用、任意phase protocol、失敗出力値、生packed-bit順は推測しません。

registerの対応は、metadata、map rightsの共通部分、選択したwrite-zero prediction policy、
pre／post methodとcallbackの作用、登録解除、明示順序を区別します。
virtual-registerの対応は、static／dynamic配置、allocation、再配置／release、field slice、
owner／map／addressの同一性を扱います。memory-managerの対応は、重複／bounds、
完全なlocationへの切上げ、制約allocation、iterationの所属、互換reconfiguration、
相対frontdoor変換を扱います。model化bus accessは、物理DUT、DPI backend、
walking algorithm全体の成立を示しません。

新しい[policy／object同期テスト](../tests/u16/test_policy_object_stack_tracks_nested_active_policy_push_and_pop.sv)は、
標準のobject側getterで、入れ子の2 policyを観測します。pushの記帳とpop後の復元の両方へ対応付け、
API欠落による既知のbuild差分を保持します。既存のpolicy側stack検査だけでは、この観測を満たしません。

以前の対応と制限は、core service、recording、phase、同期、utility、sequenceの所有／lifecycle／response制御、
registerの転送／prediction／coverage、convenience wrapper、付録Eのdispatchを扱います。
動作の境界と以前の拡充は、[FAQ](faq.ja.md)、[既知差分](known-differences.ja.md)、
[拡充の履歴](history.ja.md)を参照してください。B.5.11の呼出し、FIFOの失敗出力、
stream列挙の戻り数など、signature／本文の矛盾は、引き続きレビューが必要な解釈です。
対応付けは、実測pass、人の承認、承認済み分母を追加しません。

## 生成レポートの識別

`ledger_inputs_sha256`は要求の対応付けの入力、`inputs_sha256`はテスト入力、`runner_sha256`はrunnerを識別し、測定を比較する際にどの同一性を確かめるかは[証拠の再利用規則](results.ja.md#記録の合算)で説明しています。

生成したinventoryとbacklogには、`ledger_inputs_sha256`を付けます。
検査した入力全体、`coverage/scope.json`、`coverage/requirements.json`、`coverage/assessments.json`、`coverage/test_index.json`、
catalogの`catalog_sha256`を識別します。索引には現在のテスト入力の指紋があり、先に台帳の検査で実入力との一致を確認します。

ツールは、object keyをsortして余分な区切りの空白を省いたUTF-8の正規化JSONをhash化します。
JSONの空白、key順、日本語のescape表記／直接表記は識別値に影響しません。
配列の順序は保持し、catalogのbyte変更はその指紋に反映します。
絶対path、生成先、表示言語、backlogのroot filterは入力fieldに含めません。
同じ入力なら全体とfilterしたレポートで同じ識別値になります。異なる表示を比較するときはschemaと選択条件も比較してください。
これは入力の識別値であり、生成file全体のhashではありません。

要求文、適用条件、期待値、制限、照合、対応の変更、分類の根拠／照合、範囲や確認済みのsnapshotの変更が識別値に反映します。
digestはレビューの承認でも実行結果でもありません。各テストの`inputs_sha256`、runnerの`runner_sha256`とも別です。
シミュレーションsourceが変わらなくても、台帳の意味が変われば古い生成レポートを作り直す必要があります。
hashが同じでも、既知差分を含む未完／未承認の棚卸しの場合があります。

## テストや対応付けの更新

新しい数値配置が既存の義務の証拠を増やしても別の義務になるとは限らず、同じ要求IDの対応を拡張する例は[Q393](faq.ja.md#q393-callback要求をprofileごとに増やさず既存の対応を拡張する理由は)で確認できます。

索引はファイル名だけでなく正確なテスト入力と対応付けを結び付けるため、古い指紋の置換前に対応のレビューが必要な理由は[Q78](faq.ja.md#q78-テスト索引が古くなったらどう直しますか)で説明しています。

1. 適用される規範的動作を読み、日英の要求、条件、制限を書き直します。照合状態も再評価します。
2. テストと期待する観測を確認します。`direct`／`control`を明示し、まだ対応付けない要求のlinkは空にします。
3. `check`を実行します。入力や主引用の変更、テストの追加／削除は正本の索引を無効にします。
4. `sync`で別fileに案を作ります。現行テストを追加し、未対応の指紋を更新しますが、対応済みの既存指紋は保持します。
   案を取り込むだけでは、古くなった対応は有効になりません。対応済みテストの削除には、先にlinkの確認／削除が必要です。
5. 案とsourceの変更を比較します。影響する全対応を再照合した後、現行入力から指紋／主引用を更新し、確認した索引の差分を取り込みます。
   新しい指紋だけでは人による照合にはなりません。
6. metadata、台帳、ツールを検査します。範囲、schema、棚卸しの記述が変わる場合は日英資料も更新します。
   シミュレーション入力やrunnerが変わる場合は、影響する実行の証拠を別途再現します。

共通helperの変更は複数テストの証拠を同時に古くする場合があるため、編集した検査系に加え、依存する各記録でも[結果の再利用の確認項目](results.ja.md#記録の合算)を確認してください。

入力の変更時に既存の対応を黙って認定し直すコマンドは設けません。唯一の例外はcommentと改行だけを加える編集で、`python3 tools/code_identity.py refresh --base BASE`は、編集した入力がすべてcodeを保つことを示してから指紋を持ち越します（[読みやすさの編集](testing.ja.md#読みやすさの編集)）。
回帰テストは期待値／helper／lockの変更、direct／controlの区別、引用の自動昇格の防止、重複や不正データ、
範囲の主張、生成先の保護を検査します。Check CIでも、既存のmetadata・ライブラリ検査とともに実行します。

付録Hの個別評価は非推奨の文脈を記録するもので、現行APIの部分契約や保留scopeの承認と異なる理由は[Q382](faq.ja.md#q382-規範的な付録hは非推奨apiの拒否を要求しますか)で説明しています。

総則の評価は記載された語や規約の解釈を関連APIへつなぐもので、残るB.4と部分義務を完了しない理由は[Q386](faq.ja.md#q386-総則を評価すると何が残りますか)で説明しています。

## M4の残作業と承認

未評価の一覧が空になっても部分分解の義務や適用条件が残ることがあり、次に確認する残作業は[棚卸しの状態](#レビュー用の未整理項目とroot別集計)で説明しています。

候補の条項を読み、義務と条件への分解を続けます。既存テストを対応付けてから必要な追加テストを決め、
未対応や不一致でも規範的な期待値は変えません。文脈／保留の区分、catalogの完全性、要求の同一性、重複、
実際に非規範的な箇所をレビューします。backendの制約は制限として記録し、分母から暗黙に除外しません。

割合の公開前に、規範的義務の棚卸しとレビューを終え、範囲を決定し、計数規則と固定した要求集合の明示的な承認を得ます。
レビュー済みの検査対応と、実行成功をどう数えるかは分けて定義し、実行条件と証拠の同一性も含めます。
承認には後続のschema／手順の更新が必要です。scope schema 1では意図的に、棚卸し完了や承認済み分母を表せません。
現在のAIによる4151要求案と直接の対応は、その条件を満たしていません。
