/*
:name: test_command_vpi_first_value_preserves_the_first_suffix_and_counts_all_matches
:description: command vpi first value preserves the first suffix and counts all matches (IEEE 1800.2-2020 Section G.1.4.1)
:tags: uG uvm
:type: simulation
:lrm: 1800.2-2020 G.1.4.1 G.1.3.4 1800-2023 6.21
:uvm: 2020.3.1
:uvm_dpi: yes
:uvm_cmdline_backend: vpi
:uvm_cmdline_oracle: verilator@5.052
:uvm_defines: UVM_HDL_NO_DPI
:dpi_c: @../../tools/cmdline_backend/uvm_cmdline_vpi.cpp
:files: ../../tools/cmdline_backend/uvm_cmdline_regex.cpp ../../tools/cmdline_backend/malloc.h
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:args: +kr_value=alpha,beta +kr_value=second +kr_empty=
:expected_stdout: @test_command_vpi_first_value_preserves_the_first_suffix_and_counts_all_matches.expected
*/
// What it checks:
// 1. get_arg_value returns the first matching suffix and the number of all
//    matches.
// 2. An exactly matching prefix can return an empty suffix.
// 3. get_arg_value returns zero when the selected prefix has no match.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 G.1.4.1 (UVM-CMDLINE-FIRST-SUFFIX-AND-TOTAL-COUNT) gives rule
//    1 above. Setup: Two ordered matching arguments supply different suffixes.
//    Expected: The first suffix is alpha,beta and the returned count is two.
// 2. 1800.2-2020 G.1.4.1 (UVM-CMDLINE-FIRST-EMPTY-SUFFIX) gives rule 2 above.
//    Setup: One supplied argument ends immediately after the queried prefix.
//    Expected: Count is one and the scalar suffix is empty.
// 3. 1800.2-2020 G.1.4.1 (UVM-CMDLINE-FIRST-MISSING-COUNT) gives rule 3 above.
//    Setup: A missing literal prefix is queried after successful queries.
//    Expected: The count is zero; the unspecified scalar output is not
//    asserted.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The command line gives an explicit first occurrence. A comma remains
// inside its suffix. The unmatched scalar value is not constrained.
module test_command_vpi_first_value_preserves_the_first_suffix_and_counts_all_matches;
  import uvm_pkg::*;
  initial begin
    automatic uvm_cmdline_processor processor = uvm_cmdline_processor::get_inst();
    string value;
    int count;
    value = "stale"; count = processor.get_arg_value("+kr_value=", value);
    $display("UT: first count %0d first_suffix %0d", count, value == "alpha,beta");
    value = "stale_again"; count = processor.get_arg_value("+kr_empty=", value);
    $display("UT: empty count %0d empty_suffix %0d", count, value == "");
    count = processor.get_arg_value("+kr_absent=", value);
    $display("UT: missing count %0d", count);
    $finish;
  end
endmodule
