/*
:name: test_object_compare_honors_hook_return
:description: the compare result honors a user hook failure without field miscompares (IEEE 1800.2-2020 Section 5.3.9.1)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.9.1 5.3.9.2 16.3.3.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_compare_honors_hook_return.expected
*/
// A do_compare hook can reject a comparison independently of the policy
// miscompare counter. Its return value must participate in the final result.

module test_object_compare_honors_hook_return;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class decision extends uvm_object;
    `uvm_object_utils(decision)
    bit accept = 0;
    function new(string name="decision"); super.new(name); endfunction
    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      return accept;
    endfunction
  endclass
  initial begin
    automatic decision lhs = new;
    automatic decision rhs = new;
    automatic uvm_comparer comparer = new;
    bit same;
    same = lhs.compare(rhs, comparer);
    $display("UT: rejected %0d miscompares %0d", same, comparer.get_result());
    lhs.accept = 1;
    same = lhs.compare(rhs, comparer);
    $display("UT: accepted %0d miscompares %0d", same, comparer.get_result());
    $finish;
  end
endmodule
