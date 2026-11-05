/*
:name: test_reg_hdl_slice_first_starts_duplicate_standard_view79
:description: original register HDL path observations for 18.4.6.5
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.6.5 18.4.6.4 18.4.6.5 18.4.6.7 18.4.6.9 17.2.1.7 17.2.3.1 18.1.2.2 18.1.6.4 18.1.6.7 18.1.6.8 18.1.6.9 18.4.2.1 18.4.2.2 17.2.3.3.3 1800-2023 6.21 7.6 13.5.1
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers79/hdl_models79.svh helpers79/hdl_views79.svh
:expected_exit: 0
:expected_stdout: @test_reg_hdl_slice_first_starts_duplicate_standard_view79.expected
*/
// Standard public API observations; independent expectations precede runs.
// Symbolic metadata only; no physical HDL access or DPI calls.
module test_reg_hdl_slice_first_starts_duplicate_standard_view79;
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
