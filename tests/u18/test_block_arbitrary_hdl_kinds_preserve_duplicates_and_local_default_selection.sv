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
// What it checks:
// 1. Arbitrary selected string kinds identify independent HDL path
//    representations for one block.
// 2. Omitted add_hdl_path kind adds the selected path under RTL.
// 3. Repeated add_hdl_path for one selected kind retains both distinct
//    implementation paths.
// 4. has_hdl_path distinguishes the selected explicit/default present kind
//    from a missing or cleared kind.
// 5. set_default_hdl_path selects the exact local kind without changing a peer
//    default.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.1.6.1 (UVM-BLOCK-CONFIG-KIND-ARBITRARY) gives rule 1
//    above. Setup: Original root, flattened intermediate and leaf blocks use
//    selected symbolic path strings. Only metadata getters are called;
//    explicit RTL is used unless the fixture deliberately tests default-kind
//    inheritance. Expected: Arbitrary selected string kinds identify
//    independent HDL path representations for one block.
// 2. 1800.2-2020 18.1.6.5 (UVM-BLOCK-CONFIG-ADD-HDL-DEFAULT-RTL) gives rule 2
//    above. Setup: Original root, flattened intermediate and leaf blocks use
//    selected symbolic path strings. Only metadata getters are called;
//    explicit RTL is used unless the fixture deliberately tests default-kind
//    inheritance. Expected: Omitted add_hdl_path kind adds the selected path
//    under RTL.
// 3. 1800.2-2020 18.1.6.5 (UVM-BLOCK-CONFIG-ADD-HDL-DUPLICATES) gives rule 3
//    above. Setup: Original root, flattened intermediate and leaf blocks use
//    selected symbolic path strings. Only metadata getters are called;
//    explicit RTL is used unless the fixture deliberately tests default-kind
//    inheritance. Expected: Repeated add_hdl_path for one selected kind
//    retains both distinct implementation paths.
// 4. 1800.2-2020 18.1.6.6 (UVM-BLOCK-CONFIG-HAS-HDL-SELECTED-KIND) gives rule
//    4 above. Setup: Original root, flattened intermediate and leaf blocks use
//    selected symbolic path strings. Only metadata getters are called;
//    explicit RTL is used unless the fixture deliberately tests default-kind
//    inheritance. Expected: has_hdl_path distinguishes the selected
//    explicit/default present kind from a missing or cleared kind.
// 5. 1800.2-2020 18.1.6.10 (UVM-BLOCK-CONFIG-SET-DEFAULT-HDL-LOCAL) gives rule
//    5 above. Setup: Original root, flattened intermediate and leaf blocks use
//    selected symbolic path strings. Only metadata getters are called;
//    explicit RTL is used unless the fixture deliberately tests default-kind
//    inheritance. Expected: set_default_hdl_path selects the exact local kind
//    without changing a peer default.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
