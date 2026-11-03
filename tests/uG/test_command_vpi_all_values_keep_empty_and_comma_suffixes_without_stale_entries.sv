/*
:name: test_command_vpi_all_values_keep_empty_and_comma_suffixes_without_stale_entries
:description: command vpi all values keep empty and comma suffixes without stale entries (IEEE 1800.2-2020 Section G.1.4.2)
:tags: uG uvm
:type: simulation
:lrm: 1800.2-2020 G.1.4.2 G.1.3.4 1800-2023 6.21
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
:args: +kr_many=alpha,beta +kr_many= +kr_many=tail +kr_other=ignored
:expected_stdout: @test_command_vpi_all_values_keep_empty_and_comma_suffixes_without_stale_entries.expected
*/
// Literal prefixes select all suffixes, including empty and comma-containing
// values. Membership is checked without prescribing iteration order.
module test_command_vpi_all_values_keep_empty_and_comma_suffixes_without_stale_entries;
  import uvm_pkg::*;
  initial begin
    automatic uvm_cmdline_processor processor = uvm_cmdline_processor::get_inst();
    string values[$];
    int count, comma, empty, tail, stale;
    values.push_back("stale"); count = processor.get_arg_values("+kr_many=", values);
    comma = 0; empty = 0; tail = 0; stale = 0;
    foreach (values[i]) begin
      if (values[i] == "alpha,beta") comma++;
      if (values[i] == "") empty++;
      if (values[i] == "tail") tail++;
      if (values[i] == "stale") stale++;
    end
    $display("UT: suffixes count %0d size %0d comma %0d empty %0d tail %0d stale %0d",
             count, values.size(), comma, empty, tail, stale);
    count = processor.get_arg_values("+kr_absent=", values);
    $display("UT: missing count %0d size %0d", count, values.size());
    count = processor.get_arg_values("+kr_many=", values);
    $display("UT: repeated count %0d size %0d", count, values.size());
    $finish;
  end
endmodule
