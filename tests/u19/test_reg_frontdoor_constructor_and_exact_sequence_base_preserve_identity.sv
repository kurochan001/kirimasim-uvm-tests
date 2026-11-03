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
