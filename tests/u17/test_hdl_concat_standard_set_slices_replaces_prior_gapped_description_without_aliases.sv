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
// What it checks:
// 1. A valid concat description may preserve a gap between nonoverlapping
//    slices.
// 2. A single whole-register concat description uses one -1/-1 slice.
// 3. set_slices replaces the previously stored array with the supplied
//    description.
// 4. Initializing slices retains the supplied value independently of later
//    caller-array changes.
// 5. A returned slice array can be modified without changing the stored array.
// 6. set_slices can initialize the stored array to the supplied empty array.
// 7. Replacing one concat description leaves a separate instance unchanged.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 17.2.3.1 (UVM-REG-GLOBAL-CONCAT-GAPPED-DESCRIPTION) gives
//    rule 1 above. Setup: A high slice at 24 and a low slice at 0 each cover 8
//    bits. Expected: The returned array retains high then low with their
//    selected offsets and sizes.
// 2. 1800.2-2020 17.2.3.1 (UVM-REG-GLOBAL-CONCAT-WHOLE-DESCRIPTION) gives rule
//    2 above. Setup: The gapped description is replaced by a single
//    whole-register description. Expected: The returned array contains only
//    the whole slice with both fields -1.
// 3. 1800.2-2020 17.2.3.3.2 (UVM-REG-GLOBAL-CONCAT-SET-REPLACEMENT) gives rule
//    3 above. Setup: A two-slice description is replaced by one whole slice.
//    Expected: The new array has length one and the selected whole metadata.
// 4. 1800.2-2020 17.2.3.3.2 (UVM-REG-GLOBAL-CONCAT-SET-INPUT-COPY) gives rule
//    4 above. Setup: The caller changes its high path after passing the array.
//    Expected: The stored high path remains high.
// 5. 1800.2-2020 17.2.3.3.3 (UVM-REG-GLOBAL-CONCAT-GET-OUTPUT-COPY) gives rule
//    5 above. Setup: The caller modifies a returned path and retrieves the
//    array again. Expected: The fresh result retains the stored high path.
// 6. 1800.2-2020 17.2.3.3.2 (UVM-REG-GLOBAL-CONCAT-SET-EMPTY) gives rule 6
//    above. Setup: An empty array follows a nonempty valid description.
//    Expected: A fresh query returns an array of length zero.
// 7. 1800.2-2020 17.2.3.3.2 (UVM-REG-GLOBAL-CONCAT-PEER-ISOLATION) gives rule
//    7 above. Setup: Two instances receive the same initial values and only
//    one is replaced or cleared. Expected: Fresh peer queries retain the
//    original two slices.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
