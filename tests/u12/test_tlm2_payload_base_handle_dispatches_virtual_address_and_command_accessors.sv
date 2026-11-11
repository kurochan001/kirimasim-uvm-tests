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
// What it checks:
// 1. A base-typed generic-payload call to set_address dispatches to its
//    derived override.
// 2. A base-typed generic-payload call to get_address dispatches to its
//    derived override.
// 3. A base-typed generic-payload call to set_command dispatches to its
//    derived override.
// 4. A base-typed generic-payload call to get_command dispatches to its
//    derived override.
// 5. The public setter specifies the selected payload command.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.4.2.15 (UVM-PAYLOAD-VIRTUAL-SET-ADDRESS) gives rule 1
//    above. Setup: A derived payload forwards to the standard implementation;
//    counters are reset after construction and each selected public method is
//    called once. Expected: The set_address override records one call and the
//    selected values are preserved.
// 2. 1800.2-2020 12.3.4.2.15 (UVM-PAYLOAD-VIRTUAL-GET-ADDRESS) gives rule 2
//    above. Setup: A derived payload forwards to the standard implementation;
//    counters are reset after construction and each selected public method is
//    called once. Expected: The get_address override records one call and the
//    selected values are preserved.
// 3. 1800.2-2020 12.3.4.2.15 (UVM-PAYLOAD-VIRTUAL-SET-COMMAND) gives rule 3
//    above. Setup: A derived payload forwards to the standard implementation;
//    counters are reset after construction and each selected public method is
//    called once. Expected: The set_command override records one call and the
//    selected values are preserved.
// 4. 1800.2-2020 12.3.4.2.15 (UVM-PAYLOAD-VIRTUAL-GET-COMMAND) gives rule 4
//    above. Setup: A derived payload forwards to the standard implementation;
//    counters are reset after construction and each selected public method is
//    called once. Expected: The get_command override records one call and the
//    selected values are preserved.
// 5. 1800.2-2020 12.3.4.2.17 (UVM-PAYLOAD-SET-COMMAND-EXPLICIT-UPDATE) gives
//    rule 5 above. Setup: The existing accessor fixture selects IGNORE; the
//    new base-typed virtual-accessor fixture explicitly selects WRITE and
//    reads it back. Expected: IGNORE reads back with read/write predicates
//    false; the new explicit WRITE call reads back as WRITE with the exact
//    override argument.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
