/*
:name: test_field_op_rejects_combined_pack_unpack_flags
:description: field operation set reports an error for multiple operation flags (IEEE 1800.2-2020 Section 5.7.2.2)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.7.2.2 5.7.2.9 5.7.2.3 5.7.2.4 6.5.1.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_field_op_rejects_combined_pack_unpack_flags.expected
*/
// Combine two reserved operation bits. Discard the invalid state,
// flush, and demonstrate reuse with one valid operation.

module test_field_op_rejects_combined_pack_unpack_flags;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_field_op operation = new;
    automatic uvm_root root = uvm_root::get();
    automatic uvm_report_server server = uvm_report_server::get_server();
    int errors;
    root.set_report_severity_action(UVM_ERROR, UVM_DISPLAY);
    errors = server.get_severity_count(UVM_ERROR);
    operation.set(UVM_PACK | UVM_UNPACK);
    $display("UT: combined_flags_report_error %0d", server.get_severity_count(UVM_ERROR) > errors);
    operation.flush();
    operation.set(UVM_RECORD);
    $display("UT: reused name %s type_matches %0d", operation.get_op_name(),
        operation.get_op_type() == UVM_RECORD);
    $finish;
  end
endmodule
