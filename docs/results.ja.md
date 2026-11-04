# 現在の実行結果と測定方法

[English](results.md) · [README](../README.ja.md) · [既知差分](known-differences.ja.md)

## 現在のスナップショット

2026-11-04に集約したVerilator記録は現在の1677件すべてを対象にします。他2系統は未変更1083件の記録で、
594入力は未測定です。各記録は入力と実行条件を指紋で識別します。
スイートは21 directoryの1677件で、simulation 1631件とelaboration 46件です。
milestoneはM1 640件（604／36）、M2 538件（533／5）、M3 499件（494／5）で、括弧内はruntime／elaborationです。
全件が`spec_check: ai`で、人のレビューは記録していません。DPIなし1651件のうち46件は不正elaboration検査であり、HDL-DPI 8件とcommand-line／regex-DPI runtime 18件は別です。

| シミュレータとライブラリ | 観測結果 | 実行範囲 |
| --- | --- | --- |
| Verilator 5.052・固定版UVM | `pass` 1468件：runtime 1424＋compile拒否44、`known` 209件 | runtime一致はseed 1／73。期待compiler拒否は実行時seedを実行しない |
| Verilator 5.052・独自VPI HDL backend | `pass` 7件、`fail` 1件 | 重複する8件の別条件。一致はseed 1／73、差分はseed 1 |
| Verilator 5.052・独自command-line VPI bridge・固定regex DPI | `pass` 17件、`known` 1件 | 重複する18件の別条件。一致はseed 1／73、差分はseed 1 |
| kirimasim・固定版UVM | `unsupported`が1074件、`fail`が9件 | 未変更1083入力。594入力は未測定 |
| Ghost・同梱UVM | `pass`が207件、`fail`が876件 | 各seedで未変更1083入力。失敗集合は同じ。594入力は未測定 |
| Ghost・固定版UVM | 現在の実行ファイルの固定コピーでは未測定 | 現在の固定版modeの結果は示さない |

