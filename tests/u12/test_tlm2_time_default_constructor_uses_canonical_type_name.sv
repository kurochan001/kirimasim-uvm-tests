/*
:name: test_tlm2_time_default_constructor_uses_canonical_type_name
:description: TLM 2 canonical time uses the uvm_time alias and prescribed time operations (IEEE 1800.2-2020 Section 12.3.9)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.9 5.6.2.1 5.6.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_time_default_constructor_uses_canonical_type_name.expected
*/
// What it checks:
// The default canonical time constructor name is uvm_time through its TLM
// alias.
//
// How the expected output follows from the standard:
// 1800.2-2020 5.6.2.1 (UVM-TLM-TIME-DEFAULT-CONSTRUCTOR-NAME) gives the rule
// above. Setup: Construct without an explicit name. Expected: The name getter
// returns uvm_time.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The typedef uses the canonical constructor default name. The pinned
// library uses the legacy alias name instead; retain the required
// canonical name as a spec-only expectation.

module test_tlm2_time_default_constructor_uses_canonical_type_name;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  function automatic bit close_to(real actual, real wanted);
    real difference;
    difference = actual - wanted;
    if (difference < 0.0) difference = -difference;
    return difference <= 1.0e-12 * (wanted + 1.0);
  endfunction
  initial begin
    automatic uvm_tlm_time value = new();
    $display("UT: default_name %s", value.get_name());
    $finish;
  end
endmodule
