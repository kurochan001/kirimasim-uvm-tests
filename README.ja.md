# kirimasim-uvm-tests

[English](README.md)

IEEE 1800.2-2020（UVM）の動作を確かめる、シミュレータ向けの適合性テストスイートです。
[kirimasim](https://github.com/kurochan001/kirimasim)向けに作り、
[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests)（IEEE 1800-2023の言語の適合性）と対になります。
英語版が正本で、この日本語版はその対訳です。

> **状態：M0（骨組み）。** テスト1件、固定版のUVMライブラリの取得、kirimasimとVerilatorの
> ランナー、メタデータの検査、Checkワークフローがあります。この後の予定は「進め方」を参照してください。

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
```

ランナーにはPython 3.10以降が必要です。結果のJSONはkirimasim-testsと同じ形
（`tools/suite_results.py`）なので、履歴やレポートのツールでそのまま読めます。
`run_verilator.py`はテストごとにUVMパッケージ全体をビルドします。8コアで30秒ほどかかります
（`--build-jobs`、既定はすべてのハードウェアスレッド）。ccacheは使いません。Verilatorは大きなモデルを
事前コンパイル済みヘッダーでビルドし、そこにビルド先の絶対パスが入るので、ccacheが別の場所で作った
ヘッダーを返すとビルドが壊れるためです。

| シミュレータ | M0での状態 |
| --- | --- |
| kirimasim | 実行できる。ライブラリが未対応（クラスが未実装）と報告される |
| Verilator 5.052 | `UVM_NO_DPI`でライブラリをビルドして実行できる |
| Ghost（kirimasim-testsと同じく、公開前のシミュレータ） | まだ。固定版ではなく同梱のUVMを使うため、比べ方が未定 |
| Icarus Verilog 13.0 | 使わない。UVMを実行できない |

## 8. 検査

```sh
python3 tools/fetch_uvm.py --check
python3 -m unittest discover -s tools -p 'test_*.py'
python3 tools/lint_metadata.py
```

`.github/workflows/check.yml`は、これらと、Verilator 5.052で記録したテストをseed 1・73で実行します。

## 9. 進め方

| 段階 | 内容 | 完了の目安 |
| --- | --- | --- |
| M0 | 骨組み：取得ツール、kirimasimとVerilatorのランナー、検査、Check、スモークテスト1件 | Checkが通り、両ランナーが結果JSONを出す |
| M1 | 中核：基本クラス（5）、ポリシー（16：copy・compare・print・pack）、factory（8）、フェーズ（9）、objection（10.5）、config_db（C.4）、レポートの件数（6）。Ghostのランナー | 各条項に2件以上 |
| M2 | シーケンス、シーケンサ、TLM（12〜15）、コールバック（10.7、付録D） | 同上 |
| M3 | レジスタ層（17〜19、付録E）。ライブラリの差異3件を避ける | 同上 |
| M4 | 1800.2の要求台帳とカバレッジ（kirimasim-testsと同じ仕組み） | 分母の承認 |

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
