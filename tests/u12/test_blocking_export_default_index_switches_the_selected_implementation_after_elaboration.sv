/*
:name: test_blocking_export_default_index_switches_the_selected_implementation_after_elaboration
:description: an export default index selects the called implementation and can be changed after elaboration (12.2.6.1)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.6.1 5.5.2.13 5.5.2.12 5.5.2.16 5.5.2.15 12.2.7.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_blocking_export_default_index_switches_the_selected_implementation_after_elaboration.expected
*/
// What it checks:
// 1. A typed blocking export forwards an interface call to its resolved
//    implementation.
// 2. An export without explicit selection uses implementation index zero.
// 3. Changing an export default index after elaboration changes the invoked
//    implementation.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.2.6.1 (UVM-TLM1-EXPORT-TYPED-IMPLEMENTATION-FORWARDING)
//    gives rule 1 above. Setup: Resolve one export to two distinct int sinks,
//    identify indices by handles, then call default, index one and index zero.
//    Expected: One completed call delivers value eleven to exactly the
//    implementation at index zero.
// 2. 1800.2-2020 5.5.2.13 (UVM-PORT-EXPORT-DEFAULT-INDEX-ZERO) gives rule 2
//    above. Setup: Resolve one export to two distinct int sinks, identify
//    indices by handles, then call default, index one and index zero.
//    Expected: The first call is delivered exactly once to the handle obtained
//    at index zero.
// 3. 1800.2-2020 5.5.2.13 (UVM-PORT-EXPORT-DEFAULT-INDEX-RESELECTION) gives
//    rule 3 above. Setup: Resolve one export to two distinct int sinks,
//    identify indices by handles, then call default, index one and index zero.
//    Expected: Index one receives twenty-two once, then index zero receives
//    thirty-three on reuse; total calls reach three.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_blocking_export_default_index_switches_the_selected_implementation_after_elaboration;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class sink extends uvm_component;
    uvm_blocking_put_imp#(int, sink) imp;
    int calls = 0;
    int last = 0;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      imp = new("imp", this);
    endfunction
    task put(int value); #1; calls++; last = value; endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    sink left, right;
    uvm_blocking_put_export#(int) bridge;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      left = new("left", this);
      right = new("right", this);
      bridge = new("bridge", this, 1, 2);
    endfunction
    function void connect_phase(uvm_phase phase);
      bridge.connect(left.imp);
      bridge.connect(right.imp);
    endfunction
    task run_phase(uvm_phase phase);
      uvm_port_base#(uvm_tlm_if_base#(int, int)) first, second;
      bit first_selected, second_selected, reused;
      phase.raise_objection(this);
      first = bridge.get_if(0);
      second = bridge.get_if(1);
      bridge.put(11);
      first_selected = (first == left.imp && left.calls == 1 && left.last == 11) ||
                       (first == right.imp && right.calls == 1 && right.last == 11);
      $display("UT: default_zero selected %0d total %0d", first_selected, left.calls + right.calls);
      bridge.set_default_index(1);
      bridge.put(22);
      second_selected = (second == left.imp && left.calls == 1 && left.last == 22) ||
                        (second == right.imp && right.calls == 1 && right.last == 22);
      $display("UT: selected_one changed %0d total %0d", second_selected, left.calls + right.calls);
      bridge.set_default_index(0);
      bridge.put(33);
      reused = (first == left.imp && left.calls == 2 && left.last == 33) ||
               (first == right.imp && right.calls == 2 && right.last == 33);
      $display("UT: selected_zero reused %0d total %0d", reused, left.calls + right.calls);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
endmodule
