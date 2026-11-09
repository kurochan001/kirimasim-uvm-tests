/*
:name: test_hdl_slice_struct_preserves_whole_register_sentinel_and_gapped_fields
:description: hdl slice struct preserves whole register sentinel and gapped fields (IEEE 1800.2-2020 Section 17.2.1.7)
:tags: u17 uvm
:type: simulation
:lrm: 1800.2-2020 17.2.1.7 17.2.3.1 1800-2023 6.21 6.19
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_hdl_slice_struct_preserves_whole_register_sentinel_and_gapped_fields.expected
*/
// What it checks:
// 1. The public slice struct exposes the HDL path string.
// 2. The public slice struct carries the implemented register LSB offset.
// 3. The public slice struct carries the number of implemented bits.
// 4. A whole-register slice can represent offset and size as -1.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 17.2.1.7 (UVM-REG-GLOBAL-SLICE-PATH) gives rule 1 above.
//    Setup: Original whole and gapped partial descriptions are assigned to the
//    public struct. Expected: Each selected path string is retained in its
//    struct value.
// 2. 1800.2-2020 17.2.1.7 (UVM-REG-GLOBAL-SLICE-OFFSET) gives rule 2 above.
//    Setup: Original whole and gapped partial descriptions are assigned to the
//    public struct. Expected: Selected partial slices retain offsets 24 and 0.
// 3. 1800.2-2020 17.2.1.7 (UVM-REG-GLOBAL-SLICE-SIZE) gives rule 3 above.
//    Setup: Original whole and gapped partial descriptions are assigned to the
//    public struct. Expected: Both selected partial slices retain size 8.
// 4. 1800.2-2020 17.2.1.7 (UVM-REG-GLOBAL-SLICE-WHOLE-SENTINEL) gives rule 4
//    above. Setup: Original whole and gapped partial descriptions are assigned
//    to the public struct. Expected: The whole-register metadata retains -1 in
//    both fields.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe only public struct metadata. A whole-register sentinel uses -1 in
// both integer fields. Gapped slices do not imply actual HDL/DPI access.
module test_hdl_slice_struct_preserves_whole_register_sentinel_and_gapped_fields;
  import uvm_pkg::*;
  initial begin
    uvm_hdl_path_slice whole, upper, lower, copied;
    whole.path = "dut.whole"; whole.offset = -1; whole.size = -1;
    upper.path = "dut.high"; upper.offset = 24; upper.size = 8;
    lower.path = "dut.low"; lower.offset = 0; lower.size = 8;
    copied = upper;
    upper.path = "changed"; upper.offset = 16; upper.size = 4;
    $display("UT: whole path %0d offset %0d size %0d", whole.path == "dut.whole",
             whole.offset == -1, whole.size == -1);
    $display("UT: copied path %0d offset %0d size %0d", copied.path == "dut.high",
             copied.offset == 24, copied.size == 8);
    $display("UT: lower path %0d offset %0d size %0d gap %0d", lower.path == "dut.low",
             lower.offset == 0, lower.size == 8, copied.offset > lower.offset + lower.size);
    $finish;
  end
endmodule
