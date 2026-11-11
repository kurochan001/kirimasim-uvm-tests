/*
:name: test_reg_hdl_full_cartesian_custom_standard_view79
:description: original register HDL path observations for 18.4.6.9
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.6.9 18.4.6.4 18.4.6.5 18.4.6.7 18.4.6.9 17.2.1.7 17.2.3.1 18.1.2.2 18.1.6.4 18.1.6.7 18.1.6.8 18.1.6.9 18.4.2.1 18.4.2.2 17.2.3.3.3 1800-2023 6.21 7.6 13.5.1
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers79/hdl_models79.svh helpers79/hdl_views79.svh
:expected_exit: 0
:expected_stdout: @test_reg_hdl_full_cartesian_custom_standard_view79.expected
*/
// What it checks:
// 1. Full register paths include every applicable ancestor and register
//    implementation alternative.
// 2. A supplied separator joins the components of each full register HDL path.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.4.6.9 (UVM-REG-HDL-FULL-PATH-CARTESIAN) gives rule 1
//    above. Setup: Original 16-bit register/block models, legal most-to-least
//    nonoverlapping slices, named abstractions, isolated peers and fresh query
//    queues. Standard-view inputs use get_slices; separately declared controls
//    project the pinned library public slices member, an explicitly
//    nonstandard observability premise. No HDL storage is accessed. Expected:
//    Two root, two child and two register alternatives produce all eight
//    distinct concatenations with their slice coordinates.
// 2. 1800.2-2020 18.4.6.9 (UVM-REG-HDL-FULL-PATH-EXPLICIT-SEPARATOR) gives
//    rule 2 above. Setup: Original 16-bit register/block models, legal
//    most-to-least nonoverlapping slices, named abstractions, isolated peers
//    and fresh query queues. Standard-view inputs use get_slices; separately
//    declared controls project the pinned library public slices member, an
//    explicitly nonstandard observability premise. No HDL storage is accessed.
//    Expected: All eight concatenations use the supplied slash separator while
//    retaining slice coordinates.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Standard public API observations; independent expectations precede runs.
// Symbolic metadata only; no physical HDL access or DPI calls.
module test_reg_hdl_full_cartesian_custom_standard_view79;
  import uvm_pkg::*;
  `include "hdl_models79.svh"
  `include "hdl_views79.svh"
  initial begin
    automatic block79 root_block=new("root79");
    automatic block79 child=new("child79");
    automatic register79 selected=new("selected79");
    uvm_hdl_path_slice supplied[];
    uvm_hdl_path_concat paths[$];
    root_block.configure(null,"dut0");root_block.add_hdl_path("dut1");
    child.configure(root_block,"bank0");child.add_hdl_path("bank1");
    selected.configure(child);
    supplied=new[2];supplied[0]='{"a_hi",8,8};supplied[1]='{"a_lo",0,8};
    selected.add_hdl_path(supplied);
    supplied[0]='{"b_hi",8,8};supplied[1]='{"b_lo",0,8};
    selected.add_hdl_path(supplied);
    selected.get_full_hdl_path(paths,"RTL","/");
    $display("UT: paths79 cartesian %0b",cartesian79(paths,"/"));
    $finish;
  end
endmodule
