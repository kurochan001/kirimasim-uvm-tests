/*
:name: test_rtl_reset_jump_reruns_the_runtime_phases_and_drain_time_counts_clocks_137
:description: a jump from the main phase back to the reset phase runs the run-time phases again and resets the RTL again, and a drain time on the shutdown objection keeps the phase open for three clocks (IEEE 1800.2-2020 Section 9.3.1.9.1)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.9.1 9.3.1.4.4 9.3.1.7.1 9.8.2 9.8.2.2 9.8.2.5 9.8.2.8 9.8.2.11 10.5.1.3.7 10.5.1.3.3 10.5.1.3.4 13.1.4.3.3 13.3 13.4 13.5 13.7 14.2.3.1 C.4.2.2.1 C.4.2.2.2 1800-2023 6.21 14.4 14.13 14.16 25.9 20.3.1
:uvm: 2020.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +UVM_TESTNAME=t
:expected_exit: 0
:expected_stdout: @test_rtl_reset_jump_reruns_the_runtime_phases_and_drain_time_counts_clocks_137.expected
:files: ../u19/helpers116_rtl/rf_rtl116.sv ../u19/helpers116_rtl/rf_env116.svh
*/
// What it checks:
// 1. The reset, configure, main and shutdown phases run in that order, and a
//    jump from the main phase back to the reset phase runs reset, configure
//    and main again.
// 2. The second reset phase resets the RTL again, so the design holds only
//    what was written after it.
// 3. A drain time set on the objection of the shutdown phase keeps the phase
//    open for that time after the last objection is dropped.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 9.3.1.9.1 (UVM-RTL-JUMP-RERUNS-RUNTIME-PHASES) gives rule 1
//    with 9.8.2.2, 9.8.2.5, 9.8.2.8 and 9.8.2.11. Setup: the test counts each
//    phase task; its first main phase jumps to the reset node that find
//    returns, after its objection is dropped. Expected: reset, configure and
//    main run twice and shutdown once.
// 2. 1800.2-2020 9.8.2.2 (UVM-RTL-RESET-PHASE-RESETS-RTL) has the reset phase
//    call reset_phase, so the task runs once more after the jump; that the
//    task resets the RTL is this test's own code. Setup:
//    each reset phase holds rst_n of the design in rf_rtl116.sv low for two
//    clocks; each configure phase writes 'h10 plus its count to CTRL and each
//    main phase 'h20 plus its count to DATA; the shutdown phase reads CTRL,
//    DATA and COUNT. Expected: by the rules of the design CTRL is 'h12, DATA
//    is 'h22, and COUNT is 2, the accepted writes since the second reset,
//    not 4.
// 3. 1800.2-2020 10.5.1.3.7 (UVM-RTL-DRAIN-TIME-IN-CLOCKS) gives rule 3 with
//    13.1.4.3.3. Setup: the shutdown phase sets a drain time of 30 time
//    units, three periods of the clock, on its objection for the test and
//    drops the objection; phase_ended records the time. Expected: the phase
//    ends 30 time units after the drop, which is three clock periods. The
//    time is read with $time and no clock edge takes part; the library and
//    the test share one time unit, which the runners give on the command
//    line (docs/testing.md, "Time unit and report declarations").
// These expectations come from the cited clauses and from the rules of the
// test's own design, not from the output of a simulator.
// No sequence is running when the jump is requested, so the test does not
// depend on what a jump does to a sequence in progress.
module test_rtl_reset_jump_reruns_the_runtime_phases_and_drain_time_counts_clocks_137;
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
    int unsigned resets;
    int unsigned configures;
    int unsigned mains;
    int unsigned shutdowns;
    bit [7:0] ctrl;
    bit [7:0] data;
    bit [7:0] count;
    time dropped_at;
    time ended_at;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = rf_env116::type_id::create("env", this);
    endfunction

    task write116(bit [1:0] addr, bit [7:0] value);
      rf_seq116 seq = rf_seq116::type_id::create("write_seq");
      seq.add116(1, addr, value);
      seq.start(env.agent.sqr);
    endtask

    task reset_phase(uvm_phase phase);
      phase.raise_objection(this);
      resets++;
      env.agent.drv.vif.rst_n <= 1'b0;
      repeat (2) @(posedge clk);
      env.agent.drv.vif.rst_n <= 1'b1;
      @(posedge clk);
      phase.drop_objection(this);
    endtask

    task configure_phase(uvm_phase phase);
      phase.raise_objection(this);
      configures++;
      write116(0, 8'h10 + configures);
      phase.drop_objection(this);
    endtask

    task main_phase(uvm_phase phase);
      phase.raise_objection(this);
      mains++;
      if (mains > 2) `uvm_fatal("RTL137", "unexpected repeated jump")
      write116(1, 8'h20 + mains);
      phase.drop_objection(this);
      if (mains == 1) begin
        uvm_phase target = phase.find(uvm_reset_phase::get());
        if (target == null) `uvm_fatal("RTL137", "no reset node")
        phase.jump(target);
      end
    endtask

    task shutdown_phase(uvm_phase phase);
      rf_seq116 seq = rf_seq116::type_id::create("read_seq");
      uvm_objection objection = phase.get_objection();
      phase.raise_objection(this);
      shutdowns++;
      seq.add116(0, 0, 8'h00);
      seq.add116(0, 1, 8'h00);
      seq.add116(0, 2, 8'h00);
      seq.start(env.agent.sqr);
      ctrl = seq.ops[0].data;
      data = seq.ops[1].data;
      count = seq.ops[2].data;
      objection.set_drain_time(this, 30);
      dropped_at = $time;
      phase.drop_objection(this);
    endtask

    function void phase_ended(uvm_phase phase);
      super.phase_ended(phase);
      if (phase.get_name() == "shutdown") ended_at = $time;
    endfunction

    function void check_phase(uvm_phase phase);
      $display("UT: phases reset %0d configure %0d main %0d shutdown %0d", resets, configures,
               mains, shutdowns);
      $display("UT: after rerun ctrl %0h data %0h count %0d", ctrl, data, count);
      $display("UT: drain clocks %0d", (ended_at - dropped_at) / 10);
    endfunction
  endclass

  initial begin
    uvm_config_db #(virtual rf_if116)::set(null, "uvm_test_top.env.agent*", "vif", bus);
    run_test();
  end

  initial begin
    #5000;
    $fatal(1, "watchdog");
  end
endmodule
