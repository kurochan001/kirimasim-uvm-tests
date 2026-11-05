# 用語集

[English](glossary.md) · [README](../README.ja.md) · [FAQ](faq.ja.md)

これらの用語を最初の実行と結果へ結び付ける読み順は、[読み方ガイド](reading-guide.ja.md)で案内しています。

このリポジトリのテストや結果で使う言葉をまとめています。読むための手引きであり、
各テストの期待値の根拠は、そのテストが引用する規格の条項です。

主な分類は[期待値](#規格と期待値)・[UVMの構成要素](#uvmの構成要素)・[transaction単位の通信](#transaction単位の通信)・[レジスタモデル](#レジスタモデル)・[実行記録](#実行と結果)・[カバレッジの件数](#範囲とカバレッジ)で、読んでいるページに出てくる用語の分類から調べられます。

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

これらの名前はテストベンチ内の役割を表し、test class、phase、objectionは[動作確認用テストのソース](../tests/u09/test_common_phases_run_in_order.sv)、そのヘッダーは[テスト形式のガイド](testing.ja.md#例)で確認できます。

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

**sequence library／登録wrapper** — sequenceの型の集合から実行するものを選ぶsequence／
その型を識別するfactoryの記述子です。instanceへの登録は局所的で、typewideの追加は以降に生成する
instanceへ反映されます。一覧取得は呼び出し元のqueueへ追記します。

**libraryの選択mode／実行回数** — 登録sequenceを選ぶ規則／実行中の子を含めない完了済みの子の数です。
既定のuser選択hookは0から上限値までのindexを返し、その後0へ戻ります。
hookを直接呼んでも子は実行されず、USER modeでの実行を検証したことにはなりません。

**fieldの`rand_mode`／子の乱数化enable** — 個々の乱数変数を変更できるか／子sequenceの操作で
`randomize`自体を呼ぶかの制御です。fieldだけを無効にしても、乱数化のcallbackは呼ばれます。
この2つの制御は別に検査します。

**libraryのstatic所属／subtypeの構築** — `uvm_add_to_seq_lib`で登録したsequence型／
utilitiesマクロとconstructorを使ってlibraryのsubtypeを生成することです。継承分を含む登録済みの型は、
公開の一覧で取得できる必要があります。instanceへの追加登録は別の操作です。

**`finish_item`の委譲／完了ID** — convenience操作が呼ぶsequenceのvirtualな送信・待機method／
待機へ渡すitemのtransaction IDです。データの到着だけでは、必須の呼び出しと引数が守られたとは示せません。

**extensionのtype handle／type-handle名** — TLM 2 extensionの型を識別する不透明なkey／
その識別名です。名前を持つ個別のinstanceではなく型を識別します。payloadの検索にはhandleを使い、
型名のテストは特定の修飾形式を指定せず、同一性・相違を比較します。

**databaseの接続hook** — database拡張が実装するopen／close処理です。接続だけの検査系で外部backendを使わず呼出し数と成否を制御します。
別のmemory内stream hookがlifecycleのmetadataを検査し、接続状態だけではrecordingの動作を示しません。

**異なるkey数** — poolの占有数は、保存する異なるkey数を数えます。既存keyの値の置換ではentryは増えず、
欠落keyの生成やkeyの削除では件数が変わり得ます。

**待機中の所有権要求の解放** — sequenceのkillやsequencerの全sequence停止によって、待機するlock／grab要求を削除することです。
後の転送成功と別の待機者の生存によって、何もない状態のstopと区別します。

**統計の累積copy** — report-serverのcopyは元の統計を宛先へmergeし、元のentryで一致するcountを置き換え、
宛先だけのIDを保持します。元のcountが0でも、0でない宛先countを置き換えます。

**出力への所属** — printerの出力に、選択したfield名や値があることです。固有markerにより、配置を固定せずに、
名前の制御、配列の負の境界、再利用を検査します。

**comparisonのreport観測区間** — 比較hookの中で個別の不一致reportを数える区間です。後のframeworkの集約報告は区間外にし、
comparerの結果は全fieldの不一致を引き続き数えます。

## Transaction単位の通信

TLMはテストベンチの構成要素の間でtransactionを渡す仕組みで、注記した遅延と実際の待機の効果の違いは[Q25](faq.ja.md#q25-tlmのdelay-annotationを変えるとシミュレーション時刻も進みますか)で説明しています。

**push sequencer／push driver** — driverのblocking `put`を呼ぶsequencer／
`req_export`でその呼び出しを受けるdriverです。`put`から戻ると、その要求が完了します。
応答はdriverのanalysis `rsp_port`からsequencerの`rsp_export`へ返せます。

**sequence操作マクロ** — `uvm_create`は生成とcontext設定、`uvm_send`は乱数化なしの実行、
`uvm_rand_send`は乱数化と実行、`uvm_do`は生成から乱数化付きの実行までを行います。
子sequenceでは乱数化の有効・無効を尊重し、`call_pre_post`を0にして開始します。

**payloadのpack／配列の有効長** — TLM 2 generic payloadの規定されたフィールドを直列化する処理／
data・byte-enableの配列から含めるbyte数です。余分なbyteは含めず、配列が有効長より短い場合は
fatalを報告します。extensionは既定のpack対象に含まれません。

**TLM／port／export／implementation** — Transaction-level modeling／呼び出し側の口／
呼び出しを転送する口／APIを実装する終端です。通常のelaborationで接続を解決してから通信を観測します。

**master／slave／分割imp** — TLM 1で要求を書き応答を読むinterface／要求を読み応答を書くinterface／
要求側と応答側を別々の兄弟componentへ委譲するimpです。constructorの`req_imp`・`rsp_imp`引数で、
親とは独立に実装componentを指定します。

**通常のTLM 2 export／型parameter** — portと実装の間を中継する接続／
その接続が扱うtransactionとnonblocking phaseの型です。forwardとbackwardは個別に接続します。
汎用の型の伝搬とbase protocolの網羅は別の検査対象です。

**FIFO／blocking／nonblocking** — 到着順のキュー／データや空き容量を待てる操作／
その待機をせずに利用可否や成否を返す操作です。失敗した読み出しの出力引数は、規格が定める場合だけ検査します。

**analysis port／analysis FIFO** — 値をsubscriberへ配送するwriteの口／そのwriteを受けるFIFOです。
objectはハンドルのまま配送される場合があり、必ずcloneされるとは限りません。
subscriber同士の未規定の呼び出し順は仮定しません。

**FIFOの`put_ap`／`get_ap`** — 受け入れた書き込みのanalysis通知／成功したget・peekの通知です。
peekはキューのitemを残しながら通知する必要があります。利用可否の照会や転送の失敗は、通知対象の
transactionを供給しません。

**外部objectのcallback実行** — マクロの呼び出し元ではなく、引数で指定したobjectに登録された
callbackを実行する操作です。無効なentryを飛ばし、exit-onでは指定した真偽値が返ると途中終了します。
テストは不一致時の戻り値の方針を決めつけません。

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

**imp宣言マクロ／suffix** — interfaceに対応する別のTLM imp classを作るマクロ／
class名と実装method名へ付ける文字列です。通常のportは引き続き`put`・`get`などを呼び、
生成されたimpが実装objectの`put_left`などへ委譲します。

**実装の型／実装のhandle** — `IMP`・`REQ_IMP`・`RSP_IMP`などの型parameter／
実際のobjectを指定するconstructor引数です。生成したmaster impでも、要求と応答を別々の兄弟へ
委譲できます。親はimpを所有しますが、転送methodを実装する必要はありません。

**型付きanalysis入力** — class handleもtransaction型にできるanalysis接続です。
suffix付きwrite handlerへそのhandleを渡し、入力先の選択だけではtransactionを複製・変更しません。

**nonblocking transport／`nb_transport`** — 即時に要求・応答を完了できれば1、できなければ0を返す操作です。
呼び出し中の同期的なanalysis callbackが応答を供給できます。
0という結果だけでは、出力引数の特定の値や、要求側の途中の副作用がなかったことは示せません。

**失敗readのsentinel** — 取得不可のnonblocking TLM readへ渡す、既定値でない値／nonnull handleです。
記載された出力保持の契約を観測します。UVMの`output` formalとSystemVerilogのreturn時の代入には別途解釈の論点があり、
register／memoryの失敗readの値は推定しません。

**応答の識別** — 通常はrequestからcopyする、応答のsequence／transactionのrouting IDです。
実行中のsequence間でtransaction IDが同じでも別々に配送し、一致の重複が同順位内の順序を意味するとは限りません。

## レジスタモデル

registerモデルはソフトウェア状態とアクセス先の記憶域を分けて保持するため、model更新を物理転送と同一視する前に[このリポジトリが検査すること](reading-guide.ja.md#このリポジトリが検査すること)を参照してください。

**Register／field／block** — ひとまとまりでアクセスする値のモデル／同じpolicyで扱う連続bit／
register・map・子blockをまとめる容器です。registerのbyte幅は端数を切り上げ、fieldの列挙はbit位置の昇順です。

**Desired／mirrored／`needs_update`** — 要求するモデル値／モデルが現在記録している値／
書き込み可能な状態を更新する必要があるかの問い合わせです。`set`はpolicyに従ってdesiredを変え、
直接のpredictionは両方をそろえます。どちらもDUTの読み書きは行いません。

**Access policy／mapの権限** — RO・RW・W1Cなどのfieldの読み書き規則／
あるmapを通るregisterのアクセス制限です。両方からfieldの実効accessを決めます。
モデル内の`set`にもfieldのpolicyを適用します。

**Resetの種類／モデルのreset** — HARD・SOFTなどの名前付きイベント／
そのイベントのdesired／mirrored値を復元する操作です。設定のない種類はfieldを変えません。
blockのresetは子blockへ再帰しますが、物理的なハードウェアのresetは行いません。

**Address map／local offset／物理アドレス** — interfaceのアドレス空間のモデル／
その中のregisterの位置／rootのinterfaceから見えるアドレスです。単位はbyteかbus wordで、
返される配列はデータの下位側から並びます。submapはoffsetとbus幅を組み合わせます。

**Frontdoor／backdoor／predictor** — モデル化したbus経路のアクセス／designの記憶域への直接のアクセス／
観測したtransactionに基づくモデルの更新です。M3ではbusモデルのfrontdoorと観測packetによるpassive predictionを追加しました。ユーザー定義の記憶域backdoorも追加しました。RTL／HDL path／DPIとの接続は今後の作業です。
[レジスタモデルのFAQ](faq.ja.md#レジスタモデルの基本)を参照してください。

**Memory／location／location番号** — 連続した記憶域のモデル／その中の1 word／選択するwordの番号です。
`uvm_mem`は配置を保持し、全locationのmirror値は持ちません。local offsetと外部アドレスにはlocationの間隔を反映し、
現在はテストベンチdriverを通るfrontdoorのデータ転送も検査します。driverの記憶域は検査系の状態です。

**READ／WRITE prediction** — 渡された観測値とaccess policyの効果でモデルを更新する操作です。
RC／RSはreadの効果、W1C／W1S／W1TとW0C／W0Sは選んだbitへのwriteの効果を適用します。
観測値を渡すだけではbus転送は起きません。write-onceはHARD resetで次の初回書き込みを許します。

**Mapのreset／再配置／方向による検索** — 既定でSOFTのregisterモデルの復元／要素やsubmapのoffsetの変更／
同じアドレスのregisterを読み書きの方向で選ぶことです。modeの取得やアドレスの問い合わせはbusの動作を示しません。
[memoryとpredictionのFAQ](faq.ja.md#memorypredictionmapの制御)も参照してください。

**Register adapter／操作context** — genericなbus操作とprotocol固有itemの変換／
`reg2bus`内で読める`get_item`の参照です。`provides_responses`で別のdriver応答を選び、callback外のcontextはnullです。

**Predictor／reg_ap／pre_predict** — bus観測を受け取るcomponent／genericな操作の公開port／値や転送先を変えるhookです。
幅の広い操作はbus wordを集めてから公開し、memory観測は除外します。公開する観測値とpolicy適用後のmirrorは別です。

**Frontdoorのbusモデル／auto-prediction** — adapter・sequencer・テストベンチdriverを通るregisterやmemoryの読み書き／
有効にした場合にアクセス後のregisterのmirrorを自動更新することです。RTLのbus実装を示すものではありません。
[経路の説明](faq.ja.md#adapterpredictorfrontdoorの経路)も参照してください。

**Update／mirror／アクセスstatus** — 必要な場合にregisterのdesiredを書き込む操作／
readしてmirrorを更新し、必要なら比較する操作／アクセスの成否です。
updateはfieldのpolicyからbusのwriteデータを組み立てます。失敗したreadのデータには移植可能な期待値を置きません。

**Registerのアクセスhook** — 値やstatusの変更、bus要求前の中止を行える継承pre／post read／write methodです。
callback objectの登録とは別です。[アクセスhookのFAQ](faq.ja.md#memory転送とregisterのアクセスhook)も参照してください。

**Custom frontdoor／rw_info** — registerやmemoryに関連付けるユーザー定義のアクセスsequence／
その抽象的な操作記述子です。現在のcustomケースはsequence内の記憶域を使い、adapter／driverの接続とは別に検査します。

**登録型register callback／post_predict** — registerやfieldへ登録するcallback object／
READ／WRITE predictionの結果を変えられるhookです。要素の継承methodをoverrideすることとは別です。

**Virtual register／virtual field／増分** — memory上に重ねる論理的なfieldの集まり／そのbit範囲／
memory word単位の配列要素の間隔です。byte幅は実装先memoryのlocation幅の整数倍になります。
現在は静的な配置に加え、選択したfrontdoor転送と動的な実装・解放も検査します。
[配置例](faq.ja.md#custom-frontdoor登録callbackvirtual-register)も参照してください。

**Memory allocation manager／region／相対offset** — memory locationの排他的な予約を管理するもの／
予約範囲の記述子／範囲内のlocation番号です。byte要求はmemory location単位へ切り上げます。
virtual配列は`implement`／`release_region`で実装先の予約を管理し、regionの所有者の問い合わせは別の契約です。
[転送と実装状態のFAQ](faq.ja.md#virtual-registerの転送とmemory領域)も参照してください。

**Virtual配列の割り当て／指定policy** — `uvm_vreg::allocate`とmemory allocation managerで実装先の領域を選ぶ操作です。
現在のpolicy検査は有効な開始位置を1つに固定し、統計的な割り当て動作は確認しません。

**Virtualのwrite-hook順序** — pre-writeはfieldからvirtual register、post-writeはregisterからfieldです。
登録pre callbackはmethodの後、登録post callbackはmethodの前です。field単独のpostには固定版の差分を保持します。
[callbackのFAQ](faq.ja.md#virtual配列の割り当てcallbackユーザー定義backdoor)も参照してください。

**ユーザー定義backdoor／peek／poke** — `uvm_reg_backdoor`の実装／記憶域のsample／rawなdepositです。
現在のsubclassはHDL DPIなしのテストベンチ記憶域を使い、必須のpre／post helperを呼びます。
物理アクセスを模擬する`read`／`write`はregisterのaccess policyを適用します。

**付録Eの組み込みテストsequence** — `uvm_reg_hw_reset_seq`など、規格が定めるregister／memoryのテストです。
現在の検査系はテストベンチの記憶域でreset・bit bash・register access・memory walkを扱います。
[sequenceのFAQ](faq.ja.md#付録eの組み込みテストsequence)も参照してください。

**除外resource／REG名前空間** — `REG::`に置く`uvm_resource_db#(bit)`のentryで、
組み込みsequenceが名前の一致するblock・register・memoryを対象から外すために使います。
現在の検査系は完全一致のscopeと、独立して成功する比較対象を使います。

**故障の注入／成功する比較対象** — 正常だと確認した検査系へ意図的に変更を加えること／観測経路が働くことを確認する検査です。
付録Eのケースは正常実行の後にデータの故障を入れ、正確な診断文や内部パターンを要求せずに診断の増加を観測します。

**Memory access sequence** — `uvm_mem_single_access_seq`または`uvm_mem_access_seq`で、
frontdoorでのwriteとbackdoorでのreadを比較し、次に経路を逆にします。現在の検査系はテストベンチの4 locationを扱います。
[memory accessのFAQ](faq.ja.md#memory-accessshared-mapテストの選択)を参照してください。

**map間の可視性** — あるmapで書いた値を、同じregister／memoryの別のmapから読めることです。
検査系はmapの列挙順序や乱数payloadに依存せず、locationごとに書き込み元と読み手の組を記録します。
[shared mapのFAQ](faq.ja.md#memory-accessshared-mapテストの選択)を参照してください。

**組み込みテストの選択mask** — `uvm_reg_mem_built_in_seq`の64 bitの`tests` propertyです。
`uvm_reg_mem_tests_e`のflagで系統を選び、bitwise ORで17.2.2.10の順序に従って組み合わせます。
[dispatcherのFAQ](faq.ja.md#memory-accessshared-mapテストの選択)を参照してください。

**登録した独自access policy** — `uvm_reg_field::define_access`で登録した有効なfield policy名です。
組み込みテストsequenceには動作が未知の場合があり、skip検査では既知policyの別対象を動作する比較対象にします。

**物理beatの端数** — bus幅より少ない有効model bitを運ぶ物理アクセスです。16-bit busの24-bit memoryでは、
`n_bits`の幅16・8を期待します。20-bit modelには、sub-byteのlogical幅とbyteへ丸める幅の要レビューの解釈があります。
未使用data bitは制約しません。burst配列要素のpackingは別の条件です。

**部分predictionの分離** — 異なる広幅registerのbus wordを、別々に蓄積することです。
片方の完了で通知しても、別のregisterは自身の最後のwordが来るまで以前のmirrorを保ちます。

## 実行と結果

不正設計の検査ではcompiler拒否が期待する成功になるため、runtime失敗との違いは[結果の解釈](results.ja.md#結果の解釈)を参照してください。

**ランナー／メタデータ** — ビルド・実行・判定を行う`tools/run_*.py`／
テスト冒頭のコメントでその動作を指定する項目です。対応するoptionやライブラリのmodeも実行条件に含みます。

**fixture／helper** — テストの準備、刺激の入力、観測を担う検査系／その構築に使う補助コードやデータです。
検査系の記憶域をテストベンチ内でモデル化する場合もあり、名前だけでは物理DUTの使用を示しません。
宣言したhelperはテストの入力指紋に含まれ、[テスト形式の例](testing.ja.md#例)で指定方法を確認できます。

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

結果を再利用するときは、[記録の合算](results.ja.md#記録の合算)にある識別情報を照合すると、記録した入力と実行条件が現在も当てはまるかを確認できます。

**watchdog** — blockingのテストで完了を待つ時間に上限を設け、完了しなければ失敗として知らせる仕組みです。
正の遅延を入れることで、同じ時刻のプロセス順に頼らず待機状態を観測できます。

## 範囲とカバレッジ

条項の引用は参照先を示しても義務の検査を立証しないため、追加の要求と観測のlinkは[引用・要求・実行の証拠](requirements.ja.md#引用要求実行の証拠)で説明しています。

**M0〜M4** — [開発段階](../README.ja.md#進め方)です。基盤、基本UVM、TLM・sequence・callback、
レジスタ層、レビュー済みの要求台帳の順で進めます。次の段階を始めても、前の段階の完了を保証しません。

**条項の引用／要求カバレッジ／一致件数** — メタデータの参照／定義した要求と条件を検査する証拠／
特定の実行で期待値に一致したテスト数です。それぞれ分母が異なります。
このリポジトリでは要求カバレッジの分母をまだ承認しておらず、テスト総数やoracle件数はその割合ではありません。

**Check／Nightly** — このリポジトリの検証workflow／kirimasim-testsで使う別の定期実行・報告workflowです。
こちらには現在Checkだけがあります。バッジは、全シミュレータの一致率を示すものではありません。

**要求台帳／安定した要求ID** — 規範的な動作を、観測できる義務と条件に分解して版管理するもの／
テストのfilenameとは独立した名前です。[現在の台帳](requirements.ja.md)は部分的で全件がAIの案です。
その長さは承認済み分母ではありません。

**直接の対応／controlの対応／期待する観測** — 要求を直接検査するテストの明示的な対応／検査系や比較のcontrol／
期待出力内で指定する行です。controlは直接のカバレッジを与えず、期待値のanchorは実行の証拠ではありません。

**主引用／補助引用** — `:lrm:`の最初のUVM条項／後続のUVM条項です。
棚卸しでは別々に数え、要求の自動生成や子条項から親のカバレッジへの集約はしません。

**対象範囲の案／承認済み分母** — レビュー可能な候補集合と計数規則／分解と照合を終えて承認した固定の要求集合です。
後者は未設定で、保留した非推奨APIは承認済み除外ではありません。
[M4の承認までの手順](requirements.ja.md#m4の残作業と承認)を参照してください。

**レビューの未整理一覧／root別集計** — 要求の対応付けや分解が必要な項目の生成一覧／条項番号の最初の部分でまとめた棚卸しです。
要求は自身の条項、テストは主引用を使います。[backlogコマンド](requirements.ja.md#レビュー用の未整理項目とroot別集計)は、
controlのみの要求や文脈／保留の番号も残し、未評価の項目を確定した適合性の失敗にはしません。

**台帳入力の識別値** — 生成したinventory／backlogの`ledger_inputs_sha256`です。
検査した範囲、要求データ、番号の分類、テスト索引、catalogを、配置先に依存せず識別します。
JSONの書式を正規化し、配列順とcatalogのbyteは保持します。
[レポートの識別](requirements.ja.md#生成レポートの識別)を参照してください。
表示間で同じ値でも、カバレッジの承認や測定したシミュレータ実行の識別にはなりません。

## コンテナとmemory hookの観測

**コンテナのcursor（Container cursor）** — poolの端点／step methodへ参照で渡すkeyです。
空の端点や終端のstepが不成功なら、その値を保ちます。
走査テストは追加の順序規則を指定せず、所属と一意性を検査します。

**globalコンテナのsingleton（Global container singleton）** — 特殊化ごとのstaticなglobal accessorが返す、
共有するpool／queueです。local instanceは独立したままで、key／indexによるglobal取得は共有内容を観測します。

**待機するconsumerとobserver（Waiting consumers and observers）** — 待機するFIFO getは各到着を1回消費し、
待機するpeekは1つの先頭値を削除せず全員で観測できます。
並行動作の検査では、schedulerがどのconsumerを選ぶかは制約しません。

**memory hookの経路変更（Memory hook routing）** — memoryのアクセス前callbackは、転送前の操作descriptorを、
offset／mapも含めて変更できます。アクセス後のcallbackとmethodは、転送後に返すdata／statusを合成します。
method／callbackの各順序規則は`uvm_mem`について検査する必要があり、registerの動作だけでは示せません。

## 同期とtransportの履歴

**eventの持続（Event persistence）** — on状態はresetまで持続します。一方、persistent triggerの待機は、
現在のtime slice内だけでtriggerを認識し、on状態が残っていても、後のtime sliceでは新しいtriggerが必要です。

**barrierのthreshold（Barrier threshold）** — 同期点で必要な参加者の数です。
既定のauto-resetでは再利用時に新しい組が必要で、無効にすると、到達したbarrierをresetまで開いたままにします。
これらのテストでは解除順序を要求しません。

**nonblocking transportの履歴（Nonblocking transport history）** — テストベンチが駆動し、待機を隔てた
forward／backwardのphase呼出し列です。socketは指定phase、payload／delay handle、enum結果を転送し、
検査系が未完了の状態とscheduleを担当します。時間注釈とsimulation時刻の待機は別のものです。

**read後の予測（Post-read prediction）** — READ予測は指定のsample値を使い、access policyの副作用があれば
その後のdesired／mirrorへ記録します。予測したclear／setだけでは、物理readやその戻りdataの証拠にはなりません。

## 階層、binding、HDLの記述

**階層名のcursor（Hierarchy name cursor）** — componentの走査methodへ参照で渡す子の名前です。
空／終端の照会ではその値を保ち、globalなcomponent検索ではなく、選択した親の中の位置を表します。

**解決済みimplementation（Resolved implementation）** — 互換port／exportの接続をたどって到達する、最終的なTLM impです。
elaboration後のsizeはこれらの接続先を数え、index付きinterface handleは、provider順を要求せずそれらを識別します。

**HDL pathのkind（HDL path kind）** — RTLやGATEのような、symbolicなdesign-abstractionの選択子です。
elementの照会では親blockの既定を使えますが、明示kindと既定引数が同じabstractionを選ぶとは限りません。

**HDL pathの絶対root（Absolute HDL path root）** — 1 kindで祖先／incrementalのHDL pathを置換する、register blockのpath prefixです。
暗黙のUVM component rootとは別で、名前付きHDL objectの実在も示しません。

## callback dispatch、取消、modelの照会

**pre-triggerの拒否（Pre-trigger veto）** — 1回のevent triggerとそのpost-trigger hookを抑止する、非0のcallbackの戻りです。
callbackの削除や待機processの取消は行いません。

**waiterの取消（Waiter cancellation）** — processがdisableされたり別の方法で起動したりした後、event／barrierの件数から
待機participantを明示的に除くことです。processのkillとcancelの呼出しは別の操作です。

**重なるblocking呼出し（Overlapping blocking calls）** — 実行区間が重なる2つのtask呼出しです。
各呼出し側は自身のcalleeを待ち、別々のpayload／delay objectで、共有objectのraceなしにroutingと完了を検査できます。

**modelの照会（Model introspection）** — 設定済みregister modelの親handle、包含object、名前の照会です。
modelの階層を記述し、それ自体ではaddress-map転送の実行やHDL storageへのアクセスを行いません。

## 記録のlifecycleとfield metadata

**記録stream（Recording stream）** — databaseが所有する、transaction recorderのcontainerです。
local hookでmemory内streamを用意し、外部databaseや記録したtransaction内容なしでlifecycleを検査できます。

**stream handle（Stream handle）** — staticなlookupでstreamへ解決する整数識別子です。
close後も有効で、free後に無効になります。正確な数値や将来のID再利用は検査系の範囲外です。

**reset metadata（Reset metadata）** — kindで索引するfieldのreset値です。
このmetadataの代入／削除は、liveなdesired／mirror状態のresetや物理reset信号のassertとは別です。

**fieldのcompare制御（Field compare control）** — set_compareで選び、get_compareで返すmodelの設定です。
設定の観測だけでは、mirror readによる比較の実行／抑止は成立しません。

## recorderと間接access

**recorder（Recorder）** — streamが所有するrecordであり、そのfieldを記録するpolicyでもあります。
localなimplementation hookで、外部databaseの形式を生成せず、lifecycleとscalar引数を保持できます。

**socketの宣言上の接続数（Socket declaration bounds）** — socketのconstructorが指定する最小／最大の接続数です。
解決済み接続先の数とは別であり、transportが実行されたことを示しません。

**index／data register pair（Index/data register pair）** — array要素を選ぶaddress registerと、
その要素にアクセスするdata registerです。検査系では、data portへアクセスする前に明示したindex writeを完了します。

**選択したarrayのprediction（Selected-array prediction）** — model化した転送の観測後、間接indexが選んだarray registerのmirrorを更新することです。
他のarray mirrorは以前の値を保持し、testbenchのstorageは別の状態として残します。

## phaseの同一性とcoverage sampling

**phase implementationとnode** — IMPは再利用可能なphase動作を提供し、schedule nodeは個別graph context／stateを持ちます。
異なるnodeが動作を供給する同じsingleton handleを共有しても、node handleは別です。この共有だけで全並行state／lifetime条件は証明しません。

**coverage modelの搭載状況** — register、memory、blockの抽象modelが宣言した計測modelです。
搭載していることは、現在収集が有効であることや、何らかのbinをsampleしたことを示しません。

**coverage有効mask** — 現在計測を有効にしている搭載済みmodelです。このmaskの変更と搭載状況の照会は別で、
規格はset_coverageが直前の有効maskを返すことを定めます。

**sampling hook** — accessまたは現在のmodel値を計測のために観測する、userがoverrideできるmethodです。
hookの呼出し回数を数えることで、covergroupを作ったりcoverage比率を出したりせずに、dispatchとtimingを検査できます。

## component stream、report context、readの比較

**componentの記録** — componentが選択したdatabaseとstream経由の記録です。
transaction自身の記録経路とは別の有効化制御を持ち、componentのendでtransaction属性のhookを呼べます。

**stream cacheのkey** — 1 component内で要求したstreamの名前／型pairです。
参照を解放するかstreamをfreeするまで、同じ要求は同一性を保持し、別componentは異なるscopeを持ちます。

**sequenceのreport context** — 空ならsequence-parentのpathで埋めるmessageのcontext文字列です。
handlerとverbosity設定を用意するsequencerまたはrootのreport objectとは別です。

**check-on-read** — sampleしたregister／field dataを既存mirrorと比較して、不一致を報告するmap設定です。
比較制御と自動予測は別の設定であり、検査系は予測を明示的に有効化し、fieldごとの比較maskを適用します。

## core service、wrapper index、bus操作の順序

**core service** — 中央のUVM serviceと既定policyへの共有access pointです。
service handleの選択自体は、そのserviceの動作や独自初期化手順を示しません。

**実装既定policy** — 明示した既定値がない場合やnull reset後に返すpolicy instanceです。
具体的な型と同一性は実装が選び、呼出しごとに渡すpolicy引数とは別です。

**sequence wrapperのindex** — 1 library内で登録sequence型のwrapperへ解決する位置です。
wrapperのlookupはsequenceを実行せず、共通の登録順を要求しません。

**registerのtransaction-order policy** — 1つの論理register read／writeについて、
完全な物理bus操作structを並べ替えるhookです。実行順が変わっても、address／dataの対応と論理readの再合成を保持する必要があります。

## 走査とaccess wrapper

**visitor** — 走査adapterが選ぶnodeのcallbackを受けるobjectです。
無効化しなければ、begin／end callbackが走査の前後を囲みます。

**structure proxy** — nodeの直下の構成要素を列挙する、adapter向けobjectです。
異なる構造型へ共通の走査方式を適用できます。

**走査の部分順** — 親が子より前、または子が親より前などの必要な関係です。
無関係な兄弟間の順序は制約しません。

**register-sequenceの便利method** — 呼出しsequenceをparentとして指定し、
その他の明示access引数を引き渡すregister／memory accessのwrapperです。

## 照合と記述子の状態

**簡易照合表記** — starが0文字以上、plusが1文字以上、questionがちょうど1文字を表す文字列全体の照合です。
検査した他の非meta文字はliteralの意味を保持します。

**enum名の変換** — 大文字小文字を区別する正確なenumerator名をenum値へ変換する処理です。
失敗の通知と出力値は別に扱います。

**response queueのclear** — 1 sequenceの保留replyを除く操作です。
新しいreplyは到着でき、他のsequenceのqueueはclearしません。

**register操作記述子** — element、access、data、map、status、生成元metadataを保持する抽象transaction objectです。
そのobjectの読取り／更新だけでは、物理register accessは行いません。

## 検索範囲とstate mask

**rootのcomponent検索** — componentのfull nameをpatternと比較し、一致handleを返す公開root lookupです。

**検索開始component** — scope付き検索が下へ辿る開始点で、一致する場合は自身も含みます。
patternは引き続きfull nameを使います。

**sequence-state mask** — 許容するsequence状態のbit結合で、呼出し対象が選択状態のいずれかになると待機がreturnします。

**memoryの便利accessor** — 選択memory locationへaccessし、自身のsequenceをparentとして指定する、
register-sequenceのpoke／peek wrapperです。

## HDLの実行条件

**VPI（Verification Procedural Interface）** — HDL objectの検索や、対応する値の観測／変更に使う、
simulatorの公開APIです。実際のhandle lookupは、path文字列をlocal storageへ対応付ける検査系とは異なります。

**HDL backendの実測条件** — 測定に用いたrunner、linkしたDPI／backend、HDLの可視性、対応する型の組合せです。
独自の限定backendでの結果は、別のbackendの動作を示しません。

## 表現の選択と解釈

**Abstraction list** — path検査で選ぶHDL表現名です。空でなければそのentry、空ならblock既定を使います。

**歴史的なalgorithm解釈** — 詳細が不足するalgorithmを、以前の公式資料を使って読む、記録した解釈です。
レビュー可能な文脈で、新たな規範的改訂や、現在の適合性を自動的に示す証明ではありません。

## 番号の分類とconfiguration条件

**Identifier assessment（番号の分類）** — catalogの1番号を構造または文脈として明示的に分類し、レビューと日英の根拠を持つ記録。
観測可能な要求とは別であり、成功した実行結果を与えない。

**Strict configuration condition（strict configuration条件）** — 自動configurationでresourceの選択方法を変える固定libraryのbuild設定。
既定modeの結果と測定を区別し、同じ規範的oracleを保持する。

## Registry proxy・履歴・model lock

**Registry singleton（registryのsingleton）** — 1 registry specializationのgetが返す共有wrapper。
対象のinstanceを生成せず、その型を表す。

**Sequencer history capacity（sequencer履歴容量）** — 保持するrequest／response履歴の設定上限。
転送の配送や、存続中の転送累計とは独立している。

**Model lock state（modelのlock状態）** — register modelの構造上のlock状態。
lock_modelによるaddress検索の構築と、set_lockによるflag変更は異なり、sequencerの所有権やhardware bus lockではない。

## Abstract proxy・IDコピー・map解除

**Abstract registry（abstract registry）** — instanceを生成せずに登録できる、virtual object／component型のproxy。
生成には具象factory overrideが必要となる。

**ID information copy（ID情報のコピー）** — set_id_infoでresponse routingのsequence／transaction IDをコピーすること。
payloadや名前のコピーとは独立している。

**Block map unregister（block mapの解除）** — 選択mapとその内容のmodelを、blockが持つ情報から除くこと。
bus accessの実行や、解除後のdefault map選択とは範囲が異なる。

## Recording callbackと実行階層

**Recording callback（recording callback）** — backendの処理を担当する、overrideしたdatabase／stream／recorder method。
stream／recorderのnull結果は初期化を抑制する。

**Optional body hooks（optional body hook）** — call_pre_postで選ぶsequenceのpre_body／post_body呼出し。
start hookとparent callbackには、それぞれ別の契約がある。

**Block hierarchy / map hierarchy（block階層／map階層）** — register-model blockの親子関係と、address-map submapの接続。
論理的なblock名照会のために、child blockのmapをlocal mapのsubmapへ接続する必要はない。

## Constructor引数とregister fileのpath

**Omitted name / explicitly empty name（名前省略／明示的な空の名前）** — 基底constructorで名前引数を省略すると基底の既定値を使う。
空文字を渡す場合は明示引数である。具体的な転送用拡張で、この2条件を区別する。

**Register-file HDL contribution（register fileのHDL寄与）** — 論理register fileが与えるlocal pathの成分。
flattenされたfileはscope名を加えず、親／localの代替成分から複数の完全なsymbolic pathが得られる。

**Enclosing abstraction default（包含abstractionの既定値）** — register fileのlocal path／存在APIが選ぶ、最も近い包含register file／blockの既定値。
現在file自体で明示した既定値の照会とは異なる。
[Q147](faq.ja.md#q147-register-fileの照会はどのhdl-abstractionの既定値を使いますか)を参照。

## Heartbeat・virtual accessor・FIFOモデル

**Heartbeat window（heartbeatのwindow）** — trigger eventで区切り、監視componentが同期objectionを通じて参加する区間。
新しい正常windowの検査系はALL_ACTIVEを明示選択し、広いmode／失敗条件は別に残す。

**Virtual accessor dispatch（virtual accessorのdispatch）** — 基底型のpayload handleからvirtual accessorの派生overrideを呼ぶこと。
counterと転送値で選択した公開呼出しを観測し、transport／pack動作とは分ける。

**Abstract register FIFO（register FIFOの抽象表現）** — register-layer FIFO modelの公開queueと容量。
対象getは先頭をpopせず観測し、queueの直接変更は検査系の刺激とする。
inlineとsubtypeの制約条件は[Q151](faq.ja.md#q151-fifoのinline制約とsubtype宣言制約をなぜ分けて記録しますか)で分けて示す。

## Catcherの発行と印字／返却対象object

**Catcher helper emission（catcherの補助発行）** — catching callbackを迂回してcatcher内で生成する補助報告です。
issueで現在のmessageを発行することとは別です。[Q152](faq.ja.md#q152-catcherのhelper報告とissue後のthrowはどう違いますか)を参照してください。

**Typed sequence print visit（型付きsequenceの印字訪問）** — 深さ無制限のdeep再帰で現在のrequestまたはresponse itemのprint hookを観測します。
printerの書式を固定せず、到達したobjectを識別します。

**Separate response identity（別responseの同一性）** — requestのrouting IDを引き継ぎ、driverが返す新規objectそのものです。
矛盾するrequest状態により、別responseを選択しているのにrequest内の経路を使う場合を検出しやすくします。

## 現在の報告状態と選択する所有／byte

**Catcher mutation scope（catcher変更の範囲）** — 現在のmessageを変更し、後続catcherから観測できる範囲です。
新しい報告は自身のattributeを持ちます。発行前にcatchすることで、callback状態とserver出力の検査を分けます。

**Sequence release target（sequenceの解放対象）** — unlock／ungrabで明示したsequencer、または省略時の設定済み既定sequencerです。
1対象の解放は、別のsequencerで保持する所有を解放しません。

**Live neighbor / mirrored neighbor（実際の隣接値／mirrorの隣接値）** — 隣接fieldのbus model上の値とmodel mirrorの値です。
個別byteのwriteは実際の隣接値を保持し、全registerへのfallback writeは最善の試みとしてmirrorの隣接値を使います。
[Q157](faq.ja.md#q157-byte-enableでのfieldアクセスは隣接fieldを保持しますか)を参照してください。

## 共有messageと制御したfatal観測

**Preformed report message（事前構成した報告message）** — 呼出し側が作り、report objectへ直接処理を依頼するmessageです。
現在のreport-object参照の設定と、callbackが同じobjectへアクセスすることは、別の観測対象です。

**Controlled fatal sentinel（制御したfatal sentinel）** — 必須の元のfatal severityを観測してから、検査系自身が行う終了です。
宣言したnonzero終了と自身の診断で、fatal後の継続を要求せず検査系の終了を明示します。

**Field width / physical bus width（field幅／物理bus幅）** — 論理fieldの大きさと各物理転送のdata幅です。
配置、byte共有、endian順のすべてが関係し、個別アクセス可否だけでは正しい転送dataを示しません。

## 公開の委譲と繰り返す適格性

**Handler processing argument（handler処理引数）** — 設定したreport handlerの公開処理methodへ渡すmessageです。
その引数の記録で委譲を調べ、catcher内部やserverの出力書式へ依存しません。

**Relevance wake-up（relevance待ちの復帰）** — sequenceの実行可能性待ちから戻り、sequencerが再arbitrationできることです。
複数の待機要求と再開後のgateは、poll回数を固定せず別々のlifecycle条件を検査します。

**Payload byte length / valid-bit extent（payload byte長／有効bit範囲）** — byte配列の転送長と、generic bus operationが運ぶabstract-value bit数です。
最後の部分byteには明示的な解釈が必要で、今回は逆対応を固定しません。
[Q163](faq.ja.md#q163-payloadのbyte長からpartial-byteの有効bit数を一意に復元しますか)を参照してください。

## 現在の型と報告の対応先

**Static proxy / dynamic type proxy（static proxy／動的型proxy）** — 登録class自身のwrapperと、objectのvirtual型照会が返すwrapperです。
factory overrideは生成する動的型を変えても、baseのstatic proxyを変えません。

**Sequence-report admission（sequence報告の処理可否）** — enabled確認に続き、sequence interfaceが報告を処理する判断です。
保持するclass固有の解釈は、report objectでのnon-INFOのverbosity動作と分けます。
[Q166](faq.ja.md#q166-sequence報告のadmissionがreport-objectの動作と異なるのはなぜですか)を参照してください。

**Nonuniform conversion roundtrip（非一様な往復変換）** — 異なるbyte値や有効laneを持つoperationをpayloadへ変換し、戻した有効fieldを比較することです。
両変換の整合性を検査し、片方向のbyte順を独立には評価しません。

**Hierarchical file association（階層的なfile対応付け）** — あるcomponent subtreeへ再帰的にreport file設定を適用することです。
公開の実効handle照会で、数値descriptorを固定せずscopeと優先順位を検査できます。
[Q167](faq.ja.md#q167-再帰的なreport-file設定を固定file番号なしでどう検査しますか)を参照してください。

## 宣言のevidenceと残る条件

**Declaration evidence（宣言のevidence）** — 公開型、名前付き選択肢、signatureの存在や選択した範囲の観測です。
その宣言を使う全操作は認定しません。[Q168](faq.ja.md#q168-logic-typedefの幅とunknown-status-symbolは4-state動作を証明しますか)を参照してください。

**Valid slice description（有効なslice記述）** — most-to-least順で重複せず、隙間を許すHDL metadata、または両数値fieldが-1のregister全体の単一sliceです。
有効記述を渡しても、不正記述の拒否は検査できません。

**Zero unassessed identifiers（未評価番号0）** — 全catalog番号に部分的な要求案または根拠のある明示分類がある状態です。
棚卸しの状態であり、全義務や継続するM1〜M4 goalの完了ではありません。
[Q170](faq.ja.md#q170-第17章の未評価0件で継続goalは完了しますか)を参照してください。

## Command-line実行条件

**Process argument bridge（process引数bridge）** — 標準VPIで実際の起動引数を読み、固定UVMのcommand-line DPI interfaceへ渡す独自の接続codeです。
UVM parserの実装や期待値の導出は行いません。

**Condition-specific oracle marker（条件別oracle marker）** — 明示したrunner条件で再現済み検査系を選ぶmetadataです。
command-lineは`:uvm_cmdline_oracle: verilator@5.052`を使い、通常runnerのpassを示すtagにはしません。

**Locked quit-limit diagnostic（lockしたquit上限の診断）** — command-lineで変更不可にしたquit上限をuser codeが変えようとした際に必要な警告です。
正しい拒否と診断severityは別の観測です。[Q172](faq.ja.md#q172-lockしたquit上限が正しいのになぜテストは差分になりますか)を参照してください。

## Sequence fieldとlifecycleの観測

**Standard protected-member probe（標準protected memberのprobe）** — 明示的に標準化されたprotected fieldを独自subtypeで観測することです。
そのfieldの契約を検査し、欠落した公開accessorは検査しません。
[Q174](faq.ja.md#q174-protected実行counterの観測は欠落したgetterを置き換えますか)を参照してください。

**Cyclic-field observation（巡回fieldの観測）** — 標準の巡回indexを直接randomizeし、有限の合法domainのcycleを検査することです。
libraryがmodeで制御する実行時に、そのfieldで子を選ぶことは証明しません。

**Relevance-wait cancellation（relevance待ちの中止）** — 待機要求が実行不可の間にsequenceを終了することです。
停止状態、startの戻り、生存側の保持、その後の実trafficは別々の観測で、全終了hookの完全な証明ではありません。

## User-backdoorとpredictorの観測

**Default-read delegation（既定readの委譲）** — 継承したbackdoor read taskがpre／post処理を保持し、peek段階でuser functionを呼ぶことです。
この経路の観測は、task-based read overrideの境界配置を検査しません。

**Backdoor hook trace（backdoor hookのtrace）** — user hook、登録callback、記憶操作を独自testbenchで観測し、
descriptorの同一性と選択した値／status伝播も含めることです。非公開library queueの説明やencode／decode配列動作の認定ではありません。

**Pre-run predictor configuration（run前のpredictor設定）** — run phase前にmapとadapterの選択を完了し、
実際のmirror更新とanalysis公開を通して効果を検査することです。run中の設定変更が対応済みであるとは約束しません。

## Pipelineとtranslationのevidence

**Callback value pipeline（callback値pipeline）** — 登録した変換の結果配列を、次のcallbackと最終operation経路へ渡すことです。
呼出し順序と値の伝播は異なる観測で、traceだけでは両方を証明できません。

**Layered register translation（階層化register変換）** — upstream register sequencerが、bus sequencer上で実行するtranslation sequenceへ抽象itemを渡すことです。
設定adapterと実際のdriver handshakeで、選択した各操作を運びます。

**Parameter-only HDL check（parameterだけのHDL検査）** — HDL support routineを呼ばず、公開のsize parameterとmacroから導く値を調べることです。
force／release、物理記憶域、backend ABIのevidenceは示しません。

## 同期の観測

**Established waiter（確立したwaiter）** — 正の時間進行と公開waiter countを使い、解放stimulus前に確認した待機です。
予想外のwakeupを調べる場合、呼出しを遅延しただけではより弱いevidenceです。

**Waiter accounting（waiter計数）** — 内部countのresetから進行を推論せず、現在待機するprocessを報告することです。
eventとbarrierのreset契約は異なり、件数と実際の解放を別々に観測します。

**Initial pool membership（pool初期所属）** — getterがlazy生成する前から、生成直後に存在するkeyです。
新keyの増分やconstructorの名前では、必要な既定項目やglobal-access signatureは証明できません。

## Objectionと型付きcallbackのevidence

**Propagation-mode observation（伝播modeの観測）** — callback経路、source／descendant照会値、合法な状態遷移を別々に検査することです。
hookを省略するだけで、異なるtotal照会の定義は認定しません。

**Objection hook context（objection hookのcontext）** — componentまたは登録callback hookへ渡す、選択したobjection、target／source object、description、countです。
未規定のcallback body相対順を固定せず、metadata同一性と遅延完了を観測します。

**Optional callback parameter（省略可能なcallback parameter）** — 有効な登録object／callback組で、callback add／deleteのCBだけを省略することです。
正確な型検査と型付き委譲で、mode省略値や不正組の診断は解決しません。

## TLM宣言と照会のevidence

**Independent response default（独立した応答既定値）** — 要求型を変えても固定される、宣言された応答型の既定値です。
全int specializationでは一致しても、REQに従う応答parameterの既定値とは異なります。

**Capacity versus occupancy（容量と使用数）** — FIFOの設定した最大数と、現在保存しているentry件数です。
容量0は上限なしを表し、使用数の測定や空の無制限is_full文言の解決ではありません。

**Interface-view forwarding（interface view経由の転送）** — 公開virtual interface基底を通して実際の標準port／exportを呼ぶことです。
選択型／委譲と転送経路を検査し、独自backend algorithmをlibrary oracleにはしません。

## 宣言の既定値とcompiler検査

以下の用語は宣言されたAPIの形とruntime動作を区別するもので、不正入力と合法controlの判定方法は[compiler検査のFAQ](faq.ja.md#compiler拒否と合法control)で説明しています。

**既定型引数（Default type argument）**：parameterized classで型引数を省略したときに選ぶ宣言型です。
channelのREQ依存RSP既定値から、通常port宣言の独立integer既定値は決まりません。

**継承rand member（Inherited rand member）**：派生classが継承するrandomized memberです。
選択payload制約は公開accessorで観測する全値を固定しますが、物理bus targetを実装しません。

**分類の再評価（Classification reassessment）**：以前に分類した条項を再読し、独立した規範的義務が見つかれば分類を置き換えることです。
元の識別子は範囲に残り、直接要求を追加します。

**印刷provider一覧（Printed provider list）**：socket connect条項が明示列挙するprovider class名です。
blocking／nonblockingの名前が矛盾する場合、別の実動経路が動いても限定解釈として残ります。

**直接provider entry（Direct provider entry）**：portの直接照会で見えるrawな接続です。
不正呼出し後の残存entryは解決済み実行bindingと異なり、合法な実行時経路を証明しません。

**独自phase型（Custom phase type）**：parameterized nonblocking interfaceで明示選択するphase型です。
正の正確なviewと選択双方向転送から、phase parameter省略の印刷connect signatureは確定しません。

**compile診断anchor（Compile diagnostic anchor）**：不正elaboration要求のlinkへ付ける正確な宣言error regexとcompile stageです。
期待oracleへの対応であり、一致するcompiler evidenceは別に測定します。

**期待compile拒否（Expected compile rejection）**：必要な対象errorでcompileが失敗する、成功したnegative検査です。
runtime binaryやseedは実行せず、予期しないlibrary／API／link build失敗とは異なります。

**検査種別の件数（Test-kind census）**：simulation／elaborationを分けた検査系の件数です。
全検査系、runtimeの両seed一致、期待compiler拒否は異なる量で、coverage率を証明しません。

**pure interface充足（Pure-interface fulfillment）**：具象subtypeが全ての継承pure virtual methodについて、その場で定義するか具象親から継承した実装を持つことです。
選択した未完成classはnegative compile fixtureにします。

**不正compile受理（Illegal compile acceptance）**：規格から導いたoracleが拒否を要求するfixtureのcompileが成功することです。
negative検査の不一致であり、runnerは生成binaryやruntime seedを実行しません。

## reportingとpolicyの状態

**report pipeline trace（Report pipeline trace）**：独自catcherとserver overrideでcatching、composition、executionの順序を観測することです。
既定formatter algorithmを規定せず、framework dispatchを確認します。

**有効file経路（Effective file route）**：severity／ID pair、ID、severity、defaultのfile対応から選択された実logging出力先です。
同一性照会と実payload書込みは、その選択を別の観測で確認します。

**printer値observer（Printer value observer）**：非公開field名や組込みlayoutを固定せず、print hookから渡る選択値を調べる独自policyです。

**print再帰state（Print recursion state）**：objectと再帰選択について公開するNEVER／STARTED／FINISHED履歴です。
hook段階の観測ではactive-object stack所属と区別します。

**printer depth境界（Printer depth boundary）**：設定maximum depthによりobject印字をreference動作へ変える境界です。
entry-depth等号の読み方を、既にmaximumを超えるscopeと分けて保持します。

**flush後のprinter形式既定値（Printer format defaults after flush）**：table／tree indentとtree／line separatorでflush後に明示された既定値です。
他のbase printer controlを選択して観測した結果と区別します。

**policy hook段階（Policy hook stage）**：標準policy操作順序におけるfield、user、完了の手順です。
active objectをpopする前に履歴がFINISHEDになる場合があります。

**独立したerror後control（Independent post-error control）**：不正要求を検査した後、不正policyの状態に依存せず使う別生成の有効policyです。

## regionとsequenceとcomponentの境界

**region location単位（Region location unit）**：region offsetと長さが数えるaddress単位です。
設定したlocation当たりbyte数によりbyte要求を全locationへ変換します。

**region委譲observer（Region delegation observer）**：regionが変換したAPI入力を観測し、応答data／statusを供給する独自memory subtypeです。
物理storageやbus／HDL転送動作は立証しません。

**sequencer interface view（Sequencer interface view）**：解決済みpull connectorを通じて実sequencer実装から取得する、公開された型付sequence-driver interfaceです。

**rerandomization Boolean観測（Rerandomization Boolean observation）**：retryやcallbackの回数を固定せず、requestが1回以上randomizeされたかを確認する述語です。

**Component domain（component domain）**: componentへ割り当てた公開phase-domain handle。
階層割当では子孫へ伝播でき、schedule定義と実際の非同期実行は別条件です。

**Child print gate（child印刷gate）**: componentのprint_enabled bitはchildとしての自動印刷を制御します。
明示printer policyでrootとして直接印刷する呼出を禁止しません。

**User protocol dispatch（user protocolへのdispatch）**: component base viewからuserが提供するvirtual suspend／resume実装を呼びます。
自身の状態はdispatchのobserverで、共通library process制御algorithmではありません。

**Terminal error observer（errorで終了するobserver）**: 要求された一般errorを観測した後、自身のsimulationを終了する独自report catcher。
不正呼出の回復、return動作、error後のobject状態を規定せずに済みます。

## componentの寿命と便宜hook

**Phase-task descendant（phase taskの子孫）**: component phase taskがforkするprocess。
選択寿命probeは非公開process handleや正確なtick数によらず、phase後のwriteが止まるかを観測します。

**Callback-spawned thread（callbackがspawnするthread）**: phaseのstart／ready-to-end／end callbackが作るprocess。
要求される継続性はphase taskの寿命と異なります。

**Hook signature conflict（hook signatureの食違い）**: function／taskのように、印刷API宣言と利用可能な呼出形式が異なること。
限定した宣言probeはruntime hook-dispatch観測と別にbuild evidenceを保持します。

**Severity verbosity exception（severityによるverbosity例外）**: 明示報告規則では実warning／error／fatal報告はverbosityを無視します。
severity-ID設定照会は閾値を返せても、その照会は実report経路ではありません。

**Empty convenience name（便宜APIの空名）**: 便宜生成APIの空の既定名。
選択した独自constructorも空を既定とし、そのfixtureは全application constructorのfallbackを空に制約しません。

## recording callbackとregisterへの転送

**Selected recording backend（選択recording backend）**: 公開recording callbackを観測する独自database／stream／recorder実装。
そのtimestamp解釈はapplication固有token／string encodingを標準化しません。

**Zero-length error record（長さ0のerror記録）**: keep_activeを省略／0にしたとき、選択開始／終了時刻が同じerror transaction。
backend観測は普遍的な返却handle解釈と区別します。

**Bidirectional declaration probe（双方向宣言probe）**: 呼び出すgeneric functionがaliasと宣言された正確なspecialization間の双方向暗黙class代入を要求します。
null完了markerはcallback runtime動作を証明しません。

**Forbidden registry identifier（禁止registry識別子）**: 規格宣言がregistry typedefを禁止するclassに対するtype_id参照。
対象compiler拒否を、合法constructor／iterator実行と別に測定します。

**Printed alias conflict（印刷aliasの食違い）**: 条項の見出しと印刷typedefでalias名が異なること。
動作する名前へ黙って置換せず、字義的な綴りと限定期待を保持します。

**Named model access（名前によるモデルアクセス）**: block単位の便宜callが単純名でregister／memoryを見つけ、選択read／write操作へ委譲すること。

**Forwarding observer（転送observer）**: 独自target subtypeが公開引数を記録して選択応答を供給します。
wrapper algorithmを置換せず境界を検査し、targetの物理transportを認定しません。

**Block update write census（block updateのwrite棚卸し）**: 選択した全幅RW階層でaddressごとにwriteを数えること。
兄弟走査順を課さず変更registerの最小writeを確認し、全field policyが同じ件数になるとは仮定しません。

**Mirror check mode（mirrorのcheck mode）**: NO_CHECKは古い値との不一致を報告せず選択register mirrorを更新し、明示CHECKは不一致報告を加えます。
成功bus read／更新は比較結果と別です。

**Milestone grouping（milestone分類）**: 機能対象のmilestoneでテストを数え、主引用条項で章directoryを決めます。
D.3の名前モデルアクセスはfileをuDに置いてもM3へ属します。

## blockとregisterの照会の境界

照会は転送を行わずにモデルの設定を調べる場合があり、アクセスやcoverageの主張に追加で必要な観測は[照会のFAQ](faq.ja.md#blockとregisterの照会の境界)で説明しています。

**Available coverage mask（利用可能coverage mask）**: 選択抽象classが保持するmodelで、現在測定が有効なmodelとは区別します。

**Coverage inclusion intersection（coverage includeの共通部分）**: 選択build_coverage結果には、要求され、一致する階層instance scopeへincludeされたmodelが入ります。

**Inherited backdoor query（継承backdoor照会）**: local user-backdoor定義のないblockがparentを参照すること。より近い明示block／register定義が優先されます。

**Flattened block path（flattened blockのpath）**: 中間blockは寄与するHDL segmentを持たず、子孫は周囲の設定済みpath成分を結合します。

**Map membership boundary（mapの所属境界）**: 内容は選択した物理interface mapに属し、同じblockの別mapはそのmapのsubtreeへ自動的には入りません。

**System bus association（system busの関連）**: 階層map照会は最上位busのsequencer／adapterを選び、明示local照会はmap自身の関連を観測します。

**Unmapped logical frontdoor（unmapped論理frontdoor）**: memoryが物理map addressを占有せず、独自access sequenceが論理memory locationを処理すること。

**Qualified address-unit relation（限定したaddress単位の関係）**: 字面の読み方でword単位を既定の階層get_n_bytes結果へ結び付けます。local幅の解釈と観測した有効幅差分は別の照合課題として残します。

**Captured maximum baseline（捕捉した最大値の基準）**: 他モデルが存在しないと仮定せず、選択register追加前の全体最大値を記録すること。

**Reset-kind definition（reset種別の定義）**: model metadataが選択reset原因ごとに値／存在を持つこと。その変更とmodel値へのreset適用を区別します。

**Clone source control（cloneのsource control）**: clone要求後に元mapのrights／関連を観測し、新instanceの未観測内容は主張しないこと。

**Gated busy observation（gate制御busy観測）**: request到着後に独自driver応答を保持し、別threadが実処理待ちregister操作のis_busyを観測すること。

## 式の型とregistry宣言

**Declared expression type / receiver conversion** — `$typename`が照会する型と、式を引数へ渡すときに生じ得る変換です。
型付きreceiverでの受理だけでは、式の元の宣言型を証明できません。

**Phase synchronization / sync / unsync** — domain間で選択phase nodeの開始と終了を揃える関係です。
`sync`が追加し`unsync`が解除します。1関係の解除は他の関係を保持し、兄弟の訪問順は規定しません。

**type_id / registry specialization** — 表現するclassと名前／parameterに応じた、宣言されたfactory proxy型です。
継承type_id memberが見つかっても、それが基底classを表現する場合は不十分で、必要なregistryがclass固有の特殊化と互換である必要があります。
明示例外とpackageの全型には別の照合が必要です。

## memory位置とcallbackの配送

**Memory HDL location / slice** — location indexは物理arrayの1 wordを選び、sliceのoffset／sizeはそのword内のbitを選びます。
path文字列の一致だけでは、物理選択やdata合成を証明しません。

**Public declaration / inherited implementation** — 印字された公開methodへcompile時にaccessできることと、合法な派生wrapper経由で基底実装へ到達することは別です。
それぞれに固有のevidenceと残る制限があります。

**Callback membership / delivery** — add／deleteの成功返却値と実通知先は別の観測です。後のentryの削除はactive peerを保持し、選択した削除handleを抑制する必要があります。

**Saved signed shift** — 比較がunsigned operand contextをshiftへ伝える前に、算術shift出力をsigned型へ保存することです。

## resourceとsequenceの順序

queueの順序、要求の解放、transactionの完了は別の確認点で、1つの観測が他の成立を示さない理由は[sequenceのFAQ](faq.ja.md#sequenceの実行可否とtransaction完了)で説明しています。

**Resource priority / precedence** — priorityは選択name／type queue内でresourceを移動し、数値precedenceは明示type-lookup例外の下で最大name matchを決めます。
2つの制御には独立したevidenceが必要です。

**Resource modification notification** — 変更writeは待機waiterを解放します。選択resource契約の下では、同値writeとread-only拒否writeは変更を通知しません。

**Zero-time relevance bound（時間を進めない関連性待機の上限）** — 時間が進まないwait_for_relevant反復callbackの設定可能な最大値です。
callback回数と実simulation時刻をprivate counter実装と分けて観測します。

**Pipelined transaction completion（pipeline transactionの完了）** — sequence-item ackより後のモデル化した完了markです。
sequenceはfinish_itemの復帰後、item-pool end eventを待つことができます。

**Builtin-sequence target slot（組み込みsequenceの対象slot）** — 定義済みregister／memory test sequenceの対象を選ぶmodel／register／memory handleです。
storage同一性の検査と実際の対象実行には異なる観測が必要です。

**Live child-sequence slot（実行中child-sequence slot）** — 選択処理を実行中のchildへのwrapperのprotected参照です。
経路probeは初期値、割当回数、body後の保持を仮定せず、実行中handleを照合できます。

## 時間単位とconstructorの前提

**caller単位のcanonical time** — 呼出しscopeの時間単位で解釈するreal時間量です。
明示scaled／secs引数がcanonical表現との換算を指定し、nanosecond基準の例をpicosecond scopeで未変更のまま再利用できません。

**virtual overrideのformal名** — SystemVerilog 8.20で基底virtual methodと一致が必要な引数名です。
引数型の一致やcompile受理だけでは、override宣言の妥当性を証明しません。

**typed resource最大値** — container特殊化がTに一致する、最初の最大precedence resourceの選択です。
typed DB APIはuntyped選択や独自検査系filterと別に扱います。

**recent-set resource sort** — probeがmost-recently-setの文言を明示解釈する、独立した同precedenceのsort規則です。
最初の最大値の同順位選択を置換せず、安定したqueue順を暗黙に規定しません。

**FIFO preload／DUT転送** — setはabstract FIFOを準備し、updateは間にblocking文を挟む前に新preloadを転送します。
直接write／read、auto／外部予測は別の経路と観測です。

**FIFO constructor前提／build control** — 記載APIの入力と、別索引の固定library初期化variantです。
controlのpassで元の前提をpassにせず、記載外methodをIEEE義務へ変えません。

**core-service宣言control** — 合法なbase-view dispatchとpure実装欠落を区別する独自method本体です。
固定版の追加hookを明示するcontrolでbuiltin algorithmや記載methodだけの前提を認定しません。

## field macroとcallbackのcontrol

**enum collection T前提** — field-macro本文の字面どおりに渡すcollection typedefで、要素enum型を使うcontrolとは別です。
controlはstorageを保持しても元の前提を解決しません。

**対応するPACK flag** — PACKでpackとunpackをenableするfield-macro契約です。明示UNPACK controlは別の証拠であり、
互換roundtripで全ての片方向packing条件を独立に証明しません。

**callbackによるmap変更の前提** — callbackがmapを変更するaccessです。開始時mapを明示するcontrolは異なる前提であり、
provider選択を直接示してもこの変更義務をpassにしません。

**物理／モデル隣接値の分離** — 独自backdoor storageとregisterモデルの隣接fieldを異なる値にし、置換を観測可能にすることです。
選択sliceの保護と、限定した全word保持は別の条件です。

**定義済み保護callback** — 禁止access方向をERRORとUVM_NOT_OKで拒否するregister callbackです。
register／fieldへの所属と削除履歴はfield自身のaccess policyとは別です。

**予測callbackのcontext** — post-predictへ渡すfield同一性、以前／最新の値、予測kind、door、mapです。
選択したdirect予測からread／write callbackの配送や物理accessは導きません。

## scalar macroと走査のcontrol

互換性を確認するcontrolの成功はそのcontrol固有の前提での結果であり、印刷された形の入力の差分を置き換えない理由は[macroのFAQ](faq.ja.md#recordingとscalar-macroの条件)で説明しています。

**scalar macroの独立した方向** — macroでpackして公開APIでdecodeする入力、または公開APIでencodeしてmacroでunpackする入力に、別の末尾観測を加えることです。
この証拠の範囲は[Q269](faq.ja.md#q269-packの反対方向に公開scalar-apiを使う理由は)で説明しています。

**印刷macroの引数control** — 追加引数を明示するか別の印刷interfaceを使い、元のsignature前提を解釈するための別入力です。
control一致後も元の差分を保持する理由は[Q270](faq.ja.md#q270-互換controlが一致すれば印刷macro-signatureは解決しますか)で説明しています。

**依存するvisitor既定値** — 選択したSTRUCTURE型から作るVISITOR型の既定値です。
元の入力と明示型controlの区別は[Q274](faq.ja.md#q274-依存visitorのbuild差分はlibrary宣言の誤りを証明しますか)で説明しています。

**継承した空のvisitor hook** — 派生型がvisitを実装する一方、基底本体は選択した状態を変えないbegin／end callbackです。
選択観測の範囲は[Q276](faq.ja.md#q276-f5の未評価0で走査coverageは完了しますか)で説明しています。

## Virtual抽象の照会の前提

同じ照会でも単位や静的な型が異なる場合があり、測定例と制限は[照会のFAQ](faq.ja.md#virtual-registerの照会と宣言の境界)で説明しています。

**virtual抽象の基底の前提（Virtual abstraction base premise）** — overviewが記載するuvm_reg／uvm_reg_field基底と、明示uvm_object宣言の違いです。
字面の入力と宣言された基底の入力は別の同一性を保持し、controlの一致で文言の食違いを解決しません。

**virtual照会の単位の境界（Virtual query unit boundary）** — 要素offset／incrementはmemory word単位、byte幅は実装memoryの完全なlocationへ切り上げた幅、外部addressは選択mapのaddress単位を使うことです。
model照会の一致では物理storageの転送や普遍的なpacking配置を認定しません。

## Global照会と結合した観測

照会と対応付けの例は異なる前提を明示して保持し、結果の読み方は[FAQ](faq.ja.md#専用global照会と対応付けの修正)で説明しています。

**専用global照会（Dedicated global lookup）** — 共有event／barrier poolに束縛したitemへの静的アクセスです。
印刷pool返却型と本文のitem返却が食違うため、2つの型の前提を別テストと限定した期待値へ保持します。

**結合した観測行（Combined observation row）** — parent、幅、LSBなどの複数の観測列を含む1つの期待行です。
別々の義務がその行の各値へ対応しても、テストとrunner全体の判定は1つのままです。

## recorderのlink可能期間

**Recorder link lifetime window（recorderのlink可能期間）** — open_recorder後からfree前まで、recorderをdatabase linkの端点にできる期間です。
closeはtransactionを終えてもこの期間を終えず、open recorderのflushや所有streamのfreeではrecorderをfreeする場合があります。
free後もobject参照が残る場合がありますが、link可能性やerror回復を保証しない理由は[期間のFAQ](faq.ja.md#recorderのlink可能期間)で説明しています。

## 正準bus操作の観測

**Numeric-word bus fixture（数値wordのbus検査系）** — addressごとの数値wordをuvm_reg_bus_opのfieldで運ぶ独自testbench protocolです。
組み込みTLM payloadのbyte encodingからmapの正準値を分離し、独立したread設定と範囲は[Q289](faq.ja.md#q289-数値wordのbus検査系は何を測定しますか)で説明しています。

**Address-sorted observation（address順の観測表示）** — 実際の操作順を変えず、完了した観測用コピーをaddress順に並べてword／bitの関係を比較する表示です。
時間順やRTL timingとは別である理由は[Q290](faq.ja.md#q290-観測requestをaddress順に並べる理由は)で説明しています。
