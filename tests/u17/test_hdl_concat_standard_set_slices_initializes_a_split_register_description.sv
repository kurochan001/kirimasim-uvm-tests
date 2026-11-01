/*
:name: test_hdl_concat_standard_set_slices_initializes_a_split_register_description
:description: standard HDL concat set slice API preserves a two-slice description (IEEE 1800.2-2020 Section 17.2.3.3.2)
:tags: u17 uvm
:type: simulation
:lrm: 1800.2-2020 17.2.3.3.2 17.2.1.7 17.2.3.1 17.2.3.3.1 17.2.3.3.3 17.2.3.3.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_hdl_concat_standard_set_slices_initializes_a_split_register_description.expected
*/
// The pinned library lacks this required slice accessor API.
// Keep the standard slice API rather than substituting library legacy members.
// These are metadata values; no HDL handle or DPI access is requested.
module test_hdl_concat_standard_set_slices_initializes_a_split_register_description;
  import uvm_pkg::*;
  initial begin
    automatic uvm_hdl_path_concat concat_value = new();
    uvm_hdl_path_slice input_slices[];
    uvm_hdl_path_slice result_slices[];
    input_slices = new[2];
    input_slices[0].path = "high"; input_slices[0].offset = 8; input_slices[0].size = 8;
    input_slices[1].path = "low"; input_slices[1].offset = 0; input_slices[1].size = 8;
    concat_value.set_slices(input_slices);
    concat_value.get_slices(result_slices);
    $display("UT: slices %0d high %0d low %0d", result_slices.size(),
             result_slices[0].path == "high" && result_slices[0].offset == 8 &&
             result_slices[0].size == 8, result_slices[1].path == "low" &&
             result_slices[1].offset == 0 && result_slices[1].size == 8);
    $finish;
  end
endmodule
