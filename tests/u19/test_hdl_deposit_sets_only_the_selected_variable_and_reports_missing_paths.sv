/*
:name: test_hdl_deposit_sets_only_the_selected_variable_and_reports_missing_paths
:description: HDL deposit updates the selected real HDL variable and returns success/failure (19.6.2.2)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.6.2.2 19.6.2.1 19.6.2.7 1800-2023 6.21
:uvm: 2020.3.1
:uvm_dpi: yes
:uvm_hdl_backend: vpi
:uvm_defines: UVM_REGEX_NO_DPI UVM_CMDLINE_NO_DPI
:dpi_c: @../../tools/uvm_hdl_vpi.cpp
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_hdl_deposit_sets_only_the_selected_variable_and_reports_missing_paths.expected
*/
// What it checks:
// 1. HDL deposit sets the selected HDL object value and reports whether the
//    operation succeeded.
// 2. HDL path checks distinguish an accessible object from a missing path.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 19.6.2.2 (UVM-HDL-DEPOSIT) gives rule 1 above. Setup: An
//    allowed backend provides linked HDL DPI and both valid and invalid HDL
//    paths. Expected: A successful deposit returns 1 and changes the target; a
//    failed deposit returns 0.
// 2. 1800.2-2020 19.6.2.1 (UVM-HDL-CHECK-PATH-PRESENCE) gives rule 2 above.
//    Setup: Provide a public packed variable and a nonexistent leaf under the
//    same module. Expected: The valid path returns one and the missing path
//    zero.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Actual public HDL storage is accessed through the original VPI backend.
// Run with tools/run_verilator_hdl.py; ordinary runs do not link this DPI.
module test_hdl_deposit_sets_only_the_selected_variable_and_reports_missing_paths;
  import uvm_pkg::*;
  logic [7:0] live /*verilator public_flat_rw*/;
  logic [7:0] peer /*verilator public_flat_rw*/;
  logic [39:0] wide /*verilator public_flat_rw*/;
  localparam string ROOT_PATH =
      "test_hdl_deposit_sets_only_the_selected_variable_and_reports_missing_paths";
  initial begin
    uvm_hdl_data_t data;
    int ok, bad, wide_ok;
    live = 'h3c;
    peer = 'h5a;
    wide = 'h123456789a;
    #1;
    $display("UT: paths valid %0d missing %0d", uvm_hdl_check_path({ROOT_PATH, ".live"}),
             uvm_hdl_check_path({ROOT_PATH, ".absent"}));
    ok = uvm_hdl_deposit({ROOT_PATH, ".live"}, 'ha6);
    #1;
    $display("UT: deposit success %0d value %0d peer %0d", ok, live == 'ha6, peer == 'h5a);
    bad = uvm_hdl_deposit({ROOT_PATH, ".absent"}, 'hff);
    #1;
    $display("UT: missing failed %0d selected_unchanged %0d peer_unchanged %0d",
             bad == 0, live == 'ha6, peer == 'h5a);
    wide_ok = uvm_hdl_deposit({ROOT_PATH, ".wide"}, 'hc981234567);
    #1;
    $display("UT: wide success %0d crosses_word %0d narrow_unchanged %0d",
             wide_ok, wide == 'hc981234567, live == 'ha6);
    ok = uvm_hdl_read({ROOT_PATH, ".wide"}, data);
    $display("UT: readback success %0d matches %0d", ok, data[39:0] == 'hc981234567);
    $finish;
  end
endmodule
