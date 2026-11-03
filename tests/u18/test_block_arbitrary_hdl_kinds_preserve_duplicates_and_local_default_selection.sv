/*
:name: test_block_arbitrary_hdl_kinds_preserve_duplicates_and_local_default_selection
:description: block arbitrary hdl kinds preserve duplicates and local default selection
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.6.5 18.1.6.1 18.1.6.6 18.1.6.7 18.1.6.10 18.1.6.9 18.1.6.4 18.1.2.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_arbitrary_hdl_kinds_preserve_duplicates_and_local_default_selection.expected
*/
// Arbitrary kind strings identify symbolic path metadata, not HDL simulation.
module test_block_arbitrary_hdl_kinds_preserve_duplicates_and_local_default_selection;
  import uvm_pkg::*;
class block_type extends uvm_reg_block;
  function new(string name="",int available=UVM_NO_COVERAGE);
    super.new(name,available);
  endfunction
endclass

initial begin
  automatic block_type selected=new("chosen50");
  automatic block_type peer=new("peer50");
  string paths[$];
  bit seen[string];
  selected.add_hdl_path("rtl50");
  selected.add_hdl_path("impl0","c_model50");
  selected.add_hdl_path("impl1","c_model50");
  selected.add_hdl_path("case50","C_model50");
  peer.add_hdl_path("peer_impl50","c_model50");
  selected.set_default_hdl_path("c_model50");
  selected.get_hdl_path(paths);
  foreach (paths[i]) seen[paths[i]]=1;
  $display("UT: hdl_kinds default_exact %0d duplicate_count %0d members %0d",
    selected.get_default_hdl_path()=="c_model50",paths.size(),
    seen.num()==2 && seen.exists("impl0") && seen.exists("impl1"));
  $display("UT: hdl_kinds explicit_rtl %0d case_distinct %0d missing %0d default_present %0d",
    selected.has_hdl_path("RTL"),selected.has_hdl_path("C_model50"),
    !selected.has_hdl_path("missing50"),selected.has_hdl_path());
  selected.clear_hdl_path("c_model50"); paths.delete();
  selected.get_hdl_path(paths,"C_model50");
  $display("UT: hdl_kinds clear_default_absent %0d case_kept %0d peer_kept %0d peer_default %0d",
    !selected.has_hdl_path(),paths.size()==1 && paths[0]=="case50",
    peer.has_hdl_path("c_model50"),peer.get_default_hdl_path()=="RTL");
  $finish;
end
endmodule
