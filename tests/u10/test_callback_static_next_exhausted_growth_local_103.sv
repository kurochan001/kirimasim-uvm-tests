/*
:name: test_callback_static_next_exhausted_growth_local_103
:description: Static callback exhaustion remains null after completed additions until the required endpoint reset
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.7.2.4.3 10.7.2.4.1 10.7.2.4.2 10.7.2.4.4 10.7.2.3.1 10.7.2.3.3 10.7.1.1 10.7.1.2.1 10.7.1.2.2 10.7.2.2.1 10.7.2.2.2 B.4.1 1800-2023 6.21 8.13 8.16
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers103_static/static103.svh
:expected_exit: 0
:expected_stdout: @test_callback_static_next_exhausted_growth_local_103.expected
*/
// What it checks:
// 1. get_first selects the enabled endpoint and initializes the caller
//    iterator.
// 2. get_next advances its iterator through enabled callbacks and remains null
//    after exhaustion until reset.
// 3. After an exhausted get_next returns null,completed callback additions do
//    not replace the required get_first reset.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.7.2.4.1 (UVM-CALLBACK-STATIC-FIRST) gives rule 1 above.
//    Setup: Use independent integer iterators and either an object context or
//    the null typewide context. Expected: The selected endpoint belongs to the
//    requested queue and can restart an exhausted traversal.
// 2. 1800.2-2020 10.7.2.4.3 (UVM-CALLBACK-STATIC-NEXT) gives rule 2 above.
//    Setup: Traverse in the selected direction with disabled entries,
//    independent iterators and typewide-only queries. Expected: Valid entries
//    follow the selected queue; exhausted calls stay null and separate
//    positions remain independent.
// 3. 1800.2-2020 10.7.2.4.3
//    (UVM-CALLBACK-STATIC-NEXT-EXHAUSTION-UNTIL-RESET-AFTER-ADD-103) gives
//    rule 3 above. Setup: Use an opaque integer cursor in local or null
//    typewide context. Obtain repeated null from get_next on an empty
//    queue,add mixed requested/unrelated and disabled callbacks,then continue
//    before resetting. Exhaust a nonempty walk,append five enabled callbacks
//    after the completed exhausted calls,and continue before a fresh
//    get_first. Expected: Both post-add continuations remain null until
//    get_first. A fresh reset then selects the required endpoint and
//    subsequent get_next calls return exactly the enabled requested-family
//    handles in order before repeated null; unrelated or excluded peer entries
//    never substitute.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_callback_static_next_exhausted_growth_local_103;
  import uvm_pkg::*;
  localparam int MODE103=2,TYPEWIDE103=0;
  `include "static103.svh"
endmodule
