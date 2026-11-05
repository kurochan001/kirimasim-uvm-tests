/*
:name: test_vreg_query_offset_tight
:description: The element offset combines the base and index spacing in memory words.
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.2.14 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.4 18.6.3.1 18.6.3.2 18.9.1.1.1 18.9.1.1.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_query_offset_tight.expected
:files: helpers70/vreg_query_fixture70.svh
*/
// Independently derived model observations; original testbench setup.
module
  test_vreg_query_offset_tight;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "vreg_query_fixture70.svh"
initial begin
    automatic model70 m=new(.stride(0));
    m.owner.lock_model();
    $display("UT: offset_tight first %0d third %0d",
      m.vr.get_offset_in_memory(0),m.vr.get_offset_in_memory(2));
    $finish;
  end
endmodule
