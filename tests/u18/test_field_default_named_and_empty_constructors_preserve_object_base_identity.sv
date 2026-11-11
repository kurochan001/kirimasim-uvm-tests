/*
:name: test_field_default_named_and_empty_constructors_preserve_object_base_identity
:description: Field constructor defaults explicit names and object ancestry retain original identities
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.3.1 18.5.1 18.5 18.5.4.1 18.5.4.2 18.5.4.3 18.5.3.2 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.4.2.1 18.4.2.2 18.4.6.2 18.2.3.6 18.2.5.2 19.4.2.2.1 19.4.2.1 19.4.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 19.5.2.8 19.1.1.2.9 1800-2023 6.21 8.20 8.21 18.5
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers66/field_access_fixture66.svh
:expected_exit: 0
:expected_stdout: @test_field_default_named_and_empty_constructors_preserve_object_base_identity.expected
*/
// What it checks:
// 1. Field construction defaults to the declared uvm_reg_field name.
// 2. Field construction preserves explicit and empty names.
// 3. The concrete field retains its uvm_object base view.
// 4. A configured field belongs to its selected containing register and bit
//    slice.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.5.3.1 (UVM-FIELD-ACCESS-AUDIT-CONSTRUCTOR-DEFAULT) gives
//    rule 1 above. Setup: Fresh original field/register instances with valid
//    configuration; distinguish model state and independent original
//    access-provider storage. Expected: The omitted constructor name is
//    uvm_reg_field.
// 2. 1800.2-2020 18.5.3.1 (UVM-FIELD-ACCESS-AUDIT-CONSTRUCTOR-EXPLICIT) gives
//    rule 2 above. Setup: Fresh original field/register instances with valid
//    configuration; distinguish model state and independent original
//    access-provider storage. Expected: The selected named and empty objects
//    retain their supplied names.
// 3. 1800.2-2020 18.5.1 (UVM-FIELD-ACCESS-AUDIT-FIELD-ANCESTRY) gives rule 3
//    above. Setup: Fresh original field/register instances with valid
//    configuration; distinguish model state and independent original
//    access-provider storage. Expected: Implicit base assignment preserves the
//    exact original named field handle.
// 4. 1800.2-2020 18.5 (UVM-FIELD-ACCESS-AUDIT-SINGLE-PARENT-FIELD) gives rule
//    4 above. Setup: Fresh original field/register instances with valid
//    configuration; distinguish model state and independent original
//    access-provider storage. Expected: The original register is the exact
//    parent and the selected field is eight bits at LSB zero.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original access-provider storage is distinct from physical HDL evidence.
module test_field_default_named_and_empty_constructors_preserve_object_base_identity;
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
        automatic uvm_reg_field omitted=new(),named=new("named66"),empty=new("");
        automatic uvm_object base=named;
        $display("UT: field_constructor default %0d named %0d empty %0d ancestry %0d",
          omitted.get_name()=="uvm_reg_field",named.get_name()=="named66",
          empty.get_name()=="",base==named);
        $display("UT: field_containment parent %0d width %0d lsb %0d",
          selected.get_parent()==rg,selected.get_n_bits(),selected.get_lsb_pos());
      end

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("trial");
  initial begin #200;$fatal(1,"original66 watchdog");end
endmodule
