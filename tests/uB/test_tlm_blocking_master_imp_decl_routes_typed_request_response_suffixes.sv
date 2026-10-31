/*
:name: test_tlm_blocking_master_imp_decl_routes_typed_request_response_suffixes
:description: blocking_master declaration macro keeps typed requests and responses on their selected suffix (IEEE 1800.2-2020 Section B.5.13)
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.5.13 12.2.7.2.2 12.2.3.2 12.2.5.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_blocking_master_imp_decl_routes_typed_request_response_suffixes.expected
*/
// Use integer requests and string responses on two generated imp types
// owned by one component. Exercise the selected interface variants with
// independent lane state and no unsuffixed transfer implementation. Ignore
// failed-read outputs and preserve peek/get head relationships.

module test_tlm_blocking_master_imp_decl_routes_typed_request_response_suffixes;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `uvm_blocking_master_imp_decl(_left)
  `uvm_blocking_master_imp_decl(_right)
  class endpoint extends uvm_component;
    `uvm_component_utils(endpoint)
    uvm_blocking_master_imp_left#(int, string, endpoint) left_imp;
    uvm_blocking_master_imp_right#(int, string, endpoint) right_imp;
    int requests_left[$];
    int requests_right[$];
    string responses_left[$];
    string responses_right[$];
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
      wait (requests_left.size() < 1);
      #2;
      requests_left.push_back(t);
      puts_left++;
    endtask
    function bit try_put_left(int t);
      if (requests_left.size() >= 1) return 0;
      requests_left.push_back(t);
      puts_left++;
      return 1;
    endfunction
    function bit can_put_left(); return requests_left.size() < 1; endfunction

    task get_left(output string t);
      wait (responses_left.size() > 0);
      #2;
      t = responses_left.pop_front();
      gets_left++;
    endtask
    task peek_left(output string t);
      wait (responses_left.size() > 0);
      #2;
      t = responses_left[0];
      peeks_left++;
    endtask
    function bit try_get_left(output string t);
      if (responses_left.size() == 0) return 0;
      t = responses_left.pop_front();
      gets_left++;
      return 1;
    endfunction
    function bit try_peek_left(output string t);
      if (responses_left.size() == 0) return 0;
      t = responses_left[0];
      peeks_left++;
      return 1;
    endfunction
    function bit can_get_left(); return responses_left.size() > 0; endfunction
    function bit can_peek_left(); return responses_left.size() > 0; endfunction

    task put_right(int t);
      wait (requests_right.size() < 1);
      #2;
      requests_right.push_back(t);
      puts_right++;
    endtask
    function bit try_put_right(int t);
      if (requests_right.size() >= 1) return 0;
      requests_right.push_back(t);
      puts_right++;
      return 1;
    endfunction
    function bit can_put_right(); return requests_right.size() < 1; endfunction

    task get_right(output string t);
      wait (responses_right.size() > 0);
      #2;
      t = responses_right.pop_front();
      gets_right++;
    endtask
    task peek_right(output string t);
      wait (responses_right.size() > 0);
      #2;
      t = responses_right[0];
      peeks_right++;
    endtask
    function bit try_get_right(output string t);
      if (responses_right.size() == 0) return 0;
      t = responses_right.pop_front();
      gets_right++;
      return 1;
    endfunction
    function bit try_peek_right(output string t);
      if (responses_right.size() == 0) return 0;
      t = responses_right[0];
      peeks_right++;
      return 1;
    endfunction
    function bit can_get_right(); return responses_right.size() > 0; endfunction
    function bit can_peek_right(); return responses_right.size() > 0; endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    endpoint sink;
    uvm_blocking_master_port#(int, string) left;
    uvm_blocking_master_port#(int, string) right;
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
      sink.responses_left.push_back("L1");
      sink.responses_right.push_back("R1");
      left.put(11);
      right.put(21);
      left.peek(left_response_head);
      right.peek(right_response_head);
      left.get(left_response);
      right.get(right_response);
      $display("UT: requests %0d %0d heads %s %s responses %s %s", sink.requests_left[0],
               sink.requests_right[0], left_response_head, right_response_head,
                   left_response, right_response);
      $display("UT: puts %0d %0d gets %0d %0d peeks %0d %0d", sink.puts_left, sink.puts_right,
               sink.gets_left, sink.gets_right, sink.peeks_left, sink.peeks_right);
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
