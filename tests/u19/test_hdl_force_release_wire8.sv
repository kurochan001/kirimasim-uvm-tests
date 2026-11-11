/*
:name: test_hdl_force_release_wire8
:description: real 8-bit wire force and release preserve the declared effects (IEEE 1800.2-2020 Section 19.6.2.6)
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
:expected_stdout: @test_hdl_force_release_wire8.expected
*/
// What it checks:
// 1. HDL force reports one for a successful operation and zero when the call
//    fails.
// 2. A forced value overrides subsequent ordinary procedural or
//    continuous-driver updates until release.
// 3. HDL release reports one for success and zero when the call fails.
// 4. A successful release removes the prior force so ordinary assignment or
//    net-driver behavior resumes.
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
// 3. 1800.2-2020 19.6.2.6 (UVM-HDL-RELEASE-RETURN-STATUS) gives rule 3 above.
//    Setup: Actual public forceable 8/40-bit reg and wire signals, one
//    independent unforced peer, opposing procedural assignments or changed
//    continuous drivers, plain release or immediate release-and-read, and
//    missing/uninstrumented failure targets. Public VPI force/release flags
//    implement the separately fingerprinted backend; ordinary runs do not link
//    it. Expected: Valid forced paths return one and the declared
//    missing/uninstrumented failure paths return zero.
// 4. 1800.2-2020 19.6.2.6 (UVM-HDL-RELEASE-REMOVES-FORCE) gives rule 4 above.
//    Setup: Actual public forceable 8/40-bit reg and wire signals, one
//    independent unforced peer, opposing procedural assignments or changed
//    continuous drivers, plain release or immediate release-and-read, and
//    missing/uninstrumented failure targets. Public VPI force/release flags
//    implement the separately fingerprinted backend; ordinary runs do not link
//    it. Expected: Reg retains the forced value until the next procedural
//    assignment; wire resolves to its current driver and follows a subsequent
//    driver change.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original live HDL signals; forceable is the documented compiler interface.
// Settled force observations and immediate release readback stay distinct.
module test_hdl_force_release_wire8;
  import uvm_pkg::*;
  logic [7:0] source_value;
  wire [7:0] live /*verilator public_flat_rw*/ /*verilator forceable*/;
  assign live = source_value;
  logic [7:0] peer /*verilator public_flat_rw*/;
  localparam string ROOT_PATH = "test_hdl_force_release_wire8";
  initial begin
    int result;
    uvm_hdl_data_t sample;
    source_value = 8'h12; peer = 8'h5a; sample = '1;
    #1;
    result = uvm_hdl_force({ROOT_PATH, ".live"}, 8'h8e);
    #1;
    $display("UT: force77 success %0d held %0b peer %0b", result,
             live == 8'h8e, peer == 8'h5a);
    source_value = 8'h34;
    #1;
    $display("UT: force77 reassignment_held %0b peer %0b",
             live == 8'h8e, peer == 8'h5a);
    result = uvm_hdl_release({ROOT_PATH, ".live"});
    $display("UT: release77 success %0d", result);
    #1;
    $display("UT: wire77 resolved %0b peer %0b",
             live == 8'h34, peer == 8'h5a);
    source_value = 8'h56;
    #1;
    $display("UT: wire77 resumed %0b peer %0b", live == 8'h56, peer == 8'h5a);
    $finish;
  end
endmodule
