/*
:name: test_reg_hdl_add_default_rtl_member_view_control79
:description: original register HDL path observations for 18.4.6.4
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.6.4 18.4.6.4 18.4.6.5 18.4.6.7 18.4.6.9 17.2.1.7 17.2.3.1 18.1.2.2 18.1.6.4 18.1.6.7 18.1.6.8 18.1.6.9 18.4.2.1 18.4.2.2 1800-2023 6.21 7.6 13.5.1
:uvm: 2020.3.1
:uvm_defines: KIRIMASIM_HDL_VIEW_CONTROL79
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers79/hdl_models79.svh helpers79/hdl_views79.svh
:expected_exit: 0
:expected_stdout: @test_reg_hdl_add_default_rtl_member_view_control79.expected
*/
// Explicit nonstandard view control; no standard API pass is inferred.
// Symbolic metadata only; no physical HDL access or DPI calls.
module test_reg_hdl_add_default_rtl_member_view_control79;
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

    owner.configure();owner.set_default_hdl_path("GATE");
    selected.configure(owner);peer.configure(owner);
    supplied=new[2];supplied[0]='{"rtl_hi",8,8};supplied[1]='{"rtl_lo",0,8};
    selected.add_hdl_path(supplied);
    selected.add_hdl_path_slice("gate",-1,-1,0,"GATE");
    peer.add_hdl_path_slice("peer",-1,-1);
    selected.get_hdl_path(paths,"RTL");selected.get_hdl_path(other);
    peer.get_hdl_path(peer_paths,"RTL");
    valid=paths.size()==1 && other.size()==1 && peer_paths.size()==1;
    if (valid) valid=pair79(paths[0],"rtl_hi","rtl_lo") &&
      one79(other[0],"gate",-1,-1) && one79(peer_paths[0],"peer",-1,-1);
    $display("UT: paths79 default_rtl %0b parent_kind %0b peer %0b",valid,
             owner.get_default_hdl_path()=="GATE",peer_paths.size()==1);
    $finish;
  end
endmodule
