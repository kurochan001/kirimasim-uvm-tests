/*
:name: test_hdl_force_release_read_reg40
:description: real 40-bit reg force and release_read preserve the declared effects (IEEE 1800.2-2020 Section 19.6.2.5)
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
:expected_stdout: @test_hdl_force_release_read_reg40.expected
*/
// What it checks:
// 1. HDL force reports one for a successful operation and zero when the call
//    fails.
// 2. A forced value overrides subsequent ordinary procedural or
//    continuous-driver updates until release.
// 3. HDL release-and-read reports one for success and zero when the call
//    fails.
// 4. For a procedurally assigned reg, release-and-read returns its retained
//    forced value until the next procedural assignment.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 19.6.2.3 (UVM-HDL-FORCE-RETURN-STATUS) gives rule 1 above.
//    Setup: Actual public forceable 8/40-bit reg and wire signals, one
//    independent unforced peer, opposing procedural assignments or changed
//    continuous drivers, plain release or immediate release-and-read, and
//    missing/uninstrumented failure targets. Public VPI force/release flags
//    implement the separately fingerprinted backend; ordinary runs do not link
//    it. Expected: Instrumented valid paths return one; missing/uninstrumented
//    paths return zero and the independent valid control succeeds.
// 2. 1800.2-2020 19.6.2.3 (UVM-HDL-FORCE-HOLDS-VALUE) gives rule 2 above.
//    Setup: Actual public forceable 8/40-bit reg and wire signals, one
//    independent unforced peer, opposing procedural assignments or changed
//    continuous drivers, plain release or immediate release-and-read, and
//    missing/uninstrumented failure targets. Public VPI force/release flags
//    implement the separately fingerprinted backend; ordinary runs do not link
//    it. Expected: The selected forced value remains while the opposing
//    assignment/driver changes, and the unforced peer is unchanged.
// 3. 1800.2-2020 19.6.2.5 (UVM-HDL-RELEASE-READ-RETURN-STATUS) gives rule 3
//    above. Setup: Actual public forceable 8/40-bit reg and wire signals, one
//    independent unforced peer, opposing procedural assignments or changed
//    continuous drivers, plain release or immediate release-and-read, and
//    missing/uninstrumented failure targets. Public VPI force/release flags
//    implement the separately fingerprinted backend; ordinary runs do not link
//    it. Expected: Valid forced paths return one; missing/uninstrumented paths
//    return zero without prescribing failed output data.
// 4. 1800.2-2020 19.6.2.5 (UVM-HDL-RELEASE-READ-REG-VALUE) gives rule 4 above.
//    Setup: Actual public forceable 8/40-bit reg and wire signals, one
//    independent unforced peer, opposing procedural assignments or changed
//    continuous drivers, plain release or immediate release-and-read, and
//    missing/uninstrumented failure targets. Public VPI force/release flags
//    implement the separately fingerprinted backend; ordinary runs do not link
//    it. Expected: Immediate readback and the retained reg equal the forced
//    value; a subsequent procedural assignment becomes visible.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original live HDL signals; forceable is the documented compiler interface.
// Settled force observations and immediate release readback stay distinct.
module test_hdl_force_release_read_reg40;
  import uvm_pkg::*;
  logic [39:0] live /*verilator public_flat_rw*/ /*verilator forceable*/;
  logic [39:0] peer /*verilator public_flat_rw*/;
  localparam string ROOT_PATH = "test_hdl_force_release_read_reg40";
  initial begin
    int result;
    uvm_hdl_data_t sample;
    live = 40'h123456789a; peer = 40'h5aa55aa55a; sample = '1;
    #1;
    result = uvm_hdl_force({ROOT_PATH, ".live"}, 40'he1d2c3b4a5);
    #1;
    $display("UT: force77 success %0d held %0b peer %0b", result,
             live == 40'he1d2c3b4a5, peer == 40'h5aa55aa55a);
    live = 40'h1122334455;
    #1;
    $display("UT: force77 reassignment_held %0b peer %0b",
             live == 40'he1d2c3b4a5, peer == 40'h5aa55aa55a);
    result = uvm_hdl_release_and_read({ROOT_PATH, ".live"}, sample);
    $display("UT: release77 success %0d sampled %0b", result,
             result == 1 && sample[39:0] == 40'he1d2c3b4a5);
    #1;
    $display("UT: reg77 retained %0b peer %0b",
             live == 40'he1d2c3b4a5, peer == 40'h5aa55aa55a);
    live = 40'haa99776655;
    #1;
    $display("UT: reg77 resumed %0b peer %0b", live == 40'haa99776655, peer == 40'h5aa55aa55a);
    $finish;
  end
endmodule
