/*
:name: test_typed_event_constructor_names_default_parameter_and_base_preserve_identity
:description: typed event constructor names default parameter and base preserve identity (IEEE 1800.2-2020 Section 10.1.2.2.1)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.1.2.2.1 10.1.2.1 10.1.1.1 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_typed_event_constructor_names_default_parameter_and_base_preserve_identity.expected
*/
// What it checks:
// 1. The typed event constructor accepts an optional empty-default name.
// 2. The omitted event data parameter selects the object type.
// 3. A typed event extends the abstract event base.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.1.2.2.1 (UVM-SYNC-REVIEW-EVENT-NAMES) gives rule 1 above.
//    Setup: Create omitted-name, selected-name and explicitly empty-name
//    events. Expected: The supplied names are retained.
// 2. 1800.2-2020 10.1.2.1 (UVM-SYNC-REVIEW-EVENT-DEFAULT-TYPE) gives rule 2
//    above. Setup: Assign the default event to the exact object-data
//    specialization. Expected: The exact specialization denotes the same
//    event.
// 3. 1800.2-2020 10.1.2.1 (UVM-SYNC-REVIEW-EVENT-BASE-INHERITANCE) gives rule
//    3 above. Setup: Upcast an integer-data event to the event base. Expected:
//    The base denotes the same typed event.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe optional names, the omitted object-data specialization and a
// concrete
// integer-data specialization through the event base. Data before any accepted
// trigger, invalid types and implementation layout remain unconstrained.
module test_typed_event_constructor_names_default_parameter_and_base_preserve_identity;
  import uvm_pkg::*;
  initial begin
    automatic uvm_event omitted = new();
    automatic uvm_event named = new("selected");
    automatic uvm_event empty = new("");
    automatic uvm_event#(uvm_object) exact_default = omitted;
    automatic uvm_event#(int) typed = new("typed");
    automatic uvm_event_base base_view = typed;
    $display("UT: event_names omitted %0d named %0d empty %0d",
             omitted.get_name() == "",named.get_name() == "selected",empty.get_name() == "");
    $display("UT: event_types default %0d typed_base %0d",
             exact_default == omitted,base_view == typed);
    $finish;
  end
endmodule
