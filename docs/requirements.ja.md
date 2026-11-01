# 要求台帳の案とカバレッジの棚卸し

[English](requirements.md) · [README](../README.ja.md) · [テストと開発のガイド](testing.ja.md)

## 現在の状態

M4を進めています。[対象範囲の案](../coverage/scope.json)、[要求台帳](../coverage/requirements.json)、
[テスト索引](../coverage/test_index.json)を版管理します。台帳の要求案は915件で、911要求を876テストへ直接対応付け、
4要求には直接対応するテストがありません。追加の1テストをcontrolとして対応付けています。
1045テストのうち残る168件は要求単位でまだ整理していませんが、規範的な動作を検査していないという意味ではありません。
人による要求の照合記録はありません。

条項catalogの番号は2,504件です。645件は要求を一部分解し、残る1,859件は未評価です。
どちらも完了を示しません。M4の開始は、範囲や分母の承認、M1〜M3の完了を意味しません。
`approved_denominator`と`coverage_percentage`は`null`のままです。

## 計数単位と対象範囲の案

適用条件を伴う、観測可能な規範的義務を1要求とする案です。methodの1条項にも、成功、失敗、default引数、
順序、副作用など、複数の要求が必要な場合があります。見出し自体は義務ではありません。
915件の要求案は複数領域にわたりますが、その条項内の全義務を列挙したものではありません。

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
catalogのうち主引用がある番号は482件、どちらかの引用がある番号は1,084件です。
補助引用は準備に使うAPIの場合もあります。引用から要求の対応付けを自動生成せず、子条項の参照を親条項へ自動集約もしません。

対象候補2,479件について、従来の「各条項2テスト」の主引用の棚卸しは、0件が1,997、1件が251、2件以上が231です。
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
現在の1045件には新たに測定した検査系を含みます。変更していない既存テストの対応付け自体は、追加の実行結果ではありません。

## 版管理するデータと生成する棚卸し

JSONはUTF-8、schema versionは1です。未知のfield、重複key、重複する要求ID、未知の条項／テストを拒否します。

- `coverage/scope.json`は、日英の計数単位、rootの区分、従来の主引用の目標を記録します。
  schema 1で表せるのは、承認済み分母のない未完の範囲案だけです。
- `coverage/requirements.json`は、安定したID、条項、日英の`statement`、`conditions`、`expected`、`limitations`、
  `review`、`test_links`を記録します。対応にはtest ID、`direct`／`control`の役割、空でない`expected_observations`を持たせます。
  直接の対応先は要求の条項を引用する必要があり、レビューで対応を確認すれば補助引用でも構いません。
- `coverage/test_index.json`は、全テストの`primary_clause`と`inputs_sha256`を記録します。
  指紋は既存runnerの収集処理を使い、source、宣言したhelper／include／data、期待値file、UVM lockを含めます。
  索引は棚卸しであり、1045件のレビュー済み要求対応ではありません。

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

次の17個のrootの既存主引用テストをすべて対応付けましたが、規範的義務の分解は部分的なままです。

| Root | 要求案 | 主引用テスト | 対応のないテスト | 未評価の番号 |
| --- | --- | --- | --- | --- |
| 5 | 47 | 42 | 0 | 79 |
| 6 | 34 | 32 | 0 | 87 |
| 7 | 30 | 13 | 0 | 45 |
| 8 | 23 | 34 | 0 | 52 |
| 9 | 37 | 27 | 0 | 89 |
| 10 | 50 | 54 | 0 | 80 |
| 11 | 17 | 12 | 0 | 17 |
| 13 | 36 | 20 | 0 | 87 |
| 16 | 92 | 97 | 0 | 129 |
| 17 | 7 | 2 | 0 | 26 |
| 19 | 29 | 37 | 0 | 97 |
| B | 36 | 54 | 0 | 110 |
| C | 9 | 16 | 0 | 80 |
| D | 6 | 6 | 0 | 40 |
| E | 48 | 54 | 0 | 79 |
| F | 22 | 10 | 0 | 119 |
| G | 1 | 2 | 0 | 21 |

未対応テスト0件でも、網羅の完了ではありません。付録Eには、HDL-pathの利用可否とwalking-ones algorithm自体の2要求が直接未対応です。
location maskは、必要なlocationアクセスの特性だけに対応付け、walking algorithm全体には対応付けません。
B.5.11の矛盾する印刷上の呼出しは、レビューが必要な解釈として記録します。既知差分の期待値も規格に従って保持し、
915件の要求の照合状態はすべて`ai`です。

