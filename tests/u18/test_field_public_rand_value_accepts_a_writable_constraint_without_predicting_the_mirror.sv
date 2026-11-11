/*
:name: test_field_public_rand_value_accepts_a_writable_constraint_without_predicting_the_mirror
:description: The public field value has the register data type and can be constrained independently of mirror prediction
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.2 18.5.5.8 18.5.5.3 18.5.5.1 18.5.5.17 18.5.3.2 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.4.2.1 18.4.2.2 18.4.6.2 18.2.3.6 18.2.5.2 19.4.2.2.1 19.4.2.1 19.4.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 19.5.2.8 19.1.1.2.9 1800-2023 6.21 8.20 8.21 18.5
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers66/field_access_fixture66.svh
:expected_exit: 0
:expected_stdout: @test_field_public_rand_value_accepts_a_writable_constraint_without_predicting_the_mirror.expected
*/
// What it checks:
// 1. The public randomizable field value has the register-data type width.
// 2. The writable public field value can be constrained through randomization.
// 3. A constrained desired-value change makes the writable field need an
//    update.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.5.2 (UVM-FIELD-ACCESS-AUDIT-PUBLIC-VALUE-TYPE) gives rule
//    1 above. Setup: Fresh original field/register instances with valid
//    configuration; distinguish model state and independent original
//    access-provider storage. Expected: The value property is accessible with
//    the same bit width as uvm_reg_data_t.
// 2. 1800.2-2020 18.5.2 (UVM-FIELD-ACCESS-AUDIT-PUBLIC-VALUE-CONSTRAINT) gives
//    rule 2 above. Setup: Fresh original field/register instances with valid
//    configuration; distinguish model state and independent original
//    access-provider storage. Expected: A fixed legal constraint succeeds with
//    value and desired state 0x63, leaving the selected mirror at 0x11 and
//    performing no original-provider transfer.
// 3. 1800.2-2020 18.5.5.8 (UVM-FIELD-ACCESS-AUDIT-PENDING-RANDOMIZATION) gives
//    rule 3 above. Setup: Fresh original field/register instances with valid
//    configuration; distinguish model state and independent original
//    access-provider storage. Expected: The selected randomized field becomes
//    pending without a frontdoor or backdoor write.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original access-provider storage is distinct from physical HDL evidence.
module test_field_public_rand_value_accepts_a_writable_constraint_without_predicting_the_mirror;
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


      begin
        bit success;
        success=selected.randomize() with {value==8'h63;};
        $display("UT: field_rand success %0d value %0d width %0d desired %0d mirror %0d",
          success,selected.value=='h63,$bits(selected.value)==$bits(uvm_reg_data_t),
          selected.get()=='h63,selected.get_mirrored_value()=='h11);
        $display("UT: field_rand_pending update %0d frontdoor %0d backdoor %0d",
          selected.needs_update(),first_fd.calls,bd.writes);
      end

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("trial");
  initial begin #200;$fatal(1,"original66 watchdog");end
endmodule
