/*
:name: test_hierarchical_put_port_resolves_parent_fanout_to_the_final_implementations
:description: a child port resolves a single parent connection to both final put implementations (IEEE 1800.2-2020 Section 12.2.5.1)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.5.1 12.2.7.1 5.5.2.12 5.5.2.13 5.5.2.14 5.5.2.15 5.5.2.16 12.2.4.2.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_hierarchical_put_port_resolves_parent_fanout_to_the_final_implementations.expected
*/
// Access indexed implementations only after automatic binding resolution.
// Handle membership determines expectations; provider index order is
// unspecified.
module test_hierarchical_put_port_resolves_parent_fanout_to_the_final_implementations;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  typedef uvm_tlm_if_base#(int, int) channel_if_t;
  typedef uvm_port_base#(channel_if_t) bound_if_t;
  class receiver extends uvm_component;
    uvm_blocking_put_imp#(int, receiver) put_export;
    int values[$];
    function new(string name, uvm_component parent);
      super.new(name, parent); put_export = new("put_export", this);
    endfunction
    task put(int value); #1; values.push_back(value); endtask
  endclass
  class source extends uvm_component;
    uvm_blocking_get_peek_imp#(int, source) get_export;
    int values[$];
    function new(string name, uvm_component parent);
      super.new(name, parent); get_export = new("get_export", this);
    endfunction
    task get(output int value); wait (values.size() > 0); #1; value = values.pop_front(); endtask
    task peek(output int value); wait (values.size() > 0); #1; value = values[0]; endtask
  endclass
  class requester extends uvm_component;
    uvm_blocking_put_port#(int) tx;
    function new(string name, uvm_component parent);
      super.new(name, parent); tx = new("tx", this, 1, 2);
    endfunction
  endclass
  class relay extends uvm_component;
    uvm_blocking_put_port#(int) tx;
    requester child;
    function new(string name, uvm_component parent);
      super.new(name, parent); tx = new("tx", this, 1, 2); child = new("child", this);
    endfunction
    function void connect_phase(uvm_phase phase); child.tx.connect(tx); endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    relay parent_port; receiver first; receiver second;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      parent_port = new("parent_port", this); first = new("first", this); second = new("second",
      this);
    endfunction
    function void connect_phase(uvm_phase phase);
      parent_port.tx.connect(first.put_export); parent_port.tx.connect(second.put_export);
    endfunction
    task run_phase(uvm_phase phase);
      bound_if_t selected;
      bit okay = 1;
      int first_index;
      phase.raise_objection(this);

      $display("UT: resolved child %0d parent %0d", parent_port.child.tx.size(),
      parent_port.tx.size());
      first_index = parent_port.child.tx.get_if(0) == first.put_export ? 0 : 1;
      for (int i = 0; i < 2; i++) begin
        selected = parent_port.child.tx.get_if(i);
        okay &= selected == first.put_export || selected == second.put_export;
        selected.put(20 + i);
      end
      okay &= first.values.size() == 1 && second.values.size() == 1 &&
              first.values[0] == 20 + first_index && second.values[0] == 21 - first_index;
      $display("UT: final_implementations %0d distinct %0d", okay,
               parent_port.child.tx.get_if(0) != parent_port.child.tx.get_if(1));

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #80; $fatal(1, "indexed TLM port watchdog expired"); end
endmodule
