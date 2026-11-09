/*
:name: test_component_config_disabled_user_hook_skips_set_local_for_one_application
:description: disabled configuration user hook suppresses set_local and is reset for later application (13.1.5.1)
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.5.1 5.3.12 5.7.2.7 5.7.2.8 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_config_disabled_user_hook_skips_set_local_for_one_application.expected
*/
// What it checks:
// 1. Disabling the field-operation user hook suppresses the following
//    set_local call.
// 2. A subsequent configuration application can use its enabled user hook
//    after an earlier suppression.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 13.1.5.1 (UVM-COMPONENT-CONFIG-DISABLED-USER-HOOK-SKIP) gives
//    rule 1 above. Setup: Disable the hook in do_execute_op for one matching
//    resource application. Expected: The operation occurs once but no local
//    call occurs and value three is retained.
// 2. 1800.2-2020 13.1.5.1 (UVM-COMPONENT-CONFIG-USER-HOOK-REUSE) gives rule 2
//    above. Setup: Remove the suppression and apply the same resource again.
//    Expected: Two total operations lead to one local write of value 43.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The pinned default name-filter mode skips resources not registered by
// field macros. Retain the normative all-matching-resource expectation.
module test_component_config_disabled_user_hook_skips_set_local_for_one_application;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  // Only explicitly named fixture resources contribute to the observations.
  // Exact rhs handles and per-resource hook ordering define the oracle.
  class configured extends uvm_component;
    uvm_resource#(int) selected;
    int operations = 0;
    int locals = 0;
    int value = 3;
    bit suppress = 0;
    bit exact_rhs = 1;
    bit ordered = 1;
    function new(string name); super.new(name, null); endfunction
    function void do_execute_op(uvm_field_op op);
      uvm_resource#(int) resource;
      super.do_execute_op(op);
      if ($cast(resource, op.get_rhs()) && resource.get_name() == "fixture_knob") begin
        operations++;
        exact_rhs &= resource == selected && op.get_op_type() == UVM_SET;
        if (suppress) op.disable_user_hook();
      end
    endfunction
    function void set_local(uvm_resource_base rsrc);
      uvm_resource#(int) resource;
      if ($cast(resource, rsrc) && resource.get_name() == "fixture_knob") begin
        locals++;
        ordered &= operations == locals;
        value = resource.read(this);
      end
    endfunction
  endclass
  initial begin
    automatic uvm_resource_pool pool = uvm_resource_pool::get();
    automatic configured target = new("target");
    automatic uvm_resource#(int) setting = new("fixture_knob", "target");
    setting.write(43); pool.set_scope(setting, "target"); target.selected = setting;
    target.suppress = 1; target.apply_config_settings();
    $display("UT: suppressed operations %0d locals %0d value %0d rhs %0d",
             target.operations, target.locals, target.value, target.exact_rhs);
    target.suppress = 0; target.apply_config_settings();
    $display("UT: restored operations %0d locals %0d value %0d rhs %0d",
             target.operations, target.locals, target.value, target.exact_rhs);
    $finish;
  end
endmodule
