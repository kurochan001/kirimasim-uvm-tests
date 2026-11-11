/*
:name: test_field_readonly_backdoor_write_is_protected_while_poke_deposits_as_is
:description: Physical-style read-only protection and as-is field deposition remain distinct
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.5.11 18.5.5.9 18.5.4.6 18.5.3.2 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.4.2.1 18.4.2.2 18.4.6.2 18.2.3.6 18.2.5.2 19.4.2.2.1 19.4.2.1 19.4.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 19.5.2.8 19.1.1.2.9 1800-2023 6.21 8.20 8.21 18.5
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers66/field_access_fixture66.svh
:expected_exit: 0
:expected_stdout: @test_field_readonly_backdoor_write_is_protected_while_poke_deposits_as_is.expected
*/
// What it checks:
// 1. Physical-style read-only field writes preserve its existing bits.
// 2. Field poke deposits as-is even when physical-style writes are read-only.
// 3. For simple side-effect-free original storage, interpret field-write best
//    effort as preserving the unselected peeked bits.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.5.5.9 (UVM-FIELD-ACCESS-AUDIT-READONLY-PHYSICAL-WRITE)
//    gives rule 1 above. Setup: Use a configured sixteen-bit register, middle
//    field at LSB four, original backdoor storage B75D and optional distinct
//    extension; access policy is selected explicitly. Expected: The selected
//    read-only slice remains 0x75 after physical-style backdoor write.
// 2. 1800.2-2020 18.5.5.11 (UVM-FIELD-ACCESS-AUDIT-READONLY-POKE) gives rule 2
//    above. Setup: Use a configured sixteen-bit register, middle field at LSB
//    four, original backdoor storage B75D and optional distinct extension;
//    access policy is selected explicitly. Expected: The following poke
//    changes B75D to B39D successfully.
// 3. 1800.2-2020 18.5.5.9
//    (UVM-FIELD-ACCESS-AUDIT-READONLY-NEIGHBOR-BEST-EFFORT) gives rule 3
//    above. Setup: Use a configured sixteen-bit register, middle field at LSB
//    four, original backdoor storage B75D and optional distinct extension;
//    access policy is selected explicitly. Expected: The whole original B75D
//    word remains unchanged during the read-only field write; an independently
//    reset following poke deposits B39D.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original access-provider storage is distinct from physical HDL evidence.
module test_field_readonly_backdoor_write_is_protected_while_poke_deposits_as_is;
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


      begin
        bit protected_value,protected_slice;
        bd.word='hb75d;
        selected.write(status,'h39,UVM_BACKDOOR,first_map);
        protected_value=bd.word=='hb75d;
        protected_slice=bd.word[11:4]=='h75;
        $display("DETAIL: readonly_word %0h status %0d",bd.word,status);
        bd.word='hb75d;
        selected.poke(status,'h39);
        $display("DETAIL: readonly_poke_word %0h status %0d",bd.word,status);
        $display("UT: field_ro_deposit protected %0d deposited %0d status %0d",
          protected_value,bd.word=='hb39d,status==UVM_IS_OK);
        $display("UT: field_ro_slice unchanged %0d",protected_slice);
      end

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("trial");
  initial begin #200;$fatal(1,"original66 watchdog");end
endmodule
