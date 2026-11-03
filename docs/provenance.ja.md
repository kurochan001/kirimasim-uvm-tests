# 関連リポジトリとソースの出典

[English](provenance.md) · [README](../README.ja.md) · [テストと開発のガイド](testing.ja.md)

関連リポジトリの規約、取り込んだコード、このスイート独自のコードを記録します。
現在の測定は[実行結果](results.ja.md)、追加作業の経緯は[履歴](history.ja.md)を参照してください。

## kirimasim-testsとの関係

| | kirimasim-tests | kirimasim-uvm-tests |
| --- | --- | --- |
| 規格 | IEEE 1800-2023 | IEEE 1800.2-2020（実行の意味は1800-2023の言語に従う） |
| 外部依存 | なし（小さな独立した設計） | UVMライブラリ（版と指紋で固定） |
| 配置 | `tests/chNN/`（1800-2023の章） | `tests/uNN/`（1800.2の章） |
| 固定版のoracle | Icarus Verilog 13.0、Verilator 5.052 | 再現できる範囲でVerilator 5.052 |
| 共通の判定・結果JSON | 元になる実装 | `suite_results.py`を固定コミットから写す。ランナーはこのスイート独自（[`tools/UPSTREAM`](../tools/UPSTREAM)） |
| CI | 独自 | 独自（テストごとにUVMをコンパイルするため重い） |

UVMのテストが言語機能（クラス、パラメータ化クラス、制約、プロセス制御など）の不具合で失敗したら、
その最小例をkirimasim-testsに言語のテストとして追加します。UVMのスイートは、
言語のテストの不足を見つける役も担います。


## 共通の判定・結果コード

`tools/suite_results.py`は、
[kirimasim-testsの19034b575e1b715c356660ac1422b45f25c15ab3](https://github.com/kurochan001/kirimasim-tests/blob/19034b575e1b715c356660ac1422b45f25c15ab3/tools/suite_results.py)
から取り込み、次を変更しています。

- `SIMULATORS`は`kirimasim`・`verilator`・`ghost`を列挙します。
- `input_files()`は、固定版で各テストと一緒にコンパイルするライブラリを識別する`third_party/uvm.lock`もhash対象にします。
- `runner_digest()`は、このスイートが使わない`normalize_output.py`の代わりに`tools/uvm_common.py`をhash対象にします。
- moduleのdocstringに取得元を記載します。

## このスイート独自のツール

ランナー（`run_*.py`）と`lint_metadata.py`はkirimasim-testsのツールを参考に、このスイート向けに書いたもので、コピーではありません。
`sv_lifetimes.py`とその回帰テストも独自のコードです。このhelperは、初期化付きblock内ローカル変数の寿命の明示を字句的に検査します。
シミュレータのparserや言語規格から写したものではありません。

`requirements.py`と回帰テストは、このスイート独自のコードです。
[台帳のデータ](requirements.ja.md)は、ユーザー提供の規格を独自の日英の言葉で要約し、条項番号と期待出力のanchorを添えます。
規範本文やサンプルコードの転載、シミュレータ結果の取り込みは行いません。

`run_verilator_hdl.py`、その回帰テスト、`uvm_hdl_vpi.cpp`は、本スイート独自のcodeです。
runnerは、既存スイートのcompile／判定の流れを、別のevidence同一性で扱います。
限定backendは、標準DPI／VPI interfaceと実際のsimulator handleを使い、商用overlayやsimulator実装から複製しません。
統合には[公開VPI文書](https://verilator.org/guide/latest/connecting.html#verification-procedural-interface-vpi)を参照し、
期待する動作は、ユーザーが与えたIEEE条項から導きます。

[command-line runner](../tools/run_verilator_cmdline.py)と[VPI引数bridge](../tools/cmdline_backend/uvm_cmdline_vpi.cpp)は独自のsuite codeです。
標準VPIのprocess情報と[公開VPI interface文書](https://verilator.org/guide/latest/connecting.html#verification-procedural-interface-vpi)を使います。
[regex wrapper](../tools/cmdline_backend/uvm_cmdline_regex.cpp)は[固定library](../third_party/uvm.lock)にあるApache-2.0 regex sourceをcompileし、
その実装を追跡sourceへ複製しません。[移植用header](../tools/cmdline_backend/malloc.h)は標準の割当宣言を提供します。
期待値は独立したIEEE由来の観測のままで、simulator実装や商用overlayをoracleに使いません。

memory-walkのoracleは、[公式UVM 1.2 class referenceの27.7](https://accellera.org/images/downloads/standards/uvm/UVM_Class_Reference_Manual_1.2.pdf#page=739)を使うAI解釈を明示します。
役割と制限は[Q134](faq.ja.md#q134-memory-walk-algorithmをどう解釈していますか)に記録します。
独立に書いたobserverは、擬似codeの複製や実装由来のoracleではありません。歴史的な文脈はIEEE 1800.2を改訂しません。

照合した歴史的PDFのSHA-256は`87117e30e17701a13434f785687d3776e710e13c74475b6ada4e7823244ea87a`です。
27.7は印刷page 730／PDF page 739にあります。PDFと描画したpageはlocal資料で、コミットしません。

両リポジトリの判定規則が分岐した場合は、共通packageへ集約する計画です。
[tools/UPSTREAM](../tools/UPSTREAM)は、この出典記録への日英の案内です。

## ライブラリと規格

外部のAccellera UVMライブラリは[uvm.lock](../third_party/uvm.lock)で取得・検査し、コミットしません。
ライセンスはApache-2.0で、コミットする場合はライブラリ自身の`LICENSE.txt`と`NOTICE.txt`を一緒に置きます。
リポジトリのライセンス原文は[LICENSE](../LICENSE)で、全文の[日本語参考訳](../LICENSE.ja.md)を用意します。

IEEEの条項は番号を引用し、自分の言葉で説明します。規格の本文・図・サンプルコードはテストや資料へ転載しません。
GPL／LGPLシミュレータの実装ソースは読みません。非公開シミュレータの識別情報、版、profile、パスは公開しません。
これらの変更時の規則は[テストと開発のガイド](testing.ja.md#権利と出典)にあります。

## 条項カタログの保守

番号だけの[条項カタログ](../tools/clauses_1800_2.txt)へB.2.1.2、B.2.1.3、D.2.2.3を追加しました。
折り返した見出しが以前のcatalogから欠けており、ユーザー提供のIEEE 1800.2-2020規格と手動照合しました。
復元により番号数は2,504から2,507となり、分解前の候補が3件増えます。local抽出textの番号付き見出しらしい行を走査した範囲では、
対象rootでほかの欠落番号は見つかりませんでした。この走査は完全性の証明ではなく、すべての規範的義務を発見したり、
番号のない本文を評価したりするものではありません。規格本文は再配布しません。

## Issueの投稿方針とフォーム

商用結果の方針は[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests)のFAQと日英の報告フォームを踏襲します。
[元のフォーム](https://github.com/kurochan001/kirimasim-tests/blob/0ca2ff7c922a257b1db681e96352a169625ebb9b/.github/ISSUE_TEMPLATE/report.yml)を、
IEEE 1800.2-2020、このリポジトリの確認対象ランナー、ローカルの投稿方針リンクへ合わせました。
必須の確認欄と、空欄Issueを選ばせない設定を維持しています。
[このリポジトリの方針](faq.ja.md#商用シミュレータとissueの投稿方針)と[フォーム](../.github/ISSUE_TEMPLATE/report.yml)を参照してください。
