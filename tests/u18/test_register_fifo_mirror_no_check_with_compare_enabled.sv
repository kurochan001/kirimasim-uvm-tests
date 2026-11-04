/*
:name: test_register_fifo_mirror_no_check_with_compare_enabled
:description: register fifo mirror no check with compare enabled
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.8.5.6 18.8.3.2 18.8.5.4 18.4.4.14 18.8 18.8.1 18.8.3.1 18.8.2 18.4.2.2 18.2.3.3 18.2.5.2 19.1.2.2 19.1.2.3 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_fifo_mirror_no_check_with_compare_enabled.expected
:files: helpers63/fifo_frontdoor_fixture63.svh
*/
module test_register_fifo_mirror_no_check_with_compare_enabled;
  import uvm_pkg::*;
  `include "fifo_frontdoor_fixture63.svh"
  class t extends fifo_env63;
    `uvm_component_utils(t)
    function new(string name,uvm_component parent); super.new(name,parent); endfunction


    virtual task exercise();
      uvm_status_e status;
      chosen.fifo='{'h11}; driver.words='{'h22};
      chosen.set_compare(UVM_CHECK);
      reports.gated=1;
      chosen.mirror(status,UVM_NO_CHECK,UVM_FRONTDOOR,mapping);
      reports.gated=0;
      $display("UT: fifo_mirror comparison_gate %0d physical_read %0d",
        reports.errors==0,driver.fifo_reads==1);
    endtask
  endclass
  initial run_test("t");
  initial begin #200; $fatal(1,"FIFO fixture watchdog expired"); end
endmodule
