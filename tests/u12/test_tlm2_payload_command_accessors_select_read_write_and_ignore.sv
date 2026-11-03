/*
:name: test_tlm2_payload_command_accessors_select_read_write_and_ignore
:description: generic payload command accessors select mutually exclusive command states (IEEE 1800.2-2020 Section 12.3.4.2.16)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.16 12.3.4.2.17 12.3.4.2.18 12.3.4.2.19 12.3.4.2.20 12.3.4.2.21 12.3.4.1.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_command_accessors_select_read_write_and_ignore.expected
*/
// Assign each command explicitly. No observation depends on the
// constructor default or on numeric enumeration values.

module test_tlm2_payload_command_accessors_select_read_write_and_ignore;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_tlm_generic_payload payload = new("payload");
    payload.set_command(UVM_TLM_IGNORE_COMMAND);
    $display("UT: ignore %0d read %0d write %0d", payload.get_command() == UVM_TLM_IGNORE_COMMAND,
             payload.is_read(), payload.is_write());
    payload.set_read();
    $display("UT: read_command %0d read %0d write %0d",
        payload.get_command() == UVM_TLM_READ_COMMAND,
             payload.is_read(), payload.is_write());
    payload.set_write();
    $display("UT: write_command %0d read %0d write %0d",
        payload.get_command() == UVM_TLM_WRITE_COMMAND,
             payload.is_read(), payload.is_write());
    $finish;
  end
endmodule
