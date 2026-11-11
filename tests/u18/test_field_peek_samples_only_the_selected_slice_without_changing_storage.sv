/*
:name: test_field_peek_samples_only_the_selected_slice_without_changing_storage
:description: Field peek extracts original storage without a write and forwards the extension
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.5.12 18.5 19.1.1.2.9 18.5.3.2 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.4.2.1 18.4.2.2 18.4.6.2 18.2.3.6 18.2.5.2 19.4.2.2.1 19.4.2.1 19.4.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 19.5.2.8 1800-2023 6.21 8.20 8.21 18.5
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers66/field_access_fixture66.svh
:expected_exit: 0
:expected_stdout: @test_field_peek_samples_only_the_selected_slice_without_changing_storage.expected
*/
// What it checks:
// 1. Field peek samples the selected slice without modifying storage.
// 2. Field peek forwards the supplied extension to the original sample.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.5.5.12 (UVM-FIELD-ACCESS-AUDIT-PEEK-SLICE) gives rule 1
//    above. Setup: Use a configured sixteen-bit register, middle field at LSB
//    four, original backdoor storage B75D and optional distinct extension;
//    access policy is selected explicitly. Expected: It returns 0x75, keeps
//    original B75D unchanged and performs no write.
// 2. 1800.2-2020 18.5.5.12 (UVM-FIELD-ACCESS-AUDIT-PEEK-EXTENSION) gives rule
//    2 above. Setup: Use a configured sixteen-bit register, middle field at
//    LSB four, original backdoor storage B75D and optional distinct extension;
//    access policy is selected explicitly. Expected: The read observer
//    receives the exact extension handle.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original access-provider storage is distinct from physical HDL evidence.
module test_field_peek_samples_only_the_selected_slice_without_changing_storage;
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


      bd.word='hb75d;
      selected.peek(status,value,.extension(extension));
      $display("UT: field_peek status %0d slice %0d unchanged %0d writes %0d extension %0d",
        status==UVM_IS_OK,value=='h75,bd.word=='hb75d,bd.writes,
        bd.read_extension==extension);

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("trial");
  initial begin #200;$fatal(1,"original66 watchdog");end
endmodule
