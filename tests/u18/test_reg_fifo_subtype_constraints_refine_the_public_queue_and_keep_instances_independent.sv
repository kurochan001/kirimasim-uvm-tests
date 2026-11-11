/*
:name: test_reg_fifo_subtype_constraints_refine_the_public_queue_and_keep_instances_independent
:description: subtypes can constrain the public FIFO queue while preserving the inherited capacity bound (18.8.2)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.8.2 18.8.4.1 18.8.4.2 18.8.5.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_fifo_subtype_constraints_refine_the_public_queue_and_keep_instances_independent.expected
*/
// What it checks:
// 1. A FIFO subtype can refine its public queue using additional constraints.
// 2. Separate FIFO instances retain independent abstract queue storage.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.8.2 (UVM-REG-FIFO-SUBTYPE-PUBLIC-QUEUE-CONSTRAINTS) gives
//    rule 1 above. Setup: A concrete subtype constrains three entries to
//    17/18/19 inside capacity four. Expected: Both instances randomize
//    successfully and the selected values match.
// 2. 1800.2-2020 18.8.2 (UVM-REG-FIFO-ABSTRACT-QUEUE-INSTANCE-ISOLATION) gives
//    rule 2 above. Setup: Two identically constrained FIFOs are randomized
//    before changing the first front to 99. Expected: The changed front is 99
//    while the peer still returns 17 and retains size three.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A public queue refinement is original fixture code, not a FIFO algorithm.
// Direct queue mutation is used only to check instance isolation.
module test_reg_fifo_subtype_constraints_refine_the_public_queue_and_keep_instances_independent;
  import uvm_pkg::*;
  class constrained_fifo extends uvm_reg_fifo;
    constraint chosen_values {
      fifo.size() == 3;
      foreach (fifo[i]) fifo[i] == 17 + i;
    }
    function new(string name); super.new(name, 4, 8, UVM_NO_COVERAGE); endfunction
  endclass
  initial begin
    automatic constrained_fifo first = new("first");
    automatic constrained_fifo peer = new("peer");
    bit first_ok, peer_ok;
    first_ok = first.randomize(); peer_ok = peer.randomize();
    $display("UT: randomized %0d %0d first %0d %0d %0d", first_ok, peer_ok,
             first.fifo[0], first.fifo[1], first.fifo[2]);
    first.fifo[0] = 99;
    $display("UT: local_change front %0d peer %0d size %0d capacity %0d", first.get(),
             peer.get(), peer.size(), first.capacity());
    $finish;
  end
endmodule
