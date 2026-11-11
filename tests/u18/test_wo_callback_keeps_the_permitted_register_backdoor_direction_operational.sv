/*
:name: test_wo_callback_keeps_the_permitted_register_backdoor_direction_operational
:description: The predefined protection callback preserves the opposite permitted access direction
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.11.5 18.11 18.11.1 18.11.2.2 18.11.2.4 18.4.2.1 18.4.2.2 18.4.4.9 18.4.4.10 18.5.3.2 18.5.5.9 18.5.5.10 18.4.6.2 18.1.2.1 18.1.2.2 18.2.3.6 18.2.5.2 19.4.2.1 19.4.2.2.1 19.4.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 19.5.2.8 6.6.3.2 6.6.5 D.4.5.1 D.4.5.7 10.7.2.5 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers67/protection_fixture67.svh
:expected_exit: 0
:expected_stdout: @test_wo_callback_keeps_the_permitted_register_backdoor_direction_operational.expected
*/
// What it checks:
// The predefined WO callback leaves the selected opposite register backdoor
// direction operational.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.11.5 (UVM-PROTECTION-AUDIT-WO-PERMITTED-REGISTER-BACKDOOR)
// gives the rule above. Setup: The predefined protection callback preserves
// the opposite permitted access direction. Fresh original sixteen-bit RW
// models, two contained byte fields and independent frontdoor/backdoor
// storage; exact message text/count and physical HDL are not prescribed.
// Expected: The permitted read returns the original selected data, or the
// permitted write updates the supplied selected data, with UVM_IS_OK, provider
// activity and no ERROR.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original providers and selected callback contracts; no physical HDL.
module test_wo_callback_keeps_the_permitted_register_backdoor_direction_operational;
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
      install67(1);access67(0,0,1,UVM_BACKDOOR,status,value);
      $display("UT: protection_wo_allow_register_backdoor allowed %0d error %0d provider %0d",
        allowed67(0,0,1,UVM_BACKDOOR,status,value),catcher.errors,transfers67()>0);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("trial");
  initial begin #200;$fatal(1,"original67 watchdog");end
endmodule
