/*
:name: test_wo_callback_add_reaches_the_register_and_both_contained_fields
:description: Adding a protection callback registers it on the selected register and every contained field
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.11.5.2.2 18.11 18.11.1 18.11.2.2 18.11.2.4 18.4.2.1 18.4.2.2 18.4.4.9 18.4.4.10 18.5.3.2 18.5.5.9 18.5.5.10 18.4.6.2 18.1.2.1 18.1.2.2 18.2.3.6 18.2.5.2 19.4.2.1 19.4.2.2.1 19.4.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 19.5.2.8 6.6.3.2 6.6.5 D.4.5.1 D.4.5.7 10.7.2.5 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers67/protection_fixture67.svh
:expected_exit: 0
:expected_stdout: @test_wo_callback_add_reaches_the_register_and_both_contained_fields.expected
*/
// What it checks:
// 1. Protection add attaches the callback to the specified register.
// 2. Protection add attaches the callback to all selected contained fields.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.11.5.2.2 (UVM-PROTECTION-AUDIT-WO-ADD-REGISTER) gives rule
//    1 above. Setup: Adding a protection callback registers it on the selected
//    register and every contained field. Fresh original sixteen-bit RW models,
//    two contained byte fields and independent frontdoor/backdoor storage;
//    exact message text/count and physical HDL are not prescribed. Expected:
//    The selected concrete callback family is present on the register after
//    add.
// 2. 1800.2-2020 18.11.5.2.2 (UVM-PROTECTION-AUDIT-WO-ADD-FIELDS) gives rule 2
//    above. Setup: Adding a protection callback registers it on the selected
//    register and every contained field. Fresh original sixteen-bit RW models,
//    two contained byte fields and independent frontdoor/backdoor storage;
//    exact message text/count and physical HDL are not prescribed. Expected:
//    Both the lower and upper byte field have the selected callback family
//    after add.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original providers and selected callback contracts; no physical HDL.
module test_wo_callback_add_reaches_the_register_and_both_contained_fields;
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
      install67(1);
      $display("UT: protection_wo_members register %0d low %0d high %0d",
        members67(1,0)>0,members67(1,1)>0,members67(1,2)>0);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("trial");
  initial begin #200;$fatal(1,"original67 watchdog");end
endmodule
