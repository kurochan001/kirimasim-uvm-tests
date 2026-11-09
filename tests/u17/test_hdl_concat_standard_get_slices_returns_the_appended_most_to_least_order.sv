/*
:name: test_hdl_concat_standard_get_slices_returns_the_appended_most_to_least_order
:description: standard HDL concat get slice API preserves a two-slice description (IEEE 1800.2-2020 Section 17.2.3.3.3)
:tags: u17 uvm
:type: simulation
:lrm: 1800.2-2020 17.2.3.3.3 17.2.1.7 17.2.3.1 17.2.3.3.1 17.2.3.3.2 17.2.3.3.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_hdl_concat_standard_get_slices_returns_the_appended_most_to_least_order.expected
*/
// What it checks:
// 1. The standard get_slices method returns the configured slice array.
// 2. add_slice appends a valid next slice to the concat.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 17.2.3.3.3 (UVM-HDL-CONCAT-GET-SLICES) gives rule 1 above.
//    Setup: Prepare a concat using add_slice or set_slices, then call the
//    standard getter. Expected: The result contains high then low with offsets
//    eight/zero and sizes eight.
// 2. 1800.2-2020 17.2.3.3.4 (UVM-HDL-CONCAT-APPEND-SLICES) gives rule 2 above.
//    Setup: Append high and low slices and inspect with get_slices. Expected:
//    The resulting array retains the supplied most-to-least order and
//    geometry.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The pinned library lacks this required slice accessor API.
// Keep the standard slice API rather than substituting library legacy members.
// These are metadata values; no HDL handle or DPI access is requested.
module test_hdl_concat_standard_get_slices_returns_the_appended_most_to_least_order;
  import uvm_pkg::*;
  initial begin
    automatic uvm_hdl_path_concat concat_value = new();
    uvm_hdl_path_slice input_slices[];
    uvm_hdl_path_slice result_slices[];
    input_slices = new[2];
    input_slices[0].path = "high"; input_slices[0].offset = 8; input_slices[0].size = 8;
    input_slices[1].path = "low"; input_slices[1].offset = 0; input_slices[1].size = 8;
    concat_value.add_slice(input_slices[0]);
    concat_value.add_slice(input_slices[1]);
    concat_value.get_slices(result_slices);
    $display("UT: slices %0d high %0d low %0d", result_slices.size(),
             result_slices[0].path == "high" && result_slices[0].offset == 8 &&
             result_slices[0].size == 8, result_slices[1].path == "low" &&
             result_slices[1].offset == 0 && result_slices[1].size == 8);
    $finish;
  end
endmodule
