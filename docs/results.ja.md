# 現在の実行結果と測定方法

[English](results.md) · [README](../README.ja.md) · [既知差分](known-differences.ja.md)

## 現在のスナップショット

2026-11-05に集約したVerilator記録は現在の1837件すべてを対象にします。他2系統は未変更1083件の記録で、
754入力は未測定です。各記録は入力と実行条件を指紋で識別します。
スイートは21 directoryの1837件で、simulation 1778件とelaboration 59件です。
milestoneはM1 745件（699／46）、M2 547件（542／5）、M3 545件（537／8）で、括弧内はruntime／elaborationです。
全件が`spec_check: ai`で、人のレビューは記録していません。DPIなし1808件のうち59件は不正elaboration検査であり、HDL-DPI 11件とcommand-line／regex-DPI runtime 18件は別です。

| シミュレータとライブラリ | 観測結果 | 実行範囲 |
| --- | --- | --- |
| Verilator 5.052・固定版UVM | `pass` 1587件：runtime 1531＋compile拒否56、`known` 250件 | runtime一致はseed 1／73。期待compiler拒否は実行時seedを実行しない |
| Verilator 5.052・独自VPI HDL backend | `pass` 10件、`fail` 1件 | 重複する11件の別条件。一致はseed 1／73、差分はseed 1 |
| Verilator 5.052・独自command-line VPI bridge・固定regex DPI | `pass` 17件、`known` 1件 | 重複する18件の別条件。一致はseed 1／73、差分はseed 1 |
| kirimasim・固定版UVM | `unsupported`が1074件、`fail`が9件 | 未変更1083入力。754入力は未測定 |
| Ghost・同梱UVM | `pass`が207件、`fail`が876件 | 各seedで未変更1083入力。失敗集合は同じ。754入力は未測定 |
| Ghost・固定版UVM | 現在の実行ファイルの固定コピーでは未測定 | 現在の固定版modeの結果は示さない |

