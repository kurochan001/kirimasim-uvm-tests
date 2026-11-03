/*
:name: test_command_vpi_prefix_matches_replace_queues_and_clear_missing_queries
:description: command vpi prefix matches replace queues and clear missing queries (IEEE 1800.2-2020 Section G.1.3.4)
:tags: uG uvm
:type: simulation
:lrm: 1800.2-2020 G.1.3.4 G.1.2 1800-2023 6.21
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
:args: +kr_pick=alpha +kr_pick_more=beta +other_kr_pick=ignored
:expected_stdout: @test_command_vpi_prefix_matches_replace_queues_and_clear_missing_queries.expected
*/
// Literal beginning-of-argument matches only. Pinned regex DPI is linked,
// but these observations do not establish extended regex semantics.
module test_command_vpi_prefix_matches_replace_queues_and_clear_missing_queries;
  import uvm_pkg::*;
  initial begin
    automatic uvm_cmdline_processor processor = uvm_cmdline_processor::get_inst();
    string args[$];
    int count, alpha, beta, stale;
    args.push_back("stale"); count = processor.get_arg_matches("+kr_pick", args);
    alpha = 0; beta = 0; stale = 0;
    foreach (args[i]) begin
      if (args[i] == "+kr_pick=alpha") alpha++;
      if (args[i] == "+kr_pick_more=beta") beta++;
      if (args[i] == "stale") stale++;
    end
    $display("UT: prefix count %0d size %0d alpha %0d beta %0d stale %0d", count,
             args.size(), alpha, beta, stale);
    args.push_back("stale_again"); count = processor.get_arg_matches("+kr_absent", args);
    $display("UT: missing count %0d size %0d", count, args.size());
    count = processor.get_arg_matches("+kr_pick", args);
    $display("UT: repeated count %0d size %0d", count, args.size());
    $finish;
  end
endmodule
