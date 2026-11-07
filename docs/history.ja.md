# 開発履歴

[English](history.md) · [README](../README.ja.md)

このページの件数は各変更時点の値なので、現在のスイート規模や実行範囲が必要なときは[現在のスナップショット](results.ja.md#現在のスナップショット)を使ってください。

M1・M2の15回目、M3の9回目、M4の3回目と既存テストの要求への未対応付け解消の時点を含む、段階をまたぐ薄い領域の112回目の拡充（全2723件：simulation 2624・elaboration 99）までを記録しています。以前の349件の時点は
[500f22e](https://github.com/kurochan001/kirimasim-uvm-tests/commit/500f22e10c3ce62a497df929232a562b78952fc5)
です。件数・測定・未検証項目の説明は、それぞれの追加時点のものです。
現状と実行方法はREADME、現在のライブラリの制約は[既知差分](known-differences.ja.md)を参照してください。

各領域を追加した理由は以下の入口から辿り、現在の作業を選ぶときは[引継ぎ資料の優先候補](handoff.ja.md#残作業と優先候補)を参照してください。

- [M1：UVMの基本機能](history.ja.md#m1の追加)
- [M2：sequenceとTLM](history.ja.md#m2の追加)
- [M3：レジスタモデル](history.ja.md#m3初回レジスタモデルの基本2026-11-01)
- [M4：要求台帳](history.ja.md#m4の最初の追加)
- [段階をまたぐ薄い領域の拡充](history.ja.md#m1m4の薄い領域の拡充)
- [走査の宣言と既定値](history.ja.md#薄い領域の69回目の拡充走査の宣言と既定値)

[memory accessとrelocationの拡充](#薄い領域の104回目の拡充memory-access制限とrelocation単位)には追加したprofileの記録があり、そこで使うquery契約の意味は[memoryのFAQ](faq.ja.md#q398-memoryのrightsと有効accessが異なる理由は)で確認できます。

[入れ子transportの拡充](#薄い領域の105回目の拡充入れ子transportのinput-handleとlive-phase)にはinput／refの観測記録があり、呼出し中の観測時点が重要な理由は[phaseのFAQ](faq.ja.md#q403-transport呼出しの復帰前にcallerのphaseを読む理由は)で確認できます。

[保留objectionの拡充](#薄い領域の106回目の拡充保留objectionの取消しと差分件数)には取消しと件数補正の記録があり、公開する観測の意味は[差分件数のFAQ](faq.ja.md#q406-新しい件数が保留dropより少ない場合は何をassertしますか)で確認できます。

履歴中の`out/`パスは現在も残っているとは限らないローカル資料を指すため、そのファイルがない環境での再開に使う保守対象のツールは[引継ぎ資料のファイル案内](handoff.ja.md#ファイルとローカル資料)を参照してください。

「追加」や「拡充」は開発作業のひとまとまりを表し、段階の完了を意味せず、残るM1〜M4の目標は[現在の進め方](../README.ja.md#進め方)で確認できます。

過去の測定を現在のファイルに再利用する前に、記録した入力と実行条件へ[証拠の互換性の確認](results.ja.md#記録の合算)を適用します。

## Ghostの同梱UVMによる測定

同梱モードはシミュレータが供給するUVMライブラリを使う実行であり、以下の過去の件数が前提にする条件は[Q11](faq.ja.md#q11-ghostの結果は何を確認しなぜ仮名なのですか)で説明しています。

最初のM1の同梱UVMでの実行はseed 1・73とも18/27件が一致し、同じ9件で不一致になりました。
同じ実行ファイルでの固定版UVMのスモークテストは、前処理を有効にした場合も不一致でした。
これらは失敗として記録し、期待値は変えません。原因がシミュレータと同梱ライブラリのどちらに
あるかは、この結果だけでは決めません。
2回目のM1追加後は、同梱UVMで両seedとも31/61件が一致し、同じ30件で不一致になりました。
3回目の追加後は、両seedとも41/101件が一致し、同じ60件で不一致になりました。
4回目の追加後は、両seedとも45/133件が一致し、同じ88件で不一致になりました。
6回目の追加後は、両seedとも49/157件が一致し、同じ108件で不一致になりました。
7回目の追加後は、両seedとも53/181件が一致し、同じ128件で不一致になりました。
8回目の追加後は、両seedとも54/205件が一致し、同じ151件で不一致になりました。
9回目の追加後は、両seedとも57/229件が一致し、同じ172件で不一致になりました。
M2の初回追加後は、両seedとも73/253件が一致し、同じ180件で不一致になりました。
M2の2回目の追加後は、両seedとも79/277件が一致し、同じ198件で不一致になりました。
M2の3回目の追加後は、両seedとも82/301件が一致し、同じ219件で不一致になりました。
M2の4回目の追加後は、両seedとも92/325件が一致し、同じ233件で不一致になりました。
M2の5回目の追加後は、両seedとも93/349件が一致し、同じ256件で不一致になっています。

## M1の追加

各追加作業で検査したのは記載した条件下の動作なので、具体的な観測内容は[テストと要求を辿る例](reading-guide.ja.md#1件のテストをファイルで辿る)から確認できます。

最初の追加分として、既存のフェーズのスモークテストに独立したテスト26件を加えました。
期待する観測値はシミュレータの実行前に決めます。

- オブジェクトの名前・改名、cloneと複製したデータの独立性：4件。
- factoryの型置換の更新、インスタンス置換の範囲と優先順位：4件。
- buildの巡回、connectの子から親への巡回：2件。既存の共通フェーズテストは別です。
- objectionの件数、部分的なdrop、親への伝播：2件。
- config_dbのスコープ・型、build時の優先順位、実行時の更新：4件。
- レポートの重大度・ID別件数と冗長度による抑制：2件。
- copy・compare・print・packのポリシー：各2件。printerは既定の表示書式ではなく入力値を、
  packerは実装固有のバイト列ではなく値と長さを確かめます。

2回目の追加分は34件で、スイート全体で61件になりました。

- オブジェクトIDの寿命、静的・動的な型情報、copyのポリシー選択、compareのフックと結果：8件。
- レポートのaction・冗長度の優先順位とNO_ACTIONによる抑制：4件。
- factoryの型・インスタンス別名、置換と登録の検索：6件。
- 共通フェーズの検索と前後関係：2件。
- objectionのdrain timeとdrain中の再raise：2件。
- config_dbのスコープのglobと`wait_modified`の通知：4件。
  待ち合わせのテストにはタイムアウトを付けています。
- 文字列比較と状態の初期化、文字列packの境界、入れ子のdeep copyとcopyフック、printerの設定：各2件。

条項番号の一覧には、抜けていた6.3.5.2を原本と照合して加えました。
IDは具体的な数値ではなく同一性を、文字列packerは実装固有のバイト列ではなく読み戻した値を
確かめます。

3回目は40件を追加し、スイート全体で101件になりました。

- bit・byte・int・longint配列によるobjectのpack/unpack、ポリシーの再利用と既定値の選択、
  field_opの状態とフックの抑制：8件。
- レポートサーバーの重大度別件数、サーバーごとの状態、quit上限と現在の件数の更新：4件。
- 親と明示的なコンテキストを指定したobject・componentのregistry経由の生成：4件。
- タスクフェーズ終了時のスレッド停止と、objectionを保持した状態での子タスクのreturn：2件。
- objectionをraiseしたオブジェクトの一覧、件数がゼロになった要素の除去、全体のclear：4件。
- ポリシー側の処理中オブジェクトのスタック、comparerの型・参照比較、printerの出力先と
  既定値の選択、配列・time・realのpack：14件。
- config_dbの存在確認、診断用のスペルチェック、フィールド・スコープごとの独立した更新：4件。

配列packerの明示的なサイズはビット数で指定し、読み戻した値を検査します。
空配列のunpackにはゼロビットを明示します。printerのファイル検査は独自に定めた文字列を使い、
組み込みの書式には依存しません。タスクフェーズでは正の時間だけobjectionを保持し、
停止対象の子タスクが本来再開する時刻を過ぎてから状態を確認します。

4回目は32件を追加し、スイート全体で133件になりました。

- transactionのライフサイクル時刻、フック、識別子、initiator、名前付きイベント、
  規格が定める生成直後の非active状態：6件。
- レポートの出力先の選択と独立した更新、重大度置換の優先順位と更新、handlerの共有と差し替え：6件。
- registryの便利メソッドを介した相対インスタンス置換と、型置換の更新：4件。
- フェーズのコールバック時の状態、ready-to-endでのobjection、反復上限、状態待ち：4件。
- objectionのraised・dropped・all-droppedのイベント待ち、コールバック・drainの待ち時間、
  対象オブジェクトの区別：4件。
- real比較、copy・compareの順序付き履歴と初期化、int配列のpack境界：8件。

transactionはaccept前にrecordingを無効化し、記録バックエンドに依存させません。
ブロックするフェーズ・objectionのテストにはタイムアウトと、イベント発生前の正の待ち時間を
設けています。フェーズ状態の観測側は、mainの終了を確認するまでrunのobjectionを保持します。
今回の初期化付き手続き内ローカル変数は、SystemVerilog 6.21に従いautomaticを明示し、
ブロック開始時に初期化します。フェーズの反復上限は、static初期化の後で実行文から既定値を読みます。

5回目の追加では、全133件の初期化付きローカル変数の寿命指定を確認しました。
以前の84件にある202個の宣言を`automatic`に変更しました。
ガード付きforkで待ち合わせるconfig_dbの2件では、共有する4個の変数をstaticの記憶域に置き、
ブロック開始時の代入で初期化します。これにより、並行処理をまたぐ共有状態の寿命を保ち、
スコープを越える可能性のあるautomatic変数の参照をVerilatorが拒否する問題も避けます。
206個の初期化すべてが、コンストラクターやgetterも含め、ブロック開始時に実行されます。
対象テストにはSystemVerilog 1800-2023の6.21も引用しています。期待値ファイルは変更しません。
残りのケースは寿命が明示済み、クラスのautomaticメソッド内、または初期化付きローカル変数が
ありません。モジュール直下の補助関数2個も明示的なautomaticです。

メタデータ検査に`tools/sv_lifetimes.py`を組み込み、initial・alwaysのbegin・forkブロックで
同じ暗黙の寿命指定を検出します。入れ子、パラメーター付き・スコープ付きの型、配列、
コメント、文字列、明示したautomatic・staticを回帰テストで検査します。
このチェックは字句検査で、マクロ展開やサブルーチンの寿命の解析、固定版ライブラリの検査は
行いません。コンパイルと実行による検証も続けます。

5回目はUVMテスト133件を維持し、ツールの単体テストが30件から41件になりました。
変更したケースはVerilatorの両seedで再ビルド・実行し、変更していない実行証拠は入力と
ランナーの指紋が一致する場合だけ引き継ぎます。

6回目は24件を追加し、スイート全体で157件になりました。

- ポリシー拡張の保存、動的な型を使うキー、置換、個別・全削除、インスタンス間の独立性、
  flush後の保持、copy・compareフックからの参照：12件。
- config_dbのobjectハンドルの同一性、クラス型の特殊化、null値、古いハンドルを保持した置換：4件。
- ローカルなフェーズスケジュールへの追加、前後を指定した挿入、並列分岐、隣接ノードの検索：4件。
  ローカルなスケジュール自体の実行は対象にしません。
- レポートhandlerのreset、IDの集合、統計の独立したスナップショット：4件。
  重大度・ID別の置換をresetで消すケースは、規格の期待値をspecのみで保持します。

拡張は登録した型のwrapperとハンドルの関係を検査し、内部の保存形式に依存させません。
フックでは未登録の拡張も明示的に扱います。レポートIDとグラフの隣接ノードは、列挙順ではなく
集合の要素を検査します。統計の初期値はレポート呼び出しで作り、実装固有のID件数setterは使いません。

7回目は24件を追加し、スイート全体で181件になりました。

- UVM全体で共有するseeding設定、無効時のreseedによる乱数状態の保持、仮想メソッドによる
  object生成、既定・独自の文字列変換：8件。
- bit・byte・int・longint配列を使うpacker状態の移送、comparerのレポート設定、
  printerの配列表示範囲とelementスタックのpush・pop・flush：12件。
- taskフェーズのobjection APIとノード間の独立した件数、functionフェーズでの
  無効なobjection操作に対するエラー：4件。

乱数状態は同じオブジェクトの前後で一致するかだけを検査し、その形式や乱数値は指定しません。
packerの状態は互換性のある実装の対応するgetterから取得し、配列の内部形式は検査しません。
printerの保護されたスタック取得APIはテスト用サブクラスから公開します。flush後はelementを
再利用できるため、古いハンドルを検査しません。functionフェーズのエラー検査は無効な戻り値を
使わず、文面やIDに依存しません。ローカルなスケジュール自体は実行しません。

8回目は24件を追加し、スイート全体で205件になりました。

- report messageの共通フィールド、action・出力先ファイルの独立した更新、処理側オブジェクトの
  参照、メッセージ間の独立性、生成ヘルパーによる呼び出しスレッドの乱数状態の保持：8件。
- field_opの操作名と型、getterの事前条件、flushなしの再設定、複数操作フラグの混在：8件。
  getterの事前条件を検査する2件は、規格の必須エラーをspecのみで保持します。
- factoryの登録とwrapper検索、型・名前による照会、factory間の独立性、core serviceを通した
  factoryの選択：8件。

messageは設定したフィールドとハンドルの同一性を検査し、レポートとして出力せず、ファイル記述子の
数値にも依存しません。乱数状態はinitialプロセスで取得し、一致するかだけを比較します。
field_opのエラー検査は無効な戻り値を使わず、再利用前にflushします。登録の検査にはローカルな
factoryを使い、大域的に登録された組み込み型の影響を避けます。選択の検査では、終了前に元の
大域factoryへ戻します。

9回目は未検証のAPI条項を先に選び、24件を追加しました。スイート全体で229件になりました。

- wrapperのobject・component生成と、表す型の名前：6件。
  8.3.2.2.1・8.3.2.2.2・8.3.2.2.3を各2件で検査します。
  `tests/u08/`の`test_wrapper_*`は共通のproxyハンドルを通して呼び出します。
- packerのobject往復、状態を進めないnull照会、不適合なnull引数、operation・hookの順序、
  処理中objectの状態、hook抑制：8件。16.5.4.2・16.5.4.3・16.5.4.4を各2件以上で検査します。
- printer elementの生成とフィールド更新、直下の子要素照会、既存キューの保持、葉、繰り返し追加：10件。
  16.2.8.2.1〜16.2.8.2.6と16.2.9.2.1〜16.2.9.2.2を各2件以上で検査します。

今回照合した14のAPI条項は各2件の目標を満たしました。この対応付けは対象を絞ったもので、
M1全体の要求台帳ではありません。残りの条項は引き続き確認が必要です。メタデータの引用は
準備に使うAPIや構造上の条項も含むため、引用件数だけでは要求の網羅や正確な残テスト数を判断できません。

objectのストリームは同じpacker実装で生成し、マーカーの幅や形式を指定しません。
不適合なnull引数のエラー後は、追加のunpackを行いません。子要素の関係は標準のprinterスタックAPIで
構築し、proxyの検査は兄弟の順序を仮定せず、集合と既存キューの保持を確かめます。実装固有の
子要素更新APIは使わず、flush後の古いハンドルも検査しません。仮想メソッドの引数名は基底宣言に合わせ、
`do_execute_op`では`op`を使います。

## M2の追加

M2は`tests/u12/`のTLM 1テスト24件から開始し、スイート全体で253件になりました。

- 上限あり・なしのFIFOの容量、使用数と利用可否、到着順、消費しないpeek、書き込み拒否、
  flush、インスタンス間の独立性：8件。12.2.8.2と12.2.4.2のメソッドが中心です。
- データ・空き容量ができるまで待つblocking FIFO get・put：2件。
- analysis FIFOの書き込み順、無制限の容量、読み書きの混在、peek、flush、独立性：6件。
  12.2.8.3を対象にします。
- analysis portによる2つの受信先への配信、objectハンドルの保持、受信先なしのwrite、
  analysis exportを経由する転送：4件。12.2.10を対象にします。
- FIFO exportに接続したblocking・nonblocking put portと複合get-peek port：4件。
  12.2.5.1と12.2.8.1.3・12.2.8.1.4を対象にします。

portの検査は通常のUVM elaborationを通し、bindingsの解決後に観測します。analysisの受信結果は
write完了後に検査し、受信先の呼び出し順を仮定しません。受信先はトランザクションを変更しません。
blockingの検査はobjectionを保持し、正の遅延で待機状態を観測します。共有値はテストobjectに置き、
watchdogも設けます。状態を変える操作は別々の文で実行してから結果を表示します。
利用できない読み出しの検査は成否とキューの状態を観測し、失敗時の出力引数の保持まで
検証したとは扱いません。

M2の初回24件はVerilator 5.052のseed 1・73で一致します。

M2の2回目は`tests/u14/`と`tests/u15/`に24件を追加し、スイート全体で277件になりました。

- sequence itemの文脈設定・置換、親・深さ・root・pathの照会、sequence情報のフラグ、
  非実行時のsequencer参照、itemとsequenceの仮想判定：8件。14.1.2を対象にします。
- sequenceの実行hookと状態、pre/post-bodyの省略、親hook、優先度、再実行、状態待ち、
  randomizationの有効値、開始phaseと自動objectionの設定：8件。14.2を対象にします。
- sequencerのarbitrationと要求・応答バッファのサイズ設定、明示的な完了通知、peek・get、
  2件の要求転送、item_done・putによる応答の配送：8件。15.3と15.5を対象にします。

追加24件もVerilator 5.052の両seedで一致します。要求・応答のケースは通常のUVM elaborationを通し、
driverのpull portをsequencer exportに接続します。自動item recordingは無効にし、共有する要求・応答の
ハンドルはテストobjectに置きます。完了通知の待機状態は正の遅延後に観測し、応答の待ち合わせにも
正の遅延を設けます。blockingのケースにはwatchdogがあります。応答はset_id_infoで配送IDを引き継ぎ、
表示するのは明示的に設定したtransaction IDだけです。割り当てられるsequence IDの数値は使いません。
カウンターは明示初期化し、単独の状態待ちの検査はmodule寿命のハンドルと正のbody遅延を使います。

設定値のケースは、自動randomization、自動phase objection、競合するsequenceのarbitration順、
バッファ内容まで検証したとは扱いません。

M2の3回目は24件を追加し、スイート全体で301件になりました。

- callbackの有効・無効と無視するmode値、append・prepend順、instance別の登録・削除、
  重複登録・再削除時の必須warning、typewide登録・削除、get_allの内容：12件。
  10.7と、型の組み合わせの登録・実行に使うB.4のマクロを対象にします。
- callback iteratorの前後の走査、無効な要素の除外、現在のcallback、位置とobject文脈の独立性：4件。
  D.1を対象にします。
- request/response channelの順序、独立した容量、消費しないpeek、無制限のキュー、
  受理した書き込みのanalysis通知、複合master・slave、blocking transportの待機・再利用：8件。
  12.2.9を対象とし、要求にはint、応答にはstringを使います。

追加24件もVerilator 5.052の両seedで一致します。callbackの有効値は明示し、実行は規定の
append・prepend順で検査します。get_allは集合と既存キューの保持を検査します。
テスト用の型名はuser_callbackとし、マクロ内のローカル識別子cbとの衝突を避けます。
期待値は型名自体には依存しません。iteratorの走査中に登録を変更することはありません。

channelは通常のelaboration後に公開port・exportを通して操作し、保護された内部FIFOは参照しません。
analysis通知は書き込みの受理後に読み出します。transportは共有値をテストobjectに置き、正の遅延で
待機を観測してwatchdogを設けます。その追加分ではTLM 1のnonblocking transportと、
名前によるcallback登録・型継承は対象にしていません。

M2の4回目は24件を追加し、スイート全体で325件になりました。

- TLM 2 generic payloadのcommand・address、unsignedなdata・byte-enable配列のコピー・置換、
  応答判定、streaming幅とDMI hintの設定：8件。12.3.4.2を対象にします。
- payload拡張の型キー、ハンドルの取得・置換、個別削除、payload間の独立性、全削除後の再利用：4件。
  12.3.4.2と12.3.4.5を対象にします。
- blocking socketのREAD処理とpayload再利用、nonblocking forwardの完了、forwardで受理した要求を
  backward応答とphase参照の更新で完了させる経路：4件。12.3.2と12.3.5・12.3.6・12.3.8を対象にします。
- 検索root内での完全名・globによるcallback登録と削除、基底型のtypewide callbackの継承と削除、
  true・falseでのcallback処理の途中終了：8件。10.7とB.4を対象にします。

追加24件はVerilator 5.052の両seedで一致します。payloadの配列と長さは対応する値を設定し、
独立した不一致の長さは検査しません。data・byte-enableはメンバーの内部配置ではなくaccessorで確認します。
DMIとstreamingのケースは設定値を検査し、実際のDMIアクセスやtargetのstreaming処理まで
検証したとは扱いません。拡張の型キーは基底型のハンドルで比較し、数値IDを指定しません。

transportは通常のelaboration後に、transaction・delayのハンドル、戻り値、phase更新を検査します。
blocking targetは明示した2-byteのREAD要求を処理します。nonblockingはIGNORE transactionを使い、
呼び出し中の即時完了とbackward応答による完了を検査します。delayは受け渡しを確認するだけで、
数値の分解能や時間変換までは検証しません。phaseを使うケースにはwatchdogを設けます。

名前によるcallback操作はcomponentの完全名で照合し、同じパターンに一致するobjectをrootの外にも
置きます。継承は標準の基底型登録マクロを使います。途中終了のケースは後続callbackが呼ばれないことを
検査します。期待値は階層検索の列挙順には依存しません。

M2の5回目は24件を追加し、スイート全体で349件になりました。

- 応答handlerとキューの既定値・設定の独立性、FIFO順・transaction ID指定の取得、
  handlerへの配送とキューへの切り替え、clear後の再利用、overflowエラーの有効・無効、
  無制限の容量、応答数未満への深さ変更：12件。14.2.7と14.3.3.3を対象にします。
- `item_done`・`get`までのsequence／sequencerのcurrent item、要求・応答の履歴、
  応答analysis portでの配送、`execute_item`、要求がない場合の`try_next_item`、
  候補1件のUSER arbitration、子sequenceの関係：8件。14.3.3.2と15.3・15.4・15.5を対象にします。
- 自動starting-phase objectionの有効・無効、子sequenceのpriority継承、
  driverの要求を待たせるrelevanceの制御：4件。14.2.3・14.2.4・14.2.5を対象にします。

追加24件のうち19件はVerilator 5.052の両seedで一致します。残る5件は応答エラー報告の既定値、
深さ変更の必須エラー、USER arbitrationのcallbackをspecのみで保持し、seed 1で既知の差分を記録します。
期待値は規格から導いており、固定版ライブラリではこれらの点が規格と異なります。

応答は実際にdriverへ渡した要求を完了させ、そのID情報をコピーして作ります。
キューの読み出し前に応答をすべて送り、内部キューを参照せずにFIFO順・ID指定取得・handler切り替えを
競合なく確認します。overflowはエラー制御を観測し、残る応答の選択は仮定しません。
履歴は値と明示したtransaction IDを確かめ、snapshotや同一ハンドルを仮定しません。
範囲外の履歴indexは、設定したサイズより明確に大きい値を使います。

current itemと直接実行は、driverのacknowledgement前の状態を検査します。
relevanceは正の遅延後にゲートを開きます。自動objectionは、独立したtask-phase nodeで
sequence callback内と自然完了後の件数を確認します。待機するテストにはwatchdogを設けます。

現在の集計は、追加24件の新規実行と既存325件の結果を合算しています。
既存分は入力・ランナーの指紋とシミュレータ設定が一致することを確認しています。

M1のspecのみの6件と未達の条項は保持し、M2開始によってM1完了とは扱いません。
sequence・sequencerとcallbackの残りの動作、TLM 1のnonblocking transport、TLM 2のより広い
timing・protocol検証が今後のM2追加範囲です。M2全体は未完です。

### M2の6回目

24件を追加し、スイート全体で373件になりました。

- 競合するsequenceの仲裁：8件。異なる優先度でのFIFO到着順、到着順の反転、
  STRICT_FIFOの優先度と同順位の到着順、STRICT_RANDOMの単独最高優先度、
  USERによる先着・後着の低優先度候補の選択、RANDOMの配送集合を検査します。
  15.3.2.19・F.2.4.1と、USERの15.3.2.3・15.3.2.4を対象にします。
- lock／grab：8件。sequenceとsequencerのAPI、取得方法と異なる名前の解放API、
  親子の入れ子の所有と復帰、unlockまで待つ取得の引き継ぎを検査します。
  14.2.5.5〜14.2.5.10と15.3.2.8〜15.3.2.13・15.3.2.15・15.3.2.16を対象にします。
- TLM 1のnonblocking transport：8件。即時応答なし、要求容量が満杯の状態、
  nonblocking・複合transport port、容量の再利用、channel間の独立性、失敗した呼び出しの
  要求を回収した後の再実行、要求・応答のobjectハンドルを検査します。
  公開APIを通し、12.2.9.2.2と12.2.4.2.11を対象にします。

追加24件はVerilator 5.052のseed 1・73とも一致します。specのみの追加はなく、
全体ではoracle付き362件が一致し、11件の既知差分をseed 1の記録として保持します。
Ghostの同梱UVMは各seedで95件一致・278件不一致で、不一致になるテストも同じです。
kirimasimは373件とも`uvm_object_wrapper`未実装です。集計は今回の24件の新規実行と、
指紋を確認した変更のない349件の結果を合算しています。

仲裁は要求の到着時刻を分け、両候補が待ってからdriverを開始します。RANDOMは各要求が
1回ずつ届いたことを確認し、順序や分布の検査は主張しません。USERは候補2件のcallbackを
検査し、候補1件の必須呼び出しは別のspecのみのテストとして保持します。

lockの照会は、明示的にsequencerへ関連付けたsequence objectで行います。
親のlock下で子が取得できること、子の所有中は親がblockedになること、解放で親が再び
実行可能になることを検査します。競合する取得は正の遅延後と、取得側が遅延して解放する前に
観測します。所有とblocking APIの検査であり、キュー上のlockとitemの順序の検査ではありません。

即時transportは、受理された要求のanalysis通知で応答を計算し、公開response put portから返します。
成功した要求は公開get interfaceで回収し、容量を再利用します。失敗時の出力引数や途中の
キュー状態は指定せず、再実行の前に残った要求があれば回収します。回収の成否自体は期待値にしません。
objectは型付きハンドルとpayloadを比較します。待機するテストにはwatchdogを設け、
保護されたFIFOや仲裁キューは参照しません。

### M2の7回目

24件を追加し、全体で397件になりました。

- itemの排他と利用可能性：8件。lock／grab中の所有者の連続item、取得済みitemの完了を待つlock、
  FIFOでのlock順、親lock下の子の通信、子grab中の親の待機、lock・relevanceによる
  `has_do_available`の変化を検査します。
- 停止：8件。sequencerあり・なしのkill、lockの解放、実行中の2つのbodyの停止、
  driverが保持する要求を破棄した後の再実行、kill後の必須hook、killによる自動objectionのdropを検査します。
- default phase sequence：8件。randomization無効時のinstance、wrapperからの生成と乱数hook、
  factory instance overrideの文脈、phaseごとのresource、高優先度のnullによる無効化、
  phase終了時のkill、不適合な2種類のwrapperに対する必須エラーを検査します。

追加18件はVerilator 5.052のseed 1・73で一致します。残る6件はlock順序、kill後のhook、
不適合なdefault型のエラーを各2件で検証し、seed 1の既知差分として規格の期待値を保持します。
指紋を確認した既存373件との合算では、380件一致・既知差分17件です。
Ghostの同梱UVMは両seedとも96件一致・301件不一致で、不一致の集合も同じです。
kirimasimは397件とも`uvm_object_wrapper`未実装です。

driverは有効な要求だけを完了通知します。`stop_sequences`で保持中の要求を破棄した後は、
新しいitemを取り出してから`item_done`を呼びます。killは待ち合わせ後に停止状態とstartの復帰を
確認し、元のbodyの遅延処理を過ぎるまでobjectionを保持して、生き残った処理を検出します。
自動objectionは独立したtask-phase nodeで観測します。

default sequenceは実際のruntime scheduleで動かします。phaseのobjectionで自然完了までの時間を確保し、
より長いrunのobjectionでphase終了時のkill不足も検出します。randomizationはpre/post hookで確認し、
乱数の値は表示しません。factory overrideは規定のsequencer文脈とwrapper型名で指定します。
nullの無効化は登録順ではなく、build時のrootとtestの優先度を使います。
不適合な型は診断の文面を指定せず、エラー件数で確認します。

M1・M2は引き続き未完です。キュー上の所有の相互作用、階層的な停止と応答の後処理、
default resource選択の残りの条件、callbackとTLM protocolの検査が残っています。

### M2の8回目

24件を追加し、全体で421件になりました。

- 停止：8件。親子、兄弟、3階層、親のlockと子のgrabの後処理、別sequencerへの独立性、
  単独・親子の自動objection、実行中の`get_response`待ちの中断を検査します。
- 応答の配送：8件。自然終了・kill・stop後のqueueとhandlerへの不達、別sequenceのkill後も
  生存する配送経路、同じtransaction IDを再利用する新しい経路への古い応答の混入防止を検査します。
- default resource：8件。名前不一致、高優先度の不適合な型と無関係なnull object、
  wrapper・instanceの両方向の優先度、null wrapperによる無効化、同一優先度の2通りの
  登録順の間に不適合な型を入れた場合の選択を検査します。

追加22件はVerilator 5.052のseed 1・73で一致します。残る2件はstop時の自動objection解除を
specのみで保持し、seed 1で既知差分を記録します。固定版ではrootの件数が残り、親子のケースでは
子だけがdropされます。観測後に独立したobjectionをclearします。指紋を確認した既存397件と
合算し、402件一致・既知差分19件です。Ghostの同梱UVMは両seedとも98件一致・323件不一致で、
不一致の集合も同じです。kirimasimは421件とも`uvm_object_wrapper`未実装です。

階層は兄弟の停止順を指定せず、状態とobjectごとのhookを確認します。別sequencerの処理は自然終了させ、
遅延したbodyのフラグは元の期限を過ぎてから観測します。自動objectionのnodeは実際のphase scheduleと
独立させ、既知差分の経路でも規格の件数を検査できるようにします。

遅れた応答は実際に完了通知した要求からIDをコピーします。warningは重大度の件数で確認します。
queueは時間を区切って待ち、その読者を中断します。handlerは呼び出し件数で確認します。
古い応答が、同じtransaction IDを使う新しい経路へ混入してはいけません。
これだけでstopが配送済みの全応答キューを消去することまで検証したとは扱いません。

default resourceは実際のmain phaseで検査し、rootとtestのbuild文脈で優先度を分けます。
同一優先度は個別のresourceと公開pool APIの低優先度での追加を使い、型のフィルタ後も最初の
有効な要素を選ぶことを確認します。コンストラクターの値と同一性でwrapper生成とinstanceを区別し、
randomizationは乱数値ではなくhook件数で確認します。M1・M2は引き続き未完です。

### M2の9回目（2026-11-01）

24件を追加し、全体で445件になりました。

- canonical time：8件。明示・既定の名前、規格のdefault-resolution設定API、絶対単位の変換と
  置換、異なるresolutionでのreset、scaledな増減、alias経由の変更、時間を進めないblocking注記を検査します。
- nonblocking socket：8件。pass-through initiator・target・両者・二段の経路を使い、
  即時完了と、受理後の自動backward完了・phase更新を検査します。
- callback iterator：8件。static APIの前後の終端と再開、typewide文脈、integer位置と
  object文脈の独立性、facadeの再開と有効なcurrent callbackを検査します。

追加21件はVerilator 5.052のseed 1・73で一致します。3件はspecのみで保持し、既定名と二段の
initiator backward接続はseed 1の差分、規格の時刻APIは欠落によるビルド不可です。
指紋を確認した既存421件と合算し、423件一致・既知差分22件になりました。
既知差分のうち21件はseed 1の実行時の記録、1件は実行前のビルド失敗です。
Ghostの同梱UVMは両seedとも103件一致・342件不一致で、不一致の集合も同じです。
kirimasimは444件がUNSUPPORTED、1件は時刻API欠落によるFAILです。

時刻はrealの許容差と明示単位で比較します。scaledな増減は、すべての合法な時間単位でゼロに
ならない100秒のliteralを使い、その時間は待ちません。canonical値の範囲内で検査し、
resolution未満の丸めや負の時刻は指定しません。規格のsetter名を旧APIへ置き換えません。

socketは通常のelaborationを通し、親port・子exportの階層を使います。backwardはconnectによる
自動接続を検査し、二段initiatorの差分を隠す手動接続は追加しません。
payload・delayの同一性、注記、phase参照、statusを観測し、portの内部格納は参照しません。
これでTLM 2のprotocolやtiming全体の網羅とは扱いません。

iteratorの位置の数値は指定しません。走査前に登録を完了し、規定に従って無効な要素やinstance限定の
要素を除外します。facadeの`get_cb`は有効なアクセス後だけを確認し、終端後の値は指定しません。
M1・M2は引き続き未完です。

### M2の10回目の追加（2026-11-01）

24件を追加し、全469件になりました。

- push sequencer・driverを8件：型付き接続と階層、blocking完了、複数要求の転送順序、
  応答の経路とID、共通APIの要求・応答履歴、response handler、handleの変更です。
- sequence操作マクロを8件：item・子sequenceの生成とcontext、乱数化なしの送信、
  item・子sequenceの乱数化付き送信、子の乱数化無効、生成から乱数化・実行までの組み合わせです。
- generic payloadのpackを8件：公開APIで規定順序を読む検査、scalarの往復、data・byte-enableの
  有効な先頭部分、短い配列の必須fatal、source extensionの省略、destination extensionの維持です。

新規21件はVerilator 5.052のseed 1・73で一致しました。複数のpush要求と要求・応答履歴の3件は、
規格の期待値をspecのみで保持します。固定版は完了した要求をFIFOに残し、次の要求を拒否します。
テストを通すためにFIFOを手動で消費したり、pull方式の完了通知を加えたりはしていません。

指紋を照合した既存445件と合算し、全体は444件一致・既知差分25件です。
既知差分は実行時のseed 1差分24件と、どのseedも実行できないAPI欠落のビルド失敗1件です。
Ghostの同梱版は各seedで105件一致・364件不一致で、不一致になるテストも同じです。
kirimasimは468件が`uvm_object_wrapper`未実装、1件が時刻API欠落でFAILです。

pushの待機は正の遅延の途中で観測し、応答は実際の要求IDと異なる要求・応答の型を使います。
マクロの乱数化は解が1つの制約とcallback回数で検査し、item送信ではdriverが受けたhandleも確認します。
子のhookでは`body`と任意のpre・post hookを区別します。payloadは公開packer APIで検査し、
内部のstream表現やobject markerを指定しません。fatalの検査はcatcher内で終了を要求し、
fatal後のpayload内容を定めません。README・用語集・FAQ・既知差分を日英で更新しました。
M1・M2とも目標の棚卸しは未完です。

### M2の11回目の追加（2026-11-01）

24件を追加し、全493件になりました。

- library登録を8件：単独・一括の重複抑制、callerの既存queueへの追記、instance内の削除、
  未登録型の必須warning、将来のinstanceへのtypewide追加、static削除の伝搬です。
- libraryの選択・制御を8件：既定の選択hookの周回と独立した位置、規格APIによるmodeの既定・更新、
  回数範囲の既定・制約、実行前・実行中・完了後の回数です。
- マクロを8件：子の生成から実行までと別sequencerのcontext、item・子のfactory置換、
  乱数化あり・なしのitemのhook順序、生成後のfield `rand_mode`、型付きsequencer変数の宣言です。

新規16件はVerilator 5.052のseed 1・73で一致しました。削除の2件はseed 1の既知差分です。
未登録型でwarningを出さず、static登録の削除も他の既存instanceへ反映されません。
別の6件はsequence libraryの必須APIが7つ欠けるためビルドできません。
必須APIの呼び出しを、旧来の公開fieldへ置き換えていません。

指紋を照合した既存469件と合算し、全体は460件一致・既知差分33件です。
既知差分は実行時のseed 1差分26件と、seed未実行のビルド失敗7件です。
Ghostの同梱版は各seedで107件一致・386件不一致で、不一致になるテストも同じです。
kirimasimは486件が`uvm_object_wrapper`未実装、時刻APIの1件とsequence libraryの6件が
API欠落でFAILです。

登録は公開の一覧と所属回数で観測し、挿入順を決めつけません。typewide追加はinstance生成の前後を
分けて確認し、削除はinstance登録とstatic登録を区別します。選択hookの戻り値は別々の文で保存します。
hookの直接呼び出しをUSER modeの実行結果とは扱わず、API欠落の回数検査も実行済みとは主張しません。

マクロの制約は解を1つに限定します。親の`pre_do`・`mid_do`・`post_do`、乱数化callback、
driverの受信をtraceで区別します。factory置換は生成したsubtypeとcontextを確認し、fieldの乱数化を
無効にしてもcallbackが呼ばれることを検査します。型付き変数は明示的なcast後にmemberへアクセスします。
README・用語集・FAQ・既知差分を日英で更新しました。M1・M2とも目標の棚卸しは未完です。

### M2の12回目の追加（2026-11-01）

24件を追加し、全517件になりました。

- TLM 1を8件：blocking・nonblocking・両対応のmaster／slave impを要求側・応答側の兄弟componentへ
  委譲し、両対応exportでも同じ経路を検査します。intの要求とstringの応答で、容量・利用可否・
  peekによる保持・領域の再利用を確認します。
- 低水準のsequence APIを8件：driver要求までのgrant待ち、既定の乱数化なし送信、明示的な再乱数化、
  完了通知の待機、transaction ID別の完了、`get`による暗黙の完了、grant時のlock要求、
  現在のsequencerへの優先度・送信元の伝搬です。
- TLM 2を8件：blocking exportの完了待ち、階層経路での時間を進めないannotation更新、
  異なるpayloadの反復、nonblockingの両方向のphase更新、個別に接続した往復経路、
  独自transaction・phase型を扱う両方向の階層exportです。

新規24件はVerilator 5.052のseed 1・73で一致しました。指紋を照合した既存493件と合算し、
全体は484件一致・既知差分33件です。既知差分は実行時のseed 1差分26件と、seed未実行の
API欠落によるビルド失敗7件のままです。Ghostの同梱版は各seedで107件一致・410件不一致で、
不一致になるテストも同じです。kirimasimは510件が`uvm_object_wrapper`未実装、7件がAPI欠落でFAILです。

分割impの親には転送methodを設けず、constructorで要求・応答それぞれの兄弟FIFOを選びます。
読み出し失敗時の未規定の出力値は検査しません。低水準の送信はgrant後に時間を進めず呼び、
ID指定の完了待ちは対応する完了通知前に開始します。正の遅延で待機中の状態を観測し、
grantの観測用overrideは通常のsequencerの仲裁へ委譲します。

通常のTLM 2 exportは親から子への階層を使い、往復はforward・backwardを個別に接続します。
handleの共有とcanonical annotationを観測し、blocking呼び出しではtargetが待機している途中を検査します。
独自phase型は汎用の型の伝搬を検査し、base protocolのやり取りが成立したとは主張しません。
README・用語集・FAQと現在の集計を日英で更新しました。M1・M2とも目標の棚卸しは未完です。

### M2の13回目の追加（2026-11-01）

24件を追加し、全541件になりました。

- FIFOのanalysis通知を8件：blocking・nonblockingのput／get配信、両方のpeek通知、
  putの拒否と利用可否の照会、両analysis経路でのobject handleの同一性です。
- `start_item`を8件：明示引数・item・親sequenceのsequencer選択順序、非負・負の優先度、
  null item・itemではないsequence・sequencer不足に対する必須ERRORと早期returnです。
- 外部object指定のcallbackマクロを8件：contextの切り替え、dispatcherの除外、無効化と再有効化、
  typewideとinstanceの所属、true・falseでの途中終了、不一致時の全走査、空の外部contextです。

新規19件はVerilator 5.052のseed 1・73で一致しました。5件はseed 1の既知差分です。
固定版は2種類のFIFO peek通知を省略し、3種類の不正な`start_item`入力をERRORではなくFATALで報告します。
指紋を照合した既存517件と合算し、全体は503件一致・既知差分38件です。既知差分は実行時の
seed 1差分31件と、seed未実行のAPI欠落によるビルド失敗7件です。Ghostの同梱版は各seedで
108件一致・433件不一致で、不一致になるテストも同じです。kirimasimは534件が`uvm_object_wrapper`
未実装、7件がAPI欠落でFAILです。

FIFOのobserverは独立した履歴を保持し、subscriber間の呼び出し順を指定しません。peekではitemが
残ることと必須通知数を別々に観測します。読み出し失敗時の出力値は検査せず、拒否や利用可否の照会を
通知件数に加えません。

sequencer選択は別々に接続した3つのdriverで実際の要求を処理し、通常の仲裁とpre・mid・post hookを
確認します。不正入力はcatcherで元の重大度を変えずに数え、早期returnと`pre_do`がないことを観測します。

callbackマクロは安定した外部contextとfunction callbackを使い、真偽値が一致したら後続を呼ばずに
停止します。不一致や空のcontextでは呼び出し回数を検査し、戻り値や後続文へ進む方針は指定しません。
README・用語集・FAQ・既知差分を日英で更新しました。M1・M2とも目標の棚卸しは未完です。

### M2の14回目の追加（2026-11-01）

24件を追加し、全565件になりました。

- put・get・peek・get_peekの宣言12系列：blocking・nonblocking・両対応を、独立した2つの
  suffix付きhandlerへ振り分けます。
- master・slaveの宣言6系列：intの要求とstringの応答を、両方向で正しいsuffixへ渡します。
- transportの宣言3系列とanalysis宣言：要求・応答の組と入力別の履歴を、指定したmethodへ渡します。
- 追加の2件：生成したanalysis入力でのclass handleの維持と、master impの要求・応答を別の兄弟へ
  委譲するconstructor引数を確認します。

新規24件はVerilator 5.052のseed 1・73で一致しました。複合master・slaveと分割masterでは、
拒否後の領域の再利用によるnonblocking書き込みの成功と、読み出し前後の利用可否も検査します。
強化した3件は最終sourceを全ランナーで再実行しました。指紋を照合した既存541件と合算し、
全体は527件一致・既知差分38件です。既知差分は実行時のseed 1差分31件と、seed未実行のAPI欠落による
ビルド失敗7件です。Ghostの同梱版は各seedで110件一致・455件不一致で、不一致になるテストも同じです。
kirimasimは558件が`uvm_object_wrapper`未実装、7件がAPI欠落でFAILです。

生成したimpは通常のportから呼び、実装にはsuffix付きmethodだけを設けます。入力ごとの値と利用可否を
変えて振り分けを観測し、blocking handlerには正の遅延を入れて、完了後に呼び出しが戻ることを検査します。
失敗時の出力値は確認しません。分割したケースでは親に転送methodを設けず、要求・応答の実装handleを
constructorへ明示的に渡します。

B.5.11は見出しとclassの説明がnonblocking get／peekですが、呼び出し例はpeek専用の表記です。
ケースは見出しと説明されたclassに従う解釈を採用し、sourceコメントとFAQにレビュー項目として残します。
固定版での再現だけでは表記の不一致を解消したとは扱いません。全件の`spec_check: ai`を維持し、
README・用語集・FAQと現在の集計を日英で更新しました。M1・M2とも目標の棚卸しは未完です。

### M2の15回目の追加（2026-11-01）

24件を追加し、全589件になりました。

- libraryを8件：2つのinstance・2種類の型へのstatic登録、継承とinstance内の追加、
  1種類・2種類の候補による既定のRAND実行と、どちらかを選ぶ単一解の制約です。
- extensionを8件：多相的な型key・型名の同一性と改名、keyによる登録・置換・削除、
  `uvm_tlm_gp` aliasによるpayload状態の共有です。
- finish_itemを8件：明示的な完了ID、virtualな送信・待機の呼び出し、mid-doの変更とpost-doの完了通知、
  不正入力3種類の必須検査です。

新規13件はVerilator 5.052のseed 1・73で一致しました。11件はseed 1の既知差分です。
static libraryの構築4件、virtual呼び出し2件、完了ID2件、入力検査3件で規格の期待値を保持します。
入力検査の固定版の経路は、期待する通常のreturnより前に終了します。指紋を照合した既存565件と合算し、
全体は540件一致・既知差分49件です。既知差分は実行時のseed 1差分42件と、seed未実行のビルド失敗7件です。
Ghostの同梱版は各seedで112件一致・477件不一致で、不一致になるテストも同じです。
kirimasimは582件が`uvm_object_wrapper`未実装、7件がAPI欠落でFAILです。

libraryは規格のsubtype constructorと必須マクロを使い、実装固有の追加の初期化呼び出しを加えません。
成功する実行検査はinstance登録を使い、合法な既定の10回を維持します。固定選択は公開の一覧からindexを
見つけ、規格の選択変数へ制約を付けます。自由な選択は総数だけを確認し、分布や順序を要求しません。
欠落した規格の制御・実行回数APIを呼んだり、別の操作に置き換えたりはしていません。

finish_itemは通常のsequence・sequencer APIへ委譲し、実際のdriver要求へ正の遅延後に完了を通知します。
必須のmethod呼び出しとtransaction IDを、データの転送成功とは別に観測します。成功するhookのケースは
送信時の変更と完了通知後のpost-doを確認します。不正入力ではERRORとmid-do前のreturnを要求し、
fatal後の継続は指定しません。

extensionは共通のbase handleから呼び、型の数値IDや修飾名の表記を指定せず型の同一性を比較します。
instance名と型名は別の概念として扱います。README・用語集・FAQ・既知差分を日英で更新しました。
M1・M2とも目標の棚卸しは未完です。

## M3初回：レジスタモデルの基本（2026-11-01）

第18章に24件を追加し、全613件になりました。M1は229件、M2は360件で、条項ごとの目標は未完のままです。

- fieldを8件：親・配置・volatility、desiredとmirrored、ROへの直接prediction、RO・W1Cのset、
  HARD／SOFTのreset値と、1種類のreset設定の削除です。
- register／blockを8件：byte幅の切り上げと親、LSB順のfield列挙、desiredの分割、
  predictionとresetによる組み立て、更新要否、再帰reset、既定mapとmodel lockです。
- mapを8件：byte／word単位、little／big endianのアドレス配列、local／外部アドレス、
  mapごとの権限、baseの再配置、階層のoffsetと最小bus幅です。

新規20件はVerilator 5.052のseed 1・73で一致しました。4件はseed 1の既知差分です。
lock前のfield名検索とbus幅、物理アドレス変換の転送byte数、階層mapの実効幅と転送byte数で規格の期待値を保持します。
lock前のケースはlock後の正しい検索・幅も観測し、アドレス配列と戻り値の転送幅は別々に確認します。
指紋を照合した既存589件と合算し、全体は560件一致・既知差分53件です。
既知差分は実行時のseed 1差分46件と、seed未実行のAPI欠落7件です。
Ghostの同梱版は各seedで116件一致・497件不一致で、不一致になるテストも同じです。
kirimasimは606件が`uvm_object_wrapper`未実装、7件がAPI欠落でFAILです。

モデル内の操作はDUTの読み書きやresetを行いません。直接のpredictionはaccess policyにかかわらず更新し、
setはpolicyを適用します。物理アドレス配列はデータの下位側から並び、big endianのケースでは数値が降順です。
registerの複数map登録ではmap引数を明示し、ライブラリが公表するmemoryの複数map登録とnull時のmap解決の
差が出る分岐を避けています。deprecated APIとDPIは要求しません。

日英のREADMEをM3開始の状態にし、用語集・FAQにモデル値・mapの単位・今後の転送検査を追記しました。
既知差分の規格に基づく期待値を維持し、ツールの単体テスト、メタデータ、ライブラリの整合性、
実行証拠の指紋、ドキュメントのリンクを確認しました。全件が`spec_check: ai`で、M1・M2・M3とも未完です。

## M3の2回目：memory・prediction・mapの制御（2026-11-01）

24件を追加し、全637件、M3は48件になりました。M1は229件、M2は360件で、3段階とも目標は未完です。

- memoryを8件：寸法と所属map、locationごとのoffset・アドレス、幅の広いbig endianとword単位のlocation、
  再配置、実効access、独立した2つのinterfaceへの登録です。
- fieldのpredictionを8件：RC／RSのread、W1C／W1S／W1T・W0C／W0Sのwrite、
  SOFT／HARD resetをまたぐwrite-onceの保護です。
- mapを8件：register／submapの再配置、既定のSOFT resetと範囲、拒否時のアドレス配列の維持、
  同じアドレスのRO／WO、無効なsubmap、権限の矛盾、mapごとのauto-predict flagです。

新規22件はVerilator 5.052のseed 1・73で一致しました。2件はmemoryの規格に基づく期待値を保持します。
location引数を使わないoffsetと、単一mapのRO制限を反映しない実効accessです。
前者の外部アドレスは正しく進みます。指紋を照合した既存613件と合算し、全体は582件一致・既知差分55件です。
既知差分は実行時のseed 1差分48件と、seed未実行のAPI欠落7件です。
Ghostの同梱版は各seedで134件一致・503件不一致で、不一致になるテストも同じです。
kirimasimは630件が未対応、7件がAPI欠落でFAILです。

Ghostは既存記録から実行ファイルの指紋が変わったため、同梱版の全637件を両seedで再測定しました。
最初の再測定は途中の更新で結果を破棄し、採用する記録は実行ファイルとprofileを非公開の一時コピーに固定しました。
過去の固定版スモークは履歴であり、今回のbuildの固定版測定としては扱いません。
Verilatorとkirimasimは既存記録と互換の実行条件を確認しています。

権限とaccessのケースは、18.6.4.5の非共有memoryのRW権限と、18.6.4.6の実効accessを分けて観測します。
2つのinterfaceのmemory登録は、add_memの引用条項の期待値にエラーなしで一致しました。
この構成だけでは配布物の複数mapの注記や共有mapの階層を解決したとは扱いません。
memoryのmirrorやDUTのデータは使わず、READ／WRITE predictionは観測値を模擬します。
auto-predict flagは実転送時の自動predictionを示しません。再配置の検索はroot baseを0にし、
不正入力では元の重大度と必須の戻り値・出力の維持を観測します。

日英のREADME・用語集・FAQ・既知差分を更新しました。ツールの単体テスト、メタデータ、
固定UVMの整合性、実行証拠の指紋、ドキュメントのリンクを確認しました。
全件がUVM_NO_DPI・spec_check: aiで、deprecated APIを要求しません。M1・M2・M3とも未完です。

## M3の3回目：adapter・predictor・frontdoor（2026-11-01）

24件を追加し、全661件、M3は第18〜19章に72件となりました。M1は229件、M2は360件で、3段階とも未完です。

- TLM adapterを7件と操作記述子の配列を1件：command・address・byte長／enable・生成・応答変換・callback範囲・配列のresizeです。
- predictorを8件：操作情報の公開、RW／RO・RC／W1C、両endianのwordの収集、対象外の観測、転送先と値の変更です。
- frontdoorを8件：read／writeのauto-prediction設定、別のresponse、幅の広いwrite、big endianのread、adapter contextです。

新規22件はVerilator 5.052のseed 1・73で一致しました。転送先変更とbig endianのreadの2件はseed 1の既知差分です。
指紋を照合した既存637件と合算し、全体は604件一致・既知差分57件です。内訳は実行時のseed 1差分50件と、seed未実行のAPI欠落7件です。
Ghostは前回と同じ実行ファイル・profileの固定コピーを使い、合算で各seed 140件一致・521件不一致で、不一致集合も同じです。
kirimasimは新しい固定buildで全件を測定し、修正ケースを再実行して、654件未対応・API欠落7件となりました。

frontdoorは実際のsequencer／driver接続と正の遅延後の完了通知で、テストベンチ内の記憶域を読み書きします。
passive predictorは別に用意した観測値を入力し、RTLやbus monitorをつないだ検査としては扱いません。
TLMは同じbyteを使い、失敗したreadのdataや規定されていない転送順序を指定しません。
big endianのfrontdoor readは標準TLM adapterと同じpayload byteを使って確認します。
virtual overrideの引数名は基底と揃え、extension用tokenは具体クラスを使います。

日英のREADME・用語集・FAQ・既知差分を更新し、activeとpassiveの検査系を分ける図を追加しました。
単体テスト、メタデータ、固定UVM、入力・ランナー・設定の指紋、リンク、図の描画を確認しました。
全件がspec_check: ai・UVM_NO_DPIで、deprecated APIを要求しません。

## M3の4回目：memory転送とregisterのアクセスhook（2026-11-01）

第18章に24件を追加し、全685件、M3は96件（第18章79件・第19章17件）になりました。
M1は229件、M2は360件のままで、3段階とも未完です。

- memoryのfrontdoorを8件：0以外のlocation、別応答、little endianの幅の広いread／write、
  word単位のアドレス、幅をそろえたburst read／write。
- registerを8件：更新不要／必要時のupdate、W1C／W1Sのwrite命令、mirrorの比較と比較無効、
  read／writeのbusエラーを返した後の再試行。
- アクセスhookを8件：pre-writeの値、pre-accessでの中止、post-readの値とpost-accessのstatus、
  register／fieldのpre-read／pre-writeの順序。

20件がVerilator 5.052のseed 1・73で一致します。残る4件はregister／fieldのhook順序と、burstの物理beatのREAD／WRITE種別を
規格の期待値で保持します。固定版UVMはhookを逆順とし、抽象的なburst種別をadapterへ渡すためspecのみです。変更のない256d873時点の661件と合算すると、624件一致、既知差分61件です。
内訳は実行時のseed 1の差分54件と、実行時のseed結果がないAPI欠落7件です。
同じ実行ファイル・profileの固定コピーでGhostは各seedで145件一致・540件不一致（不一致の集合も同じ）、
kirimasimは678件未対応・API欠落7件です。合算前に入力・ランナー・版・設定の指紋を確認しています。

memoryのburstはmemory・bus・配列要素を64 bitにそろえており、狭いmemoryへのpackingや部分beatは検査しません。
失敗したreadのデータと失敗時点のmirrorには期待値を置きません。driverの記憶域はRTLのDUTやUVMのmemory mirrorではありません。
アクセスhookは継承methodのoverrideであり、callback objectの登録は含みません。
追加のmemory／エラー／policy条件やpredictorとの統合は未完です。

日英README、用語集、FAQ、既知差分を更新しました。ツールテスト、metadata、固定ライブラリの整合性、
実行記録の指紋、ローカルリンクを確認しました。全件がspec_check: ai、UVM_NO_DPIで、deprecated APIは要求しません。

## M3の5回目：custom frontdoor・callback・virtual registerの配置（2026-11-01）

24件を追加し、全709件、M3は120件（第18章95件・第19章25件）になりました。
M1は229件、M2は360件のままで、3段階とも未完です。

- custom frontdoorを8件：register／memoryのデータとstatus、unmapped register、
  操作とsequencerのcontext、mapごとのhandlerの置き換え。
- 登録callbackを8件：値とstatusの変更、事前の中止、削除、同じregisterの継承methodとの順序、
  fieldのpost-prediction。
- virtual register／fieldの基礎を8件：親と未実装の状態、静的なpackingと間隔、mapとアドレス、
  fieldの配置・順序・名前検索、実装先memoryの幅に切り上げたbyte幅。

23件がVerilator 5.052のseed 1・73で一致します。残る1件は18.9.1.2.9が定めるmemory幅に切り上げたbyte幅をspecのみで保持します。
変更のない7206861時点の685件と合算すると、647件一致、既知差分62件です。
内訳は実行時のseed 1の差分55件と、実行時のseed結果がないAPI欠落7件です。
同じ実行ファイル・profileの固定コピーでGhostは各seedで149件一致・560件不一致（不一致の集合も同じ）、
kirimasimは702件未対応・API欠落7件です。合算前に入力・ランナー・版・設定の指紋を確認しています。

custom sequenceは本体で記憶域をモデル化し、adapter／driverの経路を使いません。
登録callbackは継承methodとの違いを区別し、1件でbus転送なしにfieldのpredictionを入力します。
virtual registerは静的な配置の問い合わせであり、データ転送、動的な割り当て、予約領域の所有権は検査しません。
日英FAQの表に、memory word単位の間隔と外部アドレスの計算例を追加しました。

日英README、用語集、FAQ、既知差分を更新しました。ツールテスト、metadata、固定ライブラリの整合性、
実行記録の指紋、ローカルリンクを確認しました。全件がspec_check: ai、UVM_NO_DPIで、deprecated APIは要求しません。

## M3の6回目：virtual registerの転送とmemory領域（2026-11-01）

第18章に24件を追加し、全733件、M3は144件（第18章119件・第19章25件）になりました。
M1は229件、M2は360件のままで、3段階とも未完です。

- frontdoorを8件：詰めた／間隔を明示したvirtual配列、fieldの部分writeとlocationをまたぐread、
  狭いbusへ分割する幅の広いmemory、regionの相対read／write、virtual readの失敗と再試行。
- virtual配列の実装を8件：領域の配置、同じ／別memoryへの移動、解放と再利用、静的な実装の解放拒否、
  重複の拒否、memory省略時のresize、regionから所有者の取得。
- memory managerを8件：予約の切り上げ、重複と範囲、個別／全解放、順序を要求しない列挙とreset、
  互換な再設定、有効な開始位置を1つに固定したpolicy。

22件がVerilator 5.052のseed 1・73で一致します。残る2件はmemory引数を省略したresizeと、実装領域からvirtual配列の所有者を返す
規格の結果をspecのみで保持します。変更のない92ee613時点の709件と合算すると、669件一致、既知差分64件です。
内訳は実行時のseed 1の差分57件と、実行時のseed結果がないAPI欠落7件です。
同じ実行ファイル・profileの固定コピーでGhostは各seedで150件一致・583件不一致（不一致の集合も同じ）、
kirimasimは726件未対応・API欠落7件です。合算前に入力・ランナー・版・設定の指紋を確認しています。

転送はadapter・sequencer・正の遅延を持つテストベンチdriverを使い、RTLのDUTやvirtual registerのmirrorは使いません。
失敗したreadのデータには期待値を置きません。動的な解放はvirtual registerを通じて行い、managerからの直接解放への保護と
virtual registerのランダム割り当ては未検証です。列挙のアドレス順を要求せず、再設定は値で確認し、requestのpolicyの開始位置は1つです。
日英FAQに、動的／静的な実装状態を区別する図を追加しました。

日英README、用語集、FAQ、既知差分を更新しました。ツールテスト、metadata、固定ライブラリの整合性、
実行記録の指紋、ローカルリンクと新しい図の描画を確認しました。全件がspec_check: ai、UVM_NO_DPIで、deprecated APIは要求しません。

## ドキュメントの整理（2026-11-01）

日英READMEには現在の対象範囲、前提環境、コマンド、実行結果、未完の作業を記載し、追加作業の経緯はこの履歴に残します。
テストと開発の詳しい手順、現在の記録の測定方法、ソースの出典を、それぞれ対になるガイドへ分けました。
すべてのガイドで英語と日本語の内容を対応させ、用語集の項目順も揃えました。LICENSEの原文は変更せず、全文の非公式な日本語訳を用意しました。
tools/UPSTREAMは、対になる出典ガイドへ両言語で案内します。ドキュメントだけの変更であり、テスト733件、
oracle付き669件、specのみ64件と、測定記録は変わりません。

## M3の7回目：割り当て・virtual callback・ユーザー定義backdoor（2026-11-01）

24件を追加し、全757件、M3は168件（第18章135件・第19章33件）になりました。
M1は229件、M2は360件のままで、3段階とも未完です。

- virtual配列の割り当てを8件：指定policy、領域と配列の配置・アドレス、解放と再利用、同じ／別memoryへの移動、
  矛盾policyと静的な実装の拒否、幅の広いmemoryの単位。
- virtual callbackを8件：registerの値とstatus、field範囲の変更、親経由のwrite-hook順序とfield単独のpost-write順序。
- ユーザー定義backdoorを8件：rawなpoke／peek、RO／W1CのwriteとRCのreadの効果、memoryのlocation、
  blockとローカルhandlerの優先、失敗と再試行。

22件がVerilator 5.052のseed 1・73で一致します。field単独のpost-writeは規格の`cM`をspecのみで保持し、
固定版は`Mc`になります。親の操作経由の比較対象は一致します。
RCのユーザー定義backdoorも自動予測を明示し、read後のミラー値0を保持します。
固定版は記憶域をclearしますがsampleした値をミラーに記録します。ac008b6時点の互換な既存733件と新規測定を合算すると、
691件一致、既知差分66件（実行時のseed 1の差分59件、実行時のseed結果がないAPI欠落7件）です。
同じ固定コピーで本プロジェクトのゲストGhostは各seedで150件一致・607件不一致（不一致の集合も同じ）、
kirimasimは750件未対応・API欠落7件です。入力・ランナー・版・configurationの指紋を確認します。

割り当てpolicyは有効な開始位置を1つとし、制御した受け渡しを検査して統計的な割り当て動作は確認しません。
ユーザー定義backdoorは必須のpre／post helperを呼ぶ記憶域モデルで、UVM_NO_DPIを保持します。
vendor backendやHDL pathは使わず、失敗したreadのデータは規定しません。

投稿方針と日英Issueフォームはkirimasim-testsを踏襲し、商用製品の実行・比較、第三者の出力・診断や匿名化した要約の流用を除外します。
フォームに必須の確認欄を設け、一般投稿者の空欄Issueを無効にしますが、内容の自動検査ではありません。
ゲストGhostの公開とプライバシーは商用製品の結果とは別の枠であり、仮名による投稿の迂回は認めません。

READMEは現在の状態に限定し、実行結果、テストのガイド、FAQ、用語集、既知差分、出典、この履歴を日英で更新しました。
ツールテスト、metadata、ライブラリ整合性、実行記録の指紋、日英の構造、リンク、IssueフォームのYAMLを確認しました。
商用シミュレータの結果は利用していません。全件がspec_check: aiで、deprecated APIを要求しません。

## M3の8回目：付録Eのregister／memoryテストsequence（2026-11-01）

新しいディレクトリへ付録Eの最初の24件を追加し、M3は192件、全781件・15の章／付録ディレクトリになりました。
第18章135件・第19章33件は変わらず、付録Eが24件です。M1は229件、M2は360件で、各段階の目標は未達です。

hardware resetの比較、bit bash、register access、memory walkを6件ずつ追加し、単独／blockのsequence、
map、階層、除外resourceの選んだ条件を検査します。register accessはcustom frontdoorとユーザー定義backdoorで
記憶域を共有し、ほかの系統はcustom frontdoorを使います。正の遅延で実行し、RTL・HDL path・DPI・vendor backendは使いません。
resetの記憶域は開始前に初期化し、物理的なDUTのreset動作は未検証です。
期待値は転送の有無、データの整合、故障の検出を規定し、内部パターン・順序・診断文は規定しません。

データの故障は正常実行を先に確認してから入れ、reset値の誤り、registerのstuck bit、経路間の不一致、
memoryのstuck bitを検査します。完全一致のscopeの除外には、別の要素や直接選んだ対象による比較を含めます。
故障や直接の比較対象を観測する前にカウンタを初期化します。
block指定のmemory-walkの除外はspecのみで保持します。E.6.2はNO_MEM_WALK_TESTを指定しますが、
固定版のwrapperはNO_MEM_ACCESS_TESTを調べるためです。直接のsingle-memoryの比較対象は動作します。

新規23件がVerilator 5.052のseed 1・73で一致します。4c7f452時点の互換な既存757件と最終入力での新規測定を合算し、
714件一致・既知差分67件（実行時のseed 1の差分60件、実行時のseed結果がないAPI欠落7件）です。
同じ固定コピーでゲストGhostは各seedで152件一致・629件不一致（不一致の集合も同じ）、
kirimasimは774件未対応・API欠落7件です。付録Eのゲストの一致2件は転送なしのskipを観測するケースです。現在の入力・ランナー・版・configurationの指紋を確認しました。

READMEは現在の範囲に限定し、実行結果、テストのガイド、FAQ、用語集、既知差分、この履歴を日英で更新しました。
FAQにはsequenceの系統と観測の対応表を追加しました。ツールテスト、metadata、固定ライブラリの整合、
日英の構造、ローカルリンク、公開内容のプライバシー、staged差分の空白を確認しました。
商用シミュレータの結果は利用していません。全件がspec_check: ai・UVM_NO_DPIで、deprecated APIを要求しません。

## M3の9回目：memory・shared accessとテストの選択（2026-11-01）

付録Eへ24件を追加し、M3は216件、全805件・15の章／付録ディレクトリになりました。
第18章135件・第19章33件は変わらず、付録Eは48件です。M1は229件、M2は360件で、各段階の目標は未達です。

memoryのfrontdoor／backdoor access、shared register、shared memory、dispatcherの選択を6件ずつ追加しました。
4 location、2／3 mapと方向を持つ書き込み元・読み手の観測、階層、完全一致のscopeの除外、
正常な比較の後のread値の故障を検査します。観測区間の間でカウンタ・mask・最後の書き込み元を初期化し、
共有する記憶域は変えません。乱数payloadや内部のアクセス順序・件数はoracleへ出力しません。
RTL・HDL DPI・vendor backendは使いません。

dispatcherは規格のvirtualな基底classを拡張し、全選択を実行せずに既定の64 bitの全テストmaskを検査します。
0による選択とresetの比較対象、reset／register access／memory accessの個別flag、
bit-bash／memory walkのORと17.2.2.10の実行順序も確認します。統合access wrapperとHDL pathのsequenceは未検証です。

新規23件がVerilator 5.052のseed 1・73で一致します。1件はE.5.1のNO_MEM_SHARED_ACCESS_TESTによる除外を
specのみで保持します。固定版はNO_MEM_ACCESS_TESTを調べるためです。別scopeのmemoryは成功する比較対象です。
c253fc9時点の互換な既存781件と最終入力の新規測定を合算し、737件一致・既知差分68件
（実行時のseed 1の差分61件、実行時のseed結果がないAPI欠落7件）です。
同じ固定コピーでゲストGhostは各seedで153件一致・652件不一致（不一致の集合も同じ）、
kirimasimは798件未対応・API欠落7件です。ゲストの付録Eの一致はskipの条件だけを対象にします。
現在の入力・ランナー・版・configurationの指紋を確認しました。

README・実行結果・FAQ・用語集・既知差分・履歴を日英で更新しました。FAQの表は選んだ8区分を説明し、
未検証範囲とゲストの測定範囲も明示します。ツールテスト41件、metadata 805件、固定ライブラリの整合、
日英の構造、ローカルリンク、既存履歴の保持、公開内容のプライバシー、staged差分の空白を確認しました。
商用シミュレータの結果は利用していません。全件がspec_check: ai・UVM_NO_DPIで、deprecated APIを要求しません。

## M4の最初の追加

以下は以前の台帳形式を記録した履歴であり、現在使うschemaと更新規則は[版管理するデータのガイド](requirements.ja.md#版管理するデータと生成する棚卸し)で確認できます。

[要求台帳](requirements.ja.md)を開始し、M1〜M3の目標はいずれも未完のままにします。
変更していない全805テストと既存の条項番号2,504件を索引化します。
root 5〜19／B〜Gを対象候補（2,479番号）、1〜4を文脈（16）、非推奨の付録Hを保留（9）とする案を作成します。
対象範囲の案であり、分母の承認ではありません。規範的義務の分解は未完で、割合は公開しません。

基本UVM、reporting、factory、phase、objection、configuration、policy、callback、TLM、
sequence／sequencer、register model、付録Eから、独自の日英要約でAIによる義務の案36件を追加します。
database、pool、agent、HDL deposit、string split、command-line引数の未対応候補も含めます。
30要求を既存テストへ直接対応付け、別の親virtual registerのテスト1件をcontrolにし、774テストは要求未対応とします。
条項番号35件が部分的な分解、2,469件が未評価です。人による照合や完了の記録は付けません。

棚卸しでは主引用の番号356件と、UVMの引用がある番号814件を区別します。
候補番号の主引用は0件が2,123、1件が157、2件以上が199です。配置の件数であり、規範的要求の分母や十分性の判断ではありません。
明示した期待値のanchorは実行成功ではなく、直接の対応先にも既知差分を保持します。

検査、棚卸し、索引案のコマンドを追加します。不正／片言語のデータ、ID／keyの重複、未知の参照、期待行の欠落、
古い入力指紋、未対応の承認の主張を拒否します。syncは再照合まで対応済みの指紋を保持し、controlを区別して、生成物による正本の上書きを防ぎます。
CIに台帳の検査を加え、日英のガイド、FAQ、用語集を更新します。

ツール単体テスト61件、metadata 805件、36件の台帳、固定ライブラリの整合性の検査が成功しました。
日英の構造、ローカルリンク、履歴の保持、ライセンス原文、非公開情報、空白を検査します。
既存805件の入力／runner指紋は、記録済みのVerilator、kirimasim、guestの証拠と引き続き一致します。
シミュレーションsource、期待値、runner、ライブラリlockは変更せず、新たなシミュレーションや商用の結果は使いません。

## M4の2回目

独自の日英の要約によるAIの義務案139件を加え、台帳を175件にします。
163要求を異なる190テストへ直接対応付け、直接未対応の要求は12件、別のcontrolテストは1件、
要求との対応がないテストは614件です。最初の36件の識別子と文面は保持します。
範囲は提案、規範的義務の棚卸しは未完で、条項番号115件が部分的な分解、2,389件が未評価です。
分母、割合、人による照合、段階の完了は主張しません。

第5章42件、付録B 54件、付録C 16件、付録D 6件、付録E 48件の既存主引用テストをすべて対応付けます。
objectのlifecycleの時刻／event、不正なfield operationのaccessor、callbackの走査操作を別の義務に分解します。
条件が異なる場合は複数構成を用い、1テストに複数の独立した義務を対応付けることも可能にします。
除外resourceの実際の名前とelement／block scopeを区別します。
既知のライブラリ差分の期待値と、B.5.11の呼出しの矛盾に対する解釈をレビュー用に保持します。

付録Eの新しい6義務、register-accessのblock除外、統合access wrapper、HDL-pathの利用可否、
walking-ones algorithm、2つの未知policyのskipは未対応とします。
既存location maskは必要なアクセス特性だけに対応付け、algorithm全体の検査へ昇格しません。
未対応テストの一覧が空でも、要求分解の完了にはしません。

root別集計と、正確なrootで絞れるbacklogコマンドを追加します。
直接未対応の要求、どちらの役割の対応もないテスト、未評価の番号を分け、文脈／保留の範囲も残します。
要求は自身の条項、テストは主引用のrootに割り当て、第17章から付録Eへの対応も扱います。
filter前に台帳全体を検査し、生成先を保護します。
この区別の回帰検査8件を追加し、日英のガイドを更新します。

単体テスト69件、metadata 805件、台帳175件、固定ライブラリの整合性の検査が成功しました。
全体／root別の生成物、rootと全体の集計、ローカルリンク、日英の構造、履歴、非公開情報を検査します。
シミュレーション入力、runner、期待値、lockは変更せず、記録済みのVerilator、kirimasim、guestの
入力／runner指紋は全805件で引き続き一致します。新たなシミュレーションや商用の結果は使いません。

## M4の3回目

reporting、factory、phase、objection／callback、policyに、独自の日英の要約によるAIの要求案180件を追加します。
台帳は355件で、331要求を374テストへ直接対応付け、直接未対応は24要求、別のcontrolは1テスト、
どちらの役割の対応もないテストは430件です。部分的に分解した条項番号は257件、未評価は2,247件になります。
範囲と分母は未承認で、全要求の照合はAIのみのままです。

以前の5つのrootに加え、第6章28件、第8章32件、第9章19件、第10章36件、第16章80件の既存主引用テストをすべて対応付けます。
既存のcallback-mode要求の条件／期待値を整理し、範囲外の引数の構成を追加して、同じ契約の重複登録を避けます。
他の既存174件は変更しません。rootをまたぐ対応では、print／sprintの要求を第5章、継承を付録B、
phaseのretry動作を第13章に割り当て、テストの主引用は変更しません。

設定値の証拠と実動作を分けます。報告統計のmerge、quit終了、ready-to-end上限の強制、dropped callbackなしのclear、
nullのactive-object push、object側のactive-policy同期、comparerのmessage上限、reference modeのcopy error、
配列／名前の出力制御、整数の上限超過拒否を、新しい未対応12義務とします。
getterの値、1回のretry、境界値の成功、policy側stackだけでは、それらを主張しません。
readyのdefault accessorの表記の矛盾は、レビューが必要な解釈として明示します。
quit actionの表記も宣言されたUVM_COUNTとroot終了の条項を照合し、未定義のactionは導入しません。
同じ期待行はanchorに1回だけ登録し、runnerは引き続き全行の並びを検査します。

生成inventory／backlogのJSONにledger_inputs_sha256を加えます。
既存のテスト指紋を含むscope／ledger／indexの正規化objectとcatalogの識別値をhash化します。
全体／filterの表示は同じ入力識別値を共有し、書式、日本語のescape、リポジトリの配置先では変わりません。
意味の変更、照合／対応、確認済みsnapshotの変更では変わります。
この識別値はカバレッジや実行成功を承認せず、実行の証拠とは別です。

新しい識別値の回帰検査5件を含む単体テスト74件、metadata 805件、台帳355件、固定ライブラリの整合性の検査が成功しました。
rootと全体の一覧、生成した識別値、日英の構造、ローカルリンク、履歴、非公開情報、空白を確認します。
805件のシミュレーション入力、期待値、runner、lockは変更せず、記録済みのVerilator、kirimasim、guestの
入力／runner指紋は引き続き一致します。シミュレータの再実行や商用の結果は使いません。
README、対になるガイド、FAQ、用語集をこの状態へ更新します。

## M1〜M4の薄い領域の拡充

要求案に直接のテストがなかった箇所や、実行条件の検査が薄い箇所へ20検査系を追加します。
M1はdatabaseの接続hook、異なるpool keyの件数、agentの状態、文字列の分割、command-lineのsuffix照会の10件で、
章・付録7・11・13・F・Gのディレクトリを新設します。M2は成立済みのlock／grab待機者の停止、
別待機者の生存、新しい転送の完了を調べる4件です。M3はregister／memory accessの統合wrapper、
register-accessのblock除外、登録した独自policyのskipの6件です。段階別の件数はM1が239、M2が364、M3が222となり、
20ディレクトリにシミュレーション825件があります。

期待値を対応付ける前に該当する規格条項を再確認します。databaseは接続hookを制御し、streamや実backendは使いません。
空の文字列fieldは区切りの境界を保持し、引数は順序を固定せずsuffixの所属を比較します。所有権待機の検査は、
正の遅延、公開の状態、実driver転送を使い、非公開queueを読みません。統合accessはchild階層を含む
frontdoor／user-backdoorの共有記憶域を使い、乱数dataの正確な値の代わりにlocation maskを検査します。
skip検査では観測区間を初期化し、独立した対象が動作することも確認します。

新規20件と選択した既存FIFO 24件を要求へ対応付け、既存のうち23件は初めての対応です。要求案を21件追加し、
直接未対応だった9要求にもテストを付けます。台帳はAIの376要求案で、直接対応する要求361件・テスト417件、
直接未対応の要求15件、別のcontrol 1テスト、どちらの対応もない407テストになります。
catalogの部分分解は274番号、未評価は2,230番号、主引用ありは363番号、いずれかの引用ありは840番号です。
候補の主引用は0件が2,116番号、1件が159番号、2件以上が204番号です。索引の既存805件を保持し、
再照合後に新規20件の入力識別値だけを追加します。範囲、棚卸し、M1〜M4は未完で、分母は承認しません。

runnerを変えず、固定したシミュレータのコピーで最終入力を測定します。新規16件がVerilator 5.052のseed 1・73で一致します。
command-line 2件は固定ライブラリのDPIなしの引数列挙が空になるため不一致です。
統合wrapperのblock除外ではmemoryへのアクセスが残り、単独bit bashは登録した独自policyのregisterにもアクセスするため、
両方とも規格のskip期待値を保持します。変更のない
[a7522cc](https://github.com/kurochan001/kirimasim-uvm-tests/commit/a7522cc1345dc80babca37d55c0b255f2df01350)
時点の805件と合算すると753件一致・既知差分72件です。内訳はseed 1での実行時差分65件と、実行seedのないAPI欠落build 7件です。
これらの差分へ期待値を合わせません。

新規分のGhost同梱実行は、各seedで5件一致・15件不一致で、不一致の集合も同じです。合算では158件一致・667件不一致です。
新しい一致はpoolのcount 1件、agent 2件、引数照会2件で、付録Eの新しい転送成功は示しません。
kirimasimは未対応20件を追加し、全体で未対応818件・API欠落の失敗7件です。合算前に入力、runner、設定、
実行ファイル／profileの同一性を確認します。guestの識別情報と生の診断は非公開を保ち、商用シミュレータの結果は使いません。

日英の現状資料を更新し、FAQと用語を4件ずつ追加して84問・96語とし、従来の履歴を保持します。
ツール単体テスト74件、metadata 825件、要求台帳376件、固定ライブラリ、日英の構造、local link、
ライセンス原文、実行記録の指紋、空白を検査します。

## M1〜M4の薄い領域の2回目の拡充

シミュレーション20件を追加します。M1はreport-server統計の累積merge、dropped callbackを呼ばないobjection clear、
active objectのnull push、reference modeのcopy error、整数packの上限超過errorの10件です。
M2は2状態値／object handleによる、取得不可のFIFO get／peekの出力保持4件、M3はsub-byte／byte整列のmemory端数転送と
失敗／再試行statusの6件です。段階別にM1が249、M2が368、M3が228、同じ20ディレクトリに845件となります。

各negative契約に、独立した動作する比較対象を用意します。serverはglobalを置き換えず、公開message実行と明示したseverity setterで準備します。
clearはmethodと登録callbackの両probeを、正の遅延と通常の部分dropで確認します。null pushはstackの深さ、top、実popを観測します。
不正copyの引数／結果、不正packの状態は調べず、新object／policyで正常なdeep-copy／64-bit境界を確認します。
診断ID／文面、未定義の復旧動作は制約しません。

FIFOは規格の出力保持の事後条件を維持し、宣言するoutput formalとSystemVerilog 13.5のreturn時の代入との食い違いを、
signature／本文の解釈の論点とします。成功するget／peekで配送と占有数も検査します。8-bit busの20-bit memoryでは、
address／方向／dataの観測をlogical bit幅8・8・4の期待値から分け、固定版は8・8・8を返します。
sub-byteの解釈は要レビューとして残し、ライブラリの確定した不具合とは断定しません。
16-bit busの24-bit比較対象は、byteに整列する幅16・8を期待し再現します。公開address一覧で記憶域を準備し、
変換を独立に証明するものではありません。上位padding、失敗readのdata、一般のburst配列packingは制約せず、または未評価です。

新規20件と、以前は要求未対応だったregister／memory、virtual register／field、custom frontdoorの34検査系を対応付けます。
要求案を30件追加し、以前は直接未対応だった5要求にもテストを付けます。台帳はAIの406要求案で、直接対応する要求396件・テスト471件、
直接未対応10要求、別のcontrol 1テスト、どちらの対応もない373テストです。部分分解は292番号、未評価は2,212番号、
主引用ありは363番号、いずれかの引用ありは843番号です。候補の主引用は0件が2,116番号、1件が156番号、2件以上が207番号です。
段階、規範的棚卸し、照合目標、範囲、分母の完了／承認は宣言しません。

既存read 3検査系の主引用と説明がwrite条項だったため訂正します。本体と期待出力は変えず、索引を再照合して両seedで再実行します。
他の既存822件の入力snapshotを保持します。[2100ad5](https://github.com/kurochan001/kirimasim-uvm-tests/commit/2100ad5315fe595c262be4f8040912cef82ebd55)
時点の変更のない記録と、新規20件・引用訂正3件の最終入力の測定を、変更のないrunnerと固定した実行ファイル／profileで合算します。

新規12件がVerilator 5.052のseed 1・73で一致します。既知差分は8件で、整数packの上限超過で必要なerrorがない2件、
FIFO出力のsignature／本文の食い違い4件、sub-byteのlogical幅の解釈2件です。24-bit比較対象は一致します。
既存分を含め765件一致・既知差分80件で、seed 1の実行時差分73件、実行seedのないAPI欠落build 7件です。
規格／明示してレビュー対象とした解釈の期待値をbackend出力へ置き換えません。

新規Ghost同梱実行は、各seedでFIFOのsentinel 4件が一致し、他の16件は不一致で、その集合も同じです。
引用訂正3件は従来の2件一致・1件不一致を保ちます。合算は162件一致・683件不一致で、原因の割当、固定ライブラリ、
付録Eの新しい転送成功は示しません。kirimasimは未対応20件を加え、未対応838件・API欠落の失敗7件です。
guestの識別情報と生の診断は非公開とし、商用の結果は使いません。

日英の現状資料を更新し、以前の履歴をすべて保持します。FAQと用語を3件ずつ追加し、87問・99語にします。
ツール単体テスト74件、metadata 845件、台帳406件、ライブラリ、local link 609件、日英の構造、ライセンス原文、
空白、現在の入力／runner／設定の指紋を検査してから実行記録を合算します。

## M1〜M4の薄い領域の3回目の拡充

20件を追加します。M1はprinterのfield／配列の出力、比較message上限、overrideなしのfactory照会、有限quit上限、
実際のready反復上限の12件です。M2は特定ID／空／重複IDの応答取得と実行中sequenceのroute分離4件、
M3は広幅registerの交互のpredictionとwrite／read byte enableの4件です。M1が261、M2が372、M3が232、
20ディレクトリにシミュレーション865件となります。

printerの所属検査は組み込みtable／line出力、実field-macro配列、固有値、再利用の比較対象を使います。
有限windowの中央省略は任意のままです。比較probeはfieldを短絡せず、hook内の個別reportだけを数えて、後の集約報告を除きます。
全不一致の結果を保ち、上限5の比較対象でreport経路を確認します。factoryはobject／componentのwrapperを通常の実生成と比較します。
overrideなしの名前照会とcomparer上限0は、規格の期待値を維持します。

quit上限はUVM_COUNT、実pre_abortの走査、後の時刻へ継続しない遅延guardを使い、終了要求後の同一評価内の順序は指定しません。
未宣言のUVM_QUITという表記はF.2.2.2／F.7.3.2で解釈します。component hookの実際の条項は13.1.4.6で、
F.7.3.2の印刷上の参照13.1.4.1.6とは区別します。ready callbackは常にraise／遅延dropを対応させ、上限がなければ反復を再起動します。
設定した2／3で実callback数を制限してphase_endedへ進み、永久にdropしないobjectionや兄弟phaseの条件は未評価とします。

応答は正の遅延で待機を成立させ、実際にacknowledgeしたrequestからrouting IDを両方copyします。
不一致到着は特定IDの待機を完了せず、同じIDの一致同士は順序を固定せず所属を確認します。空の待機は取得後も再び成立させます。
実行中の2 sequenceでtransaction IDが同じでも別々に配送します。predictorはlittle／big-endian mapの広幅register 2つを交互に観測し、
address到着順を逆にする条件も使いますが、非公開の待機mapは読みません。byteに整列する2 fieldを、active predictionを無効にして、
RW write／RO readの下位／上位／全無効laneで検査します。未完了検出の診断、field内のmask、RTL timing、全protocol／policy組合せは未完です。

31要求案を追加し、新規20件と、第19章に残っていた既存未対応23件を対応付け、以前は未対応だった基本APIの6要求にも直接linkを付けます。
台帳はAIの437要求案で、直接対応する要求433件・テスト514件、直接未対応4要求、別のcontrol 1テスト、どちらの対応もない350テストです。
第19章の主引用37テストはすべて対応がありますが、分解は部分的なままです。value配列の既定size／prefix／拡張時0、
adapterのcontext／変換、prediction／通知、backdoorのアクセス／policyを明示した観測へ対応付けます。

catalogは部分分解305番号、未評価2,199番号、主引用あり365番号、いずれかの引用あり853番号です。
候補の主引用は0件が2,114番号、1件が156番号、2件以上が209番号です。既存の全テスト／索引snapshot、runner、library lockを保持します。
object側のpolicy同期、HDL deposit、HDL-pathの利用可否、memory-walk algorithm全体は直接未対応のままです。
範囲、分母、規範的な棚卸し、各段階の目標は未完／未承認とします。

新規の最終入力17件がVerilator 5.052のseed 1・73で一致し、overrideなしの名前照会2件とcomparer上限0の3件は既知差分を保持します。
backendの出力から期待値をコピーしません。変更のない
[9112476](https://github.com/kurochan001/kirimasim-uvm-tests/commit/91124768db9f537c763d1ca67afc88feec66f65b)
時点の845件と合算すると782件一致・既知差分83件です。内訳はseed 1の実行時76件、実行seedのないAPI欠落build 7件です。
互換な記録の合算であり、全件を単一の実行で再測定したという主張ではありません。

新規Ghost同梱実行は、各seedでoverrideなしの照会2件と重複ID応答の所属1件が一致し、他の17件は不一致で、その集合も同じです。
合算は165件一致・700件不一致です。kirimasimは未対応20件を加え、未対応858件・API欠落の失敗7件です。
合算前に実行ファイル／profile／設定と、現在の入力／runnerの同一性を確認します。guestの識別情報と生の診断は非公開を保ち、商用の結果は使いません。

日英の資料を更新し、FAQ／用語を4件ずつ追加して91問・103語とし、以前の履歴をすべて保持します。
ツール単体テスト74件、metadata 865件、台帳437件、固定ライブラリ、日英の構造、local link、ライセンス原文、
空白、現在の実行記録の指紋を検査します。

## M1〜M4の薄い領域の4回目の拡充

[b77962b](https://github.com/kurochan001/kirimasim-uvm-tests/commit/b77962bb48072147a5b196e5afbf3401538cc1d8)の865件に
シミュレーション20件を追加し、計885件（M1 271件、M2 376件、M3 238件）にしました。
以前のテスト入力はすべて保ちます。M1はpool／queueの走査の端点／cursor、global共有、挿入境界、
空のpop、繰り返し待機の10検査系を追加しました。M2は待機producerとflush、2 consumer、
2 peeker、analysis FIFOの独立した再開の4検査系を追加しました。
M3はmemory hookでのdata／offset／map変更、中止／retry、post-readの合成、
post-writeの順序／statusの6検査系を追加しました。

固定UVMとVerilator 5.052では、新規16件がseed 1・73で一致しました。空queueの先頭／末尾popのwarning、
memoryのpre-readのmap変更、memoryのpost-write callback順序の4件は、規格の期待値をspec-onlyで保ちます。
互換性を確認した全体記録は798件一致、87件の既知差分です。実行時80件はseed 1で最初に差分が出て、
API欠落によるbuild失敗7件には実行seedの結果がありません。
Ghostの同梱UVMは、新規5件一致／15件差分で、全体は各seedで170件一致／715件差分となり、失敗集合は同じです。
kirimasimは追加20件とも未対応で、全体は未対応878件とAPI欠落による失敗7件です。
実行ファイル／profileのsnapshotとrunner／libraryの指紋は互換性を保ち、Ghostの固定UVM modeの新しい結果は主張しません。

M4はAI要求案53件を追加し、新規20検査系と既存のmemory／register-map照会21検査系を対応付けました。
台帳は490要求案、直接対応は486要求／555テスト、追加control 1件、未対応テスト329件です。
条項番号2,504件のうち、354件は一部分解し、2,150件は未評価です。
主引用の番号は381件、引用全体では874件です。対象候補2,479番号の主引用の棚卸しは、0件2,098番号、
1件170番号、2件以上211番号です。直接未対応の要求案4件は残ります。
範囲は提案のままで、人による照合、分母の承認、適合率は示しません。

既存入力の全指紋、runner／tool／libraryの入力、以前の履歴を保ちます。
toolの単体テスト74件、metadata 885件、台帳／索引の整合性、現行入力への測定の結合、
完全な英日ガイドを検査します。用語集は107項目、FAQは94問です。
READMEには現状を記載し、この節には今回の拡充分を残します。

## M1〜M4の薄い領域の5回目の拡充

[631c6a4](https://github.com/kurochan001/kirimasim-uvm-tests/commit/631c6a43977444e741ddb38ed17e8cbd515c3bc4)の885件に
シミュレーション20件を追加し、計905件（M1 279件、M2 380件、M3 246件）にしました。
既存テストの全入力を保ちます。M1はevent／barrierの8件で、持続するon／off状態、新しいtriggerと同sliceのtrigger data、
既定data、thresholdの各round、auto-reset、thresholdの引下げ、reset後の再利用を扱います。
M2はTLM 2 socketの時刻を隔てた4履歴で、4 phase、返すphaseの変更、backward完了と再利用、
未完了の2 contextの逆順応答を扱います。M3は追加の9 field policyに対する8予測履歴で、
相補的な0を選ぶwrite／read副作用と、隣接fieldの比較対象を含めます。

固定UVMとVerilator 5.052では、追加20件すべてがseed 1・73で一致しました。
互換性を確認した全体記録は818件一致と、変化のない既知差分87件です。実行時80件はseed 1で最初に差分が出て、
API欠落によるbuild失敗7件には実行seedの結果がありません。
Ghostの同梱UVMは、新規12件一致／8件差分で、全体は各seedで182件一致／723件失敗となり、失敗集合は同じです。
kirimasimは新規20件とも未対応で、全体は未対応898件とAPI欠落による失敗7件です。
実行ファイル／profileのsnapshotとlibrary／runnerの識別値は互換性を保ち、Ghostの固定UVM modeの結果は追加しません。

M4はAI要求案53件を追加し、新規20件と既存の第14章の20検査系を対応付けました。
台帳は543要求案、直接対応は539要求／595テスト、追加control 1件、未対応テスト309件です。
条項番号は386件が一部分解、2,118件が未評価で、主引用389番号、引用全体892番号です。
対象候補2,479番号の主引用の棚卸しは、0件2,090番号、1件176番号、2件以上213番号です。
直接未対応の要求案4件は残ります。範囲は提案のまま、照合はAIのみで、分母と割合は未承認です。

toolの単体テスト74件、metadata 905件、正本の台帳／索引の整合性、最終入力の実行指紋、
完全な英日ガイドを検査します。用語集は111項目、FAQは97問となり、対の4-phase図も追加しました。
制御getterと未検査の副作用、明示predictionと物理trafficを区別します。
READMEには現状を保ち、この節には今回の拡充分を記録します。

## M1〜M4の薄い領域の6回目の拡充

[8437db3](https://github.com/kurochan001/kirimasim-uvm-tests/commit/8437db393929aaa45d80a74f5021f68e1e8a1d0b)の905件に
シミュレーション20件を追加し、21ディレクトリに計925件（M1 287件、M2 384件、M3 254件）にしました。
既存テストの全入力を保ちます。M1はcomponent階層の8件で、親、名前／depth、子queue、直接の所属、cursor境界、lookupを扱います。
M2はindex付きTLM 1転送の4件で、親portのfanoutも含めます。M3はsymbolicなHDL記述の8件で、
標準concat APIの2件と、kind／既定／block pathの6件です。第17章には初めて主引用の2検査系を追加し、
HDLやDPIのアクセスは試みません。

固定UVMとVerilator 5.052では、新規17件がseed 1・73で一致しました。concat APIの2検査系はビルドできず、
blockの既定の継承1件はseed 1で実行時の差分を保ちます。互換性を確認した全体記録は835件一致と既知差分90件で、
実行時81件はseed 1で最初に差分が出て、API欠落のbuild失敗9件には実行seedの結果がありません。
Ghostの同梱UVMは、新規6件一致／14件差分で、全体は各seedで188件一致／737件失敗となり、失敗集合は同じです。
kirimasimは新規18件が未対応、2件がAPI欠落で失敗し、全体は未対応916件、失敗9件です。
runner、実行ファイル／profile、libraryの識別値は互換性を保ち、Ghostの固定版modeの測定は追加しません。

M4はAI要求案61件を追加し、新規20件と既存のpayload／extension 21検査系を対応付けました。
台帳は604要求案、直接対応600要求／636テスト、追加control 1件、未対応テスト288件です。
条項番号2,504件のうち、438件は一部分解、2,066件は未評価で、主引用402番号、引用全体931番号です。
対象候補2,479番号の主引用の棚卸しは、0件2,077番号、1件186番号、2件以上216番号です。
直接未対応の要求案4件は残ります。範囲は提案、人による照合はなく、分母と割合は未承認です。

toolの単体テスト74件、metadata 925件、台帳／索引の整合性、最終入力への測定の結合、完全な英日ガイドを検査します。
用語集は115項目、FAQは100問となり、親portのfanout図も追加しました。symbolicなHDL pathとbackendの利用可否、
payload／制御の状態とtargetの実行を区別します。READMEには現状を保ち、この節に今回の追加分を記録します。

## M1〜M4の薄い領域の7回目の拡充

[b392959](https://github.com/kurochan001/kirimasim-uvm-tests/commit/b392959c512df803680f5b2030d6d78ca0f97956)の925件へ
シミュレーション20件を追加し、21ディレクトリに計945件（M1 295件、M2 388件、M3 262件）にしました。
既存925件の全入力を保ちます。M1は、型付きevent callback、wakeup reset、killしたwaiterの取消、
専用event／barrier poolの8件です。M2は、重なる呼出し、独立socket channel、error／再利用、
入れ子のexportを通す独自transactionの、blocking TLM 2の4件です。M3は、親handle、local／再帰的な所属、
単純名の検索を照会するregister modelの8件で、入れ子のregfileの配置も含めます。

追加17件がVerilator 5.052のseed 1・73で一致しました。3件はseed 1で実行時の差分を保持し、
無効callbackのdispatch、wakeup reset、blockのregister名検索を扱います。resetのsimulator／libraryの原因は未確定です。
通常のlock後のregister検索は対照として動作し、入れ子のregfileの検索は差分が残ります。
互換性を確認した全体記録は852件一致と既知差分93件で、実行時の最初の差分84件、実行seedのないAPI欠落build 9件です。
Ghostの同梱UVMは、各seedで新規5件一致／15件差分、全体193件一致／752件失敗で、失敗集合は同じです。
kirimasimは、新規20件がすべて未対応で、全体は未対応936件、API欠落の失敗9件です。
最終測定はvirtual callbackの引数名を修正した後に行い、置換済み入力の記録は使いません。
runner／実行ファイル／profile／libraryの識別値は互換性を保ち、Ghostの固定版modeの主張は追加しません。

M4はAI要求案47件を追加し、新規20件と既存のsequencer制御・履歴・pull／push転送の20検査系を対応付けました。
台帳は651要求案、直接対応647要求／676テスト、追加control 1件、未対応テスト268件です。
条項番号2,504件のうち、480件は一部分解、2,024件は未評価で、主引用417番号、引用全体954番号です。
対象候補2,479番号の主引用の棚卸しは、0件2,062番号、1件201番号、2件以上216番号です。
直接未対応の要求案4件は残り、第15章には未対応の主引用検査系56件、未評価の番号64件が残ります。
照合はすべてAI、範囲は提案、分母／割合は未設定です。

toolの単体テスト74件、全945件のmetadata、台帳／索引の整合性、最終入力の測定fingerprint、完全な英日ガイドを検査します。
用語集は119項目、FAQは103問です。callbackの有効状態、reset wakeup、取消の計数、endpointで定義するblocking動作、
modelだけの照会を、より広いcoverageと区別します。READMEは現状を記述し、今回の履歴はここに保持します。

## M1〜M4の薄い領域の8回目の拡充

[888203c](https://github.com/kurochan001/kirimasim-uvm-tests/commit/888203cdc404b75cc7a64abdf6cd004558da5894)の945件に
シミュレーション20件を追加し、21ディレクトリに計965件（M1 303件、M2 392件、M3 270件）にしました。
既存945件の全入力を保持します。M1は、local hookを使う記録stream／linkの8件で、lifecycle、metadata、列挙、
handle、warning、endpoint dispatchを扱います。M2は、request／responseの方向別blockingの4件です。
M3は、fieldのaccess、compare／volatility、reset metadata／状態、最大幅の8件で、物理resetやbus転送は行いません。

追加17件がVerilator 5.052のseed 1・73で一致し、3件はseed 1で実行時の差分を保持します。
暗黙のdatabase open、stream数の戻り、初期化前のwarningを扱います。stream数の検査は、queue数の本文と
1-bit unsignedのsignatureの解釈が要レビューであり、確認済みlibrary／simulator不具合ではありません。
互換性を確認した全体記録は869件一致と既知差分96件で、実行時の最初の差分87件、実行seedのないAPI欠落build 9件です。
Ghostの同梱UVMは、各seedで196件一致／769件失敗となり、失敗集合は同じです。
kirimasimは未対応956件、API欠落の失敗9件です。link検査系を具体endpoint subtypeへ修正した後の最終入力に測定を結び付け、
runner／実行ファイル／profile／libraryの識別値はすべて互換性を保ちます。Ghostの現在の固定版modeの主張は追加しません。

M4はAI要求案54件を追加し、新規20件と既存のTLM 1 analysis・接続port・分離imp・channelの20検査系を対応付けました。
台帳は705要求案、直接対応701要求／716テスト、追加control 1件、未対応テスト248件です。
条項番号2,504件のうち、524件は一部分解、1,980件は未評価で、主引用432番号、引用全体985番号です。
対象候補2,479番号の棚卸しは、0件2,047番号、1件212番号、2件以上220番号です。直接未対応の要求案4件は残ります。
範囲は提案、照合はすべてAI、分母／割合は未設定です。

toolの単体テスト74件、全965件のmetadata、台帳／索引の整合性、最終入力の測定fingerprint、完全な英日ガイドを検査します。
用語集は123項目、FAQは106問で、streamのlifecycle図も追加しました。recorder、外部databaseの内容、物理的なfieldへの作用、
並行する応答の照合は検査系の範囲外です。READMEは現状を記述し、今回の追加分はここに保持します。

## M1〜M4の薄い領域の9回目の拡充

[8482f3f](https://github.com/kurochan001/kirimasim-uvm-tests/commit/8482f3f137671d1abbafdceda07f41151c671e8d)の965件に
シミュレーション20件を追加し、21ディレクトリに計985件（M1 311件、M2 396件、M3 278件）にしました。
既存965件の全入力を保持します。M1は、recorderの受理、metadata、close／free／handle、stream連鎖、scalar hookの8件です。
M2は、socketのconstructorと禁止target-connectの4件です。M3は、等幅の間接registerで、選択した転送、再選択、最新index、
独立pair、error／再試行、任意のregfile配置を扱う8件です。記録はlocal、model化したbus storageとpredictionは別で、RTL／DPIは使いません。

追加20件すべてがVerilator 5.052のseed 1・73で一致し、新しいspec-onlyはありません。
互換性を確認した全体記録は889件一致と既知差分96件で、実行時のseed 1で最初の差分87件、実行seedのないAPI欠落build 9件です。
Ghostの同梱UVMは、両seedで新規20件すべてが差分となり、全体は196件一致／789件失敗で、失敗集合は同じです。
kirimasimは新規20件すべてが未対応で、全体は未対応976件、API欠落の失敗9件です。
regfile配置の検査系は、必須のnull regfile-parent引数を指定してから最終測定します。
runner／実行ファイル／profile／libraryの識別値はすべて互換性を保ち、Ghostの現在の固定版modeの測定は追加しません。

M4はAI要求案55件を追加し、新規20件と既存のsequencer arbitration・所有権・利用可否の20検査系を対応付けました。
台帳は760要求案、直接対応756要求／756テスト、追加control 1件、未対応テスト228件です。
条項番号2,504件のうち、565件は一部分解、1,939件は未評価で、主引用443番号、引用全体1,020番号です。
対象候補2,479番号の棚卸しは、0件2,036番号、1件220番号、2件以上223番号です。直接未対応の要求案4件は残ります。
範囲は提案のまま、照合はすべてAI、分母／割合は未設定です。

toolの単体テスト74件、全985件のmetadata、台帳／索引の整合性、最終入力の測定fingerprint、完全な英日ガイドを検査します。
用語集は127項目、FAQは109問で、間接access図も追加しました。以前のstreamだけの説明は、別のrecorderの対応範囲と区別します。
randomの選択は統計的なcoverageではなく、constructorの接続数は解決済みtrafficではありません。
READMEは現状を記述し、今回の追加分はここに保持します。

## M1〜M4の薄い領域の10回目の拡充

[dcc6330](https://github.com/kurochan001/kirimasim-uvm-tests/commit/dcc6330034e652830fd05c4e50153d6c7017aac5)
の985件へシミュレーション20件を追加し、21 directoryで1005件となります。
M1は319件、M2は400件、M3は286件で、既存985件の入力はすべて保持します。
M1はlocal phase graphのmetadata・同一性・lookup・順序の8件です。
M2はcustom transactionのsocket 4件で、blockingのparent／明示implementationへの配送と、
nonblockingの単一initiator／target pass-throughでのforward／backward routeを扱います。
M3はcoverage制御、sampling順序、再帰value hookの8件です。
covergroupや機能coverage比率、RTL access、DPIは使いません。

追加の16件はVerilator 5.052でseed 1・73と一致します。4件は規範的なspec-only差分を保持します。
現在nodeのfindがnodeでなくimplementationを返すこと、coverage制御2検査系が直前でなく新しい有効maskを返すこと、
memory samplingが1 locationのaccessごとに余分なlocationを訪問することです。
後者は搭載状況、再帰制御、peerの一致する観測を別に保持します。
最初のsocket 4検査系はget_abstime／set_abstimeでcanonical timeをannotateするよう修正し、
最終evidenceは修正後の呼出しを使います。互換なsnapshotは一致905件、既知差分100件で、
seed 1の実行時初回差分91件と、seed実行結果のないAPI欠落build 9件です。
Ghost bundledは各seedで一致198件、不一致807件で、失敗集合は同じです。
kirimasimはunsupported 996件、API欠落のfail 9件です。
runner／実行ファイル／profile／libraryの識別は互換で、現在のGhost pinned modeの主張は加えません。

M4はAI要求案51件を追加し、新規20件と既存register／fieldのset・reset・予測・update 20件を対応付けます。
台帳は要求案811件、直接対応の要求807件、直接対応テスト796件、別のcontrol 1件、未対応208件です。
条項番号2,504件のうち592件を一部分解し、1,912件は未評価、主引用は458番号、いずれかの引用は1,046番号です。
候補2,479番号の棚卸しは主引用0件が2,021、1件が232、2件以上が226です。
直接テストのない要求案は4件のままです。対象範囲は提案、照合はすべてAI、分母／比率は未設定です。

検証はtool unit test 74件、metadata全1005件、台帳／索引の整合性、最終入力のevidence fingerprint、
完全な日英guideを対象とします。用語集は131語、FAQは112回答で、phase graphの図を加えます。
model状態、bus mask、hook counterは、物理DUT動作とは区別します。
READMEは現状を記載し、今回の増分はこの履歴に保持します。

## M1〜M4の薄い領域の11回目の拡充

[34b4ba0](https://github.com/kurochan001/kirimasim-uvm-tests/commit/34b4ba002f28005aa38a8d56e686aa24febf4d75)
の1005件へシミュレーション20件を追加し、21 directoryで1025件となります。
M1は327件、M2は404件、M3は294件で、既存1005件の入力はすべて保持します。
M1はcomponent記録の制御、database／streamのcache、null guard、時刻／hook、属性記録のlifecycleの8件です。
M2はsequenceのreport context、verbosity、message生成、handler routingの4件です。
M3はmap check-on-readの既定値、切替、submap、独立interface、field mask、RC順序の8件です。
local storage／hookは、外部記録形式、component eventの起動、受動predictor統合、RTL access、DPIを示しません。

追加19件はVerilator 5.052でseed 1・73と一致します。1件は13.1.7.10の新規stream要求を保持します。
free_tr_streamが誤った型keyを使い、固定版は元cache entryを残します。有効記録の検査系は、
component hookへ渡したrecorder handleから実際のstreamを得て、内部で選ぶ型への仮定を避けます。
2026-11-02の互換なsnapshotは一致924件、既知差分101件で、seed 1の実行時初回差分92件と、
seed実行結果のないAPI欠落build 9件です。Ghost bundledは各seedで一致199件、不一致826件で、失敗集合は同じです。
kirimasimはunsupported 1016件、API欠落のfail 9件です。runner、実行ファイル、profile、libraryの識別は互換で、
現在のGhost pinned modeの主張は加えません。

M4はAI要求案54件を追加し、新規20件と既存sequenceのstart／finish／grant／送信20件を対応付けます。
台帳は要求案865件、直接対応の要求861件、直接対応テスト836件、別のcontrol 1件、未対応188件です。
条項番号2,504件のうち612件を一部分解し、1,892件は未評価、主引用は470番号、いずれかの引用は1,068番号です。
候補2,479番号の棚卸しは主引用0件が2,009、1件が242、2件以上が228です。直接テストのない要求案は4件のままです。
対象範囲は提案、照合はすべてAI、分母／比率は未設定です。既知の不正入力severity、finishのvirtual dispatch、
完了IDの差分は保持します。

検証はtool unit test 74件、metadata全1025件、台帳／索引の整合性、最終入力のevidence fingerprint、
完全な日英guideを対象とします。用語集は135語、FAQは115回答で、read照合／予測の図を加えます。
report生成のprobeと実handlerの実行は区別します。不一致の報告、戻りdata、予測mirror状態、bus完了は別の観測です。
READMEは現状を記載し、今回の増分はこの履歴に保持します。

## M1〜M4の薄い領域の12回目の拡充

[c731bc9](https://github.com/kurochan001/kirimasim-uvm-tests/commit/c731bc919f105ed8aa6c71ff19257a98b1aaf2c9)
の1025件へシミュレーション20件を追加し、21 directoryで1045件となります。
M1は335件、M2は408件、M3は302件で、既存1025件の入力はすべて保持します。
M1はcore-serviceのpolicy／既定fallback、serviceの置換／復元、seed不変性の8件です。
M2はsequence-libraryのwrapper index、範囲、instance、削除の4件です。
M3はregisterのtransaction-order policyの照会と、endian、方向、interface独立性、置換、解除を扱うbus統合の8件です。

追加17件はVerilator 5.052でseed 1・73と一致します。3件は規範的なspec-only差分を保持します。
little-endian readは要求bus順に従っても、実行順にdataを再合成します。
big-endian write／readは既存の全幅byte反転制約も示し、readは両原因を組み合わせます。
policyのdispatchと要求geometry／順序は、失敗するdata保持とは別です。
互換なsnapshotは一致941件、既知差分104件で、seed 1の実行時初回差分95件と、seed実行結果のないAPI欠落build 9件です。
Ghost bundledは各seedで一致203件、不一致842件で、失敗集合は同じです。
kirimasimはunsupported 1036件、API欠落のfail 9件です。runner、実行ファイル、profile、libraryの識別は互換で、
現在のGhost pinned modeの主張は加えません。

M4はAI要求案50件を追加し、新規20件と既存sequence libraryの登録、選択、境界、counter、既定RAND実行の20件を対応付けます。
台帳は要求案915件、直接対応の要求911件、直接対応テスト876件、別のcontrol 1件、未対応168件です。
条項番号2,504件のうち645件を一部分解し、1,859件は未評価、主引用は482番号、いずれかの引用は1,084番号です。
候補2,479番号の棚卸しは主引用0件が1,997、1件が251、2件以上が231です。直接テストのない要求案は4件のままです。
対象範囲は提案、照合はすべてAI、分母／比率は未設定です。標準APIの欠落と既存のstatic削除／warningの差分は、
明示した制約として残します。

検証はtool unit test 74件、metadata全1045件、台帳／索引の整合性、最終入力のevidence fingerprint、
完全な日英guideを対象とします。用語集は139語、FAQは118回答で、order-policyの図を加えます。
既定handleの選択、型lookup、物理順序、論理再合成は別の観測です。外部database、独自core初期化、memory burst、
端数bus word、任意の同時accessは主張しません。READMEは現状を記載し、今回の増分はこの履歴に保持します。

## M1〜M4の薄い領域の13回目の拡充

[fdfbd57](https://github.com/kurochan001/kirimasim-uvm-tests/commit/fdfbd57d235a9fc19ede9163f23f8e9b255f5e0a)
の1045件へシミュレーション20件を追加し、21 directoryで1065件となります。
M1は343件、M2は412件、M3は310件で、既存1045件の入力はすべて保持します。
M1はvisitor／proxy／走査とcoreのvisitor選択の8件、M2はblocking transport channelの4件です。
M3はregister-sequenceの便利APIの8件で、data動作と暗黙parent／明示transaction metadataを区別します。

互換なsnapshotは、Verilator 5.052のseed 1／73で一致961件、既知差分104件です。
内訳はseed 1の実行時初回差分95件と、seed実行結果のないAPI欠落build 9件です。
Ghost bundledは各seedで一致207件、不一致858件で、失敗集合は同じです。
kirimasimはunsupported 1056件、API欠落fail 9件です。runner、実行ファイル、
非公開profile、固定libraryの識別は互換で、現在のGhost pinned modeの結果は推測しません。

M4はAI要求案46件を追加し、新規20件と既存default-sequenceのresource選択／終了responseのroutingの20件を対応付けます。
台帳は要求案961件、直接対応要求957件、直接対応テスト916件、別control 1件、未対応148件です。
条項番号2,504件のうち663件を一部分解し、1,841件は未評価です。主引用は496番号、いずれかの引用は1,109番号です。
候補2,479番号の棚卸しは、主引用0件が1,983、1件が263、2件以上が233です。
直接テストのない要求案は4件のままです。対象範囲は提案、照合はすべてAIで、分母／比率は未設定です。
既存の不正wrapperのseverity差分はspec-onlyを保持します。

検証はtool unit test 74件、metadata全1065件、台帳／索引の整合性、最終入力のevidence fingerprint、
完全な日英guideを対象とします。用語集は143語、FAQは121回答です。走査は兄弟順を固定せず必要な部分順を要求します。
blocking transportは各channelに1 callerを使い、逐次再利用、事前reply、channel独立性を比較します。
register wrapperはvirtual sequenceとして動き、backdoorはHDL／DPIなしでstorageをモデル化します。
循環graph、同一channelの同時呼出し、任意BASE specialization、変換bodyは主張しません。
READMEは現状を記載し、今回の増分はこの履歴へ保持します。

## M1〜M4の薄い領域の14回目の拡充

[101405a](https://github.com/kurochan001/kirimasim-uvm-tests/commit/101405abac10d45544cb9c372548cacf22c1524e)
の1065件へシミュレーション20件を追加し、21 directoryで1085件となります。
M1は351件、M2は416件、M3は318件で、既存1065件の入力はすべて保持します。
M1は簡易照合4件とenum名変換4件です。M2はID待機、response queueのclear、peer独立性、容量／control保持、
M3は物理DUT accessを伴わない記述子のmetadata、bulk配列、不正indexの8件です。

追加18件はVerilator 5.052のseed 1／73と一致し、簡易plusと記述子indexは規範的な差分2件を保持します。
互換snapshotは一致979件、既知差分106件で、seed 1の実行時初回差分97件とAPI欠落build 9件です。
Ghost bundledは各seedで一致207件、不一致878件で、失敗集合は同じです。
kirimasimはunsupported 1076件、API欠落fail 9件です。最終evidence前に検査系の問題2つを修正し、
enum名のlookupは型付き値、extension tokenは具体的な派生クラスを使います。
最終記録は現在の全入力hashと一致し、runner、実行ファイル、非公開profile、libraryの識別は互換です。
現在のGhost pinned modeやDPI有効時の照合結果は推測しません。

M4はAI要求案60件を追加し、新規20件と既存stop／response検査系20件を対応付けます。
台帳は要求案1021件、直接対応要求1017件、直接対応テスト956件、別control 1件、未対応128件です。
条項番号2,504件のうち684件を一部分解し、1,820件は未評価、主引用は504番号、いずれかの引用は1,114番号です。
候補2,479番号の棚卸しは、主引用0件が1,975、1件が267、2件以上が237です。
第15章を含む18 rootは主引用検査系の未対応0件です。直接テストのない要求案は4件で、範囲は提案、
照合はすべてAI、分母／比率は未設定です。既存の単一候補USER、自動objection、response既定値の差分は
規範的な期待を保持します。共有anchorは独立coverageを意味しません。

検証はtool unit test 74件、metadata 1085件、台帳／索引、最終入力のevidence、日英9組とlocal linkを対象とします。
用語集は147語、FAQは124回答です。READMEは現状を記載し、今回の増分はこの履歴へ保持します。
失敗したenumの出力、記述子の未定義初期field、POSIX／DPI動作、重複ID順、clear／配送の同時raceは検査対象外です。

## M1〜M4の薄い領域の15回目の拡充

[e58bd5a](https://github.com/kurochan001/kirimasim-uvm-tests/commit/e58bd5afbe1d9cda33c7a9db3e065a8710eeca92)
の1085件へ20件を追加し、21 directoryで1105件となります。M1は359件、M2は420件、M3は326件です。
既存入力はすべて保持します。M1はrootのcomponent検索8件、M2はstate mask／待機4件、
M3はmemory sequenceのpoke／peek統合8件です。追加20件はVerilator 5.052のseed 1／73で一致します。
互換snapshotはpass 999件、known 106件で、seed 1の実行時初回差分97件とAPI欠落build 9件です。
追加のknownはありません。

kirimasim／Ghostの一時実行ファイル／profile snapshotと、互換なlocal環境が利用できませんでした。
現在の未変更入力1085件の記録を保持し、kirimasimはunsupported 1076件、fail 9件、
Ghost bundledは各seedでpass 207件／fail 878件、失敗集合は同じです。新規20件のguestは明示的に未測定です。
新しい全件guest実行、Ghost pinned modeの結果、代替設定の使用は主張しません。
evidence-scope JSONは、未測定IDを実測結果と別に記録します。

M4はAI要求案42件を追加し、新規20件と第14章の既存20検査系を対応付けます。
台帳は要求案1063件、直接対応要求1059件、直接対応テスト996件、別control 1件、未対応108件です。
条項番号2,504件のうち692件を一部分解し、1,812件は未評価、主引用は507番号、いずれかの引用は1,116番号です。
候補2,479番号の棚卸しは、主引用0件が1,972、1件が266、2件以上が241です。
第14／15章を含む19 rootは主引用検査系の未対応0件です。未対応テストは第18章62件と第12章46件に残ります。
直接テストのない要求案は4件で、照合はすべてAI、範囲は提案、分母／比率はnullです。

検証はtool単体74件、metadata全1105件、台帳／索引、library整合性、最終入力evidence、完全な日英10組を対象とします。
用語集は151語、FAQは127回答です。ハンドオフも最新backlogと部分的なguest対象へ更新します。
第18章の本文集計は、正規の要求案182件へ修正します。検査系の構文と直接field待機を最終測定前に修正し、期待値は変更しません。
兄弟順、曖昧な複数一致の選択順、失敗readのdata、既定backdoor kindの解決、物理DUT accessは推測しません。

## 既存テストの要求への未対応付けを解消

2026-11-03に、残る未対応108検査系すべてへ、要求と期待観測の明示的な対応を追加しました。
第12章46件、第18章62件です。元のsimulation入力は変更しません。
TLMの対応は、分離implementation、nonblocking reply、export／socket中継、payload packing、canonical timeを扱います。
registerの対応は、metadata、method／callback、virtual配列のallocation／lifecycle、memory regionを扱います。

独自のpolicy／object同期検査系1件を追加し、標準のobject側getterで、入れ子の2 policyのpush／popを検査します。
以前直接未対応だったpush同期要求案と、新しいpop復元要求案へ直接対応付けます。
固定libraryはgetterを欠くため、新テストはspec-onlyの既知build失敗を保持します。
legacy getterやpolicy側だけの代替は使いません。

スイートは1106件で、M1 360件、M2 420件、M3 326件です。Verilator 5.052はseed 1／73での一致999件を保持し、
既知差分は107件です。seed 1で最初に異なる実行時97件、API欠落build 10件です。
以前の1105記録は、変更していない現在入力と一致します。guestの実行snapshotは復元できず、以前の1085件の記録を保持し、
現在の21件は明示的に未測定です。部分集合でGhost同梱は各seed pass 207件／fail 878件、
kirimasimはunsupported 1076件／fail 9件のままです。新しいguest結果は主張しません。

台帳はAI要求案100件を加えて1163件となり、1160要求を1105テストへ直接対応し、追加の1テストはcontrolです。
未対応テストは108件から0件となり、主引用テストのある21 rootすべてで解消します。
直接テストのない要求案は、HDL deposit、HDL-path利用可否、memory-walk algorithm全体の3件です。
catalogの2,504識別子は、735件を一部分解し、1,769件は未評価です。
主引用ありは507番号、引用ありは1,119番号、候補の集計は0件1,972番号／1件266番号／2件以上241番号です。
範囲は提案、照合はすべてAI、分母／比率はnullのままです。対応付けqueueの解消で、M1〜M4の完了ではありません。

現在の日英ガイドとハンドオフを更新し、要求ガイドの重複する拡充経緯を、現在集計と残る観測へ整理しました。
FAQは、未対応テスト0件と規範的coverage完了の違いを含む128回答となり、用語集は151語を保持します。
検証は、tool単体74件、全metadata、台帳／索引、library整合性、最終入力evidence、日英10組を対象とします。

## M1〜M4の薄い領域の16回目の拡充

2026-11-03に、規格から導いた独自検査系9件を追加しました。port-baseの名前、parent、role／型名、
既定／明示bounds、接続の所属、export fanout照会、exportのdefault-index選択／再選択、実際のHDL deposit／read／path検査です。
専用constructorでbase boundsを省略し、wrapperの既定値ではなく標準APIの既定値を観測します。
スイートは1115件で、M1 364件、M2 421件、M3 330件です。

別の独自VPI HDL backend／runnerは、商用結果やsimulator実装sourceを使わず、実際の公開8／40 bit変数へaccessします。
標準1024 bit UVM DPI ABIで、64 bitまでのpacked変数のcheck／read／depositに対応します。
force／release、配列、他の型、4値、細かな権限は対象外です。回帰テスト9件が、明示選択、ABI guard、backend指紋、seed判定を検査します。
通常runnerの入力は変えず、以前の1106記録をすべて保持します。

通常のVerilator 5.052記録は、seed 1／73一致1002件、known 113件です。
seed 1の実行時差分99件、API欠落build 10件、DPI未linkのbuild 4件です。
generic型名は規定の接頭辞を省き、実測したexportのdefault-index setterは呼出しを切り替えません。
別のVPI条件は、3件が両seed一致です。E.7は、保持するwarning／転送なしの解釈に対してERRORを報告し、readを試み、
失敗1件はseed 1で停止します。重複する2条件を合計しません。guestの未変更1085記録を保持し、現在の30件は未測定です。

AI要求案20件を加えて1183件となり、1182要求を1114テストへ直接対応し、追加の1テストはcontrolです。
未対応テストは0件を保持します。実際のstorageを使うHDL検査系で、直接テストのない要求案は3件から1件、memory-walk algorithm全体となります。
2,504識別子のうち751件を一部分解し、1,753件は未評価です。主引用ありは515番号、引用ありは1,135番号、
候補の集計は0件1,964番号／1件273番号／2件以上242番号です。範囲は提案、照合はすべてAI、分母／比率はnullを保持します。

現在の日英ガイド、ハンドオフ、FAQ、用語集を、別の実測条件と残る制限へ更新しました。
FAQは130回答、用語集は153語です。検証はtool単体83件、全1115 metadata、台帳／索引、library整合性、
最終入力evidence、日英10組、local参照を対象とします。M1〜M4は未完です。

## M1〜M4の薄い領域の17回目の拡充

2026-11-03に、独自検査系16件を追加しました。container 8件、双方向export 3件、HDL表現／zero-time wrapper 4件、
instrument付きmemory-walk observer 1件です。スイートは1131件で、M1 372件、M2 424件、M3 335件です。
新規no-DPI 12件は、Verilator 5.052のseed 1／73で一致し、HDL 4件は未変更のVPI条件で一致します。

containerは、明示した型aliasとreceiverの変更で、既定specializationとstorage共有を観測し、
名前、置換、所属、順序を保つ挿入／削除、占有数、合法／不正な取得も検査します。
数値の失敗値は2値bit-vector型、objectの失敗値はnullです。双方向exportの9 constructorは具象型で照会し、
反転したslave interfaceを不正に共通baseへcastしません。配送は、入れ子export、独自request／response object、
blockingのreturn、nonblockingのstatus、失敗、再利用を別に検査します。
未変更の混在master／slave検査系2件にも、方向を明示するexportの対応を加えます。

最後のmemory-walk未対応には、Q134の歴史的解釈の下で、候補となる直接テストを追加します。
独立したobserver codeで、2 mapのaddress／dataと順序の関係を検査します。
実装出力の複製、IEEEの改訂、省略された詳細の承認ではありません。
frontdoor保護warningはalgorithm oracleの対象外で、ERRORと関係は検査します。

AI要求案29件を加えて1212件となり、すべて1130テストへ直接対応し、追加の1テストはcontrolです。
未対応テストと直接テストのない要求案のqueueは両方0件です。2,504識別子のうち768件を一部分解し、1,736件は未評価です。
主引用ありは524番号、引用ありは1,142番号、候補の集計は0件1,955番号／1件277番号／2件以上247番号です。
照合はすべてAI、範囲は提案、分母／比率はnullで、queue 0件はM1〜M4の完了ではありません。

通常evidenceは以前の1115入力を保持し、最終入力16件を加え、両seed一致1014件、known 117件です。
seed 1の実行時差分99件、API欠落build 10件、DPI未linkのbuild 8件となります。
別のVPI記録は以前の4入力と新規4入力で、pass 7件、E.7のfail 1件です。重複する条件は合計しません。
guest記録は未変更1085入力のままで、現在の46件は明示的に未測定です。

現在の日英ガイドとハンドオフを更新し、FAQは134回答、用語集は155語です。
検証は、tool単体83件、metadata 1131件、台帳／索引、library整合性、互換evidence、日英10組、local参照です。
既存テスト、runner、VPI backendは未変更です。

## M1〜M4の薄い領域の18回目の拡充

simulation検査系14件を追加します。component configuration 6条件、TLM binding／report 4件、memory policy 4件です。
全体1145件、M1 382件、M2 424件、M3 339件で、追加9件はVerilator 5.052のseed 1／73で一致し、
5件は規範的な実行時差分を保持します。既定configurationは独自resourceをskipし、strict buildはresourceを見つけますが
UVM_SET hookを省略します。値0のrelationship resourceもactionのあるwarningを有効にしてしまいます。
検査系の修正では、公開resource-pool挿入APIと具象component派生classを使い、UVM_NO_ACTIONをreport集計から除きました。
期待値を観測出力からコピーしていません。

互換な通常snapshotは、以前の1131入力を保持し、新規測定を加えてpass 1023件、known 122件です。
knownはseed 1の実行時差分104件、API欠落build 10件、DPI未link build 8件です。
別条件のVPI 8件は未変更でpass 7件・fail 1件を保持します。guestは互換な1085入力を保持し、新規60件は未測定です。

AI要求案23件を追加して1235件となり、すべて1144テストへ直接対応します。追加control 1件を含め、未対応テストは0件です。
新たな正本の分類fileに、個別に読んだ構造5件と、既存要求へ関連する文脈1件を記録します。
要求との競合、不明／重複参照、日英根拠の欠落、未レビュー状態の適用、入力の上書きを拒否し、意味のあるtoolテスト5件を追加します。
inventory／backlogのschemaは2、正本のschemaは1で、report digestは分類も識別します。見出しの自動分類は行いません。

catalogは2,504番号で、部分分解776件、明示分類6件、未評価1,722件です。主引用529番号、いずれかの引用1,148番号、
候補の主引用棚卸しは0件1,950、1件276、2件以上253です。第11章の未評価は0件ですが、要求の分解は部分的なままです。
範囲、分母、人による照合、M1〜M4の完全なcoverageは未完です。

資料はすべて日英で揃え、用語157語、FAQ 136回答です。toolテスト88件、全1145 metadata、台帳／分類／索引、
library整合性、日英参照、evidence指紋を検査します。simulation runner、既存テスト、VPI backend、以前の履歴は未変更です。

## M1〜M4の薄い領域の19回目の拡充

registry singleton／初期化4条件、sequencer履歴4件、register blockのlock／検索6件の、計14検査系を追加します。
全体1159件、M1 386件、M2 428件、M3 345件です。registryは型／名前ごとのproxy、constructorなしの取得、
新しく選択したfactoryへの初期化を区別します。履歴は容量0／再有効化と実際のhandshake、正確なhandle、peer分離を組み合わせます。
blockは構造lock、offset検索の再構築、wait、root所属、絶対／相対glob検索を区別します。
response検査系は、転送前に通常のUVM build／connectを実行します。引用条項に完了後の新規waitが明記されないため、
waiter検査は完了前の待機に限定します。

追加14件すべてがVerilator 5.052のseed 1／73で一致します。
互換な通常evidenceは以前の1145入力を保持し、新規測定を加えてpass 1037件、known 122件です。
別条件のVPI 8件は未変更でpass 7件・fail 1件です。guestは互換な1085入力を保持し、新規74件は未測定です。

AI要求案26件を追加して1261件となり、すべて1158テストへ直接対応します。追加control 1件を含め、未対応テストは0件です。
個別に読んだ構造見出し8件を追加し、分類は14件（構造13件・文脈1件）となります。
自動分類、親への集約、人の承認、承認済み分母は導入しません。2,504番号のうち部分分解798件、分類14件、未評価1,692件で、
減少30件の内訳は要求分解22件・明示的な構造の分類8件です。主引用542番号、いずれかの引用1,162番号、
候補の主引用棚卸しは0件1,937、1件288、2件以上254です。

資料はすべて日英で揃え、用語160語、FAQ 139回答です。toolテスト88件、全1159 metadata、台帳／分類／索引、
library整合性、日英参照、evidence指紋を検査します。既存simulation入力、runner、HDL backend、要求、以前の履歴は保持します。
M1〜M4は未完で、対応付けqueue 0件は適合性の確立ではありません。

## M1〜M4の薄い領域の20回目の拡充

abstract registry 7条件、sequence ID／parent 2件、block map／door／解除6件の、計15検査系を追加します。
全体1174件、M1 393件、M2 430件、M3 351件です。virtual型でsingleton／既定名、選択factoryへの初期化、
具象／scope付きoverride、未実装callbackを検査します。2つのlive sequenceでresponse routingとtransaction値のコピー、
payload／名前の保持を確認し、parent変更では以前の観測後の現在階層を調べます。mapは設定、default、明示door、
register／memory／static overlayの解除、同名childの保持を検査します。

追加13件はVerilator 5.052のseed 1／73で一致します。2件はseed 1の実行時差分で、parentなしabstract component診断の
null参照と、parent変更後のsequence depth cacheを保持します。parentありcallbackの対照検査は一致します。
互換な通常evidenceは以前の1159入力を保持し、新規15測定を加えてpass 1050件、known 124件です。
knownは実行時初回差分106件、API欠落build 10件、DPI未link build 8件です。別条件VPI 8件はpass 7件・fail 1件のままで、
guestは互換な1085入力を保持し、新規89件は未測定です。

AI要求案40件を追加して1301件となり、すべて1173テストへ直接対応します。追加control 1件を含め、要求未対応テストは0件です。
個別に読んだ構造見出し8件を追加して分類22件（構造21件・文脈1件）です。2,504番号のうち部分分解827件、分類22件、
未評価1,655件です。減少37件の内訳は要求分解29件・明示分類8件です。主引用554番号、いずれかの引用1,186番号、
候補の棚卸しは0件1,925、1件298、2件以上256です。範囲、人の照合、分母承認は未完のままです。

資料はすべて日英で揃え、用語163語、FAQ 142回答です。toolテスト88件、全1174 metadata、台帳／分類／索引、
library整合性、日英参照、evidence指紋を検査します。既存simulation入力、runner、backend、以前の要求／分類／履歴を保持します。
対応付けqueue 0件は、M1〜M4の完了や適合性の確立ではありません。

## M1〜M4の薄い領域の21回目の拡充

recording callback／失敗4件、sequence hook／phase再利用4件、model階層／map 6件の、計14検査系を追加します。
全体1188件、M1 397件、M2 434件、M3 357件です。recordingは失敗／再試行、null結果の初期化gate、正確なmetadataとlink同一性を観測します。
sequenceはoptional body hookとparent／start callbackを分け、phase／objection制御は完了したstart間だけで変更します。
modelはvirtual-fieldの所属、simple nameのscope、map内容の解除と正確なpeer同一性を検査します。

追加12件はVerilator 5.052のseed 1／73で一致します。2件はseed 1の実行時差分で、local submapに接続していないchild blockのmap名を見つけず、
直接childの対照が一致してもrootからsimple grandchild block名を見つけません。oracleは有効なsimple name入力だけを使います。
互換な通常evidenceは以前の1174記録を保持し、新規14測定を加えてpass 1062件、known 126件です。
knownは実行時初回差分108件、API欠落build 10件、DPI未link build 8件で、別条件VPI 8件はpass 7件・fail 1件です。
guestは互換な1085入力を保持し、新規103件は明示的に未測定です。

AI要求案50件を追加して1351件となり、すべて1187テストへ直接対応します。追加control 1件を含め、未対応テストは0件です。
未変更hook検査系4件にcallbackの明示対応7件を加え、追加実行evidenceは与えません。
個別に読んだ構造見出し14件を追加し、分類36件（構造35件・文脈1件）です。2,504番号のうち部分分解853件、分類36件、未評価1,615件で、
減少40件は要求分解26件と構造の分類14件です。主引用568番号、いずれかの引用1,197番号、候補の棚卸しは0件1,911、1件312、2件以上256です。
人の照合や承認済み分母は追加しません。

資料はすべて日英で揃え、用語166語、FAQ 145回答です。toolテスト88件、全1188 metadata、台帳／分類／索引、
library整合性、日英参照、evidence指紋を検査します。既存simulation入力、runner、backend、以前の要求／分類／履歴を保持します。
対応付けqueueが空でもM1〜M4の完了ではありません。

## M1〜M4の薄い領域の22回目の拡充

recording constructor／link 4件、sequence constructor 3件、register file 6件の、計13検査系を追加します。
全体1201件、M1 401件、M2 437件、M3 363件です。命名の検査は、基底引数の省略、明示名、明示的な空の名前を分けます。
prefilled linkは規定の既定名とhandleの独立性を保持します。register fileはconfigure、local／fullのsymbolic path、
複数abstraction、clear、近い既定値、直積の代替、flatten scopeを追加し、HDL／DPIの転送を行いません。

追加11件はVerilator 5.052のseed 1／73で一致します。2件は、register fileの既定値継承と、flattenされた親の下でのkind省略full pathの、
seed 1実行時差分を保持します。明示RTL／GATEとlocal overrideの対照は一致します。存在／local pathのAPIは、規格どおり最も近い包含先の既定値を使う条件として分けます。
互換な通常evidenceは以前の1188記録を保持し、最終入力13測定を加え、pass 1073件、known 128件です。
knownは実行時初回差分110件、API欠落build 10件、DPI未link build 8件です。別条件VPIはpass 7件・fail 1件を保持します。
guestは未変更1085入力の記録を保持し、現在の116件は明示的に未測定です。

AI要求案44件を加えて1395件となり、すべて1200テストへ直接対応します。追加control 1件を含め、未対応テストは0件です。
未変更M2検査系5件に義務5件の明示対応を加え、新測定は与えません。個別に読んだ構造見出し10件を加え、分類46件（構造45件・文脈1件）です。
2,504番号のうち部分分解874件、未評価1,584件で、減少31件は新しい分解21件と構造の分類10件です。
主引用581番号、いずれかの引用1,212番号、候補の棚卸しは0件1,898、1件325、2件以上256です。人の照合と分母の承認は未完です。

日英の資料はSVG図を維持し、APIごとの説明を追加して用語169語、FAQ 148回答です。toolテスト88件、全1201 metadata、台帳／分類／索引、
library整合性、日英対応、evidence指紋を検査します。既存simulation入力、runner、backend、以前の台帳記録と履歴の節は保持します。
対応付けqueueが空でもM1〜M4の完了ではありません。

## M1〜M4の薄い領域の23回目の拡充

heartbeat 5件、基底型経由のpayload accessor 3件、abstract register FIFO 5件の、計13検査系を追加します。
全体1214件、M1 406件、M2 440件、M3 368件です。heartbeatはmodeの明示選択／照会、不在／置換／再利用するevent、
正常なALL_ACTIVEでの参加者変更を扱います。payload overrideで選択したvirtual method 14個を観測します。
FIFOはconstructorの寸法、公開queueの照会、popしないget、debug引数、instanceの独立性、inline／subtype制約を扱い、DUT accessを行いません。

追加10件はVerilator 5.052のseed 1／73で一致します。3件はseed 1の実行時差分を保持します。
動作中に省略したheartbeat eventはerror整形中に参照されますが、その前のstop後の既定再利用と明示same-eventの対照は一致します。
容量ちょうどのFIFO inline randomizeは成功してqueueが空のままですが、過大inline要求は正しく拒否します。
容量ちょうどを宣言したsubtypeは一致し、過大なsubtypeも成功を返します。FIFO観測だけではsimulator／libraryのどちらが原因かを決めません。
互換な通常evidenceは以前の1201記録を保持し、最終入力13測定を加え、pass 1083件、known 131件です。
knownは実行時初回差分113件、API欠落build 10件、DPI未link build 8件です。別条件VPIはpass 7件・fail 1件を保持します。
guestは未変更1085入力の記録を保持し、現在の129件は未測定です。

AI要求案56件を加えて1451件となり、すべて1213テストへ直接対応します。追加control 1件を含め、未対応テストは0件です。
未変更検査系7件に、transactionのhook／時刻の義務6件とpayload setterの義務11件を加え、新測定は与えません。
構造の分類7件とpayload member導入の文脈分類1件を加え、分類54件（構造52件・文脈2件）です。
2,504番号のうち部分分解903件、未評価1,547件で、減少37件は新しい分解29件と明示分類8件です。
主引用588番号、いずれかの引用1,225番号、候補の棚卸しは0件1,891、1件329、2件以上259です。人の照合と分母の承認は未完です。

日英資料はSVG 6個を維持し、検査範囲の説明、FIFO制約の比較、用語172語、FAQ 151回答を揃えます。
toolテスト88件、全1214 metadata、台帳／分類／索引、library整合性、日英参照、evidence指紋を検査します。
既存simulation入力、runner、backend、以前の台帳記録と履歴の節は保持します。
FIFOの転送／compare／初期化と、広いheartbeat、payload protocol、要求分解の作業は未完です。

## M1〜M4の薄い領域の24回目の拡充

catcherのhelper／issue 5件、sequence既定req／rsp印字3件、adapterの別response 4件の、独自検査系12件を追加します。
全体1226件、M1 411件、M2 443件、M3 372件です。helper報告は両catcherを迂回し、現在のmessageのissueと通常の発行を、
CAUGHT／THROWと変更後のIDで区別します。型付きprint hookは、書式を固定せず、現在・置換後・null化後のfieldを観測します。
IDを引き継いだ新規responseを使い、write、反復read、失敗writeの再試行、失敗memory readの復帰で、矛盾するrequest状態と区別します。

最終入力12件はすべてseed 1・73で一致します。互換な通常evidenceは以前の1214記録を保持し、pass 1095件、known 131件です。
knownには実行時の最初の差分113件、API欠落build 10件、DPI未linkのbuild 8件があります。
重複するVPI条件はpass 7件・fail 1件のままです。guest記録は未変更1085入力のままで、現在の141件は未測定です。
商用シミュレータの結果とsimulator実装sourceは使いません。

AI要求案34件を加えて1485件となり、すべて1225テストへ直接対応します。追加control 1件を含め、未対応テストは0件です。
個別に本文を読んだ整理用見出し4件を加え、分類は58件、構造56件・文脈2件です。2,504番号のうち部分分解914件、未評価1,532件で、
減少15件は新しい部分分解11件と明示分類4件です。M4は進行中で、範囲／分母の承認と人のレビューは未完です。

日英10組のguideを更新し、FAQ 3件と用語3件を追加して154回答・175語になります。tool単体88件、全1226 metadata、台帳／索引／library、
日英参照、現在の入力とevidenceの指紋を検証します。既存検査系、runner、VPI backend、lock、scope、license、SVG 6 assetは変更しません。

## M1〜M4の薄い領域の25回目の拡充

catcherの状態変更／getter 6件、sequence側の解放3件、個別／fallback field access 3件の、独自検査系12件を追加します。
全体1238件、M1 417件、M2 446件、M3 375件です。catcherのfield変更は後続callbackへ伝わり、新たに明示初期化した報告へ漏れません。
sequenceは既定／明示の解放対象、peerのblocking、相互解放を区別します。

最終入力10件がseed 1・73で一致し、2件はseed 1の差分を保持します。byte enable対応で16-bit bus wordの別byteを占めるfieldでも、
固定libraryは個別アクセスを拒否し、全wordのmaskを使います。low writeは実際のhigh byteを0xabからmirrorの0x12へ変え、
high readはlow mirrorを0x34に保持せず0xcdへ更新します。必要なbyte単位の期待をspec-onlyで保持します。
byte-enable非対応の全registerへのfallbackは、実際のstorage変更後にpeer mirrorを使う条件も含め、両seedで一致します。
bus幅でまとめる判定の診断には許可されたApache UVM sourceだけを使い、simulator実装sourceや商用シミュレータ結果は使いません。

互換な通常evidenceは以前の1226入力を保持し、最終12測定を加えてpass 1105件、known 133件です。
knownは実行時の最初の差分115件、API欠落build 10件、DPI未linkのbuild 8件です。別のVPI条件はpass 7件・fail 1件のままです。
guest記録は未変更1085入力で、現在の153件は未測定です。

AI要求案44件を加えて1529件となり、すべて1237テストへ直接対応し、別control 1件があります。未変更のkill-hook検査系3件にdo_killの直接対応を加え、
新測定やpost hook結果の変更は加えません。個別に読んだmethod見出し4件を加え、分類は62件、構造60件・文脈2件です。
2,504番号のうち部分分解937件、未評価1,505件で、減少27件は新たな分解23件と分類4件です。
主引用606番号、いずれかの引用1,247番号、候補の棚卸しは0件1,873、1件343、2件以上263です。範囲承認、人のレビュー、分母は未完です。

日英10組のguideを照合し、現在の件数を更新します。FAQ 3件と用語3件を加え、157回答・178語です。
tool単体88件、全1238 metadata、台帳／索引／library、日英参照、現在の入力のevidenceを検査します。
既存simulation入力、runner、VPI backend、scope、lock、license、SVG 6 assetは未変更です。

## M1〜M4の薄い領域の26回目の拡充

事前構成／受付の報告4件、既定sequencerなしの所有API 4件、field配置／endian 4件の12検査系を追加します。
全体1250件、M1 421件、M2 450件、M3 379件です。最終入力8件は両seedで一致し、3件は標準catcher get_report_message欠落でbuildできません。
1件はnarrow busのbig-endian field address／dataでseed 1の差分を保持します。little-endian、byte共有、byte境界をまたぐ対照は一致します。
fatal probeは必須severityを観測した後、検査系自身の意図的なfatal sentinel、宣言したnonzero終了と固有診断を使います。
先行する終了方法の試行は検査系の診断であり、適合性の差分として保持しません。

互換evidenceは以前の1238記録を保持し、pass 1113件、known 137件です。内訳は実行時差分116件、API欠落build 13件、DPI未link build 8件です。
重複するVPI条件はpass 7件・fail 1件のままで、guestは未変更1085入力、165件は未測定です。
AI要求案46件で台帳は1575件、1249テストへ直接対応し、別control 1件があります。未変更のpriority／照会検査系3件の明示対応は再測定ではありません。
個別に読んだ見出し4件を加え、分類66件は構造64件・文脈2件です。2,504番号のうち部分分解951件、未評価1,487件で、減少18件は新たな分解14件と分類4件です。
主引用609番号、いずれかの引用1,250番号、候補の棚卸しは0件1,870、1件341、2件以上268です。

日英10組を検査し、FAQ 160回答・用語181語です。tool単体88件、metadata 1250件、正本台帳／索引、library整合性、日英参照、互換evidenceを検証します。
以前のsimulation入力、runner、VPI backend、scope、lock、license、SVG 6 assetは未変更です。範囲／分母の承認と人のレビューは未完です。

## M1〜M4の薄い領域の27回目の拡充

実際のhandler委譲4件、複数要求／再開後のrelevance 3件、標準TLM-adapter 4件の11検査系を追加し、最終入力はすべてseed 1・73で一致します。
全体1261件、M1 425件、M2 453件、M3 383件です。handlerの同一性、source field、共有、置換を公開処理引数で調べ、欠落したcatcher getterは使いません。
adapterは新規payload、5つの負のstatus、operation再利用、contextを限定したactive frontdoor readを扱います。同じ値のbyteで数値byte順を固定しません。
根拠の不足したn_bits逆変換の断定は最終入力前に外し、有効bit再構築を観測値に合わせず未整理として残します。

互換な通常evidenceは以前の1250入力を保持し、pass 1124件、known 137件です。内訳は実行時差分116件、API欠落build 13件、DPI未link build 8件です。
別のVPIはpass 7件／fail 1件のままです。guest記録は未変更1085入力で、現在の176 IDは未測定です。
AI要求案51件で台帳は1626件、すべて1260テストへ直接対応し、別control 1件があります。未変更の設定検査系3件の対応追加は再測定ではありません。
個別に読んだ見出し4件を加えて分類70件、構造68件・文脈2件です。2,504番号のうち部分分解961件、未評価1,473件で、減少14件は新しい分解10件と分類4件です。
主引用612番号、いずれかの引用1,252番号、候補の棚卸しは0件1,867、1件342、2件以上270です。

日英10組を照合し、FAQ 163回答・用語184語です。tool単体88件、全1261 metadata、台帳／索引／library、日英参照、現在入力のevidenceを検証します。
以前のsimulation入力、runner、backend、scope、lock、license、SVG 6 assetは未変更です。人のレビューと範囲／分母の承認は未完です。

## M1〜M4の薄い領域の28回目の拡充

objectの型／名前／印字4件、sequence報告4件、非一様TLM-adapter 4件、階層report-file 1件の13検査系を追加します。
annex Dのfile検査系はM1報告に属し、全体1274件、M1 430件、M2 457件、M3 387件です。
最終入力12件はseed 1・73で一致し、1件は14.1.3.3のsequence-interface admission解釈を保持します。
明示したHIGH enabled照会はすべてfalseですが、固定libraryではnon-INFOの呼出しがvirtual処理へ届きます。
検査系counterをresetした閾値以内の比較対象は4 severityとも通ります。report-objectの6.3.3.3とは別です。
往復変換は非一様な有効bitとmaskを比較し、片方向のbyte順、padding、逆変換するn_bitsを独立に認定しません。
階層fileはpair優先より前にID選択を観測し、検査系の順序誤りを最終入力前に修正しました。

互換な通常evidenceは以前の1261入力を保持し、pass 1136件、known 138件です。内訳は実行時差分117件、API欠落build 13件、DPI未link build 8件です。
別のVPIはpass 7件／fail 1件のままです。guest記録は未変更1085入力で、現在の189 IDは未測定です。
AI要求案68件で台帳は1694件、すべて1273テストへ直接対応し、別control 1件があります。未変更のobject／印字検査系3件の対応追加は再測定ではありません。
構造3件・文脈1件を加えて分類74件、構造71件・文脈3件です。規格の手動照合で欠けたB.2.1.2、B.2.1.3、D.2.2.3を復元しました。
catalogは2,504から2,507へ増え、見出しらしい行の走査は完全性の証明ではありません。部分分解970件、未評価1,463件です。
未評価の純減10件は、復元3件から新しい分解9件と分類4件を引いた値です。主引用616番号、いずれかの引用1,257番号、候補の棚卸しは0件1,866、1件343、2件以上273です。

日英10組を照合し、FAQ 167回答・用語188語です。tool単体88件、全1274 metadata、台帳／索引／library、日英参照、現在入力のevidenceを検証します。
以前のsimulation入力、runner、backend、scope、lock、license、SVG 6 assetは未変更です。人のレビューと範囲／分母の承認は未完です。

## M1〜M4の薄い領域の29回目の拡充

ユーザーがM1〜M4の未対応を解消する継続goalを有効化し、最初の反復は検査が薄いregister-global章へ集中します。
M3の9検査系で全体1283件、M1 430件、M2 457件、M3 396件です。既定／設定変更時のtypedef幅、enum symbol、coverage集合、
公開slice field、標準concatの生成／置換／追記を扱います。最終入力6件はseed 1・73一致で、3件は名前付きconstructor 1件と標準slice accessor 2件のAPI欠落buildを保持します。
標準をlegacy interfaceに置換せず、宣言evidenceからX／Z保持、enumで制御する後段の操作、不正入力の拒否、保持名の観測、実際のHDL accessを認定しません。

互換なevidenceは以前の1274入力をすべて保持し、pass 1142件、known 141件です。内訳は実行時の最初の差分117件、API欠落build 16件、DPI未link build 8件です。
別のVPIはpass 7件／fail 1件のままです。guest記録は未変更1085入力で、現在の198 IDは未測定です。
AI要求案41件で台帳1735件、1282テストへ直接対応し、別control 1件があります。個別に読んだ構造見出し6件と文脈2件で分類82件、構造77件・文脈5件です。
第17章は部分分解22番号・分類8番号で未評価0件となり、幅macro 4条項も一部分解します。全体2,507番号のうち部分分解991件、分類82件、未評価1,434件で、goal有効化から29件減りました。
主引用624番号、いずれかの引用1,272番号、候補の棚卸しは0件1,858、1件350、2件以上274です。

goalは有効なままで、章の未評価0はcoverageの完了ではありません。handoffに全体の完了監査を記録します。
日英10組、FAQ 170回答・用語191語に加え、tool単体88件、全1283 metadata、台帳／索引／library、現在入力の同一性を照合します。
以前のsimulation入力、runner、catalog、backend、scope、lock、license、Issue方針、SVG 6 asset、VPI記録は未変更です。人のレビューと範囲／分母の承認は未完です。

## M1〜M4の薄い領域の30回目の拡充

継続goalの2反復目でcommand-line 18検査系を追加します。17件はM1で、実際のphase default sequence 1件はannex G配置でもM2です。
全体1301件、M1 447件、M2 458件、M3 396件です。新しい独立runnerは独自VPI process引数bridgeと、wrapper／移植用割当headerからcompileする固定Apache-2.0 UVM regex codeを使います。
simulator実装、商用overlay、実装由来のoracleは使いません。生成／継承／singleton、引数filter、literal／extended-regex照合、suffix、組込みoption全9条項へ選択観測を追加し、
時刻設定、scope付きaction／severity、実factory型、数値baseのconfig値、default sequence実行を扱います。

最終入力17件は両seed一致です。1件は変更不可quit-count変更の拒否に必要なG.2.6のWARNINGを保持し、固定serverは正しく7を保持してもINFOを発行します。
YESの比較対象は9を受け付けます。別metadata markerは再現済み17件を既定check／CIへ選び、全件実行では差分をknownのまま保持します。
通常runnerはbackendをlinkせず、新規18記録はDPI未link buildです。互換な通常evidenceは以前の1283入力をすべて保持し、pass 1142件、known 159件です。
内訳は実行時差分117件、API欠落build 16件、DPI未link build 26件（HDL 8・command-line 18）です。別HDL VPIはpass 7件／fail 1件のままです。
guest記録は未変更1085入力で、現在の216 IDは未測定です。重複するnative passを通常合計へ加えません。

AI要求案44件で台帳1779件、1300テストへ直接対応し、別control 1件があります。個別に読んだ見出し4件で分類86件、構造81件・文脈5件です。
annex Gは部分分解18番号・構造分類4番号で未評価0件ですが、より広い条件は残ります。全体2,507番号のうち部分分解1008件、分類86件、未評価1,413件です。
今回21件減、goal有効化から50件減です。主引用639番号、いずれかの引用1,294番号、候補の棚卸しは0件1,843、1件363、2件以上276です。
goalは有効なままで、範囲／分母を承認しません。

tool単体101件、全1301 metadata、台帳／索引、library整合性、日英資料、互換evidenceを検証し、日英10組、FAQ 173回答・用語194語を照合します。
通常／HDL／guest runner、以前の入力、catalog、scope、lock、license、Issue方針、SVG 6 asset、以前のevidenceは未変更です。
CIへ別command-line 17件を追加し、timeoutを150分へ増やします。

## M1〜M4の薄い領域の31回目の拡充

継続goalの3反復目でM2の12検査系を追加し、継承／型parameter 4件、標準protected counter 2件、巡回index 3件、relevance待ち中のkill 2件、親子sequencer stop／新規traffic 1件を扱います。
最終入力はすべてseed 1・73一致で、全体1313件、M1 447件、M2 470件、M3 396件です。初回probeの問題は期待観測を変えず修正し、
forkが使う記憶域をstaticにし、継承fieldのrandomizeをsubtype method内で指定し、counter libraryを実際のsequencerへbindしました。
公開getterやmode APIをlegacy fieldで置換しません。protected counterは0、実行中の子の除外、完了prefix、最終10回、peer分離を観測します。
randcは幅、有効index、重複しない2 cycle、単一候補の再利用、subtype制約の部分集合を順序固定なしで観測します。
kill／stop cleanupは実要求、gate、公開状態／hook、その後の実driver完了を使い、必要なpost-hook差分は保持します。

AI要求案23件で台帳1802件、1312テストへ直接対応し、別control 1件があります。既存6要求へ直接link 9件を加え、全ての元のlinkを保持し、
1つの制限注記で以前の手動2回getter検査と新しい既定10回protected-field probeを区別しました。未変更RAND 3検査系へ、再測定せず導入の対応付けを加えます。
個別に読んだ導入／例5件で分類91件、構造81件・文脈10件です。第14章は部分分解89番号・分類17番号で未評価0件です。
全体2,507番号は部分分解1015件、分類91件、未評価1,401件となり、今回12件減、goal有効化から62件減です。
主引用645番号、いずれかの引用1,305番号、候補の棚卸しは0件1,837、1件367、2件以上278です。部分的なreview evidenceであり、範囲／分母や人の承認はありません。

互換な通常記録は以前の1301入力をすべて保持し、pass 1154件、known 159件です。内訳は実行時の最初の差分117件、API欠落build 16件、DPI未link build 26件です。
別command-line evidenceはpass 17／known 1、HDL VPIはpass 7／fail 1のままです。guest記録は未変更1085入力で、現在の228 IDは未測定です。
tool単体101件、全1313 metadata、台帳／索引／library同一性、互換evidence、日英10組のFAQ 176回答・用語197語を照合します。
以前の入力、全runner／tool、CI、catalog、backend、scope、lock、license、Issue方針、SVG 6 asset、別VPI記録は未変更です。
部分分解した残る義務を含め、goalは有効なままです。

## M1〜M4の薄い領域の32回目の拡充

継続goalの4反復目でM3の13検査系を追加し、item／adapterの名前・型・変換4件、backdoorの名前・型1件、既定read／callback 3件、独自write 2件、predictorの型・設定3件を扱います。
最終入力はすべてseed 1・73一致で、全体1326件、M1 447件、M2 470件、M3 409件です。初期predictor packetの設定には正しい型のfactory登録がなく、
追加によって固定libraryのtype-name経路を直し、期待観測は変えていません。既定readは独自functionを呼び、正確なdescriptor同一性、pre／post順序、
現在のcallback登録、成功／失敗statusを観測します。write hookは実際のregister modelからprotected helperを通し、変換dataを独自記憶域へ渡します。
独立に設定したmap／decoderは、実際のmirrorと公開値へ反映されます。

AI要求案26件で台帳1828件、1325テストへ直接対応し、別control 1件があります。以前の要求案はすべて保持します。
個別の構造6件・文脈7件の分類で計104件、構造87件・文脈17件です。第19章は部分分解70番号・分類15番号・未評価26番号です。
全体2,507番号は部分分解1038件、分類104件、未評価1,365件で、今回36件減、goal有効化から98件減です。
主引用653番号、いずれかの引用1,318番号、候補の棚卸しは0件1,829、1件375、2件以上278です。
分解、milestone目標、範囲、人のreviewは未完で、率や承認を捏造しません。

互換な通常evidenceは以前の1313入力をすべて保持し、pass 1167件、known 159件です。内訳は実行時初回差分117件、API欠落build 16件、DPI未link build 26件です。
別command-line evidenceはpass 17／known 1、HDL VPIはpass 7／fail 1のままです。guest evidenceは未変更1085入力で、現在の241 IDは未測定です。
tool単体101件、全1326 metadata、台帳／索引／library同一性、互換実行記録、日英10組のFAQ 179回答・用語200語を照合します。
全runner／tool、以前のsimulation入力、CI、catalog、scope、library lock、license、Issue方針、SVG 6 asset、別VPI記録は未変更です。
goalは有効で、task-readの境界条件、encode／decode配列、既定formatterの完全性、印刷されたwriteの可視性／virtual性、
parent-sequenceのdo_clone、predictorの診断severity、その他すべての部分分解した義務を保持します。

## M1〜M4の薄い領域の33回目の拡充

継続goalの5反復目でM3の17検査系を追加し、遅延task read 2件、callback pipeline／既定比較対象5件、sequence／frontdoorの型・名前3件、
直接／layered translation 3件、super-bodyの警告／戻らない検査1件、virtual model選択1件、HDL parameter 2件を扱います。
13件は最終入力でseed 1・73一致、encode／decode伝播4件はseed 1で最初に異なり、seed 73の結果はありません。全体1343件、M1 447件、M2 470件、M3 426件です。
callbackの順序は一致しますが、配列変更が後段callback／最終記憶域や戻り値へ届きません。非可換な2操作とmemory値2要素を使い、
検査側で書戻しを修復せず、規範的な変換値を保持します。実際の既定callbackの無変更比較対象は一致します。
実translationはupstream／bus sequencer、独自adapter、遅延driverを使い、write失敗／再試行を含めます。選択した不正なsuper-body呼出しはwarningを出し、cleanup前には戻りません。
parameter probeはmacroから導く宣言integer値を比較し、実装の数値既定値を固定せず、HDL実行も主張しません。

AI要求案28件で台帳1856件、1342テストへ直接対応し、別control 1件があります。以前の要求案はすべて保持します。
個別の構造4件・文脈5件の分類で計113件、構造91件・文脈22件です。第19章は部分分解81番号・分類24番号・未評価6番号です。
全体2,507番号は部分分解1051件、分類113件、未評価1,343件で、今回22件減、goal有効化から120件減です。
主引用664番号、いずれかの引用1,327番号、候補の棚卸しは0件1,818、1件381、2件以上283です。部分分解した義務、milestone目標、範囲、人のreviewは未完で、率や承認を捏造しません。

互換な通常evidenceは以前の1326入力をすべて保持し、pass 1180件、known 163件です。内訳は実行時初回差分121件、API欠落build 16件、DPI未link build 26件です。
別command-line evidenceはpass 17／known 1、HDL VPIはpass 7／fail 1のままです。guest evidenceは未変更1085入力で、現在の258 IDは未測定です。
tool単体101件、全1343 metadata、台帳／索引／library同一性、互換実行記録、日英10組のFAQ 182回答・用語203語を照合します。
全runner／tool、以前のsimulation入力、CI、catalog、scope、library lock、license、Issue方針、SVG 6 asset、別VPI記録は未変更です。
goalは有効で、callback伝播4差分と、残るすべての適用条件、部分分解した義務、解釈の作業を保持します。

## M1〜M4の薄い領域の34回目の拡充

継続goalの6反復目でM1の14検査系を追加し、constructor／型5件、event-pool初期所属1件、raw待ち2件、受理時刻／状態1件、data 2件、混在waiter reset 1件、barrier 2件を扱います。
11件は最終入力でseed 1・73一致、3件はseed 1で最初に異なりseed 73の結果はありません。全体1357件、M1 461件、M2 470件、M3 426件です。
trigger前の公開照会で早いraw waiterを確認しますが、実測条件では2回目のtriggerで初めて再開し、遅いcallerは正しく新triggerまで待機します。
既定event resetでは3 callerが待機してもwaiter 0を報告し、後の新triggerでは全員を解放します。必要なevent-pool名はlazy get前に存在しません。
規範的期待をspec-onlyで保持し、persistent待ち、barrier threshold／reset、scalar複製、live object aliasの別比較対象は一致します。
barrier silent-resetは有限の観測とcleanupを使い、取り残しが起きても公開結果を隠さない構成です。

AI要求案36件で台帳1892件、1356テストへ直接対応し、別control 1件があります。以前の要求案はすべて保持します。
個別の構造7件・文脈7件の分類で計127件、構造98件・文脈29件です。第10章は部分分解65番号・分類15番号・未評価36番号です。
全体2,507番号は部分分解1072件、分類127件、未評価1,308件で、今回35件減、goal有効化から155件減です。
主引用676番号、いずれかの引用1,339番号、候補の棚卸しは0件1,806、1件391、2件以上285です。
pool get_globalの両宣言／本文矛盾、部分分解した義務、milestone目標、範囲、人のreviewは未完です。

互換な通常evidenceは以前の1343入力をすべて保持し、pass 1191件、known 166件です。内訳は実行時初回差分124件、API欠落build 16件、DPI未link build 26件です。
別command-line evidenceはpass 17／known 1、HDL VPIはpass 7／fail 1のままです。guest evidenceは未変更1085入力で、現在の272 IDは未測定です。
tool単体101件、全1357 metadata、台帳／索引／library同一性、互換実行記録、日英10組のFAQ 185回答・用語206語を照合します。
全runner／tool、以前のsimulation入力、CI、catalog、scope、library lock、license、Issue方針、SVG 6 asset、別VPI記録は未変更です。
部分分解した残る義務を含め、goalは有効なままです。

## M1〜M4の薄い領域の35回目の拡充

継続goalの7反復目でM1のobjection／heartbeat 9件とM2のgeneric callback 4件、計13検査系を追加します。
12件は最終入力でseed 1・73一致、1件はseed 1で最初に異なりseed 73の結果はありません。全体1370件、M1 470件、M2 474件、M3 426件です。
実際の既定objection hookが元のsource／description／countでcomponent methodと明示enableした登録callbackへ到達します。
正のdrain後に遅延source hookを実行し、各実行中はroot totalを保持して完了後に0となります。raised／drain中のmode変更はERRORでmodeを保持し、後のidle変更は成功します。
callback宣言、明示enable照会、CB省略add／deleteには正の検査があります。初期のobjection-callback constructor設定は明示名を渡すよう直し、
同一性／状態の期待出力を変えず、subtype constructor省略形は保証しません。mode 0のcallback経路は正しい一方、中間descendant totalを含まないため、2／1の期待をspec-onlyに保持します。
callback_mode省略既定値の矛盾は未解決で、すべて明示引数を使います。

AI要求案28件で台帳1920件、1369テストへ直接対応し、別control 1件があります。以前の要求案はすべて保持します。
個別の構造7件・文脈7件の分類で計141件、構造105件・文脈36件です。第10章は部分分解85番号・分類29番号・未評価2番号で、両方ともpool get_globalの宣言／本文矛盾です。
全体2,507番号は部分分解1092件、分類141件、未評価1,274件で、今回34件減、goal有効化から189件減です。
主引用687番号、いずれかの引用1,354番号、候補の棚卸しは0件1,795、1件401、2件以上286です。部分分解した義務、milestone目標、範囲、人のreviewは未完です。

互換な通常evidenceは以前の1357入力をすべて保持し、pass 1203件、known 167件です。内訳は実行時初回差分125件、API欠落build 16件、DPI未link build 26件です。
別command-line evidenceはpass 17／known 1、HDL VPIはpass 7／fail 1のままです。guest evidenceは未変更1085入力で、現在の285 IDは未測定です。
tool単体101件、全1370 metadata、台帳／索引／library同一性、互換実行記録、日英10組のFAQ 188回答・用語209語を照合します。
全runner／tool、以前のsimulation入力、CI、catalog、scope、library lock、license、Issue方針、SVG 6 asset、別VPI記録は未変更です。
部分分解した残る義務を含め、goalは有効なままです。

## M1〜M4の薄い領域の36回目の拡充

継続goalの8反復目でM2の13検査系を追加し、interface parameter／委譲、FIFO-base生成、port既定値／constructor 3件、FIFO／transport／analysis 8件を扱います。
12件は最終入力でseed 1・73一致、1件はbuildで失敗して実行時seed evidenceはありません。全体1383件、M1 470件、M2 487件、M3 426件です。
REQだけ指定するbidirectional検査は規格の独立integer RSP既定値を保持し、固定RSP=REQは正確なstring／int基底引数検査で失敗します。
全int既定と明示packed要求／応答transportは一致します。新しい宣言既定値build区分をAPI欠落／DPI未linkと分けます。
FIFO状態、object head availability、公開export、blocking／nonblocking転送、analysis broadcastを観測し、容量0のis_fullと概要alias／imp-parameter文言は未完です。
constructor probeはbinding解決を認定せず、整形／名前の調整はoracleを変えず最終測定前に完了しました。

AI要求案35件で台帳1955件、1382テストへ直接対応し、別control 1件があります。未変更のindex付きimp 1検査系へ直接要求対応を加え、以前のsource／evidenceを保持します。
以前の要求案はすべて保持します。個別の構造11件・文脈13件の分類で計165件、構造116件・文脈49件です。第12章は部分分解108番号・分類28番号・未評価78番号です。
全体2,507番号は部分分解1113件、分類165件、未評価1,229件で、今回45件減、goal有効化から234件減です。
主引用699番号、いずれかの引用1,359番号、候補の棚卸しは0件1,783、1件412、2件以上287です。部分分解した義務、milestone目標、範囲、人のreviewは未完です。

互換な通常evidenceは以前の1370入力をすべて保持し、pass 1215件、known 168件です。内訳は実行時初回差分125件、API欠落build 16件、応答既定型の宣言build 1件、DPI未link build 26件です。
別command-line evidenceはpass 17／known 1、HDL VPIはpass 7／fail 1のままです。guest evidenceは未変更1085入力で、現在の298 IDは未測定です。
tool単体101件、全1383 metadata、台帳／索引／library同一性、互換実行記録、日英10組のFAQ 191回答・用語212語を照合します。
全runner／tool、以前のsimulation入力、CI、catalog、scope、library lock、license、Issue方針、SVG 6 asset、別VPI記録は未変更です。
部分分解した残る義務を含め、goalは有効なままです。

## M1〜M4の薄い領域の37回目の拡充

M2の13検査系で、channel既定型／継承とconstructor同一性、省略／固定1枠のqueue容量、analysis型／constructor metadata、直接imp配送、多段export fanoutを追加しました。
TLM 2 probeは、正確な既定／独自interface型とvirtual経路、継承した制約付きrand field、payload名／sequence-item継承／初期incomplete status、7 statusのvirtual応答照会を扱います。
独自interface algorithmは設定で、全bus targetや全protocolを認定しません。

新規13件と引用を修正した既存command 1件はseed 1・73で一致します。
初期predicate counterがerror照会から内部呼出しするOK照会まで制約していた点を、選択した外部呼出しだけを数えるguardへ修正し、規範的出力を変えず再測定しました。
通常snapshotは旧入力の未変更1382記録を保持し、全1396件（pass 1228／known 168）、M1 470件、M2 500件、M3 426件となります。
別HDL／command-line条件はpass 7／fail 1、pass 17／known 1のままで、全runner／library／他の旧入力は未変更です。

要求案46件を追加して計2001件となり、以前の1955要求は全て保持します。個別分類6件を追加します。
12.2.9.2の再読で独立した固定容量義務を確認したため、以前の文脈分類を削除して直接要求2件へ置き換えます。
部分分解1141番号・分類170番号（構造119／文脈51）・未評価1196番号で、第12章は136／33／45です。
継続goalの9反復目は未評価33番号を減らし、有効化以降267番号を減らしました。
TLM 1の未評価番号は0ですが、部分分解の義務と全milestone目標は未完です。

引用を変更したcommand 1入力は旧guest指紋と一致しなくなりました。歴史的1085記録のfileは保持し、現在と互換なcopyは1084入力です。
Ghostは各seedでpass 207／fail 877、kirimasimはunsupported 1075／fail 9で、未測定312入力は追加311件と変更した既存1件を含みます。
guest実行は主張しません。tool unit 101件、metadata、台帳／library、日英資料の検査を通過しました。
範囲と分母は未承認で、goalは継続します。

## M1〜M4の薄い領域の38回目の拡充

M2の12検査系で、合法／既定extension生成、8種全socket宣言、通常port／export／imp既定値、実既定imp binding、明示／親socket実装選択、独自phase双方向relay、blocking relay完了／再利用、選択合法／禁止provider接続を追加します。
9件はseed 1・73一致で、限定解釈probe 3件はseed 1で最初に異なりseed 73結果はありません。
blocking見出しの印刷nonblocking provider一覧は拒否され、同種initiator接続はERRORを報告してもraw直接entryを保持し、targetは残しません。
不具合の証明ではなく照合可能な解釈です。実動blocking比較対象は一致します。
初期のpacked-stringラベルpaddingは修正して両seedで再実行し、oracleは変えていません。

以前の1396入力／記録、2001要求案、170分類は全て保持します。全体1408件（M1 470／M2 512／M3 426）、通常pass 1237／known 171（実行時の最初の差分128／build 43）です。
別HDL／command-line記録はpass 7／fail 1、pass 17／known 1です。guest部分集合は互換1084入力のままで、Ghostは各seedでpass 207／fail 877、kirimasimはunsupported 1075／fail 9です。
未測定324入力は追加323件と以前に引用を変更したcommand入力で、guest実行は主張せず、runner／library／schema／catalogは未変更です。

AI要求案83件で計2084件、個別構造分類12件で計182件（構造131／文脈51）です。規範的概要は除外せず部分対応へ残します。
第12章は部分分解169／分類45／未評価0で、全体は部分分解1174／分類182／未評価1151です。
goalの10反復目は未評価45番号を減らし、有効化以降312番号を減らしました。第12章の未評価0は残る義務の完了ではありません。
tool unit 101件、metadata、台帳／library、互換evidence、日英資料の検査を通過しました。範囲と分母は未承認で、M1〜M4 goalを継続します。

## M1〜M4の薄い領域の39回目の拡充

台帳schema 2で、以前の出力anchorを保持してcompile診断linkを追加します。compile stage、正確な有効宣言regex、実際の不正elaboration metadataを要求し、runtime／混在期待を拒否します。
schema 1も引き続き読め、意味のある回帰9件でtool unitは110件です。レポートに検査種別件数と明示的な台帳schema版を追加し、計数単位、範囲、古い入力の検出は保持します。

新規elaboration 8検査は、virtual transaction、report catcher、wrapper、component、TLM extension base、typed sequence、frontdoor／backdoorの直接生成を扱います。
全て対象compiler errorで拒否され、binary／実行時seedは実行しません。未変更の具象／proxy runtime control 8件は別に保持します。
以前の1408入力／記録、2084要求object、182分類は全て保持し、新規8要求案で2092件です。未評価宣言4件を部分対応へ進め、既存部分条項4件へ禁止条件を追加しました。
部分分解1178／分類182／未評価1147で、goalの11反復目は未評価4番号を減らし、有効化以降316番号を減らしました。M1〜M4全体のgoalは継続します。

全1416検査系はsimulation 1408・elaboration 8で、M1は474（470／4）、M2は514（512／2）、M3は428（426／2）です。括弧内はruntime／elaboration順です。
通常Verilatorはruntime両seed一致1237と期待compiler拒否8（pass計1245）、既知simulation差分171です。
guestは互換runtime 1084入力のまま、未測定332入力（runtime 324・elaboration 8）があり、別HDL／command-line記録は未変更です。

runner／library／catalogの同一性は保持します。workflowのcomment／step名、日英の2つの測定図とガイドはcompiler拒否とruntimeを区別するよう更新し、SVG 4枚をrenderして見た目も確認しました。
tool unit 110件、metadata、台帳／library、互換evidence、日英資料を検証しました。範囲と分母は未承認で、新しい人のレビューやguest測定は主張しません。

## M1〜M4の薄い領域の40回目の拡充

negative elaboration 14件で、database hook 4つ、link hook 4つ、catcherのcatch、subscriberのwrite、visitorのvisit、adapter converter 2つとconst参照変更を分離します。
12件は必要な診断で拒否されます。subscriber／visitorの欠落はcompileに成功するため、拒否oracleを変えずspecのみを維持します。
不正designはbinary／runtime seedを実行しません。初回のregex escape／分類patternを最終測定前に修正し、規範的期待は変えません。

正のfixture 3件は、public wrapper経由のrecording hook、型付きanalysis export経由のsubscriber配送、adapter converter signature／参照効果の具象実装を継承し、全件seed 1／73で一致します。
独自payload algorithmは準備で規定library動作ではありません。以前の1416入力／記録、2092要求、182分類を全て保持します。
日英AI案29件で2121件とし、個別に読んだmethods見出し1件を構造分類します。未評価の規範的7番号は部分対応へ進めます。
合計は部分分解1185／分類183／未評価1139です。goal第12反復で未評価が8番号、有効化以降324番号減り、goalは継続します。

全1433検査系はsimulation 1411／elaboration 22です。M1 485（471／14）、M2 516（513／3）、M3 432（427／5）です。
通常Verilatorは1260 passで、runtime両seed一致1240件とcompiler拒否20件です。既知173件はsimulation差分171件と不正compile受理2件です。
guest evidenceは互換なruntime 1084入力を保持し、未測定349件（simulation 327／elaboration 22）です。別のHDL／command-line evidenceは未変更です。
tool test 110件、metadata、台帳／library、現入力evidence、日英資料の検査は全て成功します。
runner／library／catalog、schema、workflow、SVGは未変更です。guest実行、人のレビュー、範囲／分母承認は主張しません。

## M1〜M4の薄い領域の41回目の拡充

M1 13検査系でreporting constructor／既定設定、共有reset／filter連携、catcher／compose／execute順序、message database handle、使用severity queue、global server統計転送、fatal／warning helper迂回／既定field、実file経路、summary出力先／既定引数、抽象server直接生成を追加します。
runtime 11件はseed 1／73で一致し、抽象生成は対象errorで拒否されruntimeは実行しません。
共有reset 1件はseverity／ID verbosityを保持してseed 1で最初に異なりseed 73結果はなく、既定復帰oracleは維持します。
初回のconstructor／global準備／初期counterのfixture誤りを修正しました。独自の追加ID-count setterは固定pure interfaceを満たす準備だけで、非標準APIを要求とはしません。custom hook本体も準備です。

以前の1433 fixture入力同一性／記録と全分類を保持します。日英AI案56件で2177件です。以前の3項目は元linkを保持して直接anchorと制限注記を補強します。
整理見出し7件と文脈概要1件を個別に分類し、規範的概要は部分対応に保持します。全体は部分分解1218／分類191／未評価1098、第6章は96／19／2で、do_print 2条項と部分条件が残ります。
goal第13反復で未評価が41番号、有効化以降365番号減り、M1〜M4の完了は未実証でgoalを継続します。

全1446検査系はsimulation 1423／elaboration 23で、M1 498（483／15）、M2 516（513／3）、M3 432（427／5）です。
通常Verilatorは1272 passで、runtime両seed一致1251件とcompiler拒否21件です。既知174件はruntime差分129件、simulation build差分43件、不正compile受理2件です。
guest evidenceは互換なruntime 1084入力を保持し、未測定362件（simulation 339／elaboration 23）です。別のHDL／command-line evidenceは未変更です。
tool test 110件、metadata、台帳／library、現evidence、日英資料の検査は成功します。schema、runner／library／catalog、workflow、SVGは未変更です。
guest実行、人のレビュー、範囲／分母承認は主張しません。

## M1〜M4の薄い領域の42回目の拡充

M1 26 fixtureでmessage／handler print observer、printer field／user hookと履歴順序、無効hook、再帰／depth、scalar／array構造、radix control／値、root名、prefix、constructor／base型、default-instance回復、種類別flush／separatorを追加します。
runtime 16件はseed 1／73一致、virtual生成2件は対象errorで拒否されruntimeは実行しません。printer 8件はseed 1で最初に異なりseed 73結果はありません。
差分はSHALLOW、entry-depth境界、超過済みscope、無効radix prefix、root既定値、format-control flush 3 fixtureです。等号解釈は限定し、上限超過probeは独立に保持します。
独自observerはraw整数とdecimal generic値を受け、非公開field名や既定文面はoracleにしません。

以前の1446 fixture入力同一性／記録と分類は全て保持します。重複案2件を削除した日英AI案97件で2274件です。以前のconstructor 1項目へ直接linkを加え、元linkとfieldを保持します。
整理見出し11件と表現を説明する導入2件を個別分類し、文脈項目には具体的関連義務を示します。全体は部分分解1273／分類204／未評価1030です。
第6章は98／19／0、第16章は132／13／63で16.2.10は未評価、部分義務は全て残ります。goal第14反復で未評価68番号、有効化以降433番号減り、M1〜M4全体のgoalは継続します。

全1472件はsimulation 1447／elaboration 25、M1 524（507／17）、M2 516（513／3）、M3 432（427／5）です。
通常Verilatorは1290 passで、runtime両seed一致1267件とcompiler拒否一致23件です。既知182件はruntime 137、simulation build 43、不正compile受理2です。
guest evidenceは互換なruntime 1084入力を保持し、未測定388件（simulation 363／elaboration 25）です。別HDL／command-line evidenceは未変更です。
tool test 110件、metadata、台帳／library、互換evidence、日英資料の検査は成功します。以前のpacker link labelを実fixture幅の128-bitへ訂正し、fixtureとevidence自体は変えません。
schema、runner／library／catalog、workflow、SVGは未変更です。新guest実行、人のレビュー、範囲／分母承認は主張しません。

## M1〜M4の薄い領域の43回目の拡充

M1 29 fixtureでcomparer／copier／packer constructor、base／type同一性、default wrapper、wide比較／pack、comparer message／threshold、copy所有関係、field／user／history順序、recorder設定、open-record flush、既定object hook、attribute override、分離したabstract／pure-hook宣言禁止7件を追加します。
runtime 15件はseed 1／73一致、compiler拒否7件はruntimeなしで一致します。runtime 7件はcopier名、comparer／copy reset、SHALLOW child compare／copy、wide-size error、recorder radix resetでseed 1の初回差分です。
SHALLOWと既定field flagの読み方は限定して保持します。独自observerの誤りは最終測定前に修正し、不一致で規範的期待値を置換しません。

以前の1472入力／記録と分類204件は全て未変更です。日英案74件で2348件とし、既存義務8件へ他fieldと元linkを保持して直接linkを追加します。
構造13件と文脈5件の分類は明示根拠と関連義務を保持します。全体は部分分解1315／分類222／未評価970、第16章は174／31／3です。
章、table-format、recorder lifecycle／link概要は未完了です。goal第15反復で未評価60番号、有効化以降493番号減ります。

全1501件はsimulation 1469／elaboration 32、M1 553（529／24）、M2 516（513／3）、M3 432（427／5）です。
通常Verilatorは1312 pass（runtime両seed一致1282、期待compiler拒否30）、known 189（runtime 144、simulation build 43、不正compile受理2）です。
guest evidenceは互換なruntime 1084入力を保持し、未測定417件（simulation 385／elaboration 32）です。別VPI evidenceは未変更です。
tool test 110件、metadata、台帳／library、evidence、日英検査は成功します。schema、runner／library／catalog、workflow、SVGは未変更です。
guest実行、人のレビュー、分母承認、goal完了は主張しません。

## M1〜M4の薄い領域の44回目の拡充

M3 runtime 17 fixtureでmanager／memory同一性、region descriptor単位とbyte丸め、包含境界、予約保持、独立control付き他manager／二重解放、反復、設定照会／縮小、default-policy反復randomize、割当失敗、転送委譲6 methodを追加します。
全て最終metadataでseed 1／73に一致します。独自observerの生成／signatureを修正し、失敗read dataは検査しません。
転送spyはwrapper委譲を立証し、物理storage／backendを立証しません。memory burst-writeのoffset省略とregion burst-readのoutput／refの食違いは限定した解釈を保持します。

以前の1501入力／記録と分類222件を全て保持します。日英AI案44件で2392件となり、既存義務8件へ他fieldと元linkを変えず直接linkを追加します。
構造6件と文脈1件の分類で部分分解1337／分類229／未評価941、第18章は227／25／204です。
MAMの未評価6番号にはmode／localityの意味、状態文面、region概要があり、部分条件も全て残ります。goal第16反復で未評価29番号、有効化以降522番号減ります。

全1518件はsimulation 1486／elaboration 32、M1 553（529／24）、M2 516（513／3）、M3 449（444／5）です。
通常Verilatorは1329 pass（runtime両seed一致1299、compiler拒否30）、known 189は未変更（runtime 144、simulation build 43、不正compile受理2）です。
guest evidenceは現在と互換なruntime 1084入力を保持し、未測定434件（simulation 402／elaboration 32）です。別VPI記録は未変更です。
tool test 110件、metadata、台帳／library、evidence、日英検査は成功します。schema、runner／library／catalog、workflow、SVGは未変更です。
guest実行、人のレビュー、分母承認、goal完了は主張しません。

## M1〜M4の薄い領域の45回目の拡充

M2 22 fixtureでsequencer型／名／parent、直接抽象生成禁止、実typed pull connector、virtual interface request／response method、trafficを通じた記録無効化、base grant／send／完了、共通照会を追加します。
runtime新規17件はseed 1／73一致、抽象生成2件はruntimeなしで拒否されます。新規build 2件はinterface request既定値と印刷getterの差を保持し、限定したwait_for_sequences probeはseed 1差分でseed 73結果はありません。
最終測定前にblocking契約を弱めずobserverの共有先を明示しました。

既存rerandomization fixture 1つを正確1回から1回以上のcallbackを許容するよう訂正し、安定ID／期待行を保持して両seed再測定します。
その古いguest記録を除外し、他のguest記録と元の1085記録fileは保持します。重複history案2件を削除した日英案51件で2443件です。
既存義務4件にlinkを追加し、既存rerandomizationの期待／制限を訂正して以前の全IDを保持します。構造7件と文脈7件の分類で部分分解1366／分類243／未評価898、第15章は65／18／2です。
interface導入の矛盾とzero-time relevance guardを保持し、goal第17反復で未評価43番号、有効化以降565番号減ります。

全1540件はsimulation 1506／elaboration 34、M1 553（529／24）、M2 538（533／5）、M3 449（444／5）です。
通常Verilatorは1348 pass（runtime両seed一致1316、compiler拒否32）、known 192（runtime 145、simulation build 45、不正compile受理2）です。
未変更の以前のnative 1517記録と修正入力を保持します。guest互換入力は1083でGhostは各seed pass 207／fail 876、kirimasimはunsupported 1074／fail 9、未測定457（simulation 423／elaboration 34）です。
部分集合件数の変化はfilterで、新実行や改善ではありません。別VPI記録を保持し、tool test 110件、metadata、台帳／library、evidence、日英検査は成功します。
schema、runner／library／catalog、workflow、SVGは未変更で、人のレビュー、分母承認、goal完了は主張しません。

## M1〜M4の薄い領域の46回目の拡充

M1 20 fixtureで第13章componentを補強します。family constructor／名目的型、抽象直接生成5件、environment既定値、
許可名と同名error、child印刷、domain選択／定義、user protocol dispatch、exact driver endpoint／既定put、string agent設定、common／runtime phase callback、exit／pre_abort方向を扱います。
error observerは不正呼出の回復を仮定せず自身で終了します。phaseの鎖は事前生成し、function方向を検査しつつ並行task開始順は未規定のままにします。suspend／resumeはuser dispatchだけを観測します。

runtime 15件はVerilator 5.052のseed 1／73に一致し、対象compiler拒否5件はruntimeを実行しません。
以前の全1540 fixture／入力hash・記録・2443要求・243分類を未変更で保持します。新AI案77件で2520、構造7／文脈10の追加で分類260（183／77）です。
第13章は部分80／分類18／未評価12、全体は1416／260／831で、今回は未評価67減、goal 18反復では632減です。全ての部分条件とmilestone目標は未完了です。

全1560件はsimulation 1521／elaboration 39、M1 573（544／29）、M2 538（533／5）、M3 449（444／5）です。
通常Verilatorは1368 pass（runtime両seed一致1331、compiler拒否37）と未変更known 192です。互換guest fileは1083記録をbyte単位で保持し、未測定477（438／39）は以前の修正2入力を含みます。
別HDL／command-line evidenceは7／1と17／1のままで、新guest実行は主張しません。

tool test 110件、metadata、台帳／索引／library同一性、native生結果とcompiler診断、互換な保持evidence、日英guide 10組の用語239語・FAQ 218回答を検査します。
schema、runner、library／catalog、workflow、SVG 6つは未変更です。範囲は提案、棚卸し未完、分母／割合null、AI照合、goal有効を保持し、人の承認やgoal完了は主張しません。

## M1〜M4の薄い領域の47回目の拡充

M1 runtime 17 fixtureでphase task／forkとcallback-thread寿命、印刷all_dropped function宣言、名前によるtest選択、factory便宜method 6つ、
階層verbosity／action／maximum、実選択log file、virtual recording setterを補強します。11件はVerilator 5.052の両seedで一致します。
runtime差分5件はtask終了、ready-thread完了、型／名前によるreplace 0と名前生成の期待を保持します。
印刷function／task食違い1件はbuildできずruntime seedを実行せず、確定原因は割り当てません。WARNING verbosityは明示的に無視し、設定照会と実reportを分けて観測します。
独自constructorの既定を空にして、user fallback名のpolicyを課さないようにします。

新AI案51件で2571件です。component objection hook義務3つは互換な既存伝播evidenceを再利用し、新実行を主張しません。
以前の全2520要求・260分類・1560 fixture・native記録を未変更で保持します。文脈分類4件で264（183／81）となり、全体は部分1434／分類264／未評価809です。
第13章は87／21／2でerror／event記録番号を残し、付録Dは18／1／28です。未評価は今回22減、goal 19反復で654減で、全ての部分条件は未完了です。

全1577件はsimulation 1538／elaboration 39、M1 590（561／29）、M2 538（533／5）、M3 449（444／5）です。
通常evidenceは1379 pass（runtime両seed一致1342、compiler拒否37）と198 known（runtime 150、simulation build 46、不正受理2）です。
新signature buildはAPI欠落17、型既定build 2、DPI未link 26と区別します。guest fileは1083記録をbyte単位で保持し、以前の修正2入力を含む未測定494（455／39）です。
別HDL／command-line evidenceは7／1と17／1のままで、新guest測定は主張しません。

tool test 110件、metadata、台帳／索引／library同一性、native生結果／compile evidence、用語244語・FAQ 220回答の日英guide 10組を検査します。
schema、runner／library／catalog、workflow、SVG 6つは未変更です。範囲は提案、棚卸し未完、分母／割合null、照合AI、継続goal有効を保持します。

## M1〜M4の薄い領域の48回目の拡充

M1 13 fixtureで独自error／event backend観測、object.recordのnull／委譲直接確認、抽象recording宣言、base constructor／object view、同名link role dispatch、exact callback alias、禁止iterator type_idアクセスを追加します。
runtime 8件は両seed一致、対象compiler拒否4件はruntimeなしです。印刷report_db alias欠落1件はruntimeのない限定build差分に保持します。
timestampはbackend限定解釈で、返却token、string、keep-active handle利用はapplication固有です。alias null値はcompile markerで、user-hook抑制はrecorderの16.4.7.7に対応付けます。

新AI案42件で2613です。以前の全2571 IDを保持し、constructor既定名義務2件へdirect linkだけを追加します。以前の全1577 fixture／native記録と264分類は未変更です。
文脈11／構造4の分類で279（187／92）、全体は部分1461／分類279／未評価767です。今回は42減、goal 20反復で696減です。
第7／13章は50／20／0と89／21／0、付録Dは35／7／5で、未評価0でも部分条件や元のmilestone目標は完了しません。

全1590件はsimulation 1547／elaboration 43、M1 603（570／33）、M2 538（533／5）、M3 449（444／5）です。
通常evidenceは1391 pass（runtime両seed一致1350、compiler拒否41）、199 known（runtime 150、simulation build 47、不正受理2）です。
API／型名欠落18、型既定2、印刷signature 1、DPI未link 26のbuildを区別します。guest fileは1083記録をbyte単位で保持し、以前の修正2入力を含む未測定507（464／43）です。
別HDL／command-lineは7／1と17／1のままで、新guest結果は主張しません。

tool test 110件、全metadata、台帳／索引／library同一性、native生結果／compile evidence、用語249語・FAQ 222回答の日英10組を検査します。
schema、runner／library／catalog、workflow、SVG 6つは未変更で、範囲は提案、棚卸し未完、分母／割合null、照合AI、継続goal有効を保持します。

## M1〜M4の薄い領域の49回目の拡充

M3 runtime 9 fixtureで名前によるregister／memory転送probe 4つ、実frontdoor storage経路2つ、block集約確認3つを追加し、全9件がVerilator 5.052の両seedに一致します。
実configure済みlookup、既定／明示引数、完了待ち、選択data／status、debug専用の機能不変性を観測し、失敗read dataや正確なdebug文面転送は規定しません。
block caseは兄弟順を課さずlocal／子孫の変更有無、全幅最小write、clean時の無write、mirror更新／checkを観測します。新knownはありません。

新AI案65件で2678となり、以前の全2613要求・279分類・1590 fixture／native記録は未変更です。D.3と明示参照18.1.5.7を個別に文脈分類します。
全体は部分1468／分類281／未評価758、付録Dは39／8／0、第18章は230／26／200です。今回は9減、goal 21反復では705減で、部分条件と元のmilestone目標は未完了です。

全1599件はsimulation 1556／elaboration 43、M1 603（570／33）、M2 538（533／5）、M3 458（453／5）です。
D.3の6 fixtureはmetadata規約でuDに置いてregister層M3へ数え、他の3つはu18に置きます。通常evidenceは1400 pass（runtime両seed一致1359、compiler拒否41）と未変更known 199です。
guest fileは互換1083記録をbyte単位で保持し、以前の修正2入力を含む未測定516（473／43）です。別HDL／command-lineは7／1と17／1のままで、guest実行は主張しません。

tool test 110件、metadata、台帳／索引／library同一性、native生結果／compile evidence、用語254語・FAQ 224回答の日英10組を検査します。
英語のDPIなし注記の古いelaboration件数34を43へ訂正します。schema、runner／library／catalog、workflow、SVG 6つは未変更です。
範囲は提案、棚卸し未完、分母／割合null、照合AI、継続goal有効を保持します。

## M1〜M4の薄い領域の50回目の拡充

M3 runtime 10 fixtureでblock constructor／object view、既定／明示coverage利用可能性、flattened HDL path、完全一致scopeのcoverage構築、constructor内だけのcoverage union、全要求有効照会、backdoor継承／置換、任意HDL kind選択を扱います。
9件はVerilator 5.052の両seed一致で、継承HDL kind存在probeは最寄り祖先oracleを保持し、seed 1の差分を残してseed 73は実行しません。
実継承register poke／peekはdebug／失敗／再試行制御の下でroot／child／register-localの独自storageを選びます。metadataはcovergroup測定や物理HDL transportではなく、初期有効既定値は推定しません。

新AI案38件で2716となり、以前の全2678要求・281分類・1599 fixture／native記録は未変更です。18.1と18.1.6を個別に文脈分類します。
全体は部分1481／分類283／未評価743、第18章は243／28／185です。18.1配下の未評価はありませんが部分条件は未完了です。
今回は15減、goal 22反復では720減で、元のM1〜M4目標は未完了です。

全1609件はsimulation 1566／elaboration 43、M1 603（570／33）、M2 538（533／5）、M3 468（463／5）です。
通常evidenceは1409 pass（runtime両seed一致1368、compiler拒否41）とknown 200（runtime 151／build 47／不正受理2）です。
guest fileは互換1083記録をbyte単位で保持し、以前の修正2入力を含む未測定526（483／43）です。別HDL／command-lineは7／1と17／1のままで、guest実行は主張しません。

tool test 110件、metadata、台帳／索引／library同一性、native生結果／compiler evidence、用語258語・FAQ 226回答の日英10組を検査します。
schema、runner／library／catalog、workflow、SVG 6つは未変更です。範囲は提案、棚卸し未完、分母／割合null、照合AI、継続goal有効を保持します。

## M1〜M4の薄い領域の51回目の拡充

M3 runtime 15 fixtureでmap名／object viewとsingleton同一性、local／system bus設定、実入れ子sequencer／adapter置換、map単位の6列挙系列、byte／word memory lookup境界、unmapped memoryの論理frontdoorアクセスを追加します。
13件はVerilator 5.052の両seed一致で、空／register配置済みmap幅caseはroot経路の最小幅2でなくlocal幅8を返すseed 1差分を保持し、seed 73は実行しません。
適用条件の異なるfixtureで、独立に特定した2つの欠陥ではありません。word単位は限定解釈のままとし、この有効幅不一致から単位の欠陥は特定しません。

新AI案57件で2773となり、以前の全2716要求・283分類・1609 fixture／native記録は未変更です。18.2を文脈、18.2.5を構造として個別分類します。
全体は部分1498／分類285／未評価724、第18章は260／30／166です。18.2.3.12は印刷APIからclone内容／rightsの妥当な観測経路を導くまで未評価に残します。
今回は19減、goal 23反復では739減で、部分義務と元のM1〜M4目標は未完了です。

全1624件はsimulation 1581／elaboration 43、M1 603（570／33）、M2 538（533／5）、M3 483（478／5）です。
通常evidenceは1422 pass（runtime両seed一致1381、compiler拒否41）とknown 202（runtime 153／build 47／不正受理2）です。
guest fileは互換1083記録をbyte単位で保持し、以前の修正2入力を含む未測定541（498／43）です。別HDL／command-lineは7／1と17／1のままで、guest実行は主張しません。

tool test 110件、metadata、台帳／索引／library同一性、native生結果／compiler evidence、用語262語・FAQ 228回答の日英10組を検査します。
schema、runner／library／catalog、workflow、SVG 6つは未変更です。範囲は提案、棚卸し未完、分母／割合null、照合AI、継続goal有効を保持します。

現在のknown-build要約をAPI／型名欠落18件、型既定宣言2件、印刷hook signature 1件、未link DPI 26件へ訂正します。以前のbuild 47記録は全て未変更で、別HDL／command-line条件は7／1と17／1です。

## M1〜M4の薄い領域の52回目の拡充

M3 simulation 16 fixtureでregister構築／配置、所属／unregister view、local-map解決、捕捉した全体最大幅、gapのあるfield順、reset種別metadata、model専用getter、gate制御busy、clone call／宣言controlを追加します。
13件はVerilator 5.052の両seed一致で、単一mapのnull／既定選択とlock前field名の2件はseed 1差分を保持しseed 73は実行しません。
字面のclone scalar返却overrideは利用できるmap返却へbuildできずruntimeはありません。公開clone call／source保持は別に一致し、新map内容／rightsは未完了です。

新AI案58件で2831となり、以前の全2773要求・285分類・1624 fixture／native記録は未変更です。個別に読んだ分類5件は文脈2件・構造3件です。
全体は部分1516／分類290／未評価701、第18章は278／35／143です。18.2／18.3配下の未評価番号はありませんが部分義務は未完了です。
今回は23減、goal 24反復では762減で、元の目標は未完了です。

全1640件はsimulation 1597／elaboration 43、M1 603（570／33）、M2 538（533／5）、M3 499（494／5）です。
通常evidenceは1435 pass（runtime両seed一致1394、compiler拒否41）とknown 205（runtime 155／build 48／不正受理2）です。
build 48件はAPI／型名欠落18、型既定2、限定印刷signature 2、未link DPI 26です。guest fileは互換1083記録をbyte単位で保持し、以前の修正2入力を含む未測定557（514／43）です。
別HDL／command-lineは7／1と17／1のままで、新guest実行はありません。

tool test 110件、metadata、台帳／索引／library同一性、native生結果／compiler evidence、用語266語・FAQ 230回答の日英10組を検査します。
schema、runner／library／catalog、workflow、SVG 6つは未変更です。範囲は提案、棚卸し未完、分母／割合null、照合AI、継続goal有効を保持します。

古い日本語の予期しないsimulation build要約45件を現在の48件へ訂正し、両言語の要約で印刷signatureの食違い2件を区別します。資料だけの訂正で、以前のbuild記録は全て保持します。

## 薄い領域の53回目：phase状態・domain・proxyの契約（2026-11-04）

M1の22 fixtureはsimulation 19件とelaboration検査3件です。simulation 15件がseed 1／73に一致し、virtual phase classの直接生成3件はruntimeなしの期待拒否に一致します。
simulation 4件はseed 1の差分を保持しseed 73は実行しません。初期必須domain entry、早期終了taskの寿命、字面のget_imp／get_schedule文であり、後2件のsignature／本文矛盾を明示します。
string receiverだけの検査には、現在の測定前に`$typename`を追加しました。

初期fixtureの問題は現在のevidence集約前に修正しました。registry probeの予約語変数名と、適用component domainを持たない独立走査contextです。
古い結果は現在のsnapshotから除外します。domainへ接続したtop-down／bottom-up走査は祖先順に一致し、兄弟順を仮定しません。

他の一致controlはcallback descriptor／範囲／既定値、後方jump回数／target、遅延target指定、constructor／base view、単一親の名前、domain重複ERRORとruntime挿入、
非同期task proxy引数、1つの21行定義済みgetter matrixを扱います。matrixは9.8の汎用義務3件へ対応し、完全なdelegate coverageではありません。

AI案56件で2887、構造12件と文脈6件の分類で308（203／105）です。全体は部分1556／分類308／未評価643、第9章は67／18／31、付録Fは33／0／104です。
以前の全2831要求・290分類・1640 fixture入力／native記録を未変更で保持します。goalの25反復目は未評価を58減らし、部分義務と元の全milestone目標を保持します。

全1662（simulation 1616／elaboration 46）、M1 625（589／36）、M2 538（533／5）、M3 499（494／5）です。
通常native evidenceはpass 1453（runtime 1409／compiler拒否44）、known 209（runtime 159／simulation build 48／不正受理2）です。
guest 1083記録と別HDL／command-line条件をbyte単位で保持し、以前の修正2入力を含む未測定579（simulation 533／elaboration 46）を残します。guest実行は主張しません。

metadata、台帳／索引、library整合性、tool test 110件、現在のnative／compiler同一性、日英資料検査は成功します。
照合は全てAIで、範囲は提案、分母／割合は未設定、継続goalは有効です。schema、runner／library／catalog、workflow、SVG 6個は未変更です。

## 薄い領域の54回目：delegate・timing・domainの実行（2026-11-04）

M1 simulation 15件は全てseed 1／73に一致します。共有matrix 2個でcommon function phase 8個とtask phase 13個の選択virtual delegateを動かし、contextを保持してpeer／他hookを区別します。
直接task proxyは遅延returnを待ち、executeのforkは別契約として保持します。

レビューでruntime並行検査を、開始markerからactive run-node状態と2単位間隔の独自task heartbeat進行へ強化しました。
再測定した現在の入力が以前の弱い記録を置き換えます。

実engine controlはrun前時刻0、run／final終了時刻一致、12 runtime phaseの順序／非重複とstart／extract境界、run並行性を検査します。
lockした絶対timeoutは保持した上限でFATALを報告し、overridable省略呼出しは後の上限を許します。run段落の参照F.7.2.3に対して実際のtimeout定義F.7.3.3を引用します。

task走査はdomainに接続した部分木の独自遅延proxyでSTARTED／EXECUTING／READY_TO_END／ENDEDを扱います。
特化component proxyは型ごとのsingleton同一性と共通phase viewを保持します。6 domain fixtureは独立、同名／異名phase同期、選択／全体／明示解除、保持する関係を分けます。
並行jumpは両方の関連active分岐を再開し、独立peerは1回完了します。新しい既知差分はありません。

AI案47件で2934、文脈分類4件で312（構造203／文脈109）です。全体は部分1584／分類312／未評価611、第9章は94／22／0で案138件、付録Fは34／0／103です。
以前の全2887要求・308分類・1662入力／native記録を未変更で保持します。goalの26反復目は未評価を32減らし、全ての部分条件や元のmilestone目標は認定しません。

全1677（simulation 1631／elaboration 46）、M1 640（604／36）、M2 538（533／5）、M3 499（494／5）です。
通常evidenceはpass 1468（runtime 1424／compiler拒否44）、known 209（runtime 159／simulation build 48／不正受理2）です。
guest 1083記録とHDL／command-line条件をbyte単位で保持し、以前の修正2入力を含む未測定594（simulation 548／elaboration 46）を残します。guest実行は主張しません。

metadata、台帳／索引、library、tool test 110件、native／compiler同一性、日英資料検査は成功します。
重複したphase定義の用語entryを統合し同期の用語を追加し、全268語を保持します。照合は全てAI、範囲は提案、分母／割合は未設定、goalは有効です。
schema、runner／library／catalog、workflow、SVG 6個は未変更です。

## 薄い領域の55回目：factory一覧とbuilt-in registryの契約（2026-11-05）

M1 factoryの19 fixtureはsimulation 18件とelaboration 1件です。simulation 12件はseed 1／73に一致し、virtual uvm_factory生成はruntimeなしのcompiler拒否に一致します。
合法simulation 4件はbuildできず、transaction／report-serverのtype_id欠落とsubscriber／sequenceの継承registry特殊化非互換です。
未知名2 fixtureはnullを返して登録controlを生成しますが、seed 1で必要なERRORを観測せずseed 73はありません。独立sequence-base probeは一致し、停止matrixの結果を流用しません。
7 category fixtureと分離2 probeは固有built-in宣言14個を選択し、全8 categoryやpackage全型ではありません。レビューで宣言aliasをruntime castなしの静的な双方向代入へ強化し、現在の版を再測定します。

printの0／省略／1／2選択は固定table構文なしで検査します。stdoutとstderrを別々に囲み、runtime message regexで分割内容も含めた和集合を調べます。
UT markerだけでは内容欠落をpassできません。local predicate検査52個は空／欠落／禁止内容と囲み外の名前を拒否します。
独自proxyは表現instance生成なしの登録、by-name／by-type委譲、名前／parentを観測します。未知名controlは不正要求より前へ置き、規定のないerror後registry状態をoracleにせず、ERROR／nullの期待を維持します。初期fixtureの予約語変数名を修正後、default-factory拡張は一致し、古いbuildを除外します。
global active viewは概要の単一instance記述に関する限定解釈を保持します。

AI案28件で2962、構造6件と文脈2件の分類で320（209／111）です。全体は部分1592／分類320／未評価595、第8章は60／12／0で案83件です。
以前の全2934要求・312分類・1677 fixture入力／native記録を未変更で保持します。goalの27反復目は未評価を16減らし、部分義務と元のmilestone目標は未完了です。

全1696（simulation 1649／elaboration 47）、M1 659（622／37）、M2 538（533／5）、M3 499（494／5）です。
通常evidenceはpass 1481（runtime 1436／compiler拒否45）、known 215（runtime 161／simulation build 52／不正受理2）です。
guest 1083記録と別HDL／command-line記録をbyte単位で保持し、以前の修正2入力を含む未測定613（simulation 566／elaboration 47）を残します。guest実行は主張しません。

metadata、台帳／索引、library、tool test 110件、print predicate検査、native／compiler同一性、日英資料は成功します。
照合は全てAI、範囲は提案、分母／割合は未設定、goalは有効です。schema、runner／library／catalog、workflow、SVG 6個は未変更です。

## 薄い領域の56回目：memory選択と実HDL array（2026-11-05）

M3 memory 17 fixtureで具象constructor／既定値、保存した幅最大値、公開allocation-managerの連続／vreg予約、
正確なlocal virtual-register／field列挙と検索分離を追加します。mapごとのcustom frontdoorはdebug metadataでも独立storageを保持し、
継承／local user backdoorは実際のmodel access、拒否、retryを動かします。ROMのmodel writeはstorageを保持し、pokeは直接depositします。
concat座標／重複、ancestor path直積、階層coverage-resource選択は独立したmetadata probeです。

通常11 fixtureは両seed一致で、2件はseed 1で初めて異なりseed 73は実行しません。local-only照会が以前に継承してcacheしたbackdoorを返し、
coverage setterが以前でなく新maskを返します。合法な公開read宣言build 1件はprotected accessで停止し、task本体は実行しません。
独立した公開write宣言は一致します。実arrayの通常build 3件はDPI未linkでruntime結果がありません。

その物理3 fixtureは、未変更の独自VPI backendで別に両seed一致します。選択16-bit memory word、24-bit分割bank、ROM writeとpoke／read／peekを検査します。
独自派生wrapperは公開read契約を修復せず継承基底taskへ達します。以前のHDL 8記録を未変更で保持し、11件中10一致／保持するE.7差分1件となります。
これらの限定two-state array結果で一般HDL supportを示しません。

初期の幅最大値fixtureは予約語の変数名を使い、初期path設定は空ancestor pathも含めていました。両設定問題を修正して再測定してから現在の対象へ含めます。
有効な期待を観測した失敗出力で置換していません。oracle tag追加後の現在入力を指紋で結びます。

日英AI案31件で2993、個別に読んだ構造見出し7件で分類327（構造216／文脈111）です。第18章は部分298／分類42／未評価116で案606、全体は1612／327／568です。
goalの28反復目は未評価を27減らし、元のmilestone目標と全ての部分義務を未完了で残します。以前の全2962要求・320分類・1696通常入力／記録を未変更で保持します。

全1713（simulation 1666／elaboration 47）、M1 659（622／37）、M2 538（533／5）、M3 516（511／5）です。
通常結果はpass 1492（runtime 1447／期待compiler拒否45）とknown 221（runtime 163／simulation build 56／不正compiler受理2）です。
guest 1083とcommand-line記録をbyte単位で保持し、以前に修正した2入力を含む未測定630（simulation 583／elaboration 47）を残します。guest実行は主張しません。

tool test 110件、metadata、台帳／索引、library、現在の入力／native／compiler同一性、日英資料の検査は成功します。
FAQと用語を各2件追加し、237／271件です。人のレビュー、分母承認、完了は主張しません。schema、runner／library／catalog、backend、workflow、SVG 6件は未変更です。goalは継続中です。

## 薄い領域の57回目：package契約とrun callback（2026-11-05）

M1のpackage／run-test callback 18 fixtureで、runtime 13件が両seed一致、1件が期待compiler拒否一致、4件がseed 1 runtime差分となり、差分のseed 73は実行しません。
generic reportは必要なNONE 0に対しWARNING 200／ERROR 100を観測し、warning helperも0でなく200です。明示message／debug／context fieldは独自root handler経由で一致します。

callbackの所属返却値は一致しますが、後のhandleを削除すると配送回数が異なり、削除handleもhookを受けます。削除なしの独立fixtureは両hookを受けますが、
pre-run callbackでUVM_CORE_PRE_RUNでなくUVM_CORE_INITIALIZEDを観測し、post-run stateは一致します。これらは独立した要求とknown入力です。
別の直接die fixtureでabort通知、componentからcallbackの順序、finalのABORTED stateが一致し、peer callback間の順序は規定しません。

一致controlはmacro選択のsigned bitstream、signed 64-bit integral、actionのone-hot／容量、実file／MCD格納、標準handle、global reporter／enabled照会、
事前check済み／形成済みreport委譲、後続初期化、constructor名、virtual基底拒否も扱います。signed shift fixtureはunsigned比較contextの前にshiftを保存する形へ修正し、古い差分を除外してUVMへ割り当てません。
four-state保持、最初の非null初期化、全registry hook、完全なabort／report／終了の組合せは別監査に残します。

package監査はM1の18 fixtureへAI案38件を追加し、選択型／macro契約、action-vector容量、FD／MCDと標準handle、global reportingの既定値／委譲、
反復初期化、callback所属と実配送、run-state境界、abortを分けます。

report既定値の2 fixtureはparameter値の差分を保持し、明示fieldの一致で入力全体をpassにしません。所属返却値でどのcallbackを削除したかは認定しません。
別の削除なしfixtureで、配送差分とpre-run state差分を分離します。直接dieは明示F.7.3.2手順を使い、F.2.10のABORTEDにあるpost_run callback記述は別解釈問題として残します。
観測library実装でoracleを定義しません。

個別に読んだ分類見出し13件を構造、callback導入をhook／登録義務に関連する文脈に分類します。付録Fは部分56／分類14／未評価67で案91件です。
B.6.2へ選択macro義務2件を追加し、付録Bは部分39／分類0／未評価105で案50件です。全体は部分1635／分類341／未評価531（構造229／文脈112）です。
以前の全2993要求・327分類を未変更で保持します。型のX／Z動作、全enum意味、最初の非null初期化、registry hook、callback変更／再入、完全なrun／abort経路は未対応です。
全1731（simulation 1683／elaboration 48）、M1 677（639／38）、M2 538（533／5）、M3 516（511／5）です。
通常evidenceはpass 1506（runtime 1460／compiler拒否46）、known 225（runtime 167／simulation build 56／不正compiler受理2）です。
以前の全1713通常記録・2993要求・327分類を未変更で保持し、guest 1083／HDL 11／command-line 18記録はbyte単位で同一です。
guest未測定は修正した2入力を含む648（simulation 600／elaboration 48）です。

goalの29反復目は未評価を37減らして531を残し、全ての部分義務は未完了です。tool test 110件、metadata／台帳／library、evidence同一性、日英資料検査は成功し、FAQ／用語は239／273件です。
schema、runner／library／catalog／backend、workflow、SVG 6件は未変更です。guest実行、人のレビュー、分母承認、完了は主張しません。goalは継続中です。

## 薄い領域の58回目：resource、scope、型付きstorage（2026-11-05）

M1 resource 32 fixtureで、runtime 24件が両seed一致、4件が期待compiler拒否一致、3件がseed 1 runtime差分でseed 73なし、合法拡張1件がruntimeなしのbuild差分です。
不在name lookupは必要な既定warningを出しません。独立に測定したlocal／global poolの両caseは割当precedence 3／9を保持しますが、
nameでは必要な最大値でなく最初のresourceを返し、type priorityとqueueは一致します。localの公開constructor／singleton境界は限定解釈として明示します。

独自の2拡張に明示名と省略のbase constructor直接呼出しを別々に宣言し、規格に記載されたpure type hookを実装しますが、固定libraryは追加の記載外pure helperも要求するためcompileできず、合法宣言をspec-onlyで保持します。
別のtype-hook欠落negativeは必要なget_type_handle拒否を分離する独自compatibility本体を使い、合法拡張を修復しません。
他negativeはvirtual基底の直接生成と非互換型read／write contextを拒否し、それぞれruntime seedなしで独立した合法controlを持ちます。

一致controlは正確なqueue／DB alias、既定resource／DB型、constructor名、static／多態token、scalar／string／queue copyとobject handle同一性、
read-only ERROR／storage、同値／拒否write通知の抑制、変更writeで待機全員の解放、scope置換／削除、null insert warning、name／type／bothのpriority／override、
最初の最大値queue、core-service pool／既定値選択、DBの値／同一性／失敗read sentinel／共有scope writeを扱います。

初期accessor設定はabstractなuvm_objectを直接生成していました。独自具象accessor classへ置換して再測定し、古い設定buildをUVMへ割り当てず除外します。
期待出力は規格から導いたままです。constructorの本文／prototype差、lookup_typeのqueue／便利説明の矛盾、type-priorityと広いlookup記述の食違い、
type-write本文のname-based参照は明示解釈に残し、成功writeの返却値は作りません。

resource監査はM1の32 fixtureへAI義務63件を追加し、constructor／宣言surface、正確なalias／type token、選択payload／型安全性、
read-only／通知、pool所有／scope／map／precedence、core既定値、型付きDB操作を独立した条件／観測で扱います。
同値／拒否writeはwaiterを保持し、変更writeは両waiterを解放します。name／type／bothのpriorityとoverrideは独立した6 fixtureで、停止した共有matrixの行を流用しません。

runtime差分3件と記載外pure-hookの合法build差分を保持します。pure-hook negativeの追加した独自compatibility本体は規格hookの拒否を分離するもので、未修正拡張をpassにはしません。
割当数値precedenceはname選択と独立に観測し、global／local pool結果は独立した現在入力です。singleton／constructorとlookup／type／write本文の解釈境界を残します。

個別に読んだ見出し10件を構造、導入2件を関連義務のある文脈に分類します。付録Cは部分52／分類12／未評価20で案68件、core-service義務4件により付録Fは60／14／63で案95件です。
全体は部分1687／分類353／未評価467（構造239／文脈114）で、以前の全3031要求・341分類は未変更です。
Cの残りはoverview／印字契約、sortの同値順、regex／scope collection、型filter付き最大precedence、static DB／config継承／便利alias、不正precedence引数、全ての部分lifecycle／並行条件です。
いずれの件数も完全適合を示しません。
全1763（simulation 1711／elaboration 52）、M1 709（667／42）、M2 538（533／5）、M3 516（511／5）です。
通常結果はpass 1534（runtime 1484／compiler拒否50）、known 229（runtime 170／simulation build 57／不正compiler受理2）です。
以前の全1731通常記録・3031要求・341分類を未変更で保持し、guest 1083／HDL 11／command-line 18記録はbyte単位で同一です。
guest未測定は修正2入力を含む680（simulation 628／elaboration 52）です。

goalの30反復目は未評価を64減らして467とし、全部分義務と元の目標は未完了です。tool test 110件、metadata、台帳／library、evidence同一性、日英資料検査は成功し、FAQ／用語は242／275件です。
schema、runner／library／catalog／backend、workflow、SVG 6件は未変更です。guest実行、人のレビュー、分母承認、完了は主張せず、goalは継続中です。

## 薄い領域の59回目：sequencer上限とtransaction event（2026-11-05）

M2 sequencer 9 fixtureを追加し、8件が両seed runtime一致、1件がseed 1 runtime差分でseed 73なしです。
relevance guardは時刻0で省略時10、明示2／12、base view経由のvirtual setterに一致します。
時刻3に3を設定して新しいzero-time burstを始めると、通知はcallback 5回目となります。
保持する限定oracleは上限または最初の超過（3／4回）での通知を許すため、spec-onlyに残します。
生のcallback回数／時刻は境界predicateと分け、未指定のerror通知としてERROR／FATALを許容し、正確なseverity／ID／文面規則は作りません。
counter reset、負上限、error後の復旧動作も作りません。

実pull-port転送は自動の指定begin／end通知とtimestamp、初回要求前の無効化による抑止、モデル化したpipeline完了を制御する明示component recording、
独立した独自address／data eventに一致します。規格typed callbackはtransaction-pool entryを観測し、登録は初期pool所属の証明ではありません。
物理DUT完了、recorder handle配置、DB形式は認定しません。interface overviewの継承記述と実class宣言の矛盾は未解決に残し、新たな継承規則にはしません。

新しいlibrary-utils義務1件を未変更macro fixture 4件へ対応付けます。派生subtypeを含む各拡張は既に自身の正確な型で必要macroを呼んでいます。
空のstatic membership差分は未変更で保持し、追加の実装init helperや新たな実行は主張しません。

sequencer監査はM2の9 fixtureと未変更library-macro入力4件へAI義務16件を追加します。
既定／明示／正時刻のrelevance上限とvirtual dispatchは独立した条件を持ちます。実pull転送で自動event／時刻、無効化の副作用、
早いackとモデル化した完了、独自address／data通知gateを区別します。正時刻の上限差分は限定結果に残し、他の新規fixtureは両seed一致です。
正確なerror識別や復旧policyは仮定しません。

B.3.2.2のstatic-list義務を既存のB.3.2.1／B.3.2.2共同観測へ直接対応し、派生型は既に必要なmacroを含みます。
個別に読んだ見出し2件を構造、導入2件を文脈に分類し、規範的な15.2.1 overviewは継承矛盾も含めて部分的に残します。
第15章は部分67／分類18／未評価0で案131件、付録Bは40／4／100で案51件です。第15章の未評価0は残り条件の完了を意味しません。
全体は部分1690／分類357／未評価460（構造241／文脈116）で、以前の全3094要求・353分類は未変更です。
元のM1〜M4目標と全ての部分義務は未完了です。

全1772（simulation 1720／elaboration 52）、M1 709（667／42）、M2 547（542／5）、M3 516（511／5）です。
通常結果はpass 1542（runtime 1492／compiler拒否50）、known 230（runtime 171／simulation build 57／不正compiler受理2）です。
以前の全1763通常記録・3094要求・353分類は未変更で、guest 1083／HDL 11／command-line 18記録はbyte単位で同一です。
guest未測定は修正2入力を含む689（simulation 637／elaboration 52）です。

goalの31反復目は未評価を7減らして460（開始から1003減）とし、全部分義務と元の目標は未完了です。
初期のreport-catcher引用誤記と生成したindentを最終入力再測定前に修正し、設定誤りをlibrary差分にはしません。
tool test 110件、metadata、台帳／library、evidence同一性、日英資料検査は成功し、FAQ／用語は245／277件です。
schema、runner／library／catalog／backend、workflow、SVG 6件は未変更です。guest実行、人のレビュー、分母承認、完了は主張せず、goalは継続中です。

## 薄い領域の60回目：builtin sequence宣言と実行中child slot（2026-11-05）

M3の29 fixtureを追加し、24件が両seed runtime一致、2件が期待protected-access拒否一致、2件がseed 1のconstructor名差分でseed 73なし、
1件がruntimeなしの不正直接生成受理です。single-memory access／walk constructorは記載された既定名の期待を保持し、明示非空／空名と対象controlを別の観測にします。
印字virtual builtin dispatcherは直接生成を受理され、合法具象拡張をその拒否義務の代わりにはしません。

選択検査は15 builtinのconstructor／宣言、正確なregister-sequence継承、公開model／register／memory対象handle、置換／peer独立性、64 bit選択field、
abstraction queue保存、6つの正確なprotected child slotを扱います。選択wrapper 2件で外部accessを拒否します。
実行中factory-child probe 5件は実行slotと選択対象を調べ、独自child bodyは経路だけを認定し、builtin access／walking algorithmの代わりにはしません。
既存full-algorithm controlと未変更reset／dispatcher body記録は別の証拠です。

異なる具象拡張handle型の初期直接比較は、生成後のC++ compileに失敗しました。controlを同じ同一性predicateの共通builtin-base viewへ変えて再測定し、
古いbuildをUVM差分には数えません。access経路probe 2件は初期にbackdoor適用条件を欠いていたため、対象別の独自storage backdoorを設定して修正入力を再測定しました。
初期のskipは検査系の設定問題でUVM差分ではありません。初期の引用／整形preflight誤りも測定前に修正し、規格由来の期待は置換しません。
req_seq見出しとreg_seq prototype、印字E.6.3番号を明示して保持し、追加公開accessor、childの既定／保持規則、割当／兄弟順序は作りません。

付録E監査は新M3の29 fixtureと未変更body／control入力へAI義務62件を追加します。
15個のconstructor／名前／継承、13対象変数、6 protected child宣言、選択可視性negative、7 body義務、dispatcher選択／幅、abstraction queueに明示条件を持たせます。
一致する独自委譲probeはbuiltin payload algorithmを証明せず、未引用の旧algorithm fixtureはcontrol linkだけです。既定名とvirtual宣言の差分はspec-onlyに残します。

見出し16件を個別の構造、導入4件を関連義務のある文脈と分類します。以前に未評価だったEの77番号へ対応し、付録は部分74／分類20／未評価0で案114件、主引用88 fixture（simulation 85／elaboration 3）です。
部分契約74件、物理DUT reset／access、歴史的walking-ones解釈、skip／error／中止／並行の組合せ、元のmilestone目標の完了ではありません。

全体は部分1747／分類377／未評価383（構造257／文脈120）で、以前の全3110要求・357分類は未変更です。
範囲は提案で分母／割合はnullのままであり、どの条項状態も完了を意味しません。

全1801（simulation 1746／elaboration 55）、M1 709（667／42）、M2 547（542／5）、M3 545（537／8）です。
通常結果はpass 1568（runtime 1516／compiler拒否52）、known 233（runtime 173／simulation build 57／不正compiler受理3）です。
以前の全1772通常記録・3110要求・357分類は未変更で、guest 1083／HDL 11／command-line 18記録はbyte単位で同一です。
guest未測定は修正2入力を含む718（simulation 663／elaboration 55）です。

goalの32反復目は未評価を77減らして383（開始から1080減）とし、全部分義務と元の目標は未完了です。
tool test 110件、metadata、台帳／library、evidence同一性、日英資料検査は成功し、FAQ／用語は248／279件です。
schema、runner／library／catalog／backend、workflow、SVG 6件は未変更です。guest実行、人のレビュー、分母承認、完了は主張せず、goalは継続中です。

## 薄い領域の61回目の拡充：基底classの適用条件

[58ba1c5](https://github.com/kurochan001/kirimasim-uvm-tests/commit/58ba1c5782c0a47980539b0d8a7ca9501f2be296)を基に2026-11-05 JSTに実施しました。M1の36 fixtureを追加し、19件が一致します。runtime 15件はseed 1／73、4件は期待compiler拒否です。
17件は既知差分で、runtime 12件はseed 1だけ、合法build 5件はruntimeなしです。
object／void／port宣言、constructor省略と名前、transaction recording制御／handle／event、object policy hookとactive policy、
canonical timeの単位／既定値、field-operation lifecycleを扱います。

合法build 5件はobject active-policy API欠落4件と、time decrで省略可と印刷されたsecs引数をlibraryが要求する1件です。
明示secondsの減算とcaller単位の換算controlは独立に一致します。runtime 12件はtransactionの初期active、recordingのdefault-on文言、
禁止区間のrecording制御通知4件、record-object経路2件、time／port既定名、set前／flush後のfield-operation hook照会を保持します。
handle／registry／freeや階層の観測一致でfixture全体をpassにしません。明示DEEPのrecorderはsubject callbackを確認する前に選択recursion modeを観測します。
error probeはERROR／FATAL通知を要求し、診断text、ID、回数、未規定の回復は固定しません。

既存printer fixture 1件はSystemVerilog 8.20に従いvirtual引数名を規格のvalueとsizeへ修正し、未変更期待出力が修正入力の両seedに一致します。
初期のoverride引数名とcaller単位のtime設定誤りは最終測定前に修正し、古い結果を現在のUVM差分へ数えません。
独自print／compare、直接record、名前付きresourceのset_local probeは選択拡張経路を検査し、全builtin format、field自動設定、全macroを認定しません。
印刷されたpure-method／既定bodyの文言とtransaction constructorのcomma欠落は、解釈の境界として明示して残します。

第5章監査は新M1の36 fixtureと選択した既存controlへAI義務60件を追加します。
見出し8件を個別の構造、active-policy導入1件を関連push／pop／get義務のある文脈と分類します。
以前に未評価だった48番号へ対応し、第5章は部分99／分類12／未評価0で案168件、主引用92 fixture（simulation 87／elaboration 5）です。
残る条件の完了ではありません。

object／void継承と生成、virtual拡張経路、transaction recording制御／handle／event、generic port既定値、canonical time単位、
field-operation hook lifecycleに明示条件を持たせます。API欠落、secs引数既定値のbuild、runtime 12差分はspec-onlyです。
既存initiator／IDとfield-operation controlは狭く対応付け、initiatorのprint／record、自動設定、広いerror／lifecycle組合せは部分義務に残します。
pure-method／既定bodyとconstructor句読点の衝突を、libraryに合わせて暗黙解決しません。

全体は部分1786／分類386／未評価335（構造265／文脈121）で、以前の全3172要求・377分類は未変更です。
直接対応1836テスト、controlだけ1テスト、control linkを持つ42テストです。範囲は提案で分母／割合はnullのままであり、どの条項状態も完了を意味しません。
既存printerの入力／索引／記録1件はoverride引数名の修正と再測定後に意図して更新し、oracleは変更しません。

最終スイートは1837（simulation 1778／elaboration 59）、M1 745（699／46）、M2 547（542／5）、M3 545（537／8）です。
通常evidenceはpass 1587（両seed runtime 1531／期待拒否56）、known 250（seed 1 runtime 185、合法build 62、不正生成受理3）です。
ほかの以前の通常1800記録と全旧compiler 55記録は未変更です。guest 1083記録と別条件のHDL 11／command-line 18記録も未変更です。
guest未測定754（simulation 695／elaboration 59）は、元の測定後の追加752件と修正した元入力2件です。printerは元からguest部分集合の外です。
初期time／override設定失敗とgeneric-portの早過ぎたtagは修正し、最終指紋が新規／修正した全記録へ対応します。
GPL／LGPLシミュレータ実装や商用結果は利用しません。library整合性、tool test 110件、metadata、台帳／索引、生の観測／evidence、日英資料検査は成功です。
永続goalは有効で、33反復により未評価は1463から335へ1128減少しました。完了や人の承認は主張しません。

## 薄い領域の62回目の拡充：resource収集とconfig型

[c9d01f3](https://github.com/kurochan001/kirimasim-uvm-tests/commit/c9d01f36f61881dd9c36750c5808cab4961e6b4e)を基に2026-11-05 JSTに実施しました。M1のresource／config 21 fixtureを追加し、15件が一致します。runtime 14件はseed 1／73、1件はpoolからobjectへの不正代入の期待拒否です。
6件は既知差分で、runtime 3入力はseed 1だけ、合法build 3件はruntimeなしです。欠落したtyped resource-DB最大値helperは、
混合型、最初の最大値の同順位、既定object特殊化で直接呼び、untyped pool helperや検査系filterで置換しません。

異なるprecedenceのsortと変更後の再sortは一致します。同precedenceは、most-recently-setを観測した挿入履歴とする明示解釈で差分を保持し、
その解釈にはレビューが必要です。最初の最大値選択規則とは別に扱います。literal regex lookup、正確なname集合、名前付き／無名scope収集、scope置換は走査順を固定せず一致します。
anchor付きalternationは通常no-DPI条件で異なります。印刷virtualのregex／scope呼出しもbase view経由で異なり、独自overrideは委譲だけを検査し、builtin収集algorithmを認定しません。

configの既定／継承static interfaceと正確なalias 4種は、bitstream上位bit、空文字列、共有／置換object handle、factory proxy handleを含む選択set／getを検査します。
正時刻のcomponent要求は明示getを使い、自動configurationのoracleにはしません。typed virtual-interface resourceはliveな独自instanceを保持します。
resource-base print probeは継承virtual委譲だけを調べます。bitstreamの補助引用1件を修正し、最終tag／detail／name所属変更を再測定し、規格由来期待を置換しません。
これらの条件で全resource契約は完了しません。

付録C監査は新M1の21 fixtureへAI義務30件を追加し、以前の未評価19番号を部分分解します。
type-interface導入1件は保持するstatic／polymorphic accessor義務のある文脈と個別分類します。
以前の未評価20番号へ対応し、Cは部分71／分類13／未評価0で案98件、主引用69 fixture（simulation 64／elaboration 5）です。部分条件は未完です。

sort順序／recency、混合型最大値選択、regex／scope収集、virtual宣言、priority enumの意味、config継承／既定値とalias 4種、
正時刻component access、virtual-interface値、resource-base print委譲に選択観測を持たせます。
typed helper欠落build 3件とruntime差分3件はspec-onlyに残し、recent-setの意味とlookup_type／overviewの矛盾も限定したまま保持します。

全体は部分1805／分類387／未評価315（構造265／文脈122）です。以前の全3232要求・386分類・1837テスト索引と通常実測記録は未変更です。
直接対応1857テスト、controlだけ1テスト、control linkを持つ43テストです。範囲は提案で分母／割合はnullのままで、どの状態もM1〜M4完了を認定しません。

最終スイートは1858（simulation 1798／elaboration 60）、M1 766（719／47）、M2 547（542／5）、M3 545（537／8）です。
通常evidenceはpass 1602（両seed runtime 1545／期待拒否57）、known 256（seed 1 runtime 188、合法build 65、不正生成受理3）です。
以前の通常1837入力／記録とcompiler 59記録はすべて未変更です。guest 1083記録、HDL 11記録、command-line 18記録も未変更で、
guest未測定775（simulation 715／elaboration 60）は追加773件と修正した元入力2件です。最終sourceは規格oracleを保持し、
初期補助引用を修正し、全tag／detail変更を再測定します。library整合性、tool test 110件、metadata、台帳／索引、生の観測／evidence、日英資料検査は成功です。
GPL／LGPLシミュレータ実装や商用結果は利用しません。goalは有効で、34反復により未評価は1463から315へ1148減少し、人の承認や完了は主張しません。

## 薄い領域の63回目の拡充：memory mapとspecial-register FIFO

[b95b8a8](https://github.com/kurochan001/kirimasim-uvm-tests/commit/b95b8a891128bdcf2c7639a820d1edd428873b2c)を基に2026-11-05 JSTに実施しました。M3の37入力を追加し、19件が両seed runtime一致、18件がseed 1だけのruntime差分です。
25件は記載APIを使い、独立した通常register bus controlを含みます。追加のcontrol専用12入力は固定FIFOの記載外build methodで初期化し、
別の索引指紋と期待観測を持ちます。初期化controlは7件一致・5件差分です。control結果で直接要求のconstructor／configureだけの前提をpassにしません。

memory address既定値は唯一の所属mapまたは共有時のparent既定mapを選びます。無関係mapのaddress／offset／address-array warningは一致し、
−1とcaller array未変更も検査します。rights照会はRWを返しますが必要なwarningを生成しません。独自遅延backdoor readは外部の隣接word変更を観測します。
memory／indirect／FIFO builtinのfactory例外は合法登録拡張controlを保持し、indirectの省略／明示constructorとregister-base write／read経路は一致します。

constructor／configureだけのFIFO 12入力は、set／predict、転送／update、compare／mirrorの観測完了前に内部fieldのnullで停止します。
期待値確定後の原因調査で、固定Apache-2.0 UVMの記載外build初期化を確認しました。明示的な前提／解釈の境界であり、IEEE前提を作ったり独立library不具合を証明したりしません。
別途初期化したcontrolは選択algorithmへ到達し、set／full、write／read prediction、比較gate 4組、compare省略既定値は一致します。
直接writeは外部FIFO setなしでもNeeds Updateで拒否され、外部観測はbus writeなしにabstract状態を重複します。
updateはpreload 2個を4 entry／転送へ重複し、反復updateも4 entryを保持します。公開FIFO／DUTが一致するchecked pairは両queueをpopしても、
内部0 mirrorとの差分を報告します。公開queueの期待は限定した解釈で、レビューに残します。

最終write controlは拒否write後に戻り、後続の空の独自DUTへのreadを避けます。規格由来期待は未変更です。
分離した宣言helper directory 2個で以前の1858入力同一性を保持します。source／metadata preflight修正は検査系の作業でUVM差分ではありません。
他の以前の通常／compiler／guest／backend記録は未変更で、guest再実行や完了は主張しません。

memory／indirect／FIFO監査はAI義務45件と、個別に読んだMethods構造見出し1件を追加します。
18.6〜18.8の以前の未評価15番号を部分分解14件とその分類へ対応します。第18章は部分312／分類43／未評価101、案651件、主引用369テストです。
この3節の未評価番号は0ですが、残る契約と元のmilestone目標は未完です。

新37入力は直接／reference probe 25件と、初期化を明示した固定libraryのcontrol専用12件です。control linkで記載API前提を置換しません。
全体では直接対応1882テスト、control専用13テスト、control linkあり56テストです。独立した通常register転送、constructor-only FIFO停止、
初期化後のalgorithm観測を、別々の証拠と適用条件で保持します。

全体は部分1819／分類388／未評価300（構造266／文脈122）です。以前の全3262要求・387分類・1858索引入力／通常記録・60 compiler記録は未変更です。
build controlで既知差分をpassへ変更せず、どの状態も提案範囲、分母、人のレビュー、完了を承認しません。

最終スイートは1895（simulation 1835／elaboration 60）、M1 766（719／47）、M2 547（542／5）、M3 582（574／8）です。
通常はpass 1621（両seed runtime 1564／期待compiler拒否57）、known 274（seed 1 runtime 206、合法build 65、不正生成受理3）です。
以前の通常1858入力／記録とcompiler 60記録、guest 1083記録、HDL 11記録、command-line 18記録は未変更です。
guest未測定812（simulation 752／elaboration 60）は追加810件と修正した元入力2件です。新初期化12入力はcontrol linkだけを持ち、
control専用は全13入力、control linkありは56テストで、未対応入力はありません。library整合性、tool test 110件、metadata／台帳／索引、
生の観測／evidence、日英資料検査は成功です。有効goalの35反復で初期未評価1463番号から300へ1163減少し、完了、人のレビュー、分母承認は主張しません。

## 薄い領域の64回目の拡充：core宣言、phase上限、seeding

[89b06ab](https://github.com/kurochan001/kirimasim-uvm-tests/commit/89b06ab55ee9970712d61e628265960a2e6650c7)を基に2026-11-05 JSTに実施しました。M1の35入力を追加し、期待compiler拒否27件と両seed runtime一致5件を得ました。
差分3件はseed 1 runtime 2入力と、runtimeのない合法simulation build 1入力です。
method省略probe 26個は他の印刷pure method全部と固定版の追加phase-hopper hookを実装し、最終compiler診断は選択した欠落methodだけを示します。
virtualなcore-service基底の直接生成も拒否されます。

印刷method 26個をすべて実装した独自serviceは、固定libraryが追加get_phase_hopperを要求するため拒否されます。
別索引のcontrol専用variantでそのhookを補うと、正確なsignatureの全26 methodがbase viewから各1回dispatchされ、独自引数と返却handleを保持します。
controlで記載methodだけのconstructor前提をpassにせず、新global serviceを設定せず、builtin facility algorithmを認定しません。
期待値はApache sourceの原因調査前に導き、追加IEEE要求を作りません。

既定core-serviceの生成、合法拡張、base継承は一致します。選択core／root／report-object handleは一致し、具体的な実childの生きた状態を保持します。
core seedingはenableで始まり、object class 2種と変更を共有します。core disableは改名したobject 2個と呼出しprocessのRNG状態を保持し、
後続乱数payload 3個は独立にseedしたreferenceと一致します。特定乱数値や直列化状態形式は規定しません。

coreのready-to-end最大値7／9への変更はphase既定値や新nodeへ届かず20を保持します。実main phasingでもcore選択最大値3に対してready callbackは20回です。
明示node状態は区別し、最後の遅延drop回数は診断だけとします。root probeの初期の抽象component直接生成は具体拡張へ修正し、
編集／tag変更した入力をすべて再測定しました。以前の入力と通常／compiler／guest／backend記録は未変更です。

core-service監査は日英AI義務74件と個別に読んだ構造見出し2件を追加します。以前の未評価14番号は部分分解12件とその分類2件になります。
附属書Fは部分72／分類16／未評価49、案163件、主引用89テスト（simulation 60／elaboration 29）です。
全体は部分1831／分類390／未評価286（構造268／文脈122）で、元のmilestone目標はすべて未完です。

全3381義務に直接テストがあり、直接対応1916テスト、他のcontrol専用14テスト、control linkあり57テストです。
新追加hook controlで記載methodだけの完全serviceやbuiltin algorithmを認定しません。negative 26入力は選択pure宣言だけを分離する目的でhookを実装します。
未対応テストと直接テストのない義務はありません。以前の全3307義務、388分類、1895索引入力／通常記録は未変更で、
以前の60 compiler記録も新87件集合内で未変更です。範囲／分母承認、人のレビュー、完了は主張しません。

最終スイートは1930（simulation 1843／elaboration 87）、M1 801（727／74）、M2 547（542／5）、M3 582（574／8）です。
通常evidenceはpass 1653（seed 1／73 runtime 1569、期待compiler拒否84）、known 277（seed 1 runtime 208、合法build 66、不正受理3）です。
以前の通常1895入力／記録とcompiler 60記録、guest 1083記録、HDL 11記録、command-line 18記録を保持します。
guest未測定847（simulation 760／elaboration 87）は追加845件と修正した元入力2件です。新control専用入力は1件、全体のcontrol専用は14テスト、
control linkありは57テストです。library整合性、tool test 110件、metadata／台帳／索引、生の観測／evidence、日英資料検査は成功です。
goal第36反復で初期未評価1463から286へ1177減り、完了は未立証です。

## 薄い領域の65回目の拡充：型別fieldと操作flag

[80a8bdf](https://github.com/kurochan001/kirimasim-uvm-tests/commit/80a8bdf631334668107f42328acd6af395d69fe7)を基に2026-11-05 JSTに実施しました。M1の42入力を追加し、両seed runtime一致37件と期待compiler拒否1件を得ました。
差分4件は合法simulation build 3件とseed 73結果のないseed 1 runtime 1件です。
別索引の対照4件は一致してもcontrol linkだけを持ち、元の前提を置換しません。

型別field probe 33個はscalar、静的／動的array、queue、string／integral keyの連想propertyを扱います。
選択copyと正／負比較は72-bit data、signed／unsigned／high／wide key、collection size、古いentryの除去、未登録peerの分離を確認します。
object値の6形状はDEEPを明示し、copy後の別handleとtarget変更後のsource状態を保持します。
user copy／compare hookでfield automationを置換せず、走査順も規定しません。

enum collection probeは印刷T本文が記述するcollection typedefを字面どおり使い、静的／動的／queueのbuildが失敗します。
別のcontrol 3件はcollection storageを保ったまま要素enum型を渡して一致します。
これは明示した解釈境界であり、library不具合数の証明や文言の解決ではありません。元の期待値は未変更です。

NOCOPY／NOCOMPAREの優先順位と、省略／DEFAULT／ALL_ONのcopy／compare観測は一致します。
PACKだけではpaired-unpack期待に失敗し、別のcontrolでUNPACKを明示追加すると一致します。
互換roundtripとtarget sentinelの結果で、全ての独立した片方向packing義務やstream配置は証明しません。
手動field-utilsのcreate／型名／clone観測は自動factory登録なしで一致します。const ARG禁止は宣言診断で拒否されruntime seedを実行しません。
最終tag入力を再測定し、以前の全source／evidence記録を保持します。

field-macro監査は日英AI義務125件を追加し、番号の新分類は行いません。以前の未評価45番号（Bの41件とFの4件）を部分分解します。
附属書Bは部分81／分類4／未評価59、案164件、主引用96テスト（simulation 95／elaboration 1）です。
附属書Fは76／16／45で案174件、全体は部分1876／分類390／未評価241（構造268／文脈122）です。元の目標はすべて未完です。

全3506義務に直接テストがあり、直接対応1954テスト、control専用18テスト、control linkあり61テストです。
新enum型／明示UNPACK controlで元の前提をpassにしません。同じ観測を共有するcopyと比較義務は独立テスト数ではありません。
以前の全3381義務、390分類、1930索引入力／通常記録、87 compiler記録は未変更で、compiler集合は現在88入力です。
範囲／分母承認、人のレビュー、完了は主張しません。

最終スイートは1972（simulation 1884／elaboration 88）、M1 843（768／75）、M2 547（542／5）、M3 582（574／8）です。
通常evidenceはpass 1691（seed 1／73 runtime 1606、期待compiler拒否85）、known 281（seed 1 runtime 209、合法build 69、不正受理3）です。
以前の通常1930入力／記録とcompiler 87記録、guest 1083記録、HDL 11記録、command-line 18記録を保持します。
guest未測定889（simulation 801／elaboration 88）は追加887件と修正した元入力2件です。新control専用入力は4件、全体のcontrol専用は18テスト、control linkありは61テストです。
library整合性、tool test 110件、metadata／台帳／索引、生の観測／evidence、日英資料検査は成功です。goal第37反復で初期未評価1463から241へ1222減り、
完了は未立証で、人のレビューや分母承認を作りません。

## 薄い領域の66回目の拡充：field accessとcallback

[f827d1e](https://github.com/kurochan001/kirimasim-uvm-tests/commit/f827d1e9922e5b1cb4d58318a257370b617c8057)を基に2026-11-05 JSTに実施しました。M3の36入力を追加し、seed 1／73でruntime一致31件、seed 73結果のないseed 1差分5件を得ました。
field／callback構築、制約付きpublic value、構成後のrandomization mode、pending状態、実read／write hook、
callbackのenable／delete、backdoorの選択slice、mirrorのcheck gateを扱います。
明示した第2mapのcontrol 2件と単独read-only pokeには直接義務もあり、新しいcontrol専用入力はありません。

親registerのwrite／read traceはRCFDBcrdfを期待しますが、FDRCBcrdfを観測し、field pre hookがregister pre hookに先行します。
独立したpost観測はcrdfに一致しても、入力全体には順序差分を保持します。field pre-read／pre-writeでmapを変更してもprovider Aを使い、
開始時にmap Bを明示するcontrolは一致します。独立した独自route bufferでproviderを区別し、物理map aliasの整合性やRTL protocolの証拠は主張しません。

独自backdoor storageの物理隣接nibble B／Dは、モデルのA／3と異なります。pokeはB75DからB39Dをdepositし、peekはstorageを保持し、
選択した失敗／extension検査も一致します。read-only writeは選択slice 75を保持しますが、全wordはA753になります。
全wordの期待は限定したbest-effort解釈として差分を保持し、無条件の周辺bit保証や独立した不具合数にはしません。
続くpokeの前に物理storageをB75Dへ明示resetすると一致し、履歴のない単独read-only pokeも一致します。

履歴付きfixtureでは意図したresetとslice観測の挿入が最初に漏れていたため、修正した最終sourceを再測定しました。
以前のseed 73 logは物理／モデルの隣接値が同じ旧入力を使い、旧入力指紋付きで保存して最終evidenceから除外します。
最終期待の順序とmap結果は規格に基づく元の内容を保持します。

field-access監査は日英AI義務69件と、個別に読んだ分類5件（構造見出し4件、型参照先を示す文脈1件）を追加します。
以前の未評価22番号のうち17件を部分分解し、5件を明示分類します。第18章は部分329／分類48／未評価79、案717件、主引用405テストです。
field 18.5の未評価番号はありませんが、部分的な契約が残ります。全体は部分1893／分類395／未評価219（構造272／文脈123）で、元の目標は未完です。

全3575義務に直接テストがあり、直接対応1990テスト、control専用18テスト、control linkあり64テストです。
新control 3件にはそれぞれ独自の直接義務もあり、他入力の元前提をpassにしません。以前の全3506義務、390分類、1972索引入力／通常記録、88 compiler記録は未変更です。
範囲／分母承認、人のレビュー、完全coverageは立証していません。

全2008（simulation 1920／elaboration 88）、M1 843（768／75）、M2 547（542／5）、M3 618（610／8）です。
通常passは1722（runtime 1637／拒否85）、knownは286（runtime 214／build 69／不正受理3）です。
以前の通常1972記録、3506義務、390分類、88 compiler記録は未変更です。library整合性、tool test 110件、metadata／台帳／索引、現在evidence、日英資料検査は成功です。
guest／HDL／command-line記録も未変更で、guest未測定は925入力です。人の承認と完了は未立証です。

guest未測定925入力は追加923件と修正した元入力2件（simulation 837／elaboration 88）です。
compiler 88記録、HDL 11記録、command-line 18記録は保持します。新control専用入力はなく、直接義務も持つ新control 3件でcontrol linkありは64、control専用は18のままです。
goal第38反復で初期未評価1463から219へ1244減りました。goalは有効のままで、完了は未立証です。

## 薄い領域の67回目の拡充：保護と予測のcallback

[81da564](https://github.com/kurochan001/kirimasim-uvm-tests/commit/81da564f14ea16b4fac16870a817abcd236e27d0)を基に2026-11-05 JSTに実施しました。M3の48入力がruntime seed 1／73で一致します。定義済みread-only／write-only callbackの検査は、
具象基底view、直接拒否hook、registerと両byte fieldへの登録、無関係なhandleを保持する削除、peer分離、
独立したguard family、削除／再追加の履歴を扱います。registerと下位／上位fieldの拒否をそれぞれfrontdoor／backdoorで検査します。
期待するERROR、UVM_NOT_OK、provider転送0、独自storageの保持を確認し、正確な診断ID／文面／件数は規定しません。
許可方向と削除後のaccessも独自providerへ届きます。

read／writeのpost-predict検査は、正確なfield、以前／最新data、kind、door、mapを渡し、置換で選択desired／mirror状態を更新して、
peerと独自storageを保持します。明示／省略したdirect予測はread／write callback配送なしに指定値を使います。
選択callbackのdisable／deleteで後続予測への効果を止めます。これらは独自frontdoor／backdoor providerであり、物理HDLやcallback guardによるfield access policyの置換を主張しません。

初期fixture 14件で表示formatへpacked連結を渡す誤りがあり、literal format引数へ修正しました。期待値fileはすべて保持し、修正probeと最終tag入力を再測定します。
以前の全2008入力／evidence記録と既知差分286件は未変更です。

保護callback監査は日英AI義務70件と、個別に読んだ構造Methods見出し2件を追加します。
以前の未評価12番号のうち10件を部分分解し、2件を明示分類します。第18章は部分339／分類50／未評価67、案785件、主引用453テストです。
callback 18.11の未評価番号はありませんが、部分契約を保持します。全体は部分1903／分類397／未評価207（構造274／文脈123）で、元のmilestone目標はすべて未完です。

全3645義務に直接テストがあり、直接対応2038テスト、control専用18テスト、control linkあり64テストです。
新入力はすべて直接義務を持ち、新control専用入力はありません。以前の全3575義務、395分類、2008索引入力／通常記録、88 compiler記録は未変更です。
人のレビュー、範囲／分母承認、完全coverageは主張しません。

全2056（simulation 1968／elaboration 88）、M1 843（768／75）、M2 547（542／5）、M3 666（658／8）です。
通常passは1770（runtime 1685／拒否85）、knownは286（runtime 214／build 69／不正受理3）のままです。
以前の通常2008記録、3575義務、395分類、88 compiler記録は未変更です。library整合性、tool test 110件、metadata／台帳／索引、現在evidence、日英資料検査は成功です。
guest／HDL／command-line記録も未変更で、guest未測定は973入力です。人の承認と完了は未立証です。

guest未測定973入力は追加971件と修正した元入力2件（simulation 885／elaboration 88）です。
compiler 88記録、HDL 11記録、command-line 18記録はすべて未変更です。新control専用入力はなく、新しいシミュレータ／library既知差分は主張しません。
goal第39反復で初期未評価1463から207へ1256減りました。goalは有効のままです。

以前の分割前[Check実行](https://github.com/kurochan001/kirimasim-uvm-tests/actions/runs/41976785278)は、設定された150分のjob上限を超えました。
現在のworkflowは同じタグ付き1770検査を重複しない8 shard（222／222／221／221／221／221／221／221）へ分け、同時shard jobは最大4です。
和集合の完全一致と重複なしをlocalで検証しました。command-line 17検査はshard 0で通常検査の前に1回だけ実行します。
seed 1／73、compiler拒否85件、固定依存関係、runner指紋は未変更です。従来のverilator gateは全shardの成功を要求します。shard分割は実行の構成であり、local検証でhosted workflowの成功は立証しません。

続くドキュメント見直しで、日英の[読み方ガイド](reading-guide.ja.md)と、既存ガイドの34箇所に短い説明文・参照リンクを追加しました。
READMEは現在の対象範囲を要約し、最初の実行、結果ラベル、証拠の同一性、要求件数の区別を疑問が生じる箇所から辿れるようにしました。
以前の履歴記録は保持します。

## 薄い領域の68回目の拡充：recordingとscalar I/O macro

[e8a6d8e](https://github.com/kurochan001/kirimasim-uvm-tests/commit/e8a6d8e1b5a955baed158d3e2bbaaab861a713ef)を基に、M1のsimulation 44件と独自の日英AI義務41件を追加します。
scalarの各方向は公開packer APIと7-bit末尾値を独立に使い、選択幅・値・hook観測でserialized配置を固定しません。
実行中のtransaction handleで独自recorder observerを動かします。3引数typed attribute入力6件はbuild差分を保持し、
4番目の引数を明示するcontrol 6件は一致してもcontrol専用です。enumNと直接small record_fieldのcontrolは別の直接義務も持ちます。
印刷された1引数enum signatureと既定attributeのhandle解釈は限定した前提に残します。

新入力33件がseed 1／73で一致し、4件がseed 1で異なり、7件はbuildできません。元の期待値fileは保持します。
metadata補助引用と省略radixの観測をIEEEと照合して修正し、現在の入力と最終入力を再測定しました。
固定Apache-2.0のrecorder macro headerは独立した期待値を書いた後の原因調査だけに使います。

全2100（simulation 2012／elaboration 88）、M1 887（812／75）、M2 547（542／5）、M3 666（658／8）です。
通常passは1803（runtime 1718／compiler拒否85）、knownは297（runtime 218／build 76／不正受理3）です。
以前の全2056通常入力／記録、3645義務、397分類、88 compiler記録は未変更です。guest／backend記録も未変更で、guest未測定は1017入力です。
分類を追加せず21番号を部分分解し、全体は1924／397／186、付録Bは102／4／38です。
範囲・分母・人のレビュー・元の目標は未承認／未完です。

全11言語対の読み手向け案内を保持し、短い説明と関連する節へのリンクを補います。
library／tool／metadata／台帳、現在のevidence、既存source保持、8 shardの完全選択をlocalで検証しますが、hosted Checkの成功を立証するものではありません。

## 薄い領域の69回目の拡充：走査の宣言と既定値

[19c4d55](https://github.com/kurochan001/kirimasim-uvm-tests/commit/19c4d5513ad8137d0dc1f122c0bb0568adfaf743)を基にM1の33入力（simulation 29／elaboration 4）と独立した日英AI義務33件を追加します。
正確な宣言型／既定値の束縛、基底／object同一性、実際の基底constructorの引数形式、継承した空hook、参照queue dispatchを観測します。
組み込みadapterが選択treeを走査し、独自interface本体で基底algorithmを認定しません。

26入力がruntime両seedで一致し、virtual生成2件は拒否されます。
STRUCTURE単独指定の依存既定値3入力はbuildできず、明示型controlは一致します。
確認した固定宣言は規格どおりの依存関係を持ち、原因は断定しません。pure method省略2入力は受理されますがruntimeは実行しません。
元の期待と診断を保持し、最終tagと順序の補助引用を反映して再測定し、本体やhelperは変更しません。

区切り見出し4件とoverview 3件を個別評価し、14番号を部分分解します。全体は1938／404／165（構造278／文脈126）、
付録Fは90／23／24で、義務207件、主引用122テストです。F.5の未評価番号はありませんが部分的なままです。
全2133（simulation 2041／elaboration 92）、M1 920（841／79）、M2 547（542／5）、M3 666（658／8）です。
通常passは1831（runtime 1744／拒否87）、knownは302（runtime 218／build 79／不正受理5）です。
以前の通常2100記録、3686義務、397分類、以前の88 compiler記録を保持します。guest／backend記録も未変更で、guest未測定は1050入力です。

collection macroは未完です。短いpacking契約を根拠にraw stream配置を作りません。
規格本文／algorithm、商用結果、シミュレータ実装sourceをoracleの根拠にしません。日英資料と読み手向け案内を保持し、
local evidence、library／tool／metadata／台帳、8 shardの完全な選択を検証します。
hosted CI成功、人のレビュー、範囲／分母承認、goal完了は未立証です。

## 薄い領域の70回目の拡充：virtual registerとfieldの照会

[13e6cce](https://github.com/kurochan001/kirimasim-uvm-tests/commit/13e6cce15f930f443629dcb8e7e023c417f62952)を基に、2026-11-05と2026-11-06 JSTに測定しました。新しいM3の43入力はmodel内のsimulationで、39件がseed 1／73で一致します。
2件はseed 1のruntime差分でseed 73結果がなく、限定したoverview基底型の2入力はbuildできずruntime結果がありません。

overviewはvirtual抽象の基底にuvm_reg／uvm_reg_fieldを挙げますが、class宣言はuvm_objectを指定します。
字面どおりの静的基底型の入力はこの食違いを保持し、object基底のcontrolは別に一致します。
build結果で文言を解決したり、無条件の実装不具合を認定したりしません。

8-bit constructorの構成は、保持する完全memory location単位の2-byte期待に対して1 byteを返し、64-bitの構成は一致します。
名前と幅の義務には別の期待行を使い、公開constructor／getterの連鎖を観測してもconstructorへ原因を割り当てません。
無関係なrights mapはRWを返しますが、必要なERRORを出しません。fallbackと診断を別の義務に分け、一致する行だけで入力全体をpassにしません。

region照会は未実装／release後のnullと、唯一の予約descriptorとの同一性を観測します。
明示再配置、要素数、完全memory location数、間隔、word offset、map所属、policyを別々に検査します。
byte addressと2-byte wordのmapは、それぞれの単位で外部addressを返します。
shared照会は必要なmapを明示し、default mapの選択は別条件にします。不正address照会はWARNINGを要求し、戻り値は固定しません。
map列挙は所属を観測し、queue順序や空でないqueueへの追記／消去を仮定しません。

fieldのconfigureは親・幅・LSBの観測を分け、memory locationをまたぐ構成も含めます。
getterとRO／WO／RW policyの入力は別に保持します。実際のHDLやmemory storage転送は実行も認定もしません。
control 4件も直接義務を持ち、元の限定した前提の代わりにはしません。

virtual照会の監査は日英AI義務45件を追加し、以前の未評価21番号を部分分解します。
個別に読んだIntrospection見出し1件を構造として分類します。
全体は部分1959／分類405／未評価143（構造279／文脈126）です。
第18章は部分360／分類51／未評価45で、義務830件、主引用simulation 496テストです。
これらの部分的な照会契約で、レジスタ層のmilestoneやその条件を完了にしません。

全3764義務に直接テストがあり、直接対応2152テスト、control専用24テスト、control linkあり83テストです。
新入力はすべて直接義務を持ち、うち4件はcontrolも提供します。
以前の全3719義務、404分類、2133索引入力／通常記録、92 compiler記録は未変更です。
人のレビュー、範囲／分母承認、完全coverageは主張しません。

全2176（simulation 2084／elaboration 92）、M1 920（841／79）、M2 547（542／5）、M3 709（701／8）です。
通常passは1870（runtime 1783／拒否87）、knownは306（runtime 220／build 81／不正受理5）です。
以前の通常2133記録、3719義務、404分類、92 compiler記録は未変更です。
guest／HDL／command-line記録も未変更で、guest未測定は1093入力です。人の承認と完了は未立証です。

測定前に期待値と独自sourceを固定しました。一致入力だけに固定版tagを付けて両seedで再測定し、未変更known入力は正確に互換な初回記録を保持します。
合算前に入力／runner／library／設定の同一性を確認します。compiler証拠と以前の通常／guest／backend記録は未変更です。
local fileは`out/thin-seventieth-`を使い、guest再実行は主張しません。
tool、metadata、台帳／索引、source／証拠、日英資料、CIの正確な選択の検査を伴います。goalは有効に保ちます。

## 薄い領域の71回目の拡充：global照会と対応の正確さ

[ba5e87e](https://github.com/kurochan001/kirimasim-uvm-tests/commit/ba5e87e2a22b9280f991ee69042e02e9ef231afc)を基に2026-11-06 JSTに集約しました。今回は新規simulation 32件（専用global pool 28・virtual field constructor 4）と、修正した既存1入力を測定します。
新規30件と修正した1件が両seedで一致し、印刷pool返却の2入力はbuildできずruntime結果がありません。

専用get_globalのsignatureはpoolを返すと記し、本文とgeneric get_globalはitemを指します。
pool型receiverは印刷signature、item型の動作入力は本文の解釈を保持します。後者が一致しても前者をpassにせず、文言の食違いを解決しません。
原PDFの104〜105ページでも、両方の印刷pool型を確認しました。
印刷型のmarkerは静的な受理だけを示し、返却値の動作を示しません。

静的照会前にglobal keyを明示的に用意し、正確なhandle選択、同一／別key、local／globalの独立性、生きた状態の共有、明示置換、削除／再作成、alias、item改名、空／wildcard風の字面keyを観測します。
実際のevent待機とbarrierの2到着は、返却handle、格納した参照、正の時刻差を使います。
解除前にwaiter数、解除後に完了時刻を観測し、同時刻の実行順は固定しません。存在しないkeyの静的動作と全並行条件は未完に保ち、instance getによる明示再作成から決めません。

factory生成するfield派生型は、実際のsuper.newの名前省略／明示の結果を基底呼出し直後に取得します。
別の組み込みfactory入力は、同じ／異なる明示名で新しい別instanceを観測します。
既存のconfigure検査系はdescription／主引用だけを18.10.2.2へ直し、本体と期待出力を変えずに再測定します。
その安定した義務はparentの列を扱うようにし、既存の幅／LSB義務に元の5-bit・LSB 7の構成を加えて結合期待行を共有します。
1行を独立した3テストに数えません。これらのconstructor／configure観測からfield転送やHDL動作を推測しません。

日英AI義務32件で、以前は未評価だった専用get_globalの2番号を部分分解し、選択したconstructor条件を補います。
以前の3義務を再照合し、configure義務はconstructorからconfigureへ移してparentへ絞り、幅／LSBには同じ既存観測への別linkを加えます。
新しい分類は追加しません。全体は部分1961／分類405／未評価141で、分類は構造279／文脈126です。

第10章は部分87／分類29／未評価0、義務160件、主引用simulation 114テストです。
未評価0でも契約、返却型の食違い、元のM1目標を完了にしません。第18章は360／51／45のままで、義務834件、主引用simulation 500テストです。

全3796義務に直接テストがあり、直接対応2184テスト、control専用24テスト、control linkあり85テストです。
新入力はすべて直接義務を持ち、うち2件はcontrolも提供します。以前の3764義務のうち3761件は未変更で、3件を明示修正します。
ほかの全2175通常入力／記録、全405分類、全92 compiler記録は未変更です。範囲、分母、人のレビュー、元のmilestone目標は未承認／未完です。

全2208（simulation 2116／elaboration 92）、M1 948（869／79）、M2 547（542／5）、M3 713（705／8）です。
通常passは1900（runtime 1813／拒否87）、knownは308（runtime 220／build 83／不正受理5）です。
32入力を追加し、既存1入力を再測定し、ほかの2175件は未変更です。guestのfilterは新しく古くなった1記録を除外するもので、新しい実行ではありません。
HDL／command-lineの証拠と全92 compiler記録はbyte単位で未変更です。

新規32入力と修正した1入力を初回測定し、新しくtagを付けた一致30件を再測定します。
修正した既存ケースは既に現在のtag付きsourceであり、両seed一致の記録を保持します。未変更の限定build 2入力は正確な初回証拠を保持します。
測定中にhelper／期待値／本体のbyteを変えず、合算前に再帰的な入力／runner／library／設定とbatchの同一性を確認します。
local資料は`out/thin-seventy-first-`を使い、guest再実行や承認は主張しません。

## 薄い領域の72回目の拡充：recorder-linkの期間

[6608860](https://github.com/kurochan001/kirimasim-uvm-tests/commit/660886076f74d42dc7c7bfa2fad969c51af7d472)を基にします。

新規recorder-link検査系14件は、stream端点ではなく実際のrecorderを測定します。
open／closedの期間を扱う8件はseed 1／73で一致します。free済み端点の6件は必要なerrorがない差分をseed 1で保持し、seed 73はありません。
WARNING出力はERROR／FATALの観測を満たしません。新しいbuild失敗や不正compiler受理はありません。

独自helperは外部の記録databaseを使わず、database／stream／recorder callbackを提供します。
related、parent／child、cause／effect linkで、同じ／別streamの端点、片方／両方のclose、stream経由のclose、別peerのfreeを扱います。
不正期間はopen／close後の直接free、両端点のfree、open recorderのflush、所有streamのfreeで作ります。
実際のestablish_link呼出し前に、公開open／closed／handle観測で選択した状態を確認します。
独自catcherはその呼出し中のERROR／FATALで終了し、回復、診断文／件数、error後のbackend状態を仮定しません。
6検査系は観測であり、独立した不具合6件の証明ではありません。

日英AI義務14件で16.4.4を部分分解し、新しい分類は追加しません。
以前の全3796義務、全405分類、範囲案は未変更です。全体は部分1962／分類405／未評価140で、分類は構造279／文脈126です。
第16章は175／31／2、義務277件、主引用166テスト（simulation 157／elaboration 9）です。
章導入とtable-format概要は未評価で、全ての部分契約と元のmilestone目標は未完です。

全3810義務に直接テストがあり、直接対応2198テスト、control専用24テスト、control linkあり90テストです。
新しい正の入力5件はfree済み端点の6義務へcontrolも提供しますが、その一致で元の前提を置換しません。
以前の全2208通常入力／記録と全92 compiler記録は未変更です。範囲、分母、人のレビューは未承認／未完です。

最初のinclude-path構成の誤りは別に保存し、修正した入力でも元の規格由来の期待観測を保持します。
再現した8 sourceはタグで入力同一性が変わるため再測定し、spec-only 6 sourceはseed 1の差分を保持してseed 73はありません。
ツール検査110件、metadata、台帳／索引、ライブラリ、日英文書、CI selectorの検査を通します。
通常合計は2222検査系でpass 1908／known 314、guestは互換1082入力、未測定1140入力です。
goalの44回目の反復で未評価を1件減らして140件とし、元のmilestoneはどれも完了にしません。

## 薄い領域の73回目の拡充：正準bus操作

[92a85d8](https://github.com/kurochan001/kirimasim-uvm-tests/commit/92a85d88963935846643688e76edc20cc5f7da6f)を基にします。

新規の正準bus操作24検査系は、全registerまたは最初のmemory locationのreadとwriteを独立に測定します。
64 bitを64-bit busで、64 bitを32-bit busで、48 bitを32-bit busで扱い、両endianを選びます。
little-endian 12入力はseed 1／73一致、big-endian 12入力はseed 1の値の差分を保持しseed 73はありません。
新しいbuild差分やcompiler拒否検査は追加しません。

独自の数値word adapterは、testbench itemへ変換する前のreg2bus入口で正準descriptorを記録します。
read用の記憶域は独立に事前設定し、bus2regの件数は同じrequestへ結果を戻す変換で、driverの別response packet数ではありません。
完了後の観測用コピーだけをaddress順に並べ、busの時間順は固定しません。宣言したdata bitだけを検査します。
選択したbig-endianの単一wordではbyte反転、分割では選択write部分または戻り値の0を観測します。
件数／幅が正しくてもdataが異なる全入力をpassにはしません。12検査系の差分であり、独立した不具合12件やsimulator／libraryの原因を認定しません。

日英AI義務5件で19.1.2を部分分解します。既存のUVM-MEMORY-PARTIAL-BEAT-WIDTHはID、statement、以前のlink、限定を保持し、
新しいregister／memory条件と幅の観測を追加します。sub-byteの20-bit解釈は未解決です。
以前の3810義務のうち3809件は未変更、1件を再照合し、新しい分類は追加しません。
全体は部分1963／分類405／未評価139（構造279／文脈126）です。第19章は82／24／5、義務188件、主引用132検査系（simulation 127・elaboration 5）です。
pending transaction、parent sequence、HDL force／releaseの契約、全ての部分義務、元の目標は未完です。

全3815義務が2222テストへ直接対応し、ほかの24テストはcontrol専用、control linkあり98テストです。
単一cycle 8入力は分割件数のcontrolにもなり、4件が両seed一致、4件はknownで、それぞれ固有の直接義務を持ちます。
controlで分割入力を置換しません。以前の全2222通常入力／記録、compiler 92記録、互換guest、両backendのsnapshotは未変更です。
組み込みTLM payloadのbyte変換、外部RTL、4-state data、byte enable、任意memory stride、protocol／timingは別のままです。
範囲、分母、人のレビューは未承認／未完です。

独立したIEEE由来の24入力を実行前に固定し、一致した12 sourceはタグ変更後に再測定します。
続いて全24入力の補助引用を修正し、本体／helper／oracleが同じことを確認して、全ての最終sourceを新たに再測定します。
以前の記録は元の同一性で保存し、修正後の記録だけを現在のevidenceに数えます。known 12件はseed 1だけでseed 73はありません。全2246件で通常pass 1920／known 326です。
guestは互換1082記録、未測定1164入力を保持し、guestやbackendの再実行は主張しません。
ツール検査110件、metadata、台帳／索引、library、日英文書、CI selectorの検査を通します。
goalの45回目の反復で未評価を1件減らして139とし、元のmilestone目標は全て未完です。

## 薄い領域の74回目の拡充：policy差し替えと型付きstream

新規policy差し替え10検査系は、最終の現行入力でseed 1／73に一致します。
1つの未変更の独自object classでprinter／comparerとcopier／recorderの操作を交互に行います。
明示派生型はA／B／Aと切り替え、recordごとに新たに開いたrecorderを使い、再利用recorderの処理履歴が消えるとは仮定しません。
独自printer文字列、比較mask、選択policyの同一性、他observerの未実行、正確なcopier引数、現在のfield値を観測します。

pack 4入力とunpack 4入力で、bit／byte／int／longintのobject入口を別々に扱います。
独自observer tickで、field pack後の同型状態取得とfield unpack前の同型状態設定を確認します。
unpackが状態を消費する前に、pack戻り値を選択policyのget_packed_sizeと比較します。
streamは不透明のまま、同じ互換policy instance／型で往復し、現在のdataを確認しますが、独立した符号化／復号の正しさの証明にはしません。

日英AI義務5件で、明示pack／unpack policyの選択、型付き状態受渡し、pack戻り件数を分けます。
既存4義務はID、statement、旧linkを保持して限定付き条件と観測を追加し、以前の3811義務は未変更です。
個別に読んだ導入16は、操作・基底型・設定の義務を関連付ける文脈に分類し、親の重複義務や見出し名だけの除外を追加しません。
全体は部分1963／分類406／未評価138（構造279／文脈127）です。
第16章は175／32／1、義務277件、主引用176検査系（simulation 167・elaboration 9）で、16.2.10は未評価に残ります。
全ての部分条件と元のM1〜M4目標は未完です。

全3820義務が2232テストへ直接対応し、他の24テストはcontrol専用、control linkあり98テストの役割は保持します。
以前の全2246通常入力／記録、compiler 92記録、互換guest、両backend snapshotは未変更です。
新しい一致で既存の既知差分をpassにはしません。範囲、分母、人のレビューは未承認／未完です。

順序observer追加前の初回10件と、追加後のspecのみ10件は、それぞれ固有の入力同一性で両seed一致します。
後者の一致後にタグを追加し、最終10入力を再度測定します。以前のlogは元のhash付きで保存し、現在のevidenceへ付け替えません。
通常合計は1930 pass／326 knownです。guestは互換1082記録を保持し1174入力は未測定で、新しい実行／filterはありません。
goal第46反復で未評価を1件減らし138とし、元のmilestone目標は全て未完に残します。

## 薄い領域の75回目の拡充：printer属性と出力時の制御

新規printer可視性10入力は、seed 1／73一致6件と、seed 1だけのdefault-peer差分4件を保持します。
実table／tree／lineの各出力で名前／型／sizeの全8 maskを扱い、object sprint前、または反対maskでの収集後に設定します。
異なる独自の文字列属性を使い、可視性を数値size変換、行構文、見出し、列順／幅、罫線、句読点から分離します。
現在値、古い値の不在、独立peerを観測します。

選択した本体の可視性／値の検査は全て一致しますが、新規tree／line peerの型名とsize設定は必要な1に対して0を返します。
tableのdefault-peer 2入力と、別名でtree／line peerを明示有効化するcontrol 4入力は両seed一致です。
controlで未設定入力をpassにはせず、4検査系の差分から独立した不具合4件や原因は認定しません。

新規AI義務2件で実際の型名／size出力を分解します。名前出力と3設定getterの義務はID、statement、旧linkを保持し、
新しい条件と別に識別したcontrolを追加し、他の3816義務は未変更です。全406分類と範囲案も未変更です。
16.2.10は表形式概要の正確な行／列構文が規定されていないため未評価に保ち、今回の可視性検査でその解釈を完了にしません。
全体は部分1963／分類406／未評価138のままです。第16章も175／32／1で、義務279件、主引用186検査系（simulation 177・elaboration 9）です。
全ての部分条件と元のM1〜M4目標は未完です。

全3822義務が2242テストへ直接対応し、他の24テストはcontrol専用、control linkあり102テストです。
以前の全2256通常入力／記録、compiler 92記録、互換guest、両backend snapshotは未変更です。
範囲、分母、人のレビューは未承認／未完です。

初回6入力の記録はgetter診断行追加前の同一性で保持します。追加のgetter期待値も規格から1と定め、観測した0へ合わせません。
独立した明示peer control 4件を追加し、現行入力を再現してから一致6件にタグを追加し、最終10入力を測定します。
通常合計は1936 pass／330 knownです。guestは互換1082記録を保持し、1184入力は未測定です。
goal第47反復では部分条件を補強し、未評価138は減らしていません。元のM1〜M4目標は全て未完です。

## 薄い領域の76回目の拡充：adapter親sequence context

新規adapter parent-context 8検査系は、最終入力でseed 1／73に一致します。
独自1-byte protocolと選択したsequence基底を要求するdriverで、register／memoryのreadとwriteを独立に扱います。
prototypeはA／B／A、現在tagは17／34／51と切り替えます。paired入力はadapter、map、sequencer、driverの別々の2経路を並行実行し、peerは基底B／tag 119を保持します。
実pull-driver handshakeで、要求parent基底、現在tag、成功status、選択dataを観測します。read storageは独立に事前設定し、
両操作のjoin後に行を出力して完了順は規定しません。

独自の公開clone overrideがfixture定義のdo_clone bridgeを呼びます。
条項はdo_cloneのprototypeを示さず、標準signature、clone件数／同一性、生成名、任意の基底状態copy、外部RTLは推定しません。
明示caller-parentとの組合せは別のregister／memoryのchild規則のもとで未完に残し、今回の入力ではcaller parentを省略して、adapter規則による上書きを仮定しません。
predictor check_phaseは別のレビュー対象として未評価に残し、記載されたvoidの検査から診断severityを仮定しません。

日英AI義務1件で19.2.1.2.4を部分分解し、以前の全3822義務、406分類、範囲案は未変更です。
全体は部分1964／分類406／未評価137です。第19章は83／24／4、義務189件、主引用140検査系（simulation 135・elaboration 5）です。
残る未評価番号はpredictor check_phaseとHDL force／releaseの3項目です。
全ての部分義務と元のM1〜M4目標は未完です。

全3823義務が2250テストへ直接対応し、他の24テストはcontrol専用、control linkあり102テストです。
以前の全2266通常入力／記録、compiler 92記録、互換guest、両backend snapshotは未変更です。
範囲、分母、人のレビューは未承認／未完です。

独立した期待値を先に固定し、specのみの8入力が両seedで一致した後にタグを追加し、最終8入力を再測定します。
以前の記録は元の入力hashで保持し、通常合計は1944 pass／330 knownです。
guestは互換1082記録を保持して1192入力は未測定で、新しい実行／filterはありません。
goal第48反復で未評価を1件減らして137とし、明示caller-parentの組合せと元のM1〜M4目標は全て未完に残します。

## 薄い領域の77回目の拡充：実HDLのforceとrelease

新規HDL force／release 9検査系は、別のVPI条件でseed 1／73に一致します。
公開forceableの8／40-bit regとwireへforceし、反対の手続き代入／driver更新、通常release、即時release/readを観測します。
regは新しい手続き代入まで値を保持し、連続駆動wireは即時にdriverの解決値を返します。
独立した未force peerと存在しない／未instrument pathで、有効呼出しと宣言したbackend失敗を区別します。
独自backendは標準VPI force／release flagと文書化された公開capability markerを使い、path／valueの模擬やsimulator sourceの複製はありません。

宣言したbackendの変更で、sourceと期待値が同じ既存11入力も指紋が変わります。
11件の対応を再照合し、全20通常／HDL入力を新たに測定します。別HDL条件は19件が両seed一致、
保持するE.7 warning／転送なしの差分1件はseed 1で、seed 73の結果はありません。
通常20入力はDPIのlinkに失敗してspec-onlyのbuild knownを保持し、backendの一致を通常runnerのpassにはしません。

新規日英AI義務7件で19.6.2.3／.5／.6を部分分解します。zero-time force_timeの以前の2義務は、
制限の歴史的な記述を保持して現在backend／runnerの同一性更新を追記し、source／oracleとdepositだけの前提は未変更です。
他の以前の3821義務、全406分類、範囲案は未変更です。全体は部分1967／分類406／未評価134です。
第19章は86／24／1、義務196件、主引用149検査系（simulation 144／elaboration 5）で、predictor check_phaseは未評価です。
正時間force_time、広いHDL型、全ての部分義務は未完です。

全3830義務が2259テストへ直接対応し、他の24テストはcontrol専用、control linkあり103テストです。
影響しない通常2263記録、compiler全92記録、command-line 18記録、互換guest 1082記録を保持します。
新しいguest実行／filterはありません。範囲、分母、人のレビュー、元のM1〜M4目標は未承認／未完です。

新規9件の期待値を測定前に固定し、probe後に最終20通常入力と20HDL入力を測定します。
通常は1944 pass／339 known、別HDLは19 pass／1 failです。以前のbackend／runnerの証拠は元の同一性で保存し付け替えません。
goal第49反復で未評価を3件減らして134としますが、正時間force_time、未分解の部分義務、人のレビュー、分母承認、元のM1〜M4目標は未完です。
前の資料レビューで追加した日英の説明とリンクを保持し、現在の測定範囲に合わせて資料を更新します。

## 薄い領域の78回目の拡充：正時間のHDL force

新規の正時間force_time 8検査系は、未変更の別VPI HDL条件でseed 1／73に一致します。
実公開forceableの8／40-bit regと連続駆動wireを、同一または異なるtargetへ期間5／13で逐次呼出しします。
独立observerは各期間のoffset 1／3／duration-1で、反対の代入／driver変更を含めて観測します。
duration+1ではregがforce値を保持し、駆動wireはdriverへ解決し、その後の通常更新が見えます。
未使用targetと未force peerは独立した値を保持します。両scopeは共通のコンパイル既定時間単位を使います。

task宣言と戻り値本文の矛盾から、架空の結果assertionは作りません。
満了瞬間のprocess順、task復帰時刻、backend内部呼出し数、時間単位の変換／丸め、重なるstatic-task引数、中止、一般失敗cleanupは推定せず、部分条件に残します。

新規日英AI義務2件で、既に部分分解した19.6.2.4を補強します。以前の全3830義務、406分類、範囲、既存入力の同一性は未変更です。
全体は部分1967／分類406／未評価134のままで、未評価counterを減らさず部分契約を補強した拡充です。
第19章は86／24／1、義務198件、主引用157検査系（simulation 152／elaboration 5）で、predictor check_phaseは未評価です。

通常の新規8入力はspec-onlyのDPI link build knownを保持します。以前の通常2283記録とHDL 20記録は保持し、
別HDL条件は27件が両seed一致、保持するE.7の1件はseed 1差分です。
全3832義務が2267テストへ直接対応し、control専用24、control linkあり103です。
compiler、command-line、互換guest 1082記録は未変更で、新しいguest実行／filterはありません。
範囲、分母、人のレビュー、全ての部分義務、元のM1〜M4目標は未承認／未完です。

新規8件の期待値は測定前に固定し、最終通常8入力とHDL 8入力を測定します。
通常は1944 pass／347 known、別HDLは27 pass／1 failで、以前の2283通常記録と20 HDL記録は元の同一性で保持します。
goal第50反復では既に部分分解した条項を補強するため未評価134は変わらず、分類や分母は変更しません。
元のM1〜M4目標と全ての部分条件は未完で、読者向けの日英説明とリンクを保持して現在の資料を更新します。

## 薄い領域の79回目の拡充：register HDL pathと実storage

新規register HDL path 22入力は、標準concat view 8件、明示的な非標準公開member-view control 8件、実VPI転送6件を分けます。
標準view 8件はget_slices欠落のbuild差分を保持します。修正後のmember controlは7件が両seed一致、
祖先ごとの既定kindの1件はseed 1差分で、seed 73結果はありません。7 controlだけを再現タグ付きへ変えて新たに測定し、標準getter契約をpassにはしません。

物理6入力は、未変更の別backend条件で両seed一致です。公開backdoor_read直接呼出し、peek、pokeで、実16／40-bit whole変数の-1／-1 pathと、合法な2変数high／low referenceを観測します。
新data、独立storage、read counterで実HDL accessを区別し、peekだけで正確なbackdoor_read taskへの進入や公開宣言を証明しません。
通常6入力はDPI未linkのbuild knownを保持します。

APIの4番号へ日英AI義務14件を追加します。個別に読んだ18.4.6の整理見出しは構造分類し、以前の全3832義務、406分類、範囲案は未変更です。
全体は部分1971／分類407／未評価129、第18章は364／52／40、義務848件、主引用522 simulationです。
全3846義務が2281テストへ直接対応し、他の32テストはcontrol専用、control linkあり113です。
全ての部分義務と元のM1〜M4目標は未完です。

初回fixtureの引数方向と規格にないset_path呼出しは修正し、旧blob／logは再利用せず保存します。
collectorはhelper directory内の兄弟fileも含むため、修正後の全22入力を現在の同一性で測定し、タグ追加後の7 controlも再測定します。
以前の通常2291記録、HDL 28記録、compiler 92記録、command-line 18記録、互換guest 1082記録は未変更です。
新しいguest実行／filterはありません。範囲、分母、人のレビューは未承認／未完です。

独立期待値は測定前に固定し、fixtureの引数方向とAPI名、include directory指紋の影響を修正／監査してから現在の入力を測定します。
初回48 blobとlogは旧同一性で保存し、現在記録へ付け替えません。修正後の18入力と追加4物理入力を通常条件で測定し、タグ後の7 controlを再測定、別HDL 6入力も両seedで測定しました。
通常は1951 pass／362 known、別HDLは33 pass／1 failです。goal第51反復で未評価を5件減らして129にしますが、部分1971番号、元のM1〜M4目標、人のレビュー、範囲と分母は未完です。

## M1〜M4の薄い領域の80回目の拡充（register coverageの構築とsampling）

register coverageの新規12検査系はsimulation 10件と不正な外部access 2件です。
simulation 9件はseed 1／73に一致し、protected builder／addへの2呼出しは宣言した診断で拒否され、runtime seedは実行しません。
constructorでmodelを追加した測定の1件はseed 1差分で、seed 73結果はありません。搭載、有効union、非搭載modelのgateは一致しますが、以前のmaskを返すflagが期待1に対して0です。規格由来の期待値を保持します。

日英AI義務14件は完全階層名／単純patternのinclude、block／register／memoryの選択、要求した構築mask、constructor中の追加、protected／virtual宣言、field値samplingのdispatchを扱います。
既存の部分義務2件は元の文とlinkを保持して条件と直接linkを補い、個別に読んだ18.4.7の整理見出しだけを構造分類します。以前の全407分類と範囲は保持します。
全体は部分1975／分類408／未評価124、第18章は368／53／35、義務862件、主引用534検査系（simulation 532／elaboration 2）です。

sampling overrideは独自observerで、継承block methodが実際の再帰routingを行います。搭載／有効maskはcovergroup／binの測定を立証しません。
短いregister-builder契約はinclude APIと明示的なblockの類似契約と合わせて読み、AI解釈を明示します。
resourceの格納namespace、重複する優先順位、全regex対応、他のconstructor／階層条件は未完です。

一致入力はタグ追加前の証拠を得てからタグを付け、最終同一性で新たに測定します。
以前の通常2313記録、HDL 34記録、command-line 18記録、互換guest 1082記録の内容は保持し、新しいguest実行／filterやHDL／backend変更はありません。
guest未測定1243入力は追加1240件と修正した元入力3件（simulation 1149／elaboration 94）です。
全ての部分義務、元のM1〜M4目標、人のレビュー、範囲／分母承認は未完です。

要求は3860件、直接対応2293テスト、control専用32／control linkあり115です。通常は1962 pass（runtime 1873／compile拒否89）、363 known（runtime 244／build 114／不正受理5）です。

goal第52反復で未評価を129から124へ減らし、有効化時1463からの減少は1339です。全体の完了は未立証でgoalを継続します。

## 薄い領域の81回目の拡充：report macroとINFO境界

M1の新規runtime 18検査系は、基本reporting macro 4種と明示context形式4種を実行します。16件はseed 1／73に一致します。
限定した字義的INFO境界の2件はseed 1差分で、seed 73結果はありません。等しいverbosityで実行hookへ到達しMSGを評価しますが、厳密なlower-than解釈は抑制を期待します。
別の閾値より低い呼出しは一致しても、macro本文とAPIの等値を含む境界の違いは解消しません。

実report-server hookがseverity、verbosity、ID、本文、発信元、自動file／lineを取得し、既定textを比較せず、既定DISPLAY／COUNT／EXITを実行しません。
INFOのverbosity／actionによる抑制はMSG評価前に観測します。括弧なしif／else形式がcompileでき、選択した呼出しはcallerの正の時刻を保持します。
既定fatal終了やreport件数は認定せず、明示report-object RO引数によってoptional／report-message本文を解決しません。

初回の可視MSG判定は不要に評価1回を要求していたため、正の回数を要求する形へ修正し、抑制INFOの0回は保持します。
初回18入力のblob／logは旧同一性で保持して現在の証拠から除外し、修正後の全18入力を新たに測定します。
その一致から16件に再現タグを付け、最終入力も新たに測定します。期待値fileと独自helperは両段階を通じて未変更です。

日英AI義務16件は規範的なB.1と8 macro条項を部分分解します。個別に読んだB.1.1の整理見出しだけを構造分類し、以前の全3860義務、408分類、範囲案は未変更です。
全体は部分1984／分類409／未評価114、付録Bは111／5／28、義務220件、主引用157検査系（simulation 156／elaboration 1）です。
全3876義務は2311テストへ直接対応し、他の32テストはcontrol専用、control linkあり119です。全ての部分義務と元のM1〜M4目標は未完です。

以前の通常2325記録、HDL 34記録、command-line 18記録、compiler 94記録、互換guest 1082記録の内容は保持します。
新しいguest実行／filterやbackend／runner変更はありません。guest未測定1261入力は追加1258件と修正した元入力3件（simulation 1167／elaboration 94）です。
人のレビューと範囲／分母承認は未完です。

全2343件（simulation 2249／elaboration 94）、M1 1000（921／79）、M2 547（542／5）、M3 796（786／10）です。
通常は1978 pass（runtime 1889／compiler拒否89）、365 known（runtime 246／build 114／不正受理5）です。
goal第53反復で未評価124から114へ減らし、開始時1463からの減少は1349です。全体の完了は未立証でgoalを継続します。

## 薄い領域の82回目の拡充：callback登録とdispatch macro

M2の新規16検査系はcallback登録／dispatch macroを実行し、runtime 14件と不正なMETHOD signature 2件に分かれます。
runtime 13件はseed 1／73に一致し、compiler 2件は必要なhook82診断と共に拒否されruntimeを実行しません。
新しい未登録instanceへの空queue delete入力は、呼出し後のUT観測前にnull参照診断とexit 1でseed 1を終了し、seed 73結果はありません。
warningの不在やsimulator／libraryの根本原因は認定しません。

他の未登録呼出し3件はWARNINGの存在を観測し、text／ID／正確な件数を固定しません。
parameterized callbackのtypedef、暗黙caller同一性、参照引数の順序、明示enable状態、型付きvirtual dispatch、派生型のtypewide membership、
完了した呼出し間の登録変更、空callerの分離を観測します。affine値33／37とAB／BA traceは独自fixture codeの値です。
private登録bit、factory utilityの前提、反復中の変更、未指定のqueue間順序は仮定しません。

日英AI義務11件はB.4.1とB.4.3を部分分解します。以前の部分義務2件へ条件と直接linkを加え、元のstatementとlinkを保持し、
挿入profileの期待値と限界を拡張します。全409分類と範囲案は未変更です。B.4概要はcallback基底の本文が10.7.2.2.2と異なるため未評価に残します。
全体は部分1986／分類409／未評価112、付録Bは113／5／26、義務231件、主引用173検査系（simulation 170／elaboration 3）です。
全3887義務は2327テストへ直接対応し、他の32テストはcontrol専用、control linkあり121です。全ての部分義務と元のM1〜M4目標は未完です。

以前の通常2343記録、HDL 34記録、command-line 18記録、以前のcompiler 94記録、互換guest 1082記録の内容は保持します。
新しいguest実行／filterやbackend／runner変更はありません。guest未測定1277入力は追加1274件と修正した元入力3件（simulation 1181／elaboration 96）です。
人のレビューと範囲／分母承認は未完です。

全2359件（simulation 2263／elaboration 96）、M1 1000（921／79）、M2 563（556／7）、M3 796（786／10）です。
通常は1993 pass（runtime 1902／compiler拒否91）、366 known（runtime 247／build 114／不正受理5）です。
goal第54反復で未評価114から112へ減らし、開始時1463からの減少は1351です。全体の完了は未立証でgoalを継続します。

## 薄い領域の83回目の拡充：サイズ定義とversion識別

M1の新規size／version 12検査系はruntime入力11件と不正parameter代入1件に分かれます。
runtime 9件はseed 1／73に一致し、代入は選択したsource／parameter診断で拒否されruntimeを実行しません。
合法simulation buildの2件はruntimeなしのknownで、reserved＋129のflag拡張は64 bitを超えるenum methodの未対応を報告し、UVM_PACKER_MIN_BITSは未定義です。

既定flag幅、正確な符号なしbit-vector refへの互換性、reserved flagの和、reserved＋17拡張は一致します。
reserved数と下位bit配置は実装依存に残します。別の未変更packerは非一様8／64-bit fieldで32768 bitを保持し、
opaque encoding、割当方式、最大容量は規定せず、その一致でmacro存在を成功扱いにしません。
標準2020 version macro、非空の定数implementation string、POST_2017の存在は一致し、vendor textや記載外の過去macroは固定しません。

日英AI義務12件はleaf識別子7件を部分分解し、個別に読んだ本文のないB.6／B.7の整理見出しだけを構造分類します。
以前の全3887義務、以前の409分類、範囲案は未変更です。全体は部分1993／分類411／未評価103です。
付録Bは118／7／19、義務239件、主引用183検査系（simulation 179／elaboration 4）で、付録Fは92／23／22、義務211件、主引用124検査系（simulation 91／elaboration 33）です。
全3899義務は2339テストへ直接対応し、他の32テストはcontrol専用、control linkあり122です。全ての部分義務と元のM1〜M4目標は未完です。

初回の104桁commentは測定終了後に折り返し、初回source／expectedの23 blobを保管します。
測定で一致した10件に再現tagを付け、変更した最終12入力を全て新たに測定し、本体と期待値file 11件は未変更です。
以前の通常2359記録、以前のcompiler 96記録、HDL 34記録、command-line 18記録、互換guest 1082記録の内容は保持します。
新しいguest実行／filter、実装sourceの閲覧、backend／runner変更はありません。guest未測定1289入力は追加1286件と修正した元入力3件（simulation 1192／elaboration 97）です。
人のレビューと範囲／分母承認は未完です。

全2371件（simulation 2274／elaboration 97）、M1 1012（932／80）、M2 563（556／7）、M3 796（786／10）です。
通常は2003 pass（runtime 1911／compiler拒否92）、368 known（runtime 247／build 116／不正受理5）です。
goal第55反復で未評価103へ減らし、開始時1463から1360の減少です。全体の完了は未立証でgoalを継続します。

## 薄い領域の84回目の拡充：reportの列挙型とsequence state

新規runtime 13検査系は、uFにM1のreport／enum 8件とM2のsequence-state 5件を加えます。11件はseed 1／73に一致します。
限定した入力2件はexit 0のseed 1差分を保持し、seed 73結果はありません。字義的なverbosity無効化不可の解釈に対して負のID閾値でUVM_NONEが抑制され、
killは必要なpost_body／post_start callbackを呼びません。API境界queryとSTOPPEDの行は一致しても、差分のある全入力を成功扱いにしません。
根本原因、訂正、独立したbug件数は認定しません。

実公開APIは型付きseverity fieldを保持し、genericの非INFO reportで選択verbosity上限を無視し、標準INFO levelを等値込みで配送します。
ID／severity-ID閾値と独立reporterは選択した条件を保持します。別の既定server入力は正のquit上限100未満でCOUNT専用error 2件の後も継続します。
他の実行observerは既定DISPLAY／COUNT／EXIT動作を置換し、既定fatal終了を認定しません。

severity名の逆変換とone-hotな9 sequence stateを観測し、選択した全512 state maskがbit位置を固定せず所属を保持します。
通常／optional-hook無効のstartで実hook state、CREATED、FINISHEDと一致済みmaskの時刻を進めない待機を観測します。
killしたsequenceはpeerの正常完了中もSTOPPEDを保持し、同じhandleで後のstartを完了します。一過性ENDEDの採取と任意の取消時刻は未完で、
state専用の一致で字義的なkill post-callback義務を成功扱いにしません。

日英AI義務12件はF.2.2.1、F.2.2.4、F.2.4.2、F.3.4を部分分解します。以前のkill post-callback義務2件は直接／control linkのみを加え、
他の以前の3897義務、411分類、範囲案は未変更です。全体は部分1997／分類411／未評価99です。
付録Fは96／23／18、義務223件、主引用137検査系（simulation 104／elaboration 33）です。
全3911義務は2352テストへ直接対応し、他の32テストはcontrol専用、control linkあり123です。全ての部分義務と元のM1〜M4目標は未完です。

整形はnative測定前に終え、測定したpretagの28 blobを保管します。実測に基づくheader tag 11件は最終入力を新たに測定し、
負のID閾値observerは、選択したAPI呼出し内で正確な対象messageの正の観測を数える形へ補強し、ID閾値0の明示controlで同じobserverを確認します。
改訂した最終入力を新たに測定し、以前のobserver記録は旧同一性で保管して除外します。元の期待2行を保持し、規格に基づく正のcontrol 1行を追加します。
本体12件、期待値file 12件、helper 2件は未変更で、字義的kill入力は実pretag同一性を保持します。
以前の通常2371記録、compiler 97記録、HDL 34記録、command-line 18記録、互換guest 1082記録の内容は保持します。
新しいguest実行／filter、実装sourceの閲覧、backend／runner変更はありません。guest未測定1302入力は追加1299件と修正した元入力3件（simulation 1205／elaboration 97）です。
人のレビューと範囲／分母承認は未完です。

全2384件（simulation 2287／elaboration 97）、M1 1020（940／80）、M2 568（561／7）、M3 796（786／10）です。
通常は2014 pass（runtime 1922／compiler拒否92）、370 known（runtime 249／build 116／不正受理5）です。
goal第56反復で未評価103から99へ減らし、開始時1463からの減少は1364です。全体の完了は未立証でgoalを継続します。

## 薄い領域の85回目の拡充：virtual registerのbackdoor観測

新規M3 runtime 16検査系はvirtual register／fieldのpoke／peekを検査します。独自user backdoorの12件はseed 1／73に一致します。
実公開16-bit HDL arrayの4件も別VPI条件で両seedに一致し、通常実行はspec-onlyのDPI未linkによるbuild差分を保持します。
model記憶域と実HDL accessの違いは[virtual registerのFAQ](faq.ja.md#virtual-registerのbackdoor観測)で説明しています。

配列indexを2つ選び、独立したmemory内容と全raw wordのsnapshotで、index値、field slice、bit保持、peer要素、strideの隙間を検査します。
debug引数省略、正の行番号、負の行番号が同じ独立した判定を満たします。単一word条件は8／16-bit memory／registerと4／9-bit fieldです。
32-bit全register条件は同じ16-bitの両半分を使い、LSB 8の16-bit境界跨ぎfieldは独立に導いた結果pairのどちらの順序も許します。
これは配置順に依存しない必要な検査で、複数wordの一意な配置契約ではありません。内部access回数／順序、未使用の上位出力bit、
失敗時結果、並行処理、callback、resetによるsemaphore回復は未完です。

日英AI義務12件が18.9.1.3.3／.4と18.10.4.3／.4を部分分解し、個別に読んだ本文のない見出し18.9.1.3と18.10.4を構造分類します。
以前の3911要求と411分類は全objectをそのまま保持し、範囲案は未変更です。全体は部分2001／分類413／未評価93です。
第18章は372／55／29、義務874件、主引用550テスト（simulation 548／elaboration 2）です。
全3923義務は2368テストへ直接対応し、他の32テストはcontrol専用、control linkあり123です。

初期のinclude不足をnative runtime前に修正して保管し、実測runtime出力を使わずoracle照合で内部access所属の制限を外します。
最終期待値は実行前に固定します。再現した通常header 12件へtagを加えて新たに測定し、後のoracle照合で独自user記憶域を宣言memory word幅へ揃えるため、helper 1件とconstructor引数12件を変更します。
通常16件とHDL 4件は現在の指紋で全件を新たに測定し、幅制限前の記録は保管して除外します。
ステージ後の空白検査で物理source 4件の空行を整形し、通常／HDLの両条件で新たに測定して以前の指紋の記録を保持します。期待値fileは未変更です。
以前の通常2384記録、compiler 97記録、以前のHDL 34記録、command-line 18記録、互換guest 1082記録は内容を保持します。
新しいguest実行／filter、実装sourceの読取り、runner／backend変更はありません。guest未測定は1318入力へ増え、追加1315件と修正した元入力3件（simulation 1221／elaboration 97）です。
部分義務、元のmilestone目標、人のレビュー、範囲／分母承認は未完です。

全2400件（simulation 2303／elaboration 97）、M1 1020（940／80）、M2 568（561／7）、M3 812（802／10）です。
通常2026 pass（runtime 1934／compiler拒否92）、374 known（runtime 249／build 120／不正受理5）、別HDLは38件中37 pass・1 failです。
goal第57反復で未評価99から93へ減らし、開始時1463からの減少は1370です。全体の完了は未立証でgoalを継続します。

## 薄い領域の86回目の拡充：virtual registerのcallback契約

新規M3 20入力はcallback 17条件、合法宣言2条件、不正なvirtual直接構築1条件を追加します。
runtime 16入力はseed 1／73に一致し、compiler拒否1件はruntimeなしで一致します。
限定したfield pre-read順序2入力はexit 0のseed 1差分を保持してseed 73結果はなく、印刷上は具象のregister callback facadeはabstractとして拒否されruntimeがありません。
method、facade、構築の条件の違いは[callbackのFAQ](faq.ja.md#virtual-registerのcallback契約)で説明しています。

map別の独自frontdoorとuser backdoorは、変更前に3経路の正常性を確認します。実hookがpre-writeのdata／path、pre-readのmap／path、post-readのdata／status、post-writeのstatusを変更します。
親registerとfield単独の呼出しは別条件にします。最初／最後の観測は選択したread／write種別に限定し、内部transfer／callback回数を固定しません。
register側のpre-read整理は一致し、field method／facadeをregisterより後にする解釈は、存在、値／status、post順序の行が一致しても差分を保持します。
限定した解釈から訂正、根本原因、独立した欠陥件数を認定しません。

初期のfield単独部分writeはfrontdoor／backdoorの内容が不整合で、変更を無効にしたcontrolにも同じ非選択bit差分が出たため、post-statusの欠陥の証拠にはしません。
修正した新入力は使用するfrontdoor／backdoorを同じ記憶域へ明示的に結び、元の期待6行を保持し、変更なしcontrolとmemory postより後のfield postを確認して両seedに一致します。
初期／診断入力とlogは保管して除外し、指紋を付け替えません。実測に基づくtag 17件は最終入力を新たに測定し、helper、他の本体19件、他の期待値file 18件は未変更です。

規格に基づく構築期待の固定後に、固定Apacheライブラリのsrc/reg/uvm_vreg.svhの宣言を確認し、register callback facadeはvirtualでbuild拒否と整合します。
印刷されたIEEEのclass期待は保持します。合法派生型は別のcontrolで、拒否した直接構築入力を成功扱いにしません。simulatorの実装sourceや商用結果は使いません。

日英AI義務24件がcallback／宣言の11 leafを部分分解し、個別に読んだ本文のない見出し4件とfacadeの説明的導入2件を構造／文脈分類します。
以前の3923義務、413分類、範囲案は全objectを保持します。全体は部分2012／分類419／未評価76、第18章は383／61／12、義務898件、主引用570テスト（simulation 567／elaboration 3）です。
全3947義務は2388テストへ直接対応し、他の32テストはcontrol専用、control linkあり124です。

以前の通常2400記録、compiler 97記録、HDL 38記録、command-line 18記録、互換guest 1082記録は内容を保持し、新しいguest実行／filterやrunner／backend／tool／workflowの変更はありません。
guest未測定1338入力は追加1335件と修正した元入力3件（simulation 1240／elaboration 98）です。
部分適用条件、失敗起点／競合／無効callback、blocking、並行処理、reset回復、限定解釈、元のmilestone目標、人のレビュー、範囲／分母承認は未完です。

全2420件（simulation 2322／elaboration 98）、M1 1020（940／80）、M2 568（561／7）、M3 832（821／11）です。
通常2043 pass（runtime 1950／compiler拒否93）、377 known（runtime 251／build 121／不正受理5）です。
goal第58反復で未評価93から76へ減らし、開始時1463からの減少は1387です。部分義務と元の目標の完了は未立証でgoalを継続します。

## 薄い領域の87回目の拡充：kill後のaccess復旧とfrontdoor照会

新規M3 runtime 16入力は、kill後のaccess復旧8条件とregister frontdoor照会8条件です。12件はseed 1／73に一致し、限定したnull-setter 4入力はseed 1でexit 1停止し、seed 73結果はありません。
セマフォのresetとdata resetの違い、mapを明示する条件は[accessのFAQ](faq.ja.md#killしたaccessの復旧とfrontdoorの選択)で説明しています。

復旧入力は、両配列indexと独立peerの正常性を先に確認します。実virtual-register readまたはwriteを独自user backdoor内の記憶域処理前で待機させ、到達確認後に呼出しprocessをkillします。
同じmemory／providerのpeerが引き続き動作することを確認し、reset()またはreset("HARD")の後、別indexへの新accessとvictim indexのreadを実行します。
全32 raw wordを照合します。victim／復旧操作4組、reset引数2形式、2つのindexで有限の復旧を観測します。
reset前のkill済みaccessが必ずlockされたままとは要求せず、規格の時間期限、待機者順序、自動cleanupも主張しません。

frontdoor入力は、単一mapの省略／明示getterと、2つのmapでの明示選択を使います。非nullの4 variantは、初期null／現在のhandle、独自providerのread値、置換、debug引数の機能不変性、peer register、他map、復元を確認します。
未変更の探索入力4件はさらにnull-as-clearを試み、最初の5行が一致した後にnull参照で停止します。setterは解除を明記しないため、これらは解釈照合待ちのcontrol専用で、無条件のIEEE不具合を主張しません。元の期待出力を保持し、非nullの一致で元入力全体をpassにしません。
複数mapのregisterでは必ずmapを指定し、物理busやHDLは主張しません。

日英AI義務5件がresetとfrontdoor getter／setterを部分分解し、個別に読んだ本文のないFront door見出し1件を構造分類します。
以前の3947義務、419分類、範囲のobjectは保持します。全体は部分2014／分類420／未評価73、第18章は385／62／9で、義務903件、主引用586テスト（simulation 583／elaboration 3）です。
全3952義務は2400テストへ直接対応し、他の36テストはcontrol専用、control linkあり128です。

以前の通常2420記録、compiler 98記録、HDL 38記録、command-line 18記録、互換guest 1082記録は内容を保持します。
新しい実測由来tagは本体／helper／期待値を変えずに新たに測定します。guest未測定1354入力は追加1351件と修正した元入力3件（simulation 1256／elaboration 98）です。
新しいguest実行／filter、runner／backend／tool／workflow変更、実装由来oracle、商用結果はありません。
残る部分適用条件、存続待機者、frontdoor取消、predictor check_phase、限定callback解釈、元の目標、人のレビュー、範囲／分母承認は未完です。

全2436件（simulation 2338／elaboration 98）、M1 1020（940／80）、M2 568（561／7）、M3 848（837／11）です。
通常2055 pass（runtime 1962／compiler拒否93）、381 known（runtime 255／build 121／不正受理5）です。
goal第59反復で未評価76から73へ減らし、開始時1463からの減少は1390です。部分義務と元の目標の完了は未立証でgoalを継続します。

## 薄い領域の88回目の拡充：rootの終了guardとpredictorのcheck

新規20入力はM1の12件（simulation 11／elaboration 1）とM3のsimulation 8件です。
runtime 10件はseed 1／73に一致し、非公開constructorの拒否1件はruntimeなしで一致します。元の5入力はexit 0のseed 1観測を保持しseed 73なし、未登録packetの4入力はruntimeなしのbuild拒否を保持します。
条件の違いは[root／predictorのFAQ](faq.ja.md#rootの終了guardとpredictorのcheck)で説明しています。

getter履歴とcaller所有の終了は一致します。別の正時間controlは、既定／再有効化の終了が後続activityより先であること、child callbackの先行を要求しないbuild errorのfatalがstart-of-simulationより先であること、root extensionのfatalが後続activityより先であることを観測します。
未変更の厳しい入力は同時刻の返却と早いguardの順序を保持します。遅いchild error入力はbottom-upでのcheck配置という限定した期待を直接保持し、必要なfatalなしにstart-of-simulationへ到達します。無条件の根本原因や独立欠陥件数を導きません。

明示登録packetの4 controlは、独立した未完了／完了modelと実bottom-up check phaseを使い、1／2 registerとlittle／big endianを扱います。完了mirror／publicationが一致し、残存転送は何らかのreportを生成します。
severity、ID、本文、件数は固定せず、CAUGHTは生成だけを観測して既定fatal／abortを検査しません。元の期待値固定とbuild拒否の後、固定Apacheの型名生成function 1つを確認し、BUSTYPEのfactory生成が未登録型の診断と整合します。
登録は独立controlの前提で、IEEEの追加必須条件にしません。初期12本体と期待値はすべて未変更で、control一致で元入力全体をpassにしません。

日英AI義務8件がroot／predictorの5 leafを部分分解し、新しい分類や範囲承認は追加しません。以前の3952義務、420分類のobjectは保持します。
全体は部分2019／分類420／未評価68です。付録Fは100／23／14、義務230件、主引用149テスト（simulation 115／elaboration 34）で、第19章は87／24／0、義務199件、主引用165テスト（160／5）です。
全3960義務は2412テストへ直接対応し、他の44テストはcontrol専用、control linkあり136です。第19章の未評価0で部分契約87件を完了にしません。

以前の通常2436記録、compiler 98記録、HDL 38記録、command-line 18記録、互換guest 1082記録は内容を保持します。実測由来tag 11件は本体／helper／期待値を変えずに新たに測定します。
guest未測定1374入力は追加1371件と修正した元入力3件（simulation 1275／elaboration 99）です。
新しいguest実行／filter、runner／backend／tool／workflow変更、実装由来oracle、simulator source参照、商用結果、人のレビューはありません。
限定したshutdown／guard／宣言／report解釈、全ての部分適用条件、元の目標、範囲／分母承認は未完です。

全2456件（simulation 2357／elaboration 99）、M1 1032（951／81）、M2 568（561／7）、M3 856（845／11）です。
通常2066 pass（runtime 1972／compiler拒否94）、390 known（runtime 260／build 125／不正受理5）です。
goal第60反復で未評価73から68へ減らし、開始時1463からの減少は1395です。部分義務と元の目標の完了は未立証でgoalを継続します。

## 薄い領域の89回目の拡充：enumの効果とMAMの選好

新規runtime 14入力はM1のcallback順序2件とM3のmanager／configuration 12件です。9件はseed 1／73に一致します。
5件はexit 0のseed 1で選好の差分を保持し、seed 73結果はありません。上位の解放履歴を持つGREEDY、下位／上位履歴のTHRIFTY、有効region 1／2個のNEARBYです。
これらの入力でも境界、幅、非重複、保持端点／所属、cleanupは一致し、他条件のpassで全入力をpassにしません。異なる前提は[enum／allocationのFAQ](faq.ja.md#列挙型の効果とallocationの選好)で説明しています。

実際の有効callback dispatchは、どちらのmodeからも始める型付きappend／prependの交互挿入5回と独立した空peerを観測します。
未変更の型付き／既定agentテストは既にF.2.1.7を引用し、互換な実測記録を保持します。新しい要求linkは新しい実行でも主引用件数の追加でもありません。enum数値encodingや全agent動作も推論しません。

manager configurationのcycleは、型付きmode／locality、以前／現在のhandle、独立peer、有効regionを観測します。別のrand-field入力は選択fieldを反対値へ初期化してから、object randomizationで変更するよう制約します。
readbackだけで乱数性やallocation選好を証明しません。新規／再利用の歴史的解釈は限定し、各trialは1つの観測requestで統計的保証ではありません。
NEARBYはどちら側／どの適格な隣接先も許し、BROADは選択した明示非隣接policyを検査して非制約の分布を要求しません。

最終選択前にMAM helperだけへrequest前の保持端点snapshotを追加しました。初期12 source本体と期待値、および後のrand-field 2本体／期待値は実測由来tag以外を変更していません。
以前のMAM入力／logは保管して除外し、全変更入力を新たに測定して指紋を読み替えません。日英AI義務13件がenum／configurationの6 leafを部分分解し、新しい分類は追加しません。
以前の3960義務、420分類、範囲案のobjectは保持します。全体は部分2025／分類420／未評価62です。
付録Fは102／23／12、義務233件、主引用151テスト（simulation 117／elaboration 34）で、第18章は389／62／5、義務913件、主引用598テスト（595／3）です。
全3973義務は2426テストへ直接対応し、他の44テストはcontrol専用、control linkあり136です。

以前の通常2456記録、compiler 99記録、HDL 38記録、command-line 18記録、互換guest 1082記録は内容を保持します。実測由来tag 9件は最終入力を新たに測定しました。
guest未測定1388入力は追加1385件と修正した元入力3件（simulation 1289／elaboration 99）です。
新しいguest実行／filter、runner／backend／tool／workflow変更、実装由来oracle、商用結果、人の照合、範囲／分母承認はありません。
全ての部分適用条件、限定した履歴／locality解釈、元の段階目標は未完です。

全2470件（simulation 2371／elaboration 99）、M1 1034（953／81）、M2 568（561／7）、M3 868（857／11）です。
通常2075 pass（runtime 1981／compiler拒否94）、395 known（runtime 265／build 125／不正受理5）です。
goal第61反復で未評価68から62へ減らし、開始時1463からの減少は1401です。部分義務と元の目標の完了は未立証でgoalを継続します。

## 薄い領域の90回目の拡充：manager policyと印刷backdoor task

新規M3 runtime 16入力はpolicy履歴8件、manager説明2件、有効region descriptor履歴2件、印刷されたregister backdoor taskのdispatch 4件です。
14件はseed 1／73に一致します。矛盾／修復の2入力はexit 0のseed 1で差分を保持し、seed 73結果はありません。
失敗requestのpost-hook predicateが異なる一方、null、文脈、保持region、後の修復済み割り当ては一致します。他条件の一致で全入力をpassにしない範囲は[manager文脈のFAQ](faq.ja.md#manager-policyの文脈と印刷backdoor-task)で説明しています。

policyのpre／post observerは正確なretry回数ではなく発生を数え、丸めた長さ、設定境界、順序によらない以前の割り当てhandleを検査します。
既定policyの反復／置換、非互換な既定値に対する明示policy、現在の既定値への復帰、矛盾／修復を2つのlocation幅で扱い、保持端点と独立peerも別に確認します。

説明ケースはstring返却と、非空で異なる選択占有状態のsnapshotを検査し、配置やaddress文法を固定しません。これは限定した部分解釈で、人に読めることの完全な証拠ではありません。
region descriptorは割り当て中に比較し、直接構築の禁止や解放後のobject同一性は推論しません。独自backdoor本体は印刷された基底taskの宣言／dispatchを検査し、既定UVM algorithm、DPI、register accessの経路、任意の監視動作を認定しません。

現行測定の前にpolicy helperの予約語だったlocal識別子を改名し、SystemVerilog 18.6.2が要求する基底randomization hook呼び出しを追加しました。
以前の構文／observer版は保管して除外し、影響する8入力を新たに測定します。16 source本体と期待値は実測由来tag 14件以外を変えず、指紋を読み替えません。
必要な基底呼び出しを備えた別のignored診断では、独自plain class、policy、MAM requestでrandomizeがfalseを返した後のpost-hook増加を両seedで観測します。
空UTのharnessを動作のpassとせず、元のknown 2入力のseed 73 evidenceも追加しません。実装sourceで期待値を定義せず、既定MAMの欠陥を認定しません。

日英AI義務15件が以前に未評価だった4 leafを部分分解し、新しい分類は追加しません。以前の3973義務と420分類のobjectは保持します。
現在は部分2029／分類420／未評価58です。第18章は393／62／1、義務928件、主引用614テスト（simulation 611／elaboration 3）で、付録Fは102／23／12のままです。
全3988義務は2442テストへ直接対応し、他の44テストはcontrol専用、control linkあり136です。元の段階目標と全ての部分適用条件は未完です。

以前の通常2470記録、compiler 99記録、HDL 38記録、command-line 18記録、互換guest 1082記録は内容を保持します。
guest未測定1404入力は追加1401件と修正した元入力3件（simulation 1305／elaboration 99）です。
新しいguest実行／filter、runner／backend／tool／workflow変更、商用結果、人の照合、範囲／分母承認はありません。

## 薄い領域の91回目の拡充：型付き役割とtopology policy

新規runtime 13入力は、既存の機能対象の分類でM1が11件、M2のport／analysisが2件です。10件はseed 1／73に一致します。
3入力はexit 0のseed 1で差分を保持し、seed 73結果はありません。共有domain内の反復IMP lookup 2件は厳しいschedule内の限定解釈、1件は安定したUNINITIALIZED IMPへの字義どおりのEQ／NE比較です。
他の型／走査と大小比較の観測は一致し、異なる前提は[型付き役割のFAQ](faq.ja.md#名前付きの役割待機演算とtopology-policy)で説明しています。

別phase入力は両scheduleをdomainへ接続する前にnodeを取得し、その後の独立文脈と実topdown／bottomup走査を検査します。
これらで元の接続後lookup入力をpassにしません。公開同一性の診断では、その2 queryが最初のscheduleのnodeを返すことを観測し、重複IMPのscope選択はレビュー事項に残します。
UNINITIALIZED状態の待機は字義どおりの等値／非等値期待を保持します。状態maskの意味と未実行implementationへの適用は限定し、確定した欠陥や実phase全体の完了を主張しません。

型付きconstructor役割に加えて、反対のchild providerへの実analysis転送を検査します。型付きobjection eventはraise・部分drop・独自callback処理後のall-dropped完了を、drain 0と未変更peerで区別します。
topology printerの明示・省略・null呼び出しは、選択policyの同一性と独自component 5つの訪問を検査します。enum数値encoding、兄弟順序、正確な表示文面、callback回数は固定しません。
独自topology emitterにだけ改行を加えてUT行をreporter文面から分離し、以前の区切り不足の記録を除外して、期待行を変えず依存する3入力を新たに測定します。

13 source本体と期待値は実測由来tag 10件以外を変えていません。日英AI義務21件は付録Fの20件と限定した第9章lookup 1件で、以前に未評価だったFの5 leafを部分分解し、新しい分類は追加しません。
未変更constructor sourceは既にF.2.5.1を引用し、直接の識別子linkを加えても新しい実行や主引用を増やしません。元／prescoped phase入力にはdirect／controlの役割を明示し、他条件のpassで元入力をpassにしません。

以前の3988義務、420分類、通常2486記録は内容を保持します。現在はAI義務4009件、直接対応2455テスト、control専用44テスト、control linkあり140です。
棚卸しは部分2034／分類420／未評価53です。付録Fは107／23／7、義務253件、主引用164テスト（simulation 130／elaboration 34）です。
第9章の1義務追加で主引用入力を増やさず、全ての部分適用条件と元の段階目標は未完です。

compiler 99記録、HDL 38記録、command-line 18記録、互換guest 1082記録も未変更で保持します。
guest未測定1417入力は追加1414件と修正した元入力3件（simulation 1318／elaboration 99）です。
新しいguest実行／filter、範囲／catalog、runner／backend／tool／workflow変更、商用結果、実装由来oracle、人の照合、範囲／分母承認はありません。

## 薄い領域の92回目の拡充：sequence-libraryのmodeとheartbeatのwindow

新規runtime 28入力はM2のsequence library 16件とM1のheartbeat 12件で、16件がseed 1／73に一致します。
標準mode APIの8入力はsetter／getter欠落でruntime前に停止します。4件はexit 0のseed 1で差分を保持し、seed 73結果はありません。
監視外outsiderが活動するONE_ACTIVE入力2件と、字義どおりの無効化を限定して解釈するNO_HB_MODE明示入力2件で、条件の違いは[mode／windowのFAQ](faq.ja.md#sequence-libraryのmodeとheartbeatのwindow)で説明しています。

4つの標準library modeは記載setter／getter呼出しと実行のpredicateを保持します。既定RANDの2入力は反対の合法indexを制約し、反対のchild型を実行します。
別のlegacy-field control 6件は、2型の循環選択、childを実行しない実item-driver handshake、独自USER選択hookを観測します。
controlで標準API入力をpassにしません。enum数値encoding、任意の乱数列、未指定の登録順、count accessorの置換、sequence library全体の完了は主張しません。

heartbeatのALL windowには両監視actor、ANY windowには一方または両方が参加します。元のONE windowでは監視actorのちょうど1つが反復した釣り合うraise／dropを行い、監視外outsiderも活動します。
outsiderの活動だけを外す別controlは一致しますが、元入力は最初のwindowの報告差分を保持します。公開reportの診断は報告を識別するためのもので、severity、文面、件数をoracleとして固定しません。
独自catcherは非INFO報告で終了を要求し、その後の継続や回復を仮定しません。

NO_HB_MODEの2入力は正常なALLまたはONE windowを先に完了し、その値を明示して空windowが静かであることを期待します。
選択値は無効値として読み戻されず、後続windowで報告を生じます。F.2.11はこの値を無効とし、10.6.2.2は照会の既定値に使うため、APIによる設定は限定した解釈の疑問であり、確定した欠陥の帰属ではありません。
別stop control 2件は記載stop methodを使って一致し、字義的mode入力をpassにせず、以前の照会テストも書き換えません。

最終proofの前に独自library検査系を強めてRANDの2 variantが異なるchild型を実行するようにし、独自heartbeat catcherには非UTの公開report診断を加えました。
期待値は未変更です。全依存入力を新たに測定し、以前の入力の記録は保存して現在の証拠から除きます。独立性の追加確認でALLの2件目には別helperを用意し、監視list／参加順を反転し、countもA2／B1からA1／B3へ変えます。
期待行は未変更で、tagの前に両seedを測定し、tagの後でも新たに測定します。現在の実測済みtag 16件は互換な最終記録を持ち、入力指紋の読み替えはしません。

日英AI義務10件は、付録Fの8件、mode APIによる実行1件、明示stop 1件です。F.2.4.3とF.2.11を部分分解し、新たな分類は追加しません。
以前の4009義務、420分類、通常2499記録は内容を保持します。現在は4019義務、直接対応2475テスト、control専用52テスト、control linkあり150です。
棚卸しは部分2036／分類420／未評価51です。付録Fは109／23／5、義務261件、主引用192テスト（simulation 158／elaboration 34）です。部分的な全適用条件と元の段階目標は未完です。

compiler 99記録、HDL 38記録、command-line 18記録、互換guest 1082記録を未変更で保持します。
guest未測定1445入力は追加1442件と修正した元入力3件（simulation 1346／elaboration 99）です。
新しいguest実行／filter、範囲／catalog、runner／backend／tool／workflow変更、商用結果、実装由来oracle、人の照合、範囲／分母承認はありません。

## 薄い領域の93回目の拡充：radixの意味とtable row

新規M1 runtime 14入力は、整数radix flag、packed／native文字列、型付きrealの3表記、time／enum field、recording metadata／data、短いtable rowを調べます。
10件はseed 1／73に一致し、4件はexit 0のseed 1差分を保持してseed 73結果はありません。real表記2件と限定した字義%u control 2件で、入力ごとの結論は[radix／observerのFAQ](faq.ja.md#radixの意味とobserverの限界)で説明しています。

整数のBIN／OCT／HEX／DECと、符号なし10進という文言の解釈は32／65-bitの符号なし値を保持します。明示NORADIXと省略は選択HEX／BIN既定値を使います。
符号なし10進という文言と記載%uは食い違い、SystemVerilogの%uはraw 2-value出力なので、別の字義controlで代替解釈を保持し、元の文言入力をpassにせず書き換えません。
packed ASCII／native文字列とenum名は一致します。timeは同UVM package文脈の公開print_time controlと明示したglobal format suffixに一致し、絶対単位、scope間変換、丸めは未完です。

型付きreal flagは独立したgeneral／decimal／exponential期待を保持します。数値は一致しますが、両ケースで指数表記がなく、選択した大きいgeneral値も期待する指数を欠きます。
選択した表記の観測であり、完全な精度／丸めや確定した欠陥の帰属ではありません。recordingケースは、名前付き14選択、値、幅、操作ごとの件数を実際の独自の開いたrecorder hookへ渡し、peerは待機したままです。
NORADIXは未指定のままか、解決位置を指定しないhook境界で設定済みの既定値へ解決でき、測定前からその2形式だけを許します。
UNFORMAT2／4はそのmetadata／data境界を検査するもので、binary DB配置、endianness、X／Z描画は未検証であり、NULを含む不可能なstring oracleは作りません。

独自の整数observerは合法な可変scanf formatを使いましたが、コンパイラが拒否したため、同じpredicateを定数format 4分岐で保持します。
別の小さな言語診断では10進18446744073709574711を表示してもcount 1で7fffffffffffffffと解析し、observerの幅制限を切り分けました。65-bitケースの別の独自桁算術observerは両seed一致です。
以前のparser buildと誤ったwide観測は保存して、現在のUVM証拠から除きます。14 source本体と期待行は未変更で、実測したtag 10件とhelper宣言1件の変更に互換な新しい測定があります。
言語診断で正規テスト、元入力のseed結果、実装由来期待値を追加しません。

実table printerは、caller指定の名前／型／size／値のcellを短い2／3 rowに対応させ、挿入順を反転し、peerは別のcellを保持します。
物理rowの読み方はこれらのcellへ限定し、正確なheader、列順、幅、padding、句読記号、全wrapping／複数行配置を固定しません。
新規の日英AI義務16件はradix選択14件、scalar flag 1件、限定したtable 1件です。既存のrecording 2義務に新たなlinkを追加し、名前／値／metadata転送の義務を重複させません。F.2.1.5と16.2.10を部分分解し、分類や完了を記録しません。

以前の4019義務の本文、条件、期待、照合は保持し、既存2件のtest link一覧だけを拡張します。420分類と通常2527記録は内容を保持します。現在は4035義務、直接対応2487テスト、control専用54テスト、control linkあり154です。
棚卸しは部分2038／分類420／未評価49です。付録Fは110／23／4、義務275件、主引用204テスト（simulation 170／elaboration 34）です。
第16章は176／32／0、義務280件、主引用188テスト（simulation 179／elaboration 9）で、未評価0は完了を意味しません。主引用のある番号は1283です。
実際の以前の棚卸しでも引用された番号は既に2071だったため、新たな3引用を主張せず、現在の本文を2068から2071へ直します。部分的な全契約と元の段階目標は未完です。

compiler 99記録、HDL 38記録、command-line 18記録、互換guest 1082記録は未変更です。
guest未測定1459入力は追加1456件と修正した元入力3件（simulation 1360／elaboration 99）です。
新しいguest実行／filter、範囲／catalog、runner／backend／tool／workflow変更、商用結果、人の照合、範囲／分母承認はありません。

## 薄い領域の94回目の拡充：package公開・root view・低水準macro

M1のruntime 10入力で、package access、暗黙rootの階層と基底view、低水準のcustom文字列登録、裸event fieldのcopyを検査します。
最終tag付き8入力はseed 1／73に一致し、event 2入力はexit 0のseed 1差分を保持してseed 73記録はありません。
入力ごとの前提と解釈は[package／root／macroのFAQ](faq.ja.md#package公開root-view低水準macro)で説明しています。

別々の字句scopeを持つ2 packageで、UVM wildcard importなしの修飾参照とimportした参照を使い、選択したclass、型、enum値、global methodを観測します。
全公開symbolの認定やmacroのpackage member扱いはしません。root 2履歴は最初のgetの前または後にnull-parent childを生成し、2 branchとleafを追加してcomponent／object基底viewを保持し、後のchildを観測します。
F.7.1には結合した識別子uvm_root_extendsが印字されており、周辺のroot説明から意図されたcomponent継承を明示的に限定解釈し、黙って修正したり新しい必須classとしたりしません。
他のphase、reporting、root条件は部分的に残ります。

registry 4入力は低水準object／component macroだけを使い、class名と異なるcustom照会文字列を指定します。
witness生成後に公開factoryで照会し、生成順の反転、aliasの反復、実際の具体型、名前、parent、独立状態を観測します。
full utils macro、明示登録、type_id／get_type呼出し、手書き生成methodで効果を代行せず、最早static登録時点は主張しません。

裸event入力は、実際のmacro copy前に元targetのwaiter、後に新waiterを、正時間を隔てて待機させます。
COPYは選択eventをaliasし、COPY|NOCOPYは独立したtarget通知を保持しますが、copy前の有効waiterも起き、event合併のqueue規則の解釈と異なります。
選択trigger前の待機を含む他の選択行は一致します。UVMなしの独立した独自言語probeでも、先に定めたold=0、fresh=1に対しold=1、fresh=1を観測します。
これは正規テスト、guest測定、元入力のseed 73結果を追加せず、libraryだけへの原因帰属を支持しません。
裸eventと代入としてのcopyは明示AI解釈に残し、compare、packing、recording、任意の並行置換は未完です。

最初のnull三項式とevent準備のcompiler失敗はhelper／言語の依存条件でした。
同じ意味のBooleanによるroot観測と、event代入を使わない準備には新しい記録があり、元の失敗を現在のUVM件数から除外します。
元のevent predicateはすべて保持し、選択trigger前の待機検査を追加します。

以前の4035要求を変更せずAI義務6件を追記します。FとF.1には個別の根拠に基づく構造／文脈の分類を追加し、1.4.5、F.7、F.7.1、選択したBの3 macroを部分分解します。
現在は4041義務、直接対応2497テスト、control専用54テスト、control linkあり154です。棚卸しは部分2044／分類422／未評価41です。
付録Fは112／25／0、義務277件、主引用208テスト（simulation 174／elaboration 34）で、未評価0でも完了ではありません。
主引用のある番号は1288件、引用がある番号は2076件です。以前の通常2541記録と索引、以前の420分類、compiler 99記録、HDL 38記録、command-line 18記録、guest 1082入力を保持します。
guestの未測定は1469入力で、追加1466件と改訂済みの元3件（simulation 1370／elaboration 99）です。
人の照合、範囲／分母承認、元の段階目標の完了は記録しません。

## 薄い領域の95回目の拡充：collection macroの値とopaque状態

M1のruntime 32入力でcollectionのpacking／unpacking macro 12種類を検査し、unsigned要素を2つまたは4つ使います。
static array 8入力は限定した片方向scalar-API観測を保持し、24入力は互換なmacro対を検査します。unpacking中心の入力では型の対応したopaque状態の転送も行います。
最終入力はすべてseed 1／73に一致し、各profileが立証できることは[collection macroのFAQ](faq.ja.md#collection-macroの値とopaque状態)で説明しています。

明示Nは正の定数9／97で、109-bit記憶域の選択幅外にもbitを立て、推定幅は13／97です。
static arrayは非zeroの昇順／降順範囲を使い、dynamic arrayとqueueは空でなく事前にサイズを設定します。
独立に選んだsource値をsentinel宛先へ復元し、shape、元source／marker fieldの保持、独立object／policy peer、別の7-bit trailerを観測します。
get_packed_bitsのopaque状態は変更せずfreshで同じ型の互換policyのset_packed_bitsへ渡し、そのconsumerが消費しても元policyは未消費を保ちます。
状態の長さや内容をwire形式として解釈しません。

最初に提案したdynamic array／queueのflat／headerなしoracleは強すぎる前提でした。collection条項はprimitive操作の要素だけの列や特定の長さframingを約束していません。別にIEEE16.5.3.1／.2はexport状態の長さ／形式を未規定とし、修正入力で使う型の対応した転送を規定します。
このテスト前提の誤りを確認して仮batchを意図的に停止し、影響した提案16入力は正規索引への登録前に修正して新しく測定しました。
完了済みの初期記録と入力は保存し、UVMの差分件数から除外します。固定Apache UVM macroは差分後に長さprefixの診断だけに読み、header algorithmや実装由来の期待値をテストへ写しません。
有効なstatic scalar probe 8件は独立した観測を保持し、最終入力にも新しい記録があります。これは明示したoracle修正であり、有効な既知差分の中立な読み替えや古い指紋の再利用ではありません。

paired復元は両片方向実装を独立に証明せず、互いに補償する欠陥も排除しません。static scalar probeは限定した相互運用の読みを保持します。
空／異なるサイズの宛先、自動割当、signed／XZ値、不正Nの診断、別policy、全error／lifecycle／並行条件、完全なframingは未完です。
普遍的なheaderなしや必須の長さheader表現を要求しません。

以前の4041要求objectと422分類を変更せず、AI義務12件を追記します。現在は4053義務、直接対応2529テスト、control専用54テスト、control linkあり154です。
棚卸しは部分2056／分類422／未評価29です。付録Bは133／7／4、義務255件、主引用221テスト（simulation 217／elaboration 4）で、新しく部分分解した12条項も完了ではありません。
主引用のある番号は1300件、引用がある番号は2088件です。以前の通常2551記録と索引、compiler 99記録、HDL 38記録、command-line 18記録、guest 1082記録を保持します。
guestの未測定は1501入力で、追加1498件と改訂済みの元3件（simulation 1402／elaboration 99）です。
人の照合、範囲／分母承認、元のM1〜M4目標は未完です。

## 薄い領域の96回目の拡充：TLM宣言scopeとnominal型

M2のruntime 4入力で、別々の字句packageにあるTLM実装の生成classを検査し、blocking putにはint、nonblocking getには独自class handleを使います。
各packageで同じ_shared96とplain96のsuffixを使い、入力間でowner componentの生成順と選択した呼出し順を反転します。接続した通常portから既定／index指定のinterface viewを使い、選択impとparentを保持します。
class名、観測、残る解釈事項は[宣言scopeのFAQ](faq.ja.md#tlm宣言scopeとcallback概要)で説明しています。

4入力すべてがbuildしseed 1でexit 0ですが、同名のparameterized生成class間のpackageを越えるcastが予期せず成功します。
suffix間のcastは期待どおり拒否され、選択した配送、引数／履歴、readiness、成功handle／data、後の呼出し、peerの観測は一致します。
一致する行で差分入力全体や子の宣言義務を別途passにはしません。seed 73記録と固定版oracle tagはなく、nominal型の期待値を保持します。

元の期待3行は保持し、package／suffixのcast結果を別々に観測して両方をshort-circuitせず検査する行を追加し、現在の指紋で新しくbuild／実行しました。
UVMなしの独立した独自言語probeでは、package=0を期待したのにsame=1、package=1、name=0、plain_package=0、plain_name=0を観測します。
選択した差分は別packageの同名parameterized classであり、異なる名前や通常classの対照例は一致します。
正規テスト、guest測定、元入力のseed 73結果を追加せず、libraryだけへの原因帰属は行いません。

B.5のnamespace義務1件を追記し、既存の子の宣言義務2件にはそれぞれ照合したlink 2件を追加しますが、本文、条件、期待、制限、AI照合は変更しません。
B.2は個別に読んだfamily見出しとして構造分類、B.2.1はfactory基盤と使用推奨の文脈として分類し、同等の手書き基盤を禁止する規則にはしません。
B.4はregistry基底という記述と明示したcallback object／CBの基底規則が食い違うため、黙って分類せず未評価を保持します。
B.5の総称interface-imp macro名はfamilyのplaceholderであり、具体的な子の生成名だけを使って追加の区切り文字を作りません。

現在はAI義務4054件、直接対応2533テスト、control専用54テスト、control linkあり154です。棚卸しは部分2057／分類424／未評価26です。
付録Bは134／9／1、義務256件、主引用225テスト（simulation 221／elaboration 4）です。主引用のある番号は1301件、引用がある番号は2089件です。
以前の4053要求の本文と照合を保持し、4051 object全体は未変更で既存2件のlink一覧だけを拡張します。以前の422分類、通常2583記録と索引、compiler 99記録、HDL 38記録、command-line 18記録、guest 1082記録を保持します。
以前の既知418件は未変更で、新しい実行時差分4件により全体は422件です。guestの未測定は1505入力で、追加1502件と改訂済みの元3件（simulation 1406／elaboration 99）です。
全ての部分契約、元のM1〜M4目標、人の照合、範囲／分母承認は未完です。

## 薄い領域の97回目の拡充：APIの乱数状態の安定性

M1の新しいruntime 6入力は、user codeを実行しない選択呼出しについて1.4.6の乱数状態の安定性を検査します。
文字列分割、独自enumへの変換、user overrideなしの継承object名照会を扱います。
独自helperは、同じ保存状態からのUVM呼出しなしの対照とcallerの将来24drawを比較し、object照会では制約なしfield 2つのreceiver randomizeの成功と24個の結果も比較します。
user生成と任意の事前呼出しはsnapshotより前に行い、未呼出しからの24回と事前呼出し後の48回で呼出し順を変えます。
実API値と呼出し件数も検査し、enum変換失敗時の未規定ref出力は制約しません。
適用条件と相対的な期待値は[乱数状態のFAQ](faq.ja.md#乱数状態とapiの適用条件)で説明しています。

元のproof入力6件と最終tag付き入力6件はいずれもbuildに成功し、seed 1／73でexit 0の一致を得ました。
最終記録はbuild log 6個とruntime log 12個です。特定の数値乱数列、opaque状態文字列の書式、シミュレータ間のRNG同一性は要求しません。
有限の一致履歴では全状態、全API、user codeを実行する呼出しの動作を認定しません。

識別子を分類で除外せず、1.4.6にAI部分義務3件を追加します。新しいu01 directoryは主引用に従い、機能対象からM1へ数え、各APIの条項は補助引用に保ちます。
root 1は部分2番号、義務4件、主引用6テスト、未評価9番号です。文脈のscopeを保持しても、これらの操作上の要求を除外しません。
主引用のあるroot／directoryは22個です。

台帳はAI義務4057件、直接対応2539テスト、control専用54テスト、control linkあり154テストです。
catalogは部分2058／分類424／未評価25で、主引用のある番号は1302、何らかの引用がある番号は2090です。
以前の要求4054 object、分類424件、索引／通常2587記録は未変更です。compiler 99、HDL 38、command-line 18、guest 1082記録はbyte単位で同一で、入力の互換性も保持します。
以前の既知差分422件を保持し、guestは未測定1511入力で、追加1508件と修正した元3件（simulation 1412／elaboration 99）です。
シミュレータ実装sourceと商用結果は使っていません。全ての部分的な適用条件、元の段階目標、人の照合、範囲／分母承認は未完です。

## 薄い領域の98回目の拡充：返却値規則とmodelの文脈

M3の新しいruntime 8入力は、真となる条件を記載したmodel述語に1.4.2の真偽返却規則を適用します。
blockのlock状態、register／memory／実装済みvirtual-registerのmap所属について、生の数値返却が記載条件でliteral 1、妥当な反対条件で0になることを観測します。
lockの2履歴は実map／registerを持つ独立peer階層で再帰lock、unlock、再lockを扱います。
所属は初期不在、選択／peer対応の追加、選択対象の第2map追加、lock後の反復を扱い、生成／選択を反転します。
virtual arrayは別々のmemoryで静的／動的実装を使い、nullや未実装handleは照会しません。
暗黙の反対分岐とmodel内だけの観測範囲は[返却値のFAQ](faq.ja.md#真偽返却規則とmodelの文脈)で説明しています。

最終tag付き8入力はseed 1／73でexit 0の一致を得て、現在のbuild log 8個とruntime log 16個を保持します。
初期のfield configure補助引用4件は18.5.3.2へ修正し、本体と期待値を変えずに、この最終入力を新たに測定しました。
初期の実行記録と元の入力ファイル18個は暫定metadataとして保存し、妥当な現行入力の識別情報へ黙って付け替えません。
ヘッダーの変更も入力の指紋を変えるため、新しい互換な記録が必要な理由は[記録の合算](results.ja.md#記録の合算)で確認できます。

1.4.2の部分義務4件を追加します。主引用から入力をu01へ置きますが、機能対象がregister modelなのでM3へ数え、以前のu01の乱数状態入力はM1のままです。
root 1は部分3番号、義務8件、主引用14テスト、未評価8番号で、文脈のscopeを変えずに操作上の義務を保持します。

個別に読んだ第18章の親は典型的なmodel構成を説明するため、既存の包含／階層義務へ関連付けた文脈分類を記録し、新しい独立algorithmや固定model形状にはしません。
第18章は部分393／分類63／未評価0ですが、部分義務とregister層全体の目標は未完で、その理由は[Q377](faq.ja.md#q377-第18章の概要を分類するとregister層は完了ですか)で説明しています。
子のcoverageを親へ自動集約しません。

台帳はAI義務4061件、直接対応2547テスト、control専用54テスト、control linkあり154です。
catalogは部分2059／分類425／未評価23で、主引用のある番号は1303、何らかの引用がある番号は2091です。
以前の要求4057 object、分類424件、索引／通常2593記録を保持し、compiler 99、HDL 38、command-line 18、guest 1082記録はbyte単位で同一かつ入力と互換です。
以前の既知422件は未変更で、guestの未測定は1519入力、追加1516件と修正した元3件（simulation 1420／elaboration 99）です。
シミュレータ実装sourceと商用結果は使っていません。残る全適用条件、元のM1〜M4目標、人の照合、範囲／分母承認は未完です。

## 薄い領域の99回目の拡充：継承APIと明記されたoverride

新しいruntime profile 12入力は1.4.3を継承APIへ適用し、M1／M2／M3がそれぞれ4件です。
transaction、callback、sequence item、component、register、memoryの上に独自bridge／leaf classを置き、constructor以外はoverrideしません。
object／bridge／leaf viewから、渡した名、寿命内で安定し異なるID、明示transaction ID、callback有効状態、model形状を観測します。
生成／選択を変えた2履歴で異なるstatic viewから選択／peerの名を変更し、直接の親class配置、instance IDの数値や順序、具体的な型名文字列は要求しません。
祖先viewと明記されたcomponent full-name overrideは[継承のFAQ](faq.ja.md#継承apiと明記されたoverride)で説明しています。

最終tag付き10入力はbuildし、seed 1／73でexit 0の一致を得ました。
未変更の限定component profile 2入力はbuildしてseed 1でexit 0ですが、変更後の名とfull-name観測が異なり、初期観測とID／parent検査は一致します。
その2入力にseed 73結果はありません。期待する継承setterの意味は保持し、1.4.3を通じて5.3.4.1を適用します。
13.1には別のfull-name overrideが明記されますが、別のset_name契約は記載されていません。
このprofileでlibraryだけの原因、child辞書の再索引、暗黙rootの固定綴りは推測せず、ID／parent行の一致で全入力をpassにはしません。
現在の選択はbuild log 12個とruntime log 22個で、既知2記録は元の正確な入力識別情報を保ち、tag付きheader 10件は[再利用規則](results.ja.md#記録の合算)に従って新たに測定しました。

1.4.3に部分義務6件を追加し、以前の要求4061 object全体、分類425件、索引／通常2601記録を保持します。
root 1は部分4番号、義務14件、主引用26テスト、未評価7番号で、文脈のscopeは未変更です。
catalogは部分2060／分類425／未評価22で、主引用のある番号は1304、何らかの引用がある番号は2092です。
AI義務4067件すべてが2559テストへ直接対応し、control専用54テスト、control linkあり154です。
人の照合と範囲／分母承認は記録していません。

1.4.3は中間の祖先を許すため、印字されたcallback／registry基底だけで論理的な矛盾とは断定できません。
B.4は未評価を保持し、通常のcallback objectのprofileで、概要の字面のregistry記述を解消したり分類で除去したりしません。
未解決の関係は[Q380](faq.ja.md#q380-callbackとregistryの基底の記述で矛盾が証明されますか)に記録しています。

以前の既知422記録は未変更で、新しいcomponent profile 2件により現在の合計は424です。
compiler 99、HDL 38、command-line 18、guest 1082記録はbyte単位で同一かつ入力と互換です。
guestの未測定は1531入力、追加1528件と修正した元3件（simulation 1432／elaboration 99）です。
シミュレータ実装sourceと商用結果は使っていません。残る全ての部分的な適用条件と元のM1〜M4目標は完了監査に残します。

## 薄い領域の100回目の拡充：非推奨の文脈と現行API

100回目はM1 runtime 14入力を追加します。現行transaction-parent profile 8件、byte区切りsplit profile 4件、通常条件のcommand-line singleton状態profile 2件です。
live親記録2つ、子2つと子の反復で、省略／zeroと選択したnonzero親handleを扱います。
独自database／stream／recorder hookで型付き関係、begin hookと名前付きeventより前の記録を観測し、endpoint組は順不同で、lhs／rhsの役割、数値handle、link名、正確なlink件数を固定しません。
観測と残る条件は[親profileのFAQ](faq.ja.md#q383-transactionの親linkをどう観測しますか)で説明しています。

splitはcolon、space、0x80、0xffを使い、caller queueを再利用して混合、区切りのみ、不一致、空入力を扱います。
singletonのcallerは同一性と明示変更したreport verbosityを共有し、独立peerは未変更です。通常のDPIなしの一致で引数解析を認定せず、別command-line backendの証拠を置換しません。

最終tag付き14入力はseed 1／73でexit0の一致を得て、現在のbuild log 14個とruntime log 28個を保持します。
初期のinclude pathとhelperの予約語名は検査系の準備の誤りで、期待値を変えずに修正しました。元入力とlogを保存し、製品の既知差分や現行入力の成功にはしません。

部分義務7件を追加し、以前の要求4067 object全体、分類425件、索引／通常2613記録を保持します。
個別に読んだ規範的付録Hの9識別子へ構造2件・文脈7件の分類を追加します。
各根拠は規格から除かれたconstructと実装拡張の禁止を区別し、該当する現行の操作義務へ関連付け、旧APIの不在テストや範囲承認にしない理由は[非推奨のFAQ](faq.ja.md#q382-規範的な付録hは非推奨apiの拒否を要求しますか)で説明しています。
Hは保留のまま部分0／分類9／未評価0で、主引用テストはありません。現行API profileは5.4.2.4／F.3.3.2／G.1.2に置き、非推奨API macroや旧aliasは追加しません。

台帳はAI義務4074件、直接対応2573テスト、control専用54件、control linkあり154です。
catalogは部分2060／分類434／未評価13で、主引用のある番号1306、何らかの引用2093です。候補の主引用棚卸しは0件1179／目標未満771／目標以上532です。
以前の既知424件は未変更です。compiler 99／HDL 38／command-line 18／guest 1082記録はbyte単位で同一かつ入力と互換で、guest未測定1545入力は追加1542件と修正した元3件（simulation 1446／elaboration 99）です。
シミュレータ実装sourceと商用結果は使っていません。全ての部分的な適用条件、元のM1〜M4目標、人の照合、範囲／分母承認は未完です。

## 薄い領域の101回目の拡充：名前のcaseと総則の解釈

101回目は主引用1.4のruntime profile 12入力をu01へ追加し、M1 4件・M2 2件・M3 6件に数えます。
ASCIIのcaseだけが異なる名で、componentの照会／列挙、型付きpoolのkey変更、非active sequenceのpath、blockのregister／memory照会、registerのfield lookupを検査します。
componentの所属／走査では未規定の順序を固定せず、field列挙では明示されたLSBからMSBへの順序を保ち、その違いは[順序のFAQ](faq.ja.md#q387-同等dataの順序は常に自由ですか)で説明しています。

最終tag付きcomponent／pool／memory 6入力はseed 1／73でexit 0の一致を得ます。
register／field 4入力はseed 1でlock前の名前の不一致を保持し、lock後の行の一致で全検査系をpassにはしません。
改訂sequence 2入力は分離後のrootを限定解釈し、pathとparent-null flagは一致しますがroot-selfとroot-name flagが異なります。
以前の段階と同一性flagは一致します。既知6入力は全てbuild・seed 1でexit 0ですがseed 73結果はなく、[rootの解釈](faq.ja.md#q389-分離したsequenceのroot期待をどう限定していますか)をcase-foldingやlibraryだけの不具合の帰属にはしません。

sequenceの元の観測4行は保持し、root定義の補助引用と独立に決めた診断1行を加えてから改訂2入力を測定しました。
元の29入力fileと初期logは保存し、改訂の証拠へ付け替えません。現在の選択は、測り直したtag付き6入力、未変更の初期model 4入力、改訂sequence 2入力から、build log 12個とruntime log 18個を保持します。

部分義務8件を追加し、以前の要求4074 object全体、分類434件、索引／通常2627記録を保持します。
個別に読んだ総則11識別子へ構造1件・文脈10件の分類を追加し、各根拠は範囲、目的、語の用法、meta-syntax、順序の許可、言語参照、定義、classの役割という自身の文脈を特定します。
見出し名による規則や意味の一括除外は使わず、API契約の完了ではない理由は[総則のFAQ](faq.ja.md#q386-総則を評価すると何が残りますか)で説明しています。

台帳はAI義務4082件、直接対応2585テスト、control専用54件、control linkあり154です。
catalogは部分2061／分類445／未評価1で、主引用のある番号1307、何らかの引用2095です。候補の主引用棚卸しは0件1179／目標未満771／目標以上532のままです。
root 1は部分5／分類6／未評価0、義務20件、主引用38テストで、root 1〜4の文脈scopeとHの保留区分は保持します。B.4は未評価のままです。
以前の既知424入力は未変更で、現在の既知は430件です。compiler 99／HDL 38／command-line 18／guest 1082記録はbyte単位で同一かつ入力と互換です。
guest未測定1557入力は追加1554件と修正した元3件（simulation 1458／elaboration 99）です。
シミュレータ実装sourceと商用結果は使っていません。全ての部分的な適用条件、元のM1〜M4目標、人の照合、範囲／分母承認は未完です。

## 薄い領域の102回目の拡充：名前指定callbackと未評価0の区切り

102回目の拡充は主引用B.4のM2 profileを10件追加します。動作8入力は名前指定のcallback追加、明示disable／enable、
無効中の削除、implicit／external-object macroでの再追加を組み合わせます。exact／glob名、枝2選択、逆の生成順で、
対象ごとの所属、配置、参照値、caller引数を保持する条件は[callbackのFAQ](faq.ja.md#q391-名前指定callbackのlifecycle-profileは何を検査しますか)で説明しています。
最終tag付き8入力は全てseed 1／73でexit 0となり一致します。

constructorを呼ばない補助control 2件は、registryがcallbackの派生になるという選択した型解釈だけを検査します。
simulation buildの型変換の代入で失敗し、runtime結果はありません。当初のコメントはこの関係を必須と過大に記していましたが、
1.4.3は逆向きの中間継承も許します。コメントを明確にして両方を再buildし、logicと期待行は保持します。
限定したcontrolであり、必須継承、誤記、矛盾、libraryだけの不具合の証明にはせず、その境界は[型関係のFAQ](faq.ja.md#q392-型関係のcontrolでb4の基底の記述は解決しますか)に記録します。

異なる部分義務3件を追加し、mode、削除、implicit引数の義務を重複させず既存5要求の対応を増やします。
既存要求object 14件をレビューし、limitations内の未解決B.4の説明も明確にします。元の対応、statement、conditions、expected、reviewは保持します。
個別分類445件と以前のindex／通常記録2639件は保持します。AI義務4085件、直接対応テスト2593件、controlのみ56件、control対応156件になります。
人の照合と範囲／分母承認は記録していません。

catalogは部分2062／分類445／未評価0です。B.4は動作の分解によって部分となり、継承の問題を未解決で保持し、分類で除去しません。
未評価0は1つのqueueの区切りであり、全ての部分義務、適用条件、元のM1〜M4目標を未完に保つ理由は[完了の説明](faq.ja.md#q390-未評価の識別子0件なら残作業も0件ですか)で確認できます。
以前の既知430入力は全て保持し、新10入力はguestで未測定です。scope、catalog、runner、backend、workflowは未変更です。

## 薄い領域の103回目の拡充：static iteratorの境界と終端後の追加

103回目の拡充は既存static callback iteratorの6検査系を監査し、10.7.2.4.1〜.4へM1 core utilityの8profileを追加します。
localとnullのtypewide文脈で、空／全件無効queue、無関係なcallback型群、派生型の有効endpoint、終端からの明示再開を検査し、
選択した観測は[境界のFAQ](faq.ja.md#q394-static-callbackのどの境界を検査しますか)で説明しています。
異なる不在／追加後の義務4件と既存4要求の対応を追加し、元の4085要求の全fieldと対応、分類445件、index／通常2649記録は保持します。
scope、catalog、runner、backend、workflowは未変更です。

最終tag付きのendpoint／後方走査6入力はseed 1／73でexit 0となり一致します。
前方2入力はbuildとseed 1をexit 0で終えますが、終端cursorへ登録を追加すると、必要なresetの前にnonnullを返します。
after_empty_addとafter_exhausted_addの両行が異なり、他17行は一致します。元のnull-until-resetの期待を保持し、文書化された契約を
字面どおり適用する理由は[終端のFAQ](faq.ja.md#q395-終端queueへ追加してもnullを期待する理由は)に記録します。
seed 73、予期しないhandleの正体、libraryだけの原因を推測せず、他の行の一致で全入力を成功にはしません。

全体は2657テスト（simulation 2558／elaboration 99）で、M1 1149（1068／81）、M2 606（599／7）、M3 902（891／11）です。
通常evidenceはpass 2223（runtime 2129／compiler拒否94）、known 434（runtime 294／build 135／不正受理5）で、以前の既知432入力は全て保持します。
guestは互換1082入力を保持し、未測定1575入力は追加1572件と修正した元の3件（simulation 1476／elaboration 99）です。
guestの新測定は主張しません。

台帳はAI義務4089件、直接対応テスト2601件、controlのみ56件、control対応156件です。3つのレビューqueueは空のままですが、部分2062識別子と分類445識別子を保持します。
主引用の識別子は1311、引用がある識別子は2096で、candidateの棚卸しは主引用0が1175、目標未満771、目標以上536です。
配置の件数で部分義務、適用条件、元のM1〜M4目標を完了にしない理由は[coverageのFAQ](faq.ja.md#q397-主引用の追加でiterator条項は完了しますか)で説明し、人の照合と範囲／分母承認は記録していません。

## 薄い領域の104回目の拡充：memory access制限とrelocation単位

104回目の拡充はM3 profileを10件追加し、明示memory accessの6caseとflatなbyte／word relocationの4layoutを扱います。
accessは固有RW／RO policyとRO／WO／RW interface制限を分け、単独／共有の所属、親の既定変更、独立したRW peerを観測します。
共有get_accessでは常にmapを指定し、get_rightsが別の契約である理由は[accessのFAQ](faq.ja.md#q398-memoryのrightsと有効accessが異なる理由は)で説明しています。

最終tag付きの共有制限／ROM 4入力はseed 1／73で一致します。単独map 2入力はbuildとseed 1をexit 0で終えますが、
選択accessの3行でRO／WOでなくRWを返し、peerの3行は一致します。relocation 4入力はそれぞれ非ゼロlocationのoff／alt_offが10行で異なり、
address、peer、unitのfieldとlocation 0の5行は一致します。既知6入力にはseed 73結果がなく、一部fieldの一致で全入力を成功にはしません。
既存のaccessとlocation-offsetの期待を保持し、6不具合やlibraryだけの原因を推測しない扱いは[結果のFAQ](faq.ja.md#q401-共有やromのcontrolが一致すれば他の差分は解消しますか)で確認できます。

relocationは非ゼロroot基点、整数の1／2beat location、選択mapの移動、空いた範囲のpeer再利用、再移動、復元を使い、
異なる単位の別interfaceも独立に観測します。DIAG104のlookup座標20行は調査専用で、期待oracleや要求対応を作らず、非ゼロrootのlookup意味は未解決に保ちます。
その境界は[診断のFAQ](faq.ja.md#q400-lookup診断でアドレス検索の適合性を示せますか)で説明します。単位には宣言されたget_addr_unit_bytesを使い、本文の相互参照からget_add_unit_bytesという必須別名は作りません。

map制限／単位／独立性の異なる3義務を追加します。固有ROMの対応へ2linkを増やし、既存location-offset義務の条件／期待／制限を広げ、元の全本文と対応を保持します。
他の元の要求object、分類445件、以前のindex／通常2657記録を全て保持し、以前の既知434入力も保持します。scope、catalog、runner、backend、workflowは未変更です。
台帳はAI義務4092件、直接対応テスト2611件、controlのみ56件、control対応156件です。空の3queueで部分2062識別子、適用条件、元のM1〜M4目標を完了にはせず、人の照合と範囲／分母承認は記録していません。

## 薄い領域の105回目の拡充：入れ子transportのinput handleとlive phase

105回目の拡充はM2 transport profileを6件追加し、blocking、forward、backwardの各経路でtransaction／delay objectを共有する場合と分ける場合を扱います。
通常port、2つのexport、impを通常どおり解決してから、外側の呼出しが実行中に同じportへ再入します。
逐次2roundで元objectへの変更、endpoint localのhandle再束縛、置換objectの変更、非選択peerを分けて観測し、prototypeに基づく解釈は[input handleのFAQ](faq.ja.md#q402-delayのreferenceはendpointがcallerのhandleを置換できる意味ですか)で説明しています。

最終tag付きの6入力は全てseed 1／73で一致します。nonblockingの4profileは呼出しの復帰前に独自phaseのclass propertyを読み、
実転送経路を通るliveなref変更と外側／内側phaseの独立性を観測します。入れ子のUPDATEDと外側のCOMPLETEDは独自endpointで選ぶ結果で、規定protocol algorithmではありません。
blockingでは明示した待機を使い、nonblockingはsimulation時刻を進めず復帰します。最終値だけでlive参照を示せない理由は[phaseのFAQ](faq.ja.md#q403-transport呼出しの復帰前にcallerのphaseを読む理由は)で確認できます。

初回6buildは、新しいヘッダーのfiles指定でhelperへ誤って@を付けたため停止しました。そのprefixを取り除いて検査系の準備を直し、
元の全期待行とhelperを保持します。元の入力とbuild logは別に保存し、修正後の6入力を新しく測定し、再現tagの変更後も全6入力を再測定します。
初回のbuild拒否をシミュレータ／ライブラリの不具合には数えません。

input束縛とlive phaseの異なる2義務を追加し、以前の要求object全4092件、分類445件、元のindex／通常2667記録、既知440入力は全て保持します。
scope、catalog、runner、backend、workflowは未変更です。台帳はAI義務4094件、直接対応テスト2617件、control専用56件、control対応156件です。
guestは互換1082記録を保持し、現在の1591入力は未測定です。同期的な同方向呼出しは同時processの安全性、異方向／socket動作、寿命の所有、base protocol全体のcoverageを立証せず、
その違いは[再入のFAQ](faq.ja.md#q404-一致した6profileでtlm-2の完了や並行安全性も証明できますか)で説明しています。
空の3queueで部分2062識別子、適用条件、元のM1〜M4目標を完了にはせず、人の照合と範囲／分母承認は記録していません。

## 薄い領域の106回目の拡充：保留objectionの取消しと差分件数

106回目の拡充はM1の保留objection profileを12件追加し、元の引用1件を見直します。
新しいcaseはdrain／callback段階、同じobject／子孫からのraise、保留dropと同数／多い／少ない新件数を組み合わせます。
逐次2roundでgate／leaf／祖先の階層、4件を保持する別のpeer分岐、7件を保持する独立objectionを使います。
選択した待機は印刷されたobjectionまたは登録callbackのtaskに置き、all_dropped実行中の取消しが別条件になる理由は[取消しのFAQ](faq.ja.md#q405-drain中の再raiseから何を追加しましたか)で説明しています。

最終tag付きの新規12入力は全てseed 1／73で一致し、改訂した元の入力も本体と期待2行を保って両seedで一致します。
取り消されたgateの解放後も件数を保持し、最後のdropで新しいcycleを完了します。非負の補正では祖先へのraise量はR-Dで、負の補正では公開totalをoracleにし、DIAG106は各seedでhook 8行を調査専用に記録し、oracleや要求対応を持ちません。
状態の義務と未規定の補正hook詳細の違いは[差分件数のFAQ](faq.ja.md#q406-新しい件数が保留dropより少ない場合は何をassertしますか)で確認できます。

待機するtaskはobjectionのall_droppedと登録all_droppedであり、遅延するcomponent taskではありません。
別に保持した13.1.6.3の印刷function入力はbuildの既知差分を保持し、その食違いは[宣言のFAQ](faq.ja.md#q407-taskのgateでcomponentの印刷function宣言も解決しますか)で説明しています。
private process／counter、callback末尾のkill、正確なdelta順序、並行raise、mode zero全体やobjection protocol全体は推定しません。

net伝播の1義務を追加し、安定した取消し義務の元の全本文と対応を保持して適用範囲を広げます。他の元の要求object 4093件と分類445件は未変更です。
元のreraise検査系のdescription／主引用は、呼び出さないget_drain_timeからdrop_objectionへ修正します。元入力を保管し、他の通常／index 2672記録を保持して改訂入力を新たに測定します。
以前の既知440入力は全て保持し、scope、catalog、runner、backend、workflowは未変更です。

台帳はAI義務4095件、直接対応テスト2629件、control専用56件、control対応156件です。
guestは改訂した元入力を除いて互換1081記録を保持し、現在の1604入力は未測定です。Ghostは各seedでpass 206／fail 875、kirimasimはunsupported 1072／fail 9を保持します。
guestの件数減少は互換性のfilterで新測定や改善ではなく、入力同一性の変更は[引用のFAQ](faq.ja.md#q408-引用の修正でguestの結果が改善したり条項coverageを証明したりしますか)で説明しています。
主引用の棚卸しは0件1173番号、1件771番号、2件以上538番号であり、主引用で独立した検査や義務全体のcoverageを証明しません。
空の3queueで部分2062識別子、適用条件、元のM1〜M4目標を完了にはせず、人の照合と範囲／分母承認は記録していません。

## 薄い領域の107回目の拡充：物理addressの直接変換

107回目はM3の物理address直接変換profileを16件追加します。
空／独立register登録済みのmapに対し、平坦な通常mapのbyte／word単位と両endian、byte単位little-endianのchild4／root2とchild2／root4の階層、平坦なlittle／big FIFO mapを組み合わせます。
値を入れた結果配列を長さの異なる照会へ再利用し、元の照会も繰り返します。非FIFOでは非0のmemory entry indexも照会し、registerやmemoryのwrapper APIとの違いは[直接照会のFAQ](faq.ja.md#q409-mapの直接照会はregisterのaddress照会に何を追加しますか)で説明しています。

16件は全てbuildと実行に到達しますがseed1で不一致となり、seed73の結果も新しい固定版tagもありません。
観測できた完全beatの戻り幅は要求する2または4でなく0です。非0 entryの先頭と一部の階層幅／列の観測も異なります。
空と登録済みの期待は同じで、登録を新しい前提や解決策にしない理由は[準備条件のFAQ](faq.ja.md#q410-登録済みの比較で変換前のregister登録を必須にしますか)で説明しています。
階層4入力は最初の非0 entry照会でnull参照の診断とともに停止し、後続の期待行は未観測です。平坦な12入力は正常終了します。この観測でsimulatorとlibraryのどちらが原因かは推定しません。

entry0の6-byte probe 2件はaddress 2個の列をassertし、単一の部分転送の戻り値は調査専用にします。
DIAG107はそのseed1のlogに各1行あり、oracleも要求linkも持ちません。未解決の読み方は[部分幅のFAQ](faq.ja.md#q411-部分転送の戻り値を調査専用にする理由は)に残します。
bus転送、packing、RTL timing、非0 FIFO entryのstride、混在endian階層、階層word単位の解決、任意のsub-bus entryの丸めは認定しません。

memory entry indexの義務を1件追加し、安定したdata順／幅と最小幅の義務は元の文章とlinkを保持しながら適用条件を広げます。
他の旧要求4093件、分類445件、元の通常／index 2685記録、以前のknown 440入力は全て維持します。
初回buildはobserver内のnull条件式で止まり、型付きの期待parent変数へ直しますが期待値は変えません。初回入力／logは保存して除外します。
修正後16入力は、そのlogを流用せず新しく測定します。

全2701テスト、AI義務案4096件、直接対応2645テストとなり、control専用56件とcontrol link付き156件を保持します。
通常条件はpass 2245件（両seedのruntime 2151件・compile拒否94件）、known 456件（seed1のruntime 316件・simulation build失敗135件・不正設計の受理5件）です。
guestは互換1081入力の記録をbyte単位で保持し、未測定1620入力（追加1616件・修正した元入力4件）になります。guest再実行や新しいfilterはありません。
範囲、catalog、runner、backend、CIの選択は変更しません。3つのqueueは0でも、部分2062番号、適用条件、元のM1〜M4目標は未完で、人の照合と範囲／分母の承認は未記録です。

## 薄い領域の108回目の拡充：baseの記録抑制とdriver mark

108回目はM2のrecording無効化profileを4件追加し、実際のsequencer base APIでpull／push転送とdriver transaction markの省略／明示を組み合わせます。
各caseは独立した選択対象とpeerのsequencerを接続し、それぞれ実際の要求を1件使います。workerの開始前とgate付きpull driverの最初の要求前にdisableを2回呼び、状態のqueryを超えて転送とmarkの効果を観測する理由は[効果のFAQ](faq.ja.md#q413-recording無効化profileはflag-queryに何を追加しますか)で説明しています。

最終tag付き4入力は全てseed1／73で一致します。driverのmarkがない場合、選択対象のbegin／end時刻は取得済みの値を保持し、名前付きeventのcallbackも呼ばれません。
明示したcomponent begin／end呼び出しがある場合、各event callbackを取得したdriver markの時刻で1回呼び、transaction時刻も一致します。
元の要求handleが届き、driverの戻りをgateで保留する間は両producerが待ち、解放後に両方が完了します。driverごとのgateで、相対的な配送時刻やsibling callback順を仮定しません。

peerのbegin／end件数は各seedでDIAG108を4行、現在の合計8行に記録し、oracleや要求linkはありません。peerの転送は検査しますが、その診断でpush既定時のrecording動作は認定しません。[peerのFAQ](faq.ja.md#q414-peerのevent件数を調査専用にする理由は)で違いを残します。
別に既知差分がある印刷15.3.2.23のquery入力は変更せず、別のquery名に置き換えません。

安定した5義務、sequencer baseのdisable、transactionの時刻0／既定begin／end、名前付きevent通知の適用条件を広げます。元の文章とlinkを保持し、他の旧要求4091件と分類445件は同一です。
profileごとに重複する義務は追加せず、要求案4096件を変えない理由は[対応付けのFAQ](faq.ja.md#q415-4要求を追加せず既存5義務を拡張する理由は)で説明しています。
元の通常／index 2701記録と既知456入力は全て保持します。初期のgateなし入力は両seedで一致しましたが、observerを強化した後は保存して除外し、gate付き4入力をtag前に全て再測定します。
pullヘッダー2件の引用はnative実行前に直し、期待値は全段階で保持します。

全2705テスト、直接対応2649件、control専用56件、control link付き156件です。通常条件はpass 2249件（両seedのruntime 2155件・compile拒否94件）とknown 456件（seed1 runtime 316件・build 135件・不正受理5件）です。
guestは互換1081記録をbyte単位で保持し、未測定1624入力（追加1620件・修正した元入力4件）で、再実行や新しいfilterはありません。
主引用censusは0件1172番号・目標未満771番号・2件以上539番号ですが、新しい主引用で独立coverageは認定しません。
全2062部分番号、適用条件、元の段階目標は未完で、人の照合と範囲／分母承認は未記録です。

## 薄い領域の109回目の拡充：自動記録された要求property

109回目はM2の自動記録property profileを4件追加します。pull／push転送で選択sequencerの既定／無効modeを使い、独立peerは既定modeに保ちます。
最初の要求前にcomponentの記録、明示transaction stream、独自global／component backendを有効にします。
選択対象／peerの固定property 41／97を、実際の要求の独自record hookとrecorderの整数field hookへ渡し、観測する経路は[propertyのFAQ](faq.ja.md#q416-property-profileはtransaction-markに何を追加しますか)で説明しています。

最終tag付き4入力は全てseed1／73で一致します。無効にしていない各要求で独自hookとproperty fieldの証拠を得て、選択対象を無効にすると両方を抑制しつつpeerのdataは記録します。
driver gateで元の要求の同一性と完了の意味を保持します。driverもcoordinatorもitemのrecordやtransactionの明示begin／endを呼ばず、実際のlibraryの記録がdata観測を供給します。
存在と宣言した値、有効bit、size 32、UVM_DECだけを検査し、既定のobject記録の再帰とuser hook動作はrecorderの継承実装に残します。

正確なhook／stream／open／close／free件数は各seedでDIAG109を4行、現在の合計8行に記録し、oracleや要求linkを持ちません。その境界は[件数のFAQ](faq.ja.md#q417-正確な件数や時刻でなく記録の存在を検査する理由は)で説明しています。
固定dataにより、変更中のsnapshotを仮定しません。stream名、database形式、handle符号化、event件数／時刻、item処理中の切替、任意のpipelineや複数要求pushは認定しません。
記録先を明示的に有効にした条件であり、全ての既定条件を解決するものではありません。

自動propertyの義務1件を追加し、安定したbase disable義務へbackend有効の2profileを加え、元の文章とlinkを保持します。
他の旧要求4095件、分類445件、元の通常／index 2705記録、既知456入力は同一です。
metadataのcomment幅と、実際のrecord object／既定policyの補助引用はnative実行前に整えます。初期の一致したpretag／tag batchは、準備状態の観測をdisable前へ移してgetter状態の保持を余分な事後条件にしないようにした後、保存して除外します。現在の入力は新しく測定し、期待fileは全段階で保持します。
実装sourceや商用結果を期待値の根拠にしません。

全2709テスト、AI義務4097件は全て2653テストへ直接対応し、control専用56件とcontrol link付き156件を保持します。
通常条件はpass 2253件（両seedのruntime 2159件・compile拒否94件）、known 456件（seed1 runtime 316件・build 135件・不正受理5件）です。
guestは互換1081記録をbyte単位で保持し、未測定1628入力（追加1624件・修正した元入力4件）で、再実行や新しいfilterはありません。
主引用censusは0件1172番号・目標未満771番号・2件以上539番号のままです。全2062部分番号、適用条件、元の段階目標は未完で、人の照合と範囲／分母承認は未記録です。

## 薄い領域の110回目の拡充：event待機のdeltaと領域の観測

日英11組のガイドにも、迷いやすい件数やコマンドのそばの一文説明、コード表記の用語へのリンク、過去の時点を区別する案内を追加し、入口は[読み方ガイド](reading-guide.ja.md)で確認できます。

110回目はM1のevent待機profileを6件追加し、wait_on／wait_offでdelta引数の省略・明示0・明示1を使います。
既にblockした既定waiter、未成立の待機を後で解放する制御、独立peer eventを伴い、実際のevent methodを2 round再利用します。
3つの引数形式は[deltaのFAQ](faq.ja.md#q419-eventのdelta-profileは何を追加しますか)で説明しています。

独自の待機しないtaskで、SystemVerilogの子process開始条件を確認します。
新しいfork/join_noneの子は親がblockまたは終了するまで開始せず、既に条件が成立した省略／0の呼出しでは保留、明示1では実行済みとなる必要があります。
timeとrealtimeの両方が同じ値を保つことも確認します。
別のmodule processが対象呼出し前のActiveで実NBA更新を予約し、復帰時には未反映、正時間のdrain後には反映済みである必要があります。
これはyieldとNBA前の復帰の観測であり、連続する全#0制御の回数を数えるものではなく、限界は[scheduler観測のFAQ](faq.ja.md#q420-新しい子と予約したnbaを両方使う理由は)で説明しています。
検査系が#0の回避処理を挿入することはありません。

最終tag付き6入力は全てseed 1／73で一致します。最初は条件が未成立の各待機は、制御したtrigger／resetまでblockし、その遷移時刻で復帰します。
peerは自身をresetするまで待機を保ちます。既存のready waiterが完了する順序は全引数で調査用とし、各ケース・各seedでDIAG110を4行、現在の合計48行に記録しますが、oracleや要求linkにはしません。
最初は条件が未成立だった待機にdelta文が適用される範囲は照合が必要で、再開の機会という記述からwaiter全体の完了順序を追加では要求しません。

以前のpretag 6入力とtag付き6入力も一致しましたが、NBA領域の観測を持ちませんでした。
`out/thin-one-hundred-tenth-before-region-witness/`へ保存し、現在の証拠には数えません。
領域のレビューで独立に導いた期待を補強し、以前のready waiter完了assertionを外してから新しく測定しました。
現在のpretagとfinalの各batchは全6件が両seedで一致し、この2batch間の変更はoracle tagだけです。

既に成立した条件でのdelta-yield義務2件と、元の記述を保持した持続／reset義務2件の拡張により、AI義務は4099件です。
他の旧要求4095件と分類445件は同一です。元の通常／index 2709記録、既知456入力、2種類のbackend部分集合を維持します。
通常の一致は2259件で、runtimeの両seed一致2165入力と期待compiler拒否94件です。
guestの再実行やfilterは追加せず、互換1081記録をbyte単位で維持し、未測定は1634入力です。
内訳は追加1630件と修正した元入力4件で、simulation 1535・elaboration 99です。

第10章は部分87／分類29／未評価0番号のままで、義務169件・主引用テスト140件です。
catalog全体の主引用がある番号は1315で、candidateは0件1171／目標未満770／2件以上541です。
全体は部分2062／分類445／未評価0番号、直接対応2659テストとcontrolのみ56テストです。
範囲・分母は未承認、人の照合は未記録です。連続deltaの正確な回数、block後のdelta適用、event callback、waiter件数／reset、kill／cancelの組合せ、event契約全体と元の段階目標は残り、[完了のFAQ](faq.ja.md#q421-6件のevent-profileの一致で条項は完了しますか)で今回の進捗と区別しています。

## 薄い領域の111回目の拡充：待機方法を跨ぐ取消しと再利用

111回目はM1の取消し／件数profileを4件追加し、wait_trigger、wait_ptrigger、wait_on、wait_offを1件ずつ使います。
1 eventで3 callerを待機させ、選択した2つのprocess handleを順にkillしてcancelし、実際の生存waiterを1人残します。
準備と件数oracleの関係は[取消しのFAQ](faq.ja.md#q422-4件の取消しprofileは何を追加しますか)で説明しています。

明示kill／cancelの組ごとに件数は3から2、1へ進み、生存者を制御したtrigger／resetで解放した後は0である必要があります。
killとcancelの間の件数は採りません。終了させたcallerは復帰せず、peer eventは自身を解放するまで1 waiterを保ちます。
同じ対象を2 round再利用します。正時間のbarrierでblockを成立させ、以前のtriggerと同じsliceのpersistent-trigger動作に依存することを避け、前提は[再利用のFAQ](faq.ja.md#q423-onoff待機と同じeventの再利用を確認する理由は)で説明しています。

最終tag付き4入力は全てseed 1／73で一致します。既存の取消し義務と実waiter件数義務の2件へdirect linkと、元の記述を保った条件／限界を追加し、profileごとに新しい義務を作りません。
他の旧要求4097件、分類445件、元の通常／index 2715記録は同一です。
既存の混在resetとwakeup resetは各条件で既知差分に保持します。今回のprofileは、off waiterを意図的に解放するresetを除き、残るcallerがblock中に選択eventをresetしません。

全体は2719テスト（simulation 2620／elaboration 99）、AI義務4099件、直接対応2663テストとcontrolのみ56テストです。
通常の一致は2263件で、runtime両seed一致2169入力とcompiler拒否94件です。既知456入力と2種類のbackend部分集合を保持します。
guestの再実行／filterは追加せず、互換1081記録をbyte単位で維持し、未測定は1638入力です。
内訳は追加1634件と修正した元入力4件で、simulation 1539／elaboration 99です。

第10章は部分87／分類29／未評価0番号と義務169件を保持し、主引用は144テストになります。
candidateの件数は0件1171／目標未満768／2件以上543で、全体の主引用がある番号は1315です。
部分2062番号、残る実際の適用条件、元の段階目標、人の照合、範囲／分母承認は未完です。
0件／重複／生存processのcancel、suspend／resume、別手段で起動したcaller、callback取消や並行resetは認定せず、3つのqueueが空でもgoal完了にならない理由は[完了のFAQ](faq.ja.md#q424-取消しの一致でevent契約は完了しますか)で説明しています。

## 薄い領域の112回目の拡充：独立unpackと限定したsetter観測

112回目はM2のpayload unpack profileを4件追加し、通常／観測targetとdataの空／非空を組み合わせます。
独自の公開packer writerで、payloadのdo_pack結果やendianの生表現を使わず、宣言された幅に従って列挙fieldを入力します。
異なる入力address／byteと保持するextensionでtargetを2 round再利用し、入力とactive prefixの境界は[unpackのFAQ](faq.ja.md#q425-独立したunpack-streamは何を検査しますか)で説明しています。

通常targetの最終tag付き2入力はseed 1／73で一致します。観測targetの2入力はseed 1の既知差分で、正常終了0、seed 73の結果はありません。
他の検査行10行は全て一致し、sentinel準備、直接呼出しの逆順setter確認、復元したscalar／active byte、extensionの同一性／値／hook保持を含みます。
実際に継承したdo_unpack中の初回setter訪問は両roundとも観測されず、要求するtrace 2行が異なります。
値の行が一致しても観測ケース全体はpassにせず、simulator／libraryの原因を帰属しない解釈は[限定した読み方のFAQ](faq.ja.md#q426-field値が一致してもsetter順序を限定した解釈とする理由は)で説明しています。

順序oracleは12.3.4.2.5のsetter列挙と12.3.4.2.15のvirtual accessor宣言、SystemVerilog 8.20から、空配列setterを含む実際の列挙順訪問と読むものです。
その読み方は照合が必要です。各setterの初回訪問と存在だけを検査し、現在のDIAG112 4行の正確な呼出し回数はoracleや要求linkにしません。
観測側は各公開setterをsuperへ渡し、do_unpackはoverrideしません。直接呼出しの確認後に観測をclearします。

入力field値と限定した初回setter順序の2義務を分解し、既存のextension保持義務1件を拡張します。
AI義務は4101件で、他の旧要求4098件と分類445件は同一です。
通常profileはfield値にdirect、setter順序にはcontrolなので役割が重なり、直接対応は2667テスト、control対応は158テスト、controlのみは56テストです。
元の通常／index 2719記録と旧既知456入力は全て維持します。

全体は2723テスト（simulation 2624／elaboration 99）です。通常一致は2265件で、runtime両seed 2171入力とcompiler拒否94件です。
既知は458入力で、runtime seed 1差分318件、simulation build 135件、runtimeのない不正design受理5件です。
2種類のbackend部分集合は同一です。guestの再実行／filterは追加せず、互換1081記録をbyte単位で保持し、未測定は1642入力です。
追加1638件と修正した元入力4件で、simulation 1543／elaboration 99です。

第12章は部分169／分類45／未評価0番号、義務328件、主引用204テストです。
主引用がある番号は1316へ増え、candidateは0件1170／目標未満768／2件以上544です。
部分2062番号、実際に残る条件、元の段階目標、人の照合、範囲／分母承認は未完で、対応付けやcontrolの一致でgoalが完了しない理由は[完了のFAQ](faq.ja.md#q427-unpack-profileでpayload条項は完了しますか)で説明しています。
