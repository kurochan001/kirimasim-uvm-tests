/*
:name: test_packer_unpack_object_honors_disabled_user_hook
:description: object unpacking skips the unpack hook when execute disables it (IEEE 1800.2-2020 Section 16.5.4.4)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.5.4.4 16.5.4.2 5.3.13 5.7.2.8 16.1.3.3 16.1.3.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_packer_unpack_object_honors_disabled_user_hook.expected
*/
// What it checks:
// Object unpack omits do_unpack when its operation hook disables user
// processing.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.5.4.4 (UVM-PACKER-UNPACK-HOOK-GATE) gives the rule above.
// Setup: Only the disabled unpack hook could otherwise alter the target
// payload. Expected: The operation hook runs once, do_unpack stays at zero and
// payload/stack remain as expected.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Only the user unpack hook changes payload in this test class.
// Disable it on the target, then observe callback counts and stack cleanup.

module test_packer_unpack_object_honors_disabled_user_hook;
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
    target.payload = 91;
    target.suppress_hook = 1;
    packer.unpack_object(target);
    $display("UT: execute %0d unpack %0d payload %0d empty %0d depth %0d", target.execute_calls,
             target.unpack_calls, target.payload, packer.get_active_object() == null,
                 packer.get_active_object_depth());
    $finish;
  end
endmodule
