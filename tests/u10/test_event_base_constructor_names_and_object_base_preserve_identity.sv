/*
:name: test_event_base_constructor_names_and_object_base_preserve_identity
:description: event base constructor names and object base preserve identity (IEEE 1800.2-2020 Section 10.1.1.2.1)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.1.1.2.1 10.1.1.1 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_event_base_constructor_names_and_object_base_preserve_identity.expected
*/
// What it checks:
// 1. The event-base constructor accepts an optional empty-default name.
// 2. The event base derives from the object base.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.1.1.2.1 (UVM-SYNC-REVIEW-EVENT-BASE-NAMES) gives rule 1
//    above. Setup: Concrete extensions use implicit construction or forward
//    selected/empty names. Expected: Names are empty, selected and empty.
// 2. 1800.2-2020 10.1.1.1 (UVM-SYNC-REVIEW-EVENT-BASE-OBJECT) gives rule 2
//    above. Setup: Upcast an original concrete event-base subtype to an object
//    handle. Expected: The object view preserves identity.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Concrete original subtypes expose optional base construction without
// creating
// the abstract class itself. Only selected names and positive inheritance are
// checked; invalid construction and unspecified initial fields remain
// separate.
module test_event_base_constructor_names_and_object_base_preserve_identity;
  import uvm_pkg::*;
  class implicit_event extends uvm_event_base; endclass
  class named_event extends uvm_event_base;
    function new(string name); super.new(name); endfunction
  endclass
  initial begin
    automatic implicit_event omitted = new();
    automatic named_event named = new("selected");
    automatic named_event empty = new("");
    automatic uvm_object base_view = named;
    $display("UT: event_base_names omitted %0d named %0d empty %0d",
             omitted.get_name() == "",named.get_name() == "selected",empty.get_name() == "");
    $display("UT: event_base_object identity %0d",base_view == named);
    $finish;
  end
endmodule
