/*
:name: test_tlm_analysis_imp_decl_separates_two_input_histories_on_one_component
:description: analysis declaration macro supports two independently named inputs on one component (IEEE 1800.2-2020 Section B.5.22)
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.5.22 12.2.10.2 12.2.4.2.12 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_analysis_imp_decl_separates_two_input_histories_on_one_component.expected
*/
// Write through two analysis ports to independently named handlers on one
// component. Each synchronous call must reach only its selected input, and
// the component supplies no unsuffixed write method.

module test_tlm_analysis_imp_decl_separates_two_input_histories_on_one_component;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `uvm_analysis_imp_decl(_left)
  `uvm_analysis_imp_decl(_right)
  class endpoint extends uvm_component;
    `uvm_component_utils(endpoint)
    uvm_analysis_imp_left#(int, endpoint) left_imp;
    uvm_analysis_imp_right#(int, endpoint) right_imp;
    int left_values[$];
    int right_values[$];
    function new(string name, uvm_component parent);
      super.new(name, parent);
      left_imp = new("left_imp", this);
      right_imp = new("right_imp", this);
    endfunction
    function void write_left(int t); left_values.push_back(t); endfunction
    function void write_right(int t); right_values.push_back(t); endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    endpoint sink;
    uvm_analysis_port#(int) left;
    uvm_analysis_port#(int) right;
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
      left.write(11);
      right.write(21);
      left.write(12);
      right.write(22);
      $display("UT: counts %0d %0d values %0d %0d %0d %0d", sink.left_values.size(),
               sink.right_values.size(), sink.left_values[0], sink.right_values[0],
               sink.left_values[1], sink.right_values[1]);
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
