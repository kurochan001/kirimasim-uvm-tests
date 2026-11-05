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
