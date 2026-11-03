/*
:name: test_objection_callback_inherits_callback_identity_and_explicit_enable_queries
:description: objection callback inherits callback identity and explicit enable queries (IEEE 1800.2-2020 Section 10.5.2.1)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.5.2.1 10.7.1.1 10.7.1.2.2 10.7.1.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_objection_callback_inherits_callback_identity_and_explicit_enable_queries.expected
*/
// Use only explicit enable/disable arguments and base identity. The omitted
// callback_mode argument has conflicting signature/prose defaults; no
// constructor
// name or initial enable state is assumed for this callback subtype.
// The explicit constructor argument is setup, not a no-argument guarantee.
module test_objection_callback_inherits_callback_identity_and_explicit_enable_queries;
  import uvm_pkg::*;
  initial begin
    automatic uvm_objection_callback subject = new("subject");
    automatic uvm_callback base_view = subject;
    void'(subject.callback_mode(0));
    $display("UT: objection_callback disabled %0d identity %0d",!base_view.is_enabled(),
             base_view == subject);
    void'(subject.callback_mode(1));
    $display("UT: objection_callback enabled %0d identity %0d",base_view.is_enabled(),
             base_view == subject);
    $finish;
  end
endmodule
