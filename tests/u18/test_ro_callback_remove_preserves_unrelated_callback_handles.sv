/*
:name: test_ro_callback_remove_preserves_unrelated_callback_handles
:description: Removing the selected protection callback leaves independent callback identities registered
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.11.4.2.3 10.7.2.3.1 10.7.2.3.3 18.11 18.11.1 18.11.2.2 18.11.2.4 18.4.2.1 18.4.2.2 18.4.4.9 18.4.4.10 18.5.3.2 18.5.5.9 18.5.5.10 18.4.6.2 18.1.2.1 18.1.2.2 18.2.3.6 18.2.5.2 19.4.2.1 19.4.2.2.1 19.4.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 19.5.2.8 6.6.3.2 6.6.5 D.4.5.1 D.4.5.7 10.7.2.5 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers67/protection_fixture67.svh
:expected_exit: 0
:expected_stdout: @test_ro_callback_remove_preserves_unrelated_callback_handles.expected
*/
// What it checks:
// 1. Protection remove detaches it from the specified register.
// 2. Protection remove detaches it from the contained fields while retaining
//    other callbacks.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.11.4.2.3 (UVM-PROTECTION-AUDIT-RO-REMOVE-REGISTER) gives
//    rule 1 above. Setup: Removing the selected protection callback leaves
//    independent callback identities registered. Fresh original sixteen-bit RW
//    models, two contained byte fields and independent frontdoor/backdoor
//    storage; exact message text/count and physical HDL are not prescribed.
//    Expected: The selected protection family is absent from the register
//    after remove.
// 2. 1800.2-2020 18.11.4.2.3 (UVM-PROTECTION-AUDIT-RO-REMOVE-FIELDS) gives
//    rule 2 above. Setup: Removing the selected protection callback leaves
//    independent callback identities registered. Fresh original sixteen-bit RW
//    models, two contained byte fields and independent frontdoor/backdoor
//    storage; exact message text/count and physical HDL are not prescribed.
//    Expected: Both fields lose the selected protection callback; all three
//    unrelated sentinel registrations retain exact handle identity.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original providers and selected callback contracts; no physical HDL.
module test_ro_callback_remove_preserves_unrelated_callback_handles;
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
        sentinel67 keep=new();
        uvm_reg_cb::add(rg[0],keep);uvm_reg_field_cb::add(low_field[0],keep);
        uvm_reg_field_cb::add(high_field[0],keep);install67(0);remove67(0);
        $display("UT: protection_ro_removed register %0d low %0d high %0d retained %0d",
          members67(0,0)==0,members67(0,1)==0,members67(0,2)==0,
          has_sentinel67(0,keep) && has_sentinel67(1,keep) && has_sentinel67(2,keep));
      end
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("trial");
  initial begin #200;$fatal(1,"original67 watchdog");end
endmodule
