/*
:name: test_rtl_explicit_predictor_116
:description: an explicit register predictor on an RTL bus monitor updates mirrors from model and raw traffic and publishes one register item per access (IEEE 1800.2-2020 Section 19.3.2.1)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.3.2.1 19.3.2.2 19.3.2.3 19.3.2.4 18.2.5.1 18.2.5.2 18.4.4.3 18.4.4.15 13.7 13.7.2.1 13.5 13.6 13.4 13.3 13.9 15.2.1.2.1 15.2.1.2.3 14.2.6.2 14.2.6.3 C.4.2.2.1 C.4.2.2.2 12.2.10.1 12.2.8.3 12.2.8.3.1 19.2.1.2.5 19.2.1.2.6 18.2.3.6 18.1.2.3 18.2.3.3 18.1.2.6 18.4.4.9 18.4.4.10 1800-2023 14.3 14.4 14.10 14.13 14.16 25.3 25.9 25.9.1 4.4.2.8 9.2.2.4 9.4.2 23.3.1 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +UVM_TESTNAME=t
:expected_exit: 0
:expected_stdout: @test_rtl_explicit_predictor_116.expected
:files: helpers116_rtl/rf_rtl116.sv helpers116_rtl/rf_env116.svh
*/
// What it checks:
// 1. A predictor connected to the design's bus monitor updates mirrors from
//    every observed register access, subject to access policy.
// 2. The predictor publishes one register item for each observed access that
//    maps to a register.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 19.3.2.1 (UVM-RTL-EXPLICIT-PREDICTOR-MIRRORS) gives rule 1
//    above. Setup: A test top places the interface of an original
//    register-file design in the configuration database for the agent scope;
//    the driver and monitor use only its clocking blocks. Auto-prediction
//    keeps its default. The model writes CTRL; raw traffic writes DATA and the
//    read-only ID and reads COUNT. Expected: The default is off, the model
//    write succeeds, the read-write mirrors hold the written values, the ID
//    mirror is unchanged and the COUNT mirror holds the design count of two.
// 2. 1800.2-2020 19.3.2.2 (UVM-RTL-PREDICTOR-REG-AP-PER-ACCESS) gives rule 2
//    above. Setup: A test top places the interface of an original
//    register-file design in the configuration database for the agent scope;
//    the driver and monitor use only its clocking blocks. The predictor
//    observes one model write and three raw accesses, each to a mapped
//    register. Expected: Four register items are published.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Auto-prediction keeps its default. The model writes CTRL, raw traffic writes
// DATA and the read-only ID and reads COUNT, and a predictor connected to the
// monitor updates the mirrors: written values for the read-write registers, the
// unchanged ID for the ignored write and the design count for the read. Its
// register-item port publishes each of the four accesses. Expectations follow
// the original design rules in the helper, the cited UVM clauses and the
// SystemVerilog clocking-block timing; only the lines that begin with "UT: "
// are compared.
module test_rtl_explicit_predictor_116;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "rf_env116.svh"

  logic clk = 1'b0;
  always #5 clk = ~clk;
  rf_if116 bus(clk);
  rf_dut116 dut(bus);

  class t extends uvm_test;
    `uvm_component_utils(t)
    rf_env116 env;
    rf_seq116 seq;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = rf_env116::type_id::create("env", this);
      seq = rf_seq116::type_id::create("seq");
      env.use_predictor = 1;
      seq.add116(1, 1, 8'h77);
      seq.add116(1, 3, 8'h00);
      seq.add116(0, 2, 8'h00);
    endfunction

    uvm_status_e status;
    bit auto_predict;

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      auto_predict = env.model.bus_map.get_auto_predict();
      env.model.ctrl.write(status, 8'h5A);
      seq.start(env.agent.sqr);
      env.idle116(4);
      phase.drop_objection(this);
    endtask

    function void check_phase(uvm_phase phase);
      $display("UT: auto_predict %0d status %0d", auto_predict, status == UVM_IS_OK);
      $display("UT: predicted model_write %0d raw_write %0d readonly_write %0d readonly_read %0d",
               env.model.ctrl.get_mirrored_value() == 8'h5A,
               env.model.data.get_mirrored_value() == 8'h77,
               env.model.id.get_mirrored_value() == 8'hA5,
               env.model.count.get_mirrored_value() == 8'd2);
      $display("UT: reg_ap items %0d", env.reg_items.items);
      env.report116();
    endfunction
  endclass

  initial begin
    uvm_config_db #(virtual rf_if116)::set(null, "uvm_test_top.env.agent*", "vif", bus);
    run_test();
  end

  initial begin
    repeat (2) @(posedge clk);
    bus.rst_n <= 1'b1;
  end
endmodule
