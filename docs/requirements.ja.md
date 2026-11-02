# 要求台帳の案とカバレッジの棚卸し

[English](requirements.md) · [README](../README.ja.md) · [テストと開発のガイド](testing.ja.md)

## 現在の状態

M4を進めています。[対象範囲の案](../coverage/scope.json)、[要求台帳](../coverage/requirements.json)、
[テスト索引](../coverage/test_index.json)を版管理します。台帳の要求案は1163件で、1160要求を1105テストへ直接対応付け、
3要求には直接対応するテストがありません。追加の1テストをcontrolとして対応付けています。
全1106テストに要求の対応付けがあり、未対応テストは0件です。
人による要求の照合記録はありません。

条項catalogの番号は2,504件です。735件は要求を一部分解し、残る1,769件は未評価です。
どちらも完了を示しません。M4の開始は、範囲や分母の承認、M1〜M3の完了を意味しません。
`approved_denominator`と`coverage_percentage`は`null`のままです。

## 計数単位と対象範囲の案

適用条件を伴う、観測可能な規範的義務を1要求とする案です。methodの1条項にも、成功、失敗、default引数、
順序、副作用など、複数の要求が必要な場合があります。見出し自体は義務ではありません。
1163件の要求案は複数領域にわたりますが、その条項内の全義務を列挙したものではありません。

既存の番号catalogのすべてのrootを、1つずつ次に割り当てます。

| 区分 | Root | 番号の件数 | 意味 |
| --- | --- | --- | --- |
| 対象候補 | 5〜19、B〜G | 2,479 | 規範的な動作を読んで要求に分解する |
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

テストの最初のUVM `:lrm:`参照を**主引用**、後続のUVM参照を**補助引用**と呼びます。
catalogのうち主引用がある番号は507件、どちらかの引用がある番号は1,119件です。
補助引用は準備に使うAPIの場合もあります。引用から要求の対応付けを自動生成せず、子条項の参照を親条項へ自動集約もしません。

対象候補2,479件について、従来の「各条項2テスト」の主引用の棚卸しは、0件が1,972、1件が266、2件以上が241です。
これはテストの配置を測るだけで、2つの独立した検査があること、規範的な義務を分解したこと、実行が成功したことを示しません。
承認された要求の分母ではなく、主引用0件の全条項が不足だと宣言するものでもありません。

`UVM-CLONE-DISTINCT`などの要求IDは、テストのfilenameとは独立した安定した名前です。
5.3.5.2の2つの要求は同じ条項を使い、別handleの生成と、後続のscalar変更の独立性を別々に検査できます。
callbackの要求`UVM-VREG-FIELD-POST-WRITE-ORDER`は、field単独のテストを直接、親virtual registerのwriteをcontrolとして対応付けます。
controlは検査系を評価する助けになりますが、その要求の直接の対応には数えません。

対応には、汎用の期待出力にある正確な`UT: `行を登録します。この**期待する観測**は期待値への対応であり、
実行成功の観測ではありません。1行に別の義務の観測が含まれていても、この要求がすべてを検査する意味にはなりません。
checkerは参照、field、期待行の存在、入力の同一性を検査しますが、実際に要求を実行することやassertionの十分性は証明しません。
テスト、構成、規格のレビューが必要です。期待出力の順序はrunnerが検査し、台帳で行の存在を確認するだけでは順序や反復回数を保証しません。
同じ期待行の繰り返しはanchorに1回だけ登録し、runnerは引き続き期待する全行の並びを比較します。

[実行の証拠](results.ja.md)は別に扱い、入力、runner、ライブラリ、設定の同一性が必要です。
直接の対応先にもspecのみの既知差分があり得ます。対応自体は成功や適合性の主張ではありません。
現在の1106件には新たに測定した検査系を含みます。変更していない既存テストの対応付け自体は、追加の実行結果ではありません。

## 版管理するデータと生成する棚卸し

JSONはUTF-8、schema versionは1です。未知のfield、重複key、重複する要求ID、未知の条項／テストを拒否します。

- `coverage/scope.json`は、日英の計数単位、rootの区分、従来の主引用の目標を記録します。
  schema 1で表せるのは、承認済み分母のない未完の範囲案だけです。
