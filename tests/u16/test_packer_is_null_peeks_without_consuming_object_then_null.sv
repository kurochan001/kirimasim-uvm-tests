/*
:name: test_packer_is_null_peeks_without_consuming_object_then_null
:description: packer null queries preserve state while matching object unpacks advance to following fields (IEEE 1800.2-2020 Section 16.5.4.3)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.5.4.3 16.5.4.2 16.5.4.4 16.5.3.3 16.5.4.9 16.5.4.17 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_packer_is_null_peeks_without_consuming_object_then_null.expected
*/
// What it checks:
// is_null inspects the next object marker without consuming packer state.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.5.4.3 (UVM-PACKER-NULL-PEEK) gives the rule above. Setup:
// Produce null/non-null object streams in both orders and query repeatedly.
// Expected: Repeated results agree, available size stays unchanged and
// subsequent object/tail reads succeed.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use the packer to produce its own object stream. Repeated null
// queries must not consume data; no marker width or encoding is assumed.

module test_packer_is_null_peeks_without_consuming_object_then_null;
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
    int available;
    uvm_integral_t tail;
    source.payload = 173;
    packer.pack_object(source);
    packer.pack_object(null);
    packer.pack_field_int(27, 5);
    available = packer.get_packed_size();
    $display("UT: first_peek %0d %0d", packer.is_null(), packer.is_null());
    $display("UT: peek_keeps_size %0d", packer.get_packed_size() == available);
    packer.unpack_object(target);
    $display("UT: second_peek %0d", packer.is_null());
    packer.unpack_object(null);
    tail = packer.unpack_field_int(5);
    $display("UT: payload %0d tail %0d remaining %0d", target.payload, tail,
        packer.get_packed_size());
    $finish;
  end
endmodule
