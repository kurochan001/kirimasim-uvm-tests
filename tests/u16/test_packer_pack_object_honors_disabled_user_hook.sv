/*
:name: test_packer_pack_object_honors_disabled_user_hook
:description: object packing skips the pack hook when execute disables it (IEEE 1800.2-2020 Section 16.5.4.2)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.5.4.2 5.3.13 5.7.2.8 16.1.3.3 16.1.3.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_packer_pack_object_honors_disabled_user_hook.expected
*/
// The execute method disables its user hook. Check callback counts and
// stack cleanup without depending on the remaining packed representation.

module test_packer_pack_object_honors_disabled_user_hook;
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
    value.suppress_hook = 1;
    packer.pack_object(value);
    $display("UT: execute %0d pack %0d empty %0d depth %0d", value.execute_calls, value.pack_calls,
             packer.get_active_object() == null, packer.get_active_object_depth());
    $finish;
  end
endmodule
