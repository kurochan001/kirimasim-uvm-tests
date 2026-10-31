# FAQ

[日本語](faq.ja.md) · [README](../README.md) · [Glossary](glossary.md)

This guide describes the current runners. Counts and measurement scope are
kept in the [README](../README.md#current-results); specific limitations are
in [known differences](known-differences.md).

## Getting started

### Q1. How does this differ from kirimasim-tests?

kirimasim-tests checks SystemVerilog language behavior against IEEE 1800-2023.
This suite checks UVM behavior against IEEE 1800.2-2020 while a simulator runs
the pinned UVM library. A language-only reproduction of a UVM failure belongs
in kirimasim-tests; a UVM mismatch may involve the simulator, library or test.

### Q2. What do I need, and where does UVM come from?

Use Python 3.10 or later and a simulator able to run UVM. The fixed oracle is
Verilator 5.052, whose model builds also require a C++ toolchain and make.
The [Check workflow](../.github/workflows/check.yml) contains its Ubuntu setup.

Run `python3 tools/fetch_uvm.py` to fetch the locked Accellera UVM release.
`python3 tools/fetch_uvm.py --check` verifies the existing tree against its
file count and content digest. The library is fetched, not committed.

### Q3. How can I run one test first?

From the repository root, with Verilator 5.052 on PATH:

```sh
python3 tools/fetch_uvm.py
python3 tools/run_verilator.py --seeds 1 73 --build-jobs 2 -j 1 \
  --json out/verilator-smoke.json tests/u09/test_common_phases_run_in_order.sv
```

Put an option such as `--build-jobs` after the seed list and before a test
path, as shown: `--seeds` accepts multiple values. Explicit paths select only
those tests. This is a smoke test, not a full-suite run.

### Q4. How do I include spec-only cases?

Without paths, Verilator selects tests tagged `verilator@5.052` that do not
depend on X/Z. Add `--all` to include every two-state case:

```sh
python3 tools/run_verilator.py --all --seeds 1 73 --build-jobs 2 -j 2 \
  --json out/verilator-all.json
```

kirimasim and Ghost select all tests by default. `--all` belongs to the
Verilator runner; it is not a shared option for the other runners.

## Understanding a result

### Q5. What do pass, fail, known and unsupported mean?

- `pass`: expected output and specified exit/diagnostic conditions match.
- `fail`: output or another condition differs, or building/running failed.
- `known`: an untagged Verilator test differs or fails to build/run. It is not a pass.
- `unsupported`: kirimasim returns its recognized unsupported-feature diagnostic.
  Other compilation failures can still be `fail`.

Ghost records mismatches as `fail`, including bundled-library differences.
Do not interpret the number of failed tests as the number of distinct bugs.

### Q6. Why can Verilator exit successfully with KNOWN results?

Its exit status tracks regressions in tagged fixed-release oracles. An untagged
mismatch is recorded as `known` in JSON and does not make the command fail.
An untagged match is recorded as `pass`, but remains outside the terminal's
tagged-oracle denominator and does not automatically receive an oracle tag.
kirimasim exits unsuccessfully for either failures or unsupported results;
Ghost does so for failures. Read JSON statuses as well as the command exit code.

### Q7. Why compare UT lines rather than all UVM messages?

Default UVM report layout, paths, line numbers and time formatting vary.
The runner selects only lines beginning exactly with `UT: ` and preserves
their order, spaces and values. Tests expose specified behavior through those
lines, including report counts. They may also specify exit/diagnostic checks.
See [what is observed](../README.md#what-is-observed).

Some tests intentionally request an operation that must report a UVM error,
then check the resulting count. That error alone does not make a test fail;
its required outcome and termination conditions decide the result.

### Q8. Why keep spec-only tests instead of copying the library's output?

The standard determines the expectation. A library or simulator discrepancy
does not redefine it. The current spec-only cases include initial transaction
state, invalid field-operation access, report reset, objector membership,
response controls and USER arbitration. The phase-task termination difference
has not been assigned to either the simulator or library. See
[known differences](known-differences.md) for scope and linked tests.

### Q9. Why does a green Check not mean kirimasim passes UVM?

[Check](../.github/workflows/check.yml) checks metadata, tools, the pinned
library and tagged Verilator oracles. It does not run kirimasim or Ghost and
does not require spec-only cases to match. The tested kirimasim executable
currently stops all cases at `uvm_object_wrapper` as unsupported. Those
results do not establish behavior beyond that common compilation dependency.

### Q10. Where is Nightly or the public results dashboard?

This repository currently has no Nightly workflow or automatic results
publication. Its badges link to Check and the license. kirimasim-tests has its
own Nightly, which does not report this UVM suite. Runner JSON under `out/`
stays local unless deliberately shared; pushing tests does not publish it.

## Execution conditions

### Q11. What does the Ghost result cover, and why an alias?

Ghost is an unreleased simulator participating under an alias. Its executable
identity, version, paths, profiles and diagnostics stay private. Public JSON
uses generic reasons and content fingerprints.

In `pinned` mode, the runner compiles the locked library and the profile
disables automatic bundled UVM. In `bundled` mode, the profile supplies its
library, identified by a tree digest or an embedded-library declaration.
The latter result is not evidence for the pinned library. A bundled mismatch
does not by itself distinguish a simulator problem from a library problem.
See [Ghost setup](../README.md#ghost).

### Q12. Does uvm_dpi: yes automatically enable a working DPI build?

It removes `UVM_NO_DPI` from the default macro list. It does not supply or link
UVM's C/C++ implementation. The current Verilator runner does not add those
sources. All current tests use `UVM_NO_DPI`; a DPI-dependent test needs an
appropriate implementation and execution setup before it can be used as evidence.
Glob matching without DPI is also not the same as full regular-expression support.

### Q13. Why is compilation heavy, and what do the two job options control?

Every test builds the UVM package as part of its model. `-j` controls the number
of concurrent tests; `--build-jobs` controls C++ jobs within each Verilator build.
Using `--seeds` builds once and runs a fresh process for each seed. The runner
disables ccache through the build environment because the model's precompiled
header records an absolute build-directory path and cannot be reused that way.

### Q14. Do two seeds prove determinism or four-state correctness?

No. Seeds 1 and 73 check the fixed-release expectation under different
randomized initialization conditions; tests do not print random values.
Verilator's default selection excludes X/Z-dependent cases. A two-state run
does not establish four-state behavior, and two passing seeds do not prove all
possible executions. A multi-seed test stops at its first mismatch; the current
runtime known records establish seed 1 differences, not seed 73 results for
those cases. A case that cannot build has no runtime seed result.

### Q15. How do I know whether an old result still applies?

Compare test input hashes, runner hashes, configuration, simulator version and
library identity. JSON records `inputs_sha256`, `runner_sha256`,
`runner_changed`, `configuration` and `generated_at`; an input changed during
a run is marked `inputs_changed` instead of receiving a valid input hash.
Ghost additionally fingerprints its executable, profile and supplied library.
Changed inputs or conditions require new evidence; unchanged records can be
combined, while preserving their batch provenance. A combined result is not
a claim that every test was rebuilt together.

## Scope, review and contributions

### Q16. Are M1 or M2 complete, and what does the test count cover?

Both stages still have open clause targets. Starting M2 did not complete M1.
The [plan](../README.md#plan) identifies current scope and remaining work.
Counts are test cases, not a reviewed inventory of every requirement or
combination in the standard. Clause citations alone do not establish coverage;
the requirement ledger and its approved denominator are M4 work.

### Q17. Does spec_check: ai mean human review or proof?

It records AI comparison of the expectation with the cited standard. It is
neither human review nor a proof of full coverage. All current tests have this
value. Fixed-release reproduction is a separate record in `:oracle:`.

### Q18. How should I report or correct a wrong expectation?

Identify the test, cited clause, expected observation and execution conditions.
Separate changes needed in the test from simulator or library discrepancies.
Preserve privacy for Ghost. After a correction, run metadata and tool checks,
then reproduce any fixed-release oracle with both seeds. See
[adding or correcting a test](../README.md#adding-or-correcting-a-test).

The IEEE PDFs used for review remain local and ignored by Git; do not copy
their text or examples into the suite. Describe behavior in your own words
and cite clause numbers. The UVM library is fetched separately under Apache-2.0;
the suite is Apache-2.0 WITH LLVM-exception.

## Locking and nonblocking transport

### Q19. How do lock and grab differ, and can a lock owner be blocked?

Lock joins regular request arbitration; grab enters at the front. Both wait
when an incompatible existing lock or grab prevents acquisition. A child's
ownership can temporarily block its parent even when the parent still owns
a lock. Inspect `is_blocked` as well as `has_lock`; `current_grabber` identifies
the sequence currently allowed to act under nested ownership.

Current tests cover ownership, nested release, waiting acquisitions and real
driver item exclusion. Two lock-order cases retain spec-only expectations:
FIFO order behind an earlier pending item and waiting for an already granted
item's completion. The pinned library grants these locks too early; see
[known differences](known-differences.md).

### Q20. How can nonblocking transport return a response immediately?

A target can compute a response synchronously when the accepted request's
analysis notification is delivered, then write it through the response put
port before `nb_transport` returns. The tests connect this path through public
interfaces and retire the accepted request afterwards so the slot can be reused.

When completion is not immediate, the return value is 0. These expectations
do not prescribe its response output argument or whether a partial request
was queued. The recovery case drains any residual request through `try_get`
before a fresh transaction, without asserting that drain's return value.

### Q21. What happens to a sequence's body and hooks when it is killed?

Kill terminates active body work, changes the state to `UVM_STOPPED` and
releases the waiting `start` call. It also cleans up the sequence's sequencer
requests and ownership. The standard requires the post-body and post-start
hooks as well as the `do_kill` termination hook. The pinned library omits the
two post hooks; bound and unbound tests preserve that required behavior as
spec-only expectations.

Tests check direct-kill automatic-objection drop and sequencer reuse after
`stop_sequences`. The stop operation must drop automatic objections too,
but its pinned root stop path omits the drop. Standalone and parent/child
cases retain that requirement as spec-only; see [known differences](known-differences.md).
A driver-held request flushed by that operation is not
acknowledged afterwards; the test retrieves a new request before calling
`item_done` for it.

### Q22. How is a default phase sequence selected?

At phase start, the sequencer looks up `default_sequence` resources at its
full path plus the phase name, such as `uvm_test_top.sequencer.main_phase`.
Relevant resource types are `uvm_sequence_base` and `uvm_object_wrapper`.
Precedence selects the resource; a selected null disables the default.
An instance is used directly, while a wrapper uses the factory with the
sequencer path and wrapper type name as its creation context.

The sequence receives its sequencer and starting phase, is randomized unless
disabled and is killed if it outlives the phase. A wrapper creating a
non-sequence must report an error and start no default. The pinned library
only warns in that case, so the required error is retained as spec-only.

### Q23. What should happen to a response sent after its sequence finishes or stops?

`put_response` must drop it and report a warning when the original sequence
is `UVM_FINISHED` or `UVM_STOPPED`. Tests copy IDs from real requests, then
retire the sequence and check both the warning and non-delivery. Queue probes
use a bounded wait; handler probes verify no callback. A killed sequence must
not prevent another active sequence from receiving its own response.

A transaction ID is not the whole routing identity. Reusing it in a new
sequence must not let a stale response from the stopped sequence contaminate
the fresh route. These checks concern late delivery, not every possible aspect
of clearing replies that were already delivered before stop.

### Q24. Does a specific default-sequence instance always outrank a wrapper?

No. First keep only `uvm_sequence_base` and `uvm_object_wrapper` resources,
then choose highest precedence. For a tie, choose the first remaining entry
in the lookup queue. Removing wrong-type resources must preserve the relative
order of the valid entries. An unrelated null `uvm_object` resource is filtered;
only a selected null of an accepted resource type disables the default.

The equal-precedence tests create separate resources and insert them through
the public pool API with low priority, in explicit order. They do not infer
that order from repeated `config_db::set` calls that may update one setting.

### Q25. Does a TLM delay annotation advance simulation time?

The annotation object carries an offset; changing it does not wait. A target
can add an annotation and return in the same simulation time slot, or explicitly
wait as part of a blocking implementation. Tests observe annotation values and
simulation-time equality separately. Absolute conversion uses an explicit
seconds-per-unit argument. Scaled operations use the matching time literal;
the tests' 100-second scale is only a conversion reference, not a simulation delay.

Real values are compared with a small tolerance. Sub-resolution rounding,
negative times and a particular floating-point encoding are not prescribed by
these cases. The pinned library's default name and missing standard setter
remain in [known differences](known-differences.md); the setter case cannot
build and is not described as a failed seed execution.

### Q26. Why not repair the nested socket backward path inside the test?

The nonblocking socket `connect` API is responsible for the automatic backward
connections. Manual wiring would bypass that behavior. The nested initiator
case therefore keeps the required route, even though the pinned library wires
the two backward exports in the opposite direction and fails binding checks.
The forward hierarchy uses child ports connected to parent ports as required.

Passing the other paths verifies payload/delay identity, annotations, return
status and phase-reference propagation for those transactions. It does not
certify every legal base-protocol or timing combination. Callback iterator
tests likewise leave integer positions opaque and restart through public APIs.

## Push delivery, sequence actions and payload packing

### Q27. What completes an item sent through a push sequencer?

IEEE 1800.2-2020 15.6.3.3 requires the sequence's optional item-completion
wait to return after the driver's blocking `put` returns. The push driver
does not use a pull port's `item_done`. A positive-delay test checks that
`finish_item` remains blocked while `put` is still processing the request.
Separate cases send three requests and inspect delivery and common request
and response histories. See [known differences](known-differences.md) for
the pinned library's repeated-request limitation.

### Q28. Do all sequence action macros randomize their argument?

No. `uvm_create` only creates the item or child sequence and sets its context.
`uvm_send` executes it without randomization. `uvm_rand_send` randomizes before
execution, except when a child sequence has randomization disabled. `uvm_do`
combines creation with randomized execution. Child-sequence execution passes
`call_pre_post` zero, suppressing `pre_body` and `post_body`, while still
running `body`. The tests use singleton constraints and callback counts, so
their expected values do not depend on which legal random value is selected.

### Q29. What is included when a generic payload is packed?

The standard specifies an ordered set of scalar fields and the active data
and byte-enable prefixes. Backing-array bytes beyond the declared lengths
and extensions are excluded by default. A declared length larger than the
corresponding array requires a fatal report. The fatal tests finish inside
a report catcher as soon as that severity is observed; they make no claim
about execution after a fatal has been suppressed. Round trips and decoding
through the public packer API avoid prescribing a binary stream encoding.

## Sequence libraries and macro controls

### Q30. How do instance and typewide library registration differ?

`add_sequence` and `add_sequences` affect one library. The static typewide
forms affect libraries constructed afterwards; existing instances are not
updated by an addition. Duplicate sequence types are silently ignored.
`get_sequences` appends the registered list after any existing caller prefix.
Tests compare membership without imposing an undocumented insertion order.

Removal has a different rule: removing a statically registered type must
update all instances, and removing an absent type must warn. The pinned
library removes only from the receiving instance and omits the absent-type
warning. Both required behaviors remain in
[known differences](known-differences.md).

### Q31. Why do some sequence-library tests fail before a seed is run?

IEEE 1800.2-2020 defines getters/setters for selection mode and minimum/maximum
random counts, plus `get_num_sequences_executed`. These seven methods are
absent from the pinned library. Six new cases keep those standard calls and
cannot build; they have no runtime seed result. Legacy public fields are not
substituted for required APIs. Passing registration and direct-selector cases
does not establish execution-mode or execution-counter conformance.

### Q32. Does disabling an item's random field skip randomization callbacks?

No. A field's `rand_mode(0)` keeps that field's assigned value, while the
item's `randomize` operation still invokes its callbacks. Disabling child
sequence randomization instead makes the action skip that operation entirely.
The macro tests distinguish those controls, check factory overrides at
creation, and trace parent hooks around randomization and driver delivery.
The typed-sequencer declaration test uses an explicit cast before accessing
the subtype member; it does not assume an automatic initialization policy.
