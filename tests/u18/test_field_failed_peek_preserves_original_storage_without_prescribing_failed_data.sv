/*
:name: test_field_failed_peek_preserves_original_storage_without_prescribing_failed_data
:description: A failing field sample preserves storage and returns failure without constraining data
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.5.12 18.5.3.2 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.4.2.1 18.4.2.2 18.4.6.2 18.2.3.6 18.2.5.2 19.4.2.2.1 19.4.2.1 19.4.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 19.5.2.8 19.1.1.2.9 1800-2023 6.21 8.20 8.21 18.5
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers66/field_access_fixture66.svh
:expected_exit: 0
:expected_stdout: @test_field_failed_peek_preserves_original_storage_without_prescribing_failed_data.expected
*/
// What it checks:
// An original backdoor sample failure is returned by field peek.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.5.5.12 (UVM-FIELD-ACCESS-AUDIT-FAILED-PEEK-STATUS) gives the
// rule above. Setup: Use a configured sixteen-bit register, middle field at
// LSB four, original backdoor storage B75D and optional distinct extension;
// access policy is selected explicitly. Expected: It returns NOT_OK, preserves
// B75D and performs no write without constraining failed data.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original access-provider storage is distinct from physical HDL evidence.
module test_field_failed_peek_preserves_original_storage_without_prescribing_failed_data;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "field_access_fixture66.svh"
  class trial extends fixture66;
    `uvm_component_utils(trial)
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    virtual function void settings66();width66=16;size66=8;lsb66=4;endfunction
    virtual task run_phase(uvm_phase phase);
      uvm_status_e status;
      uvm_reg_data_t value;
      phase.raise_objection(this);


      bd.word='hb75d;bd.fail_read=1;
      selected.peek(status,value);
      $display("UT: field_failed_peek failure %0d unchanged %0d writes %0d",
        status==UVM_NOT_OK,bd.word=='hb75d,bd.writes);

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("trial");
  initial begin #200;$fatal(1,"original66 watchdog");end
endmodule
