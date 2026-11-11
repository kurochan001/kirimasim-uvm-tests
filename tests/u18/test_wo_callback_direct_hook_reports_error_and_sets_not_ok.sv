/*
:name: test_wo_callback_direct_hook_reports_error_and_sets_not_ok
:description: The predefined hook reports an ERROR and changes the operation status
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.11.5.2.1 19.1.1.2.1 19.1.1.2.2 19.1.1.2.3 19.1.1.2.6 18.11 18.11.1 18.11.2.2 18.11.2.4 18.4.2.1 18.4.2.2 18.4.4.9 18.4.4.10 18.5.3.2 18.5.5.9 18.5.5.10 18.4.6.2 18.1.2.1 18.1.2.2 18.2.3.6 18.2.5.2 19.4.2.1 19.4.2.2.1 19.4.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 19.5.2.8 6.6.3.2 6.6.5 D.4.5.1 D.4.5.7 10.7.2.5 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers67/protection_fixture67.svh
:expected_exit: 0
:expected_stdout: @test_wo_callback_direct_hook_reports_error_and_sets_not_ok.expected
*/
// What it checks:
// 1. The predefined rejection hook issues an error.
// 2. The predefined rejection hook sets UVM_NOT_OK.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.11.5.2.1 (UVM-PROTECTION-AUDIT-WO-HOOK-ERROR) gives rule 1
//    above. Setup: The predefined hook reports an ERROR and changes the
//    operation status. Fresh original sixteen-bit RW models, two contained
//    byte fields and independent frontdoor/backdoor storage; exact message
//    text/count and physical HDL are not prescribed. Expected: At least one
//    ERROR is captured for the direct rejecting hook invocation.
// 2. 1800.2-2020 18.11.5.2.1 (UVM-PROTECTION-AUDIT-WO-HOOK-STATUS) gives rule
//    2 above. Setup: The predefined hook reports an ERROR and changes the
//    operation status. Fresh original sixteen-bit RW models, two contained
//    byte fields and independent frontdoor/backdoor storage; exact message
//    text/count and physical HDL are not prescribed. Expected: The item status
//    changes from UVM_IS_OK to UVM_NOT_OK.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original providers and selected callback contracts; no physical HDL.
module test_wo_callback_direct_hook_reports_error_and_sets_not_ok;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "protection_fixture67.svh"
  class trial extends fixture67;
    `uvm_component_utils(trial)
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    virtual task run_phase(uvm_phase phase);
      uvm_status_e status;
      uvm_reg_data_t value;
      phase.raise_objection(this);
      begin
        uvm_reg_write_only_cbs subject=new();
        uvm_reg_item item=new("item67");
        item.set_element(rg[0]);item.set_element_kind(UVM_REG);
        item.set_kind(UVM_READ);item.set_status(UVM_IS_OK);
        subject.pre_read(item);
        $display("UT: protection_wo_hook error %0d status %0d transfers %0d",
          catcher.errors>0,item.get_status()==UVM_NOT_OK,transfers67());
      end
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("trial");
  initial begin #200;$fatal(1,"original67 watchdog");end
endmodule
