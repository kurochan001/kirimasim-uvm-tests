/*
:name: test_hdl_concat_standard_constructor_accepts_explicit_and_empty_instance_names
:description: hdl concat standard constructor accepts explicit and empty instance names (IEEE 1800.2-2020 Section 17.2.3.3.1)
:tags: u17 uvm
:type: simulation
:lrm: 1800.2-2020 17.2.3.3.1 17.2.3.2 1800-2023 6.21 6.19
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_hdl_concat_standard_constructor_accepts_explicit_and_empty_instance_names.expected
*/
// Check the standard constructor signature and distinct allocation only. No
// unprovided name getter or legacy public member is used to infer stored
// names.
module test_hdl_concat_standard_constructor_accepts_explicit_and_empty_instance_names;
  import uvm_pkg::*;
  initial begin
    automatic uvm_hdl_path_concat named = new("selected");
    automatic uvm_hdl_path_concat empty = new("");
    automatic uvm_hdl_path_concat omitted = new();
    $display("UT: constructed named %0d empty %0d omitted %0d distinct %0d",
             named != null, empty != null, omitted != null,
             named != empty && named != omitted && empty != omitted);
    $finish;
  end
endmodule