選択したFIFOの対応は、blocking／nonblockingの動作、容量、flush、到着順、analysis通知を実際の期待観測へ結び付けます。
失敗get／peekの出力の事後条件にはsentinel検査を追加し、規格の`output` signatureと本文の食い違いを要レビューとして残します。
追加の並行性と要求ごとの2検査は未評価です。基本APIの対応はlocal database hook、
pool、agentの状態、文字列field、literalな引数suffixの照会を扱い、外部database、agentの全転送、動作するDPI backendは主張しません。

選択したregister／memory、virtual register、custom frontdoorの検査系を、転送、status、prediction、slice、descriptorの観測へ対応付けます。
RTLの動作、全map／endianの組合せ、一般のburst配列packingを示すものではありません。read 3検査系は主引用をwriteからreadへ直し、
索引を再照合して実行記録も更新します。テストの動作と期待出力は変えません。

基本APIの出力、上限、overrideなしの照会には直接の検査系があります。printerの出力はfield／値の所属とfield-macro配列で検査し、
comparerの上限は比較hook内の個別reportを数えて、後の集約報告を区間外にします。quit上限は実pre-abortの走査と後の時刻へ
継続しないことを観測し、ready上限は繰り返すraise／遅延dropを正しく対応させます。選択した条件であり、全出力形式、
report／phaseの全context、兄弟phaseの全組合せは示しません。

直接未対応の要求案は、object側のactive-policy同期、HDL deposit、HDL-pathの利用可否、memory-walk algorithm全体の4件です。
第19章の既存主引用テストは未対応0件ですが、HDL／backend候補と他の未評価の義務も範囲に残します。
6.5.1.2.3のquit actionは、F.2.2.2で宣言する`UVM_COUNT`とF.7.3.2のroot終了を照合して解釈します。
印刷上の`UVM_QUIT`は、宣言されたaction値ではありません。

コンテナのlinkは、first／lastの端点、next／prevのcursor、global singletonの同一性、index／keyの取得、
挿入境界、空popのwarning、空／非空の待機を分けます。選択した複数reader、複数peeker、flushでの容量解放の検査系を、
既存のFIFO義務へ追加します。analysisのwrite／再開の新linkでも、schedule上の勝者は指定しません。

memory hookは、pre-writeの値／offsetの合成、pre-readのmap／offset変更、アクセス前の中止、post-readの戻り値変更、
post-writeの順序／最後のstatus／再転送なしを分けて対応付けます。既存のmemory／register-map照会21検査系を、
観測する親、size、幅、所属、権限、address、移動、reset、階層の性質へ対応付けます。
共通の出力行を使っても、すべてのanchorが独立した要求の検査になるわけではありません。
第18章には、主引用テストで未対応62件と、未評価の番号339件が残ります。
map変更とpost-write順序の既知差分でも必要な期待を保ち、新たな測定の合格には数えません。

event／barrierの要求案を、持続するon状態、reset／offの待機、新しい／同sliceのtrigger data、既定trigger data、
thresholdでの解除、auto-reset、開いたgateの再利用、resetでの再開／再待機へ対応付けます。
時刻を隔てたTLM 2の履歴は、呼出しの経路、返すphase／status、handleの同一性、独立した時間注釈へ対応付け、
transactionのscheduleはテストベンチの動作として扱います。

追加の9 field policyを繰り返すWRITE観測へ対応付け、該当するREADの副作用は別の要求案に分けます。
明示予測であり、物理read／write trafficではありません。選択した既存の第14章の検査系を、context、depth／root／path、
local制御、任意hookの順序、完了／state待機、priority選択、親hook、automatic objectionの期間、responseのclearへ対応付けます。
getterのlinkでは、自動randomize、print／copy／recordの副作用、lockした制御の更新、arbitrationを示しません。
既に一致するstate maskの検査系は、戻りmarkerへ到達しますが、経過時刻0は断定しません。
第14章には、主引用テストで未対応24件、未評価の番号60件が残り、要求分解はすべて部分的です。

階層の要求案は、componentの親／full name／depth、子listの追加、直接の子の所属、cursor境界、
相対／絶対／失敗のlookupを区別します。index付きTLM 1の検査系は、解決済みendpointの数／handle、
選択したblocking／nonblockingの転送、親fanoutへ対応付け、trafficでprovider順を仮定したり、既定indexのsetterを検査したりはしません。

symbolicなHDL記述を、concat API、kind選択／消去、祖先の既定、block全pathの組合せ／区切り、絶対rootへ対応付けます。
必須concatのset／get APIはビルド時の差分、既定abstractionの継承は実行時の差分を保ちます。
HDLの利用可否やdepositを示すlinkはありません。新しい第17章の主引用テスト2件は直接対応しますが、
規範的な分解は部分的で、実行時の合格は主張しません。

