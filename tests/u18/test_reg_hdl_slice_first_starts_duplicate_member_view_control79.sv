/*
:name: test_reg_hdl_slice_first_starts_duplicate_member_view_control79
:description: original register HDL path observations for 18.4.6.5
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.6.5 18.4.6.4 18.4.6.5 18.4.6.7 18.4.6.9 17.2.1.7 17.2.3.1 18.1.2.2 18.1.6.4 18.1.6.7 18.1.6.8 18.1.6.9 18.4.2.1 18.4.2.2 1800-2023 6.21 7.6 13.5.1
:uvm: 2020.3.1
:uvm_defines: KIRIMASIM_HDL_VIEW_CONTROL79
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers79/hdl_models79.svh helpers79/hdl_views79.svh
:expected_exit: 0
:expected_stdout: @test_reg_hdl_slice_first_starts_duplicate_member_view_control79.expected
*/
// What it checks:
// It is a control: it supports the setup or conditions of this duty, which
// other tests check directly:
// A true first argument starts a duplicate HDL implementation for the selected
// abstraction.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.4.6.5 (UVM-REG-HDL-SLICE-FIRST-DUPLICATE) gives the rule
// above. Setup: Original 16-bit register/block models, legal most-to-least
// nonoverlapping slices, named abstractions, isolated peers and fresh query
// queues. Standard-view inputs use get_slices; separately declared controls
// project the pinned library public slices member, an explicitly nonstandard
// observability premise. No HDL storage is accessed. Expected: Two high/low
// alternatives coexist while another abstraction and peer retain their single
// whole paths.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Explicit nonstandard view control; no standard API pass is inferred.
// Symbolic metadata only; no physical HDL access or DPI calls.
module test_reg_hdl_slice_first_starts_duplicate_member_view_control79;
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
    selected.add_hdl_path_slice("a_hi",8,8,0,"RTL");
    selected.add_hdl_path_slice("a_lo",0,8,0,"RTL");
    selected.add_hdl_path_slice("gate",-1,-1,0,"GATE");
    selected.add_hdl_path_slice("b_hi",8,8,1,"RTL");
    selected.add_hdl_path_slice("b_lo",0,8);
    peer.add_hdl_path_slice("peer",-1,-1);
    selected.get_hdl_path(paths,"RTL");selected.get_hdl_path(other,"GATE");
    peer.get_hdl_path(peer_paths,"RTL");
    valid=paths.size()==2 && has_pair79(paths,"a_hi","a_lo") &&
          has_pair79(paths,"b_hi","b_lo");
    $display("UT: paths79 first_duplicate %0b other_kind %0b peer %0b",valid,
      other.size()==1 && one79(other[0],"gate",-1,-1),
      peer_paths.size()==1 && one79(peer_paths[0],"peer",-1,-1));
    $finish;
  end
endmodule
