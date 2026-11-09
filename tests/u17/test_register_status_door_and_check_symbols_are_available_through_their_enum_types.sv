/*
:name: test_register_status_door_and_check_symbols_are_available_through_their_enum_types
:description: register status door and check symbols are available through their enum types (IEEE 1800.2-2020 Section 17.2.2.1)
:tags: u17 uvm
:type: simulation
:lrm: 1800.2-2020 17.2.2.1 17.2.2.2 17.2.2.3 1800-2023 6.21 6.19
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_status_door_and_check_symbols_are_available_through_their_enum_types.expected
*/
// What it checks:
// 1. uvm_status_e makes its documented named alternatives available.
// 2. uvm_door_e makes its documented named alternatives available.
// 3. uvm_check_e makes its documented named alternatives available.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 17.2.2.1 (UVM-REG-GLOBAL-STATUS-SYMBOLS) gives rule 1 above.
//    Setup: Each documented alternative is assigned in turn to a variable of
//    the public enum type. Expected: The assigned enum value identifies the
//    selected symbol by its standard SystemVerilog name query.
// 2. 1800.2-2020 17.2.2.2 (UVM-REG-GLOBAL-DOOR-SYMBOLS) gives rule 2 above.
//    Setup: Each documented alternative is assigned in turn to a variable of
//    the public enum type. Expected: The assigned enum value identifies the
//    selected symbol by its standard SystemVerilog name query.
// 3. 1800.2-2020 17.2.2.3 (UVM-REG-GLOBAL-CHECK-SYMBOLS) gives rule 3 above.
//    Setup: Each documented alternative is assigned in turn to a variable of
//    the public enum type. Expected: The assigned enum value identifies the
//    selected symbol by its standard SystemVerilog name query.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Typed assignment and enum names check declared symbols, not their numeric
// encoding or downstream register-operation semantics. UVM_HAS_X availability
// does not establish four-state execution.
module test_register_status_door_and_check_symbols_are_available_through_their_enum_types;
  import uvm_pkg::*;
  initial begin
    uvm_status_e status;
    uvm_door_e door;
    uvm_check_e check_mode;
    status = UVM_IS_OK; $display("UT: status %s", status.name());
    status = UVM_NOT_OK; $display("UT: status %s", status.name());
    status = UVM_HAS_X; $display("UT: status %s", status.name());
    door = UVM_FRONTDOOR; $display("UT: door %s", door.name());
    door = UVM_BACKDOOR; $display("UT: door %s", door.name());
    door = UVM_PREDICT; $display("UT: door %s", door.name());
    door = UVM_DEFAULT_DOOR; $display("UT: door %s", door.name());
    check_mode = UVM_NO_CHECK; $display("UT: check %s", check_mode.name());
    check_mode = UVM_CHECK; $display("UT: check %s", check_mode.name());
    $finish;
  end
endmodule
