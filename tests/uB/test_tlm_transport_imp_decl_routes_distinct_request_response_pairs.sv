/*
:name: test_tlm_transport_imp_decl_routes_distinct_request_response_pairs
:description: transport declaration macro forwards each request response pair to the selected suffix (IEEE 1800.2-2020 Section B.5.21)
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.5.21 12.2.7.2.1 12.2.5.2 12.2.4.2.10 12.2.4.2.11 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_transport_imp_decl_routes_distinct_request_response_pairs.expected
*/
// Provide suffix-specific transport methods and typed responses.
// Blocking handlers delay before completing; a not-ready nonblocking
// handler returns zero. Do not observe its failed response output.

module test_tlm_transport_imp_decl_routes_distinct_request_response_pairs;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `uvm_transport_imp_decl(_left)
  `uvm_transport_imp_decl(_right)
  class endpoint extends uvm_component;
    `uvm_component_utils(endpoint)
    uvm_transport_imp_left#(int, string, endpoint) left_imp;
    uvm_transport_imp_right#(int, string, endpoint) right_imp;
    int requests_left[$];
    int requests_right[$];
    int blocking_left = 0;
    int blocking_right = 0;
    int nonblocking_left = 0;
    int nonblocking_right = 0;
    bit ready_left = 1;
    bit ready_right = 1;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      left_imp = new("left_imp", this);
      right_imp = new("right_imp", this);
    endfunction

    task transport_left(input int req, output string rsp);
      #2;
      requests_left.push_back(req);
      blocking_left++;
      rsp = $sformatf("left:%0d", req);
    endtask
    function bit nb_transport_left(input int req, output string rsp);
      if (!ready_left) return 0;
      requests_left.push_back(req);
      nonblocking_left++;
      rsp = $sformatf("left:%0d", req);
      return 1;
    endfunction

    task transport_right(input int req, output string rsp);
      #2;
      requests_right.push_back(req);
      blocking_right++;
      rsp = $sformatf("right:%0d", req);
    endtask
    function bit nb_transport_right(input int req, output string rsp);
      if (!ready_right) return 0;
      requests_right.push_back(req);
      nonblocking_right++;
      rsp = $sformatf("right:%0d", req);
      return 1;
    endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    endpoint sink;
    uvm_transport_port#(int, string) left;
    uvm_transport_port#(int, string) right;
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
      left.transport(11, left_response);
      right.transport(21, right_response);
      $display("UT: blocking %s %s", left_response, right_response);
      first_ok = left.nb_transport(12, left_response);
      second_ok = right.nb_transport(22, right_response);
      $display("UT: nonblocking %0d %0d %s %s", first_ok, second_ok, left_response, right_response);
      $display("UT: requests %0d %0d %0d %0d calls %0d %0d %0d %0d", sink.requests_left[0],
               sink.requests_right[0], sink.requests_left[1], sink.requests_right[1],
               sink.blocking_left, sink.blocking_right, sink.nonblocking_left,
                   sink.nonblocking_right);
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