既存のpayload／extensionの21検査系を、address／data／maskの状態、述語、型keyの同一性、消去、alias、
既定packでのextension境界へ対応付けます。これらのlinkは配列とlengthが一致する設定を保ち、
別のlength不一致の意味は別途扱います。第12章には、主引用テストの未対応46件、未評価の番号145件が残ります。
新しいlinkだけで、測定の合格、人による照合、承認済み分母は作りません。

型付きevent callbackの要求案は、拒否、post-triggerの状態、callbackなしのreset wakeup、無効hookのdispatchを区別します。
killしたwaiterの明示的な取消と、専用poolのkey／singletonの同一性は、別々に対応付けます。
blocking TLM 2の要求案は、重なる呼出しの戻り境界、接続したsocket channel、error／再利用、独自transaction型、
入れ子のexportを観測し、endpointのtimingと応答生成は検査系の動作とします。

register modelの照会は、block／regfile／registerの親handle、local／再帰的な所属、単純名の検索へ対応付けます。
転送動作は示さず、lock前と入れ子のregfileのlookup差分は規範的な期待を保持します。
第18章には、未対応の主引用テスト62件、未評価の番号339件が残ります。

既存sequencerの20検査系を、mode／容量の制御、counter、要求／応答履歴、current-itemの寿命、peek／getの完了、
execute-itemのacknowledge、型付きpush traffic／response handlerへ対応付けます。
制御getterではarbitrationを成立させず、応答履歴のlinkを応答配送の代わりにしません。
第15章には、未対応の主引用検査系36件、未評価の番号53件が残り、要求案36件は一部分解のままです。

記録系の要求案は、database-open guard、stream metadata、open／close／freeのhookと状態、
handleの同一性／lookup、初期化前のwarning、link endpointのdispatch／prefillを区別します。
local hookがstreamを用意し、streamだけのlinkではrecorderの動作を後述の別要求へ委ねます。
外部databaseの内容は検査系の範囲外です。第7章は主引用検査系13件、要求案30件、未評価の番号45件です。stream列挙の件数は、signature／本文の解釈を要レビューとして保持します。

新しいrequest／response channelの検査系は、方向別routing、満杯queueでのblocking put、応答getの待機、
要求peekの保持へ対応付けます。既存TLM 1の20検査系は、analysis broadcast、subscriberなし、export転送、
接続port、分離implementationの委譲、型付きFIFOの方向／順序、通知、逐次transportへ対応付けます。
第12章には、未対応の主引用検査系46件、未評価の番号145件が残ります。

field metadataの要求案は、以前のaccess、custom登録と組み込み分類、volatility／compare設定、reset値の照会、
reset metadata／削除、定義済み／未知resetの状態、staticな最大幅を区別し、modelだけを観測します。
第18章には、未対応の主引用検査系62件、未評価の番号339件が残ります。新しいlinkでは、
人による照合、物理reset、外部記録backend、承認済み分母は作りません。

recorderの要求案は、open streamでの受理、streamの同一性、明示timestamp、lifecycle flag、
free時の自動close、handle lookup、recorder queueの所属、streamの連鎖cleanup、6つのscalar記録hookへ対応付けます。
local implementationを使い、file形式、vendorのattribute macro、object再帰、既定時刻の置換は扱いません。
recorder列挙はqueue所属だけに対応し、記載された戻り件数の問題は別に残します。

TLM 2 socketの全8 constructorを、役割／接続数／親の観測へ対応付けます。
blockingとnonblockingのtarget terminatorは、繰り返すconnectのERRORへそれぞれ対応します。
照会はbinding解決前であり、transportの配送は成立しません。間接registerは、明示indexの選択、選択したread／write、
再選択、独立pair、任意のregfile配置、auto-prediction、driverのerror／再試行の観測へ対応付けます。
array要素は等幅、有効indexを使い、RTLやarray frontdoorの自動生成は主張しません。

既存sequencerの20検査系を、FIFO／strict／random／USER動作、候補handle、lockの除外とFIFO配置、
grant前の完了、grabの優先、親子の適格性、入れ子所有権の照会、相互に使える解放、lock／relevanceの利用可否へ対応付けます。
randomの所属は、公平性や統計的なcoverageとは区別します。第15章には、未対応の主引用検査系36件、
未評価の番号53件が残り、要求案36件は一部分解のままです。既存lockのtiming／順序の差分は規範的な期待を保持します。

phase graphのlinkは、constructorの種類、直近parent、囲むdomain／名前、full path、
node／implementationの同一性、scope内lookup、推移順序、並列joinを扱います。
実行しないlocal graphを照会し、get_schedule／get_impの記載の矛盾は今回の範囲外です。
現在nodeのlookupは、要求するnodeの戻り値をspec-onlyとして保持します。

