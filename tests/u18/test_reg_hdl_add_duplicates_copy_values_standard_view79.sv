/*
:name: test_reg_hdl_add_duplicates_copy_values_standard_view79
:description: original register HDL path observations for 18.4.6.4
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.6.4 18.4.6.4 18.4.6.5 18.4.6.7 18.4.6.9 17.2.1.7 17.2.3.1 18.1.2.2 18.1.6.4 18.1.6.7 18.1.6.8 18.1.6.9 18.4.2.1 18.4.2.2 17.2.3.3.3 1800-2023 6.21 7.6 13.5.1
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers79/hdl_models79.svh helpers79/hdl_views79.svh
:expected_exit: 0
:expected_stdout: @test_reg_hdl_add_duplicates_copy_values_standard_view79.expected
*/
// What it checks:
// 1. Repeated add_hdl_path calls for one abstraction retain the register
//    implementation alternatives.
// 2. By-value slice inputs retain the supplied path, offset and size values
//    after the caller changes its array.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.4.6.4 (UVM-REG-HDL-ADD-DUPLICATE-CONCATS) gives rule 1
//    above. Setup: Original 16-bit register/block models, legal most-to-least
//    nonoverlapping slices, named abstractions, isolated peers and fresh query
//    queues. Standard-view inputs use get_slices; separately declared controls
//    project the pinned library public slices member, an explicitly
//    nonstandard observability premise. No HDL storage is accessed. Expected:
//    Two independent high/low descriptions remain queryable without
//    prescribing alternative order.
// 2. 1800.2-2020 18.4.6.4 (UVM-REG-HDL-ADD-SLICE-VALUE-SNAPSHOT) gives rule 2
//    above. Setup: Original 16-bit register/block models, legal most-to-least
//    nonoverlapping slices, named abstractions, isolated peers and fresh query
//    queues. Standard-view inputs use get_slices; separately declared controls
//    project the pinned library public slices member, an explicitly
//    nonstandard observability premise. No HDL storage is accessed. Expected:
//    Both earlier descriptions keep their original values after changing and
//    reusing the caller array.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Standard public API observations; independent expectations precede runs.
// Symbolic metadata only; no physical HDL access or DPI calls.
module test_reg_hdl_add_duplicates_copy_values_standard_view79;
  import uvm_pkg::*;
  `include "hdl_models79.svh"
  `include "hdl_views79.svh"
  initial begin
    automatic block79 owner=new("owner79");
    automatic register79 selected=new("selected79");
    automatic register79 peer=new("peer79");
    uvm_hdl_path_slice supplied[];
    uvm_hdl_path_concat paths[$],other[$],peer_paths[$];
    bit valid;

    owner.configure();selected.configure(owner);peer.configure(owner);
    supplied=new[2];supplied[0]='{"a_hi",8,8};supplied[1]='{"a_lo",0,8};
    selected.add_hdl_path(supplied,"RTL");
    supplied[0]='{"b_hi",8,8};supplied[1]='{"b_lo",0,8};
    selected.add_hdl_path(supplied,"RTL");
    supplied[0].path="mutated";supplied[1].size=3;
    peer.add_hdl_path_slice("peer",-1,-1);
    selected.get_hdl_path(paths,"RTL");peer.get_hdl_path(peer_paths,"RTL");
    valid=paths.size()==2 && has_pair79(paths,"a_hi","a_lo") &&
          has_pair79(paths,"b_hi","b_lo");
    $display("UT: paths79 duplicate_snapshots %0b peer %0b",valid,
             peer_paths.size()==1 && one79(peer_paths[0],"peer",-1,-1));
    $finish;
  end
endmodule
