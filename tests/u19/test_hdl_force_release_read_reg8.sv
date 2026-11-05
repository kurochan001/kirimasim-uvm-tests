/*
:name: test_hdl_force_release_read_reg8
:description: real 8-bit reg force and release_read preserve the declared effects (IEEE 1800.2-2020 Section 19.6.2.5)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.6.2.5 19.6.2.3 1800-2023 10.6.2 38.34 6.21
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
:expected_stdout: @test_hdl_force_release_read_reg8.expected
*/
// Original live HDL signals; forceable is the documented compiler interface.
// Settled force observations and immediate release readback stay distinct.
module test_hdl_force_release_read_reg8;
  import uvm_pkg::*;
  logic [7:0] live /*verilator public_flat_rw*/ /*verilator forceable*/;
  logic [7:0] peer /*verilator public_flat_rw*/;
  localparam string ROOT_PATH = "test_hdl_force_release_read_reg8";
  initial begin
    int result;
    uvm_hdl_data_t sample;
    live = 8'h3c; peer = 8'h5a; sample = '1;
    #1;
    result = uvm_hdl_force({ROOT_PATH, ".live"}, 8'ha6);
    #1;
    $display("UT: force77 success %0d held %0b peer %0b", result,
             live == 8'ha6, peer == 8'h5a);
    live = 8'h11;
    #1;
    $display("UT: force77 reassignment_held %0b peer %0b",
             live == 8'ha6, peer == 8'h5a);
    result = uvm_hdl_release_and_read({ROOT_PATH, ".live"}, sample);
    $display("UT: release77 success %0d sampled %0b", result,
             result == 1 && sample[7:0] == 8'ha6);
    #1;
    $display("UT: reg77 retained %0b peer %0b",
             live == 8'ha6, peer == 8'h5a);
    live = 8'h77;
    #1;
    $display("UT: reg77 resumed %0b peer %0b", live == 8'h77, peer == 8'h5a);
    $finish;
  end
endmodule
