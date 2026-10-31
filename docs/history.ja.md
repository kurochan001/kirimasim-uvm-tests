# 開発履歴

[English](history.md) · [README](../README.ja.md)

M1と、M2の9回目（445件）までの追加作業を記録しています。以前の349件の時点は
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
