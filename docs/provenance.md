# Repository relationship and source provenance

[日本語](provenance.ja.md) · [README](../README.md) · [Testing guide](testing.md)

This page records related-repository conventions, copied code and original
suite code. Current execution results are in [results](results.md), while
increment narratives are in [history](history.md).

## Relation to kirimasim-tests

| | kirimasim-tests | kirimasim-uvm-tests |
| --- | --- | --- |
| Standard | IEEE 1800-2023 | IEEE 1800.2-2020, run by the language of 1800-2023 |
| External dependency | none (small, self-contained designs) | the UVM library, pinned by version and digest |
| Layout | `tests/chNN/`, chapters of 1800-2023 | `tests/uNN/`, chapters of 1800.2 |
| Fixed-release oracles | Icarus Verilog 13.0, Verilator 5.052 | Verilator 5.052 where it reproduces |
| Shared judgment/result JSON | the original | `suite_results.py` copied from a fixed commit; runners are original suite code ([`tools/UPSTREAM`](../tools/UPSTREAM)) |
| CI | its own | its own, as compiling UVM for every test is slow |

When a UVM test fails because of a language feature (classes, parameterized
classes, constraints, process control and so on), the minimal case goes to
kirimasim-tests as a language test. The UVM suite thus also finds what the
language tests are missing.

## Shared judgment and result code

`tools/suite_results.py` comes from
[kirimasim-tests at 19034b575e1b715c356660ac1422b45f25c15ab3](https://github.com/kurochan001/kirimasim-tests/blob/19034b575e1b715c356660ac1422b45f25c15ab3/tools/suite_results.py),
with these changes:

- `SIMULATORS` lists `kirimasim`, `verilator` and `ghost`.
- `input_files()` also hashes `third_party/uvm.lock`, which identifies the
  library compiled with each pinned-library test.
- `runner_digest()` hashes `tools/uvm_common.py` rather than
  `normalize_output.py`, which this suite does not use.
- The module docstring identifies the source.

## Original suite tools

The runners (`run_*.py`) and `lint_metadata.py` were written for this suite
using the kirimasim-tests tools as a model; they are not copies.
`sv_lifetimes.py` and its regression tests are also original suite code.
That helper lexically checks explicit lifetimes on initialized block locals;
it is not copied from a simulator parser or the language standard.

If the two repositories' judgment rules drift, a shared package is the
planned way to centralize them. [tools/UPSTREAM](../tools/UPSTREAM) is the
bilingual pointer to this source record.

## Library and standards

The external Accellera UVM library is fetched and checked using
[uvm.lock](../third_party/uvm.lock), not committed. Its license is Apache-2.0;
its own `LICENSE.txt` and `NOTICE.txt` accompany it if the library is ever
committed. The repository's original license text is [LICENSE](../LICENSE),
with a complete [Japanese reference translation](../LICENSE.ja.md).

IEEE clauses are cited and described in our own words; standard text,
figures and example code are not copied into tests or documentation.
GPL/LGPL simulator implementation source is not read. Private simulator
identity, version, profile and paths are not published. The
[testing guide](testing.md#rights-and-sources) records these contribution rules.

## Issue reporting policy and form

The commercial-result policy follows the FAQ and the bilingual reporting form
in [kirimasim-tests](https://github.com/kurochan001/kirimasim-tests). The
[upstream form](https://github.com/kurochan001/kirimasim-tests/blob/0ca2ff7c922a257b1db681e96352a169625ebb9b/.github/ISSUE_TEMPLATE/report.yml)
was adapted to IEEE 1800.2-2020, this repository's permitted runners and local
policy links. The required confirmation and disabled blank-issue chooser are
retained. See the [local policy](faq.md#commercial-simulator-and-issue-reporting-policy)
and [form](../.github/ISSUE_TEMPLATE/report.yml).
