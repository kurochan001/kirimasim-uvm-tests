/*
:name: test_packer_unpack_object_rejects_nonnull_into_null
:description: unpacking an object with an incompatible null argument reports an error (IEEE 1800.2-2020 Section 16.5.4.4)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.5.4.4 16.5.4.2 6.5.1.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_packer_unpack_object_rejects_nonnull_into_null.expected
*/
// What it checks:
// Object unpack reports an error when target nullness disagrees with the next
// object marker.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.5.4.4 (UVM-PACKER-UNPACK-INCOMPATIBLE-NULL) gives the rule
// above. Setup: Test both null-target/non-null-stream and
// non-null-target/null-stream combinations. Expected: Both incompatible cases
// report an error.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use a stream produced by pack_object and an incompatible target.
// After the required error, do not call any further unpack op.

module test_packer_unpack_object_rejects_nonnull_into_null;
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
    automatic uvm_root root = uvm_root::get();
    automatic uvm_report_server server = uvm_report_server::get_server();
    int errors;
    root.set_report_severity_action(UVM_ERROR, UVM_DISPLAY);
    packer.pack_object(value);
    errors = server.get_severity_count(UVM_ERROR);
    packer.unpack_object(null);
    $display("UT: incompatible_target_reports_error %0d",
        server.get_severity_count(UVM_ERROR) > errors);
    $finish;
  end
endmodule
