/*
:name: test_hdl_force_time_explicit_zero_time_delegates_to_deposit_without_force_or_release
:description: zero force_time delegates to deposit with no elapsed time or force/release calls (19.6.2.4)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.6.2.4 19.6.2.2 1800-2023 6.21
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
:expected_stdout: @test_hdl_force_time_explicit_zero_time_delegates_to_deposit_without_force_or_release.expected
*/
// This exercises the UVM zero-time wrapper, not force/release backend support.
// The standard declares a task, so no return-value assertion is invented.
module test_hdl_force_time_explicit_zero_time_delegates_to_deposit_without_force_or_release;
  import uvm_pkg::*;
  import "DPI-C" function void uvm_test_hdl_reset_counts();
  import "DPI-C" function int uvm_test_hdl_count(int operation);
  logic [7:0] live /*verilator public_flat_rw*/;
  logic [7:0] peer /*verilator public_flat_rw*/;
  localparam string ROOT_PATH =
      "test_hdl_force_time_explicit_zero_time_delegates_to_deposit_without_force_or_release";
  initial begin
    time started;
    live = 'h3c;
    peer = 'h5a;
    #1;
    uvm_test_hdl_reset_counts();
    started = $time;
    uvm_hdl_force_time({ROOT_PATH, ".live"}, 'ha6, 0);
    $display("UT: delegated deposit %0d no_force_release %0d no_reads %0d zero_time %0d",
             uvm_test_hdl_count(2) == 1, uvm_test_hdl_count(3) == 0,
             uvm_test_hdl_count(1) == 0, $time == started);
    #1;
    $display("UT: storage selected %0d peer %0d", live == 'ha6, peer == 'h5a);
    $finish;
  end
endmodule
