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
