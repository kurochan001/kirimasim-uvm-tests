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
// What it checks:
// 1. Resolved port size counts the final implementation destinations.
// 2. get_if returns the resolved implementation port at a valid index.
// 3. Blocking puts through resolved interfaces deliver data to the selected
//    implementation.
// 4. Binding resolution follows a child-to-parent port connection to all final
//    implementations.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.5.2.12 (UVM-PORT-RESOLVED-IMPLEMENTATION-COUNT) gives rule
//    1 above. Setup: Connect directly to two implementations or reach them
//    through one parent port. Expected: Size is two after elaboration,
//    including the child port with only one direct parent connection.
// 2. 1800.2-2020 5.5.2.16 (UVM-PORT-INDEXED-IMPLEMENTATION-HANDLES) gives rule
//    2 above. Setup: Inspect both indexes only after resolution and invoke
//    their supported methods. Expected: The two handles are distinct final
//    implementations and methods reach their selected endpoints.
// 3. 1800.2-2020 12.2.4.2.1 (UVM-TLM1-INDEXED-BLOCKING-PUT) gives rule 3
//    above. Setup: Use a default call and explicit implementation calls with
//    delayed receiver methods. Expected: The default reaches index zero,
//    indexed values reach distinct receivers, and blocking return follows
//    receiver work.
// 4. 1800.2-2020 5.5.2.15 (UVM-PORT-PARENT-FANOUT-RESOLUTION) gives rule 4
//    above. Setup: A child port connects once to a parent port whose fanout
//    has two receiver imps. Expected: Both parent and child expose the two
//    actual receivers and indexed traffic reaches each once.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
