/*
:name: test_command_vpi_plusargs_exclude_dash_arguments_and_replace_caller_contents
:description: command vpi plusargs exclude dash arguments and replace caller contents (IEEE 1800.2-2020 Section G.1.3.2)
:tags: uG uvm
:type: simulation
:lrm: 1800.2-2020 G.1.3.2 G.1.3.1 1800-2023 6.21
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
:args: +kr_plus=alpha +kr_second=beta -kr_dash=gamma
:expected_stdout: @test_command_vpi_plusargs_exclude_dash_arguments_and_replace_caller_contents.expected
*/
// What it checks:
// 1. get_plusargs includes supplied plus arguments.
// 2. get_plusargs excludes arguments without a plus prefix.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 G.1.3.2 (UVM-CMDLINE-PLUSARG-INCLUSION) gives rule 1 above.
//    Setup: Two selected plus arguments accompany a dash argument. Expected:
//    Each selected plus string occurs once.
// 2. 1800.2-2020 G.1.3.2 (UVM-CMDLINE-PLUSARG-EXCLUSION) gives rule 2 above.
//    Setup: A dash argument and a caller sentinel accompany actual plus
//    arguments. Expected: Neither the dash argument nor the sentinel remains;
//    every returned entry begins with plus.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe selected argument membership and exclusion. Simulator-owned plus
// arguments may also be returned, so the full queue length is not fixed.
module test_command_vpi_plusargs_exclude_dash_arguments_and_replace_caller_contents;
  import uvm_pkg::*;
  initial begin
    automatic uvm_cmdline_processor processor = uvm_cmdline_processor::get_inst();
    string args[$];
    int first_found, second_found, dash_found, stale_found;
    bit all_plus;
    first_found = 0; second_found = 0; dash_found = 0; stale_found = 0; all_plus = 1;
    args.push_back("stale"); processor.get_plusargs(args);
    foreach (args[i]) begin
      all_plus &= args[i].len() > 0 && args[i].substr(0, 0) == "+";
      if (args[i] == "+kr_plus=alpha") first_found++;
      if (args[i] == "+kr_second=beta") second_found++;
      if (args[i] == "-kr_dash=gamma") dash_found++;
      if (args[i] == "stale") stale_found++;
    end
    $display("UT: plus first %0d second %0d dash %0d stale %0d all_plus %0d",
             first_found, second_found, dash_found, stale_found, all_plus);
    $finish;
  end
endmodule
