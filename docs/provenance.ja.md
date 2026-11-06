# 関連リポジトリとソースの出典

[English](provenance.md) · [README](../README.ja.md) · [テストと開発のガイド](testing.ja.md)

出典はcodeと期待値の由来を示し、変更時にその区別を使う方法は[追加資料の方針](testing.ja.md#権利と出典)で説明しています。

関連リポジトリの規約、取り込んだコード、このスイート独自のコードを記録します。
現在の測定は[実行結果](results.ja.md)、追加作業の経緯は[履歴](history.ja.md)を参照してください。

## kirimasim-testsとの関係

規格は検査する規則を示し、固定リリースのoracleは実装での再現を記録するため、以下の表での両者の役割は[期待値のガイド](testing.ja.md#期待出力の決め方)を参照してください。

| | kirimasim-tests | kirimasim-uvm-tests |
| --- | --- | --- |
| 規格 | IEEE 1800-2023 | IEEE 1800.2-2020（実行の意味は1800-2023の言語に従う） |
| 外部依存 | なし（小さな独立した設計） | UVMライブラリ（版と指紋で固定） |
| 配置 | `tests/chNN/`（1800-2023の章） | `tests/uNN/`（1800.2の章） |
| 固定版のoracle | Icarus Verilog 13.0、Verilator 5.052 | 再現できる範囲でVerilator 5.052 |
| 共通の判定・結果JSON | 元になる実装 | `suite_results.py`を固定コミットから写す。ランナーはこのスイート独自（[`tools/UPSTREAM`](../tools/UPSTREAM)） |
| CI | 独自 | 独自（テストごとにUVMをコンパイルするため重い） |

UVMのテストが言語機能（クラス、パラメータ化クラス、制約、プロセス制御など）の不具合で失敗したら、
その最小例をkirimasim-testsに言語のテストとして追加します。UVMのスイートは、
言語のテストの不足を見つける役も担います。


## 共通の判定・結果コード

共通の結果コードによって両スイートのJSON形式を揃えており、このスイートの実行スクリプトが付けるstatusの読み方は[結果の定義](faq.ja.md#q5-passfailknownunsupportedはどう違いますか)で説明しています。

`tools/suite_results.py`は、
[kirimasim-testsの19034b575e1b715c356660ac1422b45f25c15ab3](https://github.com/kurochan001/kirimasim-tests/blob/19034b575e1b715c356660ac1422b45f25c15ab3/tools/suite_results.py)
から取り込み、次を変更しています。

- `SIMULATORS`は`kirimasim`・`verilator`・`ghost`を列挙します。
- `input_files()`は、固定版で各テストと一緒にコンパイルするライブラリを識別する`third_party/uvm.lock`もhash対象にします。
- `runner_digest()`は、このスイートが使わない`normalize_output.py`の代わりに`tools/uvm_common.py`をhash対象にします。
- moduleのdocstringに取得元を記載します。

upstreamのコミットはコードを取り込んだ時点の正確な内容を識別し、そのコードを変更する際の規則は[権利と出典](testing.ja.md#権利と出典)で確認できます。

## このスイート独自のツール

runnerはテストをビルドして判定し、backendは選択した呼出しを外部コードにつなぐ役割を持ち、特定の実行条件での組み合わせ方は[HDL実行環境の説明](testing.ja.md#verilatorのvpi-hdl部分集合)で確認できます。

ランナー（`run_*.py`）と`lint_metadata.py`はkirimasim-testsのツールを参考に、このスイート向けに書いたもので、コピーではありません。
`sv_lifetimes.py`とその回帰テストも独自のコードです。このhelperは、初期化付きblock内ローカル変数の寿命の明示を字句的に検査します。
シミュレータのparserや言語規格から写したものではありません。

`requirements.py`と回帰テストは、このスイート独自のコードです。
[台帳のデータ](requirements.ja.md)は、ユーザー提供の規格を独自の日英の言葉で要約し、条項番号と期待出力のanchorを添えます。
規範本文やサンプルコードの転載、シミュレータ結果の取り込みは行いません。

`run_verilator_hdl.py`、その回帰テスト、`uvm_hdl_vpi.cpp`は、本スイート独自のcodeです。
runnerは、既存スイートのcompile／判定の流れを、別のevidence同一性で扱います。
限定backendは、標準DPI／VPI interfaceと実際のsimulator handleを使い、商用overlayやsimulator実装から複製しません。
統合には[公開VPI文書](https://verilator.org/guide/latest/connecting.html#verification-procedural-interface-vpi)を参照し、
期待する動作は、ユーザーが与えたIEEE条項から導きます。

[command-line runner](../tools/run_verilator_cmdline.py)と[VPI引数bridge](../tools/cmdline_backend/uvm_cmdline_vpi.cpp)は独自のsuite codeです。
標準VPIのprocess情報と[公開VPI interface文書](https://verilator.org/guide/latest/connecting.html#verification-procedural-interface-vpi)を使います。
[regex wrapper](../tools/cmdline_backend/uvm_cmdline_regex.cpp)は[固定library](../third_party/uvm.lock)にあるApache-2.0 regex sourceをcompileし、
その実装を追跡sourceへ複製しません。[移植用header](../tools/cmdline_backend/malloc.h)は標準の割当宣言を提供します。
期待値は独立したIEEE由来の観測のままで、simulator実装や商用overlayをoracleに使いません。

memory-walkのoracleは、[公式UVM 1.2 class referenceの27.7](https://accellera.org/images/downloads/standards/uvm/UVM_Class_Reference_Manual_1.2.pdf#page=739)を使うAI解釈を明示します。
役割と制限は[Q134](faq.ja.md#q134-memory-walk-algorithmをどう解釈していますか)に記録します。
独立に書いたobserverは、擬似codeの複製や実装由来のoracleではありません。歴史的な文脈はIEEE 1800.2を改訂しません。

照合した歴史的PDFのSHA-256は`87117e30e17701a13434f785687d3776e710e13c74475b6ada4e7823244ea87a`です。
27.7は印刷page 730／PDF page 739にあります。PDFと描画したpageはlocal資料で、コミットしません。

両リポジトリの判定規則が分岐した場合は、共通packageへ集約する計画です。
[tools/UPSTREAM](../tools/UPSTREAM)は、この出典記録への日英の案内です。

## ライブラリと規格

条項の引用先は別途入手する規格で、リポジトリ同梱のマニュアルではなく、新規cloneで利用できる資料の範囲は[ローカル資料の案内](handoff.ja.md#ファイルとローカル資料)で確認できます。

依存ライブラリ、規格、独自のスイートcodeは出典が異なり、資料を追加するときのプロジェクト方針は[権利と出典](testing.ja.md#権利と出典)にあります。

UVM APIの動作はIEEE 1800.2、その前提となるSystemVerilog言語の規則はIEEE 1800で確認し、両規格をテストで引用する方法は[メタデータの案内](testing.ja.md#メタデータ)で説明しています。

外部のAccellera UVMライブラリは[uvm.lock](../third_party/uvm.lock)で取得・検査し、コミットしません。
ライセンスはApache-2.0で、コミットする場合はライブラリ自身の`LICENSE.txt`と`NOTICE.txt`を一緒に置きます。
リポジトリのライセンス原文は[LICENSE](../LICENSE)で、全文の[日本語参考訳](../LICENSE.ja.md)を用意します。

IEEEの条項は番号を引用し、自分の言葉で説明します。規格の本文・図・サンプルコードはテストや資料へ転載しません。
GPL／LGPLシミュレータの実装ソースは読みません。非公開シミュレータの識別情報、版、profile、パスは公開しません。
これらの変更時の規則は[テストと開発のガイド](testing.ja.md#権利と出典)にあります。

FIFO期待値は測定前にIEEEから定め、その後のnull-field停止と追加build初期化の原因調査だけに固定Apache-2.0 UVMを読みました。
独自helper 2種で記載APIと明示初期化の条件を分け、追加呼出しはcontrol前提を補います。その実装で期待FIFO algorithmを定めたり、直接義務を置換したりしません。
GPL／LGPLシミュレータの実装sourceは使いません。

core-service期待値は測定前に導き、固定Apache-2.0 sourceの原因調査で追加pure phase-hopper hookを確認しました。
記載methodだけの元入力は未変更で、別の独自control本体でhookを補います。negative宣言も印刷method欠落1個を分離するためhookを補います。
そのsourceから追加IEEE前提やbuiltin期待値を導きません。初期root fixtureの抽象生成は別に修正します。

field期待は提供IEEEの型／形状、flag、copy、比較契約から導く独自観測です。
字面collection T入力と要素enum control、明示UNPACK controlと未変更PACK単独前提を、それぞれ別の同一性で保持します。
roundtrip一致から普遍stream配置を作ったり全方向を証明したりしません。

field-access期待は提供IEEEのfield／register／callback契約に基づきます。独自の遅延frontdoorとbackdoor storageで選択した効果を観測し、
物理HDL、商用シミュレータ結果、実装から導いたoracleは使いません。測定差分があっても親がfieldに先行するpre順序を保持します。
全word RO期待はbest-effort文言の解釈を明示的に限定し、選択sliceの保護や独立したpoke controlと区別します。

定義済み保護とpost-predictの期待は、提供IEEEのcallback／field契約から導いた独自観測です。
実装固有の診断文をコピーせずにERRORの存在と正確なstatusを規定します。Methods見出し2件を分類条項として個別に読みました。
表示formatの修正で規格に基づく期待観測を変更しません。

recording／scalar macroの期待は、提供IEEEのB.2.3〜B.2.5とrecorder／packer契約から独立に導きました。
その後、固定Apache-2.0のrecorder macro headerを追加引数・整数hook選択・generic書式の原因調査に読みましたが、oracleの根拠にはしません。
印刷どおりの入力、追加引数を許容するcontrol、限定したhandle解釈を分けており、[macroのFAQ](faq.ja.md#recordingとscalar-macroの条件)で説明しています。

走査の宣言期待は、提供IEEEのF.5と言語の抽象class・parameter型・constructorの規則から導きます。
oracleを書いた後、Apache-2.0固定adapterの宣言3件で依存する既定値を確認し、印刷された依存関係と一致していました。
走査algorithmやシミュレータの実装sourceを順序期待の根拠にしません。独自interface本体は公開adapterへ委譲するか宣言された呼出しを観測し、
解釈は[宣言のFAQ](faq.ja.md#走査の宣言と既定値)に記録します。

virtual register／field照会の期待値は、供給されたIEEE 18.9〜18.10の契約とmemory／map address単位の規則から定めます。
独自model設定とreport観測はHDL／storageのdataを転送しません。overviewの基底名と明示class宣言の食違いは限定した入力として保持し、libraryやシミュレータの実装からoracleを作りません。
[照会のFAQ](faq.ja.md#virtual-registerの照会と宣言の境界)を参照してください。

専用global poolの期待値は、供給されたIEEE 10.4／11.2、event／barrier、文字列keyの契約から定めます。
独自の束縛と正の時刻差の待機で実際の公開APIを観測し、実装をコピーしません。印刷pool返却と本文のitemは限定した前提を保持します。
virtual field constructorの取得値は、factoryで生成した独自派生型から実際の基底を呼び出して観測します。
既存configure sourceと安定したparent義務はconstructorの18.10.2.1からconfigureの18.10.2.2へ移し、既存の2義務へ幅／LSBのlinkを加えます。[対応のFAQ](faq.ja.md#専用global照会と対応付けの修正)で説明します。

recorder-linkの期待値は提供IEEE 16.4.4とclose／free／flush、streamのlifecycle、database linkの契約から測定前に導きます。
独自のメモリ内callbackと終了catcherを使い、外部記録databaseや測定した警告をoracleにせず、[期間のFAQ](faq.ja.md#recorderのlink可能期間)で解釈を説明しています。

正準busの期待値は、測定前に提供IEEE 19.1.2、そのfield契約、address／endian／read／write条項から導きます。
独自の数値word callbackでdescriptorと独立に設定したreadを観測し、組み込みTLM byte変換や測定出力をoracleの根拠にしません。
以前の幅の義務のstatementと限定は保持し、[bus操作のFAQ](faq.ja.md#正準bus操作)で説明しています。

補助引用を実際の設定／API呼出しへ揃え、register writeは誤ったgetterの18.4.4.3から18.4.4.9へ修正します。
本体、helper、期待出力、タグの区分は変えません。修正後の全24 sourceを新たに測定し、以前の記録は元の入力同一性で保存して付け替えません。
[Q293](faq.ja.md#q293-補助引用だけの修正でも再測定する理由は)で説明しています。

policy差し替えの期待値は提供IEEE 16、object wrapper／hook、型付き状態APIから独立に導きます。
独自派生型・callback tick・不透明streamの往復を使い、同じrecorderの履歴resetや共通符号化は仮定しません。
新しい実装sourceの参照や商用結果の利用はなく、[policyのFAQ](faq.ja.md#policy差し替えと型付きobject-stream)で前提を説明しています。

printer属性の期待値は提供IEEE 16.2.3.4と16.2.5.1〜16.2.5.3から測定前に導きます。
独自文字列で可視性と数値size表記を分け、未設定peerの既定値と明示有効化controlを保持します。
新しい実装sourceや商用結果は使わず、[出力制御のFAQ](faq.ja.md#printerの属性と出力時の制御)で範囲を説明しています。

adapter親contextの期待値は提供IEEE 19.2.1.2.4、公開clone／parent照会、register／memory frontdoor契約から測定前に導きます。
独自の型付きprotocolと事前設定read storageを使い、do_clone bridgeのsignatureを標準APIにせず、clone件数や完了順も仮定しません。
新しい実装sourceや商用結果は使わず、[親contextのFAQ](faq.ja.md#adapterのsequence-context)で限定を説明しています。

force／releaseの期待値は、測定前に提供IEEE 19.6.2.3／.5／.6、言語の10.6.2、VPIの38.34から独立に導きます。
独自backendは標準VPI flagと実handleを使い、[公開extension文書](https://verilator.org/guide/latest/extensions.html)は公開capabilityの統合だけに参照します。
最新文書の版から5.052での動作を推定せず、独自probeと最終20入力で確認します。GPL／LGPLの実装fileを開いたり利用したりせず、商用結果も使いません。
[HDLのFAQ](faq.ja.md#hdlのforceとreleaseの条件)で期待値、backendの前提、11入力の同一性更新を区別しています。

正時間force_timeの期待値は、測定前に提供IEEE 19.6.2.4とforce／release、言語のtask寿命規則から独立に導きます。
独自observerは期間内と満了後を観測し、taskの復帰時刻や戻り値、内部呼出し数をoracleにしません。
Apache-2.0のpackage／時間単位の設定を確認しましたが、backend／runnerの変更やsimulator実装source／商用結果の利用はありません。
共通コンパイル既定単位と逐次呼出しの前提は[期間のFAQ](faq.ja.md#正時間force_timeの観測)で記録しています。

register pathの期待値は提供IEEE 18.4.6、17.2.3.1、公開task、値渡し規則から測定前に導きます。
標準get_slices入力と非標準の公開slices member-view controlは別の前提にし、後者で標準APIをpassにはしません。
実16／40-bitのwhole変数と合法split referenceは公開APIと未変更の独自VPI backendで測定し、simulator実装sourceや商用結果は使いません。
fixtureの引数方向とset_door API名を修正し、include directory兄弟fileの指紋も照合して、全22入力を修正後に測定します。旧入力／logと期待値の独立性は[pathのFAQ](faq.ja.md#register-hdl-pathと観測の前提)で説明しています。

coverage構築／samplingの期待値は、提供IEEE 18.4.7.1〜.3／.8、18.1.4.1／.7、17.2.2.9と保護／virtual規則から測定前に導きます。
短いregister-builder本文をinclude APIと明示的なblockの類似契約と合わせて読み、scope／要求maskのAI解釈と未検証のresource格納条件を明示します。
独自helperとsampler本体はbin algorithmではなく、実継承block methodによるroutingの観測に使います。
商用結果や新たなimplementation sourceの読取りは使わず、[coverageのFAQ](faq.ja.md#registerのcoverage構築とsampling)で部分契約を説明しています。

report macroの期待値は、提供IEEE B.1と8基本／context条項、report object／message／server契約から測定前に導きます。
独自observerは実macro配送を取得し、default report書式やfatal exitの実装にはしません。macroの厳密なINFO境界とAPIの等値を許す規則を明示して分けます。
初回の未規定な可視MSG 1回制約は正の回数へ修正し、期待値file／helperを変えず全入力を測り直します。
商用結果やsimulator実装sourceは使わず、[macroのFAQ](faq.ja.md#report-macroとinfoの境界)で旧入力の除外と解釈を説明しています。

callback macroの期待値は提供IEEE B.4.1／.3、callback登録／iterator／型／METHOD契約から測定前に導きます。
独自affine hookは順序と参照引数を示すだけでUVM algorithmにはせず、private bitやfactory utilityを前提にしません。
実装sourceや商用結果は新たに利用せず、観測前に終了する差分と未解決B.4概要は[callbackのFAQ](faq.ja.md#callback登録とdispatch-macro)で説明しています。

size／version期待値は提供IEEE B.6／B.7、F.2.1.1／.2と公開packer／parameter／型契約から測定前に導きます。
独自patternは保持dataでありUVM algorithmではなく、reservedの数値、下位配置、vendor version text、opaque encodingを固定しません。
初回commentの折返しと再現tag後に全12入力を再測定し、期待値／本体は保持します。実装sourceや商用結果を新たに利用せず、[サイズのFAQ](faq.ja.md#サイズ定義とversion識別)で観測の限界を説明しています。

report／state期待値は提供IEEE F.2.2.1／.4、F.2.4.2、F.3.4と引用APIから測定前に導きます。
独自observerは実message／hookを取得し、INFO等値、負閾値NONE、状態とkill post-callbackを分け、数値encodingや既定fatal動作を新たに固定しません。
実装sourceや商用結果は新たに利用せず、11 header tagと補強したNONE observer／閾値0 controlを最終測定し、以前のobserver記録は保管して除外します。
未変更の字義的killのpretag同一性を保持する範囲は[report／stateのFAQ](faq.ja.md#reportの列挙型とsequence-state)で説明しています。

virtual register／fieldのpoke／peek期待値は、提供IEEE 18.9.1.3.3／.4、18.10.4.3／.4とmemoryのdeposit／sample契約から測定前に独立に導きます。
単一wordのmask／shift literal、同じ両半分、順序を問わない結果pairで、実装のword順序や内部access algorithmをoracleにしません。
独自user記憶域と未変更VPI backendによる実HDLは別に実測し、実装sourceや商用結果を新たに使わない範囲は[backdoorのFAQ](faq.ja.md#virtual-registerのbackdoor観測)にあります。

callback期待は提供IEEE 18.9.1.4、18.9.2、18.10.5／.6から測定前に導き、pre-readの両立しない整理を別の限定入力に保持します。
構築期待の固定と拒否の観測後に、固定Apacheのsrc/reg/uvm_vreg.svhのpublic宣言を確認するとuvm_vreg_cbsはvirtualです。
その宣言で印刷IEEEのclass期待を変更せず、合法派生型を別controlにします。新規field単独入力の不整合なRMW記憶域は、元の期待を保持して共有する記憶域へ修正し、旧版を保管／除外して全変更入力を新たに測定します。
simulator実装sourceや商用結果は使わず、[callbackのFAQ](faq.ja.md#virtual-registerのcallback契約)で範囲を説明しています。

## 条項カタログの保守

catalogが数えるのは規範的義務ではなく識別子なので、項目の復元でcoverage分母が決まらない理由は[計数単位と対象範囲の案](requirements.ja.md#計数単位と対象範囲の案)を参照してください。

番号だけの[条項カタログ](../tools/clauses_1800_2.txt)へB.2.1.2、B.2.1.3、D.2.2.3を追加しました。
折り返した見出しが以前のcatalogから欠けており、ユーザー提供のIEEE 1800.2-2020規格と手動照合しました。
復元により番号数は2,504から2,507となり、分解前の候補が3件増えます。local抽出textの番号付き見出しらしい行を走査した範囲では、
対象rootでほかの欠落番号は見つかりませんでした。この走査は完全性の証明ではなく、すべての規範的義務を発見したり、
番号のない本文を評価したりするものではありません。規格本文は再配布しません。

## Issueの投稿方針とフォーム

再現例は疑問のある観測を切り出した小さな独立テストであり、併記する期待動作や根拠は[Q18](faq.ja.md#q18-期待値の誤りはどう報告修正しますか)で説明しています。

商用結果の方針は[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests)のFAQと日英の報告フォームを踏襲します。
[元のフォーム](https://github.com/kurochan001/kirimasim-tests/blob/0ca2ff7c922a257b1db681e96352a169625ebb9b/.github/ISSUE_TEMPLATE/report.yml)を、
IEEE 1800.2-2020、このリポジトリの確認対象ランナー、ローカルの投稿方針リンクへ合わせました。
必須の確認欄と、空欄Issueを選ばせない設定を維持しています。
[このリポジトリの方針](faq.ja.md#商用シミュレータとissueの投稿方針)と[フォーム](../.github/ISSUE_TEMPLATE/report.yml)を参照してください。
