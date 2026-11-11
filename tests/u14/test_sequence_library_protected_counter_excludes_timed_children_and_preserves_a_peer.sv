/*
:name: test_sequence_library_protected_counter_excludes_timed_children_and_preserves_a_peer
:description: sequence library protected counter excludes timed children and preserves a peer (IEEE 1800.2-2020 Section 14.4.4.5)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.4.4.5 15.5.1 15.5.2.1 14.4 14.4.4.6 14.4.5.3 B.3.2.2 B.2.1.2 14.2.3.1 1800-2023 6.21 18.5 18.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_library_protected_counter_excludes_timed_children_and_preserves_a_peer.expected
*/
// What it checks:
// 1. A default-budget library executes ten registered member sequences.
// 2. The protected execution counter indicates no completed child before
//    execution.
// 3. The execution counter excludes a currently executing child.
// 4. The counter includes completed children while excluding the next active
//    child.
// 5. The protected field reports the completed child count after the library
//    returns.
// 6. Executing one library leaves an unstarted peer completion counter
//    unchanged.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.4.4.6 (UVM-LIBRARY-DEFAULT-EXECUTION-BUDGET) gives rule 1
//    above. Setup: Use one registered type or two unconstrained registered
//    choices. Expected: Exactly ten child bodies complete, without fixing the
//    unforced winners.
// 2. 1800.2-2020 14.4.4.5 (UVM-SEQ-REVIEW-COUNTER-FIELD-INITIAL-ZERO) gives
//    rule 2 above. Setup: An active and an unstarted peer library are queried
//    before start. Expected: Both field values are zero.
// 3. 1800.2-2020 14.4.4.5 (UVM-SEQ-REVIEW-COUNTER-FIELD-EXCLUDES-ACTIVE) gives
//    rule 3 above. Setup: Sample while the first child is held by a positive
//    delay or explicit gate. Expected: One body has started, none has
//    finished, and the completed count is zero.
// 4. 1800.2-2020 14.4.4.5 (UVM-SEQ-REVIEW-COUNTER-FIELD-COMPLETED-PREFIX)
//    gives rule 4 above. Setup: The first child completes and the second
//    remains active. Expected: Two bodies have started, one has finished, and
//    the completed count is one.
// 5. 1800.2-2020 14.4.4.5 (UVM-SEQ-REVIEW-COUNTER-FIELD-FINAL-COUNT) gives
//    rule 5 above. Setup: The default legal budget completes all ten member
//    bodies. Expected: The final field, started and finished counts are all
//    ten.
// 6. 1800.2-2020 14.4.4.5 (UVM-SEQ-REVIEW-COUNTER-FIELD-INSTANCE-ISOLATION)
//    gives rule 6 above. Setup: Only one of two independently constructed
//    libraries runs. Expected: The peer field remains zero during and after
//    the active execution.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe only the standard protected sequences_executed member through an
// original subtype probe. The missing public getter tests remain separate and
// unchanged. Use the default legal ten-member budget and one registered type;
// active children are sampled by positive delay or explicit completion gates.
module test_sequence_library_protected_counter_excludes_timed_children_and_preserves_a_peer;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class member_sequence extends uvm_sequence#(uvm_sequence_item);
    `uvm_object_utils(member_sequence)
    static int started = 0, finished = 0;
    static int releases = 0;
    function new(string name="member"); super.new(name); endfunction
    task body();
      int ordinal;
      started++; ordinal = started;
      #3;
      finished++;
    endtask
  endclass
  class observed_library extends uvm_sequence_library#(uvm_sequence_item);
    `uvm_object_utils(observed_library)
    `uvm_sequence_library_utils(observed_library)
    function new(string name="library"); super.new(name); endfunction
    function int unsigned observe_counter_field(); return sequences_executed; endfunction
  endclass
  initial begin
    static observed_library value = new("active");
    static observed_library peer = new("peer");
    static bit done = 0;
    static uvm_sequencer#(uvm_sequence_item) sequencer = new("sequencer", null);
    value.add_sequence(member_sequence::get_type());
    $display("UT: counter_initial value %0d peer %0d", value.observe_counter_field(),
             peer.observe_counter_field());
    fork begin value.start(sequencer); done = 1; end join_none
    wait (member_sequence::started == 1);
    #1;
    $display("UT: counter_first completed %0d started %0d finished %0d",
             value.observe_counter_field(), member_sequence::started, member_sequence::finished);

    wait (member_sequence::started == 2);
    #1;
    $display("UT: counter_second completed %0d started %0d finished %0d peer %0d",
             value.observe_counter_field(), member_sequence::started, member_sequence::finished,
             peer.observe_counter_field());

    wait (done);
    $display("UT: counter_final completed %0d started %0d finished %0d peer %0d",
             value.observe_counter_field(), member_sequence::started, member_sequence::finished,
             peer.observe_counter_field());
    $finish;
  end
  initial begin #100; $fatal(1, "counter watchdog expired"); end
endmodule
