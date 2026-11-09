/*
:name: test_component_config_application_matches_scope_and_passes_exact_resource
:description: scope selection dispatches UVM_SET before set_local with the exact resource (13.1.5.1)
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.5.1 5.3.12 5.3.13 5.7.2.4 5.7.2.6 C.2.4.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_config_application_matches_scope_and_passes_exact_resource.expected
*/
// What it checks:
// 1. Configuration application selects matching component-instance scopes and
//    ignores unmatched scopes.
// 2. Each matching resource is dispatched through do_execute_op as UVM_SET
//    with that exact resource as rhs.
// 3. An enabled user hook receives the resource through set_local after its
//    field operation.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 13.1.5.1 (UVM-COMPONENT-CONFIG-SCOPE-SELECTION) gives rule 1
//    above. Setup: Register resources for target and elsewhere, then apply to
//    target and an unmatched peer. Expected: Target processes its resource
//    once; the peer has no operations or local writes and retains its value.
// 2. 1800.2-2020 13.1.5.1 (UVM-COMPONENT-CONFIG-SET-OPERATION-EXACT-RHS) gives
//    rule 2 above. Setup: Compare the callback rhs handle and operation type
//    with the registered selected resource. Expected: One operation observes
//    the exact handle and UVM_SET.
// 3. 1800.2-2020 13.1.5.1 (UVM-COMPONENT-CONFIG-SET-LOCAL-AFTER-OPERATION)
//    gives rule 3 above. Setup: Count per-resource callback order and read the
//    integer resource in the user hook. Expected: set_local follows the
//    operation exactly once and installs value 37.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The pinned default name-filter mode skips resources not registered by
// field macros. Retain the normative all-matching-resource expectation.
module test_component_config_application_matches_scope_and_passes_exact_resource;
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
    automatic configured peer = new("peer");
    automatic uvm_resource#(int) local_setting = new("fixture_knob", "target");
    automatic uvm_resource#(int) other_setting = new("fixture_knob", "elsewhere");
    local_setting.write(37); other_setting.write(91);
    pool.set_scope(local_setting, "target"); pool.set_scope(other_setting, "elsewhere");
    target.selected = local_setting;
    target.apply_config_settings(); peer.apply_config_settings();
    $display("UT: selected operations %0d locals %0d value %0d rhs %0d order %0d",
             target.operations, target.locals, target.value, target.exact_rhs, target.ordered);
    $display("UT: unmatched operations %0d locals %0d value %0d",
             peer.operations, peer.locals, peer.value);
    $finish;
  end
endmodule
