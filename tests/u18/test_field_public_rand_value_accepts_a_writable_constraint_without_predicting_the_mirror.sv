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
