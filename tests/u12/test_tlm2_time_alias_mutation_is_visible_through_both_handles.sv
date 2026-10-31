/*
:name: test_tlm2_time_alias_mutation_is_visible_through_both_handles
:description: TLM 2 canonical time uses the uvm_time alias and prescribed time operations (IEEE 1800.2-2020 Section 12.3.9)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.9 5.6.2.4 5.6.2.8 5.6.2.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_time_alias_mutation_is_visible_through_both_handles.expected
*/
// Assign the delay to its canonical base alias, modify through that
// handle and reset through the TLM alias. Both views must observe the
// same object, without copying an implementation-specific representation.

module test_tlm2_time_alias_mutation_is_visible_through_both_handles;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  function automatic bit close_to(real actual, real wanted);
    real difference;
    difference = actual - wanted;
    if (difference < 0.0) difference = -difference;
    return difference <= 1.0e-12 * (wanted + 1.0);
  endfunction
  initial begin
    automatic uvm_tlm_time value = new("value", 1.0e-12);
    automatic uvm_time base_value = value;
    base_value.set_abstime(9.0, 1.0e-9);
    $display("UT: mutation_visible %0d", close_to(value.get_abstime(1.0e-9), 9.0));
    value.reset();
    $display("UT: reset_visible %0d", close_to(base_value.get_abstime(1.0e-9), 0.0));
    $finish;
  end
endmodule
