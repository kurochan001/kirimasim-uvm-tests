# 開発履歴

[English](history.md) · [README](../README.ja.md)

M1・M2の15回目、M3の9回目、M4の3回目と既存テストの要求への未対応付け解消の時点を含む、段階をまたぐ薄い領域の40回目の拡充（全1433件：simulation 1411・elaboration 22）までを記録しています。以前の349件の時点は
[500f22e](https://github.com/kurochan001/kirimasim-uvm-tests/commit/500f22e10c3ce62a497df929232a562b78952fc5)
です。件数・測定・未検証項目の説明は、それぞれの追加時点のものです。
現状と実行方法はREADME、現在のライブラリの制約は[既知差分](known-differences.ja.md)を参照してください。

## Ghostの同梱UVMによる測定

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
