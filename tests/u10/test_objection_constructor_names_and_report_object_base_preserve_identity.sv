/*
:name: test_objection_constructor_names_and_report_object_base_preserve_identity
:description: objection constructor names and report object base preserve identity (IEEE 1800.2-2020 Section 10.5.1.2)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.5.1.2 10.5.1.1 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_objection_constructor_names_and_report_object_base_preserve_identity.expected
*/
// What it checks:
// 1. The objection constructor accepts an optional empty-default name.
// 2. An objection derives from the report-object base.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.5.1.2 (UVM-OBJECTION-CB-REVIEW-OBJECTION-NAMES) gives rule
//    1 above. Setup: Create omitted-name, selected-name and empty-name
//    objections. Expected: Names are empty, selected and empty.
// 2. 1800.2-2020 10.5.1.1 (UVM-OBJECTION-CB-REVIEW-OBJECTION-REPORT-BASE)
//    gives rule 2 above. Setup: Assign the actual objection to report-object
//    and object views. Expected: Both views retain the objection identity.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe declared optional names and positive report-object inheritance. No
// factory behavior, default propagation or unspecified internal state is
// inferred.
module test_objection_constructor_names_and_report_object_base_preserve_identity;
  import uvm_pkg::*;
  initial begin
    automatic uvm_objection omitted = new();
    automatic uvm_objection named = new("selected");
    automatic uvm_objection empty = new("");
    automatic uvm_report_object report_view = named;
    automatic uvm_object object_view = named;
    $display("UT: objection_names omitted %0d named %0d empty %0d",
             omitted.get_name() == "",named.get_name() == "selected",empty.get_name() == "");
    $display("UT: objection_bases report %0d object %0d",report_view == named,object_view == named);
    $finish;
  end
endmodule
