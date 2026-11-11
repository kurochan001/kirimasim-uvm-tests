/*
:name: test_ro_callback_blocks_low_field_backdoor_before_original_provider_access
:description: A registered protection callback rejects the selected real access before transfer
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.11.4.2.1 18.11 18.11.1 18.11.2.2 18.11.2.4 18.4.2.1 18.4.2.2 18.4.4.9 18.4.4.10 18.5.3.2 18.5.5.9 18.5.5.10 18.4.6.2 18.1.2.1 18.1.2.2 18.2.3.6 18.2.5.2 19.4.2.1 19.4.2.2.1 19.4.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 19.5.2.8 6.6.3.2 6.6.5 D.4.5.1 D.4.5.7 10.7.2.5 1800-2023 6.21 8.20 8.21 21.2.1
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers67/protection_fixture67.svh
:expected_exit: 0
:expected_stdout: @test_ro_callback_blocks_low_field_backdoor_before_original_provider_access.expected
*/
// What it checks:
// 1. The predefined RO callback rejects the selected low_field backdoor access
//    with ERROR and failing status.
// 2. A rejected pre-access callback prevents original-provider transfers and
//    storage modification.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.11.4.2.1
//    (UVM-PROTECTION-AUDIT-RO-BLOCK-LOW-FIELD-BACKDOOR) gives rule 1 above.
//    Setup: A registered protection callback rejects the selected real access
//    before transfer. Fresh original sixteen-bit RW models, two contained byte
//    fields and independent frontdoor/backdoor storage; exact message
//    text/count and physical HDL are not prescribed. Expected: The selected
//    attempted access reports ERROR and returns UVM_NOT_OK before any provider
//    transfer; original storage is retained.
// 2. 1800.2-2020 18.11.2.2 (UVM-PROTECTION-AUDIT-RO-ABORT-LOW-FIELD-BACKDOOR)
//    gives rule 2 above. Setup: A registered protection callback rejects the
//    selected real access before transfer. Fresh original sixteen-bit RW
//    models, two contained byte fields and independent frontdoor/backdoor
//    storage; exact message text/count and physical HDL are not prescribed.
//    Expected: All original frontdoor/backdoor transfer counters remain zero
//    and both storage words retain 0x11AD.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original providers and selected callback contracts; no physical HDL.
module test_ro_callback_blocks_low_field_backdoor_before_original_provider_access;
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
      install67(0);access67(1,0,1,UVM_BACKDOOR,status,value);
      $display("UT: %s error %0d status %0d transfers %0d storage %0d",
        "protection_ro_low_field_backdoor",
        catcher.errors>0,status==UVM_NOT_OK,transfers67(),storage67());
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("trial");
  initial begin #200;$fatal(1,"original67 watchdog");end
endmodule
