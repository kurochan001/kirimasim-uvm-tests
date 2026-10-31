/*
:name: test_tlm_blocking_peek_imp_decl_routes_two_suffixes
:description: blocking_peek declaration macro routes each public operation to its matching suffix (IEEE 1800.2-2020 Section B.5.7)
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.5.7 12.2.7.1 12.2.5.1 12.2.4.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_blocking_peek_imp_decl_routes_two_suffixes.expected
*/
// Observe the same queued value twice on each suffix. The blocking peek
// handlers delay before returning and never consume their lane contents.
// Declare two suffixed imp classes on one component, which has no unsuffixed
// transfer methods. Blocking handlers include a positive delay. Failed-read
// output values are not inspected.

module test_tlm_blocking_peek_imp_decl_routes_two_suffixes;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `uvm_blocking_peek_imp_decl(_left)
  `uvm_blocking_peek_imp_decl(_right)
  class endpoint extends uvm_component;
    `uvm_component_utils(endpoint)
    uvm_blocking_peek_imp_left#(int, endpoint) left_imp;
    uvm_blocking_peek_imp_right#(int, endpoint) right_imp;
    int left_values[$];
    int right_values[$];
    int puts_left = 0;
    int puts_right = 0;
    int gets_left = 0;
    int gets_right = 0;
    int peeks_left = 0;
    int peeks_right = 0;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      left_imp = new("left_imp", this);
      right_imp = new("right_imp", this);
    endfunction

    task put_left(int t);
      wait (left_values.size() < 1);
      #2;
      left_values.push_back(t);
      puts_left++;
    endtask
    function bit try_put_left(int t);
      if (left_values.size() >= 1) return 0;
      left_values.push_back(t);
      puts_left++;
      return 1;
    endfunction
    function bit can_put_left(); return left_values.size() < 1; endfunction
    task get_left(output int t);
      wait (left_values.size() > 0);
      #2;
      t = left_values.pop_front();
      gets_left++;
    endtask
    function bit try_get_left(output int t);
      if (left_values.size() == 0) return 0;
      t = left_values.pop_front();
      gets_left++;
      return 1;
    endfunction
    function bit can_get_left(); return left_values.size() > 0; endfunction
    task peek_left(output int t);
      wait (left_values.size() > 0);
      #2;
      t = left_values[0];
      peeks_left++;
    endtask
    function bit try_peek_left(output int t);
      if (left_values.size() == 0) return 0;
      t = left_values[0];
      peeks_left++;
      return 1;
    endfunction
    function bit can_peek_left(); return left_values.size() > 0; endfunction

    task put_right(int t);
      wait (right_values.size() < 1);
      #2;
      right_values.push_back(t);
      puts_right++;
    endtask
    function bit try_put_right(int t);
      if (right_values.size() >= 1) return 0;
      right_values.push_back(t);
      puts_right++;
      return 1;
    endfunction
    function bit can_put_right(); return right_values.size() < 1; endfunction
    task get_right(output int t);
      wait (right_values.size() > 0);
      #2;
      t = right_values.pop_front();
      gets_right++;
    endtask
    function bit try_get_right(output int t);
      if (right_values.size() == 0) return 0;
      t = right_values.pop_front();
      gets_right++;
      return 1;
    endfunction
    function bit can_get_right(); return right_values.size() > 0; endfunction
    task peek_right(output int t);
      wait (right_values.size() > 0);
      #2;
      t = right_values[0];
      peeks_right++;
    endtask
    function bit try_peek_right(output int t);
      if (right_values.size() == 0) return 0;
      t = right_values[0];
      peeks_right++;
      return 1;
    endfunction
    function bit can_peek_right(); return right_values.size() > 0; endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    endpoint sink;
    uvm_blocking_peek_port#(int) left;
    uvm_blocking_peek_port#(int) right;
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
      int left_first;
      int right_first;
      int left_second;
      int right_second;
      int left_head;
      int right_head;
      string left_response;
      string right_response;
      string left_response_head;
      string right_response_head;
      bit first_ok;
      bit second_ok;
      bit third_ok;
      bit fourth_ok;
      bit fifth_ok;
      bit sixth_ok;
      phase.raise_objection(this);
      sink.left_values.push_back(11);
      sink.right_values.push_back(21);
      left.peek(left_first);
      right.peek(right_first);
      left.peek(left_second);
      right.peek(right_second);
      $display("UT: values %0d %0d %0d %0d peeks %0d %0d retained %0d %0d", left_first,
               right_first, left_second, right_second, sink.peeks_left, sink.peeks_right,
               sink.left_values.size(), sink.right_values.size());
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
