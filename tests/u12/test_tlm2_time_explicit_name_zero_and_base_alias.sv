/*
:name: test_tlm2_time_explicit_name_zero_and_base_alias
:description: TLM 2 canonical time uses the uvm_time alias and prescribed time operations (IEEE 1800.2-2020 Section 12.3.9)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.9 5.6.2.1 5.6.2.3 5.6.2.8 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_time_explicit_name_zero_and_base_alias.expected
*/
// Construct an explicitly named delay and assign it to the canonical
// base type. Observe the zero value and handle identity, without any
// assumption about the enclosing design time scale.

module test_tlm2_time_explicit_name_zero_and_base_alias;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  function automatic bit close_to(real actual, real wanted);
    real difference;
    difference = actual - wanted;
    if (difference < 0.0) difference = -difference;
    return difference <= 1.0e-12 * (wanted + 1.0);
  endfunction
  initial begin
    automatic uvm_tlm_time value = new("alpha", 1.0e-12);
    automatic uvm_time base_value = value;
    $display("UT: alias_same %0d name %s zero %0d", base_value == value,
             value.get_name(), close_to(value.get_abstime(1.0e-9), 0.0));
    $finish;
  end
endmodule
