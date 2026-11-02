/*
:name: test_hdl_read_returns_actual_wide_storage_without_modifying_either_variable
:description: HDL read samples actual wide storage and leaves selected/peer storage unchanged (19.6.2.7)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.6.2.7 19.6.2.1 1800-2023 6.21
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
:expected_stdout: @test_hdl_read_returns_actual_wide_storage_without_modifying_either_variable.expected
*/
// Sample actual storage directly; failed-read output is deliberately unused.
module test_hdl_read_returns_actual_wide_storage_without_modifying_either_variable;
  import uvm_pkg::*;
  logic [39:0] live /*verilator public_flat_rw*/;
  logic [7:0] peer /*verilator public_flat_rw*/;
  localparam string ROOT_PATH =
      "test_hdl_read_returns_actual_wide_storage_without_modifying_either_variable";
  initial begin
    uvm_hdl_data_t value;
    int ok, bad;
    live = 'h9c123456a5;
    peer = 'h5a;
    #1;
    ok = uvm_hdl_read({ROOT_PATH, ".live"}, value);
    $display("UT: read success %0d value %0d selected %0d peer %0d",
             ok, value[39:0] == 'h9c123456a5, live == 'h9c123456a5, peer == 'h5a);
    live = 'h0187654321;
    #1;
    ok = uvm_hdl_read({ROOT_PATH, ".live"}, value);
    $display("UT: fresh success %0d value %0d selected %0d peer %0d",
             ok, value[39:0] == 'h0187654321, live == 'h0187654321, peer == 'h5a);
    bad = uvm_hdl_read({ROOT_PATH, ".absent"}, value);
    $display("UT: missing failed %0d selected %0d peer %0d",
             bad == 0, live == 'h0187654321, peer == 'h5a);
    $finish;
  end
endmodule
