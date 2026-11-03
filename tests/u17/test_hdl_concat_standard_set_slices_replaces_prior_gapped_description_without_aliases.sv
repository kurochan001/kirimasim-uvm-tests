/*
:name: test_hdl_concat_standard_set_slices_replaces_prior_gapped_description_without_aliases
:description: hdl concat standard set slices replaces prior gapped description without aliases (IEEE 1800.2-2020 Section 17.2.3.3.2)
:tags: u17 uvm
:type: simulation
:lrm: 1800.2-2020 17.2.3.3.2 17.2.3.1 17.2.3.3.1 17.2.3.3.3 17.2.1.7 1800-2023 6.21 6.19
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_hdl_concat_standard_set_slices_replaces_prior_gapped_description_without_aliases.expected
*/
// Valid descriptions are most-to-least, nonoverlapping, and may contain a gap.
// Use only the standard set_slices/get_slices methods. Metadata copying is
// observed without any real HDL variable, DPI or library legacy-member access.
module test_hdl_concat_standard_set_slices_replaces_prior_gapped_description_without_aliases;
  import uvm_pkg::*;
  initial begin
    automatic uvm_hdl_path_concat first = new();
    automatic uvm_hdl_path_concat peer = new();
    uvm_hdl_path_slice supplied[], snapshot[], peer_slices[];
    supplied = new[2];
    supplied[0] = '{"high", 24, 8}; supplied[1] = '{"low", 0, 8};
    first.set_slices(supplied); peer.set_slices(supplied);
    supplied[0].path = "mutated";
    first.get_slices(snapshot);
    $display("UT: initial count %0d high %0d low %0d", snapshot.size(),
             snapshot[0].path == "high" && snapshot[0].offset == 24 && snapshot[0].size == 8,
             snapshot[1].path == "low" && snapshot[1].offset == 0 && snapshot[1].size == 8);
    snapshot[0].path = "returned_mutation";
    first.get_slices(snapshot);
    $display("UT: returned_copy %0d", snapshot[0].path == "high");
    supplied = new[1]; supplied[0] = '{"whole", -1, -1}; first.set_slices(supplied);
    first.get_slices(snapshot); peer.get_slices(peer_slices);
    $display("UT: replaced count %0d whole %0d peer_count %0d peer_high %0d", snapshot.size(),
             snapshot[0].path == "whole" && snapshot[0].offset == -1 && snapshot[0].size == -1,
             peer_slices.size(), peer_slices[0].path == "high");
    supplied = new[0]; first.set_slices(supplied); first.get_slices(snapshot);
    peer.get_slices(peer_slices);
    $display("UT: cleared %0d peer_retained %0d", snapshot.size(), peer_slices.size() == 2);
    $finish;
  end
endmodule
