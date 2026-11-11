/*
:name: test_field_needs_update_observes_desired_state_without_modifying_storage_or_mirror
:description: Pending field updates are observed without modifying the mirror or original storage
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.5.8 18.5.5 18.5.5.2 18.5.5.3 18.5.5.17 18.5.3.2 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.4.2.1 18.4.2.2 18.4.6.2 18.2.3.6 18.2.5.2 19.4.2.2.1 19.4.2.1 19.4.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 19.5.2.8 19.1.1.2.9 1800-2023 6.21 8.20 8.21 18.5
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers66/field_access_fixture66.svh
:expected_exit: 0
:expected_stdout: @test_field_needs_update_observes_desired_state_without_modifying_storage_or_mirror.expected
*/
// What it checks:
// 1. The selected synchronized reset field initially needs no update.
// 2. A selected writable desired/mirror difference makes update necessary.
// 3. The pending query does not change the mirror or original storage.
// 4. Synchronizing the selected desired/mirror value clears the update need.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.5.5.8 (UVM-FIELD-ACCESS-AUDIT-PENDING-INITIAL) gives rule
//    1 above. Setup: Fresh original field/register instances with valid
//    configuration; distinguish model state and independent original
//    access-provider storage. Expected: needs_update returns false in the
//    selected initial state.
// 2. 1800.2-2020 18.5.5.8 (UVM-FIELD-ACCESS-AUDIT-PENDING-DESIRED) gives rule
//    2 above. Setup: Fresh original field/register instances with valid
//    configuration; distinguish model state and independent original
//    access-provider storage. Expected: Both successive queries return true
//    after changing desired state to 0x39.
// 3. 1800.2-2020 18.5.5.8 (UVM-FIELD-ACCESS-AUDIT-PENDING-OBSERVATIONAL) gives
//    rule 3 above. Setup: Fresh original field/register instances with valid
//    configuration; distinguish model state and independent original
//    access-provider storage. Expected: The mirror and original word remain
//    0x11, with no original frontdoor call.
// 4. 1800.2-2020 18.5.5.8 (UVM-FIELD-ACCESS-AUDIT-PENDING-SYNCHRONIZED) gives
//    rule 4 above. Setup: Fresh original field/register instances with valid
//    configuration; distinguish model state and independent original
//    access-provider storage. Expected: Direct prediction to 0x39 clears
//    needs_update without a transfer.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original access-provider storage is distinct from physical HDL evidence.
module test_field_needs_update_observes_desired_state_without_modifying_storage_or_mirror;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "field_access_fixture66.svh"
  class trial extends fixture66;
    `uvm_component_utils(trial)
    function new(string name,uvm_component parent);super.new(name,parent);endfunction

    virtual task run_phase(uvm_phase phase);
      uvm_status_e status;
      uvm_reg_data_t value;
      phase.raise_objection(this);


      $display("UT: field_pending initial %0d",selected.needs_update());
      selected.set('h39);
      $display("UT: field_pending dirty %0d repeat %0d mirror %0d storage %0d calls %0d",
        selected.needs_update(),selected.needs_update(),selected.get_mirrored_value()=='h11,
        first_fd.word=='h11,first_fd.calls);
      void'(selected.predict('h39));
      $display("UT: field_pending synchronized %0d calls %0d",
        !selected.needs_update(),first_fd.calls);

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("trial");
  initial begin #200;$fatal(1,"original66 watchdog");end
endmodule