- `coverage/requirements.json`は、安定したID、条項、日英の`statement`、`conditions`、`expected`、`limitations`、
  `review`、`test_links`を記録します。対応にはtest ID、`direct`／`control`の役割、空でない`expected_observations`を持たせます。
  直接の対応先は要求の条項を引用する必要があり、レビューで対応を確認すれば補助引用でも構いません。
- `coverage/test_index.json`は、全テストの`primary_clause`と`inputs_sha256`を記録します。
  指紋は既存runnerの収集処理を使い、source、宣言したhelper／include／data、期待値file、UVM lockを含めます。
  索引は棚卸しであり、1106件のレビュー済み要求対応ではありません。

照合状態は`ai`、`unreviewed`、`human`です。humanには識別可能な`reviewer`と、`reviewed_at`のISO日付が必要です。
他の状態では両方を`null`にします。照合したという記録であり、checkerが本人性を認証するものではありません。
要求を変更しても、人が再照合したことにはなりません。

リポジトリのrootから実行します。

```sh
python3 tools/requirements.py check
python3 tools/requirements.py inventory --json out/requirements-inventory.json --lang ja
python3 tools/requirements.py sync --output out/test-index-proposal.json
```

`check`は正本の入力を検査して概要を表示します。`inventory`はさらに、全番号の区分、分解状態、主引用／補助引用、
要求の対応、照合／oracleのmetadata、指紋、root別の集計を出力します。要求がある条項は`partial`、ない条項は`unassessed`です。
どちらも完了や検査済みを示しません。生成する分母と割合は`null`を保ちます。
`--lang en`／`--lang ja`は概要の表示言語を選び、JSONのkeyと安定した識別子は変えません。
`out/`の生成物はGit対象外で、生成出力は3つの正本を上書きできません。

## レビュー用の未整理項目とroot別集計

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
`unassessed_identifiers`（要求entryのないcatalogの番号）を分けます。
レビューの作業一覧であり、確定した適合性の不足ではありません。文脈／保留の番号も区分付きで残し、分母と割合は未設定のままにします。

`inventory`と`backlog`には`roots`の集計があります。要求は自身の条項のroot、テストは主引用のrootに属します。
そのため、第17章の要求から付録Eのテストへ対応付けても、そのテストを第17章の主引用数へ移しません。
子条項の件数を親要求の認定へ集約しません。複数の要求が1テストを共有でき、1要求に複数のテストを対応付けることもできますが、
共有する期待出力の1行にある全anchorで独立した網羅を示す意味にはなりません。

主引用テストのある次の21個のrootの既存主引用テストをすべて対応付けましたが、規範的義務の分解は部分的なままです。

| Root | 要求案 | 主引用テスト | 対応のないテスト | 未評価の番号 |
| --- | --- | --- | --- | --- |
| 5 | 53 | 42 | 0 | 74 |
| 6 | 34 | 32 | 0 | 87 |
| 7 | 30 | 13 | 0 | 45 |
| 8 | 23 | 34 | 0 | 52 |
| 9 | 37 | 27 | 0 | 89 |
| 10 | 50 | 54 | 0 | 80 |
| 11 | 17 | 12 | 0 | 17 |
| 12 | 126 | 148 | 0 | 142 |
| 13 | 36 | 20 | 0 | 87 |
| 14 | 118 | 108 | 0 | 51 |
| 15 | 60 | 80 | 0 | 51 |
| 16 | 93 | 98 | 0 | 129 |
| 17 | 7 | 2 | 0 | 26 |
| 18 | 244 | 209 | 0 | 304 |
| 19 | 84 | 61 | 0 | 74 |
| B | 36 | 54 | 0 | 110 |
| C | 9 | 16 | 0 | 80 |
| D | 6 | 6 | 0 | 40 |
| E | 48 | 54 | 0 | 79 |
| F | 51 | 34 | 0 | 106 |
| G | 1 | 2 | 0 | 21 |

未対応テスト0件は、完全な要求カバレッジではありません。
直接テストのない要求案は、次の3件です。

| 要求 | 条項 | 残る観測 |
| --- | --- | --- |
| `UVM-HDL-DEPOSIT` | 19.6.2.2 | 実際のHDL depositと成功／失敗。現在の検査系はHDL DPIを無効化 |
| `UVM-HDL-PATH-ACCESSIBILITY` | E.7 | storage転送なし、時刻0での実際のpath利用可否／warning |
| `UVM-MEMORY-WALK-ALGORITHM` | E.6.1 | locationを訪れる以上の、algorithm固有のdata／address関係 |

