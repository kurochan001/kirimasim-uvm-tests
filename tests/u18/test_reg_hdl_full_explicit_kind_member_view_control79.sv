/*
:name: test_reg_hdl_full_explicit_kind_member_view_control79
:description: original register HDL path observations for 18.4.6.9
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.6.9 18.4.6.4 18.4.6.5 18.4.6.7 18.4.6.9 17.2.1.7 17.2.3.1 18.1.2.2 18.1.6.4 18.1.6.7 18.1.6.8 18.1.6.9 18.4.2.1 18.4.2.2 1800-2023 6.21 7.6 13.5.1
:uvm: 2020.3.1
:uvm_defines: KIRIMASIM_HDL_VIEW_CONTROL79
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers79/hdl_models79.svh helpers79/hdl_views79.svh
:expected_exit: 0
:expected_stdout: @test_reg_hdl_full_explicit_kind_member_view_control79.expected
*/
// What it checks:
// It is a control: it supports the setup or conditions of this duty, which
// other tests check directly:
// An explicit full-path abstraction selects that abstraction despite different
// ancestor defaults.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.4.6.9 (UVM-REG-HDL-FULL-PATH-EXPLICIT-KIND) gives the rule
// above. Setup: Original 16-bit register/block models, legal most-to-least
// nonoverlapping slices, named abstractions, isolated peers and fresh query
// queues. Standard-view inputs use get_slices; separately declared controls
// project the pinned library public slices member, an explicitly nonstandard
// observability premise. No HDL storage is accessed. Expected: The explicit
// COMMON query produces dut_X.bank_X.reg_X while retaining mixed defaults.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Explicit nonstandard view control; no standard API pass is inferred.
// Symbolic metadata only; no physical HDL access or DPI calls.
module test_reg_hdl_full_explicit_kind_member_view_control79;
  import uvm_pkg::*;
  `include "hdl_models79.svh"
  `include "hdl_views79.svh"
  initial begin
    automatic block79 root_block=new("root79");
    automatic block79 child=new("child79");
    automatic register79 selected=new("selected79");
    uvm_hdl_path_concat paths[$];
    bit valid;
    root_block.configure();root_block.add_hdl_path("dut_A","ROOT_A");
    root_block.add_hdl_path("dut_X","COMMON");root_block.set_default_hdl_path("ROOT_A");
    child.configure(root_block);child.add_hdl_path("bank_B","CHILD_B");
    child.add_hdl_path("bank_X","COMMON");child.set_default_hdl_path("CHILD_B");
    selected.configure(child);
    selected.add_hdl_path_slice("reg_B",-1,-1,0,"CHILD_B");
    selected.add_hdl_path_slice("reg_X",-1,-1,0,"COMMON");
    selected.get_full_hdl_path(paths,"COMMON");
    valid=paths.size()==1;
    if (valid) valid=one79(paths[0],"dut_X.bank_X.reg_X",-1,-1);
    $display("UT: paths79 explicit_kind %0b defaults %0b",valid,
      root_block.get_default_hdl_path()=="ROOT_A" && child.get_default_hdl_path()=="CHILD_B");
    $finish;
  end
endmodule
