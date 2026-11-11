/*
:name: test_field_readonly_poke_without_a_prior_write_deposits_the_selected_slice
:description: A standalone readonly-field poke deposits its selected slice without prior write history
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.5.11 18.5 19.1.1.2.9 18.5.3.2 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.4.2.1 18.4.2.2 18.4.6.2 18.2.3.6 18.2.5.2 19.4.2.2.1 19.4.2.1 19.4.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 19.5.2.8 1800-2023 6.21 8.20 8.21 18.5
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers66/field_access_fixture66.svh
:expected_exit: 0
:expected_stdout: @test_field_readonly_poke_without_a_prior_write_deposits_the_selected_slice.expected
*/
// What it checks:
// Field poke deposits as-is even when physical-style writes are read-only.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.5.5.11 (UVM-FIELD-ACCESS-AUDIT-READONLY-POKE-NO-HISTORY)
// gives the rule above. Setup: Use a freshly reset model and an original B75D
// backdoor word with a read-only middle byte, without any previous
// register/field access. Expected: The standalone poke deposits B39D
// successfully, preserves physical neighbors B/D and forwards the exact
// extension to read/write.
// It also supports, as a control, the setup or conditions of
// UVM-FIELD-ACCESS-AUDIT-READONLY-POKE.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original access-provider storage is distinct from physical HDL evidence.
module test_field_readonly_poke_without_a_prior_write_deposits_the_selected_slice;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "field_access_fixture66.svh"
  class trial extends fixture66;
    `uvm_component_utils(trial)
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    virtual function void settings66();width66=16;size66=8;lsb66=4;access66="RO";endfunction
    virtual task run_phase(uvm_phase phase);
      uvm_status_e status;
      uvm_reg_data_t value;
      phase.raise_objection(this);


      bd.word='hb75d;
      selected.poke(status,'h39,.extension(extension));
      $display("UT: field_ro_poke_single status %0d slice %0d reads %0d writes %0d extension %0d",
        status==UVM_IS_OK,bd.word=='hb39d,bd.reads>=1,bd.writes==1,
        bd.read_extension==extension && bd.write_extension==extension);

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("trial");
  initial begin #200;$fatal(1,"original66 watchdog");end
endmodule
