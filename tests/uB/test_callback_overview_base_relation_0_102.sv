/*
:name: test_callback_overview_base_relation_0_102
:description: Supporting qualified literal-overview static base relation without constructor or macro execution
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.4 10.7.1.1 10.7.2.1 10.7.2.2.1 10.7.2.2.2 1.4.3 1800-2023 6.21 8.13 8.16 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_callback_overview_base_relation_0_102.expected
*/
// What it checks:
// It is a control: it supports the setup or conditions of this duty, which
// other tests check directly:
// The callback macro family supports registration and execution of callback
// methods associated with the selected object context.
//
// Variant: Input 0 uses the default specialization uvm_callbacks#(); input 1 a
// specialization with an original object class and an original callback class.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.4 (UVM-CALLBACK-OVERVIEW-REGISTERED-METHOD-EXECUTION-102)
// gives the rule above. Setup: Use a valid object/callback pair registered by
// the documented macro and uvm_callback-derived methods under10.7.1; modify
// named registrations and explicit enabled state between completed implicit or
// external-object invocations. Keep the overview ancestry interpretation
// separate. Expected: Each invocation reaches the enabled callbacks currently
// associated with its selected object, preserving the original object/token,
// ordered transformations and independent peer memberships.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_callback_overview_base_relation_0_102;
  import uvm_pkg::*;
  typedef uvm_callbacks#() literal_registry102;
  // Selected registry-below-callback reading only, with the CB constraint.
  // The opposite chain is permitted by1.4.3 and is not covered here.
  // This conditional control invokes no constructor or macro and proves
  // neither mandatory ancestry nor a standards/library contradiction.
  function automatic uvm_callback convert102(literal_registry102 source_value);
    uvm_callback result_value;
    result_value=source_value;
    return result_value;
  endfunction
  initial begin
    literal_registry102 registry_value;
    uvm_callback callback_value;
    registry_value=null;callback_value=convert102(registry_value);
    $display("UT: literal102 0 null_identity %0d",callback_value==null);
    $finish;
  end
endmodule