固定ライブラリはAccellera UVM 2020.3.1、コミット`78c06547a2a0`で、326ファイルを
[lock](../third_party/uvm.lock)と照合します。Ghostの同梱実行は、lockのパッケージではなく供給されたライブラリを使います。
非公開シミュレータの識別情報、版、パス、profileの内容、診断は公開しません。
公開interfaceは[Ghostの設定](testing.ja.md#ghost)で説明します。Icarus VerilogはこのUVMスイートには使いません。

## 結果の解釈

正当なnegative期待56件は宣言したfixture／type／memberの診断によるcompiler拒否で一致します。
不正design 3件はsubscriberのwriteとvisitorのvisitの欠落、印字virtual builtin dispatcherの直接生成を受理し、拒否oracleを既知差分として保持します。
受理されてもruntimeは実行せず、simulationの予期しないbuild 62件は別です。passには宣言した期待との一致が必要です。

specのみの250件は規格由来の出力またはcompile診断期待を保持し、不正compiler受理3件とsimulation 247件です。
simulationのうち185件はseed 1で最初に異なり、seed 73結果はありません。API／型名欠落build 24件はtime API 1、sequence-library API 6、HDL slice 4、named-concat constructor 1、object active-policy API 5、catcher message-handle 3、印刷されたbase記録状態getter 1、印刷report callback typedef 1、built-in type_id 2です。

time減算build 1件は省略可と印刷されたsecs引数を要求します。
宣言build 2件は既定型の不一致で、別の2件は印刷all_dropped function／taskとclone暗黙scalar／map返却の食違いを保持します。
2件は継承したtype_id registry特殊化の非互換で、1件はmemory backdoor_readのprotected access差分で、1件は記載外pure hookを要求する合法resource-base拡張です。ほか29件はDPI未linkでHDL 11・command-line 18です。
simulation build 62件にはruntime結果がなく、別command-line条件は17一致とquit-warning差分1件を保持します。

共有handler resetではseverity／ID verbosity値が残り、general／ID値とaction／fileは既定へ戻ります。
期待するresetと後続の境界配送は変更せず、runtimeの既知fixtureが1件増えます。以前のseverity override reset差分も保持します。

別のVPI条件はHDL fixture 11件で、10件がseed 1／73に一致します。memory 3 fixtureは実公開array cellへaccessし、継承基底taskのread／write、
8／16-bit分割bankによる24-bit word、ROM writeとpoke／read／peekの違いを検査します。未変更の独自backendで選択dataとneighbor cellを確認します。
派生wrapperは継承実装へ到達しますが、別途停止している公開read宣言を認定しません。

利用不能pathのsequenceは、warningに対してERRORを報告し、保持するE.7の転送なしの解釈に対してreadを試み、seed 1で最初に異なるままです。
以前のHDL 8入力同一性／記録は未変更で保持します。64 bitまでの選択packed cellとこれらのtwo-state array検査で、一般array／type、vendor overlay、force／release、four-state supportを示しません。
重複するpass数を通常合計へ加算しません。[HDL設定](testing.ja.md#verilatorのvpi-hdl部分集合)と[既知差分](known-differences.ja.md)を参照してください。

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

snapshotは[58ba1c5](https://github.com/kurochan001/kirimasim-uvm-tests/commit/58ba1c5782c0a47980539b0d8a7ca9501f2be296)を基にし、
以前の通常1800入力／記録を未変更で保持し、修正printer 1件を再測定後だけ置換し、新M1 36入力を2026-11-05 JSTに測定します。

M1の36 fixtureを追加し、19件が一致します。runtime 15件はseed 1／73、4件は期待compiler拒否です。
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

日英AI案60件と個別分類9件を追加し、以前の全3172要求・377分類は未変更です。
HDL 11件、command-line 18件、互換guest 1083件の記録はbyte単位で同一です。修正printerは元からguest部分集合にないため、
修正した元入力の除外が3件へ増えることはありません。guest実行、人のレビュー、分母承認、完了は主張しません。

保持するkirimasim／Ghost記録は、固定した実行ファイルとseedごとの非公開profileで取得しました。

商用シミュレータの結果は[投稿方針](faq.ja.md#商用シミュレータとissueの投稿方針)に従って除外します。

以前のkirimasim／Ghostの一時的な実行ファイル／profile snapshotは失われているため、guest再実行は主張しません。
歴史的fileは1085記録を保持します。現在はcommand-enum引用と修正したBoolean rerandomization観測の2入力が異なり、そのstale記録を除外します。
互換な現在の部分集合は1083記録で、kirimasimはunsupported 1074／API欠落fail 9、Ghostは各seedでpass 207／fail 876です。
未測定754入力は追加752件と修正した既存2件です。filterしたfileと`out/thin-sixty-first-evidence-scope.json`に明示除外を保持し、許可された一致実行条件の復元を待ちます。

指紋ごとに、識別する入力が異なります。

| 識別子 | 識別する内容 | 使い方 |
| --- | --- | --- |
| `inputs_sha256` | テストsource、期待値file、収集したhelper／data、library lock | 各記録を現在のテスト入力と照合する |
| `runner_sha256` | 選択したrunner、`suite_results.py`、`uvm_common.py` | batch間で一致し、`runner_changed`がfalseであることを確認する |
| `ledger_inputs_sha256` | 正本の範囲、要求、分類、テスト索引、条項catalog | simulationの証拠と別に、生成したinventory／backlogを識別する |

[台帳の識別子](requirements.ja.md#生成レポートの識別)は、生成したレビュー資料のものです。
入力／runnerのhashが一致しても、実行記録を再利用する前にシミュレータ、configuration、libraryの同一性を確認します。

合算する前に、次を確認します。

- Verilator IDが現在の全件を覆い、guest IDは宣言した1083件の部分集合と一致すること。754入力IDは未測定のままにすること。
- 各記録の`inputs_sha256`が、ランナーの集めた現在のソース、期待出力、関連入力、ライブラリのlockと一致すること。
- batch間でシミュレータの版、configuration、`runner_sha256`が一致し、`runner_changed`がfalseであること。
- このスナップショットでは、Verilatorタグ付きの全ケースが`pass`、現在のタグなしケースがすべて`known`であること。
- Ghostの2つのseedで、不一致になるテストの集合が同じであること。

これは現在の入力に対する互換な実行記録の合算であり、全件を単一のコマンドで再実行したという主張ではありません。
追加時の件数と測定、過去のスモーク、build変更の詳細は[開発履歴](history.ja.md)に残します。
更新した記録で以前の記録を置き換える場合も、現在の入力の指紋を先に確認します。

[要求台帳の案](requirements.ja.md)はAI案3232件で、新60義務と個別分類9件により未評価は335番号です。
全体は部分1786／分類386、第5章は99／12／0で案168件です。全部分義務と元のmilestone目標は未完了です。
guest記録は互換1083入力を保持し、以前の修正2入力を含む754（simulation 695／elaboration 59）は未測定です。
新guest結果、人のレビュー、分母承認は主張しません。

## 再現と結果の保存

コマンド、profileのmode、ライブラリの設定は[テストと開発のガイド](testing.ja.md#スイートの実行)で説明します。
`--json out/<name>.json`を指定すると、分類、理由、configuration、指紋を保存します。
`out/`はGitの対象外で、Checkはこのローカル記録を公開しません。
入力、ランナー、実行ファイル、profile、ライブラリが異なる結果は、別の実行条件です。

## 継続的インテグレーション

[Check](../.github/workflows/check.yml)は`main`へのpush、pull request、手動実行で動きます。
固定ライブラリの整合性、ツールの単体テスト110件、metadata 1837件、要求台帳の案／テスト索引、通常oracle付きVerilator 1587件（seed 1／73のruntime 1531・実行時seedなしのcompiler拒否56）と、別条件の明示command-line 17件を検査します。
kirimasim、Ghost、specのみのケースは実行しません。READMEのバッジは現在のCIで、このローカル測定とは別の状態です。
Checkが成功しても、UVMの完全な適合性や全シミュレータの成功を示しません。Nightlyや結果の自動公開はありません。
