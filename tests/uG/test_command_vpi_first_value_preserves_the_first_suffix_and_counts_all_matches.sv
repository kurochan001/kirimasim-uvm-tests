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
