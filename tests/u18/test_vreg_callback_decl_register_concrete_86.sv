/*
:name: test_vreg_callback_decl_register_concrete_86
:description: Listed callback facade declaration preserves construction and callback base views
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.2.1 18.10.6.1 1800-2023 6.21 8.12 8.13 8.17 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_callback_decl_register_concrete_86.expected
*/
module test_vreg_callback_decl_register_concrete_86;
  import uvm_pkg::*;
  initial begin
    uvm_vreg_cbs facade;
    uvm_callback base_view;
    facade=new(); base_view=facade;
    $display("UT: vcb86 concrete nonnull %0d callback_view %0d",
      facade!=null,base_view==facade);
    $finish;
  end
endmodule
