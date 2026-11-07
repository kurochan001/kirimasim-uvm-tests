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
