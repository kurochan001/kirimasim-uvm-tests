/*
:name: test_blocking_put_port_indexed_implementations_route_to_distinct_receivers
:description: blocking put routes its default and indexed calls through the resolved implementation handles (IEEE 1800.2-2020 Section 12.2.5.1)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.5.1 12.2.7.1 5.5.2.12 5.5.2.13 5.5.2.14 5.5.2.15 5.5.2.16 12.2.4.2.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_blocking_put_port_indexed_implementations_route_to_distinct_receivers.expected
*/
// Access indexed implementations only after automatic binding resolution.
// Handle membership determines expectations; provider index order is
// unspecified.
module test_blocking_put_port_indexed_implementations_route_to_distinct_receivers;
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
    requester client; receiver first; receiver second;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      client = new("client", this); first = new("first", this); second = new("second", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      client.tx.connect(first.put_export); client.tx.connect(second.put_export);
    endfunction
    task run_phase(uvm_phase phase);
      bound_if_t first_if;
      bound_if_t second_if;
      int first_index;
      bit default_ok;
      bit indexed_ok;
      time before_call;
      phase.raise_objection(this);

      first_if = client.tx.get_if(0); second_if = client.tx.get_if(1);
      first_index = first_if == first.put_export ? 0 : 1;
      $display("UT: resolved size %0d members %0d distinct %0d", client.tx.size(),
               (first_if == first.put_export || first_if == second.put_export) &&
               (second_if == first.put_export || second_if == second.put_export),
               first_if != second_if);
      before_call = $time; client.tx.put(77);
      if (first_index == 0) default_ok = first.values.size() == 1 &&
          first.values[0] == 77 && second.values.size() == 0;
      else default_ok = second.values.size() == 1 && second.values[0] == 77 &&
          first.values.size() == 0;
      $display("UT: default first_index %0d blocking_return %0d", default_ok, $time > before_call);
      first_if.put(100); second_if.put(101);
      indexed_ok = first.values.size() == (first_index == 0 ? 2 : 1) &&
                   second.values.size() == (first_index == 0 ? 1 : 2) &&
                   first.values[$] == 100 + first_index &&
                   second.values[$] == 101 - first_index;
      $display("UT: indexed routed %0d total_calls %0d", indexed_ok,
               first.values.size() + second.values.size());

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #80; $fatal(1, "indexed TLM port watchdog expired"); end
endmodule
