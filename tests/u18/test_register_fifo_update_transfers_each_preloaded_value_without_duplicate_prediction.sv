/*
:name: test_register_fifo_update_transfers_each_preloaded_value_without_duplicate_prediction
:description: register fifo update transfers each preloaded value without duplicate prediction
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.8.5.5 18.8.5.2 18.8.5.3 18.8 18.8.1 18.8.3.1 18.8.2 18.4.2.2 18.2.3.3 18.2.5.2 19.1.2.2 19.1.2.3 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_fifo_update_transfers_each_preloaded_value_without_duplicate_prediction.expected
:files: helpers63/fifo_frontdoor_fixture63.svh
*/
module test_register_fifo_update_transfers_each_preloaded_value_without_duplicate_prediction;
  import uvm_pkg::*;
  `include "fifo_frontdoor_fixture63.svh"
  class t extends fifo_env63;
    `uvm_component_utils(t)
    function new(string name,uvm_component parent); super.new(name,parent); endfunction


    virtual task exercise();
      uvm_status_e status;
      // No blocking statement occurs between the preload calls and update.
      chosen.set('h11); chosen.set('h22); chosen.update(status,UVM_FRONTDOOR,mapping);
      $display("UT: fifo_update status %0d dut_order %0d abstract_once %0d transfers %0d",
        status==UVM_IS_OK,driver.words.size()==2 && driver.words[0]=='h11 && driver.words[1]=='h22,
        chosen.fifo.size()==2 && chosen.fifo[0]=='h11 && chosen.fifo[1]=='h22,
        driver.fifo_writes==2);
    endtask
  endclass
  initial run_test("t");
  initial begin #200; $fatal(1,"FIFO fixture watchdog expired"); end
endmodule
