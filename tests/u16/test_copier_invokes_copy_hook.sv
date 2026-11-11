/*
:name: test_copier_invokes_copy_hook
:description: the copier dispatches to the destination copy hook (IEEE 1800.2-2020 Section 16.6.4.1)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.6.4.1 5.3.8.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_copier_invokes_copy_hook.expected
*/
// What it checks:
// Copier object copying invokes the destination copy hook for the selected
// pair.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.6.4.1 (UVM-COPIER-COPY-HOOK) gives the rule above. Setup:
// Copy scalar data from one source into one or two distinct targets. Expected:
// Each destination receives the payload independently and the source remains
// unchanged.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A copier transfers a user payload through do_copy. The source stays
// unchanged; the destination retains the name chosen at construction.

module test_copier_invokes_copy_hook;
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
  automatic sample target = new("target");
  automatic uvm_copier copier = new;
  source.payload = 61;
  target.payload = -1;
  copier.copy_object(target, source);
  $display("UT: target %0d name %s", target.payload, target.get_name());
  target.payload = 5;
  $display("UT: source %0d", source.payload);
  $finish;
end
endmodule
