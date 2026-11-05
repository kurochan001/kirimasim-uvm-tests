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

`requirements.py` and its regression tests are original suite code. The
[ledger data](requirements.md) uses original bilingual paraphrases of the
user-provided standard, with clause numbers and expected-output anchors.
It does not copy normative text or sample code, or import simulator results.

`run_verilator_hdl.py`, its regression tests and `uvm_hdl_vpi.cpp` are original
suite code. The runner follows the existing suite's compilation/judgment flow
under a distinct evidence identity. The limited backend uses standard DPI/VPI
interfaces and actual simulator handles; it is not copied from a commercial
overlay or a simulator implementation. Public [VPI documentation](https://verilator.org/guide/latest/connecting.html#verification-procedural-interface-vpi)
informs integration; the user-provided IEEE clauses define expected behavior.

The [command-line runner](../tools/run_verilator_cmdline.py) and
[VPI argument bridge](../tools/cmdline_backend/uvm_cmdline_vpi.cpp) are original
suite code. They use standard VPI process information and the public
[VPI interface documentation](https://verilator.org/guide/latest/connecting.html#verification-procedural-interface-vpi).
The [regex wrapper](../tools/cmdline_backend/uvm_cmdline_regex.cpp) compiles the
existing Apache-2.0 regex source from the [locked library](../third_party/uvm.lock);
it does not copy that implementation into tracked sources. The
[portable header](../tools/cmdline_backend/malloc.h) supplies standard allocation
declarations. Expectations remain independent IEEE-derived observations.
No simulator implementation or commercial overlay supplies the oracle.

The memory-walk oracle has an explicit AI interpretation using the
[official UVM 1.2 class reference, 27.7](https://accellera.org/images/downloads/standards/uvm/UVM_Class_Reference_Manual_1.2.pdf#page=739).
Its role and limits are recorded in [Q134](faq.md#q134-how-is-the-memory-walk-algorithm-interpreted).
The independently written observer is not copied pseudocode or an
implementation-derived oracle. Historical context does not amend IEEE 1800.2.

The reviewed historical PDF has SHA-256 `87117e30e17701a13434f785687d3776e710e13c74475b6ada4e7823244ea87a`.
Section 27.7 appears on printed page 730 / PDF page 739. The PDF and rendered
pages remain local and are not committed.

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

FIFO expectations were written from IEEE before measurement. The locked
Apache-2.0 UVM was then read only to diagnose null-field stops and its additional
build initializer. Two original helper variants keep listed-API and explicitly
initialized conditions separate. The extra call supplies a control premise;
its implementation does not define any expected FIFO algorithm or replace a
direct duty. No GPL/LGPL simulator implementation source is used.

Core-service expectations were derived before measurement. Pinned Apache-2.0
source diagnosis identified its additional pure phase-hopper hook. The original
listed-only input remains unchanged; separate original control bodies supply
the hook. Each negative declaration also supplies it to isolate one printed
omission. No extra IEEE prerequisite or builtin oracle is derived from that
source. The initial root fixture's abstract construction is corrected separately.

Field expectations are original observations derived from the supplied IEEE
type/shape, flag, copy and comparison contracts. Literal collection-T inputs
remain separate from element-enum controls. Explicit-UNPACK control and the
unchanged PACK-only premise likewise retain distinct identities. Passing
roundtrips do not invent a universal stream layout or prove every direction.

## Clause catalog maintenance

The identifier-only [clause catalog](../tools/clauses_1800_2.txt) now includes
B.2.1.2, B.2.1.3 and D.2.2.3. Their wrapped headings were missing from the
prior catalog and were checked manually against the user-provided IEEE
1800.2-2020 standard. Restoring them changes the census from 2,504 to 2,507
identifiers and adds three candidates before decomposition. A scan of
numbered-heading-shaped lines in the local extracted text found no further
unmatched identifiers in the selected roots. That scan is not a completeness
certificate: it does not find every normative obligation or assess unnumbered
content. No standard text is redistributed.

## Issue reporting policy and form

The commercial-result policy follows the FAQ and the bilingual reporting form
in [kirimasim-tests](https://github.com/kurochan001/kirimasim-tests). The
[upstream form](https://github.com/kurochan001/kirimasim-tests/blob/0ca2ff7c922a257b1db681e96352a169625ebb9b/.github/ISSUE_TEMPLATE/report.yml)
was adapted to IEEE 1800.2-2020, this repository's permitted runners and local
policy links. The required confirmation and disabled blank-issue chooser are
retained. See the [local policy](faq.md#commercial-simulator-and-issue-reporting-policy)
and [form](../.github/ISSUE_TEMPLATE/report.yml).
