/*
:name: test_rtl_two_clock_buses_are_paired_through_analysis_fifos_by_position_136
:description: two analysis FIFOs buffer the transactions of two RTL buses on unrelated clocks, and a scoreboard pairs them by position (IEEE 1800.2-2020 Section 12.2.8.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.8.3 12.2.8.3.1 12.2.8.2.4 12.2.2.2 12.2.10.1 13.3 13.4 13.5 13.6 13.7 13.9 14.2.3.1 14.2.6.2 14.2.6.3 15.2.1.2.1 15.2.1.2.3 C.4.2.2.1 C.4.2.2.2 1800-2023 6.21 9.3.2 14.4 14.13 14.16 25.9
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +UVM_TESTNAME=t
:expected_exit: 0
:expected_stdout: @test_rtl_two_clock_buses_are_paired_through_analysis_fifos_by_position_136.expected
:files: ../u19/helpers116_rtl/rf_rtl116.sv ../u19/helpers116_rtl/rf_env116.svh
*/
// What it checks:
// Two analysis FIFOs buffer the transactions of two buses that run on
// unrelated clocks, and a scoreboard that gets one transaction from each FIFO
// pairs them by position, whatever the order in which they arrive.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.2.8.3 (UVM-RTL-TWO-CLOCK-FIFO-PAIRING) gives the rule above
// with 12.2.2.2: an analysis FIFO is an unbounded FIFO with a write interface,
// so no transaction is lost or reordered within one stream, and a get waits
// for the next one; is_empty (12.2.8.2.4) reads the state at the end. Setup:
// two instances of the design of
// rf_rtl116.sv run on clocks of period 10 and 14; an agent on each runs the
// same sequence, which writes 'h3c to CTRL and 'hc3 to DATA and reads CTRL,
// DATA and COUNT; each monitor writes to its own FIFO, and the scoreboard gets
// from both FIFOs in parallel before it compares one pair. Expected: by the
// rules of the design both buses read 'h3c, 'hc3 and 2 accepted writes; the
// scoreboard forms 5 pairs that agree in direction, address and data; both
// FIFOs are empty at the end; and the two streams end at different times.
// These expectations come from the cited clauses and from the rules of the
// test's own design, not from the output of a simulator.
// The pairs are formed by position in each stream, so the result does not
// depend on which bus delivers a transaction first.
module test_rtl_two_clock_buses_are_paired_through_analysis_fifos_by_position_136;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "rf_env116.svh"

  logic clk_a = 1'b0;
  logic clk_b = 1'b0;
  always #5 clk_a = ~clk_a;
  always #7 clk_b = ~clk_b;
  rf_if116 bus_a(clk_a);
  rf_if116 bus_b(clk_b);
  rf_dut116 dut_a(bus_a);
  rf_dut116 dut_b(bus_b);

  // Remembers when the last transaction of a stream arrived.
  class time_probe extends uvm_subscriber #(rf_item116);
    `uvm_component_utils(time_probe)
    time last;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void write(rf_item116 t);
      last = $time;
    endfunction
  endclass

  class pairing_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(pairing_scoreboard)
    uvm_tlm_analysis_fifo #(rf_item116) fifo_a;
    uvm_tlm_analysis_fifo #(rf_item116) fifo_b;
    int unsigned pairs;
    int unsigned equal;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      fifo_a = new("fifo_a", this);
      fifo_b = new("fifo_b", this);
    endfunction

    task run_phase(uvm_phase phase);
      rf_item116 from_a;
      rf_item116 from_b;
      forever begin
        fork
          fifo_a.get(from_a);
          fifo_b.get(from_b);
        join
        pairs++;
        if (from_a.write == from_b.write && from_a.addr == from_b.addr
            && from_a.data == from_b.data) equal++;
      end
    endtask
  endclass

  class two_clock_env extends uvm_env;
    `uvm_component_utils(two_clock_env)
    rf_agent116 agent_a;
    rf_agent116 agent_b;
    time_probe probe_a;
    time_probe probe_b;
    pairing_scoreboard sb;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      agent_a = rf_agent116::type_id::create("agent_a", this);
      agent_b = rf_agent116::type_id::create("agent_b", this);
      probe_a = time_probe::type_id::create("probe_a", this);
      probe_b = time_probe::type_id::create("probe_b", this);
      sb = pairing_scoreboard::type_id::create("sb", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      agent_a.mon.ap.connect(sb.fifo_a.analysis_export);
      agent_b.mon.ap.connect(sb.fifo_b.analysis_export);
      agent_a.mon.ap.connect(probe_a.analysis_export);
      agent_b.mon.ap.connect(probe_b.analysis_export);
    endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    two_clock_env env;
    rf_seq116 seq_a;
    rf_seq116 seq_b;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function rf_seq116 make(string name);
      rf_seq116 seq = rf_seq116::type_id::create(name);
      seq.add116(1, 0, 8'h3C);
      seq.add116(1, 1, 8'hC3);
      seq.add116(0, 0, 8'h00);
      seq.add116(0, 1, 8'h00);
      seq.add116(0, 2, 8'h00);
      return seq;
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = two_clock_env::type_id::create("env", this);
      seq_a = make("seq_a");
      seq_b = make("seq_b");
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      fork
        seq_a.start(env.agent_a.sqr);
        seq_b.start(env.agent_b.sqr);
      join
      repeat (4) @(posedge clk_b);
      phase.drop_objection(this);
    endtask

    function void check_phase(uvm_phase phase);
      $display("UT: reads a %0h %0h %0h b %0h %0h %0h", seq_a.ops[2].data, seq_a.ops[3].data,
               seq_a.ops[4].data, seq_b.ops[2].data, seq_b.ops[3].data, seq_b.ops[4].data);
      $display("UT: pairs %0d equal %0d empty %0d %0d", env.sb.pairs, env.sb.equal,
               env.sb.fifo_a.is_empty(), env.sb.fifo_b.is_empty());
      $display("UT: streams end at different times %0d",
               env.probe_a.last != env.probe_b.last);
    endfunction
  endclass

  initial begin
    uvm_config_db #(virtual rf_if116)::set(null, "uvm_test_top.env.agent_a*", "vif", bus_a);
    uvm_config_db #(virtual rf_if116)::set(null, "uvm_test_top.env.agent_b*", "vif", bus_b);
    run_test();
  end

  initial begin
    repeat (2) @(posedge clk_a);
    bus_a.rst_n <= 1'b1;
  end

  initial begin
    repeat (2) @(posedge clk_b);
    bus_b.rst_n <= 1'b1;
  end
endmodule
