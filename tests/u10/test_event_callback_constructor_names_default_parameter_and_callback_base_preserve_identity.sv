/*
:name: test_event_callback_constructor_names_default_parameter_and_callback_base_preserve_identity
:description: event callback constructor names default parameter and callback base preserve identity (IEEE 1800.2-2020 Section 10.2.2.1)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.2.2.1 10.2.1 10.7.1.1 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_event_callback_constructor_names_default_parameter_and_callback_base_preserve_identity.expected
*/
// What it checks:
// 1. The event callback constructor accepts an optional empty-default name.
// 2. The omitted event callback data parameter selects the object type.
// 3. A typed event callback derives from the callback base.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.2.2.1 (UVM-SYNC-REVIEW-EVENT-CALLBACK-NAMES) gives rule 1
//    above. Setup: Concrete callback extensions select implicit, named and
//    empty construction. Expected: The observed names are empty, selected and
//    empty.
// 2. 1800.2-2020 10.2.1 (UVM-SYNC-REVIEW-EVENT-CALLBACK-DEFAULT-TYPE) gives
//    rule 2 above. Setup: Assign a concrete default callback to the exact
//    object-data callback base. Expected: The exact specialization retains
//    identity.
// 3. 1800.2-2020 10.2.1 (UVM-SYNC-REVIEW-EVENT-CALLBACK-BASE) gives rule 3
//    above. Setup: Assign an integer-data callback extension to a
//    callback-base handle. Expected: The callback view denotes the same
//    extension.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original concrete callback subtypes expose constructor names, default data
// parameter and positive callback inheritance. Default pre-trigger return
// values
// and automatic registration are not asserted.
module test_event_callback_constructor_names_default_parameter_and_callback_base_preserve_identity;
  import uvm_pkg::*;
  class implicit_callback extends uvm_event_callback; endclass
  class named_callback extends uvm_event_callback;
    function new(string name); super.new(name); endfunction
  endclass
  class typed_callback extends uvm_event_callback#(int); endclass
  initial begin
    automatic implicit_callback omitted = new();
    automatic named_callback named = new("selected");
    automatic named_callback empty = new("");
    automatic typed_callback typed = new();
    automatic uvm_event_callback#(uvm_object) exact_default = named;
    automatic uvm_callback base_view = typed;
    $display("UT: callback_names omitted %0d named %0d empty %0d",
             omitted.get_name() == "",named.get_name() == "selected",empty.get_name() == "");
    $display("UT: callback_types default %0d typed_base %0d",
             exact_default == named,base_view == typed);
    $finish;
  end
endmodule
