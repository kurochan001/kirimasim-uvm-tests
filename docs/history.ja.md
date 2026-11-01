# 開発履歴

[English](history.md) · [README](../README.ja.md)

M1・M2の15回目と、M3の9回目（805件）までの追加作業を記録しています。以前の349件の時点は
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
