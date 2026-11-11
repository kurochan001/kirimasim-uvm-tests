/*
:name: test_block_hdl_clear_is_kind_local_and_preserves_sibling_incremental_paths
:description: block HDL clear removes only the selected kind and leaves sibling path lists independent (IEEE 1800.2-2020 Section 18.1.6.4)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.6.4 18.1.2.1 18.1.2.2 18.1.6.5 18.1.6.6 18.1.6.7 18.1.6.8 18.1.6.9 18.1.6.10 18.1.6.11 18.1.6.12 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_hdl_clear_is_kind_local_and_preserves_sibling_incremental_paths.expected
*/
// What it checks:
// 1. Block path clearing removes only the selected kind from that instance.
// 2. Block incremental path queries return only that block path components for
//    the selected default kind.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.1.6.4 (UVM-BLOCK-HDL-KIND-CLEAR) gives rule 1 above.
//    Setup: Use RTL/GATE paths, a GATE default and an independent sibling
//    block. Expected: Default clear removes RTL; explicit GATE clear removes
//    GATE without changing the sibling paths.
// 2. 1800.2-2020 18.1.6.7 (UVM-BLOCK-INCREMENTAL-HDL-PATHS) gives rule 2
//    above. Setup: Query two GATE alternatives and a sibling path after
//    independent clearing. Expected: The first query returns gate0/gate1 and
//    the sibling retains peer_gate.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Symbolic HDL path metadata only: no HDL access, RTL storage or DPI calls.
module test_block_hdl_clear_is_kind_local_and_preserves_sibling_incremental_paths;
  import uvm_pkg::*;
  class model_block extends uvm_reg_block;
    function new(string name="blk"); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(); super.new("r", 16, UVM_NO_COVERAGE); endfunction
  endclass
  initial begin

    automatic model_block first = new("first");
    automatic model_block second = new("second");
    string paths[$];
    bit both;
    first.configure(null, "rtl_first"); second.configure(null, "rtl_second");
    first.set_default_hdl_path("GATE");
    first.add_hdl_path("gate0", "GATE"); first.add_hdl_path("gate1", "GATE");
    second.add_hdl_path("peer_gate", "GATE");
    first.clear_hdl_path(); first.get_hdl_path(paths);
    both = paths.size() == 2 && ((paths[0] == "gate0" && paths[1] == "gate1") ||
           (paths[0] == "gate1" && paths[1] == "gate0"));
    $display("UT: clear_rtl absent %0d default_present %0d paths %0d members %0d",
             !first.has_hdl_path("RTL"), first.has_hdl_path(), paths.size(), both);
    first.clear_hdl_path("GATE");
    paths.delete(); second.get_hdl_path(paths, "GATE");
    $display("UT: clear_gate absent %0d peer_rtl %0d peer_paths %0d peer_value %s",
             !first.has_hdl_path("GATE"), second.has_hdl_path("RTL"), paths.size(), paths[0]);

    $finish;
  end
endmodule
