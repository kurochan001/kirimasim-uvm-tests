/*
:name: test_tlm_analysis_imp_decl_preserves_object_handles_and_selected_input
:description: typed analysis declaration macro forwards original handles to the selected suffixed input (IEEE 1800.2-2020 Section B.5.22)
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.5.22 12.2.10.2 12.2.4.2.12 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_analysis_imp_decl_preserves_object_handles_and_selected_input.expected
*/
// What it checks:
// The analysis declaration macro provides separately named write inputs on one
// analysis component.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.5.22 (UVM-TLM-ANALYSIS-IMP-DECL) gives the rule above. Setup:
// Drive two suffixed inputs with integers or shared class handles. Expected:
// Each input records only its own calls and retains the supplied transaction
// handle identity.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Send distinct class transactions through two generated inputs and then
// reuse one handle on the other input. Observe identity without expecting
// cloning or mutation of the transaction.

module test_tlm_analysis_imp_decl_preserves_object_handles_and_selected_input;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `uvm_analysis_imp_decl(_left)
  `uvm_analysis_imp_decl(_right)
  class packet extends uvm_object;
    `uvm_object_utils(packet)
    int value = 0;
    function new(string name="packet"); super.new(name); endfunction
  endclass
  class endpoint extends uvm_component;
    `uvm_component_utils(endpoint)
    uvm_analysis_imp_left#(packet, endpoint) left_imp;
    uvm_analysis_imp_right#(packet, endpoint) right_imp;
    packet seen_left;
    packet seen_right;
    int calls_left = 0;
    int calls_right = 0;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      left_imp = new("left_imp", this);
      right_imp = new("right_imp", this);
    endfunction
    function void write_left(packet t); seen_left = t; calls_left++; endfunction
    function void write_right(packet t); seen_right = t; calls_right++; endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    endpoint sink;
    uvm_analysis_port#(packet) left;
    uvm_analysis_port#(packet) right;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sink = new("sink", this);
      left = new("left", this);
      right = new("right", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      left.connect(sink.left_imp);
      right.connect(sink.right_imp);
    endfunction
    task run_phase(uvm_phase phase);
      packet first = new("first");
      packet second = new("second");
      phase.raise_objection(this);
      first.value = 101;
      second.value = 202;
      left.write(first);
      right.write(second);
      $display("UT: same %0d %0d values %0d %0d", sink.seen_left == first,
               sink.seen_right == second, sink.seen_left.value, sink.seen_right.value);
      left.write(second);
      $display("UT: routed_again %0d other_kept %0d calls %0d %0d", sink.seen_left == second,
               sink.seen_right == second, sink.calls_left, sink.calls_right);
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
