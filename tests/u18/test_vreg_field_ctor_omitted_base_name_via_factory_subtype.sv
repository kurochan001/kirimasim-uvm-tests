/*
:name: test_vreg_field_ctor_omitted_base_name_via_factory_subtype
:description: The actual virtual-field constructor preserves the selected omitted or explicit name form.
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.10.2.1 18.10.1 5.3.4.2 D.2.1.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_field_ctor_omitted_base_name_via_factory_subtype.expected
:files: helpers71/vreg_field_constructor71.svh
*/
// Original observations; printed pool/item return premises stay separate.
module
  test_vreg_field_ctor_omitted_base_name_via_factory_subtype;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "vreg_field_constructor71.svh"
initial begin
    automatic default_field71 subject=default_field71::type_id::create("factory_argument71");
    automatic uvm_vreg_field base_view=subject;
    $display("UT: field_ctor_omitted captured %s identity %0d",
      subject.constructor_name,base_view==subject);
    $finish;
  end
endmodule
