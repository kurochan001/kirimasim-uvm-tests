/*
:name: test_clone_results_are_independent
:description: repeated clone operations return independent copies (IEEE 1800.2-2020 Section 5.3.5.2)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.5.2 5.3.8.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_clone_results_are_independent.expected
*/
// Clause 5.3.5.2 specifies the clone result, without requiring a particular
// sequence of creation and copy callbacks. Two clones must retain the copied
// payload independently when either the source or another clone is modified.

module test_clone_results_are_independent;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class sample extends uvm_object;
    `uvm_object_utils(sample)
    int payload;
    function new(string name="sample"); super.new(name); endfunction
    function void do_copy(uvm_object rhs);
      sample source;
      super.do_copy(rhs);
      if (!$cast(source, rhs)) $fatal(1, "unexpected copy type");
      payload = source.payload;
    endfunction
  endclass
  initial begin
    sample source = new("origin");
    sample first;
    sample second;
    uvm_object first_result;
    uvm_object second_result;
    source.payload = 63;
    first_result = source.clone();
    second_result = source.clone();
    if (!$cast(first, first_result) || !$cast(second, second_result))
      $fatal(1, "clone has the wrong type");
    $display("UT: distinct %0d %0d %0d", first != source, second != source, first != second);
    source.payload = 91;
    $display("UT: copies %0d %0d", first.payload, second.payload);
    first.payload = 12;
    $display("UT: independent %0d %0d %0d", source.payload, first.payload, second.payload);
    $finish;
  end
endmodule
