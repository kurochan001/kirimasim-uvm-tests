/*
:name: test_rtl_hw_reset_sequence_reads_the_register_file_through_the_adapter_134
:description: the hardware reset sequence reads every register of an RTL register file through the adapter, finds the reset values and skips an excluded register (IEEE 1800.2-2020 Section E.1)
:tags: uE uvm
:type: simulation
:lrm: 1800.2-2020 E.1 E.1.2.1.2 19.2.1.2.5 19.2.1.2.6 18.2.3.5 18.1.2.3 13.7 13.5 13.6 12.2.10.1 6.5.1.2.6 C.3.2.3.1 C.4.2.2.1 14.2.3.1 1800-2023 6.21 14.4 14.13 14.16 25.9
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +UVM_TESTNAME=t
:expected_exit: 0
:expected_stdout: @test_rtl_hw_reset_sequence_reads_the_register_file_through_the_adapter_134.expected
:files: ../u19/helpers116_rtl/rf_rtl116.sv ../u19/helpers116_rtl/rf_env116.svh
*/
// What it checks:
// 1. uvm_reg_hw_reset_seq reads every register of the block through its
//    address map and finds the reset values of an RTL register file.
// 2. A register with a matching NO_REG_HW_RESET_TEST resource is not tested.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 E.1 (UVM-RTL-HW-RESET-SEQ-READS-RTL) gives rule 1. Setup: the
//    environment of rf_env116.svh connects a register model of CTRL, DATA,
//    COUNT and ID to the design of rf_rtl116.sv through an adapter, a
//    sequencer and a driver; the design has just left reset and nothing has
//    been written. Run the sequence on the model. Expected: the bus monitor
//    sees no write and one read of each of the four addresses, the data by
//    address are the reset values 0, 0, 0 and the constant 'ha5, and the
//    report server counts no new error (6.5.1.2.6).
// 2. 1800.2-2020 E.1 (UVM-RTL-HW-RESET-SEQ-EXCLUSION) gives rule 2. Setup: set
//    the resource for the full name of ID in the REG:: namespace and run a
//    second sequence. Expected: the monitor sees three more reads, none of
//    them at the address of ID, and no new error; the reference model of the
//    environment has matched all seven reads.
// These expectations come from the cited clauses and from the rules of the
// test's own design, not from the output of a simulator.
// The reads are counted by address, because the standard does not order them.
// A design that has left its reset state is not exercised: E.1 has the
// sequence reset the DUT, and the standard gives it no means to reach RTL.
module test_rtl_hw_reset_sequence_reads_the_register_file_through_the_adapter_134;
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
    int unsigned reads[4];
    bit [7:0] data[4];
    int unsigned writes;
    int unsigned first_reads;
    int unsigned first_writes;
    int unsigned first_by_address[4];
    int first_errors;
    int second_errors;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = rf_env116::type_id::create("env", this);
    endfunction

    // Counts the monitored transactions from the given position on.
    function void tally(int unsigned from);
      writes = 0;
      foreach (reads[i]) reads[i] = 0;
      for (int unsigned i = from; i < env.collector.seen.size(); i++) begin
        if (env.collector.seen[i].write) begin
          writes++;
        end else begin
          reads[env.collector.seen[i].addr]++;
          data[env.collector.seen[i].addr] = env.collector.seen[i].data;
        end
      end
    endfunction

    task run_phase(uvm_phase phase);
      uvm_report_server server = uvm_report_server::get_server();
      uvm_reg_hw_reset_seq first = new("first");
      uvm_reg_hw_reset_seq second = new("second");
      int errors;
      int unsigned mark;
      phase.raise_objection(this);
      errors = server.get_severity_count(UVM_ERROR);
      first.model = env.model;
      first.start(null);
      env.idle116(4);
      first_errors = server.get_severity_count(UVM_ERROR) - errors;
      tally(0);
      first_reads = reads[0] + reads[1] + reads[2] + reads[3];
      first_writes = writes;
      foreach (reads[i]) first_by_address[i] = reads[i];
      mark = env.collector.seen.size();
      $display("UT: first reads %0d writes %0d by_address %0d %0d %0d %0d", first_reads,
               first_writes, reads[0], reads[1], reads[2], reads[3]);
      $display("UT: first data %0h %0h %0h %0h errors %0d", data[0], data[1], data[2], data[3],
               first_errors);
      errors = server.get_severity_count(UVM_ERROR);
      uvm_resource_db#(bit)::set({"REG::", env.model.id.get_full_name()},
                                 "NO_REG_HW_RESET_TEST", 1);
      second.model = env.model;
      second.start(null);
      env.idle116(4);
      second_errors = server.get_severity_count(UVM_ERROR) - errors;
      tally(mark);
      $display("UT: excluded reads %0d writes %0d id_reads %0d errors %0d",
               reads[0] + reads[1] + reads[2] + reads[3], writes, reads[3], second_errors);
      phase.drop_objection(this);
    endtask

    function void check_phase(uvm_phase phase);
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
