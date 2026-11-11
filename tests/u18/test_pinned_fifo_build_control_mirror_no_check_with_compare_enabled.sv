/*
:name: test_pinned_fifo_build_control_mirror_no_check_with_compare_enabled
:description: Pinned-library build initialization control; constructor-only requirements remain independently measured
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.8.5.6 18.8.3.2 18.8.5.4 18.4.4.14 18.8 18.8.1 18.8.3.1 18.8.2 18.4.2.2 18.2.3.3 18.2.5.2 19.1.2.2 19.1.2.3 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pinned_fifo_build_control_mirror_no_check_with_compare_enabled.expected
:files: helpers63_initialized/fifo_initialized_fixture63.svh
*/
// What it checks:
// It is a control: it supports the setup or conditions of these duties, which
// other tests check directly:
// 1. FIFO mismatch checking requires both the mirror check argument and the
//    compare policy to be enabled.
// 2. Selected FIFO mirrors apply the joint checking condition while physically
//    reading the DUT FIFO.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.8.3.2 (UVM-MEM-FIFO-AUDIT-FIFO-COMPARE-GATE) gives rule 1
//    above. Setup: Independently compile four CHECK/NO_CHECK combinations with
//    a deliberate 0x11 abstract versus 0x22 physical mismatch and
//    auto-prediction enabled. Expected: Only both-enabled reports ERROR/FATAL;
//    every matrix member performs one physical read.
// 2. 1800.2-2020 18.8.5.6 (UVM-MEM-FIFO-AUDIT-FIFO-MIRROR-GATE) gives rule 2
//    above. Setup: Independently compile four CHECK/NO_CHECK combinations with
//    a deliberate 0x11 abstract versus 0x22 physical mismatch and
//    auto-prediction enabled. Expected: Only both-enabled reports ERROR/FATAL;
//    every matrix member performs one physical read.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Explicit pinned-library initialization control, not an IEEE API duty.
// Its result does not pass the separately retained constructor-only input.
module test_pinned_fifo_build_control_mirror_no_check_with_compare_enabled;
  import uvm_pkg::*;
  `include "fifo_initialized_fixture63.svh"
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
