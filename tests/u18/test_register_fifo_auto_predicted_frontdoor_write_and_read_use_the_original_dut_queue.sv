/*
:name: test_register_fifo_auto_predicted_frontdoor_write_and_read_use_the_original_dut_queue
:description: register fifo auto predicted frontdoor write and read use the original dut queue
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.8.5.3 18.8.5.4 18.8 18.8.1 18.8.3.1 18.8.2 18.4.2.2 18.2.3.3 18.2.5.2 19.1.2.2 19.1.2.3 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_fifo_auto_predicted_frontdoor_write_and_read_use_the_original_dut_queue.expected
:files: helpers63/fifo_frontdoor_fixture63.svh
*/
// What it checks:
// 1. A FIFO frontdoor write pushes the supplied value to the original DUT
//    queue.
// 2. Auto-predicted FIFO writes append to the abstract queue before returning.
// 3. A FIFO frontdoor read returns and removes the next original DUT value.
// 4. An auto-predicted FIFO read pops the abstract front.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.8.5.3 (UVM-MEM-FIFO-AUDIT-FIFO-WRITE-TRANSFER) gives rule
//    1 above. Setup: Use the original one-byte bus FIFO model and independent
//    register control, explicit frontdoor/map and selected auto/external
//    prediction. Preload update occurs before any blocking statement after
//    set. Expected: The driver receives one successful write with 0x11 at the
//    FIFO port.
// 2. 1800.2-2020 18.8.5.3 (UVM-MEM-FIFO-AUDIT-FIFO-WRITE-AUTO-PREDICT) gives
//    rule 2 above. Setup: Use the original one-byte bus FIFO model and
//    independent register control, explicit frontdoor/map and selected
//    auto/external prediction. Preload update occurs before any blocking
//    statement after set. Expected: The returned call leaves one 0x11 abstract
//    entry.
// 3. 1800.2-2020 18.8.5.4 (UVM-MEM-FIFO-AUDIT-FIFO-READ-TRANSFER) gives rule 3
//    above. Setup: Use the original one-byte bus FIFO model and independent
//    register control, explicit frontdoor/map and selected auto/external
//    prediction. Preload update occurs before any blocking statement after
//    set. Expected: A successful read returns 0x11 and empties the physical
//    model queue.
// 4. 1800.2-2020 18.8.5.4 (UVM-MEM-FIFO-AUDIT-FIFO-READ-AUTO-PREDICT) gives
//    rule 4 above. Setup: Use the original one-byte bus FIFO model and
//    independent register control, explicit frontdoor/map and selected
//    auto/external prediction. Preload update occurs before any blocking
//    statement after set. Expected: Both selected model and abstract queues
//    are empty after one write/read pair.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_register_fifo_auto_predicted_frontdoor_write_and_read_use_the_original_dut_queue;
  import uvm_pkg::*;
  `include "fifo_frontdoor_fixture63.svh"
  class t extends fifo_env63;
    `uvm_component_utils(t)
    function new(string name,uvm_component parent); super.new(name,parent); endfunction


    virtual task exercise();
      uvm_status_e status;
      uvm_reg_data_t value;
      bit write_ok;
      chosen.write(status,'h11,UVM_FRONTDOOR,mapping); write_ok=status==UVM_IS_OK;
      $display("UT: fifo_write dut %0d abstract %0d",
        write_ok && driver.words.size()==1 && driver.words[0]=='h11,
        chosen.fifo.size()==1 && chosen.fifo[0]=='h11);
      chosen.read(status,value,UVM_FRONTDOOR,mapping);
      $display("UT: fifo_read value %0d both_popped %0d transfers %0d",
        status==UVM_IS_OK && value=='h11,chosen.size()==0 && driver.words.size()==0,
        driver.fifo_writes==1 && driver.fifo_reads==1);
    endtask
  endclass
  initial run_test("t");
  initial begin #200; $fatal(1,"FIFO fixture watchdog expired"); end
endmodule
