/*
:name: test_packer_pack_object_orders_hooks_inside_active_stack
:description: object packing invokes execute before the pack hook while the object is active (IEEE 1800.2-2020 Section 16.5.4.2)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.5.4.2 5.3.13 5.3.10.2 16.1.3.1 16.1.3.2 16.1.3.3 16.1.3.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_packer_pack_object_orders_hooks_inside_active_stack.expected
*/
// What it checks:
// Object packing invokes the operation hook before do_pack while the object is
// active, then restores the stack.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.5.4.2 (UVM-PACKER-OBJECT-HOOKS) gives the rule above. Setup:
// A pack-enabled object records policy identity, active object and stack depth
// in both hooks. Expected: Both hooks see the same active object at depth 1;
// afterward the stack is empty.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe only the documented operation policy, hook order and active
// object stack. The packed object marker representation is not inspected.

module test_packer_pack_object_orders_hooks_inside_active_stack;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_object;
    `uvm_object_utils(packet)
    bit [7:0] payload;
    bit watch;
    bit suppress_hook;
    int execute_calls = 0;
    int pack_calls = 0;
    int unpack_calls = 0;
    uvm_packer expected_packer;
    function new(string name="packet"); super.new(name); endfunction
    function void do_execute_op(uvm_field_op op);
      uvm_packer packer;
      if (!$cast(packer, op.get_policy()) || packer == null) $fatal(1,
          "packer not supplied");
      execute_calls++;
      if (watch) $display("UT: execute %s policy_same %0d active_same %0d depth %0d",
          op.get_op_name(),
                          packer == expected_packer, packer.get_active_object() == this,
                              packer.get_active_object_depth());
      if (suppress_hook) op.disable_user_hook();
    endfunction
    function void do_pack(uvm_packer packer);
      pack_calls++;
      if (watch) $display("UT: do_pack active_same %0d depth %0d",
          packer.get_active_object() == this, packer.get_active_object_depth());
      packer.pack_field_int(payload, 8);
    endfunction
    function void do_unpack(uvm_packer packer);
      unpack_calls++;
      if (watch) $display("UT: do_unpack active_same %0d depth %0d",
          packer.get_active_object() == this, packer.get_active_object_depth());
      payload = packer.unpack_field_int(8);
    endfunction
  endclass

  initial begin
    automatic uvm_packer packer = new;
    automatic packet value = new("value");
    value.watch = 1;
    value.expected_packer = packer;
    packer.pack_object(value);
    $display("UT: after execute %0d pack %0d empty %0d depth %0d", value.execute_calls,
        value.pack_calls,
             packer.get_active_object() == null, packer.get_active_object_depth());
    $finish;
  end
endmodule
