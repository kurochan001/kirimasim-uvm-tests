/*
:name: test_pinned_fifo_build_control_external_predictor_observation
:description: Pinned-library build initialization control; constructor-only requirements remain independently measured
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.8.5.3 18.8.5.7 19.3.2.1 19.3.2.2 18.8 18.8.1 18.8.3.1 18.8.2 18.4.2.2 18.2.3.3 18.2.5.2 19.1.2.2 19.1.2.3 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pinned_fifo_build_control_external_predictor_observation.expected
:files: helpers63_initialized/fifo_initialized_fixture63.svh
*/
// What it checks:
// It is a control: it supports the setup or conditions of these duties, which
// other tests check directly:
// 1. With auto-prediction off, a returned FIFO write awaits bus observation
//    before abstract prediction.
// 2. A real bus predictor observation updates the FIFO abstract write state.
// 3. The FIFO predict interface accepts the observed write through the
//    standard predictor.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.8.5.3 (UVM-MEM-FIFO-AUDIT-FIFO-EXTERNAL-BEFORE) gives rule
//    1 above. Setup: Use the original one-byte bus FIFO model and independent
//    register control, explicit frontdoor/map and selected auto/external
//    prediction. Preload update occurs before any blocking statement after
//    set. Expected: The DUT model contains 0x35 while the abstract queue is
//    still empty.
// 2. 1800.2-2020 18.8.5.3 (UVM-MEM-FIFO-AUDIT-FIFO-EXTERNAL-AFTER) gives rule
//    2 above. Setup: Use the original one-byte bus FIFO model and independent
//    register control, explicit frontdoor/map and selected auto/external
//    prediction. Preload update occurs before any blocking statement after
//    set. Expected: One published successful observed write produces one
//    abstract 0x35 without another bus transfer.
// 3. 1800.2-2020 18.8.5.7 (UVM-MEM-FIFO-AUDIT-FIFO-EXTERNAL-PREDICT) gives
//    rule 3 above. Setup: Use the original one-byte bus FIFO model and
//    independent register control, explicit frontdoor/map and selected
//    auto/external prediction. Preload update occurs before any blocking
//    statement after set. Expected: The predictor bus_in route updates the
//    selected queue rather than an original testbench mirror implementation.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Explicit pinned-library initialization control, not an IEEE API duty.
// Its result does not pass the separately retained constructor-only input.
module test_pinned_fifo_build_control_external_predictor_observation;
  import uvm_pkg::*;
  `include "fifo_initialized_fixture63.svh"
  class t extends fifo_env63;
    `uvm_component_utils(t)
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    virtual function bit auto_prediction(); return 0; endfunction

    virtual task exercise();
      uvm_status_e status;
      uvm_reg_predictor#(fifo_packet63) predictor;
      fifo_packet63 observation;
      chosen.write(status,'h35,UVM_FRONTDOOR,mapping);
      $display("UT: fifo_external before_observation %0d dut_written %0d",
        chosen.size()==0,status==UVM_IS_OK && driver.words.size()==1 && driver.words[0]=='h35);
      observation=new("observed63"); observation.kind=UVM_WRITE; observation.address=0;
      observation.data='h35; observation.status=UVM_IS_OK;
      predictor=new("predictor63",this); predictor.map=mapping; predictor.adapter=adapter;
      predictor.bus_in.write(observation);
      $display("UT: fifo_external after_observation %0d one_transfer %0d",
        chosen.fifo.size()==1 && chosen.fifo[0]=='h35,driver.fifo_writes==1);
      $display("DETAIL: fifo_state dut_count %0d abstract_count %0d writes %0d reads %0d",
        driver.words.size(),chosen.fifo.size(),driver.fifo_writes,driver.fifo_reads);
      foreach (driver.words[i]) $display("DETAIL: dut_word[%0d] %0h",i,driver.words[i]);
      foreach (chosen.fifo[i]) $display("DETAIL: abstract_word[%0d] %0h",i,chosen.fifo[i]);
    endtask
  endclass
  initial run_test("t");
  initial begin #200; $fatal(1,"FIFO fixture watchdog expired"); end
endmodule
