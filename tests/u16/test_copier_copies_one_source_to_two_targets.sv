/*
:name: test_copier_copies_one_source_to_two_targets
:description: a copier visits distinct destinations for the same source (IEEE 1800.2-2020 Section 16.6.4.1)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.6.4.1 5.3.8.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_copier_copies_one_source_to_two_targets.expected
*/
// Copying the same source to two distinct destinations must invoke both
// copy operations. Changing one copied payload leaves the other unchanged.

module test_copier_copies_one_source_to_two_targets;
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
  automatic sample source = new("source");
  automatic sample first = new("first");
  automatic sample second = new("second");
  automatic uvm_copier copier = new;
  source.payload = 28;
  copier.copy_object(first, source);
  copier.copy_object(second, source);
  $display("UT: copied %0d %0d", first.payload, second.payload);
  first.payload = 99;
  $display("UT: independent %0d %0d", source.payload, second.payload);
  $finish;
end
endmodule
