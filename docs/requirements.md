# Draft requirement ledger and coverage inventory

[日本語](requirements.ja.md) · [README](../README.md) · [Testing guide](testing.md)

## Current state

M4 is in progress. The [scope proposal](../coverage/scope.json),
[requirement ledger](../coverage/requirements.json) and
[test index](../coverage/test_index.json) are versioned inputs. The ledger
contains 915 AI-drafted requirements: 911 link directly to 876 tests and 4
have no direct test. One additional test is a control. The other 168 of the 1045 tests have
not yet been mapped at requirement level; that does not mean they test no
normative behavior. No requirement records human review.

The clause catalog has 2,504 identifiers. 645 have a partial
requirement decomposition; the other 1,859 are unassessed. Neither group is
complete. Starting M4 does not approve the scope or denominator, or complete
M1–M3. `approved_denominator` and `coverage_percentage` remain `null`.

## Counting unit and scope proposal

The proposed unit is one observable normative obligation together with its
applicability conditions. A method clause may need separate requirements for
success, failure, default arguments, ordering and side effects. Conversely,
a heading is not an obligation. The 915 draft entries span several areas,
without exhausting the obligations in their clauses.

The proposal assigns every root in the existing identifier catalog once:

| Disposition | Roots | Identifier count | Meaning |
| --- | --- | --- | --- |
| Candidate | 5–19, B–G | 2,479 | Examine normative behavior for requirement decomposition |
| Context | 1–4 | 16 | Scope, references, definitions and acronyms; still inform interpretation |
| Deferred | H | 9 | Deprecated APIs await a separate scope decision; no approved exclusion |

These are identifier counts, not requirement counts. Annex A is informative
and absent from this catalog. This census does not independently certify the
catalog's completeness. Normative/non-normative distinctions still require
reading the standard. Library omissions, known differences, unimplemented
HDL/DPI support and backend availability do not silently remove candidate
obligations. SystemVerilog language requirements belong to kirimasim-tests;
UVM requirements that depend on language or HDL facilities remain candidates.

