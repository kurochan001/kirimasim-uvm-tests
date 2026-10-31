# kirimasim-uvm-tests

[English](README.md)

IEEE 1800.2-2020（UVM）の動作を確かめる、シミュレータ向けの適合性テストスイートです。
[kirimasim](https://github.com/kurochan001/kirimasim)向けに作り、
[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests)（IEEE 1800-2023の言語の適合性）と対になります。
英語版が正本で、この日本語版はその対訳です。

> **状態：M1（中核テストの拡充中）。** テスト133件、固定版UVMの取得、kirimasim・Verilator・
> Ghostのランナー、メタデータ検査、Checkワークフローがあります。M1の条項ごとの完了条件は
> まだ満たしていません。後述の「今回のM1追加分」を参照してください。

## 1. 確かめること

- **対象**：シミュレータがUVMライブラリを実行したとき、IEEE 1800.2-2020が定める結果になるか。
  フェーズの順序、objectionによるフェーズの終了、factoryの置き換え、config_dbの検索、
  シーケンスとシーケンサ、TLMの接続、レジスタ層などです。
- **期待値の根拠**：1800.2-2020の条項。`:lrm:`に記録し、テストの冒頭のコメントで、何を確かめるかを
  自分の言葉で説明します。規格本文は転載しません。
- **ライブラリ**：Accellera版UVMライブラリのリリース2020.3.1を、`third_party/uvm.lock`で固定して使います
  （「UVMライブラリ」を参照）。配布物の`DEVIATIONS.md`には、ライブラリが規格と異なる箇所が3件あります
  （18.2.3.4、18.4.3.6、13.1.5.1）。期待値はこれらに依存させず、触れざるをえないテストは差異として記録します。
- **範囲外**：SystemVerilogの言語そのもの（kirimasim-testsで扱う）、UVMの教材、性能、
  レジスタモデルの生成ツール、ベンダー固有の拡張。

## 2. kirimasim-testsとの関係

| | kirimasim-tests | kirimasim-uvm-tests |
| --- | --- | --- |
| 規格 | IEEE 1800-2023 | IEEE 1800.2-2020（実行の意味は1800-2023の言語に従う） |
| 外部依存 | なし（小さな独立した設計） | UVMライブラリ（版と指紋で固定） |
| 配置 | `tests/chNN/`（1800-2023の章） | `tests/uNN/`（1800.2の章） |
| 固定版のoracle | Icarus Verilog 13.0、Verilator 5.052 | 再現できる範囲でVerilator 5.052（5を参照） |
| 判定ツール | 元になる実装 | 固定コミットから写す（`tools/UPSTREAM`） |
| CI | 独自 | 独自（テストごとにUVMをコンパイルするため重い） |

UVMのテストが言語機能（クラス、パラメータ化クラス、制約、プロセス制御など）の不具合で失敗したら、
その最小例をkirimasim-testsに言語のテストとして追加します。UVMのスイートは、
言語のテストの不足を見つける役も担います。

## 3. ディレクトリ構成

```text
tests/uNN/<name>.sv          メタデータ付きのテスト（NNは1800.2の章：u05〜u19）
tests/uNN/<name>.expected    期待する観測行
tests/uB/ … tests/uH/        付録：B マクロ、C 設定とリソース、D 補助のクラスと
                             インタフェース、E レジスタの試験シーケンス、
                             F パッケージ範囲の機能、G コマンドライン、H 非推奨
third_party/uvm.lock         固定したライブラリ：リリース、取得元、コミット、指紋
third_party/uvm/<version>/   ライブラリ本体（取得するもので、コミットしない）
tools/fetch_uvm.py           ライブラリを取得し、指紋を確かめる
tools/uvm_common.py          ライブラリと一緒にコンパイルする方法、観測する行
tools/run_kirimasim.py       kirimasimのランナー
tools/run_verilator.py       Verilatorのランナー
tools/run_ghost.py           非公開プロファイルを使うGhostのランナー
tools/suite_results.py       判定と結果JSON（kirimasim-testsから写したもの）
tools/lint_metadata.py       メタデータとテストの形式の検査
tools/clauses_1800_2.txt     1800.2-2020の条項番号（番号だけ）
tools/UPSTREAM               写したツールの元と、変えた点
```

## 4. テストの形式

### 4.1 例

```systemverilog
/*
:name: test_common_phases_run_in_order
:description: the common phases run in their order, ... (IEEE 1800.2-2020 Section 9.8.1)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.8.1 9.5 9.6 9.7 10.5.1
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +UVM_TESTNAME=t
:expected_stdout: @test_common_phases_run_in_order.expected
*/
```

### 4.2 メタデータ

kirimasim-testsとsv-testsの形式を引き継ぎ、次の点を変えます。

| フィールド | 意味 |
| --- | --- |
| `:lrm:` | `1800.2-2020 <条項>`。言語の規則にも依存するテストは、その後に`1800-2023 <条項>`を足す。1800.2の最初の条項がディレクトリを決める |
| `:tags:` | 章のディレクトリ`uNN`と`uvm`（sv-testsがUVMのテストに付けるタグ） |
| `:uvm:` | テストが前提にするライブラリのリリース。固定したものと同じでなければならない |
| `:uvm_dpi:` | `yes`ならライブラリのDPI（正規表現、HDLバックドア）を使う。6.2を参照 |
| `:uvm_defines:` | ライブラリに渡すマクロ（例：`UVM_ENABLE_DEPRECATED_API`） |
| `:args:` | `+UVM_TESTNAME=…`などの実行時引数 |

`:oracle:`・`:spec_check:`・`:fourstate:`・`:nondeterministic:`・`:should_fail_because:`・
`:expected_stderr_regex:`・`:expected_exit:`・`:files:`・`:defines:`・`:incdirs:`・`:top_module:`の意味は
kirimasim-testsと同じです。

### 4.3 何を観測するか

1800.2が定めるのは、レポートを組み立てるメソッドの役割までで、出来上がる文字列ではありません。
`compose_report_message`（6.5.1.2.15）は重大度・コンポーネント名・ID・メッセージから文字列を作りますが、
`UVM_INFO file(line) @ time: name [id] msg`という並びはライブラリが決めています。
ファイル名、行番号、時刻の書式も、ライブラリとシミュレータで変わります。そこで次のようにします。

- **既定のレポート行は比べない。**
- **テストは、観測した値を`UT: `で始まる行に`$display`で出す。** 出すのは規格が定める値だけです
  （フェーズの順序、件数、読み戻した値、比較の結果など）。期待出力と比べるのはこの行だけです。
  レポートの仕組みが壊れていても、他の章のテストが巻き込まれずに済みます。
- **レポートの件数は値で読む。** report serverの`get_severity_count`・`get_id_count`で読み、
  `UT: `の行に出します。
- **6章（レポート）のテスト**は、独自のreport serverやreport catcherを使い、規格が定める入力
  （重大度、ID、冗長度、動作）と結果の対応を`UT: `の行で確かめます。
- 規格が定めないものに依存しません。乱数の値、同時に始まるプロセスの順序、
  規格が定める以外の自動生成名などです。

## 5. 期待出力の決め方

1. 引用した条項から期待出力を決めます（`:oracle: spec`）。
2. ライブラリのソース（Apache-2.0）は、規格の記述を理解するために読んでかまいません。
   ただし期待出力は規格から決めます。ライブラリと規格が異なる箇所は`DEVIATIONS.md`と照らして記録し、
   その箇所に依存するテストは作りません。
3. 固定版での再現：
   - Verilator 5.052は、`UVM_NO_DPI`でライブラリをビルドして実行できます。x・zに依存せず、
     seed 1と73の両方で再現したテストには、kirimasim-testsと同じく`verilator@5.052`を付けます。
   - Icarus Verilog 13.0はUVMを実行できないので使いません。
4. シミュレータと期待出力が食い違っても、出力を写して解決しません。判断するのは条項です。

## 6. UVMライブラリ

### 6.1 取得

`python3 tools/fetch_uvm.py`は、`third_party/uvm.lock`が名指すリリースを
[accellera-official/uvm-core](https://github.com/accellera-official/uvm-core)
（タグ`2020.3.1`、コミット`78c06547a2a0`）から取得して`third_party/uvm/2020.3.1/`に置き、
展開したファイルの指紋（326ファイルそれぞれのパスとSHA-256）を確かめます。
取得先が圧縮し直すことがあるので、アーカイブ自体の指紋は使いません。
`--check`は、置いてあるコピーだけを確かめます。ライブラリはコミットしません。

### 6.2 コンパイル

- 各ランナーは、テストのソースの前に`+incdir+<library>/src`と`<library>/src/uvm_pkg.sv`を渡します。
- テストが`:uvm_dpi: yes`としない限り`UVM_NO_DPI`を定義します。ライブラリのHDLバックドア用のDPIは、
  商用シミュレータ3種向けの実装しか持たないためです。DPIなしのライブラリは、`+UVM_TESTNAME`を自分で読み、
  名前の照合を正規表現ではなくglobで行い、コンポーネント名を検査しません。
  `UVM_NO_DPI`のサポートを削除するかもしれない、という警告も出します。
  正規表現やバックドアに依存するテストは`:uvm_dpi: yes`とし、DPIを読み込めるシミュレータでだけ実行します
  （`UVM_HDL_NO_DPI`ならバックドアだけを外せます）。
- 非推奨のAPI（付録H、ライブラリの`deprecated/`）は`UVM_ENABLE_DEPRECATED_API`で取り込みます。
  使うのは`tests/uH/`のテストだけです。

## 7. スイートの実行

```sh
python3 tools/fetch_uvm.py
python3 tools/run_kirimasim.py --kirimasim /path/to/kirimasim -j 8 --json out/kirimasim.json
python3 tools/run_verilator.py --all --seed 1 -j 2 --json out/verilator-1.json
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 2 --json out/verilator.json
```

ランナーにはPython 3.10以降が必要です。結果のJSONはkirimasim-testsと同じ形
（`tools/suite_results.py`）なので、履歴やレポートのツールでそのまま読めます。
`run_verilator.py`はテストごとにUVMパッケージ全体をビルドします。8コアで30秒ほどかかります
（`--build-jobs`、既定はすべてのハードウェアスレッド）。ccacheは使いません。Verilatorは大きなモデルを
事前コンパイル済みヘッダーでビルドし、そこにビルド先の絶対パスが入るので、ccacheが別の場所で作った
ヘッダーを返すとビルドが壊れるためです。

`--seeds 1 73`は各モデルを一度だけビルドし、seedごとに新しいプロセスで実行します。
すべてのseedで一致した場合だけ成功です。従来の`--seed N`も使えます。
結果JSONのconfigurationには、指定に応じて`seed`か`seeds`を記録します。

### Ghost

```sh
python3 tools/run_ghost.py --simulator /path/to/private/simulator \
  --profile /path/to/private-profile.json -j 2 --json out/ghost.json
```

非公開のJSONプロファイルに`arguments`（文字列の配列）、`environment`（文字列の対応表）、
`uvm_mode`を明示します。

- `pinned`：固定版UVMをテストより先にコンパイルします。同梱UVMの自動読み込みは
  プロファイル側で無効にします。
- `bundled`：UVMの供給をプロファイルとシミュレータに任せ、別のパッケージをコンパイルしません。
  共通の規格期待値と比較しますが、**固定版ライブラリの実行証拠にはしません**。
  テストの`:uvm:`から同梱ライブラリの版を推測しません。

同梱モードのプロファイルには、ソースとヘッダーを含む非公開ディレクトリ`uvm_library_dir`も
指定し、実行引数で同じライブラリを選びます。コードもヘッダーも実行ファイル内に組み込まれて
いる場合だけ、代わりに`uvm_embedded: true`を指定します。この2通りのどちらかが必要です。
ディレクトリのパスは結果に書きません。

公開JSONには`uvm_source`、`uvm_pinned`、テストが前提にする版（`test_uvm`）、実行ファイルと
プロファイルのSHA-256を記録します。固定版とディレクトリに置かれた同梱版では、ライブラリの
内容の指紋とファイル数も記録します。
シミュレータの名前・版・パス、プロファイルの内容、診断は公開しません。
実行中に実行ファイル・プロファイル・ライブラリが変わったら、結果を書きません。
固定版モードでは、実行前にライブラリの内容がlockと一致することも確かめます。

最初のM1の同梱UVMでの実行はseed 1・73とも18/27件が一致し、同じ9件で不一致になりました。
同じ実行ファイルでの固定版UVMのスモークテストは、前処理を有効にした場合も不一致でした。
これらは失敗として記録し、期待値は変えません。原因がシミュレータと同梱ライブラリのどちらに
あるかは、この結果だけでは決めません。
2回目のM1追加後は、同梱UVMで両seedとも31/61件が一致し、同じ30件で不一致になりました。
3回目の追加後は、両seedとも41/101件が一致し、同じ60件で不一致になりました。
4回目の追加後は、両seedとも45/133件が一致し、同じ88件で不一致になっています。

| シミュレータ | 現在の状態 |
| --- | --- |
| kirimasim | ローカルの実行ファイルでは133件とも`uvm_object_wrapper`未実装でUNSUPPORTED |
| Verilator 5.052 | `UVM_NO_DPI`で130件がseed 1・73とも一致。specのみの3件は既知の差分として保持 |
| Ghost（kirimasim-testsと同じく、公開前のシミュレータ） | 同梱UVMでは両seedとも45/133件一致。固定版UVMのスモークテストは不一致 |
| Icarus Verilog 13.0 | 使わない。UVMを実行できない |

## 8. 検査

```sh
python3 tools/fetch_uvm.py --check
python3 -m unittest discover -s tools -p 'test_*.py'
python3 tools/lint_metadata.py
```

`.github/workflows/check.yml`は、これらと、Verilator 5.052で記録したテストをseed 1・73で実行します。
複数seedのランナーを使い、この2回の実行には各テストのビルドを一度だけ行います。

## 9. 進め方

| 段階 | 内容 | 完了の目安 |
| --- | --- | --- |
| M0 | 骨組み：取得ツール、kirimasimとVerilatorのランナー、検査、Check、スモークテスト1件 | Checkが通り、両ランナーが結果JSONを出す |
| M1 | 中核：基本クラス（5）、ポリシー（16：copy・compare・print・pack）、factory（8）、フェーズ（9）、objection（10.5）、config_db（C.4）、レポートの件数（6）。Ghostのランナー | 各条項に2件以上 |
| M2 | シーケンス、シーケンサ、TLM（12〜15）、コールバック（10.7、付録D） | 同上 |
| M3 | レジスタ層（17〜19、付録E）。ライブラリの差異3件を避ける | 同上 |
| M4 | 1800.2の要求台帳とカバレッジ（kirimasim-testsと同じ仕組み） | 分母の承認 |

### 今回のM1追加分

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
以前の101件には同じ寿命指定の確認が残っており、M1の残作業です。
再現件数だけで初期化順序の移植性を確認したとは扱いません。

2〜4回目の追加では、固定版ライブラリ自身の`DEVIATIONS.md`以外にも、7件の制約を確認しました。

- `find_override_by_name`は、置換がない場合に`null`を返します。元の型を生成できる場合も
  同じです。8.3.1.7.1は生成されるオブジェクトのwrapperを返すAPIとして説明しています。
  新しい検索テストでは置換を明示し、別名テストでは生成されたオブジェクトの型を検査します。
- config_dbの既定の実装はフィールド名を文字列の一致で検索するため、設定したフィールド名の
  globがC.4.2.2.1の説明どおりに名前を選択しません。新しいglobテストはフィールド名を固定し、
  スコープのパターンを確かめます。
- fieldマクロで入れ子をcopyすると、UVM_SHALLOWでも別のオブジェクトが作られます。
  16.6.3は入れ子を参照として扱う動作を説明しています。追加分ではdeep copyと、copyフックから
  見えるcopierの設定・処理中のオブジェクトを確かめます。
- 5.3.14.3の`uvm_object::get_active_policy`がありません。フックのテストは16.1.3のAPIで
  copier側の処理中オブジェクトのスタックを観測します。
- `uvm_field_op::user_hook_enabled`は`set`前と`flush`直後の呼び出しを拒否します。
  5.7.2.7にはこの制限がありません。field_opの再利用テストは、flush後も含め、
  `set`した後で有効値を確認します。
- `get_objectors`は、件数がゼロになったソースもdrainの後処理まで一覧に残します。
  10.5.1.5.1は現在objectionを保持しているソースの一覧を説明しています。
  drop直後の一覧テストは、規格の期待値を変えずにspecのみのテストとして保持します。
- `uvm_transaction::is_active`は生成直後に1を返しますが、5.4.2.12は最初のbegin前を0と定めています。
  生成直後の非active状態をspecのみのテストとして保持します。一致するライフサイクルのテストは、
  begin・end後のactive状態を検査します。

これらの分岐は、固定版で再現したオラクルとしては扱いません。drop直後の一覧とtransactionの
生成直後の状態は診断用に保持し、残りのライブラリの制約は一致するテストシナリオでは避けています。

`verilator@5.052`を付けたテストは130件、specのみのテストは3件です。
別のspecのみのケースは9.6を検証します。pre-resetフェーズ終了時に子タスクが停止する
はずですが、固定版UVMとVerilator 5.052の組み合わせでは、後のフェーズで子タスクの遅延書き込みが
実行されます。この差分の原因がシミュレータとライブラリのどちらかは未確定です。

specのみの3件も、規格から導いた期待値を保持します。通常のVerilator実行とCIはタグのある
130件を選びます。`--all`を明示するとspecのみの3件も実行し、`known`として記録します。
ランナーは各テストで最初に不一致になったseedで停止するため、この3件の現在のVerilator記録は
seed 1の不一致を示し、seed 73の実行結果は示しません。

引用した動作と期待値はIEEE 1800.2-2020の本文と照合しています。とくにcloneは、実装固有の
生成・copyの呼び出し順に依存せず、独立した複製という結果を観測します。
照合に使う規格PDFはローカルに置き、Gitの追跡対象から外しています。

この追加分だけではM1完了ではありません。残りの条項の各2件という目標が残っています。
Ghostの差分は別途調査するために残します。`:spec_check: ai`は、人によるレビュー済みや
要求の網羅を意味しません。
M4のカバレッジ分母の承認は別の段階です。

ライブラリのソースには、実装する1800.2の条項を示す注記（`@uvm-ieee 1800.2-2020 auto <条項>`）が
約1,760か所あります。APIの棚卸しの手がかりになりますが、ライブラリ側の対応付けなので、
要求の登録はレビューを通してから行います。

## 10. 権利と出典

- 1800.2の本文・図・サンプルコードは転載しません。条項番号を引用し、自分の言葉で説明します。
- UVMライブラリはApache-2.0です。取得するもので、コミットしません。
  コミットする場合は、`LICENSE.txt`と`NOTICE.txt`を一緒に置きます。
- GPL・LGPLのシミュレータ（Icarus Verilog、Verilator）の実装ソースは読みません。
- 公開前のシミュレータの名前、版、実行プロファイル、パスは公開しません。

## ライセンス

Apache License 2.0 with LLVM Exceptions（`Apache-2.0 WITH LLVM-exception`）。
[LICENSE](LICENSE)を参照してください。
