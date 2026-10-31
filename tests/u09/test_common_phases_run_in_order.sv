/*
:name: test_common_phases_run_in_order
:description: the common phases run in their order, each bottom-up function phase calls the child before its parent, and the run phase lasts while an objection is raised (IEEE 1800.2-2020 Section 9.8.1)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.8.1 9.5 9.6 9.7 10.5.1
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +UVM_TESTNAME=t
:expected_stdout: @test_common_phases_run_in_order.expected
*/
// IEEE 1800.2-2020 §9.8.1 describes the common phases in the order they run:
// build, connect, end_of_elaboration, start_of_simulation, run, extract,
// check, report and final, the phases before run all at time 0. build and
// final are top-down phases (§9.7), run is a task phase (§9.6) and the others
// are bottom-up phases, which §9.5 runs on the components without children
// first and then on their parents.
//
// The test t creates one child, env, in its build_phase, so the child is built
// after its parent. Every bottom-up phase prints the child before the parent.
// This case prints final from t only, focusing on the bottom-up ordering.
// Only t prints run, as the run_phase tasks of the components start in
// parallel. t raises an objection in run_phase
// and drops it one time unit later, so the run phase lasts until then
// (§9.6, §10.5.1). Only the lines that begin with "UT: " are compared.

module test_common_phases_run_in_order;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class child_env extends uvm_env;
    `uvm_component_utils(child_env)

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      $display("UT: build env");
    endfunction

    function void connect_phase(uvm_phase phase);
      $display("UT: connect env");
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
      $display("UT: end_of_elaboration env");
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
      $display("UT: start_of_simulation env");
    endfunction

    function void extract_phase(uvm_phase phase);
      $display("UT: extract env");
    endfunction

    function void check_phase(uvm_phase phase);
      $display("UT: check env");
    endfunction

    function void report_phase(uvm_phase phase);
      $display("UT: report env");
    endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    child_env env;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      $display("UT: build test");
      env = child_env::type_id::create("env", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      $display("UT: connect test");
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
      $display("UT: end_of_elaboration test");
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
      $display("UT: start_of_simulation test");
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      $display("UT: run test");
      #1;
      phase.drop_objection(this);
    endtask

    function void extract_phase(uvm_phase phase);
      $display("UT: extract test");
    endfunction

    function void check_phase(uvm_phase phase);
      $display("UT: check test");
    endfunction

    function void report_phase(uvm_phase phase);
      $display("UT: report test");
    endfunction

    function void final_phase(uvm_phase phase);
      $display("UT: final test");
    endfunction
  endclass

  initial run_test();
endmodule
