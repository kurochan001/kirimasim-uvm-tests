/*
:name: test_reg_frontdoor_constructor_and_exact_sequence_base_preserve_identity
:description: reg frontdoor constructor and exact sequence base preserve identity (IEEE 1800.2-2020 Section 19.4.2.3)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.4.2.3 19.4.2.1 19.4.1.1 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_frontdoor_constructor_and_exact_sequence_base_preserve_identity.expected
*/
// What it checks:
// 1. The user-frontdoor constructor accepts its optional empty-default name.
// 2. A user frontdoor extends the declared register-sequence specialization
//    over a sequence of sequence items.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 19.4.2.3 (UVM-REG-PIPELINE-FRONTDOOR-CONSTRUCTOR-NAMES) gives
//    rule 1 above. Setup: Concrete subtypes select omitted, named and
//    explicitly empty constructor cases. Expected: The observed names are
//    empty, selected and empty.
// 2. 1800.2-2020 19.4.2.1 (UVM-REG-PIPELINE-FRONTDOOR-EXACT-BASE) gives rule 2
//    above. Setup: Assign a concrete frontdoor to the exact register-sequence
//    and item-sequence bases. Expected: Both base views preserve the frontdoor
//    identity.
// It also supports, as a control, the setup or conditions of
// UVM-ABSTRACT-REG-FRONTDOOR-DIRECT-CONSTRUCTION.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original concrete frontdoor subtypes expose the optional constructor names
// and exact declared register-sequence/base specialization. This is not
// physical transfer or default frontdoor-body coverage.
module test_reg_frontdoor_constructor_and_exact_sequence_base_preserve_identity;
  import uvm_pkg::*;
  class omitted_frontdoor extends uvm_reg_frontdoor;
    virtual task body(); endtask
  endclass
  class named_frontdoor extends uvm_reg_frontdoor;
    function new(string name); super.new(name); endfunction
    virtual task body(); endtask
  endclass
  initial begin
    automatic omitted_frontdoor omitted = new();
    automatic named_frontdoor named = new("selected");
    automatic named_frontdoor empty = new("");
    automatic uvm_reg_sequence#(uvm_sequence#(uvm_sequence_item)) exact_view = named;
    automatic uvm_sequence#(uvm_sequence_item) item_view = named;
    $display("UT: frontdoor_names omitted %0d named %0d empty %0d",
             omitted.get_name() == "",named.get_name() == "selected",empty.get_name() == "");
    $display("UT: frontdoor_types exact %0d item %0d",exact_view == named,item_view == named);
    $finish;
  end
endmodule
