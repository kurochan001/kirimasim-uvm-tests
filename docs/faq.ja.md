# FAQ

[English](faq.md) · [README](../README.ja.md) · [用語集](glossary.ja.md)

現在のランナーの動作を説明します。件数と測定範囲は[README](../README.ja.md#現在の実行結果)、
個別の制約は[既知差分](known-differences.ja.md)にまとめています。

## 最初の実行

### Q1. kirimasim-testsとの違いは何ですか

kirimasim-testsはIEEE 1800-2023のSystemVerilog言語を検査します。
こちらはシミュレータが固定版UVMライブラリを実行したときの動作をIEEE 1800.2-2020と照合します。
UVMの不一致を言語だけで再現できる最小例はkirimasim-testsに置きます。
UVMの不一致にはシミュレータ・ライブラリ・テストそれぞれの可能性があります。

### Q2. 必要な環境とUVMの取得元は何ですか

Python 3.10以降と、UVMを実行できるシミュレータが必要です。固定版のoracleはVerilator 5.052です。
モデルのビルドにはC++ツールチェーンとmakeも必要です。
Ubuntuでの準備は[Checkのworkflow](../.github/workflows/check.yml)にあります。

`python3 tools/fetch_uvm.py`で、lockに指定したAccellera UVMを取得します。
`python3 tools/fetch_uvm.py --check`は取得済みのファイル数と内容の指紋を照合します。
ライブラリは取得するもので、このリポジトリにはコミットしません。

### Q3. まず1件だけ動かすにはどうしますか

Verilator 5.052をPATHに置き、リポジトリのrootから実行します。

```sh
python3 tools/fetch_uvm.py
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 1 \
  --json out/verilator-smoke.json tests/u09/test_common_phases_run_in_order.sv
```

`--seeds`は複数の値を受け取るため、例のようにseedの後、テストのパスより前に`--build-jobs`などの
optionを置きます。パスを明示した場合は、そのテストだけが対象です。これは全件実行ではなくスモークテストです。

### Q4. specのみのテストも含めるにはどうしますか

パスを指定しないVerilator実行は、X・Zに依存せず`verilator@5.052`のタグがあるテストを選びます。
すべての2値のテストを含めるには`--all`を付けます。

```sh
python3 tools/run_verilator.py --all --seeds 1 73 --build-jobs 2 -j 2 \
  --json out/verilator-all.json
```

kirimasimとGhostは既定で全件を選びます。`--all`はVerilatorランナーのoptionで、他のランナーの共通optionではありません。

## 結果の読み方

### Q5. pass・fail・known・unsupportedはどう違いますか

- `pass`：期待出力と、指定された終了・診断の条件が一致した結果です。
- `fail`：出力などの条件が合わない、またはビルド・実行できなかった結果です。
- `known`：このVerilatorランナーではoracleタグのないテストの不一致です。成功ではありません。
- `unsupported`：kirimasimが未対応と示す所定の診断を返した結果です。それ以外のコンパイル失敗は`fail`になる場合もあります。

Ghostの不一致は、同梱ライブラリの差も含めて`fail`として記録します。
失敗したテスト数を、そのまま異なる不具合の個数と解釈しないでください。

### Q6. KNOWNがあるのにVerilatorコマンドが成功するのはなぜですか

終了コードは、固定版oracleタグ付きのテストの回帰を検出するためのものです。
タグのないテストの不一致はJSONに`known`として記録し、コマンドを失敗させません。
タグがなくても一致すればJSONでは`pass`ですが、端末のoracle付きテストの分母には含めず、
タグも自動では追加しません。kirimasimは`fail`・`unsupported`、Ghostは`fail`があれば失敗終了します。
終了コードだけでなく、JSONの分類も確認してください。

### Q7. なぜUVMの全メッセージを比較せずUT行だけを比べるのですか

UVMの既定の表示形式・パス・行番号・時刻の形式は変わり得ます。
ランナーは行頭が正確に`UT: `で始まる行だけを選び、順序・空白・値を保持して比較します。
テストはreport件数など、規格が定める動作をこの行で観測し、必要なら終了・診断の条件も指定します。
[何を観測するか](../README.ja.md#何を観測するか)を参照してください。

必須のUVMエラーを起こす操作を意図的に行い、その件数を確認するテストもあります。
そのエラーだけで失敗にはならず、要求する観測結果と終了条件で判定します。

### Q8. specのみの期待値をライブラリの出力に合わせないのはなぜですか

期待値の根拠は規格で、ライブラリやシミュレータの差によって変更しません。
現在はtransactionの初期状態、無効なfield_opのアクセス、report reset、objector一覧、
応答の制御、USER arbitrationなどをspecのみで保持しています。
phaseの子タスク終了の差分は、シミュレータとライブラリのどちらが原因か未確定です。
対象範囲とテストへのリンクは[既知差分](known-differences.ja.md)にあります。

### Q9. Checkが緑ならkirimasimでもUVMが成功したということですか

[Check](../.github/workflows/check.yml)はメタデータ・ツール・固定版ライブラリ・Verilatorのoracleを検査します。
kirimasim・Ghostは実行せず、specのみの一致も成功条件にはしていません。
確認したkirimasimの実行ファイルでは、全件が`uvm_object_wrapper`未実装で停止します。
その共通のコンパイル依存より後の動作を検査できた結果ではありません。

### Q10. Nightlyや公開の結果ダッシュボードはどこにありますか

このリポジトリには、現在Nightlyや結果の自動公開はありません。バッジはCheckとライセンスへリンクします。
kirimasim-testsには独自のNightlyがありますが、こちらのUVMスイートの結果ではありません。
`out/`のJSONは明示的に共有するまではローカルのもので、テストをpushしても自動では公開しません。

## 実行条件

### Q11. Ghostの結果は何を確認し、なぜ仮名なのですか

Ghostは公開前のシミュレータの仮名です。実行ファイルの識別情報・版・パス・profile・診断は非公開にし、
公開JSONには一般化した理由と内容の指紋を使います。

`pinned`は固定版ライブラリをコンパイルし、profile側で同梱UVMの自動読み込みを無効にします。
`bundled`はprofileがライブラリを供給し、そのtreeの指紋または実行ファイルへの組み込みを明示します。
同梱版の結果は固定版で動かした証拠にはならず、不一致だけでシミュレータとライブラリのどちらが原因かも決まりません。
[Ghostの設定](../README.ja.md#ghost)を参照してください。

### Q12. uvm_dpi: yesだけでDPIを使うビルドが完成しますか

既定のマクロ一覧から`UVM_NO_DPI`を外す指定です。UVMのC/C++実装の供給・リンクは行いません。
現在のVerilatorランナーはそのソースを追加しません。現在の全テストは`UVM_NO_DPI`を使っており、
DPIに依存するテストを実行証拠にするには、対応する実装と実行環境が必要です。
DPIなしのglobによる照合も、完全な正規表現への対応とは異なります。

### Q13. ビルドが重い理由と2種類の並列数の違いは何ですか

各テストのモデルにUVMパッケージ全体を含めるためです。`-j`は同時に実行するテスト数、
`--build-jobs`はVerilatorの各C++ビルド内の並列数です。`--seeds`ならビルドは一度で、
seedごとに新しいプロセスを使います。事前コンパイル済みヘッダーにビルド先の絶対パスが入るため、
そのまま別の場所へ再利用できないccacheはランナーのビルド環境で無効にしています。

### Q14. seedを2つ変えれば決定性や4値の動作も証明できますか

できません。seed 1・73は、乱数を使う初期化条件を変えて固定版の期待値を確認するもので、
乱数そのものは表示しません。Verilatorの既定の対象からはX・Zに依存するテストを除きます。
2値の実行は4値の動作の確認にはならず、2つのseedの成功ですべての実行の正しさも示せません。
複数seedのテストは最初の不一致で止まるため、現在の既知差分はseed 1の差分で、seed 73の結果ではありません。

### Q15. 過去の結果を現在も使えるか、どう確認しますか

テスト入力とランナーの指紋、設定、シミュレータの版、ライブラリの識別情報を比較します。
JSONには`inputs_sha256`・`runner_sha256`・`runner_changed`・`configuration`・`generated_at`を記録します。
実行中に入力が変わったテストは、有効な入力指紋の代わりに`inputs_changed`を記録します。
Ghostはさらに実行ファイル・profile・供給されたライブラリの指紋を記録します。
条件が変われば新しい証拠が必要です。同じ条件の結果は出所を残して合算できますが、
全件を一緒に再ビルドしたという意味にはなりません。

## 範囲・照合・修正

### Q16. M1やM2は完了していますか。件数は何の網羅を示しますか

どちらも条項ごとの目標に未達があります。M2を始めてもM1の完了とはしていません。
範囲と残りの作業は[進め方](../README.ja.md#進め方)にあります。
件数はテストの本数で、規格の全要求や組み合わせの棚卸しではありません。
引用条項だけでは要求の網羅は示せず、要求台帳と分母の承認はM4の作業です。

### Q17. spec_check: aiは人によるレビューや証明を意味しますか

AIが引用した規格と期待値を照合した記録です。人によるレビューや全要求の証明ではありません。
現在は全テストがこの値です。固定版シミュレータでの再現は、別の`:oracle:`に記録します。

### Q18. 期待値の誤りはどう報告・修正しますか

テスト、引用した条項、期待する観測、実行条件を特定します。テストに必要な修正と、シミュレータや
ライブラリの差分を分けて扱い、Ghostの非公開情報を守ります。修正後はメタデータとツールを検査し、
固定版のoracleは両seedで再現します。[テストの追加・修正](../README.ja.md#テストの追加修正)を参照してください。

照合に使うIEEEのPDFはローカルに置き、Gitの対象にしません。本文や例を転載せず、自分の言葉で
動作を説明して条項番号を引用します。UVMライブラリはApache-2.0で別に取得します。
このスイートのライセンスはApache-2.0 WITH LLVM-exceptionです。

## lockとnonblocking transport

### Q19. lockとgrabはどう違い、所有者がblockedになることはありますか

lockは通常の要求の仲裁に加わり、grabは先頭に入ります。どちらも、互換性のないlockやgrabが
取得を妨げている間は待ちます。親がlockを持ったままでも、子の所有によって親が一時的に
blockedになる場合があります。`has_lock`と`is_blocked`を別々に確認してください。
入れ子の所有で現在実行できるsequenceは`current_grabber`が示します。

現在のテストは所有、子の解放による復帰、待機中の取得、実際のdriverへのitemの排他を検査します。
先に待っているFIFO要求を追い越さないことと、取得済みitemの完了を待つことの2件は、specのみで保持します。
固定版ライブラリではlockを早く付与してしまうためです。[既知差分](known-differences.ja.md)を参照してください。

### Q20. nonblocking transportはどうやって即時に応答できますか

受理した要求のanalysis通知を同期的に受けたtargetが、その場で応答を計算し、
`nb_transport`から戻る前にresponse put portへ書き込めます。テストはこの経路を公開APIで接続し、
呼び出し後に受理済みの要求を回収して容量を再利用します。

即時完了できない場合の戻り値は0です。期待値では、その出力引数の値や、要求の一部がキューへ
入ったかは指定しません。再実行のテストは`try_get`で残った要求があれば回収し、
その成否自体は検査せず、新しいtransactionを実行します。

### Q21. killされたsequenceのbodyやhookはどうなりますか

実行中のbodyを停止し、状態を`UVM_STOPPED`にして、待っている`start`を復帰させます。
sequencerの要求や所有も後処理します。規格は停止hookの`do_kill`に加えて、`post_body`・`post_start`も
実行するように定めています。固定版はこの2つのpost hookを呼ばないため、sequencerあり・なしの
テストで必須動作をspecのみの期待値として保持します。

自動objectionのdropと、`stop_sequences`後のsequencerの再利用も検査します。
この操作で破棄されたdriver保持中の要求には後から完了通知せず、新しい要求を取り出してから、
その要求について`item_done`を呼びます。

### Q22. default phase sequenceはどう選ばれますか

phase開始時に、sequencerの完全名とphase名のscopeで`default_sequence` resourceを検索します。
例は`uvm_test_top.sequencer.main_phase`です。対象の型は`uvm_sequence_base`と`uvm_object_wrapper`です。
優先度でresourceを選び、選択したnullは無効化を示します。instanceはそのまま使い、wrapperは
sequencerのパスとwrapper型名を生成の文脈にしてfactoryを呼びます。

sequencerと開始phaseを設定し、無効化しない限りrandomizeしてから実行します。
phase終了時も実行中ならkillします。wrapperがsequence以外を生成した場合は、エラーを出して
defaultを開始しません。固定版はwarningだけを出すため、必須エラーをspecのみで保持します。
