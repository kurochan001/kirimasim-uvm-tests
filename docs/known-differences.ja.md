# 既知差分

[English](known-differences.md) · [README](../README.ja.md) · [FAQ](faq.ja.md)

現在の1518件と、固定したAccellera UVM 2020.3.1についての記録です。
不一致はテストの結果であり、それだけではシミュレータ・ライブラリ・期待値のどれが原因かは決まりません。

elaboration 32件は抽象class直接生成12件とpure interface／const参照違反20件で、拒否を期待します。
30件は一致し、subscriber／visitor未実装の受理2件はruntimeを実行せずspecのみを保持します。
compiler受理2件は既知simulation差分187件と別です。新しいrecorder直接生成とpure-hook欠落6件は正しく拒否されます。

## 固定版ライブラリの制約

ライブラリ自身の`DEVIATIONS.md`には18.2.3.4・18.4.3.6・13.1.5.1の3件が載っています。
現在のregister検索ではmap引数を明示します。memoryを2つの兄弟interfaceのmapに登録する単純なケースは、
固定版でも18.2.3.4の期待値に一致しました。配布物の複数mapの注記と、より広い階層の意味は別途照合が必要です。
付録Eでは選んだ2／3 mapのshared accessと1つの子blockの形も確認します。
[memoryの範囲](faq.ja.md#memorypredictionmapの制御)と
[shared accessの範囲](faq.ja.md#memory-accessshared-mapテストの選択)を参照してください。
M1・M2・M3で、追加の制約と観測を確認しました。
不足する必須動作を直接検査する場合は、規格の期待値を変えずに`:oracle: spec`で保持します。

- 新しいprinter 8検査系はseed 1の差分を保持し、seed 73は実行しません。SHALLOWでも子孫を訪問し、無効radix prefixが残り、root controlは既定1に対して0を返します。
  table／tree indentとtree／line separatorは、flush後の種類別既定値に対して変更値が残ります。
  entry-depth等号matrixは限定解釈です。一方、別のcaller scopeは測定した両上限を既に超えても再帰し、その境界問題を避けます。
  途中の正しい観測でfixture全体をpassにはしません。
  - [SHALLOW再帰](../tests/u16/test_printer_recursion_modes_distinguish_deep_shallow_reference_and_default.sv)
  - [限定entry-depth境界](../tests/u16/test_printer_max_depth_uses_reference_behavior_beyond_each_selected_boundary.sv)
  - [超過済みdepth](../tests/u16/test_printer_depth_already_above_limit_uses_reference_without_touching_caller_stack.sv)
  - [無効radix prefix](../tests/u16/test_printer_integral_values_use_selected_radix_prefix_and_honor_prefix_disabling.sv)
  - [root名既定値](../tests/u16/test_printer_root_enabled_selects_full_name_or_leaf_before_policy_dispatch.sv)
  - [flush後のtable indent](../tests/u16/test_printer_table_specific_controls_return_to_declared_defaults_after_flush.sv)
  - [flush後のtree control](../tests/u16/test_printer_tree_specific_controls_return_to_declared_defaults_after_flush.sv)
  - [flush後のline separator](../tests/u16/test_printer_line_specific_controls_return_to_declared_defaults_after_flush.sv)

- 共有handlerのresetはgeneral／ID verbosity、action、fileを復帰させてもseverity／ID verbosity閾値を保持します。
  6.3.8.3は既定設定への復帰を要求します。pairのresetと後続境界配送の期待を保持し、seed 1で停止してseed 73は実行しません。
  設定prefixの一致はfixture全体のpassではありません。[共有閾値のreset](../tests/u06/test_reporting_shared_reset_restores_all_threshold_keys_before_live_filtering.sv)を参照してください。
  以前のseverity-override reset差分は別入力として保持します。

- pureなsubscriberのwriteまたはvisitorのvisitを欠く具象subtypeがcompileに成功します。
  13.9.3.2／F.5.1.2.3の宣言とSystemVerilog 8.21は具象生成に実装を要求します。
  両拒否oracleを保持しruntimeは実行しません。独立した合法な継承subscriber controlは両seedで一致しますが、実装欠落を許す根拠にはしません。
  [subscriber欠落](../tests/u13/test_subscriber_concrete_subclass_must_implement_write.sv)と
  [visitor欠落](../tests/uF/test_visitor_concrete_subclass_must_implement_visit.sv)を参照してください。

- 新しい実行時差分3件は限定した規格解釈を保持します。12.3.5.7.4／12.3.5.8.4はblocking relay見出しでnonblocking providerを列挙します。
  逐語的な受理probeは列挙3／2 familyを全て拒否し、ERROR 6／4件を報告します。別のblocking relay転送／再利用の比較対象は一致します。
  印刷名を暗黙にblocking名へ置換せず、比較対象の一致で一覧が解決したとも扱いません。
- 同種terminatorの一般制約を「不正connect後に直接provider entryを残さない」と読む限定解釈では、両initiator種はERRORを報告してもentryを残し、target種はERRORを報告して残しません。
  rawな直接entryと解決済み実行bindingは異なります。規格は不正呼出し後の状態を明記しないため、不具合の証明ではなく照合可能な解釈差分として保持します。
  全3件はseed 1の最初の差分で停止し、seed 73結果はありません。
- forward portをbackward経路とする本文と、P／parameter構文を省略したnonblocking connect signatureも部分対応の文言として残ります。
  正確なclass既定値と独自phase転送probeは印刷signatureの逐語的正しさを認定しません。
  他の抽象／不正派生条件、不正user extension、全socket member所有関係も別作業です。

- 12.2.3.3のbidirectional port概要は、REQと独立にRSP=intを宣言します。選択した9 familyの検査系はREQだけstringへoverrideし、正確なstring／int interface基底を要求します。
  固定宣言はRSP=REQを使うため、最初の型付き引数でcompileに失敗します。全int既定と、異なるpacked型を明示したtransportの比較対象は一致します。
  これはAPI欠落や実行時失敗ではなく、宣言既定値build差分1件で、この入力は両seedとも未実行です。REQだけ指定する検査でRSPを明示する置換は行いません。

- propagation mode 0では、objection callbackは中間componentを正しく省略しますが、子が2、次に1 objectionを保持していても、その祖先のtotal照会は0を返します。
  10.5.1.3.2が指定するのはcallback省略であり、10.5.1.5.4のtotalは自身とdescendantのobjectionを含みます。source／root totalとcallback経路は一致します。
  既定modeの比較対象は中間total、hook metadata、drain／callback伝播の検査で一致します。省略modeの規範的total期待を保持し、seed 1で最初に異なりseed 73の結果はありません。
  経路の正しさを検査系全体のpassには数えません。

- raw eventの早い／遅い待機検査では、trigger前に公開count 1で早い呼出しを確立します。
  10.1.1.2.4はそのtriggerでの戻りを要求しますが、次のtime sliceでも早いcallerは戻らず、2回目のtriggerで両callerが戻ります。
  同じsliceで遅く呼ぶcallerの新trigger待ちは、一致する比較対象です。simulator／libraryを組み合わせた原因は未確定で、simulator実装sourceは調べません。
- 既定event resetはraw／persistent／on-stateの3 callerを待機させたまま、waiter 0を報告し、10.1.1.2.10の実process照会と異なります。
  後の新triggerでは3つとも期待dataで解放します。これは件数の差分で、取り残しの観測ではありません。
  barrierのsilent-reset比較対象は、規定の0 count／再待機で別に一致します。
- 新しいevent poolには、10.4.1が要求するbegin／accept／endの名前がありません。
  検査はgetのlazy生成より前に所属を調べ、正確なpool sizeは要求しません。既存の新key増分テストは初期所属と独立で、未変更です。

- user-backdoorのencode／decode callbackは必要な順序で呼ばれますが、配列変換が次のcallbackや最終の値経路へ届きません。
  18.11.2.7／.8は順次伝播、decoderの逆順、post-read methodでのclear dataを要求します。
  単一encoderは記憶値を期待0x0c／0x3aではなく0x13／0x25のままにし、単一decoderはclear値0x13／0x25ではなくencoded値0x0c／0x3aを返します。
  2 callbackの検査は中間値の喪失も示します。4件ともseed 1で最初に異なり、seed 73の結果はありません。
  [既定callbackの比較対象](../tests/u18/test_register_callback_default_encode_and_decode_leave_arrays_unchanged.sv)は両seedで一致し、既定の無変更動作だけを示します。
  物理HDLや検査側の配列修復を使わず、独自記憶域と2つの配列要素を使います。固定Apache helperの確認で観測した書戻し欠落を説明しますが、oracleには使いません。

- 固定catcherは、標準のget_report_message API（6.6.3.10）を持ちません。
  事前構成messageの同一性／live alias／再利用の3検査系はbuildできず、実行時の期待は未測定です。privateな実装fieldで代用しません。
- 1-byteのbig-endian busで個別fieldはアクセス可能を返しますが、実測high writeは0x20でなく0x21、low readは0x21でなく0x20へ向かい、
  格納／戻りdataも異なります。別のlittle-endian対照は両seedで一致します。設定したbyte順の期待を保持し、simulator実装の原因とは断定しません。

- adapterでbyte enable対応を示し、16-bitの物理word内で2 fieldが別々のbyteを占める条件です。
  18.5.5.9／.10は、この条件で個別アクセスを要求します。固定libraryの可否判定はbus幅全体でfieldをまとめ、両fieldを拒否して全wordのmaskへfallbackします。
  low writeは実際のhigh byte 0xabをmirrorの0x12へ置換し、high readはlow mirrorを0x34に保持せず0xcdへ更新します。
  選択した戻り値や後のwrite値の一致だけでは、独立したアクセスを示しません。byte-enable非対応の別fallback対照は両seedで一致します。
  個別アクセスの期待をspec-onlyで保持し、HDL DUT storageは使いません。

- heartbeatの動作中にeventを省略してstartすると、固定実装は置換eventのerrorを組み立てる際にnull引数を参照します。
  10.6.2.6は以前に設定したeventの選択を要求します。stop後の既定event再利用と明示same-eventのstartは、動作中の既定呼出しが失敗する前に一致します。
- Verilator／固定UVM条件のFIFO inline randomizeは、容量ちょうどの要求に成功を返しますが、queueが空のままです。
  別の過大inline要求は、期待どおり拒否します。
- 別のFIFO subtype制約の検査では、容量ちょうどのsubtypeは一致しますが、容量3に対して4 entryを要求するsubtypeも、拒否せずrandomize成功を返します。
  2つのFIFO観測は18.8.2の期待を保持し、simulator／libraryのどちらが原因かは決めません。abstract queueはDUT FIFOの転送を示しません。

- register fileのget_default_hdl_pathは、fileで明示的な既定を設定していなくても、包含blockをGATE、後でCPUにした後も初期値RTLを保持します。
  18.3.4.6は、この条件で最も近い祖先の既定値を要求します。同じ検査系の明示file override TLM／RTLは一致します。
- 入れ子fileのkind省略get_full_hdl_path照会は、flattenされた親のGATE既定を継承せずRTLを保持します。
  18.3.4.5／18.3.4.6に基づく期待はnet.cellで、固定版の結果はdut.leafに従います。明示RTL／GATEのflattenは一致します。
  symbolicなpathだけを扱い、HDL accessを示すものではありません。

- block get_map_by_nameは、local mapのsubmapにしていないchild blockのmapを、今回の検査で見つけません。
  18.1.3.13はchild blockの検索を要求します。同じlock済み検査系のlocal優先とscope外の結果は一致します。
- block get_block_by_nameは、直接childと、childから照会するgrandchildを見つけますが、rootから同じsimple grandchild名を見つけません。
  18.1.3.12は子孫検索を要求します。oracleはsimple name入力だけを使い、不在／ancestor／peerの対照を含めます。

- overrideのないabstract componentをparent nullで生成すると、必要なerrorの整形中にparentを参照して停止します。
  8.2.5.1.2はerrorとnull返却を要求するため、その期待をspec-onlyで保持します。
  具象parentを指定した同callbackとabstract objectの別条件は、ERRORとnullを返す対照検査として一致します。
- sequence get_depthは、parentの置換／解除後も以前に計算した値を保持します。明示set_depthがなければ、
  14.1.2.9は現在parent chainのdepthを要求します。検査系は3／2／1を保持し、parent handle、root照会、pathは別に更新します。

- componentの自動configurationは、固定libraryの既定name-filter modeでは独自resourceをskipします。
  明示strict buildではresourceを見つけますが、13.1.5.1のUVM_SET field operationなしにset_localを直接呼びます。
  そのためstrictでもhook順序と抑制が異なります。期待値は正確なrhs dispatchと抑制を保ち、strict buildを別条件とします。
- portのrelationship設定は、存在する値0のresourceを有効として扱います。5.5.2.14は0による無効化を要求します。
  設定なしの既定と非0による有効化は別の観測で一致します。actionのあるreportだけを数え、UVM_NO_ACTIONはwarning発行から除きます。

- overrideしないsubtypeの`uvm_port_base::get_type_name`は、5.5.2.5で規定する`uvm_`接頭辞を省きます。
- `set_default_index`はindexを記録しますが、5.5.2.13に反し、実測したblocking export呼出しをelaboration後に切り替えません。
- 独自VPI backendでのE.7 sequenceは、利用不能pathにERRORを報告し、HDL readを試みます。
  warning／転送なしの解釈を保持します。既定abstractionで利用可能なpathの比較対象は別に一致します。

- register-itemの範囲外value writeは、warningと無視でなくvalue配列を拡張し、
  範囲外readは必要なwarningなしに0を返します。19.1.1.2.4は、両warningとwriteの無視を要求します。
  読取り／書込みの記述子を分け、個数／個数+1のindexで誤った割当てを小さく保ち、
  readのwarning欠落をwriteの拡張から分離します。空配列の観測も同じ規範的規則を保持します。

- no-DPIの照合fallbackは、簡易表記のplusをliteral文字として扱います。
  F.3.3.1／表F.1は1文字以上を要求するため、nodeXtailとnodeXYZtailはnode+tailに一致する必要があります。
  規範的な検査はspec-onlyを保持します。star、question、検査したliteral文字は別に一致します。
  この知見は実測したno-DPI設定に限定し、POSIX式の動作やDPI有効時の結果は示しません。

- registerのorder policyは物理readの順序を変えますが、固定libraryは論理位置でなく実行順にbyteを合成します。
  18.4.2.4はreadの並べ替えを認め、18.4.4.10はregisterの論理値を保持します。
  little-endianの4 byte readは、要求addressとbyteを観測しても、12345678 hexでなく78563412を返し予測します。
  規範的な値はspec-onlyとして保持します。

- componentの`free_tr_stream`は、cacheしたstream型のkeyでなく、stream objectのclass型名でentryを削除します。
  同じ非空の名前／型pairを後で要求すると、元のstreamを返します。13.1.7.10は参照解放後に
  新しく生成したstreamを要求します。検査系は新しい同一性と生成1回を期待し、別のcache pairを保持します。

- Phaseの`find`は、呼出しnodeが指定implementationを参照する場合、渡したimplementation handleを返します。
  9.3.1.4.4はphase-node handleを要求します。検査系は正確なnodeを期待し、
  隣接nodeの成功lookupとschedule内で存在しない結果を比較対象にします。
- Register、memory、blockの`set_coverage`は、新たに有効化したmaskを返します。
  18.4.7.6、18.6.8.5、18.1.4.5は、直前に有効なmaskを要求します。
  2検査系はoffからon、置換、無効化の戻り値を保持します。搭載状況による制限、
  peerの独立性、blockの再帰は別に観測し、固定版実行で一致します。covergroupは測定しません。
- memory samplingは、read／writeのsampling loopが終端境界を含むため、1 locationのaccessごとに
  余分なlocationをsampleします。18.6.8.6は完了accessにsamplingを対応させます。
  検査系は1 locationの転送ごとにsample 1回を保持し、map、方向、data、完了は別に観測します。
  memory offsetのgeometryは規定しません。

- databaseの`open_stream`は`open_db`を呼び、閉じたdatabaseを暗黙に開く場合があります。
  7.1.4.1は、databaseが既に開いていなければ要求を無視してnullを返すことを要求します。
  検査系は、closed、接続失敗、open成功のdatabaseを別々にして独立した対照を保ちます。
- 新しいstreamは、7.2.3.1〜7.2.3.3が要求する未初期化の`get_db`、`get_scope`、
  `get_stream_type_name`でのwarningを抑止します。warning gateの初期値が無効です。
  検査系は、各照会のwarningを1つずつ保持し、初期化済みstreamが静かに有効metadataを返す対照を使います。

- eventのtrigger dispatchは、有効なhookだけでなく無効callbackのhookも呼びます。
  10.7.1.2.2は`callback_mode(0)`でcallbackを無効にします。検査系は、event dataの更新を観測しつつ、
  pre／postの呼出し0回を期待に保ちます。
- blockの`get_reg_by_name`は、model lock時だけに埋めるfull-name registryを使いますが、
  18.1.3.14はlockの前提を指定していません。通常のlocal／deep名はlock後に取得できても、
  regfile内に入れ子のregisterは単純名で取得できません。検査系はlock前後の両要求を保ち、
  通常のlock後の成功するlookupを対照にします。

- 17.2.3.3.2／17.2.3.3.3で要求される`uvm_hdl_path_concat::set_slices`と`get_slices`がありません。
  concatの2検査系は、標準の呼出しと、最上位から最下位へ並ぶ有効なsliceの記述を保ちます。
  両方とも固定ライブラリではビルドできません。
- blockは、最も近い祖先で明示したHDL abstractionを継承せず、localなRTLの既定値を初期化します。
  18.1.6.9の検査系は、継承するGATE、子のlocalなRTL override、rootをSYNへ変更後に別途継承する兄弟を
  期待値に保ちます。metadataの継承であり、HDLアクセスは試みません。

- 空queueの`uvm_queue::pop_front`と`pop_back`はnative queueの操作へ委譲し、
  11.3.2.8／11.3.2.9で要求されるwarningを出しません。両検査系は空の各呼出しでのwarning、
  2値の既定の戻り値、再設定／全取得の成功する比較対象、2回目の空の呼出しを期待値に保ちます。
  シミュレータの診断の文面は指定しません。
- memoryの`pre_read` callbackでdescriptorのmapを変更しても、固定ライブラリはcacheした
  元のlocal map／frontdoorを使います。18.11.2.4の検査系では別mapと変更後のoffsetを期待し、
  両mapで別々のstorageと、callbackを削除した比較対象を用意します。
- memoryの`post_write`は、18.6.9.2／18.11.2.3と逆に、登録callbackより先に継承methodを実行します。
  検査系はcallbackがmethodより先の順序と、methodの最後のstatusを期待値に保ちます。
  完了したstorageとpost-writeでのdescriptor変更を別々に観測し、callbackの削除で比較対象を戻します。

- `find_override_by_name`は、置換がない場合に`null`を返します。元の型を生成できる場合も
  同じです。8.3.1.7.1は生成されるオブジェクトのwrapperを返すAPIとして説明しています。
  overrideなしのobject／component検査では通常生成のwrapperを期待値に保ち、
  override照会とaliasの一致ケースは別の比較対象にします。
- config_dbの既定の実装はフィールド名を文字列の一致で検索するため、設定したフィールド名の
  globがC.4.2.2.1の説明どおりに名前を選択しません。globテストはフィールド名を固定し、
  スコープのパターンを確かめます。
- fieldマクロで入れ子をcopyすると、UVM_SHALLOWでも別のオブジェクトが作られます。
  16.6.3は入れ子を参照として扱う動作を説明しています。一致するテストではdeep copyと、copyフックから
  見えるcopierの設定・処理中のオブジェクトを確かめます。
- 5.3.14.3の`uvm_object::get_active_policy`がありません。以前のフックのテストは16.1.3のAPIで
  copier側の処理中オブジェクトのスタックを観測します。新しい2 policy同期テストは、必要なobject側getterを
  直接呼び、spec-onlyのbuild差分を保持します。policy側stackの観測だけでは、object側の同期は成立しません。
- `uvm_field_op::user_hook_enabled`は`set`前と`flush`直後の呼び出しを拒否します。
  5.7.2.7にはこの制限がありません。field_opの再利用テストは、flush後も含め、
  `set`した後で有効値を確認します。
- `get_objectors`は、件数がゼロになったソースもdrainの後処理まで一覧に残します。
  10.5.1.5.1は現在objectionを保持しているソースの一覧を説明しています。
  drop直後の一覧テストは、規格の期待値を変えずにspecのみのテストとして保持します。
- `uvm_transaction::is_active`は生成直後に1を返しますが、5.4.2.12は最初のbegin前を0と定めています。
  生成直後の非active状態をspecのみのテストとして保持します。一致するライフサイクルのテストは、
  begin・end後のactive状態を検査します。
- レポートhandlerのreset後も重大度・ID別の置換が残ります。6.3.8.3は6.3.7の置換設定を
  消す動作を定めています。件数によるreset検査は、元の重大度に戻る期待値をspecのみで保持します。
- `uvm_field_op::get_op_name`は、`set`前と`flush`後に5.7.2.3の必須エラーを出しません。
  getterの事前条件を検査する2件は、必須エラーの期待値をspecのみで保持します。
  `get_op_type`・`get_policy`・`get_rhs`による必須エラーも同時に検査します。
- `set_response_queue_depth`は、新しい深さがキュー内の応答数より小さい場合にも、
  14.2.7.7の必須エラーを出しません。M2の2件で、応答2件に対する深さ1への変更と、
  応答1件に対する深さ0への変更の必須エラーを保持します。エラー後のキュー内容は検査しません。
- 応答キューのエラー報告フラグの既定値が0ですが、14.2.7.4・14.2.7.5は1と定めています。
  M2の設定テスト2件は規格の既定値を保持します。一致するoverflowテストでは、
  エラー報告の有効・無効を明示的に設定します。
- USER arbitrationでは候補が1件の場合に`user_priority_arbitration`を呼びません。
  15.3.2.3はこの場合もcallbackを必須とします。M2の1件で、呼び出す期待値をspecのみで保持します。
- lockの要求を、先行するFIFO上のitem要求や取得済みitemの完了通知より先に付与します。
  15.3.2.10・14.2.5.5とFIFOのF.2.4.1に従う、2件の順序・待機の期待値をspecのみで保持します。
- `sequence.kill`は、14.2.5.11が要求する`post_body`・`post_start`を呼びません。
  sequencerあり・なしの2件で必須hookを保持します。`do_kill`、停止状態、bodyの中断は別に観測します。
- default sequenceのwrapperから生成したobjectがsequenceへcastできない場合、
  15.3.5の必須エラーではなくwarningだけを出します。通常のobjectとsequence itemを指定する
  2件で、エラーとdefault sequenceを開始しない期待値を保持します。
- `stop_sequences`はroot sequenceの自動starting-phase objectionを解除しません。
  15.3.2.14の停止はkillとして動作し、14.2.4.3のdropも必要です。単独と親子の2件で
  必須の件数0を保持します。親子では子のdropは実行されますが、親の件数が残ります。
- `uvm_tlm_time`がaliasする`uvm_time`の既定名が、5.6.2.1の`uvm_time`ではなく
  `uvm_tlm_time`です。引数なしの生成の名前をspecのみで保持します。
- 5.6.2.2の`uvm_time::set_default_time_resolution`がなく、旧名の`set_time_resolution`だけがあります。
  規格のAPIを呼ぶテストはビルド不可の既知差分です。コンパイルを通すためにAPI名を置き換えません。
- nonblocking pass-through initiatorを二段にするとbackward exportの接続方向が逆になります。
  外側exportが未接続となる差分を、12.3.5.5.4の自動backward接続の期待値として保持します。
- push sequencerは完了した要求を要求FIFOから取り除きません。そのため、次の要求を送ると
  FIFOが満杯のままで拒否され、15.6.3.3の連続転送を満たしません。3件で順序どおりの転送と、
  共通APIの要求・応答履歴を規格の期待値として保持します。
- sequence libraryに`get_selection_mode`・`set_selection_mode`、`get_min_random_count`・
  `set_min_random_count`、`get_max_random_count`・`set_max_random_count`、
  `get_num_sequences_executed`がありません。14.4.4.1〜14.4.4.4の必須APIを使う6件は
  ビルド不可です。旧来のfieldへ置き換えず、規格の呼び出しを保持します。
- `uvm_sequence_library::remove_sequence`は未登録の型を削除しても、14.4.5.5の必須warningを
  出しません。warningと登録済みの型を維持する期待値を保持します。
- static登録された型を削除しても、呼び出したlibrary instanceだけが変更されます。
  14.4.5.5は全instanceの更新を要求するため、別の既存instanceの一覧を公開APIで観測します。
- FIFOの`get_ap`は、12.2.8.1.6が含める`peek`と成功した`try_peek`の通知を省略します。
  2件で、peekがitemを残すことと、それでも毎回通知する規格の件数を別々に観測します。
- `start_item`は`null`のitem、itemではないsequence、sequencer不足をFATALで報告します。
  14.2.6.2はERRORと即時のreturnを要求するため、3件で重大度を変えずにcatcherで数えます。
- libraryのsubtypeの構築時に、sequence libraryマクロで登録した型やbaseの所属を取り込みません。
  4件で14.4.2のconstructorとB.3.2のマクロを使い、実装固有の追加の初期化呼び出しは加えません。
- `finish_item`は14.2.6.3が要求するsequenceのvirtualな`send_request`・`wait_for_item_done`を
  経由しません。2件で通常の実装へ委譲するoverrideを観測します。
- `finish_item`がsequencerの完了待ちへ渡すIDは、14.2.6.3のitemのtransaction IDではなく-1です。
  実際の要求へ通常どおり完了を通知し、1要求・2要求の明示IDを規格の期待値として保持します。
- `finish_item`は`null`・非itemの検査を省略し、sequencer不足でもFATALの後に即時returnしません。
  3件で14.2.6.3のERRORと早期returnを保持します。固定版の不正参照の経路は、期待する観測前に終了します。
- `uvm_reg::get_field_by_name`はlock前の構築済みfieldに`null`を返しますが、18.4.3.12はlockを前提にしていません。
  固定版はlock時に完全名の索引を作ります。1件でlock前の正しいhandleを期待値に保持し、lock後の検索成功も確認します。
- `uvm_reg_map::get_n_bytes(UVM_HIER)`はlock前のroot mapに0を返しますが、18.2.4.5はlockを前提にせずbus幅を返します。
  1件でlock前の幅を期待値に保持し、lock後の正しい幅も確認します。
- `get_physical_addresses`はアドレスを計算しても、18.2.4.16の転送byte数を返さず0になります。
  戻り値の欠落はmap初期化にも影響し、幅の広い子busではlocal幅が残ります。子mapの実効幅と
  18.4.3.15の戻り値が、18.2.4.5の最小幅2 byteに対して4 byteになります。
  word単位と階層mapの2件で、規格の転送幅を期待値に保持します。
- `uvm_mem::get_offset`はlocation引数を使わず、memory先頭のmap offsetだけを返します。
  18.6.4.15は指定locationのoffsetを返すため、location 0・1・3の異なる期待値を1件で保持します。
  同じケースで、外部アドレスが正しく進むことも別に観測します。
- `uvm_mem::get_access`は単一mapのmemoryで、そのmapがROに制限していても固有のRWを返します。
  18.6.4.6の実効accessには制限の反映が必要です。同じケースで、18.6.4.5が非共有memoryへ定める
  RWの権限問い合わせを別の観測として保持します。
- `uvm_reg_predictor::pre_predict`で公開itemの転送先を変更しても、hook前に選んだ元のregisterを更新します。
  19.3.3.2は転送先の変更を認めるため、転送先と値を変更する1件で、元と転送先のmirrorの期待値を保持します。
- big endianのfrontdoor accessは、狭いbusのデータをregister-data型全体の幅でbyte反転し、
  その後のmaskで有効bitを失います。既存の2 word readは、18.4.4.10・19.1.2.3の値の復元を保持し、
  word内のbyte順の曖昧さを避けるため同じbyteを使います。新しい8 bit busのorder-policy検査系は、
  18.4.4.9のwrite byteと18.4.4.10のread値も保持します。readは、このbyte反転制約と
  順序に依存する再合成を組み合わせ、両原因を独立して切り分けるものではありません。
  policyのdispatch、geometry、要求address順は、失敗するdata検査とは別に観測します。

- registerのpre-write／pre-read hookをfieldのhookより後で実行します。
  18.4.8.1／.3と18.5.6.1／.3はregisterを先としているため、2件で期待する`RF`の順序を保持します。
  busアクセス自体は成功しますが、固定版は`FR`になります。登録callback objectを使わない継承methodのhookです。

- memoryのburstを物理bus記述子へ変換するとき、19.1.2.1が定めるREAD／WRITEへ変えず、
  UVM_BURST_READ／UVM_BURST_WRITEを渡します。幅をそろえたburstの2件で各物理beatの種別と、
  18.6.5.3／.4のデータ転送の期待値を保持します。テストベンチdriverは規定の物理READ／WRITEを扱います。

- `uvm_vreg::get_n_bytes`は宣言したbit幅をbyteに切り上げますが、18.9.1.2.9が定める
  実装先memoryのlocation幅には切り上げません。16 bitのvirtual registerを32 bit memoryに置く1件で、
  固定版の2 byteに対し4 byteの期待値を保持します。location数と増分は期待値・観測値とも1です。

- `uvm_vreg::implement`は実装済みの動的配列でもmemoryの`null`引数を拒否します。
  18.9.1.1.3はmemoryを省略したresizeでmemory・offset・増分を保持するため、そのresize結果と配置を期待値にします。
- `uvm_mem_region::get_virtual_registers`は実装したvirtual配列の所有者を記録せず、`null`を返します。
  18.12.7.2.7はvirtual配列のhandleを返すとするため、その期待値を保持し、実装の成功とmemoryのhandleも観測します。

- field単独の`uvm_vreg_field::write`は登録callbackより先に継承`post_write`を呼びます。
  18.10.6.2.2と18.10.5.2はcallbackを先とするため、`cM`を期待し、`Mc`を観測する差分を保持します。
  親のvirtual write経路ではcallbackを先に呼ぶことを比較対象として確認します。

- ユーザー定義backdoorのRC registerのreadはsampleと記憶域のclearには成功しますが、
  自動予測を有効にしても、0の代わりにsampleした値をミラーに記録します。
  read後のミラーの期待値は18.4.4.10・18.5.4.6・18.2.5.2・18.4.4.15・18.5.5.17から導きます。
  返り値とclear後の記憶域は成功する比較対象です。

- blockのmemory-walk wrapperは、E.6.2が定める`NO_MEM_WALK_TEST`の代わりに
  `NO_MEM_ACCESS_TEST`を除外guardで調べます。wrapper経由でアクセスしないという期待値を保持し、
  memoryを直接選んだwalkは成功する比較対象として検査します。

- 個別memoryのaccess sequenceは、E.5.1が指定する`NO_MEM_SHARED_ACCESS_TEST`の代わりに
  `NO_MEM_ACCESS_TEST`を調べます。必要なskipを保持し、別scopeのmemoryへのアクセスを成功する比較対象にします。

- 統合access wrapperは、blockに`NO_REG_ACCESS_TEST`が一致しても、memoryの走査には`NO_MEM_ACCESS_TEST`を調べます。
  E.3.3ではそのblockを統合検査から除外します。wrapperの観測区間はアクセスなしを要求し、
  register／memoryを直接指定した比較対象が動作することも検査します。
- register単独のbit bashは、登録した独自field policyを含むregisterにもアクセスします。
  E.2.1は未知policyのregisterを検査できないとします。アクセスなしの期待値を保ち、
  既知RWの別対象が動作することを比較対象にします。

- `pack_field_int`はsize 65／108で、16.5.4.9が要求するERRORを出しません。
  2件とも不正packの状態は調べず、新しいpackerで64-bitの往復が動作することを比較対象にします。

- comparerの`set_show_max(0)`は、0を無制限として個別の不一致reportを出します。
  16.3.5.1／16.3.3.7は最大数を定義し、0を無制限とする例外はありません。上限0のreportなしを保持し、
  3不一致すべての記録と、reportが見える上限5の比較対象も検査します。

これらの分岐は、固定版で再現したオラクルとしては扱いません。drop直後の一覧、transactionの
生成直後の状態、重大度・ID別のreset、無効なfield_opの操作名取得、応答数未満の深さ変更、
応答エラー報告の既定値、候補1件のUSER arbitration、lockの順序、kill後のhook、
不適合なdefault型のエラー、stop時の自動objection解除、時刻の既定名・API、
二段のinitiator socket接続、pushの連続転送、sequence libraryのAPIと削除、FIFOのpeek通知、
start_itemの重大度、library subtypeの構築、finish_itemの委譲・ID・入力検査、lock前のfield名検索、mapの幅・変換結果、locationごとのmemory offsetと単一mapの実効access、predictorの転送先、big endianのfrontdoor data、順序を変更したreadの再合成は診断用に保持します。
残りのライブラリの制約は、一致するテストシナリオでは避けています。

さらにcommand-lineのsuffix照会2件では、現在の`UVM_NO_DPI`設定で渡した引数を観測できません。
固定ライブラリの引数列挙stubが空の一覧を返すためです。一致とqueue置換の期待値は規格から保持します。
これは実行設定の制約であり、suffixの照合algorithm自体の不具合を実証したものではありません。

FIFOの失敗get／peek 4件は、12.2.4.2.6／.8の出力保持の事後条件を維持します。固定版実行は呼出し側のsentinelを置き換え、
成功する比較対象は動作します。宣言する`output` signatureとSystemVerilog 13.5のreturn時の代入は本文と食い違い、
シミュレータの不具合とは断定せず、解釈の作業として残します。

20-bit memory 2件は、19.1.2.4の`n_bits`をlogical model bit数と解釈し、8-bit busで幅8・8・4を期待します。
固定版実行は8・8・8を返しますが、address、方向、宣言dataの検査は一致します。
24-bit memory／16-bit busの比較対象は、byteに整列する幅16・8と一致します。sub-byteのlogical幅と
byteへ丸める物理転送幅の違いは要レビューとし、この2件からライブラリの確定した不具合とは断定しません。
[端数転送](faq.ja.md#errorの契約と端数転送)も参照してください。

databaseのstream列挙の検査系は、7.1.4.2のqueue数を返す事後条件を保持します。
2 streamは返すqueueに正しく入りますが、関数は0を返し、1 streamでは1を返します。
記載された`function unsigned`のsignatureは、SystemVerilog 13.4では暗黙の1-bit logicの戻りとなり、2を表現できません。
期待値2は本文の解釈を保持します。このsignature／本文の矛盾は要レビューとし、確認済みのsimulator／library不具合には割り当てません。

sequence報告の1検査系は14.1.3.3のadmission解釈を保持し、report-enabled照会がfalseなら4つの簡易報告methodは処理せず戻ると期待します。
reporter閾値NONEでHIGHの4照会はいずれもfalseですが、固定sequence実装はWARNING・ERROR・FATALをoverrideした処理methodへ渡し、INFOだけを抑制します。
検査系counterをresetした閾値以内の比較対象は4つとも通ります。server出力は行いません。
これは、non-INFOのverbosityを無視する6.3.3.3のreport-object規則とは別です。class固有の契約と継承動作は要レビューで、
simulatorの確定した不具合には割り当てません。規格から導いたsequenceの期待をspecのみで保持します。

追加のconcat 3件は17.2.3.3.1〜.4の標準APIを保持します。名前付きconstructorの検査は明示文字列、空文字列、省略を使い、固定concat classには対応する名前付きconstructorがありません。
accessor 2検査系は置換、有効な隙間、値copyの独立性、空配列、置換後の追記を扱い、最初のbuild失敗は標準slice accessorの欠落です。
legacy memberや異なる名前のmethodへ置換しません。3件ともbuildの記録で、実行時結果はありません。

command-line 18検査系は別のVPI bridgeと固定regex DPIを明示要求し、通常runnerはlinkせず実行時結果のないbuild 18件として記録します。
別command-line条件では17件が両seed一致し、1件はNOでlockしたquit上限をuser codeが変える際のG.2.6の警告要求を保持します。
上限は正しく7のままですが、固定serverはINFOを発行し、警告probeはWARNINGを観測しません。YESの比較対象は警告なしで9へ変わります。
これは診断severityの差分で、上限の強制失敗ではありません。以前のno-DPI引数2件は未変更の通常実行時差分です。

スイート全体では、`verilator@5.052`を付けたテストは1329件、specのみのテストは189件です。
specのみのうち1件は9.6を検証します。pre-resetフェーズ終了時に子タスクが停止する
はずですが、固定版UVMとVerilator 5.052の組み合わせでは、後のフェーズで子タスクの遅延書き込みが
実行されます。この差分の原因がシミュレータとライブラリのどちらかは未確定です。

wakeup resetの検査系は、trigger waiterとpersistent-trigger waiterを各1つ確立してから`reset(1)`を呼びます。
10.1.1.2.8は、callbackなしで両方が起動することを要求します。固定Verilatorの実行は、待機状態の観測に到達してから
watchdogが期限切れになります。simulator／libraryを組み合わせた原因は未確定のまま、規範的なwakeupの期待を保持します。

specのみの189件も規格から導いた期待値を保持します。通常のVerilator実行とCIはoracle付き1329件（runtime 1299・compile拒否30）を選びます。
`--all`はspecのみも含め、不一致やビルド不可を`known`として記録します。
通常の実行時144件は、最初の差分であるseed 1までの記録で、seed 73の結果はありません。
API欠落build 16件は、time 1件、sequence-library 6件、HDL slice 4件、名前付きconcat constructor 1件、object active-policy 1件、catcher message-handle 3件で、
通常条件の実行時seed結果はありません。応答既定型の宣言1検査系もbuildできず、実行時seed結果はありません。HDL DPI 8検査系とcommand-line DPI 18検査系も通常runnerではlinkできません。
別のVPI条件では、7件が両seed一致、E.7のwarning／転送なしの期待はseed 1で失敗します。
重複する条件を合計しません。

policy 7 fixtureはseed 1で最初に異なり、seed 73結果はありません。copierの省略名は空でなく、comparer threshold／copier recursion／recorder radixはflush後の規定既定値へ戻りません。
stream最大超過のpack_fieldは要求errorをreportしません。SHALLOW field automationでは別handleの等値childを等値と比較し、copyで独立childを作ります。
policyと既定field flagを組み合わせた解釈は限定して保持します。これらはsimulator／libraryの組合せ観測で、原因を断定しません。
不正packerは検査も再利用もせず、別の有効controlを使います。新規runtime 15件は両seed一致、recorder不正宣言7件はruntimeを実行せず拒否されます。
attribute override controlは独自dummy tokenを使い、専用macro／backend互換性を立証しません。

## specのみのテスト

現在の189件は次のテストです。同じ制約を複数のテストで検査する場合があり、異なる不具合の個数ではありません。

- [blocking initiator relayの印刷provider受理](../tests/u12/test_tlm2_blocking_passthrough_initiator_connect_accepts_its_spec_listed_provider_families.sv).
- [blocking target relayの印刷provider受理](../tests/u12/test_tlm2_blocking_passthrough_target_connect_accepts_its_spec_listed_provider_families.sv).
- [同種terminatorの直接binding拒否の限定解釈](../tests/u12/test_tlm2_same_kind_terminator_socket_connections_leave_no_provider_bindings.sv).

- [REQだけ指定するbidirectional portの独立integer応答既定型](../tests/u12/test_tlm_bidirectional_request_only_parameter_keeps_declared_integer_response_default.sv).

- [callback省略時の中間descendant total](../tests/u10/test_objection_skipped_propagation_delivers_default_and_registered_hooks_with_context.sv).

- [確立した早いraw event待ち](../tests/u10/test_event_raw_trigger_wait_distinguishes_early_and_same_slice_late_calls.sv).
- [既定reset後の実event waiter件数](../tests/u10/test_event_default_reset_preserves_mixed_waiters_for_a_fresh_trigger.sv).
- [必要なevent-pool初期項目](../tests/u10/test_event_pool_initial_membership_contains_begin_accept_and_end_without_lazy_get.sv).

- [単一encoderの値伝播](../tests/u18/test_user_backdoor_encode_single_propagates_all_value_elements.sv).
- [encoder chainの値伝播](../tests/u18/test_user_backdoor_encode_chain_propagates_all_value_elements.sv).
- [単一decoderのclear-data伝播](../tests/u18/test_user_backdoor_decode_single_propagates_all_value_elements.sv).
- [逆順decoder chainの伝播](../tests/u18/test_user_backdoor_decode_chain_propagates_all_value_elements.sv).

- [明示HDL abstractionの選択](../tests/uE/test_hdl_path_sequence_uses_an_explicit_abstraction_instead_of_the_invalid_default.sv).
- [空abstraction listでblock既定を使用](../tests/uE/test_hdl_path_sequence_uses_the_block_default_abstraction_when_the_list_is_empty.sv).
- [明示force_time 0のdeposit委譲](../tests/u19/test_hdl_force_time_explicit_zero_time_delegates_to_deposit_without_force_or_release.sv).
- [既定force_timeのdeposit委譲](../tests/u19/test_hdl_force_time_default_time_delegates_to_deposit_without_force_or_release.sv).

- [port-baseの名前・parent・role・generic型名](../tests/u05/test_port_base_preserves_names_parents_and_each_interface_role.sv).
- [elaboration後のblocking exportのdefault index切替](../tests/u12/test_blocking_export_default_index_switches_the_selected_implementation_after_elaboration.sv).
- [HDL depositの対象選択と存在しないpathの失敗](../tests/u19/test_hdl_deposit_sets_only_the_selected_variable_and_reports_missing_paths.sv).
- [利用不能なregister pathへのwarningとstorage転送なし](../tests/uE/test_hdl_path_sequence_warns_for_inaccessible_register_paths_without_storage_access.sv).
- [HDL readの実際のwide値と両変数の保持](../tests/u19/test_hdl_read_returns_actual_wide_storage_without_modifying_either_variable.sv).
- [既定abstractionの利用可能pathと時刻不変](../tests/uE/test_hdl_path_sequence_accepts_an_accessible_default_abstraction_without_advancing_time.sv).

- [policy／objectのactive-policy push／pop同期](../tests/u16/test_policy_object_stack_tracks_nested_active_policy_push_and_pop.sv).

- [register-itemの不正value index](../tests/u19/test_reg_item_invalid_value_indices_warn_without_changing_existing_data.sv).

- [簡易表記plusの1文字以上の照合](../tests/uF/test_is_match_plus_requires_at_least_one_character.sv).

- [並べ替えたlittle-endian readの再合成](../tests/u18/test_reg_order_policy_little_endian_read_uses_requested_bus_order.sv).
- [big-endianの順序付きwrite byte](../tests/u18/test_reg_order_policy_big_endian_write_uses_requested_bus_order.sv).
- [big-endianの順序付きread値](../tests/u18/test_reg_order_policy_big_endian_read_uses_requested_bus_order.sv).

- [componentのstream参照解放後の新規生成](../tests/u13/test_component_free_recording_stream_invalidates_only_its_cached_pair.sv).

- [phase implementation lookupのnode戻り値](../tests/u09/test_phase_implementation_lookup_stays_within_each_local_schedule.sv).
- [register／memory coverageの直前mask戻り値](../tests/u18/test_coverage_register_and_memory_controls_return_the_previously_enabled_models.sv).
- [block coverageの直前mask戻り値](../tests/u18/test_coverage_block_control_recurses_through_nested_models_and_preserves_peer.sv).
- [memoryの完了locationごとのsampling](../tests/u18/test_coverage_memory_sampling_observes_completed_reads_and_writes_on_the_selected_map.sv).

- [closed databaseのstream-open guard](../tests/u07/test_recording_database_ignores_stream_opens_until_connection_succeeds.sv)。
- [stream列挙の戻り件数](../tests/u07/test_recording_database_stream_enumeration_is_local_and_excludes_failed_opens.sv)。
  1-bit signatureとの矛盾を残し、queue数の本文を保持します。
- [未初期化stream照会のwarning](../tests/u07/test_recording_uninitialized_stream_queries_each_report_a_warning.sv)。

- [無効event callbackのdispatch](../tests/u10/test_event_disabled_callback_is_skipped_and_can_be_reenabled_for_later_triggers.sv)。
- [両event待機方式のwakeup reset](../tests/u10/test_event_reset_with_wakeup_releases_both_wait_styles_without_callback_dispatch.sv)。
  simulator／libraryの原因は未確定です。
- [model lock前後でのblockのregister単純名検索](../tests/u18/test_block_register_name_lookup_prefers_local_scope_and_finds_descendants.sv)。

- 必須のHDL concat API：
  [設定／読戻し](../tests/u17/test_hdl_concat_standard_set_slices_initializes_a_split_register_description.sv)と
  [追加／読戻し](../tests/u17/test_hdl_concat_standard_get_slices_returns_the_appended_most_to_least_order.sv)。
- [最も近い祖先の既定HDL abstraction](../tests/u18/test_block_hdl_default_abstraction_inherits_from_the_nearest_configured_ancestor.sv)。

- 空queueのpopのwarning：
  [先頭](../tests/u11/test_queue_empty_pop_front_warns_returns_default_and_allows_refill.sv)と
  [末尾](../tests/u11/test_queue_empty_pop_back_warns_returns_default_and_allows_refill.sv)。
- [memoryのpre-readでのmap／offset変更](../tests/u18/test_mem_registered_pre_read_callback_redirects_the_offset_and_map_before_transfer.sv)。
- [memoryのpost-write callbackの順序と最後のstatus](../tests/u18/test_mem_post_write_callback_precedes_final_status_hook_without_rewriting_storage.sv)。

- field_opのaccessorの必須エラー：
  [set前](../tests/u05/test_field_op_accessors_report_errors_before_set.sv)と
  [flush後](../tests/u05/test_field_op_accessors_report_errors_after_flush.sv)。
- [transactionの生成直後の非active状態](../tests/u05/test_transaction_is_inactive_before_first_begin.sv)。
- [report handlerの重大度・ID別reset](../tests/u06/test_report_handler_reset_clears_pair_severity_override.sv)。
- [phase終了時の残った子タスクの停止](../tests/u09/test_task_phase_kills_remaining_child_task.sv)。
  シミュレータとライブラリのどちらが原因かは未確定です。
- [drop直後のobjector一覧からの削除](../tests/u10/test_objection_objectors_list_removes_dropped_source.sv)。
- 応答エラー報告の既定値：
  [生成直後の設定](../tests/u14/test_sequence_response_controls_have_documented_defaults.sv)と
  [変更しない別instanceの設定](../tests/u14/test_sequence_response_control_updates_are_per_instance.sv)。
- 応答数未満への深さ変更の必須エラー：
  [応答2件を深さ1へ](../tests/u14/test_sequence_response_depth_shrink_below_two_replies_reports_error.sv)と
  [応答1件を深さ0へ](../tests/u14/test_sequence_response_depth_shrink_to_zero_with_one_reply_reports_error.sv)。
- [候補1件のUSER arbitration](../tests/u15/test_sequencer_user_arbitration_calls_override_with_one_candidate.sv)。
- lockの付与順：
  [取得済みitemの完了通知を待つ](../tests/u15/test_sequencer_lock_waits_until_previously_granted_item_completes.sv)と
  [先にキューへ入ったFIFO要求を追い越さない](../tests/u15/test_sequencer_fifo_lock_does_not_overtake_earlier_pending_item.sv)。
- kill後の必須hook：
  [sequencerあり](../tests/u14/test_sequence_kill_executes_required_post_hooks_when_bound.sv)と
  [sequencerなし](../tests/u14/test_sequence_kill_executes_required_post_hooks_when_unbound.sv)。
- 不適合なdefault sequenceの必須エラー：
  [通常のobject](../tests/u15/test_default_sequence_rejects_object_wrapper_with_required_error.sv)と
  [sequence item](../tests/u15/test_default_sequence_rejects_sequence_item_wrapper_with_required_error.sv)。
- stop時の自動objection解除：
  [単独sequence](../tests/u15/test_stop_sequences_drops_automatic_objection_for_active_sequence.sv)と
  [親子sequence](../tests/u15/test_stop_sequences_drops_automatic_objection_for_parent_and_child.sv)。
- canonical timeの規格APIと既定名：
  [既定の名前](../tests/u12/test_tlm2_time_default_constructor_uses_canonical_type_name.sv)と
  [default-resolution設定API](../tests/u12/test_tlm2_time_standard_default_resolution_api_constructs_delay.sv)。
  後者はビルド不可です。
- [二段のpass-through initiatorのbackward接続](../tests/u12/test_tlm2_nested_passthrough_initiators_route_both_directions.sv)。
- push方式の複数要求：
  [転送順序](../tests/u15/test_push_sequencer_delivers_each_request_once_in_sequence_order.sv)、
  [要求履歴](../tests/u15/test_push_sequencer_common_request_history_keeps_newest_handles.sv)、
  [応答履歴](../tests/u15/test_push_sequencer_common_response_history_counts_analysis_replies.sv)。
- sequence libraryの削除：
  [未登録型のwarning](../tests/u14/test_sequence_library_remove_unregistered_type_reports_warning.sv)と
  [typewideの伝搬](../tests/u14/test_sequence_library_remove_static_type_updates_all_existing_instances.sv)。
- sequence libraryの規格API欠落（6件ともビルド不可）：
  [既定mode](../tests/u14/test_sequence_library_standard_selection_mode_defaults_to_rand.sv)、
  [mode更新](../tests/u14/test_sequence_library_standard_selection_mode_updates_are_per_instance.sv)、
  [既定の範囲](../tests/u14/test_sequence_library_standard_count_bounds_default_to_ten.sv)、
  [回数の制約](../tests/u14/test_sequence_library_standard_count_bounds_constrain_randomized_count.sv)、
  [実行前の回数](../tests/u14/test_sequence_library_standard_execution_counter_starts_at_zero.sv)、
  [実行中・完了後の回数](../tests/u14/test_sequence_library_standard_execution_counter_excludes_active_child.sv)。
- FIFOのpeek通知：
  [blocking peek](../tests/u12/test_tlm_fifo_blocking_peek_publishes_each_observation_without_consuming.sv)と
  [nonblocking peek](../tests/u12/test_tlm_fifo_nonblocking_peek_publishes_each_success_without_consuming.sv)。
- `start_item`の必須ERROR：
  [`null` item](../tests/u14/test_sequence_start_item_null_argument_reports_error_and_returns.sv)、
  [sequence引数](../tests/u14/test_sequence_start_item_sequence_argument_reports_error_and_returns.sv)、
  [sequencer不足](../tests/u14/test_sequence_start_item_without_any_sequencer_reports_error_and_returns.sv)。
- libraryのstatic所属の構築：
  [2つのinstance](../tests/uB/test_sequence_library_macros_populate_two_constructed_instances.sv)、
  [2種類のlibrary](../tests/uB/test_sequence_library_macro_registers_one_sequence_with_two_library_types.sv)、
  [baseの所属](../tests/uB/test_sequence_library_macro_subtype_inherits_base_static_membership.sv)、
  [instance内の追加](../tests/uB/test_sequence_library_macro_membership_combines_with_local_addition_only_on_one_instance.sv)。
- finish_itemの必須virtual呼び出し：
  [送信](../tests/u14/test_sequence_finish_item_invokes_sequence_send_request_override.sv)と
  [完了待ち](../tests/u14/test_sequence_finish_item_invokes_sequence_completion_wait_override.sv)。
- finish_itemの完了ID：
  [1要求](../tests/u14/test_sequence_finish_item_passes_explicit_transaction_id_to_completion_wait.sv)と
  [2要求](../tests/u14/test_sequence_finish_item_keeps_each_transaction_id_in_two_completion_waits.sv)。
- finish_itemの必須入力検査：
  [`null` item](../tests/u14/test_sequence_finish_item_null_input_reports_error_before_mid_do.sv)、
  [sequence引数](../tests/u14/test_sequence_finish_item_sequence_input_reports_error_before_mid_do.sv)、
  [sequencer不足](../tests/u14/test_sequence_finish_item_missing_sequencer_input_reports_error_before_mid_do.sv)。
- lock前のfield名の検索：
  [構築済みfield](../tests/u18/test_reg_named_field_lookup_works_before_and_after_model_lock.sv)。
- mapの幅と変換の戻り値：
  [lock前の幅](../tests/u18/test_reg_map_byte_addressing_reports_width_before_and_after_lock.sv)、
  [word単位の変換](../tests/u18/test_reg_map_word_addressing_translates_offsets_in_bus_units.sv)、
  [階層の実効幅](../tests/u18/test_reg_submap_uses_root_base_and_narrowest_bus_width.sv)。
- locationごとのmemory offset：
  [location 0・1・3](../tests/u18/test_mem_location_offsets_include_the_location_index_stride.sv)。
- 単一mapでのmemoryのアクセス制限：
  [固有policyと制限したview](../tests/u18/test_mem_intrinsic_readonly_policy_and_map_rights_are_distinct.sv)。
- predictorの転送先変更：
  [転送先と値の変更](../tests/u19/test_reg_predictor_pre_predict_redirects_the_target_and_modified_value.sv)。
- big endianのfrontdoor read：
  [2つのbus word](../tests/u18/test_reg_frontdoor_big_endian_wide_read_preserves_returned_bus_words.sv)。

- fieldより先のregister hook：
  [pre-write](../tests/u18/test_reg_pre_write_hook_precedes_the_containing_fields_hook.sv)と
  [pre-read](../tests/u18/test_reg_pre_read_hook_precedes_the_containing_fields_hook.sv)。

- memory burstの物理beatの種別と転送：
  [write](../tests/u18/test_mem_frontdoor_burst_write_advances_full_width_locations.sv)と
  [read](../tests/u18/test_mem_frontdoor_burst_read_fills_full_width_array_in_location_order.sv)。

- 実装先memoryの幅に切り上げたvirtual registerのbyte幅：
  [幅の広いmemoryでの実装](../tests/u18/test_vreg_byte_width_rounds_up_to_the_implementing_memory_location_width.sv)。

- memoryを省略したvirtual配列の動的resize：
  [配置の維持](../tests/u18/test_vreg_dynamic_resize_without_memory_preserves_placement.sv)。
- 実装したregionのvirtual配列の所有者：
  [所有者とmemoryのhandle](../tests/u18/test_vreg_implementation_region_identifies_its_virtual_register_array.sv)。

- field単独のvirtual post-write callback順序：
  [callbackがmethodより先](../tests/u18/test_vreg_field_standalone_post_write_callback_precedes_its_inherited_method.sv)。

- ユーザー定義backdoorのread-clear予測：
  [sample・clear・read後のミラー](../tests/u19/test_reg_user_backdoor_read_applies_read_clear_after_sampling.sv)。

- blockを指定したmemory-walkの除外：
  [wrapperはskip・直接の比較対象は実行](../tests/uE/test_memory_walk_sequence_honors_a_block_specific_walk_exclusion.sv)。

- 個別memoryのaccessの除外：
  [指定されたshared-accessのresourceと別の比較対象](../tests/uE/test_single_memory_access_sequence_honors_its_shared_access_exclusion_resource.sv)。

- 統合accessのblock除外：
  [アクセスなしのwrapperとregister／memoryを直接指定した比較対象](../tests/uE/test_combined_access_wrapper_honors_block_exclusion_with_direct_controls.sv)。
- bit-bashの未知policyのskip：
  [登録した独自policyと既知RWの別対象](../tests/uE/test_single_bit_bash_sequence_skips_user_defined_unknown_policy.sv)。
- `UVM_NO_DPI`でのcommand-lineのsuffix収集：
  [複数の一致suffix](../tests/uG/test_command_arg_values_collect_matching_suffixes_without_stale_entries.sv)、
  [欠落／繰り返しの照会](../tests/uG/test_command_arg_values_clear_on_no_match_and_repeat_without_appending.sv)。

- 上限を超える整数packで必要なERROR：
  [65 bit](../tests/u16/test_packer_integral_size_65_reports_error_before_independent_boundary_control.sv)、
  [128 bit](../tests/u16/test_packer_integral_size_128_reports_error_before_independent_boundary_control.sv)。
- 取得不可FIFOの出力保持（signature／本文の解釈）：
  [値のget](../tests/u12/test_tlm_fifo_failed_try_get_preserves_two_state_value_before_success.sv)、
  [handleのget](../tests/u12/test_tlm_fifo_failed_try_get_preserves_object_handle_before_success.sv)、
  [値のpeek](../tests/u12/test_tlm_fifo_failed_try_peek_preserves_two_state_value_before_success.sv)、
  [handleのpeek](../tests/u12/test_tlm_fifo_failed_try_peek_preserves_object_handle_before_success.sv)。
- sub-byteのlogical幅の解釈：
  [20-bit write](../tests/u18/test_mem_frontdoor_twenty_bit_write_preserves_location_boundaries_and_partial_width.sv)、
  [20-bit read](../tests/u18/test_mem_frontdoor_twenty_bit_read_assembles_declared_bits_and_partial_width.sv)。

- overrideなしの名前照会：
  [object](../tests/u08/test_factory_no_override_object_queries_agree_with_ordinary_creation.sv)、
  [component](../tests/u08/test_factory_no_override_component_queries_agree_with_ordinary_creation.sv)。
- comparerのmessage上限0：
  [個別reportと、reportが見える比較対象](../tests/u16/test_comparer_zero_message_limit_suppresses_reports_before_a_visible_control.sv)。
  [出力と上限](faq.ja.md#出力上限応答の観測)も参照してください。

追加のconfiguration／relationship検査系：

- [既定resource dispatch](../tests/u13/test_component_config_application_matches_scope_and_passes_exact_resource.sv)
- [既定hook抑制](../tests/u13/test_component_config_disabled_user_hook_skips_set_local_for_one_application.sv)
- [strict resource dispatch](../tests/u13/test_component_strict_config_application_matches_scope_and_passes_exact_resource.sv)
- [strict hook抑制](../tests/u13/test_component_strict_config_disabled_user_hook_skips_set_local_for_one_application.sv)
- [0によるrelationship check無効化](../tests/u05/test_port_relationship_checks_default_off_and_explicit_zero_allow_remote_providers.sv)

追加のabstract registry／depth検査系：

- [parentなしabstract componentのerror／null](../tests/u08/test_abstract_component_registry_without_override_reports_error_and_returns_null.sv)
- [parent変更後の自動depth](../tests/u14/test_sequence_parent_reassignment_updates_calculated_depth_root_and_path.sv)

追加のmodel子孫名検索検査系：

- [child blockのmap検索](../tests/u18/test_block_map_name_lookup_selects_local_maps_then_unique_descendants.sv)
- [simple nameによる子孫block検索](../tests/u18/test_block_name_lookup_uses_simple_descendant_names_and_excludes_external_roots.sv)

追加のregister file abstraction検査系：

- [最も近い祖先の既定値](../tests/u18/test_regfile_default_hdl_abstraction_follows_nearest_ancestor_and_local_override.sv)
- [継承kindによるflatten full path](../tests/u18/test_flattened_regfile_omits_its_name_from_full_paths_for_each_selected_abstraction.sv)

追加のheartbeat／FIFO検査系：

- [動作中の既定event再利用](../tests/u10/test_heartbeat_default_start_reuses_its_event_while_running_and_after_stop.sv)
- [FIFO inline制約の観測](../tests/u18/test_reg_fifo_randomization_accepts_capacity_and_rejects_an_oversized_queue.sv)
- [subtypeで宣言したFIFOの境界](../tests/u18/test_reg_fifo_capacity_constraint_applies_to_subtype_declared_queue_sizes.sv)

追加のfield個別byte-enable検査系：

- [独立したfield write](../tests/u18/test_field_byte_enable_write_selects_individual_or_whole_register_access.sv)
- [独立したfield read](../tests/u18/test_field_byte_enable_read_selects_individual_or_whole_register_access.sv)

追加のmessage-handle／endian検査系：

- [事前構成messageの同一性](../tests/u06/test_report_catcher_exposes_the_supplied_preformed_message_and_current_origin.sv)
- [messageのlive alias](../tests/u06/test_report_catcher_message_handle_mutations_are_live_in_tail_and_caller.sv)
- [事前構成messageの再利用](../tests/u06/test_preformed_report_reuse_rebinds_origin_and_actions_for_each_reporter.sv)
- [個別big-endian fieldのaddress](../tests/u18/test_field_access_big_endian_respects_layout_and_physical_bus_width.sv)

- [Virtual処理前のsequence報告のseverity admission](../tests/u14/test_sequence_item_reporting_filters_each_severity_before_virtual_processing.sv).

- [名前付きconcat生成](../tests/u17/test_hdl_concat_standard_constructor_accepts_explicit_and_empty_instance_names.sv).
- [Concatの置換とcopyの独立性](../tests/u17/test_hdl_concat_standard_set_slices_replaces_prior_gapped_description_without_aliases.sv).
- [置換後のconcat追記](../tests/u17/test_hdl_concat_standard_add_slice_appends_after_replacement_and_preserves_peer.sv).

- [実引数一覧とsingletonの同一性](../tests/uG/test_command_vpi_singleton_and_all_arguments_preserve_supplied_membership.sv).
- [Plus引数の選別とqueue置換](../tests/uG/test_command_vpi_plusargs_exclude_dash_arguments_and_replace_caller_contents.sv).
- [大小を混ぜたUVM引数の選別](../tests/uG/test_command_vpi_uvm_arguments_accept_mixed_case_keywords_and_both_prefixes.sv).
- [Prefix照合の置換と欠落照会](../tests/uG/test_command_vpi_prefix_matches_replace_queues_and_clear_missing_queries.sv).
- [最初のsuffixと全一致件数](../tests/uG/test_command_vpi_first_value_preserves_the_first_suffix_and_counts_all_matches.sv).
- [空／comma入りsuffixの全取得](../tests/uG/test_command_vpi_all_values_keep_empty_and_comma_suffixes_without_stale_entries.sv).
- [Extended-regexの選択肢と照会の消去](../tests/uG/test_command_vpi_extended_regex_matches_grouped_alternatives_and_clears_queries.sv).
- [最初のtest名選択と重複警告](../tests/uG/test_command_testname_creates_the_first_registered_test_and_warns_for_duplicates.sv).
- [生成したcomponentへの初期verbosity](../tests/uG/test_command_initial_verbosity_applies_to_components_created_in_build.sv).
- [選択ID／componentだけの時刻verbosity変更](../tests/uG/test_command_timed_verbosity_updates_the_selected_id_and_component_only.sv).
- [選択component／IDのaction設定](../tests/uG/test_command_action_setting_is_scoped_to_the_selected_component_and_id.sv).
- [Severity overrideと比較対象の保持](../tests/uG/test_command_severity_override_changes_the_selected_report_and_preserves_controls.sv).
- [Quit上限の後の変更を許可](../tests/uG/test_command_max_quit_count_allows_a_later_user_setting.sv).
- [Quit上限の後の変更を拒否](../tests/uG/test_command_max_quit_count_rejects_a_later_user_setting.sv).
- [Factoryのinstance overrideとtype override](../tests/uG/test_command_factory_instance_override_precedes_the_type_override_for_its_target.sv).
- [数値base／文字列configとscope分離](../tests/uG/test_command_configuration_sets_numeric_bases_and_strings_in_the_selected_scope.sv).
- [指定sequencer／phaseでのdefault sequence実行](../tests/uG/test_command_default_sequence_runs_on_the_named_sequencer_and_phase.sv).
- [生成時の独立した引数snapshot](../tests/uG/test_command_fresh_processors_populate_independent_argument_snapshots_at_construction.sv).

既存command 1検査系は、動作／期待出力を変えずcommand-enum引用を追加し、Verilatorで再測定します。
その入力の歴史的guest記録は指紋が古くなったため、現在のguest部分集合から除外します。
互換な1084記録、変更した入力を含む未測定434入力であり、新しいguest失敗ではなくevidence範囲の区別です。

- [copier既定名](../tests/u16/test_policy_comparer_packer_and_copier_constructors_preserve_names_types_and_policy_bases.sv)
- [flush後のcomparer threshold](../tests/u16/test_comparer_threshold_default_updates_and_flush_restore_the_declared_boundary.sv)
- [flush後のcopier recursion](../tests/u16/test_copier_recursion_default_updates_and_flush_restore_the_declared_policy.sv)
- [SHALLOW child比較](../tests/u16/test_comparer_field_automation_distinguishes_nested_recursion_and_alias_conditions.sv)
- [SHALLOW child所有関係](../tests/u16/test_copier_field_automation_distinguishes_deep_shallow_and_default_child_ownership.sv)
- [wide pack上限超過error](../tests/u16/test_packer_wide_oversize_reports_error_before_an_independent_maximum_width_control.sv)
- [flush後のrecorder radix](../tests/u16/test_recorder_configuration_defaults_updates_and_flush_restore_the_declared_values.sv)

## シミュレータとライブラリの組み合わせ

スイートは1518件ですが、以下のkirimasim／Ghost記録は未変更の現在入力1084件だけを対象とします。
以前の一時実行ファイル／profile snapshotがないため、434入力は未測定です。
新しい全件guest実測とは扱いません。[実行結果](results.ja.md)を参照してください。

Ghostの同梱UVMはseed 1・73とも207件一致・877件不一致で、不一致になるテストも同じです。
現在の実行ファイルの固定コピーでは固定版modeを測定していません。記録の合算は[実行結果と測定方法](results.ja.md)で説明します。
同梱版の結果が対象にするのは供給されたライブラリです。不一致だけでシミュレータとライブラリの原因を分けたり、
固定版ライブラリの結果を示したりはできません。非公開の識別情報・profile・診断は公開しません。

確認したkirimasimの実行ファイルでは、1075件が`uvm_object_wrapper`未実装です。
時刻設定APIの1件、sequence libraryの6件、HDL sliceの2件は、その前にAPI欠落を検出して`fail`になります。
いずれも成功ではなく、その先のUVM動作を実行できた証拠でもありません。

実行範囲は[READMEの現在の実行結果](../README.ja.md#現在の実行結果)、
過去の測定は[履歴](history.ja.md)を参照してください。
