/*
:name: test_callback_constructor_default_selected_and_empty_names_preserve_object_identity
:description: callback constructor default selected and empty names preserve object identity (IEEE 1800.2-2020 Section 10.7.1.2.1)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.7.1.2.1 10.7.1.1 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_callback_constructor_default_selected_and_empty_names_preserve_object_identity.expected
*/
// Observe the declared optional callback name and object base. No initial
// enable state, omitted mode argument, registration or callback dispatch is
// inferred.
module test_callback_constructor_default_selected_and_empty_names_preserve_object_identity;
  import uvm_pkg::*;
  initial begin
    automatic uvm_callback omitted = new();
    automatic uvm_callback named = new("selected");
    automatic uvm_callback empty = new("");
    automatic uvm_object base_view = named;
    $display("UT: callback_constructor default %0d named %0d empty %0d object %0d",
             omitted.get_name() == "uvm_callback",named.get_name() == "selected",
             empty.get_name() == "",base_view == named);
    $finish;
  end
endmodule
