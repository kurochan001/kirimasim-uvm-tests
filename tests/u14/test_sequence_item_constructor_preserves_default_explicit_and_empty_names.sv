/*
:name: test_sequence_item_constructor_preserves_default_explicit_and_empty_names
:description: sequence item construction distinguishes an omitted name from explicit and empty names (14.1.2.1)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.1.2.1 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_item_constructor_preserves_default_explicit_and_empty_names.expected
*/
module test_sequence_item_constructor_preserves_default_explicit_and_empty_names;
  import uvm_pkg::*;
  initial begin
    automatic uvm_sequence_item first = new();
    automatic uvm_sequence_item named = new("named_item");
    automatic uvm_sequence_item empty_name = new("");
    $display("UT: names default %s explicit %s empty %0d", first.get_name(), named.get_name(),
             empty_name.get_name() == "");
    $display("UT: distinct %0d %0d", first != named, named != empty_name);
    $finish;
  end
endmodule
