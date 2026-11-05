/*
:name: test_hdl_force_release_wire40
:description: real 40-bit wire force and release preserve the declared effects (IEEE 1800.2-2020 Section 19.6.2.6)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.6.2.6 19.6.2.3 1800-2023 10.6.2 38.34 6.21
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
:expected_stdout: @test_hdl_force_release_wire40.expected
*/
// Original live HDL signals; forceable is the documented compiler interface.
// Settled force observations and immediate release readback stay distinct.
module test_hdl_force_release_wire40;
  import uvm_pkg::*;
  logic [39:0] source_value;
  wire [39:0] live /*verilator public_flat_rw*/ /*verilator forceable*/;
  assign live = source_value;
  logic [39:0] peer /*verilator public_flat_rw*/;
  localparam string ROOT_PATH = "test_hdl_force_release_wire40";
  initial begin
    int result;
    uvm_hdl_data_t sample;
    source_value = 40'h123456789; peer = 40'h5aa55aa55a; sample = '1;
    #1;
    result = uvm_hdl_force({ROOT_PATH, ".live"}, 40'he1d2c3b4a5);
    #1;
    $display("UT: force77 success %0d held %0b peer %0b", result,
             live == 40'he1d2c3b4a5, peer == 40'h5aa55aa55a);
    source_value = 40'h5566778899;
    #1;
    $display("UT: force77 reassignment_held %0b peer %0b",
             live == 40'he1d2c3b4a5, peer == 40'h5aa55aa55a);
    result = uvm_hdl_release({ROOT_PATH, ".live"});
    $display("UT: release77 success %0d", result);
    #1;
    $display("UT: wire77 resolved %0b peer %0b",
             live == 40'h5566778899, peer == 40'h5aa55aa55a);
    source_value = 40'haabbccddee;
    #1;
    $display("UT: wire77 resumed %0b peer %0b", live == 40'haabbccddee, peer == 40'h5aa55aa55a);
    $finish;
  end
endmodule
