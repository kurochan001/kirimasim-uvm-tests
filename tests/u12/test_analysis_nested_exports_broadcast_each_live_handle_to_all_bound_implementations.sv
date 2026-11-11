/*
:name: test_analysis_nested_exports_broadcast_each_live_handle_to_all_bound_implementations
:description: analysis nested exports broadcast each live handle to all bound implementations (IEEE 1800.2-2020 Section 12.2.10.2)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.10.2 12.2.10.3 12.2.10.1.4 12.2.10.2.2 5.5.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_analysis_nested_exports_broadcast_each_live_handle_to_all_bound_implementations.expected
*/
// What it checks:
// Analysis exports forward writes through a selected export hierarchy to all
// bound imp subscribers.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.2.10.3 (UVM-TLM-DECL-ANALYSIS-NESTED-FANOUT) gives the rule
// above. Setup: Bind a real writer through two actual exports to two read-only
// imps; write the same object before and after mutation. Expected: Each
// subscriber receives thirteen then twenty-seven without time advance,
// retaining the same live handle.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use two actual exports and two read-only implementation endpoints.
// Each subscriber preserves its own write order and the live object identity.
// No relative subscriber callback order or modifying subscriber is assumed.
module test_analysis_nested_exports_broadcast_each_live_handle_to_all_bound_implementations;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class item extends uvm_object;
    int value = 13;
    function new(); super.new("item"); endfunction
  endclass
  class receiver extends uvm_component;
    uvm_analysis_imp#(item,receiver) sink;
    item handles[$];
    int values[$];
    function new(string name,uvm_component parent);
      super.new(name,parent); sink = new("sink",this);
    endfunction
    function void write(item value);
      handles.push_back(value); values.push_back(value.value);
    endfunction
  endclass
  class inner_hub extends uvm_component;
    uvm_analysis_export#(item) inner;
    receiver left,right;
    function new(string name,uvm_component parent);
      super.new(name,parent); inner = new("inner",this);
      left = new("left",this); right = new("right",this);
    endfunction
    function void connect_phase(uvm_phase phase);
      inner.connect(left.sink); inner.connect(right.sink);
    endfunction
  endclass
  class hub extends uvm_component;
    uvm_analysis_export#(item) outer;
    inner_hub child;
    function new(string name,uvm_component parent);
      super.new(name,parent); outer = new("outer",this); child = new("child",this);
    endfunction
    function void connect_phase(uvm_phase phase); outer.connect(child.inner); endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_analysis_port#(item) writer,unrelated;
    hub target;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      writer = new("writer",this); unrelated = new("unrelated",this);
      target = new("target",this);
    endfunction
    function void connect_phase(uvm_phase phase); writer.connect(target.outer); endfunction
    task run_phase(uvm_phase phase);
      item value = new();
      time before_time;
      phase.raise_objection(this); before_time = $time;
      writer.write(value); value.value = 27; writer.write(value); unrelated.write(value);
      $display("UT: nested_analysis counts %0d/%0d values %0d/%0d/%0d/%0d immediate %0d",
               target.child.left.values.size(),target.child.right.values.size(),
               target.child.left.values[0],target.child.left.values[1],target.child.right.values[0],
               target.child.right.values[1],$time == before_time);
      $display("UT: nested_analysis_handles all_same %0d source %0d live %0d/%0d",
               target.child.left.handles[0] == value && target.child.left.handles[1] == value &&
               target.child.right.handles[0] == value && target.child.right.handles[1] == value,
               value.value,target.child.left.handles[0].value,
               target.child.right.handles[0].value);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #60; $fatal(1,"analysis watchdog expired"); end
endmodule
