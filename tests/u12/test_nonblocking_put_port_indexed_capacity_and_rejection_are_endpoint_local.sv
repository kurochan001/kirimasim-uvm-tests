/*
:name: test_nonblocking_put_port_indexed_capacity_and_rejection_are_endpoint_local
:description: indexed nonblocking put capacity and rejected writes stay local to the chosen endpoint (IEEE 1800.2-2020 Section 12.2.5.1)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.5.1 12.2.7.1 5.5.2.12 5.5.2.13 5.5.2.14 5.5.2.15 5.5.2.16 12.2.4.2.4 12.2.4.2.5 12.2.4.2.6 12.2.8.2.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_nonblocking_put_port_indexed_capacity_and_rejection_are_endpoint_local.expected
*/
// What it checks:
// 1. Resolved port size counts the final implementation destinations.
// 2. get_if returns the resolved implementation port at a valid index.
// 3. Indexed can_put reflects the selected implementation capacity
//    independently.
// 4. A full indexed FIFO implementation rejects a nonblocking put without
//    overwriting its queued value.
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
// 3. 1800.2-2020 12.2.4.2.5 (UVM-TLM1-INDEXED-PUT-CAPACITY) gives rule 3
//    above. Setup: Use two one-entry FIFO implementations and fill each
//    separately. Expected: Each is initially available and becomes unavailable
//    only after its own accepted put.
// 4. 1800.2-2020 12.2.4.2.4 (UVM-TLM1-INDEXED-PUT-REJECTION) gives rule 4
//    above. Setup: Accept one distinct value per endpoint then attempt value
//    99 while full. Expected: Rejected attempts return zero and later gets
//    return the original selected values.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Access indexed implementations only after automatic binding resolution.
// Handle membership determines expectations; provider index order is
// unspecified.
module test_nonblocking_put_port_indexed_capacity_and_rejection_are_endpoint_local;
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
    uvm_nonblocking_put_port#(int) tx;
    function new(string name, uvm_component parent);
      super.new(name, parent); tx = new("tx", this, 1, 2);
    endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    requester client; uvm_tlm_fifo#(int) first; uvm_tlm_fifo#(int) second;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      client = new("client", this); first = new("first", this, 1); second = new("second", this, 1);
    endfunction
    function void connect_phase(uvm_phase phase);
      client.tx.connect(first.put_export); client.tx.connect(second.put_export);
    endfunction
    task run_phase(uvm_phase phase);
      bound_if_t selected;
      int first_index;
      int value;
      bit okay = 1;
      bit accepted;
      phase.raise_objection(this);

      first_index = client.tx.get_if(0) == first.put_export ? 0 : 1;
      $display("UT: resolved size %0d distinct %0d", client.tx.size(),
               client.tx.get_if(0) != client.tx.get_if(1));
      for (int i = 0; i < 2; i++) begin
        selected = client.tx.get_if(i);
        okay &= selected == first.put_export || selected == second.put_export;
        okay &= selected.can_put(); accepted = selected.try_put(10 + i); okay &= accepted;
        okay &= !selected.can_put(); accepted = selected.try_put(99); okay &= !accepted;
      end
      $display("UT: independent_capacity %0d both_full %0d", okay, first.is_full() &&
      second.is_full());
      accepted = first.try_get(value); okay &= accepted && value == 10 + first_index;
      accepted = second.try_get(value); okay &= accepted && value == 11 - first_index;
      $display("UT: original_values %0d both_empty %0d", okay, first.is_empty() &&
      second.is_empty());

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #80; $fatal(1, "indexed TLM port watchdog expired"); end
endmodule
