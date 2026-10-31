/*
:name: test_object_copy_uses_explicit_policy_each_time
:description: successive object copies dispatch through the supplied policy (IEEE 1800.2-2020 Section 5.3.8.1)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.8.1 5.3.8.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_copy_uses_explicit_policy_each_time.expected
*/
// The copy entry point calls the supplied copier for each operation. A
// second copy of the same pair observes an updated source payload.

module test_object_copy_uses_explicit_policy_each_time;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class datum extends uvm_object;
    `uvm_object_utils(datum)
    int value = 0;
    function new(string name="datum"); super.new(name); endfunction
    function void do_copy(uvm_object rhs);
      datum source;
      super.do_copy(rhs);
      if (!$cast(source, rhs)) $fatal(1, "unexpected copy type");
      value = source.value;
    endfunction
  endclass
  class counting_copier extends uvm_copier;
    `uvm_object_utils(counting_copier)
    int calls = 0;
    function new(string name="counting_copier"); super.new(name); endfunction
    function void copy_object(uvm_object lhs, uvm_object rhs);
      calls++;
      super.copy_object(lhs, rhs);
    endfunction
  endclass

  initial begin
    datum source = new("source");
    datum target = new("target");
    counting_copier copier = new;
    source.value = 16;
    target.copy(source, copier);
    $display("UT: first %0d calls %0d", target.value, copier.calls);
    source.value = 48;
    target.copy(source, copier);
    $display("UT: second %0d calls %0d", target.value, copier.calls);
    $finish;
  end
endmodule
