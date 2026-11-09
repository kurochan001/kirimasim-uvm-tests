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
// What it checks:
// 1. The concat constructor accepts an explicit instance-name argument.
// 2. The concat constructor accepts an explicitly empty name argument.
// 3. The concat constructor permits omission of its name argument.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 17.2.3.3.1 (UVM-REG-GLOBAL-CONCAT-NAMED-CONSTRUCTION) gives
//    rule 1 above. Setup: A new expression supplies selected as the name.
//    Expected: Each selected new expression produces a nonnull distinct concat
//    instance.
// 2. 1800.2-2020 17.2.3.3.1 (UVM-REG-GLOBAL-CONCAT-EMPTY-NAME-CONSTRUCTION)
//    gives rule 2 above. Setup: A new expression supplies an empty string.
//    Expected: Each selected new expression produces a nonnull distinct concat
//    instance.
// 3. 1800.2-2020 17.2.3.3.1 (UVM-REG-GLOBAL-CONCAT-OMITTED-NAME-CONSTRUCTION)
//    gives rule 3 above. Setup: A new expression omits the optional name.
//    Expected: Each selected new expression produces a nonnull distinct concat
//    instance.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
