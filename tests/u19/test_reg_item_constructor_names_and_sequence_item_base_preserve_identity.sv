/*
:name: test_reg_item_constructor_names_and_sequence_item_base_preserve_identity
:description: reg item constructor names and sequence item base preserve identity (IEEE 1800.2-2020 Section 19.1.1.3.1)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.1.1.3.1 19.1.1.1 14.1.1 5.3.4.1 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_item_constructor_names_and_sequence_item_base_preserve_identity.expected
*/
// Observe public construction and base identity only. No default undefined
// kind/data/enum value, numeric identity or formatted diagnostic is asserted.
module test_reg_item_constructor_names_and_sequence_item_base_preserve_identity;
  import uvm_pkg::*;
  initial begin
    automatic uvm_reg_item omitted = new();
    automatic uvm_reg_item named = new("selected");
    automatic uvm_reg_item empty = new("");
    automatic uvm_sequence_item item_view = named;
    $display("UT: item_names omitted %0d named %0d empty %0d",
             omitted.get_name() == "", named.get_name() == "selected", empty.get_name() == "");
    $display("UT: item_base nonnull %0d identity %0d", item_view != null, item_view == named);
    $finish;
  end
endmodule
