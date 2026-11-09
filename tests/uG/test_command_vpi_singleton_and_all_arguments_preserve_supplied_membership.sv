/*
:name: test_command_vpi_singleton_and_all_arguments_preserve_supplied_membership
:description: command vpi singleton and all arguments preserve supplied membership (IEEE 1800.2-2020 Section G.1.3.1)
:tags: uG uvm
:type: simulation
:lrm: 1800.2-2020 G.1.3.1 G.1.2 1800-2023 6.21
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
:args: +kr_all=alpha -kr_dash=beta
:expected_stdout: @test_command_vpi_singleton_and_all_arguments_preserve_supplied_membership.expected
*/
// What it checks:
// 1. get_inst returns the same singleton command-line processor.
// 2. get_args returns the supplied plus and dash arguments.
// 3. get_args populates the output queue without retaining caller entries.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 G.1.2 (UVM-CMDLINE-SINGLETON-IDENTITY) gives rule 1 above.
//    Setup: Repeated calls surround other processor construction and queue
//    queries. Expected: Repeated singleton handles identify the original
//    nonnull instance.
// 2. 1800.2-2020 G.1.3.1 (UVM-CMDLINE-ALL-ARGUMENT-MEMBERSHIP) gives rule 2
//    above. Setup: The actual invocation supplies one selected argument of
//    each kind. Expected: Both selected strings occur once in the returned
//    queue.
// 3. 1800.2-2020 G.1.3.1 (UVM-CMDLINE-ALL-ARGUMENT-QUEUE-REPLACEMENT) gives
//    rule 3 above. Setup: The caller prepopulates its output queue with a
//    sentinel. Expected: The sentinel is absent after retrieval.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use actual process arguments through the explicit VPI bridge. Executable
// identity is limited to nonempty element zero; no path, global argv count or
// private tool information is printed.
module test_command_vpi_singleton_and_all_arguments_preserve_supplied_membership;
  import uvm_pkg::*;
  initial begin
    automatic uvm_cmdline_processor processor = uvm_cmdline_processor::get_inst();
    automatic uvm_cmdline_processor same = uvm_cmdline_processor::get_inst();
    string args[$];
    int plus_found, dash_found, stale_found;
    bit executable_present;
    plus_found = 0; dash_found = 0; stale_found = 0; executable_present = 0;
    args.push_back("stale"); processor.get_args(args);
    if (args.size() > 0) executable_present = args[0].len() > 0;
    foreach (args[i]) begin
      if (args[i] == "+kr_all=alpha") plus_found++;
      if (args[i] == "-kr_dash=beta") dash_found++;
      if (args[i] == "stale") stale_found++;
    end
    $display("UT: singleton nonnull %0d same %0d", processor != null, same == processor);
    $display("UT: all executable %0d plus %0d dash %0d stale %0d", executable_present,
             plus_found, dash_found, stale_found);
    $finish;
  end
endmodule
