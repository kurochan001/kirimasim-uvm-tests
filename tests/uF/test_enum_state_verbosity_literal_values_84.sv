/*
:name: test_enum_state_verbosity_literal_values_84
:description: The five standard verbosity names provide their specified numeric levels
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.2.4  1800-2023 6.21 6.19.5 8.20 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_enum_state_verbosity_literal_values_84.expected
*/
// Standard-derived observations; no enum bit positions or report layout fixed.
module test_enum_state_verbosity_literal_values_84;
  import uvm_pkg::*;
  initial begin
    $display("UT: verbosity84 literals none %0d low %0d medium %0d high %0d full %0d",
      UVM_NONE==0,UVM_LOW==100,UVM_MEDIUM==200,UVM_HIGH==300,UVM_FULL==400);
    $finish;
  end
endmodule
