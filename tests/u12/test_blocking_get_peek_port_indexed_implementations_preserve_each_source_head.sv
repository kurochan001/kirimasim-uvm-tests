/*
:name: test_blocking_get_peek_port_indexed_implementations_preserve_each_source_head
:description: indexed blocking get/peek calls preserve and consume only the selected source (IEEE 1800.2-2020 Section 12.2.5.1)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.5.1 12.2.7.1 5.5.2.12 5.5.2.13 5.5.2.14 5.5.2.15 5.5.2.16 12.2.4.2.2 12.2.4.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_blocking_get_peek_port_indexed_implementations_preserve_each_source_head.expected
*/
// What it checks:
// 1. Resolved port size counts the final implementation destinations.
// 2. get_if returns the resolved implementation port at a valid index.
// 3. A blocking get through an indexed implementation consumes that source
//    value.
// 4. A blocking peek through an indexed implementation observes its source
//    without consumption.
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
// 3. 1800.2-2020 12.2.4.2.2 (UVM-TLM1-INDEXED-BLOCKING-GET) gives rule 3
//    above. Setup: Use two sources with values 17 and 42 and retrieve each
//    through its resolved handle. Expected: Each get returns its selected head
//    and removes exactly one entry; both sources finally drain.
// 4. 1800.2-2020 12.2.4.2.3 (UVM-TLM1-INDEXED-BLOCKING-PEEK) gives rule 4
//    above. Setup: Peek twice before each selected get. Expected: Both peeks
//    return the same selected head without reducing total occupancy.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Access indexed implementations only after automatic binding resolution.
// Handle membership determines expectations; provider index order is
// unspecified.
module test_blocking_get_peek_port_indexed_implementations_preserve_each_source_head;
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
    uvm_blocking_get_peek_port#(int) tx;
    function new(string name, uvm_component parent);
      super.new(name, parent); tx = new("tx", this, 1, 2);
    endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    requester client; source first; source second;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      client = new("client", this); first = new("first", this); second = new("second", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      client.tx.connect(first.get_export); client.tx.connect(second.get_export);
    endfunction
    task run_phase(uvm_phase phase);
      bound_if_t selected;
      int value;
      int expected_value;
      int before_count;
      bit okay = 1;
      phase.raise_objection(this);

      first.values.push_back(17); second.values.push_back(42);
      $display("UT: resolved size %0d distinct %0d", client.tx.size(),
               client.tx.get_if(0) != client.tx.get_if(1));
      for (int i = 0; i < 2; i++) begin
        selected = client.tx.get_if(i);
        expected_value = selected == first.get_export ? 17 : 42;
        okay &= selected == first.get_export || selected == second.get_export;
        before_count = first.values.size() + second.values.size();
        selected.peek(value);
        okay &= value == expected_value &&
        first.values.size() + second.values.size() == before_count;
        selected.peek(value); okay &= value == expected_value;
        selected.get(value);
        okay &= value == expected_value &&
        first.values.size() + second.values.size() == before_count - 1;
      end
      $display("UT: selected_heads %0d both_drained %0d", okay,
               first.values.size() == 0 && second.values.size() == 0);

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #80; $fatal(1, "indexed TLM port watchdog expired"); end
endmodule
