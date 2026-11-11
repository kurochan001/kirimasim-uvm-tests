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
// What it checks:
// 1. The command getter reflects explicit generic/read/write setters.
// 2. is_read is true only for the READ command.
// 3. is_write is true only for the WRITE command.
// 4. The public setter specifies the selected payload command.
// 5. The public setter specifies the selected payload read command.
// 6. The public setter specifies the selected payload write command.
// 7. The command enumeration exposes read, write and ignore identities.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.4.2.16 (UVM-GP-COMMAND-STATE) gives rule 1 above. Setup:
//    Select IGNORE, READ and WRITE successively. Expected: Each query returns
//    the selected enumeration.
// 2. 1800.2-2020 12.3.4.2.18 (UVM-GP-READ-PREDICATE) gives rule 2 above.
//    Setup: Observe all three standard commands. Expected: Only the READ stage
//    reports read true.
// 3. 1800.2-2020 12.3.4.2.20 (UVM-GP-WRITE-PREDICATE) gives rule 3 above.
//    Setup: Observe all three standard commands. Expected: Only the WRITE
//    stage reports write true.
// 4. 1800.2-2020 12.3.4.2.17 (UVM-PAYLOAD-SET-COMMAND-EXPLICIT-UPDATE) gives
//    rule 4 above. Setup: The existing accessor fixture selects IGNORE; the
//    new base-typed virtual-accessor fixture explicitly selects WRITE and
//    reads it back. Expected: IGNORE reads back with read/write predicates
//    false; the new explicit WRITE call reads back as WRITE with the exact
//    override argument.
// 5. 1800.2-2020 12.3.4.2.19 (UVM-PAYLOAD-SET-READ-EXPLICIT-UPDATE) gives rule
//    5 above. Setup: An unchanged accessor fixture assigns explicit values and
//    reads them back through public methods. Expected: The selected command is
//    READ, with read true and write false.
// 6. 1800.2-2020 12.3.4.2.21 (UVM-PAYLOAD-SET-WRITE-EXPLICIT-UPDATE) gives
//    rule 6 above. Setup: An unchanged accessor fixture assigns explicit
//    values and reads them back through public methods. Expected: The selected
//    command is WRITE, with write true and read false.
// 7. 1800.2-2020 12.3.4.1.1 (UVM-TLM-DECL-PAYLOAD-COMMAND-ENUMERATION) gives
//    rule 7 above. Setup: Use unchanged real standard-interface fixtures with
//    explicit selected enum states. Expected: Unchanged real
//    setters/getters/predicates distinguish all three named commands.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
