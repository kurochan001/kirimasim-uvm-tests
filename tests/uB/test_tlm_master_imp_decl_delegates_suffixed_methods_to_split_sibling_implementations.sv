/*
:name: test_tlm_master_imp_decl_delegates_suffixed_methods_to_split_sibling_implementations
:description: generated master imps honor separate request and response implementation constructor arguments (IEEE 1800.2-2020 Section B.5.15)
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.5.15 12.2.7.2.2 12.2.3.2 12.2.5.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_master_imp_decl_delegates_suffixed_methods_to_split_sibling_implementations.expected
*/
// What it checks:
// The declaration macro supplies a suffix-specific implementation type for
// blocking and nonblocking master.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.5.15 (UVM-TLM-MASTER-IMP-DECL) gives the rule above. Setup:
// Instantiate two suffixes with independent handlers; master/slave use typed
// request/response directions, with an additional split-implementation master
// fixture. Expected: Recorded arguments, successful outputs and
// readiness/acceptance results where applicable belong to the selected suffix.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Bind two generated master imps to sibling request and response objects.
// The parent supplies no transfer methods. Both blocking and nonblocking
// operations must select the correct sibling and suffix.

module test_tlm_master_imp_decl_delegates_suffixed_methods_to_split_sibling_implementations;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `uvm_master_imp_decl(_left)
  `uvm_master_imp_decl(_right)
  class request_sink extends uvm_component;
    `uvm_component_utils(request_sink)
    int requests_left[$];
    int requests_right[$];
    int puts_left = 0;
    int puts_right = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction

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

  endclass
  class response_source extends uvm_component;
    `uvm_component_utils(response_source)
    string responses_left[$];
    string responses_right[$];
    int gets_left = 0;
    int gets_right = 0;
    int peeks_left = 0;
    int peeks_right = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction

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
  class endpoint extends uvm_component;
    `uvm_component_utils(endpoint)
    request_sink requests;
    response_source responses;
    uvm_master_imp_left#(int, string, endpoint, request_sink, response_source) left_imp;
    uvm_master_imp_right#(int, string, endpoint, request_sink, response_source) right_imp;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      requests = new("requests", this);
      responses = new("responses", this);
      left_imp = new("left_imp", this, requests, responses);
      right_imp = new("right_imp", this, requests, responses);
    endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    endpoint sink;
    uvm_master_port#(int, string) left;
    uvm_master_port#(int, string) right;
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
      sink.responses.responses_left = '{"L1", "L2"};
      sink.responses.responses_right = '{"R1", "R2"};
      left.put(11);
      right.put(21);
      left.peek(left_response_head);
      right.peek(right_response_head);
      left.get(left_response);
      right.get(right_response);
      $display("UT: first_heads %s %s first_responses %s %s", left_response_head,
               right_response_head, left_response, right_response);
      first_ok = left.try_put(12);
      second_ok = right.try_put(22);
      void'(sink.requests.requests_left.pop_front());
      void'(sink.requests.requests_right.pop_front());
      third_ok = left.try_put(12);
      fourth_ok = right.try_put(22);
      $display("UT: write_reuse %0d %0d", third_ok, fourth_ok);
      $display("UT: full %0d %0d get_ready %0d %0d peek_ready %0d %0d", !left.can_put(),
               !right.can_put(), left.can_get(), right.can_get(), left.can_peek(),
                   right.can_peek());
      third_ok = left.try_peek(left_response_head);
      fourth_ok = right.try_peek(right_response_head);
      fifth_ok = left.try_get(left_response);
      sixth_ok = right.try_get(right_response);
      $display("UT: rejected %0d %0d reads %0d %0d %0d %0d", !first_ok, !second_ok,
               third_ok, fourth_ok, fifth_ok, sixth_ok);
      $display("UT: requests %0d %0d heads %s %s responses %s %s", sink.requests.requests_left[0],
               sink.requests.requests_right[0], left_response_head, right_response_head,
                   left_response, right_response);
      $display("UT: puts %0d %0d gets %0d %0d peeks %0d %0d", sink.requests.puts_left,
          sink.requests.puts_right,
               sink.responses.gets_left, sink.responses.gets_right,
                   sink.responses.peeks_left, sink.responses.peeks_right);
      $display("UT: consumed_get %0d %0d consumed_peek %0d %0d", left.can_get(), right.can_get(),
               left.can_peek(), right.can_peek());
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
