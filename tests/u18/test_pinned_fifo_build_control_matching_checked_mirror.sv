/*
:name: test_pinned_fifo_build_control_matching_checked_mirror
:description: Pinned-library build initialization control; constructor-only requirements remain independently measured
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.8.5.6 18.8.3.2 18.8.5.4 18.8 18.8.1 18.8.3.1 18.8.2 18.4.2.2 18.2.3.3 18.2.5.2 19.1.2.2 19.1.2.3 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pinned_fifo_build_control_matching_checked_mirror.expected
:files: helpers63_initialized/fifo_initialized_fixture63.svh
*/
// Explicit pinned-library initialization control, not an IEEE API duty.
// Its result does not pass the separately retained constructor-only input.
module test_pinned_fifo_build_control_matching_checked_mirror;
  import uvm_pkg::*;
  `include "fifo_initialized_fixture63.svh"
  class detail_reports extends fifo_reports63;
    virtual function action_e catch();
      if (gated && (get_severity()==UVM_ERROR || get_severity()==UVM_FATAL))
        $display("DETAIL: mirror_report id <%s> message <%s>",get_id(),get_message());
      return super.catch();
    endfunction
  endclass
  class t extends fifo_env63;
    `uvm_component_utils(t)
    function new(string name,uvm_component parent); super.new(name,parent); endfunction


    virtual task exercise();
      uvm_status_e status;
      detail_reports replacement;
      replacement=new(); uvm_report_cb::delete(null,reports);
      reports=replacement; uvm_report_cb::add(null,reports);
      chosen.fifo='{'h11}; driver.words='{'h11}; chosen.set_compare(UVM_CHECK); reports.gated=1;
      chosen.mirror(status,UVM_CHECK,UVM_FRONTDOOR,mapping); reports.gated=0;
      $display("UT: fifo_matching_mirror status %0d no_error %0d both_popped %0d",
        status==UVM_IS_OK,reports.errors==0,chosen.size()==0 && driver.words.size()==0);
      $display("DETAIL: fifo_state dut_count %0d abstract_count %0d writes %0d reads %0d",
        driver.words.size(),chosen.fifo.size(),driver.fifo_writes,driver.fifo_reads);
      foreach (driver.words[i]) $display("DETAIL: dut_word[%0d] %0h",i,driver.words[i]);
      foreach (chosen.fifo[i]) $display("DETAIL: abstract_word[%0d] %0h",i,chosen.fifo[i]);
    endtask
  endclass
  initial run_test("t");
  initial begin #200; $fatal(1,"FIFO fixture watchdog expired"); end
endmodule
