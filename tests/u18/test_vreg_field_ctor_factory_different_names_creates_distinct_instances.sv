/*
:name: test_vreg_field_ctor_factory_different_names_creates_distinct_instances
:description: Factory creation supplies distinct virtual-field instances with the specified names.
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.10.2.1 18.10.1 5.3.4.2 D.2.1.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_field_ctor_factory_different_names_creates_distinct_instances.expected
*/
// Original observations; printed pool/item return premises stay separate.
module
  test_vreg_field_ctor_factory_different_names_creates_distinct_instances;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
initial begin
    automatic uvm_vreg_field first=uvm_vreg_field::type_id::create("field_a71");
    automatic uvm_vreg_field second=uvm_vreg_field::type_id::create("field_b71");
    $display("UT: field_factory_different_names nonnull %0d distinct %0d names %0d",
      first!=null && second!=null,first!=second,
      first.get_name()=="field_a71" && second.get_name()=="field_b71");
    $finish;
  end
endmodule
