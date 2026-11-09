/*
:name: test_rtl_vif_config_db_116
:description: a virtual interface set in the configuration database reaches the driver and monitor of an RTL bus agent but not a component outside its scope (IEEE 1800.2-2020 Section C.4.2.2.2)
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.2.2 13.7 13.7.2.1 13.5 13.6 13.4 13.3 13.9 15.2.1.2.1 15.2.1.2.3 14.2.6.2 14.2.6.3 C.4.2.2.1 12.2.10.1 12.2.8.3 12.2.8.3.1 19.2.1.2.5 19.2.1.2.6 18.2.3.6 18.1.2.3 18.2.3.3 18.1.2.6 18.4.4.9 18.4.4.10 1800-2023 14.3 14.4 14.10 14.13 14.16 25.3 25.9 25.9.1 4.4.2.8 9.2.2.4 9.4.2 23.3.1 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +UVM_TESTNAME=t
:expected_exit: 0
:expected_stdout: @test_rtl_vif_config_db_116.expected
:files: ../u19/helpers116_rtl/rf_rtl116.sv ../u19/helpers116_rtl/rf_env116.svh
*/
// What it checks:
// A virtual interface set before build for a component scope is returned to
// components in that scope and connects them to the design.
//
// How the expected output follows from the standard:
// 1800.2-2020 C.4.2.2.2 (UVM-RTL-CONFIG-VIF-SCOPE) gives the rule above.
// Setup: A test top places the interface of an original register-file design
// in the configuration database for the agent scope; the driver and monitor
// use only its clocking blocks. The setting uses the scope
// uvm_test_top.env.agent*; a scoreboard outside it also looks up the field.
// Two writes and two reads then run through the agent. Expected: The driver
// and monitor obtain the same interface, the scoreboard obtains none, four
// transactions are monitored and the reads return the written design values.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The test top sets the bus interface for uvm_test_top.env.agent* before
// run_test. The driver and monitor inside that scope must obtain the same
// interface, the scoreboard outside it must not, and traffic through the
// obtained interface must write and read back the design registers.
// Expectations follow the original design rules in the helper, the cited UVM
// clauses and the SystemVerilog clocking-block timing; only the lines that
// begin with "UT: " are compared.
module test_rtl_vif_config_db_116;
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
      seq.add116(1, 0, 8'h3C);
      seq.add116(1, 1, 8'hC3);
      seq.add116(0, 0, 8'h00);
      seq.add116(0, 1, 8'h00);
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      seq.start(env.agent.sqr);
      env.idle116(4);
      phase.drop_objection(this);
    endtask

    function void check_phase(uvm_phase phase);
      $display("UT: vif driver %0d monitor %0d same %0d outside %0d",
               env.agent.drv.got_vif, env.agent.mon.got_vif,
               env.agent.drv.vif == env.agent.mon.vif, env.sb.outside_got);
      $display("UT: traffic monitored %0d readback %0d", env.collector.seen.size(),
               seq.ops[2].data == 8'h3C && seq.ops[3].data == 8'hC3);
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
