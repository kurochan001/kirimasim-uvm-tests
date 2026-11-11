/*
:name: test_packer_unpack_object_orders_hooks_inside_active_stack
:description: object unpacking invokes execute before the unpack hook while the target is active (IEEE 1800.2-2020 Section 16.5.4.4)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.5.4.4 16.5.4.2 5.3.13 5.3.11.2 16.1.3.1 16.1.3.2 16.1.3.3 16.1.3.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_packer_unpack_object_orders_hooks_inside_active_stack.expected
*/
// What it checks:
// Object unpack calls its operation hook before the enabled user hook while
// the target is active.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.5.4.4 (UVM-PACKER-UNPACK-HOOK-ORDER) gives the rule above.
// Setup: Unpack a valid nonnull stream into an allocated target that records
// policy/active-object identities. Expected: Both hooks see the same
// target/policy at depth 1, the payload restores and the stack returns empty.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Produce a valid non-null stream, then observe the allocated target
// during unpack. No callbacks are observed for the source packing step.

module test_packer_unpack_object_orders_hooks_inside_active_stack;
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
    automatic packet source = new("source");
    automatic packet target = new("target");
    source.payload = 17;
    packer.pack_object(source);
    target.watch = 1;
    target.expected_packer = packer;
    packer.unpack_object(target);
    $display("UT: after execute %0d unpack %0d payload %0d empty %0d depth %0d",
        target.execute_calls,
             target.unpack_calls, target.payload, packer.get_active_object() == null,
                 packer.get_active_object_depth());
    $finish;
  end
endmodule
