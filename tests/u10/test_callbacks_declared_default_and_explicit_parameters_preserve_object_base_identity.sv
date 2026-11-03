/*
:name: test_callbacks_declared_default_and_explicit_parameters_preserve_object_base_identity
:description: callbacks declared default and explicit parameters preserve object base identity (IEEE 1800.2-2020 Section 10.7.2.1)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.7.2.1 10.7.2.2.1 10.7.2.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_callbacks_declared_default_and_explicit_parameters_preserve_object_base_identity.expected
*/
// Positive concrete default/explicit specialization and transitive object
// compatibility only. Original context/callback types derive from their
// required
// bases. Registration, invalid types and private singleton state are separate.
module test_callbacks_declared_default_and_explicit_parameters_preserve_object_base_identity;
  import uvm_pkg::*;
  class context_type extends uvm_object; endclass
  class callback_type extends uvm_callback; endclass
  initial begin
    automatic uvm_callbacks#() defaults = new();
    automatic uvm_callbacks#(context_type) default_callback = new();
    automatic uvm_callbacks#(context_type,callback_type) selected = new();
    automatic uvm_callbacks#(uvm_object,uvm_callback) exact_default = defaults;
    automatic uvm_callbacks#(context_type,uvm_callback) exact_callback = default_callback;
    automatic uvm_object object_view = selected;
    $display("UT: callbacks_types defaults %0d default_cb %0d object %0d",exact_default == defaults,
             exact_callback == default_callback,object_view == selected);
    $finish;
  end
endmodule
