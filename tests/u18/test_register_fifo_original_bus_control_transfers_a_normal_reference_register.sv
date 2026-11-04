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