custom transactionのsocket linkは、既定parentと明示blocking implementationへの実配送、
単一nonblocking initiator／target pass-through nodeを通る両方向を検査します。
transactionはgeneric payloadから独立し、phase引数は標準enumを使います。
annotationの検査は、simulation時間が経過したことを示しません。

coverageのlinkは、modelの搭載状況、有効mask、要求される直前maskの戻り値を区別します。
また、blockの入れ子制御、bus完了後かつ予測前のregister hook、memory hookの方向／map、
block相対offset、成功accessのsampling、再帰sample_valuesを扱います。
hook counterはcovergroup、bin、測定したcoverage比率ではありません。
直前maskと余分なmemory sampleの差分はspec-onlyを保持します。既存register／field検査系20件は、desired／mirror状態、
reset kind、選択した予測policy、clean／dirtyのupdate、物理W1C／W1S write maskへ別途対応します。
modelだけの操作とbus maskの観測は、policyに忠実なDUTを示しません。
第18章は要求案182件、未対応の主引用検査系62件、未評価の番号339件、
第12章は要求案91件、未対応検査系46件、未評価の番号145件です。どの分解も部分的です。

component記録のlinkは、既定の有効状態、instanceごとの制御、明示／既定database、
stream pairのcacheと参照解放、null guard、transaction時刻の転送、post hook、
属性記録の遅延、closeとfreeの区別を扱います。local hookは、外部形式、component eventの起動、
transaction linkの意味を示しません。stream参照の解放は、規範的な新規streamの差分を保持します。
begin_tr内部のstream型を検査系から指定せず、begin hookのrecorder handleで実際のstreamを識別します。

sequenceのreport linkは、reporter選択、verbosity照会の委譲、virtualなmessage生成／抑止、
事前生成messageの実handlerへのroutingを区別します。明示contextは保持し、空contextはsequence pathを使います。
virtual処理のprobeはreport actionを実行しません。既存sequence 20検査系は、start itemの優先順位、
優先度、guard、context、finishのvirtual dispatch、ID転送、hook順序、低levelのgrant／送信へ別途対応します。
既知のERROR severity、virtual dispatch、完了IDの差分は保持します。
第14章は要求案82件、未対応の主引用検査系24件、未評価の番号60件で、
新しいreport linkも既存の送信linkも部分的です。

map readのlinkは、比較の既定off、既定引数での有効化、一致／不一致read、予測を止めない無効化、
既存submap 1つ、独立interface、fieldの比較mask、RCの予測前の比較を扱います。
全root interfaceで自動予測を明示的に有効化します。ERRORの観測はmirrorの不一致を表し、bus要求の拒否ではありません。
受動predictor統合、実DUTの副作用、DPIは示しません。第18章は要求案182件、
未対応の主引用検査系62件、未評価の番号339件です。これらのlinkは、人による照合や承認済み分母を追加しません。

core-serviceの要求案は、既定printer／packer／comparer／copierの選択とnull fallback、
factory／report-server／databaseの置換と復元、共有serviceの同一性、process内のglobal seed不変性へ対応します。
handleを直接照会し、具体的な既定型、元の既定値の再利用、RNGの値、独自coreの初期化、serviceの動作は推測しません。
付録Fは要求案22件、主引用検査系10件、未評価の番号119件です。

新しいlibrary indexのlinkは、有効wrapperの同一性、個数を明確に超えるERROR／nullの結果、
instance所属、削除を扱います。既存library 20検査系は、instance／typewideの登録と重複排除、
queueへの追加、削除／warning、直接呼ぶ既定selector、標準mode／count API、counter、
選択した／既定のRAND実行へ対応します。列挙順や非強制の勝者は要求しません。
記載された、個数と同じindexの境界は未解決です。標準APIの綴りの欠落、static削除、warning欠落は、
元のspec-only期待値を保持します。第14章は要求案82件、未対応の主引用検査系24件、未評価の番号60件です。

transaction-orderのlinkは、mapのgetter／選択状態と、実際のpolicy dispatch／物理転送順を区別します。
8 bit bus上の32 bit registerで、完全な操作structをaddressで並べます。write／readは、両endianについて
byte／address対応と論理的な再合成を保持し、interfaceの独立性、置換、解除は別の比較対象を持ちます。
little-endian readの再合成とbig-endianのbyte反転は、規範的な既知差分を保持します。
sortは検査系のcodeであり、それ自体を適合の主張とはしません。memory burst、端数word、任意の同時実行、
子mapへの継承は扱いません。第18章は要求案182件、未対応の主引用検査系62件、未評価の番号339件です。
新しい照合はすべてAIであり、分母や完全な分解は承認していません。

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
現在のAIによる915要求案と直接の対応は、その条件を満たしていません。
