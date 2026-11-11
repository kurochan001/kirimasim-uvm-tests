/*
:name: test_rtl_clocking_handshake_116
:description: finish_item returns after a clocking-block driver completes each RTL bus request, and the monitor observes each request one clock after it is driven (IEEE 1800.2-2020 Section 14.2.6.3)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.6.3 13.7 13.7.2.1 13.5 13.6 13.4 13.3 13.9 15.2.1.2.1 15.2.1.2.3 14.2.6.2 C.4.2.2.1 C.4.2.2.2 12.2.10.1 12.2.8.3 12.2.8.3.1 19.2.1.2.5 19.2.1.2.6 18.2.3.6 18.1.2.3 18.2.3.3 18.1.2.6 18.4.4.9 18.4.4.10 1800-2023 14.3 14.4 14.10 14.13 14.16 25.3 25.9 25.9.1 4.4.2.8 9.2.2.4 9.4.2 23.3.1 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +UVM_TESTNAME=t
:expected_exit: 0
:expected_stdout: @test_rtl_clocking_handshake_116.expected
:files: ../u19/helpers116_rtl/rf_rtl116.sv ../u19/helpers116_rtl/rf_env116.svh
*/
// What it checks:
// 1. finish_item returns only after the driver that took the item from the
//    sequencer signals item_done.
// 2. Items that a clocking-block driver takes with get_next_item reach the
//    design in sequence order on the next clock.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.2.6.3 (UVM-RTL-FINISH-AFTER-DRIVER-DONE) gives rule 1
//    above. Setup: A test top places the interface of an original
//    register-file design in the configuration database for the agent scope;
//    the driver and monitor use only its clocking blocks. A sequence starts
//    two writes and three reads; the driver stores completion data in each
//    item before item_done. Expected: Every item already holds its completion
//    record when finish_item returns.
// 2. 1800.2-2020 15.2.1.2.1 (UVM-RTL-PULL-DRIVER-CLOCKED-ORDER) gives rule 2
//    above. Setup: A test top places the interface of an original
//    register-file design in the configuration database for the agent scope;
//    the driver and monitor use only its clocking blocks. Two writes and three
//    reads are driven with zero output skew and observed with one-step input
//    sampling. Expected: Five transactions are monitored in sequence order
//    with the design values; each request is observed one clock after it is
//    driven and each read result one clock after its request.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Two writes and three reads run through a driver that drives with zero output
// skew and samples one step before each edge. Each request must be observed one
// clock after it is driven, a read result one clock after its request,
// finish_item must return only after the driver records completion, and the
// monitored stream must keep the sequence order and the design values.
// Expectations follow the original design rules in the helper, the cited UVM
// clauses and the SystemVerilog clocking-block timing; only the lines that
// begin with "UT: " are compared.
module test_rtl_clocking_handshake_116;
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
      seq.add116(1, 0, 8'h11);
      seq.add116(1, 1, 8'h22);
      seq.add116(0, 0, 8'h00);
      seq.add116(0, 1, 8'h00);
      seq.add116(0, 3, 8'h00);
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      seq.start(env.agent.sqr);
      env.idle116(4);
      phase.drop_objection(this);
    endtask

    function void check_phase(uvm_phase phase);
      bit order = env.collector.seen.size() == 5;
      bit values = order;
      bit request = order;
      bit read_result = 1;
      bit write_done = 1;
      bit [7:0] want[5] = '{8'h11, 8'h22, 8'h11, 8'h22, 8'hA5};
      bit finished = seq.done_at_return.size() == 5;
      foreach (seq.done_at_return[i]) finished &= seq.done_at_return[i];
      if (order) begin
        foreach (seq.ops[i]) begin
          order &= env.collector.seen[i].write == seq.ops[i].write &&
                   env.collector.seen[i].addr == seq.ops[i].addr;
          values &= env.collector.seen[i].data == want[i] && seq.ops[i].data == want[i];
          request &= env.collector.seen[i].seen_cycle == seq.ops[i].drive_cycle + 1;
          if (seq.ops[i].write) write_done &= seq.ops[i].done_cycle == seq.ops[i].drive_cycle + 1;
          else read_result &= seq.ops[i].done_cycle == seq.ops[i].drive_cycle + 2;
        end
      end
      $display("UT: monitored %0d order %0d values %0d", env.collector.seen.size(), order, values);
      $display("UT: request_after_drive %0d read_after_request %0d write_done_after_drive %0d",
               request, read_result, write_done);
      $display("UT: finish_after_done %0d", finished);
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
