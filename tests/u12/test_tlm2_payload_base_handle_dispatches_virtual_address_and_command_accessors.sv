/*
:name: test_tlm2_payload_base_handle_dispatches_virtual_address_and_command_accessors
:description: base-typed payload calls dispatch through virtual address and command accessors (12.3.4.2.15)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.15 12.3.4.2.16 12.3.4.2.17 12.3.4.2.22 12.3.4.2.23 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_base_handle_dispatches_virtual_address_and_command_accessors.expected
*/
// Call the public API through a base-typed handle to the derived payload.
// Counters are reset after construction; no bus target behavior is inferred.
module test_tlm2_payload_base_handle_dispatches_virtual_address_and_command_accessors;
  import uvm_pkg::*;
  class payload extends uvm_tlm_generic_payload;
    int address_sets = 0, address_gets = 0, command_sets = 0, command_gets = 0;
    bit [63:0] seen_address;
    uvm_tlm_command_e seen_command;
    function new(); super.new("payload"); endfunction
    virtual function void set_address(bit [63:0] addr);
      address_sets++; seen_address = addr; super.set_address(addr);
    endfunction
    virtual function bit [63:0] get_address();
      address_gets++; return super.get_address();
    endfunction
    virtual function void set_command(uvm_tlm_command_e command);
      command_sets++; seen_command = command; super.set_command(command);
    endfunction
    virtual function uvm_tlm_command_e get_command();
      command_gets++; return super.get_command();
    endfunction
  endclass
  initial begin
    automatic payload probe = new();
    automatic uvm_tlm_generic_payload base = probe;
    bit [63:0] address_value;
    uvm_tlm_command_e command_value;
    probe.address_sets = 0; probe.address_gets = 0;
    probe.command_sets = 0; probe.command_gets = 0;
    base.set_address(64'hfedc_ba98_7654_3210); base.set_command(UVM_TLM_WRITE_COMMAND);
    address_value = base.get_address(); command_value = base.get_command();
    $display("UT: dispatch address %0d %0d command %0d %0d", probe.address_sets,
             probe.address_gets, probe.command_sets, probe.command_gets);
    $display("UT: values address %h command %0d arguments %0d %0d", address_value,
             command_value == UVM_TLM_WRITE_COMMAND,
             probe.seen_address == 64'hfedc_ba98_7654_3210,
             probe.seen_command == UVM_TLM_WRITE_COMMAND);
    $finish;
  end
endmodule