All decomposition uses the user-provided IEEE 1800.2-2020 standard. Statements
are original English/Japanese paraphrases with clause references, not copied
standard text or implementation-derived expectations. Commercial simulator
results remain excluded under the [posting policy](faq.md#commercial-simulator-and-issue-reporting-policy).
The ledger tool consumes no simulator results.

## Citations, requirements and execution evidence

A test's first UVM `:lrm:` reference is its **primary focus**; later UVM
references are **supporting citations**. Of the catalog identifiers, 482
have a primary-focus test and 1,084 have either kind of citation. Supporting
references often describe setup APIs. No reference creates a requirement link,
and a child-clause reference is not automatically rolled up to its parent.

For the 2,479 candidate identifiers, the historical two-tests-per-clause
census currently shows 1,997 with zero primary-focus tests, 251 with one,
and 231 with at least two. It measures test placement only. It does not
establish that an identifier has two independent checks, that its normative
obligations are decomposed, or that either test passes. It is not an approved
requirement denominator or a declaration that all zero-focus clauses are gaps.

Requirement IDs such as `UVM-CLONE-DISTINCT` are stable names independent of
test filenames. Two clone requirements can share clause 5.3.5.2 while checking
distinct-handle creation and subsequent scalar independence separately.
The callback requirement `UVM-VREG-FIELD-POST-WRITE-ORDER` links the standalone
field test directly and a parent-register write test as a control. A control
helps assess the fixture but does not supply a direct link for the requirement.

Each link names exact `UT: ` lines from the generic expected output. These
**expected observations** bind the mapping to an oracle, not to an observed
pass. An anchored line can also contain observations for other obligations;
it does not make this requirement cover all of them. The checker verifies
references, fields, anchor membership and input identities. It cannot prove
that the test actually exercises the requirement or that its assertion is
sufficient. That needs review of the test, fixture and standard. Ordering in
an oracle remains a runner check; the ledger's anchor-membership check alone
does not establish ordering or repetition counts. Repeated identical expected
lines are anchored once; the runner still compares the complete expected sequence.

[Execution evidence](results.md) is separate and needs matching input, runner,
library and configuration identities. A direct link may retain a spec-only
known difference. It is not a pass or a conformance claim. The current 1045-test
snapshot includes newly measured fixtures; mapping unchanged existing tests
adds no new execution result for them.

## Versioned data and generated inventory

All JSON uses UTF-8 and schema version 1. Unknown fields, duplicate keys,
duplicate requirement IDs and unknown clauses/tests are rejected.

- `coverage/scope.json` records the bilingual counting unit, root dispositions
  and historical primary-focus target. Schema 1 permits only a proposed,
  incomplete scope with no approved denominator.
- `coverage/requirements.json` records each stable ID, clause, bilingual
  `statement`, `conditions`, `expected` and `limitations`, `review`, and
  `test_links`. A link has a test ID, `direct` or `control` role and nonempty
  `expected_observations`. A direct test must cite the requirement clause;
  a supporting citation is allowed when review establishes the actual link.
- `coverage/test_index.json` snapshots every current test's `primary_clause`
  and `inputs_sha256`. The fingerprint uses the existing runner collector:
  source, declared helpers/includes/data, expected files and UVM lock. The
  index is an inventory, not 1045 reviewed requirement mappings.

Review status is `ai`, `unreviewed` or `human`. Human status requires an
identified `reviewer` and ISO date in `reviewed_at`; other statuses must leave
both fields `null`. These fields record a review claim; the checker cannot
authenticate the reviewer. Changing a requirement does not automatically
establish renewed human review.

Run from the repository root:

```sh
python3 tools/requirements.py check
python3 tools/requirements.py inventory --json out/requirements-inventory.json --lang ja
python3 tools/requirements.py sync --output out/test-index-proposal.json
```

`check` validates the canonical inputs and prints a summary. `inventory` also
writes all identifier dispositions, decomposition states, primary/supporting
citations, requirement links, review/oracle metadata, fingerprints and root totals. A
clause with entries is `partial`; one without entries is `unassessed`. Neither
state means complete or covered. Generated denominator and percentage fields
remain `null`. `--lang en` or `--lang ja` selects summary language; JSON keys
and stable identifiers do not change. Generated files under `out/` are ignored
by Git, and no generated output may overwrite the three canonical inputs.

## Review work queue and root totals

Use `backlog` to extract work items without editing the ledger:

```sh
python3 tools/requirements.py backlog --json out/requirements-backlog.json --lang ja
python3 tools/requirements.py backlog --root E --json out/requirements-backlog-E.json --lang ja
```

`--root` accepts an exact catalog root such as `5`, `17` or `E`, only with
`backlog`. Unknown roots, subclauses and directory labels such as `u05` are
rejected. Validation of the whole canonical ledger/index precedes extraction;
a root filter cannot hide a stale binding elsewhere.

The JSON separates `requirements_without_direct_tests` (full bilingual draft
records, including control-only requirements), `tests_without_requirement_links`
(test metadata and fingerprints without either link role), and
`unassessed_identifiers` (catalog identifiers with no requirement entry).
These are review queues, not established conformance gaps. Context/deferred
identifiers remain visible with their disposition, and all denominator and
percentage fields remain unset.

`inventory` and `backlog` include `roots` totals. Requirements belong to their
own clause root; tests belong to their primary-focus root. Thus chapter 17
requirements can link to tests placed under annex E without moving those
tests into chapter 17's primary count. Counts are not rolled up from children
to certify a parent requirement. Multiple requirements can share a test, and
one requirement can have multiple test links; neither implies independent
coverage from every anchor in a shared expected-output line.

Every existing primary-focus test in these seventeen roots now has a requirement
link, while normative decomposition remains partial:

| Root | Draft requirements | Primary-focus tests | Tests without links | Unassessed identifiers |
| --- | --- | --- | --- | --- |
| 5 | 47 | 42 | 0 | 79 |
| 6 | 34 | 32 | 0 | 87 |
| 7 | 30 | 13 | 0 | 45 |
| 8 | 23 | 34 | 0 | 52 |
| 9 | 37 | 27 | 0 | 89 |
| 10 | 50 | 54 | 0 | 80 |
| 11 | 17 | 12 | 0 | 17 |
| 13 | 36 | 20 | 0 | 87 |
| 16 | 92 | 97 | 0 | 129 |
| 17 | 7 | 2 | 0 | 26 |
| 19 | 29 | 37 | 0 | 97 |
| B | 36 | 54 | 0 | 110 |
| C | 9 | 16 | 0 | 80 |
| D | 6 | 6 | 0 | 40 |
| E | 48 | 54 | 0 | 79 |
| F | 22 | 10 | 0 | 119 |
| G | 1 | 2 | 0 | 21 |

Zero unmapped tests is not complete coverage. Annex E still has two requirements
without direct tests: HDL-path accessibility and the walking-ones algorithm
itself. Location masks
are linked only to the necessary location-access property, not to the whole
walking algorithm. B.5.11's conflicting printed invocation is recorded as an
interpretation requiring review. Known differences retain normative oracles;
all 915 requirement reviews are still `ai`.

Selected FIFO mappings bind blocking/nonblocking behavior, capacity, flush,
arrival order and analysis notifications to their actual expected observations.
Failed-get/peek output postconditions now have sentinel fixtures, with the
standard's `output` signature/prose tension explicitly left for review. Broader
concurrency and two-tests-per-requirement coverage remain unassessed. Foundation mappings cover local database hooks,
pools, agent status, string fields and literal argument suffix queries; none
claims external database, full agent traffic or a working DPI backend.

Selected register/memory, virtual-register and custom-frontdoor fixtures now
link their transfer, status, prediction, slice and descriptor observations.
These do not establish RTL behavior, every map/endian combination or general
burst-array packing. Three read fixtures correct their primary citation from
write to read and carry reassessed index snapshots and refreshed execution
records; their test behavior and expected output stay the same.

Core output, limit and no-override query branches have direct fixtures. Printer
emission uses field/value membership and field-macro arrays. Comparer caps
count individual reports inside the comparison hook, with rollups outside that
window. Quit limits observe real pre-abort traversal and no later-time
continuation; ready caps use correctly paired repeated raises/delayed drops.
These remain selected conditions, not all output formats, report/phase contexts
or sibling-phase combinations.

Four drafts still lack direct tests: object-side active-policy synchronization,
HDL deposit, HDL-path accessibility and the full memory-walk algorithm. Chapter
19 has no unmapped existing primary-focus tests, while HDL/backend candidates
and other unassessed obligations remain in scope. The quit-action wording
in 6.5.1.2.3 is interpreted using declared `UVM_COUNT` in F.2.2.2 and root
termination in F.7.3.2; its printed `UVM_QUIT` is not a declared action value.

Container links now separate first/last endpoints, next/previous cursors,
global singleton identity, indexed/keyed access, insertion boundaries, empty
pop warnings and empty/nonempty waits. Selected multi-reader, multi-peeker and
flush-capacity fixtures extend existing FIFO obligations. The new analysis
write/wakeup link does not prescribe a scheduling winner.

Memory hooks separately link pre-write value/offset composition, pre-read
map/offset redirection, pre-access aborts, post-read return changes and
post-write ordering/final status/no retransfer. Twenty-one existing memory and
register-map query fixtures are mapped to their observed parent, size, width,
membership, rights, address, relocation, reset and hierarchy properties.
A shared output line does not make every anchor an independent requirement
check. Chapter 18 still has 62 unmapped primary-focus tests and 339 unassessed
identifiers. Known map-redirection and post-write-order differences retain
the required expectations, without creating new measured passes.

Event/barrier drafts now link persistent on-state, reset/off waits, fresh and
same-slice trigger data, default trigger data, threshold release, auto-reset,
open-gate reuse and reset wakeup/rearm. Timed TLM 2 histories link call routing,
returned phase/status, handle identity and independent timing annotation;
transaction scheduling remains testbench behavior.

Nine additional field policies link repeated WRITE observations, with separate
READ-side-effect drafts where applicable. These are explicit predictions,
not physical read/write traffic. Selected existing chapter 14 fixtures now
link context, depth/root/path, local controls, optional hook ordering,
completion/state waits, priority selection, parent hooks, automatic objection
lifetime and response clearing. Getter links do not establish automatic
randomization, print/copy/record side effects, locked-control updates or
arbitration. The already-matching state-mask fixture reaches a return marker
but does not assert zero elapsed time. Chapter 14 retains 24 unmapped
primary-focus tests and 60 unassessed identifiers; all decomposition is partial.

Hierarchy drafts distinguish component parent/full-name/depth, appended child
lists, direct-child membership, cursor boundaries and relative/absolute or
failed lookup. Indexed TLM 1 fixtures link resolved endpoint counts/handles,
selected blocking/nonblocking transfers and parent fanout; the traffic does
not assume provider ordering or exercise default-index setters.

Symbolic HDL descriptions now have concat API, kind-selection/clearing,
ancestor-default, full block-path combinations/separators and absolute-root
links. The required concat set/get APIs remain build differences, and default
abstraction inheritance remains a runtime difference. No link establishes
HDL accessibility or deposit. The two new chapter 17 primary tests have direct
links, with partial normative decomposition and no runtime pass claim.

Twenty-one existing payload/extension fixtures are linked to address/data/mask
state, predicates, type-key identity, clearing, aliasing and the extension
boundary of default packing. Array and length setup remains consistent in
these links; unrelated mismatched-length semantics remain separate. Chapter
12 retains 46 unmapped primary-focus tests and 145 unassessed identifiers.
No new link creates a measured pass, human review or approved denominator.

Typed event callback drafts distinguish veto, post-trigger state, reset
wakeup without callbacks and disabled-hook dispatch. Explicit killed-waiter
cancellation and dedicated pool key/singleton identities have separate links.
Blocking TLM 2 drafts observe overlapping call return boundaries, connected
socket channels, error/reuse, custom transaction types and nested exports;
endpoint timing and response generation remain fixture behavior.

Register-model introspection now links block/regfile/register parent handles,
local/recursive membership and simple-name searches. It does not establish
transfer behavior; pre-lock and nested-regfile lookup differences retain
normative expectations. Chapter 18 still has 62 unmapped primary tests and
339 unassessed identifiers.

Twenty existing sequencer fixtures now link mode/capacity controls, counters,
request/response history, current-item lifetime, peek/get completion,
execute-item acknowledgement and typed push traffic/response handlers.
Control getters do not establish arbitration and response-history links do
not substitute for response delivery. Chapter 15 retains 36 unmapped primary
fixtures and 53 unassessed identifiers; its 36 drafts remain partial.

Recording drafts now distinguish database-open guards, stream metadata,
open/close/free hooks and state, handle identity/lookup, pre-initialization
warnings and link endpoint dispatch/prefills. Local hooks provide streams;
these stream-only links leave recorder behavior to the separate recorder
requirements below. External database contents remain outside the fixtures.
Chapter 7 has thirteen primary fixtures, 30 drafts and 45 unassessed identifiers. The
stream enumeration count retains a signature/prose interpretation for review.

New request/response channel fixtures map directional routing, full-queue
blocking put, response get waiting and request peek retention. Twenty existing
TLM 1 fixtures link analysis broadcast, empty subscriptions, export forwarding,
bound ports, split implementation delegation, typed FIFO direction/order,
notifications and sequential transport. Chapter 12 still has 46 unmapped
primary fixtures and 145 unassessed identifiers.

Field metadata drafts distinguish previous access, custom registration versus
built-in classification, volatility/compare settings, reset-value queries,
reset metadata/deletion, defined/unknown reset state and static maximum width.
These are model-only observations. Chapter 18 still has 62 unmapped primary
fixtures and 339 unassessed identifiers. No new link supplies a human review,
physical reset, external recording backend or approved denominator.

Recorder drafts now link open-stream admission, stream identity, explicit
timestamps, lifecycle flags, automatic close-on-free, handle lookup, recorder
queue membership, stream cleanup cascades and six scalar recording hooks.
These use local implementations, without a file format, vendor attribute
macro, object recursion or default-time substitution. Recorder enumeration
links only queue membership, leaving the printed return-count issue separate.

All eight TLM 2 socket constructors link role/bounds/parent observations;
blocking and nonblocking target terminators each have repeated-connect ERROR
links. Queries precede binding resolution and establish no transport delivery.
Indirect-register links cover explicit index selection, selected read/write,
reselection, independent pairs, optional regfile placement, auto-prediction
and driver-error/retry observations. Array elements have equal widths and
valid indices; neither RTL nor automatic array-frontdoor generation is claimed.

Twenty existing sequencer fixtures link FIFO/strict/random/USER behavior,
candidate handles, lock exclusion and FIFO placement, completion-before-grant,
grab precedence, parent/child eligibility, nested ownership queries,
interchangeable release and lock/relevance availability. Random membership
is distinct from fairness or statistical coverage. Chapter 15 retains 36
unmapped primary fixtures and 53 unassessed identifiers; its 36 drafts remain
partial. Existing lock timing/order differences retain normative expectations.

Phase graph links now cover constructor kinds, immediate parents, enclosing
domains/names, full paths, node/implementation identity, scoped lookup,
transitive order and parallel joins. These inspect unexecuted local graphs;
the printed get_schedule/get_imp inconsistencies remain outside this batch.
The current-node lookup keeps its required node result as a spec-only case.

Custom-transaction socket links exercise actual delivery through default
parent and explicit blocking implementations, and both directions through
one nonblocking initiator/target pass-through node. The transaction is
independent of the generic payload, while phase arguments use the standard
enumeration. Annotation checks do not imply elapsed simulation time.

Coverage links distinguish model availability, enabled masks and required
previous-mask returns. They also cover nested block control, register hooks
after bus completion but before prediction, memory hook direction/map,
block-relative offsets, successful-access sampling and recursive sample_values.
Hook counters are not covergroups, bins or a measured coverage percentage.
The previous-mask and extra-memory-sample differences remain spec-only. Twenty existing register/field
fixtures separately link desired/mirror state, reset kinds, selected prediction
policies, clean/dirty update and physical W1C/W1S write masks. Model-only
operations and bus-mask observations do not establish a policy-accurate DUT.
Chapter 18 has 182 drafts, 62 unmapped primary fixtures and 339 unassessed
identifiers; chapter 12 has 91 drafts, 46 unmapped fixtures and 145 unassessed
identifiers. All decompositions remain partial.

Component recording links distinguish default enable state, instance-local
controls, explicit/default databases, stream-pair caching and reference
release, null guards, transaction-time forwarding, post hooks, deferred
property recording and close-versus-free behavior. Local hooks establish
no external format, component-event wakeup or transaction-link semantics.
Stream reference release retains its normative fresh-stream difference.
The stream type chosen internally by begin_tr is not prescribed by the
fixture; the begin hook's recorder handle identifies the actual stream.

Sequence reporting links distinguish reporter selection, verbosity-query
delegation, virtual message construction/filtering and real-handler routing
of preformed messages. Explicit contexts are preserved; empty contexts use
the sequence path. A virtual-processing probe does not execute report actions.
Twenty existing sequence fixtures separately map start-item precedence,
priority, guards and context; finish virtual dispatch, ID forwarding and
hook ordering; and low-level grant/submission behavior. Their known
ERROR-severity, virtual-dispatch and completion-ID differences remain.
Chapter 14 has 82 drafts, 24 unmapped primary fixtures and 60 unassessed
identifiers; its new reporting links and old submission links remain partial.

Map-read links cover default comparison-off, default enabling, matching and
mismatching reads, disabling without stopping prediction, one existing
submap, independent interfaces, field comparison masking and comparison
before RC prediction. All root interfaces explicitly enable auto-prediction.
ERROR observations describe mirror discrepancies, not a rejected bus request.
No passive predictor integration, actual DUT side effect or DPI is claimed.
Chapter 18 has 182 drafts, 62 unmapped primary fixtures and 339 unassessed
identifiers. These links add no human review or approved denominator.

Core-service drafts link default printer/packer/comparer/copier selection
and null fallback, factory/report-server/database replacement and restoration,
shared-service identity and within-process global-seed immutability. They
query handles directly; no concrete default type, original-default reuse,
RNG value, custom core initialization or service behavior is inferred.
Annex F has 22 drafts, ten primary fixtures and 119 unassessed identifiers.

New library-index links cover valid wrapper identity, strictly out-of-range
ERROR/null results, instance membership and removal. Twenty existing library
fixtures map instance/typewide registration and deduplication, appended
queues, removal/warnings, direct default selectors, standard mode/count
APIs, counters and selected/default RAND execution. No enumeration order or
unforced winner is required. The printed equal-count index boundary remains
unresolved. Missing standard API spellings, static-removal behavior and
missing warnings retain their original spec-only expectations. Chapter 14
has 82 drafts, 24 unmapped primary fixtures and 60 unassessed identifiers.

Transaction-order links distinguish map getter/selection state from actual
policy dispatch and physical transfer order. Complete operation structs are
sorted by address for 32-bit registers on eight-bit buses. Write/read cases
retain byte/address pairing and logical reconstruction for both endiannesses;
interface isolation, replacement and clearing have separate controls.
Little-endian read reconstruction and big-endian byte swapping retain
normative known differences. Sorting is fixture code, not itself a conformance
claim. No memory burst, partial-width word, arbitrary concurrency or child-map
inheritance is covered. Chapter 18 has 182 drafts, 62 unmapped primary fixtures
and 339 unassessed identifiers. All new reviews remain AI and no denominator
or complete decomposition is approved.

## Generated report identity

Every generated inventory and backlog carries `ledger_inputs_sha256`. It
identifies the complete validated input state: `coverage/scope.json`,
`coverage/requirements.json`, `coverage/test_index.json` and the catalog's
`catalog_sha256`. The index contains the current test-input fingerprints;
ledger validation binds those snapshots to the actual test inputs first.

The tool hashes UTF-8 canonical JSON with sorted object keys and compact
separators. JSON whitespace, key order and escaped versus literal Japanese
text do not affect this identity. Array order is retained, and catalog byte
changes affect its own fingerprint. Absolute repository paths, generated
output paths, report language and a backlog root filter are not input fields.
The identity is shared by full and filtered reports from the same inputs.
Compare the report schema and selection as well when comparing different views;
this is an input identity, not a hash of the generated output file.

Requirement wording, applicability, expectations, limitations, review or link
changes affect the identity, as do scope or accepted snapshot changes. A digest
is neither review approval nor an execution result. It is separate from each
test's `inputs_sha256` and the runner's `runner_sha256`. Old generated reports
need regeneration after a semantic ledger change even when the simulation
sources stay unchanged. A same-hash report can still describe an incomplete,
unapproved inventory with known differences.

## Updating a test or mapping

1. Read the applicable normative behavior; write or revise the bilingual
   requirement, conditions and limitations. Reassess its review status.
2. Inspect the test and expected observations. Add explicit `direct` or
   `control` links; leave links empty when the requirement is not yet mapped.
3. Run `check`. Changed inputs or primary focus, added tests and removed tests
   invalidate the canonical index.
4. Use `sync` to create a separate proposal. It adds current tests and refreshes
   unlinked snapshots, but preserves existing snapshots of linked tests. Thus
   adopting a proposal alone does not clear a stale linked mapping. Removing
   a linked test first requires reviewing/removing its links.
5. Compare the proposal and source changes. After reassessing every affected
   mapping, update its fingerprint/focus from the current inputs and adopt
   the reviewed index changes. A new snapshot is not itself a human review.
6. Run metadata, ledger and tool checks; update the paired guides when scope,
   schema or inventory claims change. Reproduce affected execution evidence
   separately when simulation inputs or runners change.

There is deliberately no command that silently certifies existing mappings
when their inputs change. The regression tests cover stale expected/helper/
lock inputs, direct/control distinctions, citation non-promotion, duplicate
or invalid data, scope claims and generated-output protection. Check CI runs
this validation alongside the existing metadata and library checks.

## Remaining M4 work and approval

Continue reading candidate clauses and splitting their obligations and
conditions. Map existing tests before deciding which new tests are necessary;
record unsupported or unmatched behavior without changing its normative
expectation. Review the context/deferred choices, catalog completeness,
requirement identities, overlap and genuinely non-normative material. Track
backend constraints as limitations rather than hidden denominator exclusions.

Before publishing a coverage percentage, finish and review the normative
inventory, resolve the scope choices and obtain explicit approval of the
counting rule and frozen requirement set. Define separately what counts as
reviewed test coverage and as execution success, including execution conditions
and evidence identity. Approval needs a later schema/procedure update; schema
1 intentionally cannot express a completed inventory or approved denominator.
The current 915 AI drafts and their direct links do not satisfy that gate.
