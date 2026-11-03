/*
:name: test_reg_fifo_randomization_accepts_capacity_and_rejects_an_oversized_queue
:description: the inherited FIFO size constraint accepts capacity and rejects a larger queue (18.8.2)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.8.2 18.8.4.1 18.8.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_fifo_randomization_accepts_capacity_and_rejects_an_oversized_queue.expected
*/
// Only the declared abstract queue bound is tested through randomization.
// State after failed randomization and actual DUT occupancy are not asserted.
// The measured inline call succeeds but leaves the requested valid queue empty.
// Its oversize request is rejected as expected; keep that observation separate.
module test_reg_fifo_randomization_accepts_capacity_and_rejects_an_oversized_queue;
  import uvm_pkg::*;
  initial begin
    automatic uvm_reg_fifo value = new("value", 3, 8, UVM_NO_COVERAGE);
    bit accepted, rejected;
    accepted = value.randomize() with {
      fifo.size() == 3;
      foreach (fifo[i]) fifo[i] == i + 1;
    };
    $display("UT: at_capacity accepted %0d size %0d capacity %0d", accepted,
             value.size(), value.capacity());
    rejected = value.randomize() with { fifo.size() == 4; };
    $display("UT: oversized rejected %0d", !rejected);
    $finish;
  end
endmodule
