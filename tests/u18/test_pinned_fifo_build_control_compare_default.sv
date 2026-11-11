/*
:name: test_pinned_fifo_build_control_compare_default
:description: Pinned-library build initialization control; constructor-only requirements remain independently measured
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.8.3.2 18.8.5.6 18.4.4.14 18.8 18.8.1 18.8.3.1 18.8.2 18.4.2.2 18.2.3.3 18.2.5.2 19.1.2.2 19.1.2.3 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pinned_fifo_build_control_compare_default.expected
:files: helpers63_initialized/fifo_initialized_fixture63.svh
*/
// What it checks:
// It is a control: it supports the setup or conditions of this duty, which
// other tests check directly:
// Omitting set_compare selects UVM_CHECK for a checked FIFO mirror.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.8.3.2 (UVM-MEM-FIFO-AUDIT-FIFO-COMPARE-DEFAULT) gives the
// rule above. Setup: Call set_compare with no argument, then a checked mirror
// against an intentionally different original DUT front. Expected: An
// ERROR/FATAL mismatch notification accompanies one physical read.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Explicit pinned-library initialization control, not an IEEE API duty.
// Its result does not pass the separately retained constructor-only input.
module test_pinned_fifo_build_control_compare_default;
  import uvm_pkg::*;
  `include "fifo_initialized_fixture63.svh"
  class t extends fifo_env63;
    `uvm_component_utils(t)
    function new(string name,uvm_component parent); super.new(name,parent); endfunction


    virtual task exercise();
      uvm_status_e status;
      chosen.fifo='{'h11}; driver.words='{'h22}; chosen.set_compare(); reports.gated=1;
      chosen.mirror(status,UVM_CHECK,UVM_FRONTDOOR,mapping); reports.gated=0;
      $display("UT: fifo_compare_default mismatch_reported %0d physical_read %0d",
        reports.errors>0,driver.fifo_reads==1);
    endtask
  endclass
  initial run_test("t");
  initial begin #200; $fatal(1,"FIFO fixture watchdog expired"); end
endmodule
