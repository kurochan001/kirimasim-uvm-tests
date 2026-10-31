# 用語集

[English](glossary.md) · [README](../README.ja.md) · [FAQ](faq.ja.md)

このリポジトリのテストや結果で使う言葉をまとめています。読むための手引きであり、
各テストの期待値の根拠は、そのテストが引用する規格の条項です。

## 規格と期待値

**UVM／IEEE 1800.2-2020** — Universal Verification Methodology。
このスイートが確認するクラス・API・動作の規格です。固定したAccellera実装は要求を実行するための
ライブラリであり、期待値の根拠そのものにはしません。

**SystemVerilog／IEEE 1800-2023** — UVMを動かす言語とその規格です。
言語だけで再現できる検査はkirimasim-tests、UVMライブラリを実行したときの動作はこのスイートで扱います。

**LRM／条項／`:lrm:`** — 参照マニュアル、規格の特定の箇所、それを記録するメタデータです。
UVMの条項は`1800.2-2020`の後に書き、必要なら言語の条項を`1800-2023`の後に追加します。
引用は、直接検査する動作だけでなく準備に使うAPIを示す場合もあります。

**適合性テスト／観測** — 規格から導いた小さな設計と期待結果の組／実際に確認する値・件数・順序・状態です。
APIを呼ぶだけで、要求された結果を観測していなければ、その動作を検査した証拠としては不十分です。

**期待出力／`.expected`** — テストが再現すべき観測行です。行頭が正確に`UT: `で始まる行だけを選び、
順序・空白・値を保持して比較します。終了コードや診断の条件は別に指定できます。

**oracle／`:oracle:`／specのみ** — 期待値の根拠を記録する項目です。
`spec`は引用した規格に基づくこと、`verilator@5.052`はその固定リリースでも再現できたことを示します。
specのみは固定版のoracleタグがない状態です。後の実行で一致しても、タグは自動で変わりません。

**照合／`:spec_check:`** — 規格と期待値を照合した主体の記録です。
`ai`はAI、`human`は人による照合を示します。シミュレータとの一致とは別で、現在は全件が`ai`です。

## UVMの構成要素

**object／component** — UVMのデータやpolicyを表すobject／UVM階層のノードとしてphaseに参加するcomponentです。
componentにはtest・environment・driver・sequencerなどがあります。

**factory／wrapper／registry** — 型の生成・置換の仕組み／登録した型を表すproxy／
factoryを通してobjectやcomponentを登録・生成する補助です。型名とinstance pathは置換の選択で別の役割を持ちます。

**config_db／resource** — scopeとfield名で選ぶ型付き設定／その基になる設定値と検索の仕組みです。
scope・型・優先度・更新を検査します。固定版のfield名globの制約は別に記録します。

**policy／copier／comparer／printer／packer** — copy・比較・表示・packの動作を制御するobjectです。
規定された値やhookを観測します。ライブラリ固有の表示形式やobjectのpack形式が、そのまま規格の要求になるわけではありません。

**phase／task phase** — UVM実行の段階／callbackがtaskで、シミュレーション時間を消費できるphaseです。
階層を辿る順序や終了の規則は、phaseの種類で異なります。

**objection／drain time** — phaseや処理を続けるための件数付きの意思表示／all-dropped処理で設定できる待ち時間です。
object自身の件数、親へ伝搬した合計、objector一覧は異なる観測点なので、1つの確認で全部を確認したとは扱いません。

**sequence item／sequence／sequencer／driver** — transaction／刺激を作る処理／
その要求を仲裁・配送するcomponent／要求を受けて完了や応答を返すcomponentです。
このスイートでは公開port・exportを接続してから通信を検査します。

**完了通知／応答** — `item_done`などによる要求の完了通知／sequenceへ返すデータです。
`get`は要求を取り出すと同時に完了通知も行います。完了通知だけで、別の応答データも届いたとは判断できません。

**grant／`send_request`／完了待ち** — itemを送信する許可／低水準の送信呼び出し／
`item_done`または`get`の暗黙の完了通知を待つ操作です。grant後はシミュレーション時間を進めずに
送信します。特定のtransaction IDの待機は、その完了通知より前に開始する必要があります。

**`start_item`のsequencer選択** — 明示的な引数、itemに設定されたsequencer、実行中sequenceの
sequencerの順で選びます。itemの優先度が非負ならその値を使い、負ならsequenceから継承します。
不正なitemやcontextの不足ではERRORが必要です。

**transaction ID／sequence ID／`set_id_info`** — 応答を選択取得するときの要求・応答の識別子／
sequenceへの配送に使う識別子／応答へ関連するIDをコピーするAPIです。
テストは明示したtransaction IDを表示し、実装が割り当てるsequence IDの数値には依存しません。

**arbitration／priority／relevance** — 要求中のsequenceからの選択／選択の入力となる優先度／
現在そのsequenceを選べるかです。USER modeは選択をcallbackへ委ねます。
relevanceを上書きするsequenceは、それに対応する`wait_for_relevant`も実装します。

