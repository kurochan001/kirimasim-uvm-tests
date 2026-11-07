# テストと開発のガイド

[English](testing.md) · [README](../README.ja.md) · [FAQ](faq.ja.md)

現在のテスト形式、ライブラリの準備、ランナー、変更時の規則を説明します。
件数と対象範囲は[README](../README.ja.md)、測定の詳細は[実行結果](results.ja.md)、過去の作業は[履歴](history.ja.md)を参照してください。

## 確かめること

シミュレータは言語を実行し、UVMライブラリは検査するclassを供給するので、役割の整理は[このリポジトリが検査すること](reading-guide.ja.md#このリポジトリが検査すること)を参照してください。

- **対象**：シミュレータがUVMライブラリを実行したとき、IEEE 1800.2-2020が定める結果になるか。
  フェーズの順序、objectionによるフェーズの終了、factoryの置き換え、config_dbの検索、
  シーケンスとシーケンサ、TLMの接続、レジスタ層などです。
- **期待値の根拠**：1800.2-2020の条項。`:lrm:`に記録し、テストの冒頭のコメントで、何を確かめるかを
  自分の言葉で説明します。規格本文は転載しません。
- **ライブラリ**：Accellera版UVMライブラリのリリース2020.3.1を、`third_party/uvm.lock`で固定して使います
  （「UVMライブラリ」を参照）。配布物の`DEVIATIONS.md`には、ライブラリが規格と異なる箇所が3件あります
  （18.2.3.4、18.4.3.6、13.1.5.1）。期待値はこれらに依存させず、触れざるをえないテストは差異として記録します。
- **範囲外**：SystemVerilogの言語そのもの（kirimasim-testsで扱う）、UVMの教材、性能、
  レジスタモデルの生成ツール、ベンダー固有の拡張。

## ディレクトリ構成

`uNN`のディレクトリは規格の章、M1〜M4は開発段階を表し、要求との関係は[対象範囲の用語](glossary.ja.md#範囲とカバレッジ)で確認できます。

```text
tests/uNN/<name>.sv          メタデータ付きテスト（NNは1800.2の章）
tests/uNN/<name>.expected    期待する観測行
tests/uB/, uC/, uD/          付録テスト：マクロ、設定、callback
tests/uE/                   組み込みregister／memoryテストsequence
tests/uF/, uG/              文字列utility・command-lineの照会
docs/testing*.md            テスト形式・実行・変更時の規則
docs/results*.md            現在の測定条件と記録
docs/requirements*.md       範囲の案・要求の対応付け・棚卸し
coverage/*.json             版管理する範囲・要求台帳・番号の分類・テスト索引
docs/provenance*.md         関連リポジトリとソースの由来
docs/glossary*.md            用語集
docs/faq*.md                 よくある質問
docs/known-differences*.md   現在の制約とspecのみの期待値
docs/handoff*.md            作業の引継ぎと再開手順
docs/history*.md             過去の追加作業と測定
third_party/uvm.lock         固定したライブラリ：リリース、取得元、コミット、指紋
third_party/uvm/<version>/   ライブラリ本体（取得するもので、コミットしない）
tools/fetch_uvm.py           ライブラリを取得し、指紋を確かめる
tools/uvm_common.py          ライブラリと一緒にコンパイルする方法、観測する行
tools/run_kirimasim.py       kirimasimのランナー
tools/run_verilator.py       Verilatorのランナー
tools/run_ghost.py           非公開プロファイルを使うGhostのランナー
tools/suite_results.py       判定と結果JSON（kirimasim-testsから写したもの）
tools/lint_metadata.py       メタデータとテストの形式の検査
tools/requirements.py        要求台帳の案の検査と棚卸し
tools/sv_lifetimes.py        初期化付き手続き内ローカル変数の字句チェック
tools/clauses_1800_2.txt     1800.2-2020の条項番号（番号だけ）
tools/UPSTREAM               写したツールの元と、変えた点
```

## テストの形式

テストは観測する動作と独自に導いた期待値を組み合わせるため、以下で使うoracleと期待出力の意味は[規格と期待値](glossary.ja.md#規格と期待値)を参照してください。

### 例

次のコードはメタデータのヘッダーだけを示しており、実行に必要なクラスやtop moduleは[動作確認用テストの全ソース](../tests/u09/test_common_phases_run_in_order.sv)で確認できます。

```systemverilog
/*
:name: test_common_phases_run_in_order
:description: the common phases run in their order, ... (IEEE 1800.2-2020 Section 9.8.1)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.8.1 9.5 9.6 9.7 10.5.1
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +UVM_TESTNAME=t
:expected_stdout: @test_common_phases_run_in_order.expected
*/
```

fixtureはテストの準備と観測を担う検査系、helperはテストを支える補助コードやデータのことで、以下の個別例で使う用語は[実行と結果の用語集](glossary.ja.md#実行と結果)で説明しています。

以下のhelperの説明は個別のテスト系列に必要な準備を扱うため、初めてテストを書く場合は、専用の検査系を使う前に[メタデータ](#メタデータ)と[観測の規則](#何を観測するか)へ進んでください。

memory／FIFO追加では[記載API設定](../tests/u18/helpers63/fifo_frontdoor_fixture63.svh)と
[固定build control](../tests/u18/helpers63_initialized/fifo_initialized_fixture63.svh)の独立helper directory 2個を宣言します。
利用sourceは`:files:`でhelperを指定し、directory内容が入力指紋に入ります。helper変更時は全依存入力を再測定します。
初期化variantは台帳でcontrol専用であり、constructor／configureだけの前提の入力をpassにしません。

core-service宣言も[記載methodだけの本体](../tests/uF/helpers64/core_method_bodies64.svh)と
[明示追加hook本体](../tests/uF/helpers64_decl_control/core_decl_control_bodies64.svh)を別の宣言directoryに保持します。
完全な追加hook入力はcontrol専用です。省略26入力は選択したpure method欠落1個だけを分離するためhookを使い、
最終診断は他の欠落method errorなしにそのmethodを示す必要があります。無関係なcompile拒否で期待値をpassにできません。

field-macro入力は字面のcollection型引数／PACK単独flagと、要素enum／明示UNPACK controlを分けます。
各variantは別の指紋と期待値fileを持ち、controlのpassで直接前提を置換しません。const ARG入力はruntimeのない不正compiler検査です。
互換packing roundtripはstream形式を規定せず、全ての片方向抑制条件を独立に認定しません。

[独自field-access helper](../tests/u18/helpers66/field_access_fixture66.svh)は分離したfrontdoor route bufferとbackdoor storageを供給し、
実HDLやmap aliasの整合性の証拠ではありません。物理隣接値をモデルresetと意図的に変えます。
callback起点のmap変更と開始時mapを明示するcontrolは異なる前提を保持します。helper変更時には全依存入力を再測定します。
別のpost行が一致してもpre順序が異なる全traceをpassにせず、旧seed logを現在の入力指紋で再利用しません。

[保護helper](../tests/u18/helpers67/protection_fixture67.svh)はregisterごとの独自frontdoor／backdoor storageとbyte field 2個を使います。
callback guard検査はERRORの存在、失敗status、転送0、storage保持を観測し、正確な診断文／件数は要求しません。反対方向と削除履歴を別に観測し、拒否read dataは規定しません。
post-predictはdirectと成功read／writeのkindを区別します。観測行にはliteral表示formatを使い、packed連結は整数式であることに注意します。helper変更時には全依存入力を再測定します。

[recording helper](../tests/uB/helpers68/recording_fixture68.svh)は実行中のtransaction handleを使って記述されたrecorder hookを観測します。
印刷された3引数attributeと4引数互換controlは別の入力同一性を持ちます。
追加引数を許容する6入力はcontrol専用で、直接small-field APIとenumNのcontrolは独自の直接義務も持ちます。
scalar macroの各方向は公開APIを独立に使い、7-bit末尾値を保持しますが、raw stream配置や全size／error動作は推測しません。
前提を変える前に[macroの解釈とcontrol](faq.ja.md#recordingとscalar-macroの条件)を参照してください。

[走査helper](../tests/uF/helpers69/traversal_fixture69.svh)は独自node・型付きvisitor・完全なinterface本体を供給します。
実際の組み込みadapterが走査を担い、独自本体は宣言されたdispatchの観測か公開実装への委譲を行います。
constructor wrapperは選択した省略／明示引数で実際の基底を呼びます。依存する既定値と明示型の入力は区別し、
型・名前・compiler結果の解釈は[走査のFAQ](faq.ja.md#走査の宣言と既定値)を参照してください。

[virtual照会helper](../tests/u18/helpers70/vreg_query_fixture70.svh)は、storage転送handlerなしの独自block／memory／map設定を供給します。
動的実装は明示し、別に既知差分があるmemory省略resizeの前提を避けます。regionの同一性にはmanagerの唯一の予約を使い、既知のowner getterには依存しません。
区間を限定したreport観測はseverityを保ち、固有の文言／件数を固定しません。constructor／getterの連鎖、字面のoverview基底型、object基底controlは限定を保持し、
[照会のFAQ](faq.ja.md#virtual-registerの照会と宣言の境界)で説明しています。

[field constructor helper](../tests/u18/helpers71/vreg_field_constructor71.svh)はfactoryで生成する独自派生型を使い、実際のsuper.new直後に公開名を取得します。
取得値から一般的なfactory生成後の命名policyは主張しません。専用global pool入力は明示した束縛後に実際の静的APIを呼び、印刷pool receiverを本文のitem型や生きた状態／待機controlと区別します。
修正した既存入力は本体とoracleを保持しても、主引用の変更に対応する新しい証拠が必要です。[照会と対応のFAQ](faq.ja.md#専用global照会と対応付けの修正)を参照してください。

[recorder-link helper](../tests/u16/helpers72/recorder_link_fixture72.svh)は独自のメモリ内database／stream／recorder callbackを提供します。
公開状態を確認した後のestablish_linkだけをerror観測の期間とし、独自catcher内で終了して回復動作を仮定しません。
外部記録databaseの検証ではなく、closeとfreeの境界は[期間のFAQ](faq.ja.md#recorderのlink可能期間)で説明しています。

[正準bus helper](../tests/u19/helpers73/busop_fixture73.svh)は、独自の数値word protocolで実際のreg2bus入力を記録します。
readの記憶域は独立に事前設定し、完了後の観測行をaddress順に並べます。bus2reg件数は同じrequestへ結果を戻す変換で、別response packet数ではありません。
有効bitだけを制約し、[bus操作のFAQ](faq.ja.md#正準bus操作)で範囲を説明しています。

[policy差し替えhelper](../tests/u16/helpers74/policy_plugin_fixture74.svh)は、1つのobject定義と独自policy派生型を使います。
recordは毎回新規、pack／unpackは同一互換policy／stream型で、observer tickがfieldと状態受渡しの順序を記録します。
内部形式や外部DBを仮定せず、[policyのFAQ](faq.ja.md#policy差し替えと型付きobject-stream)で観測範囲を説明しています。

[printer属性helper](../tests/u16/helpers75/printer_columns75.svh)は、公開APIへ固有の名前・型・size・値の文字列を渡し、見えるかどうかを確認します。
収集前／後の設定と新規peer／明示設定peerを区別し、[出力制御のFAQ](faq.ja.md#printerの属性と出力時の制御)で前提を説明しています。

[adapter親context helper](../tests/u19/helpers76/parent_sequence76.svh)は、要求sequence基底をdriverの公開parent照会で確認し、独自clone bridgeでprototypeを用意します。
register itemの親metadataとは別で、caller parentは省略し、[親contextのFAQ](faq.ja.md#adapterのsequence-context)で組合せの範囲を説明しています。

[model helper](../tests/u18/helpers79/hdl_models79.svh)と[view helper](../tests/u18/helpers79/hdl_views79.svh)は、標準get_slices入力と明示的な非標準member controlを分けます。
物理6入力はview helperをcompileせず、指紋には同じinclude directory内の兄弟fileも入るため、helper修正時には全22入力を再測定しました。
[pathのFAQ](faq.ja.md#register-hdl-pathと観測の前提)で、getterの障害、祖先ごとの既定値、実HDL観測を区別しています。

[coverage構築helper](../tests/u18/helpers80/coverage80.svh)は完全階層名／単純patternの選択、constructor中だけの追加、公開samplingの独自observerを用意します。
sampler本体はcovergroupではなく、実際の継承block methodで再帰routingを調べ、2つの外部protected呼出しはcompiler拒否として分離します。
搭載／有効maskが一致しても以前のmaskを返す観測が異なる全検査系はpassにならず、[coverageのFAQ](faq.ja.md#registerのcoverage構築とsampling)で解釈の範囲を説明しています。

[report-macro helper](../tests/uB/helpers81/report_macros81.svh)は実macroから配送されたmessageを独自serverで取得し、callerと明示RO、場所、MSG評価、括弧なし分岐、時間を分けて観測します。
可視MSGには正の評価だけを要求し、抑制INFOには0を要求します。初回の不要な1回制約を修正して全18入力を測り直し、最終タグ付き16入力も新たに測定します。
既定fatal動作や未指定の評価回数を認定しない範囲は[macroのFAQ](faq.ja.md#report-macroとinfoの境界)で説明しています。

[callback-macro helper](../tests/uB/helpers82/callbacks82.svh)は実登録／dispatch macroを使い、暗黙caller、明示mode、型、参照引数と完了呼出し間の変更を独自hookで観測します。
未登録呼出しのWARNING観測と、観測前に終了した空queue deleteは分け、typedefとMETHOD拒否の前提も[callbackのFAQ](faq.ja.md#callback登録とdispatch-macro)で説明しています。

size／versionの独自入力は、実reserved数に対するflag幅の上書き、正確なbit-vector ref、32768-bit packer保持、公開version定数を分けます。
上書きはUVM packageとテストの両方へ適用し、大きいenum buildと最小値macro欠落の差分を容量一致で置換しない前提は[size／versionのFAQ](faq.ja.md#サイズ定義とversion識別)で説明しています。

[report observer](../tests/uF/helpers84_report/report84.svh)は実APIからseverity／verbosity／ID／本文／発信元を取得し、既定actionは実行しません。
別のCOUNT-only error入力は正のquit上限のもとで実既定serverを使います。[sequence observer](../tests/uF/helpers84_sequence/states84.svh)はUVM stateを代入せず、実hook stateと自身のcounterだけを保持します。
helper folderは未変更で、header tag 11件を新たに測定します。[負のID閾値入力](../tests/uF/test_enum_state_none_negative_id_limit_literal_84.sv)のlocal observerは、呼出し区間中の正確なmessageだけを数え、明示した閾値0で正のcontrolも確認します。
改訂入力を新たに測定し、未変更の字義的kill測定を保持する範囲とmask／時刻／callbackの区別は[report／stateのFAQ](faq.ja.md#reportの列挙型とsequence-state)で説明しています。

[virtual backdoor helper](../tests/u18/helpers85/vreg_backdoor_fixture85.svh)は宣言word幅に制限した独自user記憶域とowner blockを供給し、実HDL入力はmodel記憶域を使わず公開array cellを使います。
2つのindexと3種類のdebug引数で全raw wordを独立に初期化し直して観測し、[backdoorのFAQ](faq.ja.md#virtual-registerのbackdoor観測)は配置順に依存しない複数word条件と残る失敗／回復条件を説明しています。

[callback helper](../tests/u18/helpers86/callback_fixture86.svh)は独自frontdoor／backdoorと実method／登録callbackを供給し、選択read／write種別だけの最初／最後を観測します。
型の構築は別の最小入力で確認し、[field単独の修正入力](../tests/u18/test_vreg_callback_field_post_write_standalone_status_86.sv)は観測する部分writeのfrontdoor／backdoorを同じ記憶域へ結びます。
3経路のcontrolと修正前後の入力同一性は[callbackのFAQ](faq.ja.md#virtual-registerのcallback契約)で説明しています。

[kill後復旧helper](../tests/u18/helpers87/killed_access_fixture87.svh)は実accessを独自backdoor内で待機させ、到達後のcaller kill、同じprovider上のpeer、reset後の別indexとvictim indexを観測します。
[frontdoor照会helper](../tests/u18/helpers87/frontdoor_query_fixture87.svh)は単一／複数mapで独立したsequence記憶域を使い、null／置換／peer／debug引数／復元を確認します。
有限のguardと、暗黙map選択を使わない条件は[accessのFAQ](faq.ja.md#killしたaccessの復旧とfrontdoorの選択)で説明しています。

[元のfinish helper](../tests/uF/helpers88/finish_fixture88.svh)と[guard helper](../tests/uF/helpers88/guard_fixture88.svh)は元の厳しい期待を保持します。
[正時間finish control](../tests/uF/helpers88_finish_control/finish_fixture88.svh)と[早いguard control](../tests/uF/helpers88_guard_control/guard_fixture88.svh)は別の前提です。
[未登録predictor helper](../tests/u19/helpers88/predictor_check_fixture88.svh)はbuild拒否を保持し、[登録済みhelper](../tests/u19/helpers88_registered/predictor_check_fixture88.svh)は独立modelの実check phaseを観測します。
元入力の一致を読み替えない理由は[root／predictorのFAQ](faq.ja.md#rootの終了guardとpredictorのcheck)で説明しています。

[callback helper](../tests/uF/helpers89/apprepend_fixture89.svh)は型付き交互挿入の実dispatch列と空peerを観測します。
[MAM helper](../tests/u18/helpers89/mam_modes_fixture89.svh)は型付きconfiguration、選択履歴／locality、保持端点snapshotを使い、[rand-field helper](../tests/u18/helpers89_cfg_random/configuration_rand_fixture89.svh)は反対値からの制約付き変更を別に確認します。
固定の期待行を変えずにhelperを強めて再測定する条件は[enum／allocationのFAQ](faq.ja.md#列挙型の効果とallocationの選好)で説明しています。

[policy observer](../tests/u18/helpers90_policy/policy_fixture90.svh)は選択randomization hookと公開request文脈を検査します。
[説明observer](../tests/u18/helpers90_description/description_fixture90.svh)は限定した状態比較を使い、[有効region observer](../tests/u18/helpers90_region/region_fixture90.svh)は解放後の同一性を未完に保ちます。
独自の[write](../tests/u18/helpers90_write/write_fixture90.svh)／[watch](../tests/u18/helpers90_watch/watch_fixture90.svh)本体は印刷virtual taskのdispatchを検査し、限界と失敗randomizationのhook差分は[manager文脈のFAQ](faq.ja.md#manager-policyの文脈と印刷backdoor-task)で説明しています。

[port検査系](../tests/uF/helpers91_ports/port_fixture91.svh)は型付きconstructor queryと実analysis転送を分けます。
元の[共有domain](../tests/uF/helpers91_phase/phase_fixture91.svh)と[prescoped](../tests/uF/helpers91_phase_prescoped/phase_fixture91.svh)のphase入力は異なるlookup前提を保持します。
[待機observer](../tests/uF/helpers91_wait/wait_fixture91.svh)、[objection observer](../tests/uF/helpers91_objection/objection_fixture91.svh)、[topology observer](../tests/uF/helpers91_topology/topology_fixture91.svh)は選択したevent／policyの効果を検査し、字義どおりの未初期化状態の解釈と期待値を変えない出力の区切りは[型付き役割のFAQ](faq.ja.md#名前付きの役割待機演算とtopology-policy)で説明しています。

[library検査系](../tests/uF/helpers92_library/library_fixture92.svh)は標準mode API、constructor既定RAND、明示legacy-field controlを分けます。
独自child body、実item driver、独自USER hookで乱数列を固定せず選択した効果を観測します。
[独立したALL variant](../tests/uF/helpers92_heartbeat_all/heartbeat_fixture92.svh)は監視list／参加順を反転して正のcountを変えます。
[heartbeat検査系](../tests/uF/helpers92_heartbeat/heartbeat_fixture92.svh)は元のONE入力でoutsiderの活動を保持し、[scopeを限定したcontrol](../tests/uF/helpers92_heartbeat_scoped/heartbeat_fixture92.svh)はその活動だけを外します。
独自catcherは非UTの公開report診断を記録して非INFO報告で終了を要求し、別stopと限定した無効化の前提は[mode／windowのFAQ](faq.ja.md#sequence-libraryのmodeとheartbeatのwindow)で説明しています。

[整数observer](../tests/uF/helpers93_numeric/numeric_fixture93.svh)は有限の定数scanf format、[wide observer](../tests/uF/helpers93_numeric_wide/numeric_fixture93.svh)は65-bit値を読む独立した桁算術を使います。
独自の[string](../tests/uF/helpers93_string/string_fixture93.svh)、[real](../tests/uF/helpers93_real/real_fixture93.svh)、[time／enum](../tests/uF/helpers93_time_enum/time_enum_fixture93.svh)検査系は、適切な型のscalar macroを使います。
[開いたrecorder hook](../tests/uF/helpers93_record/record_fixture93.svh)は選択metadata／data、[table row](../tests/u16/helpers93_table/table_fixture93.svh)は固有のcaller指定cellを観測し、binary DB、絶対時間単位、全表示配置を認定しない理由は[radix／observerのFAQ](faq.ja.md#radixの意味とobserverの限界)で説明しています。

[namespace helper](../tests/uF/helpers94_namespace/namespace_fixture94.sv)は別々にコンパイルする字句package 2つを供給し、[root helper](../tests/uF/helpers94_root/root_fixture94.svh)はrootを生成せず実際のsingleton／基底viewを照会します。
[registry helper](../tests/uB/helpers94_registry/registry_fixture94.svh)は低水準登録とcustom名だけを使い、[event helper](../tests/uB/helpers94_event/event_fixture94.svh)は準備でevent代入をせずcopy前後にwaiterを待機させます。
初期helper／compiler失敗の指紋は置き換わっており、保持するevent実行時差分は[明示した解釈の限界](faq.ja.md#package公開root-view低水準macro)と併せて読んでください。

[scalar packing helper](../tests/uB/helpers95_pack/collection_pack_fixture95.svh)と[scalar unpacking helper](../tests/uB/helpers95_unpack/collection_unpack_fixture95.svh)は選択したstatic-arrayの片方向観測を保持します。
[paired packing helper](../tests/uB/helpers95_pair_pack/collection_pair_pack_fixture95.svh)はmacro対による復元を検査し、[状態転送helper](../tests/uB/helpers95_pair_unpack/collection_pair_unpack_fixture95.svh)は変更しない型付き状態をfreshな互換policyへ渡します。
dynamic-array／queueの長さheaderをhelperで解釈せず、撤回した強すぎるflat oracleと残る片方向の限界は[collectionのFAQ](faq.ja.md#collection-macroの値とopaque状態)で説明しています。

[宣言helper](../tests/uB/helpers96_declarations/declaration_packages96.sv)は同じ2つのsuffix名を別々の字句packageに生成します。
[put検査系](../tests/uB/helpers96_put/put_fixture96.svh)は遅延する独自int handlerを使い、[get検査系](../tests/uB/helpers96_get/get_fixture96.svh)はreadiness、拒否status、成功時の独自class handleを観測し、失敗outputは規定しません。
両方で実際の接続と独立したcastを使い、配送の一致でnominal型の差分をpassにしない理由は[scopeのFAQ](faq.ja.md#tlm宣言scopeとcallback概要)で説明しています。

### メタデータ

ヘッダーは実行スクリプトにビルドと判定の条件を伝えるもので、条項の引用と要求への対応付けの関係は[Q76](faq.ja.md#q76-条項を引用すればその要求を検査したことになりますか)で説明しています。

`:spec_check: ai`は期待値を誰が照合したかを記録し、`:oracle: spec verilator@5.052`は固定リリースでの再現も記録するもので、両項目が別の確認を表す理由は[期待値の用語集](glossary.ja.md#規格と期待値)で説明しています。

kirimasim-testsとsv-testsの形式を引き継ぎ、UVMの設定と共通のビルド・判定設定を以下に説明します。

`:uvm:`の`2020.3.1`は実装のリリース、`:lrm:`の`1800.2-2020`は照合先の規格を表し、2つの版の付け方の違いは[ライブラリと規格の出典](provenance.ja.md#ライブラリと規格)で説明しています。

| フィールド | 意味 |
| --- | --- |
| `:lrm:` | `1800.2-2020 <clauses>`。言語の規則にも依存するテストは、その後に`1800-2023 <clauses>`を足す。1800.2の最初の条項がディレクトリを決める |
| `:tags:` | 章のディレクトリ`uNN`と`uvm`（sv-testsがUVMのテストに付けるタグ） |
| `:uvm:` | テストが前提にするライブラリのリリース。固定したものと同じでなければならない |
| `:uvm_dpi:` | `yes`はDPIを有効にするマクロ指定。実装の供給・リンクは別途必要。[コンパイル](#コンパイル)を参照 |
| `:uvm_defines:` | ライブラリに渡すマクロ（例：`UVM_ENABLE_DEPRECATED_API`） |
| `:uvm_cmdline_backend:` | `vpi`は実process引数を使う別command-line runnerを選択 |
| `:uvm_cmdline_oracle:` | `verilator@5.052`は再現済みcommand-line検査系を既定checkへ選択 |
| `:uvm_hdl_backend:` | `vpi`は別のHDL runnerを明示選択する。他のrunnerはlinkしない |
| `:dpi_c:` | `@../../tools/uvm_hdl_vpi.cpp`で独自backendを宣言し指紋へ含める |
| `:args:` | `+UVM_TESTNAME=…`などの実行時引数 |
| `:files:` | テスト基準の相対パスで、`.sv`／`.v`は指定順に先にコンパイルし、その他のファイルはincludeの探索先を追加するがヘッダーは明示的な読込が必要で、変更時は[入力の更新手順](requirements.ja.md#テストや対応付けの更新)を使う。 |
| `:incdirs:` | テスト基準の相対パスで追加するincludeの探索先で、その内容は[入力指紋](results.ja.md#記録の合算)に影響する。 |
| `:defines:` | `NAME`または`NAME=VALUE`でソースより前に渡すコンパイル時マクロで、追加のUVMマクロは[ライブラリのコンパイル](#コンパイル)で説明する。 |
| `:top_module:` | 起点となるSystemVerilogのmoduleを指定し、省略時はシミュレータが選ぶもので、`+UVM_TESTNAME`が選ぶUVMクラスとの違いは[具体例](reading-guide.ja.md#1件のテストをファイルで辿る)で示す。 |
| `:expected_exit:` | シミュレーションの終了コード、またはsignalによる終了を除く正のエラー終了を要求する`nonzero`で、別途行う出力の検査は[観測の規則](#何を観測するか)で説明する。 |
| `:expected_stderr_regex:` | 診断を照合する正規表現で、意図した拒否に正しい診断も必要な理由は[compiler検査の用語](glossary.ja.md#宣言の既定値とcompiler検査)で説明する。 |

`:expected_stdout:`の`@`で始まる値はテストのソースからの相対パスで期待値ファイルを指定し、そのファイルに記録する出力行は[Q7](faq.ja.md#q7-なぜuvmの全メッセージを比較せずut行だけを比べるのですか)で説明しています。

`--seeds`などはPython runnerの設定、`:args:`は`+UVM_TESTNAME=t`などをsimulation processへ渡す指定で、その使い分けは[初回実行のガイド](reading-guide.ja.md#最初の実行の前に)で確認できます。

`:oracle:`・`:spec_check:`・`:fourstate:`・`:nondeterministic:`・`:should_fail_because:`・
`:expected_stderr_regex:`・`:expected_exit:`・`:files:`・`:defines:`・`:incdirs:`・`:top_module:`の意味は
kirimasim-testsと同じです。共通実装の取得元は[ソースの出典](provenance.ja.md)を参照してください。

これらの指定と、選択するUVMクラス、期待値ファイルの関係は、[スモークテストをファイルで辿る例](reading-guide.ja.md#1件のテストをファイルで辿る)で確認できます。

`:fourstate: no`は検査系がX/Zの値を必要としないという宣言で、得られる2値の証拠の限界は[Q14](faq.ja.md#q14-seedを2つ変えれば決定性や4値の動作も証明できますか)で説明しています。

不正な設計を検査するケースは`:type: elaboration`と`:should_fail_because:`を使い、`:expected_stderr_regex:`でfixture、class／methodまたはconst参照の診断を識別します。
期待するruntime出力や終了は持たせません。compile拒否と一致errorの両方が必要で、受理されたdesignはbinaryを実行せず不一致にします。
要求したseedはsimulation用であり、受理／拒否いずれの不正designも実行時seedを実行しません。台帳schema-2の診断形式は、この宣言oracleを測定と別に記録します。

ここでの`elaboration`はUVMのphaseを実行しないcompiler拒否テストの分類であり、拒否だけでなく意図した診断も必要な理由は[Q199](faq.ja.md#q199-compile拒否を一致に数える理由は)で説明しています。

診断のregex（正規表現）は期待するコンパイルエラーを選ぶ照合パターンであり、別の理由による拒否でそのoracleを満たせない理由は[compiler検査の用語](glossary.ja.md#宣言の既定値とcompiler検査)で説明しています。

既定sequencerなしの所有API検査系は、元のUVM_FATAL severityをcatchした後、検査系自身のfatalで意図的に終了します。
`:expected_exit: nonzero`と`:expected_stderr_regex:`は検査系固有のsentinelを要求し、library診断やlibrary fatalの終了コードを固定しません。
signalは引き続き失敗とし、nonzero終了だけでは必要な観測を満たしません。

`:files:`やinclude directoryで指定するhelperは同じdirectoryの他のfileも入力の指紋へ含める場合があるため、directoryを変更した際は影響する各テストで[対応付けの更新手順](requirements.ja.md#テストや対応付けの更新)を確認してください。

### 何を観測するか

意図的に発生させたUVMエラー自体が必要な観測の場合もあり、エラーメッセージだけでテストの判定が決まらない理由は[Q7](faq.ja.md#q7-なぜuvmの全メッセージを比較せずut行だけを比べるのですか)で説明しています。

1800.2が定めるのは、レポートを組み立てるメソッドの役割までで、出来上がる文字列ではありません。
`compose_report_message`（6.5.1.2.15）は重大度・コンポーネント名・ID・メッセージから文字列を作りますが、
`UVM_INFO file(line) @ time: name [id] msg`という並びはライブラリが決めています。
ファイル名、行番号、時刻の書式も、ライブラリとシミュレータで変わります。そこで次のようにします。

- **既定のレポート行は比べない。**
- **simulationテストは、観測した値を`UT: `で始まる行に`$display`で出す。** 出すのは規格が定める値だけです
  （フェーズの順序、件数、読み戻した値、比較の結果など）。期待出力と比べるのはこの行だけです。
  レポートの仕組みが壊れていても、他の章のテストが巻き込まれずに済みます。
- **レポートの件数は値で読む。** report serverの`get_severity_count`・`get_id_count`で読み、
  `UT: `の行に出します。
- **6章（レポート）のテスト**は、独自のreport serverやreport catcherを使い、規格が定める入力
  （重大度、ID、冗長度、動作）と結果の対応を`UT: `の行で確かめます。
- 規格が定めないものに依存しません。乱数の値、同時に始まるプロセスの順序、
  規格が定める以外の自動生成名などです。

sequencer relevance上限fixtureは独自zero-time callbackを数え、選択上限または最初の超過で未指定のerror通知を許容します。
通知または上限付きfallback後にcallbackをblockし、復旧を仮定せずownerを完了させます。正時刻からの初回burstは時刻0の比較対象と独立です。
private counter／reset規則は主張しません。

transaction-event fixtureは実pull portを動かし、規格typed callbackで指定item-pool eventを観測します。初回要求前に無効化し、
明示component markと独自address／data gateで後続完了をモデル化します。選択した通知／timestampを扱い、初期pool所属、DB配置、物理DUT動作は認定しません。

builtin-sequence宣言fixtureは実際の省略／明示constructor呼出し、正確なstatic base／target receiver、protected slot用の独自合法派生accessorを使います。
最小不正probeはvirtual直接生成とprotected外部accessをruntimeなしで評価します。実行中factory-child probeは実行childを宣言slotと選択対象へ照合し、
独自bodyによってbuiltin access／walk algorithmを認定しません。既存full-algorithm controlは別の引用と実行同一性を保持します。

## 期待出力の決め方

期待値の誤りが疑われるときは条項に基づく修正が必要で、シミュレータやライブラリの差分との切り分け方は[Q18](faq.ja.md#q18-期待値の誤りはどう報告修正しますか)で説明しています。

1. 引用した条項から期待出力を決めます（`:oracle: spec`）。
2. ライブラリのソース（Apache-2.0）は規格の理解のために読めますが、期待値は規格から決めます。
   ライブラリ自身の`DEVIATIONS.md`と[既知差分](known-differences.ja.md)で、
   ライブラリの制約と固定版で再現したoracleを区別します。
   不足する必須動作を直接検査するテストは、specのみの期待値を保持します。
3. 固定版での再現：
   - Verilator 5.052は、`UVM_NO_DPI`でライブラリをビルドして実行できます。x・zに依存せず、
     seed 1と73の両方で再現したテストには、kirimasim-testsと同じく`verilator@5.052`を付けます。
   - Icarus Verilog 13.0はUVMを実行できないので使いません。
4. シミュレータと期待出力が食い違っても、出力を写して解決しません。判断するのは条項です。

### テストから結果までの流れ

引用した条項から決める期待値と、実行から得る観測結果を、判定の段階で照合します。

![引用条項から決めた期待値と実行の観測を、ランナーが照合して結果へ記録する流れ。](images/test-to-result.ja.svg)

ビルド・実行の失敗も結果として記録します。ライブラリの識別情報も実行条件の一部で、
Ghostの同梱モードでは供給されたUVMを使います。ステータスとコマンドの終了コードは
[FAQ](faq.ja.md#結果の読み方)を参照してください。

## UVMライブラリ

シミュレータとUVMライブラリは別々の前提なので、実行ファイルやpackageが見つからない場合は[最初の実行の前に](reading-guide.ja.md#最初の実行の前に)を確認してください。

### 取得

lockファイルは実行に使うライブラリの版と内容を固定するもので、取得した本体をスイートのソースと分ける理由は[ライブラリの出典](provenance.ja.md#ライブラリと規格)で確認できます。

`python3 tools/fetch_uvm.py`は、`third_party/uvm.lock`が名指すリリースを
[accellera-official/uvm-core](https://github.com/accellera-official/uvm-core)
（タグ`2020.3.1`、コミット`78c06547a2a0`）から取得して`third_party/uvm/2020.3.1/`に置き、
展開したファイルの指紋（326ファイルそれぞれのパスとSHA-256）を確かめます。
取得先が圧縮し直すことがあるので、アーカイブ自体の指紋は使いません。
`--check`は、置いてあるコピーだけを確かめます。ライブラリはコミットしません。

### コンパイル

DPIはSystemVerilogから外部コードを呼ぶ仕組みで、DPIを有効にしたテストに必要な実装のリンクは[Q12](faq.ja.md#q12-uvm_dpi-yesだけでdpiを使うビルドが完成しますか)で説明しています。

- 固定版の実行は`src`をinclude先に追加し、テストより先に`src/uvm_pkg.sv`をコンパイルします。
  Verilatorは`-I`、kirimasim・Ghostは`+incdir+`を使います。Ghostの同梱モードは別途パッケージを供給します。
- テストが`:uvm_dpi: yes`としない限り`UVM_NO_DPI`を定義します。ライブラリのHDLバックドア用のDPIは、
  商用シミュレータ3種向けの実装しか持たないためです。DPIなしのライブラリは、`+UVM_TESTNAME`を自分で読み、
  名前の照合を正規表現ではなくglobで行い、コンポーネント名を検査しません。
  `UVM_NO_DPI`のサポートを削除するかもしれない、という警告も出します。
  正規表現や組み込みのHDLバックドアに依存するテストは`:uvm_dpi: yes`とし、DPIを読み込める対応環境が必要です
  （`UVM_HDL_NO_DPI`ならバックドアだけを外せます）。
- ユーザー定義の`uvm_reg_backdoor`による記憶域handlerはHDL DPIなしで使えます。
  商用シミュレータの実行・結果はプロジェクトの方針で除外し、組み込みHDL path／DPIの検査は未完です。
- 現在の2531件は`UVM_NO_DPI`を使い、38件はHDL DPIを明示的に有効にします。
  `:uvm_dpi: yes`はこのマクロを外す指定で、
  C/C++のDPI実装を自動でビルド・リンクする指定ではありません。
  現在のVerilatorランナーはDPIのC/C++ソースを追加しません。
- `:uvm_defines:`で`UVM_ENABLE_DEPRECATED_API`を指定できますが、現在は付録Hのテストも、
  このマクロを要求するテストもありません。

ここで通常runnerとは`tools/run_verilator.py`を指し、[HDL runner](#verilatorのvpi-hdl部分集合)と[command-line runner](#verilatorのcommand-line部分集合)は、選択した検査系に必要な実装を明示的にlinkします。

### VerilatorのVPI HDL部分集合

このbackendはUVMのDPI呼出しをシミュレータの公開VPI interfaceへ接続するもので、2つのinterfaceと測定範囲の関係は[HDLの実行条件](glossary.ja.md#hdlの実行条件)で説明しています。

別の[HDL runner](../tools/run_verilator_hdl.py)は独自[backend](../tools/uvm_hdl_vpi.cpp)をlinkし、実HDL storageを使います。
Verilatorは5.052固定で、38検査系は`:uvm_dpi: yes`、`:uvm_hdl_backend: vpi`、宣言した`:dpi_c:`を設定します。
`UVM_REGEX_NO_DPI`と`UVM_CMDLINE_NO_DPI`で無関係なimportを無効にし、runnerはどちらのdefines fieldでもHDL無効化macroと既定1024-bit UVM DPI ABIの変更を拒否します。

ABIはSystemVerilogとCが値を受け渡す形式で、その容器は1024 bitに固定され、このbackendが現在accessするpacked objectは64 bitまでなので、宣言上の幅と実access能力の区別は[Q182](faq.ja.md#q182-hdl幅parameterの検査はforcerelease対応も示しますか)で確認できます。

```sh
python3 tools/run_verilator_hdl.py --seeds 1 73 --build-jobs 2 -j 1 \
  --json out/verilator-hdl.json
```

check／read／depositは64 bit以下の対応packed handleへ到達します。memory 3検査系は実16-bit array wordと8／16-bit分割bankを扱い、neighbor cellで分離を確認します。
固定libraryのbackdoor_readがprotectedであるため、継承taskの2検査系は独自公開wrapperを使います。
別の合法宣言probeで公開readのaccess差分を保持し、wrapperの成功でその契約をpassにはしません。

force／releaseは公開forceable packed信号を必要とします。backendは文書化された公開capability markerを確認し、実handleへ標準VPI flagを使います。
公開markerそのものへの書込みやpath／valueの模擬は行いません。[公開extensionの文書](https://verilator.org/guide/latest/extensions.html)は統合interfaceの参照先で、5.052での動作は独自probeと現在の測定で確認します。
8／40-bit reg／wireの8入力は、反対値への更新中のforce保持、通常release、即時release/read、後続更新を扱い、別の1入力は存在しない／未instrument pathと有効controlを区別します。
regは次の手続き代入までforce値を保持し、駆動wireは即時に解決値を返す違いを[HDLのFAQ](faq.ja.md#hdlのforceとreleaseの条件)で説明しています。

可視性と評価の制約は[公開VPI文書](https://verilator.org/guide/latest/connecting.html#verification-procedural-interface-vpi)を参照してください。
deposit／forceの観測は再評価後、release/readの戻り値は呼出し直後に確認します。
一般array／select／型、時間単位変換／丸めや重なり／失敗を含む広いforce_time条件、4値、細かな権限、vendor overlayは未完で、simulatorの実装sourceは読みません。

通常runnerはbackendをlinkせず、全38件が`:oracle: spec`を保持します。別の`verilator_hdl`同一性、`runner_sha256`、backend設定で同じ期待値を使います。
37件は両seed一致、E.7 warning／転送なしの1件はseed 1差分で、厳格なHDL runnerは不一致で失敗終了します。
以前の28記録を保持し、未変更backendでregisterの物理6入力を新たに測定します。公開backdoor_read直接呼出し、peek、pokeは16／40-bit whole変数と合法な2変数split表現を扱います。
標準concat viewのget_slices欠落とは分離し、[register pathのFAQ](faq.ja.md#register-hdl-pathと観測の前提)でsymbolic controlと実HDLの違いを説明しています。
通常38件のDPI link失敗とは別の重複条件です。

現在のIEEE本文にないalgorithmの詳細には、明示的に限定したAI解釈を記録する場合があります。
memory-walkの公式の歴史的資料とレビュー上の限定は[Q134](faq.ja.md#q134-memory-walk-algorithmをどう解釈していますか)にあり、algorithm実装の複製や測定出力をoracleにしません。

### Verilatorのcommand-line部分集合

この条件は追加でリンクするbridgeを通じて実際のプロセス引数を観測し、通常runnerの結果で代用できない理由は[command-lineのFAQ](faq.ja.md#実command-lineと別実行条件)で説明しています。

[別runner](../tools/run_verilator_cmdline.py)は、標準VPIを通す独自の[引数bridge](../tools/cmdline_backend/uvm_cmdline_vpi.cpp)を使います。
[regex wrapper](../tools/cmdline_backend/uvm_cmdline_regex.cpp)は固定したApache-2.0 UVM regex実装をcompileし、
[移植用header](../tools/cmdline_backend/malloc.h)はmalloc headerのないhostへ標準の割当宣言を提供します。
bridgeへUVM parserを複製せず、simulator実装sourceも使いません。合成した一覧ではなく、実process引数です。

検査系は`:uvm_dpi: yes`、`:uvm_cmdline_backend: vpi`、`:uvm_defines: UVM_HDL_NO_DPI`を指定し、
bridgeを`:dpi_c:`、wrapper／headerを`:files:`へ宣言します。directory内容とlibrary lockをfingerprintへ含めます。
backend検証はcommand-line／regex DPI無効化、宣言欠落、別backend、4-state検査系を拒否します。HDL accessは無効で、
任意のregex、不正option、4-stateの完全性は主張しません。

```sh
python3 tools/run_verilator_cmdline.py --seeds 1 73 --build-jobs 2 -j 2 \
  --json out/verilator-cmdline.json
python3 tools/run_verilator_cmdline.py --all --seeds 1 73 --build-jobs 2 -j 2 \
  --json out/verilator-cmdline-all.json
```

既定では`:uvm_cmdline_oracle: verilator@5.052`で再現済み17検査系を選びます。`--all`はspecのみのquit警告検査を加え、
差分をpassではない`known`で記録します。再現済み選択検査の回帰は`fail`で、終了codeも非zeroです。
modelを1回buildし、両seedを新規processで実行します。別の`verilator_cmdline`結果同一性でrunnerを独立にhashし、generic期待出力を共有します。
重複する通常18記録はDPIのlinkに失敗するため、両条件を分けます。Checkは既定のcommand-line 17件を実行し、既知差分の1件は実行しません。

## スイートの実行

通常・HDL・command-lineのrunnerはlinkする実装が異なるため、検査系に合う環境は[runnerの選択ガイド](reading-guide.ja.md#実行条件を選ぶ)で確認してください。

`/path/to/kirimasim`などのパスは手元の実行ファイルの場所へ置き換える例で、コマンドを使う前の準備は[必要な環境](faq.ja.md#q2-必要な環境とuvmの取得元は何ですか)で確認できます。

Verilatorの終了コードはタグ付きの不一致を集計するため、specのみのケースを含めるときに個々のstatusも必要な理由は[Q6. KNOWNがあるのにVerilatorコマンドが成功するのはなぜですか](faq.ja.md#q6-knownがあるのにverilatorコマンドが成功するのはなぜですか)を参照してください。

`--all`は選んだrunner内の検査対象を広げる指定で、[HDL backend](#verilatorのvpi-hdl部分集合)や[command-line bridge](#verilatorのcommand-line部分集合)をlinkするものではなく、それぞれ別のrunnerを使います。

UVM取得後は、インストールしたシミュレータのコマンドを選び、最初は以下の全件実行より小さい[1件の実行例](faq.ja.md#q3-まず1件だけ動かすにはどうしますか)から確認できます。

```sh
python3 tools/fetch_uvm.py
python3 tools/run_kirimasim.py --kirimasim /path/to/kirimasim -j 8 --json out/kirimasim.json
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 2 --json out/verilator.json
```

ランナーにはPython 3.10以降が必要です。結果のJSONはkirimasim-testsと同じ形
（`tools/suite_results.py`）なので、履歴やレポートのツールでそのまま読めます。
`run_verilator.py`はテストごとにUVMパッケージ全体をビルドします。
`-j`は並行するテスト数、`--build-jobs`は各テストのC++ビルド並列数です
（既定の0はすべてのハードウェアスレッド）。ccacheは使いません。Verilatorは大きなモデルを
事前コンパイル済みヘッダーでビルドし、そこにビルド先の絶対パスが入るので、ccacheが別の場所で作った
ヘッダーを返すとビルドが壊れるためです。

runtimeでは`--seeds 1 73`で各モデルを一度だけビルドし、seedごとに新しいプロセスで実行します。
要求した全runtime seedで一致した場合だけ成功です。従来の`--seed N`も使えます。
結果JSONのconfigurationには、指定に応じて`seed`か`seeds`を記録します。

Verilatorの既定の対象はoracle付き・2値の2165件（runtime 2071・期待compiler拒否94）です。`--all`を付けるとspecのみの422件も含めます。
oracleのないテストの不一致は`known`で、コマンドを失敗させません。oracle付きの不一致は失敗です。
テストのパスを明示した場合は、そのテストだけが対象です。スモークテスト1件の実行例です。

```sh
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 1 \
  --json out/verilator-smoke.json tests/u09/test_common_phases_run_in_order.sv
```

seedの一覧は複数の値を受け取るため、[1件を実行する例](faq.ja.md#q3-まず1件だけ動かすにはどうしますか)のように`--seeds 1 73`とソースのパスの間へ`--build-jobs`などのoptionを置いてください。

runtimeの不一致は、選択したテストのヘッダーにある`:expected_stdout:`のパスを辿り、[結果の読み方](reading-guide.ja.md#結果を読む)に沿って`UT: `行を比較すると調べられます。

JSONは`tests`内の各ケースに`status`、記録がある場合は`reason`、入力の指紋を保存し、コマンドの終了コードと併せた読み方は[結果のガイド](reading-guide.ja.md#結果を読む)で確認できます。

保存したテストIDと判定は専用のJSONツールなしでも表示でき、コマンド終了後に使う[Pythonの例](reading-guide.ja.md#結果jsonを開く)を用意しています。

各実行は一時的なビルドディレクトリを使います。`out/`はGitの対象外で、CheckはそのJSONを公開しません。
結果の分類・終了コード・指紋の読み方は[FAQ](faq.ja.md)を参照してください。

### Ghost

Ghostは利用が認められた非公開シミュレータの公開用の仮名であり、結果が前提にするライブラリのモードは[Q11](faq.ja.md#q11-ghostの結果は何を確認しなぜ仮名なのですか)で説明しています。

```sh
python3 tools/run_ghost.py --simulator /path/to/private/simulator \
  --profile /path/to/private-profile.json -j 2 --json out/ghost.json
```

非公開のJSONプロファイルに`arguments`（文字列の配列）、`environment`（文字列の対応表）、
`uvm_mode`を明示します。

- `pinned`：固定版UVMをテストより先にコンパイルします。同梱UVMの自動読み込みは
  プロファイル側で無効にします。
- `bundled`：UVMの供給をプロファイルとシミュレータに任せ、別のパッケージをコンパイルしません。
  共通の規格期待値と比較しますが、**固定版ライブラリの実行証拠にはしません**。
  テストの`:uvm:`から同梱ライブラリの版を推測しません。

同梱モードのプロファイルには、ソースとヘッダーを含む非公開ディレクトリ`uvm_library_dir`も
指定し、実行引数で同じライブラリを選びます。コードもヘッダーも実行ファイル内に組み込まれて
いる場合だけ、代わりに`uvm_embedded: true`を指定します。この2通りのどちらかが必要です。
ディレクトリのパスは結果に書きません。

公開JSONには`uvm_source`、`uvm_pinned`、テストが前提にする版（`test_uvm`）、実行ファイルと
プロファイルのSHA-256を記録します。固定版とディレクトリに置かれた同梱版では、ライブラリの
内容の指紋とファイル数も記録します。
シミュレータの名前・版・パス、プロファイルの内容、診断は公開しません。
実行中に実行ファイル・プロファイル・ライブラリが変わったら、結果を書きません。
固定版モードでは、実行前にライブラリの内容がlockと一致することも確かめます。

## 検査

以下のコマンドはライブラリ・ツール・テストの記述を検査し、Checkが追加で行うシミュレータの検査は[継続的インテグレーション](results.ja.md#継続的インテグレーション)で説明しています。

ライブラリの検査には取得済みのコピーが必要なので、まだない場合は[取得](#取得)の手順を済ませてから、以下の検査コマンドを実行します。

```sh
python3 tools/fetch_uvm.py --check
python3 -m unittest discover -s tools -p 'test_*.py'
python3 tools/lint_metadata.py
python3 tools/requirements.py check
```

現在のツールの単体テストは110件、メタデータの対象はテスト2587件（simulation 2488件・elaboration 99件）です。
[台帳の検査](requirements.ja.md)は、範囲案、明示した期待値への対応、入力の指紋を検査し、カバレッジを主張しません。
[Check](../.github/workflows/check.yml)は`main`へのpush・pull request・手動実行で動きます。
Verilator matrixの各jobは5.052・`UVM_NO_DPI`・seed 1と73でoracle付きのテストを実行し、
各モデルを一度ビルドして2回使います。Checkの成功はその検査の成功を示し、
UVMの全要求や全シミュレータの成功を示すものではありません。

以前の分割前[Check実行](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/41976785278)は、設定された150分のjob上限を超えました。
現在のworkflowは現在のタグ付き2165検査を重複しない8 shard（271／271／271／271／271／270／270／270）へ分け、同時shard jobは最大4です。
和集合の完全一致と重複なしをlocalで検証しました。command-line 17検査はshard 0で通常検査の前に1回だけ実行します。
seed 1／73、compiler拒否の判定規則、固定依存関係、runner指紋は未変更です。従来のverilator gateは全shardの成功を要求します。shard分割は実行の構成であり、local検証でhosted workflowの成功は立証しません。

## テストの追加・修正

watchdogはblockingの観測で待つ時間に上限を設ける仕組みで、完了しない動作を検出する役割は[実行の用語](glossary.ja.md#実行と結果)で説明しています。

source、helper、期待値を変えると入力同一性が変わるため、古い結果を再利用する前に[テストや対応付けの更新](requirements.ja.md#テストや対応付けの更新)に従ってください。

商用シミュレータの結果・出力・診断は、非公開・第三者・匿名化した資料も含め、期待値、実装判断、Issueへ利用しません。
[投稿方針](faq.ja.md#商用シミュレータとissueの投稿方針)と[Issueフォーム](../.github/ISSUE_TEMPLATE/report.yml)を使い、
報告のために商用製品を実行しないでください。Ghostの仮名を使えるのは本プロジェクトのゲストの公開用結果だけです。

シミュレータを動かす前に、引用した規格から観測結果を決めます。テストは独立させ、
規格が定める結果だけを`UT: `行に出力します。シミュレータとライブラリの組み合わせで差があっても、
規格の期待値を保持します。初期化付き手続き内ローカル変数は寿命を明示し（SystemVerilog 6.21）、
forkの共有状態が生存するようにし、blockingの観測にはwatchdogを設けます。
メタデータとツールを検査し、固定版のoracleタグは両seedで再現してから付けます。
規格PDFはローカルに置き、Gitの対象にしません。

## 権利と出典

スイートのライセンス、取得するライブラリのライセンス、引用する規格はそれぞれ別の資料に適用されるため、以下の規則を読む前に[出典の説明](provenance.ja.md#ライブラリと規格)で対応を確認できます。

- 1800.2の本文・図・サンプルコードは転載しません。条項番号を引用し、自分の言葉で説明します。
- UVMライブラリはApache-2.0です。取得するもので、コミットしません。
  コミットする場合は、`LICENSE.txt`と`NOTICE.txt`を一緒に置きます。
- GPL・LGPLのシミュレータ（Icarus Verilog、Verilator）の実装ソースは読みません。
- 公開前のシミュレータの名前、版、実行プロファイル、パスは公開しません。

## ドキュメントの更新

コマンド、メタデータの例、実行結果の表などで説明が必要になりそうな箇所には一文の補足を置き、同じ言語の詳しい説明の見出しへ直接リンクしてください。

重要な用語が初めて出る箇所には短い説明と、[用語集](glossary.ja.md)・[FAQ](faq.ja.md)・[読み方ガイド](reading-guide.ja.md)の該当する節へのリンクを添え、その場から読み進められるようにします。

プロジェクトの各ガイドには英語の`.md`と日本語の`.ja.md`を用意し、見出し、事実、コマンド、表、図、
リンクを対応させて、同じ変更で両方を更新します。API名、metadata、コマンドのoption、期待出力など、
機械が読む文字列の表記は変えません。[LICENSE](../LICENSE)の原文には、全文の非公式な
[日本語参考訳](../LICENSE.ja.md)を用意します。

SVGは`docs/images/`に`.svg`と`.ja.svg`の対で置き、label、`title`、`desc`を翻訳します。
SVGのソースを直接編集できるため、両版のnode、矢印、method名を対応させて維持します。
埋め込む画像には、その言語で内容を説明するMarkdownの代替テキストを付けます。

READMEには現在の対象範囲、前提環境、コマンド、実行結果、未完の作業を記載します。
追加作業の経緯と過去の測定は[履歴](history.ja.md)、現在の測定方法は[実行結果](results.ja.md)、
ソースの由来は[出典](provenance.ja.md)へ記載します。節を移動したら、両言語のローカルリンクとanchorを確認します。