backendの利用可否を理由に、これらの義務を提案範囲から除外しません。
memory-walkのlocation maskや固定bit故障を、algorithm全体の証拠へ昇格しません。
library実装から詳細traceを推測してはなりません。未評価の識別子1,769件も、
規範性の分類／分解が必要です。見出しが自動的にテスト義務となるわけではありません。
要求案1163件のレビューは、すべて`ai`のままです。

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

生成したinventoryとbacklogには、`ledger_inputs_sha256`を付けます。
検査した入力全体、`coverage/scope.json`、`coverage/requirements.json`、`coverage/test_index.json`、
catalogの`catalog_sha256`を識別します。索引には現在のテスト入力の指紋があり、先に台帳の検査で実入力との一致を確認します。

ツールは、object keyをsortして余分な区切りの空白を省いたUTF-8の正規化JSONをhash化します。
JSONの空白、key順、日本語のescape表記／直接表記は識別値に影響しません。
配列の順序は保持し、catalogのbyte変更はその指紋に反映します。
絶対path、生成先、表示言語、backlogのroot filterは入力fieldに含めません。
同じ入力なら全体とfilterしたレポートで同じ識別値になります。異なる表示を比較するときはschemaと選択条件も比較してください。
これは入力の識別値であり、生成file全体のhashではありません。

要求文、適用条件、期待値、制限、照合、対応の変更、範囲や確認済みのsnapshotの変更が識別値に反映します。
digestはレビューの承認でも実行結果でもありません。各テストの`inputs_sha256`、runnerの`runner_sha256`とも別です。
シミュレーションsourceが変わらなくても、台帳の意味が変われば古い生成レポートを作り直す必要があります。
hashが同じでも、既知差分を含む未完／未承認の棚卸しの場合があります。

## テストや対応付けの更新

1. 適用される規範的動作を読み、日英の要求、条件、制限を書き直します。照合状態も再評価します。
2. テストと期待する観測を確認します。`direct`／`control`を明示し、まだ対応付けない要求のlinkは空にします。
3. `check`を実行します。入力や主引用の変更、テストの追加／削除は正本の索引を無効にします。
4. `sync`で別fileに案を作ります。現行テストを追加し、未対応の指紋を更新しますが、対応済みの既存指紋は保持します。
   案を取り込むだけでは、古くなった対応は有効になりません。対応済みテストの削除には、先にlinkの確認／削除が必要です。
5. 案とsourceの変更を比較します。影響する全対応を再照合した後、現行入力から指紋／主引用を更新し、確認した索引の差分を取り込みます。
   新しい指紋だけでは人による照合にはなりません。
6. metadata、台帳、ツールを検査します。範囲、schema、棚卸しの記述が変わる場合は日英資料も更新します。
   シミュレーション入力やrunnerが変わる場合は、影響する実行の証拠を別途再現します。

入力の変更時に既存の対応を黙って認定し直すコマンドは設けません。
回帰テストは期待値／helper／lockの変更、direct／controlの区別、引用の自動昇格の防止、重複や不正データ、
範囲の主張、生成先の保護を検査します。Check CIでも、既存のmetadata・ライブラリ検査とともに実行します。

## M4の残作業と承認

候補の条項を読み、義務と条件への分解を続けます。既存テストを対応付けてから必要な追加テストを決め、
未対応や不一致でも規範的な期待値は変えません。文脈／保留の区分、catalogの完全性、要求の同一性、重複、
実際に非規範的な箇所をレビューします。backendの制約は制限として記録し、分母から暗黙に除外しません。

割合の公開前に、規範的義務の棚卸しとレビューを終え、範囲を決定し、計数規則と固定した要求集合の明示的な承認を得ます。
レビュー済みの検査対応と、実行成功をどう数えるかは分けて定義し、実行条件と証拠の同一性も含めます。
承認には後続のschema／手順の更新が必要です。schema 1では意図的に、棚卸し完了や承認済み分母を表せません。
現在のAIによる1163要求案と直接の対応は、その条件を満たしていません。
