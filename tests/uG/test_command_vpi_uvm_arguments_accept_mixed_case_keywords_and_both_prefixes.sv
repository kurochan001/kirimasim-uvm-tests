/*
:name: test_command_vpi_uvm_arguments_accept_mixed_case_keywords_and_both_prefixes
:description: command vpi uvm arguments accept mixed case keywords and both prefixes (IEEE 1800.2-2020 Section G.1.3.3)
:tags: uG uvm
:type: simulation
:lrm: 1800.2-2020 G.1.3.3 G.1.3.1 1800-2023 6.21
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
:args: +uVm_marker=one -UvM_marker=two +UVMXmarker=three +kr_UVM=other
:expected_stdout: @test_command_vpi_uvm_arguments_accept_mixed_case_keywords_and_both_prefixes.expected
*/
// What it checks:
// 1. UVM argument classification ignores the case of the first three keyword
//    letters.
// 2. The UVM keyword is recognized in the first three letters after plus or
//    minus.
// 3. get_uvm_args replaces the caller output with only the classified
//    invocation arguments.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 G.1.3.3 (UVM-CMDLINE-UVM-CASE-INSENSITIVE-PREFIX) gives rule
//    1 above. Setup: Plus and dash arguments use mixed-case UVM spellings.
//    Expected: Both supplied mixed-case forms are returned.
// 2. 1800.2-2020 G.1.3.3 (UVM-CMDLINE-UVM-FIRST-THREE-LETTERS) gives rule 2
//    above. Setup: One argument extends UVM with another letter; another
//    contains UVM later in its name. Expected: The UVM-leading extended form
//    is included and the later-occurrence form is excluded.
// 3. 1800.2-2020 G.1.3.3 (UVM-CMDLINE-UVM-QUEUE-REPLACEMENT) gives rule 3
//    above. Setup: The caller adds a sentinel before the three selected UVM
//    arguments are retrieved. Expected: Exactly those three entries remain
//    without the sentinel.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The first three letters following plus/minus define UVM classification,
// case independently. The fixture does not set any built-in UVM option.
module test_command_vpi_uvm_arguments_accept_mixed_case_keywords_and_both_prefixes;
  import uvm_pkg::*;
  initial begin
    automatic uvm_cmdline_processor processor = uvm_cmdline_processor::get_inst();
    string args[$];
    int one, two, three, other, stale;
    one = 0; two = 0; three = 0; other = 0; stale = 0;
    args.push_back("stale"); processor.get_uvm_args(args);
    foreach (args[i]) begin
      if (args[i] == "+uVm_marker=one") one++;
      if (args[i] == "-UvM_marker=two") two++;
      if (args[i] == "+UVMXmarker=three") three++;
      if (args[i] == "+kr_UVM=other") other++;
      if (args[i] == "stale") stale++;
    end
    $display("UT: uvm count %0d plus %0d dash %0d extended %0d other %0d stale %0d",
             args.size(), one, two, three, other, stale);
    $finish;
  end
endmodule
