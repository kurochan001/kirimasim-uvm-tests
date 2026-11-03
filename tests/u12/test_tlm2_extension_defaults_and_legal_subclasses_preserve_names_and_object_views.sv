/*
:name: test_tlm2_extension_defaults_and_legal_subclasses_preserve_names_and_object_views
:description: tlm2 extension default type and legal subclasses preserve constructor names and object views (IEEE 1800.2-2020 Section 12.3.4.5.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.5.3 12.3.4.5 12.3.4.5.1 12.3.4.4 12.3.4.4.1 12.3.4.4.3 5.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_extension_defaults_and_legal_subclasses_preserve_names_and_object_views.expected
*/
// User subclasses derive via the standard parameterized extension class.
// Default T and constructor-name pass-through are positive compile/runtime
// checks. The abstract nonparameterized base is used only as a handle. Illegal
// base construction/direct user extension and default IMP are not certified.
module test_tlm2_extension_defaults_and_legal_subclasses_preserve_names_and_object_views;
  import uvm_pkg::*;
  class legal_extension extends uvm_tlm_extension#(legal_extension);
    function new(string name=""); super.new(name); endfunction
  endclass
  initial begin
    automatic uvm_tlm_extension#() default_value = new();
    automatic uvm_tlm_extension#(int) exact = default_value;
    automatic legal_extension unnamed = new();
    automatic legal_extension named = new("selected");
    automatic uvm_tlm_extension_base base = named;
    automatic uvm_object object_view = base;
    $display("UT: extension_default type %0d empty_name %0d",exact == default_value,
             default_value.get_name() == "");
    $display("UT: extension_legal names %0d/%0d base %0d object %0d distinct %0d",
             unnamed.get_name() == "",named.get_name() == "selected",base == named,
             object_view == named,unnamed != named);
    named.set_name("renamed");
    $display("UT: extension_alias name %0d peer_empty %0d",object_view.get_name() == "renamed",
             unnamed.get_name() == "");
    $finish;
  end
endmodule
