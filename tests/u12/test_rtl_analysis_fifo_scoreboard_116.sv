/*
:name: test_rtl_analysis_fifo_scoreboard_116
:description: an analysis FIFO buffers every RTL monitor transaction while the scoreboard is held and then delivers them in order to the reference model (IEEE 1800.2-2020 Section 12.2.8.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.8.3 12.2.8.2.3 12.2.8.2.4 12.2.8.1.7 13.7 13.7.2.1 13.5 13.6 13.4 13.3 13.9 15.2.1.2.1 15.2.1.2.3 14.2.6.2 14.2.6.3 C.4.2.2.1 C.4.2.2.2 12.2.10.1 12.2.8.3.1 19.2.1.2.5 19.2.1.2.6 18.2.3.6 18.1.2.3 18.2.3.3 18.1.2.6 18.4.4.9 18.4.4.10 1800-2023 14.3 14.4 14.10 14.13 14.16 25.3 25.9 25.9.1 4.4.2.8 9.2.2.4 9.4.2 23.3.1 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +UVM_TESTNAME=t
:expected_exit: 0
:expected_stdout: @test_rtl_analysis_fifo_scoreboard_116.expected
:files: ../u19/helpers116_rtl/rf_rtl116.sv ../u19/helpers116_rtl/rf_env116.svh
*/
// The scoreboard does not read its analysis FIFO until six transactions have
// been monitored. The FIFO must then hold all six, the scoreboard must drain
// them, the FIFO must be empty, and the reference model must match the four
// read results. Expectations follow the original design rules in the helper,
// the cited UVM clauses and the SystemVerilog clocking-block timing; only the
// lines that begin with "UT: " are compared.
module test_rtl_analysis_fifo_scoreboard_116;
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
      seq.add116(1, 0, 8'h0F);
      seq.add116(1, 1, 8'hF0);
      seq.add116(0, 0, 8'h00);
      seq.add116(0, 1, 8'h00);
      seq.add116(0, 2, 8'h00);
      seq.add116(0, 3, 8'h00);
    endfunction

    int unsigned buffered;
    bit empty;

    function void end_of_elaboration_phase(uvm_phase phase);
      env.sb.hold = 1;
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      seq.start(env.agent.sqr);
      env.idle116(4);
      buffered = env.sb.fifo.used();
      env.sb.hold = 0;
      for (int i = 0; i < 20 && env.sb.drained < 6; i++) env.idle116(1);
      empty = env.sb.fifo.is_empty();
      phase.drop_objection(this);
    endtask

    function void check_phase(uvm_phase phase);
      $display("UT: fifo buffered %0d drained %0d empty %0d", buffered, env.sb.drained, empty);
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