固定ライブラリはAccellera UVM 2020.3.1、コミット`78c06547a2a0`で、326ファイルを
[lock](../third_party/uvm.lock)と照合します。Ghostの同梱実行は、lockのパッケージではなく供給されたライブラリを使います。
非公開シミュレータの識別情報、版、パス、profileの内容、診断は公開しません。
公開interfaceは[Ghostの設定](testing.ja.md#ghost)で説明します。Icarus VerilogはこのUVMスイートには使いません。

## 結果の解釈

正当なnegative期待44件は、宣言したfixture／class／method／禁止memberまたはconst参照の診断によるcompile拒否で一致します。
別の不正design 2件はsubscriberのwriteとvisitorのvisitを未実装でも受理され、拒否期待を既知差分として保持します。
受理されたものを含め、不正designはruntimeを実行しません。simulationの予期しないbuild失敗48件は別です。`pass`には宣言した期待との一致が必要です。

specのみの209件は規格由来の出力またはcompile診断期待を保持します。不正compiler受理2件とsimulation 207件です。
simulationのうち159件はseed 1で最初に異なり、seed 73結果はありません。API／型名欠落build 18件はtime API 1、sequence-library API 6、HDL slice 4、named-concat constructor 1、object active-policy API 1、catcher message-handle 3、印刷されたbase記録状態getter 1、印刷report callback typedef 1です。
宣言build 2件は既定型の不一致で、別の2件は印刷all_dropped function／taskとclone暗黙scalar／map返却の食違いを保持します。ほか26件はDPI未linkでHDL 8・command-line 18です。
simulation build 48件にはruntime結果がなく、別command-line条件は17一致とquit-warning差分1件を保持します。

共有handler resetではseverity／ID verbosity値が残り、general／ID値とaction／fileは既定へ戻ります。
期待するresetと後続の境界配送は変更せず、runtimeの既知fixtureが1件増えます。以前のseverity override reset差分も保持します。

別のVPI条件は、独自backendでHDL検査系8件を実測し、7件がseed 1／73で一致します。
利用不能pathのsequenceは、warningに対してERRORを報告し、保持するE.7の転送なしの解釈に対してstorage readを試み、
seed 1で最初に異なります。利用可能pathの比較対象と、実際のHDL deposit／readは一致します。
backendの64 bit packed変数という範囲は、vendor overlay、配列、4値の動作を示しません。
重複するpass数を通常の合計へ加算しません。[HDL設定](testing.ja.md#verilatorのvpi-hdl部分集合)と
[既知差分](known-differences.ja.md)を参照してください。

kirimasimは1074件で`uvm_object_wrapper`未対応を報告し、残る9件はそれより先にライブラリAPI欠落を検出します。
いずれも、その障害より後のUVM動作を実行できた証拠ではありません。Ghostの同梱版の不一致だけでは、
シミュレータとライブラリのどちらが原因かは決まらず、固定版ライブラリでの結果も示しません。ゲストの付録Eの一致は、
[RO registerのskip](../tests/uE/test_single_register_access_sequence_skips_a_readonly_register.sv)、
[registerのbackdoorなしのskip](../tests/uE/test_single_register_access_sequence_skips_a_register_without_a_backdoor.sv)、
[memoryのbackdoorなしのskip](../tests/uE/test_single_memory_access_sequence_skips_a_memory_without_a_backdoor.sv)の条件だけを対象にします。
frontdoor／backdoorの転送動作の成功は示しません。

`known`・`unsupported`は成功に数えません。コマンドの終了コードだけではスイートの一致件数は分からないため、
[FAQ](faq.ja.md#結果の読み方)の分類と終了規則も確認します。2つのseedでは、決定性や4値の正しさは証明できません。

## 記録の合算

通常snapshotは
[c80ec90](https://github.com/kurochan001/kirimasim-uvm-tests/commit/c80ec904cdcab030e2d11a2f8d4b48857c9bd6b3)
の以前の全1662入力同一性／記録を保持し、2026-11-04 JSTに測定したM1 simulation 15 fixtureを追加します。全15件がseed 1／73に一致します。
timeout満了は宣言したcatcher観測と正常なUVM終了で判定します。compiler拒否fixtureや新しい既知差分は追加せず、既存known 209件のoracleを保持します。

直接delegate matrix 2個がcommon function proxy 8個とtask proxy 13個（runと12 runtime phase）を調べます。
各行で選択virtual hookを他hookと無呼出しのpeerから区別し、明示contextを保持します。task proxyは独自の遅延hookのreturnを待ちます。
これは2 fixtureであり独立21 fixtureではなく、直接exec_taskの動作はexecuteのforkと別です。

実engine controlはrun前hookの時刻0、run／final終了時刻、12 runtime phaseの順序／非重複とstart／extract境界、run並行性を扱います。並行controlは2単位間隔で、run nodeの`EXECUTING`または`READY_TO_END`と独自task heartbeatの進行を観測します。
開始だけでは不十分なため、この強化入力が現在の集約で以前の開始markerだけの記録を置き換えます。timeoutはlockした絶対上限とoverridableの省略既定値を区別します。task走査はdomainへ接続した部分木でSTARTED、EXECUTING、READY_TO_END、ENDEDを追加します。
独自の特化component proxyは共通phase viewと型ごとのsingletonを保持します。

domainの別々の6 fixtureは独立進行、同一phase／明示異phase同期、選択／省略／明示解除、隣接関係の保持を扱います。
独自並行scheduleは関連する両active分岐を共通先行nodeへjumpし、独立peerは1回実行します。
選択したcontrolで、実行中の全変更、不正target、graph、timing、旧thread cleanupの全条件は認定しません。

日英AI案47件と個別に読んだ文脈分類4件を追加し、以前の全2887要求・308分類・1662 fixture入力／native記録を未変更で保持します。
schema、runner／library／catalog、workflow、SVGは未変更です。guest実行、人のレビュー、分母承認、完了は主張しません。

保持するkirimasim／Ghost記録は、固定した実行ファイルとseedごとの非公開profileで取得しました。

商用シミュレータの結果は[投稿方針](faq.ja.md#商用シミュレータとissueの投稿方針)に従って除外します。

以前のkirimasim／Ghostの一時的な実行ファイル／profile snapshotは失われているため、guest再実行は主張しません。
歴史的fileは1085記録を保持します。現在はcommand-enum引用と修正したBoolean rerandomization観測の2入力が異なり、そのstale記録を除外します。
互換な現在の部分集合は1083記録で、kirimasimはunsupported 1074／API欠落fail 9、Ghostは各seedでpass 207／fail 876です。
未測定594入力は追加592件と修正した既存2件です。filterしたfileと`out/thin-fifty-fourth-evidence-scope.json`に明示除外を保持し、許可された一致実行条件の復元を待ちます。

指紋ごとに、識別する入力が異なります。

| 識別子 | 識別する内容 | 使い方 |
| --- | --- | --- |
| `inputs_sha256` | テストsource、期待値file、収集したhelper／data、library lock | 各記録を現在のテスト入力と照合する |
| `runner_sha256` | 選択したrunner、`suite_results.py`、`uvm_common.py` | batch間で一致し、`runner_changed`がfalseであることを確認する |
| `ledger_inputs_sha256` | 正本の範囲、要求、分類、テスト索引、条項catalog | simulationの証拠と別に、生成したinventory／backlogを識別する |

[台帳の識別子](requirements.ja.md#生成レポートの識別)は、生成したレビュー資料のものです。
入力／runnerのhashが一致しても、実行記録を再利用する前にシミュレータ、configuration、libraryの同一性を確認します。

合算する前に、次を確認します。

- Verilator IDが現在の全件を覆い、guest IDは宣言した1083件の部分集合と一致すること。594入力IDは未測定のままにすること。
- 各記録の`inputs_sha256`が、ランナーの集めた現在のソース、期待出力、関連入力、ライブラリのlockと一致すること。
- batch間でシミュレータの版、configuration、`runner_sha256`が一致し、`runner_changed`がfalseであること。
- このスナップショットでは、Verilatorタグ付きの全ケースが`pass`、現在のタグなしケースがすべて`known`であること。
- Ghostの2つのseedで、不一致になるテストの集合が同じであること。

これは現在の入力に対する互換な実行記録の合算であり、全件を単一のコマンドで再実行したという主張ではありません。
追加時の件数と測定、過去のスモーク、build変更の詳細は[開発履歴](history.ja.md)に残します。
更新した記録で以前の記録を置き換える場合も、現在の入力の指紋を先に確認します。

[要求台帳の案](requirements.ja.md)はAI案2934件です。新47義務と文脈分類4件で未評価は611番号となります。
第9章は部分94／分類22／未評価0で、全体は部分1584／分類312です。直接delegate呼出し、選択domain関係、timing controlは条件を保持し、元のmilestone目標や全phase動作は完了しません。

guest fileは互換1083記録をbyte単位で保持し、以前の修正2入力を含む未測定594（simulation 548／elaboration 46）を残します。新guest結果、人のレビュー、分母承認は主張しません。

## 再現と結果の保存

コマンド、profileのmode、ライブラリの設定は[テストと開発のガイド](testing.ja.md#スイートの実行)で説明します。
`--json out/<name>.json`を指定すると、分類、理由、configuration、指紋を保存します。
`out/`はGitの対象外で、Checkはこのローカル記録を公開しません。
入力、ランナー、実行ファイル、profile、ライブラリが異なる結果は、別の実行条件です。

## 継続的インテグレーション

[Check](../.github/workflows/check.yml)は`main`へのpush、pull request、手動実行で動きます。
固定ライブラリの整合性、ツールの単体テスト110件、metadata 1677件、要求台帳の案／テスト索引、通常oracle付きVerilator 1468件（seed 1／73のruntime 1424・実行時seedなしのcompiler拒否44）と、別条件の明示command-line 17件を検査します。
kirimasim、Ghost、specのみのケースは実行しません。READMEのバッジは現在のCIで、このローカル測定とは別の状態です。
Checkが成功しても、UVMの完全な適合性や全シミュレータの成功を示しません。Nightlyや結果の自動公開はありません。
