/*
:name: test_port_binding_resolution_returns_distinct_implementation_handles_after_elaboration
:description: resolved bindings expose exact implementations after elaboration without prescribing index order (5.5.2.15)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.5.2.15 5.5.2.12 5.5.2.16 12.2.6.1 12.2.7.1 9.3.1.1.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_port_binding_resolution_returns_distinct_implementation_handles_after_elaboration.expected
*/
module test_port_binding_resolution_returns_distinct_implementation_handles_after_elaboration;
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
      bit complete;
      first = bridge.get_if(0);
      second = bridge.get_if(1);
      complete = (first == left.imp && second == right.imp) ||
                 (first == right.imp && second == left.imp);
      $display("UT: resolved size %0d exact_membership %0d distinct %0d default_zero %0d",
               bridge.size(), complete, first != second, bridge.get_if() == first);
    endtask
  endclass
  initial run_test("t");
endmodule
