/*
:name: test_hdl_force_release_failures_keep_independent_controls
:description: missing and uninstrumented force targets report failure with independent controls (IEEE 1800.2-2020 Section 19.6.2.3)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.6.2.3 19.6.2.5 19.6.2.6 1800-2023 10.6.2 38.34 6.21
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
:expected_stdout: @test_hdl_force_release_failures_keep_independent_controls.expected
*/
// No failed-call output buffer or diagnostic text/count is prescribed.
// Uninstrumented targets are outside this explicitly declared backend scope.
module test_hdl_force_release_failures_keep_independent_controls;
  import uvm_pkg::*;
  logic [7:0] live /*verilator public_flat_rw*/ /*verilator forceable*/;
  logic [7:0] peer /*verilator public_flat_rw*/;
  localparam string ROOT_PATH = "test_hdl_force_release_failures_keep_independent_controls";
  initial begin
    int forced, released, sampled;
    uvm_hdl_data_t value;
    live = 'h3c; peer = 'h5a; value = '1;
    #1;
    forced = uvm_hdl_force({ROOT_PATH, ".missing"}, 'ha6);
    released = uvm_hdl_release({ROOT_PATH, ".missing"});
    sampled = uvm_hdl_release_and_read({ROOT_PATH, ".missing"}, value);
    $display("UT: failure77 missing force %0d release %0d read %0d",
             forced, released, sampled);
    forced = uvm_hdl_force({ROOT_PATH, ".peer"}, 'ha6);
    released = uvm_hdl_release({ROOT_PATH, ".peer"});
    sampled = uvm_hdl_release_and_read({ROOT_PATH, ".peer"}, value);
    $display("UT: failure77 unmarked force %0d release %0d read %0d",
             forced, released, sampled);
    $display("UT: failure77 untouched %0b %0b", live == 'h3c, peer == 'h5a);
    forced = uvm_hdl_force({ROOT_PATH, ".live"}, 'hb7);
    #1;
    $display("UT: failure77 valid_force %0d held %0b peer %0b",
             forced, live == 'hb7, peer == 'h5a);
    sampled = uvm_hdl_release_and_read({ROOT_PATH, ".live"}, value);
    $display("UT: failure77 valid_release %0d sampled %0b",
             sampled, sampled == 1 && value[7:0] == 'hb7);
    live = 'h55;
    #1;
    $display("UT: failure77 reassigned %0b peer %0b", live == 'h55, peer == 'h5a);
    $finish;
  end
endmodule
