/*
:name: test_rtl_frontdoor_adapter_116
:description: register-model frontdoor writes and reads through an original adapter reach an RTL register file, with auto-prediction updating the mirror (IEEE 1800.2-2020 Section 19.2.1.2.5)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.2.1.2.5 19.1.2 18.2.5.2 18.4.4.3 13.7 13.7.2.1 13.5 13.6 13.4 13.3 13.9 15.2.1.2.1 15.2.1.2.3 14.2.6.2 14.2.6.3 C.4.2.2.1 C.4.2.2.2 12.2.10.1 12.2.8.3 12.2.8.3.1 19.2.1.2.6 18.2.3.6 18.1.2.3 18.2.3.3 18.1.2.6 18.4.4.9 18.4.4.10 1800-2023 14.3 14.4 14.10 14.13 14.16 25.3 25.9 25.9.1 4.4.2.8 9.2.2.4 9.4.2 23.3.1 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +UVM_TESTNAME=t
:expected_exit: 0
:expected_stdout: @test_rtl_frontdoor_adapter_116.expected
:files: helpers116_rtl/rf_rtl116.sv helpers116_rtl/rf_env116.svh
*/
// What it checks:
// 1. With auto-prediction enabled, frontdoor operations against the design
//    update the register mirrors.
// 2. Register-model frontdoor writes converted by reg2bus update the design
//    registers.
// 3. Register-model frontdoor reads return the design value that bus2reg
//    copies from the completed bus item.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.2.5.2 (UVM-RTL-AUTO-PREDICT-FRONTDOOR-MIRROR) gives rule 1
//    above. Setup: A test top places the interface of an original
//    register-file design in the configuration database for the agent scope;
//    the driver and monitor use only its clocking blocks. Auto-prediction is
//    enabled before the model writes CTRL and DATA and reads CTRL, ID and
//    COUNT; two raw reads follow. Expected: Seven bus operations are
//    monitored, the map reports auto-prediction on, and the mirrors hold the
//    written and read values.
// 2. 1800.2-2020 19.2.1.2.5 (UVM-RTL-FRONTDOOR-WRITE-REACHES-DESIGN) gives
//    rule 2 above. Setup: A test top places the interface of an original
//    register-file design in the configuration database for the agent scope;
//    the driver and monitor use only its clocking blocks. The model writes
//    CTRL and DATA through the map sequencer and adapter; raw bus reads then
//    bypass the model. Expected: The raw reads return the values the model
//    wrote.
// 3. 1800.2-2020 19.2.1.2.6 (UVM-RTL-FRONTDOOR-READ-RETURNS-DESIGN) gives rule
//    3 above. Setup: A test top places the interface of an original
//    register-file design in the configuration database for the agent scope;
//    the driver and monitor use only its clocking blocks. After two model
//    writes, the model reads CTRL, the constant ID and the write-counting
//    COUNT. Expected: All five operations report UVM_IS_OK and the reads
//    return the written CTRL value, 8'hA5 and two.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// With auto-prediction enabled, the register model writes CTRL and DATA and
// reads CTRL, ID and COUNT through the map sequencer and adapter. Raw bus reads
// then return the design values written by the model, seven bus operations are
// monitored, and the mirrors hold the written and read values. Expectations
// follow the original design rules in the helper, the cited UVM clauses and the
// SystemVerilog clocking-block timing; only the lines that begin with "UT: "
// are compared.
module test_rtl_frontdoor_adapter_116;
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
      seq.add116(0, 0, 8'h00);
      seq.add116(0, 1, 8'h00);
    endfunction

    uvm_status_e status[5];
    uvm_reg_data_t ctrl_value;
    uvm_reg_data_t id_value;
    uvm_reg_data_t count_value;

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      env.model.bus_map.set_auto_predict(1);
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      env.model.ctrl.write(status[0], 8'h3C);
      env.model.data.write(status[1], 8'hC3);
      env.model.ctrl.read(status[2], ctrl_value);
      env.model.id.read(status[3], id_value);
      env.model.count.read(status[4], count_value);
      seq.start(env.agent.sqr);
      env.idle116(4);
      phase.drop_objection(this);
    endtask

    function void check_phase(uvm_phase phase);
      bit ok = 1;
      foreach (status[i]) ok &= status[i] == UVM_IS_OK;
      $display("UT: frontdoor status %0d ctrl %0d id %0d count %0d", ok,
               ctrl_value == 8'h3C, id_value == 8'hA5, count_value == 8'd2);
      $display("UT: design readback ctrl %0d data %0d",
               seq.ops[0].data == 8'h3C, seq.ops[1].data == 8'hC3);
      $display("UT: bus_ops %0d auto_predict %0d mirrors %0d", env.collector.seen.size(),
               env.model.bus_map.get_auto_predict(),
               env.model.ctrl.get_mirrored_value() == 8'h3C &&
               env.model.data.get_mirrored_value() == 8'hC3 &&
               env.model.count.get_mirrored_value() == 8'd2 &&
               env.model.id.get_mirrored_value() == 8'hA5);
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