**lock／grab／unlock／ungrab** — sequenceによる所有と、その解放です。
lockは通常の仲裁に加わり、grabは先頭に入りますが、互換性のない所有者がいれば待ちます。
子は親のlock下でも取得でき、取得中は親を一時的にblockedにできます。
`has_lock`と`is_blocked`は別の状態を照会します。

**kill／`do_kill`／`stop_sequences`** — sequenceの停止／停止hook／sequencerで実行中のsequenceの停止と
キューの後処理です。killで要求される`post_body`・`post_start`は`do_kill`とは別のhookで、
固定版ライブラリが呼び出さない差分を既知差分として保持します。
stopでも自動starting-phase objectionを解除する必要がありますが、固定版のrootを停止する経路では、
直接の`kill`と異なり件数が残ります。

**default phase sequence** — sequencerとphaseのscopeで型付きの`default_sequence` resourceから選ぶsequenceです。
wrapperならfactoryで生成し、instanceならそのobjectを使います。優先度で選び、選択されたnullは無効化を示します。
sequencerと開始phaseを設定し、無効化しない限りrandomizeして実行します。phase終了時も動いていればkillします。

**resourceのprecedence／キューのpriority／型フィルタ** — 一致するresource間の優先度／
名前や型のキュー内での順序／default sequenceの規定が認めない型の除外です。
最高のprecedenceが同じ場合は、残ったキューの最初の要素を選びます。instanceという型だからwrapperより
優先するわけではなく、無関係な型のnullはdefaultの無効化にはなりません。

**callback／typewide登録／iterator** — 登録した拡張hook／単一instanceではなく型の組み合わせに適用する登録／
適用可能で有効なcallbackを辿るobjectです。登録順・継承・途中終了はそれぞれ別の検査対象です。

## Transaction単位の通信

**TLM／port／export／implementation** — Transaction-level modeling／呼び出し側の口／
呼び出しを転送する口／APIを実装する終端です。通常のelaborationで接続を解決してから通信を観測します。

**FIFO／blocking／nonblocking** — 到着順のキュー／データや空き容量を待てる操作／
その待機をせずに利用可否や成否を返す操作です。失敗した読み出しの出力引数は、規格が定める場合だけ検査します。

**analysis port／analysis FIFO** — 値をsubscriberへ配送するwriteの口／そのwriteを受けるFIFOです。
objectはハンドルのまま配送される場合があり、必ずcloneされるとは限りません。
subscriber同士の未規定の呼び出し順は仮定しません。

**TLM 2のpayload／extension／socket／phase／delay** — transactionのデータ／型付きの追加情報／
transportの接続／protocolの進行状態／時間の注記です。TLM 2のprotocol phaseとUVM実行のphaseは別です。
accessorや接続の検査だけで、protocolやtimingの全体を検査したとは扱いません。

**canonical time／`uvm_tlm_time`／annotation** — 呼び出し側の時間単位と独立した遅延の表現／
TLM 2が使う`uvm_time`のtypedef／transactionの時点に付く時間のoffsetです。
注記を変えるだけではシミュレーション時刻は進みません。絶対APIは1単位の秒数を指定し、
scaled APIはそれに対応するゼロでないtime literalの値も使います。

**pass-through socket** — 階層を跨ぐTLM 2の接続です。nonblockingのinitiator側はforward portと
backward export、target側はforward exportとbackward portを持ちます。
socketの`connect`はforwardに加え、逆方向の接続も供給します。

**callbackのinteger iterator／facade** — `uvm_callbacks::get_first/get_next/get_last/get_prev`が使う
内部表現を仮定しない整数の位置／objectのAPIを持つ`uvm_callback_iter`です。
static APIは終端で再開するまでnullを返します。nullのobject文脈はtypewideのキューを検索します。
別々の位置やfacadeを使えば独立して走査できます。

**nonblocking transport／`nb_transport`** — 即時に要求・応答を完了できれば1、できなければ0を返す操作です。
呼び出し中の同期的なanalysis callbackが応答を供給できます。
0という結果だけでは、出力引数の特定の値や、要求側の途中の副作用がなかったことは示せません。

**push sequencer／push driver** — driverのblocking `put`を呼ぶsequencer／
`req_export`でその呼び出しを受けるdriverです。`put`から戻ると、その要求が完了します。
応答はdriverのanalysis `rsp_port`からsequencerの`rsp_export`へ返せます。

**sequence操作マクロ** — `uvm_create`は生成とcontext設定、`uvm_send`は乱数化なしの実行、
`uvm_rand_send`は乱数化と実行、`uvm_do`は生成から乱数化付きの実行までを行います。
子sequenceでは乱数化の有効・無効を尊重し、`call_pre_post`を0にして開始します。

**payloadのpack／配列の有効長** — TLM 2 generic payloadの規定されたフィールドを直列化する処理／
data・byte-enableの配列から含めるbyte数です。余分なbyteは含めず、配列が有効長より短い場合は
fatalを報告します。extensionは既定のpack対象に含まれません。

