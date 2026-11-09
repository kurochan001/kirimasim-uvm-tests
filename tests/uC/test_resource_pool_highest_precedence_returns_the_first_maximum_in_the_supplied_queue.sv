/*
:name: test_resource_pool_highest_precedence_returns_the_first_maximum_in_the_supplied_queue
:description: The resource queue helper returns the first maximum rather than numeric or name tie-breaking
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.4.4.2 C.2.4.5.6 C.2.2.1 C.2.4.3.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_pool_highest_precedence_returns_the_first_maximum_in_the_supplied_queue.expected
*/
// What it checks:
// The resource-queue helper returns the first resource among those with
// maximum precedence.
//
// How the expected output follows from the standard:
// 1800.2-2020 C.2.4.4.2 (UVM-RESOURCE-AUDIT-HIGHEST-FIRST-MAXIMUM) gives the
// rule above. Setup: Registered resources have precedence
// three/seventeen/seventeen and a caller queue is reordered between calls.
// Expected: The first peak wins initially and the other peak wins after
// becoming first in the supplied queue.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_resource_pool_highest_precedence_returns_the_first_maximum_in_the_supplied_queue;
  import uvm_pkg::*;
  initial begin
    automatic uvm_resource_pool pool=uvm_resource_pool::get();
    automatic uvm_resource#(int) low_resource=new("low58");
    automatic uvm_resource#(int) first_peak=new("peak_a58");
    automatic uvm_resource#(int) later_peak=new("peak_b58");
    automatic uvm_resource_types::rsrc_q_t values=new();
    pool.set_scope(low_resource,"scope58"); pool.set_scope(first_peak,"scope58");
    pool.set_scope(later_peak,"scope58");
    pool.set_precedence(low_resource,3); pool.set_precedence(first_peak,17);
    pool.set_precedence(later_peak,17);
    values.push_back(low_resource); values.push_back(first_peak); values.push_back(later_peak);
    $display("UT: highest_queue first_maximum %0d",
      uvm_resource_pool::get_highest_precedence(values)==first_peak);
    values.delete(); values.push_back(later_peak); values.push_back(first_peak);
    $display("UT: highest_queue reordered_tie %0d",
      uvm_resource_pool::get_highest_precedence(values)==later_peak);
    $finish;
  end
endmodule
