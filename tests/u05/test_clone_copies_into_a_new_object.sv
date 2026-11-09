/*
:name: test_clone_copies_into_a_new_object
:description: clone returns a separate object with the copied payload (IEEE 1800.2-2020 Section 5.3.5.2)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.5.2 5.3.8.1 5.3.8.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_clone_copies_into_a_new_object.expected
*/
// What it checks:
// A successful clone creates a separate object with copied state.
//
// How the expected output follows from the standard:
// 1800.2-2020 5.3.5.2 (UVM-CLONE-DISTINCT) gives the rule above. Setup: A
// registered object with a working create/copy implementation and scalar value
// 37. Expected: The clone is a distinct handle and initially holds 37.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A clone returns a separate object containing the source payload.
// Observe its type, payload and distinct handle without assuming an ID.

module test_clone_copies_into_a_new_object;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

class sample extends uvm_object;
  `uvm_object_utils(sample)
  int payload;
  function new(string name="sample");
    super.new(name);
  endfunction
  function void do_copy(uvm_object rhs);
    sample source;
    super.do_copy(rhs);
    if (!$cast(source, rhs)) $fatal(1, "unexpected copy type");
    payload = source.payload;
  endfunction
endclass

initial begin
  automatic sample source = new("origin");
  sample duplicate;
  uvm_object result;
  source.payload = 37;
  result = source.clone();
  if (!$cast(duplicate, result)) $fatal(1, "clone has the wrong type");
  $display("UT: clone distinct %0d value %0d", duplicate != source, duplicate.payload);
  duplicate.payload = 90;
  $display("UT: source unchanged %0d", source.payload);
  $finish;
end
endmodule
