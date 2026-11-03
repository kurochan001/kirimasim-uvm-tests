/*
:name: test_reg_fifo_capacity_constraint_applies_to_subtype_declared_queue_sizes
:description: inherited FIFO capacity constrains queue sizes declared by concrete subtypes (18.8.2)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.8.2 18.8.4.1 18.8.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_fifo_capacity_constraint_applies_to_subtype_declared_queue_sizes.expected
*/
// Test the same inherited bound with subtype-declared constraints.
// No inline clause, implementation-specific build or DUT storage is used.
// The measured valid subtype matches, but the oversized subtype is accepted.
// This observation does not assign the cause to the simulator or library.
module test_reg_fifo_capacity_constraint_applies_to_subtype_declared_queue_sizes;
  import uvm_pkg::*;
  class at_capacity extends uvm_reg_fifo;
    constraint chosen_size {
      fifo.size() == 3;
      foreach (fifo[i]) fifo[i] == i + 1;
    }
    function new(); super.new("at_capacity", 3, 8, UVM_NO_COVERAGE); endfunction
  endclass
  class over_capacity extends uvm_reg_fifo;
    constraint chosen_size { fifo.size() == 4; }
    function new(); super.new("over_capacity", 3, 8, UVM_NO_COVERAGE); endfunction
  endclass
  initial begin
    automatic at_capacity valid = new();
    automatic over_capacity invalid = new();
    bit accepted, rejected;
    accepted = valid.randomize();
    $display("UT: declared_capacity accepted %0d size %0d capacity %0d", accepted,
             valid.size(), valid.capacity());
    rejected = invalid.randomize();
    $display("UT: declared_oversized rejected %0d", !rejected);
    $finish;
  end
endmodule
