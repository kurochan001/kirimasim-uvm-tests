/*
:name: test_hdl_concat_standard_add_slice_appends_after_replacement_and_preserves_peer
:description: hdl concat standard add slice appends after replacement and preserves peer (IEEE 1800.2-2020 Section 17.2.3.3.4)
:tags: u17 uvm
:type: simulation
:lrm: 1800.2-2020 17.2.3.3.4 17.2.3.1 17.2.3.3.1 17.2.3.3.2 17.2.3.3.3 17.2.1.7 1800-2023 6.21 6.19
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_hdl_concat_standard_add_slice_appends_after_replacement_and_preserves_peer.expected
*/
// What it checks:
// 1. add_slice appends the supplied value after the existing valid
//    description.
// 2. add_slice appends to the current array after replacement by an empty
//    array.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 17.2.3.3.4 (UVM-REG-GLOBAL-CONCAT-APPEND-AFTER-SET) gives
//    rule 1 above. Setup: One high slice is installed, then one lower slice is
//    appended. Expected: The fresh result has high then low; the peer still
//    has one high slice.
// 2. 1800.2-2020 17.2.3.3.4 (UVM-REG-GLOBAL-CONCAT-APPEND-AFTER-CLEAR) gives
//    rule 2 above. Setup: The previous array is cleared and a whole slice is
//    appended. Expected: The fresh result has only the whole slice and the
//    peer high remains intact.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Append order and replacement use valid metadata only. These methods may be
// missing in a library; do not substitute its legacy slices member or set API.
module test_hdl_concat_standard_add_slice_appends_after_replacement_and_preserves_peer;
  import uvm_pkg::*;
  initial begin
    automatic uvm_hdl_path_concat first = new();
    automatic uvm_hdl_path_concat peer = new();
    uvm_hdl_path_slice supplied[], snapshot[], peer_slices[], added;
    supplied = new[1]; supplied[0] = '{"high", 16, 8};
    first.set_slices(supplied); peer.set_slices(supplied);
    added = '{"low", 0, 8}; first.add_slice(added); added.path = "changed";
    first.get_slices(snapshot); peer.get_slices(peer_slices);
    $display("UT: appended count %0d high %0d low %0d peer_count %0d", snapshot.size(),
             snapshot[0].path == "high" && snapshot[0].offset == 16 && snapshot[0].size == 8,
             snapshot[1].path == "low" && snapshot[1].offset == 0 && snapshot[1].size == 8,
             peer_slices.size());
    supplied = new[0]; first.set_slices(supplied);
    added = '{"whole", -1, -1}; first.add_slice(added); first.get_slices(snapshot);
    peer.get_slices(peer_slices);
    $display("UT: after_clear count %0d whole %0d peer_high %0d", snapshot.size(),
             snapshot[0].path == "whole" && snapshot[0].offset == -1 && snapshot[0].size == -1,
             peer_slices[0].path == "high");
    $finish;
  end
endmodule
