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
