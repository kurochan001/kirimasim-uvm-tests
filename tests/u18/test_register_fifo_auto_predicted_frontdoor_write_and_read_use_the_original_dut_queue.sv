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
