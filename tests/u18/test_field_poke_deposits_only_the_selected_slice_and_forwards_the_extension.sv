/*
:name: test_field_poke_deposits_only_the_selected_slice_and_forwards_the_extension
:description: Field poke preserves neighboring original storage bits and forwards extension context
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
:expected_stdout: @test_field_poke_deposits_only_the_selected_slice_and_forwards_the_extension.expected
*/
// What it checks:
// 1. Field poke deposits the selected slice as supplied.
// 2. Field poke preserves other physical word bits through peek-modify-poke.
// 3. Field poke forwards the supplied extension to both original backdoor
//    operations.
// 4. Installing a user backdoor selects that original provider for field
//    deposition.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.5.5.11 (UVM-FIELD-ACCESS-AUDIT-POKE-AS-IS) gives rule 1
//    above. Setup: Use a configured sixteen-bit register, middle field at LSB
//    four, original backdoor storage B75D and optional distinct extension;
//    access policy is selected explicitly. Expected: The selected middle byte
//    becomes 0x39 through the original backdoor.
// 2. 1800.2-2020 18.5.5.11 (UVM-FIELD-ACCESS-AUDIT-POKE-NEIGHBORS) gives rule
//    2 above. Setup: Use a configured sixteen-bit register, middle field at
//    LSB four, original backdoor storage B75D and optional distinct extension;
//    access policy is selected explicitly. Expected: The original B75D word
//    becomes B39D after at least one read and one write; neighboring B/D bits
//    survive independently of model A/3 reset.
// 3. 1800.2-2020 18.5.5.11 (UVM-FIELD-ACCESS-AUDIT-POKE-EXTENSION) gives rule
//    3 above. Setup: Use a configured sixteen-bit register, middle field at
//    LSB four, original backdoor storage B75D and optional distinct extension;
//    access policy is selected explicitly. Expected: The exact extension
//    handle reaches the read and write observers.
// 4. 1800.2-2020 18.4.6.2 (UVM-FIELD-ACCESS-AUDIT-USER-BACKDOOR-SELECTION)
//    gives rule 4 above. Setup: Use a configured sixteen-bit register, middle
//    field at LSB four, original backdoor storage B75D and optional distinct
//    extension; access policy is selected explicitly. Expected: The configured
//    provider receives the real read/write operations and updates its selected
//    original word.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original access-provider storage is distinct from physical HDL evidence.
module test_field_poke_deposits_only_the_selected_slice_and_forwards_the_extension;
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
      selected.poke(status,'h39,.extension(extension));
      $display("UT: field_poke status %0d slice %0d reads %0d writes %0d extension %0d",
        status==UVM_IS_OK,bd.word=='hb39d,bd.reads>=1,bd.writes==1,
        bd.read_extension==extension && bd.write_extension==extension);

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("trial");
  initial begin #200;$fatal(1,"original66 watchdog");end
endmodule
