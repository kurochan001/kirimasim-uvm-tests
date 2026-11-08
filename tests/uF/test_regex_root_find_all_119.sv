/*
:name: test_regex_root_find_all_119
:description: component lookup by regular expression and by the simplified plus returns exactly the matching components (IEEE 1800.2-2020 Section F.7.4.1)
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.7.4.1 F.3.3.1 F.7.2.2 13.1.3.2 1800-2023 6.21
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
:expected_stdout: @test_regex_root_find_all_119.expected
*/
// Four children ag1, ag2, ag3 and other sit under one component. A regular
// expression with a character class must find ag1 and ag3, the simplified
// expression ending in plus must find the three ag children, and find with a
// regular expression must return other. The pinned regex DPI and the original
// command-line VPI bridge are enabled; the ordinary UVM_NO_DPI condition cannot
// evaluate regular expressions, so this case runs only in the command-line
// condition. Only the lines that begin with "UT: " are compared.
module test_regex_root_find_all_119;
  import uvm_pkg::*;
  class node119 extends uvm_component;
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass

  function automatic int count119(uvm_component found[$], uvm_component value);
    automatic int result = 0;
    foreach (found[i]) if (found[i] == value) result++;
    return result;
  endfunction

  initial begin
    automatic uvm_root root = uvm_root::get();
    automatic node119 env = new("env119", null);
    automatic node119 ag1 = new("ag1", env);
    automatic node119 ag2 = new("ag2", env);
    automatic node119 ag3 = new("ag3", env);
    automatic node119 other = new("other", env);
    uvm_component found[$];
    root.find_all("/^env119\\.ag[13]$/", found);
    $display("UT: regex size %0d ag1 %0d ag3 %0d", found.size(), count119(found, ag1),
             count119(found, ag3));
    found.delete();
    root.find_all("env119.ag+", found);
    $display("UT: plus size %0d ag1 %0d ag2 %0d ag3 %0d", found.size(), count119(found, ag1),
             count119(found, ag2), count119(found, ag3));
    $display("UT: find other %0d", root.find("/^env119\\.oth.*$/") == other);
    $finish;
  end
endmodule