**sequence library／登録wrapper** — sequenceの型の集合から実行するものを選ぶsequence／
その型を識別するfactoryの記述子です。instanceへの登録は局所的で、typewideの追加は以降に生成する
instanceへ反映されます。一覧取得は呼び出し元のqueueへ追記します。

**libraryの選択mode／実行回数** — 登録sequenceを選ぶ規則／実行中の子を含めない完了済みの子の数です。
既定のuser選択hookは0から上限値までのindexを返し、その後0へ戻ります。
hookを直接呼んでも子は実行されず、USER modeでの実行を検証したことにはなりません。

**fieldの`rand_mode`／子の乱数化enable** — 個々の乱数変数を変更できるか／子sequenceの操作で
`randomize`自体を呼ぶかの制御です。fieldだけを無効にしても、乱数化のcallbackは呼ばれます。
この2つの制御は別に検査します。

**master／slave／分割imp** — TLM 1で要求を書き応答を読むinterface／要求を読み応答を書くinterface／
要求側と応答側を別々の兄弟componentへ委譲するimpです。constructorの`req_imp`・`rsp_imp`引数で、
親とは独立に実装componentを指定します。

**通常のTLM 2 export／型parameter** — portと実装の間を中継する接続／
その接続が扱うtransactionとnonblocking phaseの型です。forwardとbackwardは個別に接続します。
汎用の型の伝搬とbase protocolの網羅は別の検査対象です。

**FIFOの`put_ap`／`get_ap`** — 受け入れた書き込みのanalysis通知／成功したget・peekの通知です。
peekはキューのitemを残しながら通知する必要があります。利用可否の照会や転送の失敗は、通知対象の
transactionを供給しません。

**外部objectのcallback実行** — マクロの呼び出し元ではなく、引数で指定したobjectに登録された
callbackを実行する操作です。無効なentryを飛ばし、exit-onでは指定した真偽値が返ると途中終了します。
テストは不一致時の戻り値の方針を決めつけません。

## 実行と結果

**ランナー／メタデータ** — ビルド・実行・判定を行う`tools/run_*.py`／
テスト冒頭のコメントでその動作を指定する項目です。対応するoptionやライブラリのmodeも実行条件に含みます。

**`pass`／`fail`** — 期待出力と、指定した終了・診断の条件が一致した結果／
条件に合わない、またはビルド・実行できなかった結果です。不一致1件がシミュレータの不具合1個とは限りません。

**`known`／`unsupported`** — このVerilatorランナーでoracleタグのないテストが判定に合わない結果（ビルド失敗も含む）／
kirimasimが未対応と明示した構文などの結果です。どちらも成功には数えません。
Ghostは`pass`・`fail`で記録し、同梱ライブラリの差を`known`へ変更しません。
コマンドの終了条件は[FAQ](faq.ja.md)で説明します。

**seed／2値／4値** — 乱数を使う実行条件の入力／X・Zを含まない値／X・Zを含む値です。
固定版Verilatorのoracleでは、X・Zに依存しないテストをseed 1・73で確認します。
2つのseedで成功しても、すべてのseedの正しさを証明したとは扱いません。

**DPI／`UVM_NO_DPI`** — SystemVerilogから外部コードを使う仕組み／UVMのDPIに依存する実装経路を無効にするマクロです。
現在のテストはこのマクロを使います。マクロを外すだけでは、必要なC/C++実装の供給やリンクは行われません。

**固定版ライブラリ／lock／同梱ライブラリ** — `third_party/uvm.lock`で指定した正確なライブラリ／
その版・コミット・ファイル数・内容の指紋／シミュレータやprofileが供給するライブラリです。
同梱版の結果は、固定版で実行した証拠にはなりません。

**指紋／SHA-256／結果の合算** — 入力やツールの内容を比較する識別値／その計算方法／
入力・ランナー・設定の同一性を確認した複数の実行結果をまとめることです。
指紋の一致は保存済みの結果を再利用する根拠であり、新しく実行したことにはなりません。

**watchdog** — blockingのテストで完了を待つ時間に上限を設け、完了しなければ失敗として知らせる仕組みです。
正の遅延を入れることで、同じ時刻のプロセス順に頼らず待機状態を観測できます。

## 範囲とカバレッジ

**M0〜M4** — [開発段階](../README.ja.md#進め方)です。基盤、基本UVM、TLM・sequence・callback、
レジスタ層、レビュー済みの要求台帳の順で進めます。次の段階を始めても、前の段階の完了を保証しません。

**条項の引用／要求カバレッジ／一致件数** — メタデータの参照／定義した要求と条件を検査する証拠／
特定の実行で期待値に一致したテスト数です。それぞれ分母が異なります。
このリポジトリでは要求カバレッジの分母をまだ承認しておらず、テスト総数やoracle件数はその割合ではありません。

**Check／Nightly** — このリポジトリの検証workflow／kirimasim-testsで使う別の定期実行・報告workflowです。
こちらには現在Checkだけがあります。バッジは、全シミュレータの一致率を示すものではありません。
