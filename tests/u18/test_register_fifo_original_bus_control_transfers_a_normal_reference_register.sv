/*
:name: test_register_fifo_original_bus_control_transfers_a_normal_reference_register
:description: register fifo original bus control transfers a normal reference register
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.4.9 18.4.4.10 18.2.5.1 18.8 18.8.1 18.8.3.1 18.8.2 18.4.2.2 18.2.3.3 18.2.5.2 19.1.2.2 19.1.2.3 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_fifo_original_bus_control_transfers_a_normal_reference_register.expected
:files: helpers63/fifo_frontdoor_fixture63.svh
*/
// What it checks:
// 1. The independent ordinary-register control transfers its selected write
//    through the original bus.
// 2. The independent ordinary-register control reads its selected original bus
//    storage.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.4.4.9 (UVM-MEM-FIFO-AUDIT-REFERENCE-WRITE) gives rule 1
//    above. Setup: Use the same original adapter/sequencer/driver with a
//    standalone configured 8-bit reference register and no FIFO instance.
//    Expected: One write/read pair returns 0x63, successful statuses and
//    exactly two control bus calls.
// 2. 1800.2-2020 18.4.4.10 (UVM-MEM-FIFO-AUDIT-REFERENCE-READ) gives rule 2
//    above. Setup: Use the same original adapter/sequencer/driver with a
//    standalone configured 8-bit reference register and no FIFO instance.
//    Expected: One write/read pair returns 0x63, successful statuses and
//    exactly two control bus calls.
// It also supports, as a control, the setup or conditions of
// UVM-MEM-FIFO-AUDIT-FIFO-WRITE-TRANSFER,
// UVM-MEM-FIFO-AUDIT-FIFO-WRITE-AUTO-PREDICT,
// UVM-MEM-FIFO-AUDIT-FIFO-READ-TRANSFER,
// UVM-MEM-FIFO-AUDIT-FIFO-READ-AUTO-PREDICT,
// UVM-MEM-FIFO-AUDIT-FIFO-EXTERNAL-BEFORE,
// UVM-MEM-FIFO-AUDIT-FIFO-EXTERNAL-AFTER,
// UVM-MEM-FIFO-AUDIT-FIFO-EXTERNAL-PREDICT,
// UVM-MEM-FIFO-AUDIT-FIFO-UPDATE-TRANSFER,
// UVM-MEM-FIFO-AUDIT-FIFO-UPDATE-NO-DUPLICATE,
// UVM-MEM-FIFO-AUDIT-FIFO-UPDATE-NEW-PRELOAD,
// UVM-MEM-FIFO-AUDIT-FIFO-COMPARE-GATE, UVM-MEM-FIFO-AUDIT-FIFO-MIRROR-GATE,
// UVM-MEM-FIFO-AUDIT-FIFO-COMPARE-DEFAULT,
// UVM-MEM-FIFO-AUDIT-FIFO-CHECKED-MATCH-POP.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_register_fifo_original_bus_control_transfers_a_normal_reference_register;
  import uvm_pkg::*;
  `include "fifo_frontdoor_fixture63.svh"
  class t extends fifo_env63;
    `uvm_component_utils(t)
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    virtual function bit include_fifo(); return 0; endfunction

    virtual task exercise();
      $display("UT: reference_only no_fifo %0d",chosen==null);
    endtask
  endclass
  initial run_test("t");
  initial begin #200; $fatal(1,"FIFO fixture watchdog expired"); end
endmodule
