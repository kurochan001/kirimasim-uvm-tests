/*
:name: test_analysis_export_forwards_writes_to_fifo_receiver
:description: analysis export forwards a port write to its connected FIFO receiver (IEEE 1800.2-2020 Section 12.2.10.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.10.3 12.2.10.3.2 12.2.10.1.4 12.2.8.3.1 5.5.2.12 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_analysis_export_forwards_writes_to_fifo_receiver.expected
*/
// Build a port-export-implementation chain and observe it after UVM
// resolves bindings. Each source write must reach the terminal queue once.

module test_analysis_export_forwards_writes_to_fifo_receiver;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_analysis_port#(int) ap;
    uvm_analysis_export#(int) bridge;
    uvm_tlm_analysis_fifo#(int) receiver;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      ap = new("ap", this);
      bridge = new("bridge", this);
      receiver = new("receiver", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      ap.connect(bridge);
      bridge.connect(receiver.analysis_export);
    endfunction
    task run_phase(uvm_phase phase);
      int first;
      int second;
      phase.raise_objection(this);
      ap.write(71);
      ap.write(41);
      $display("UT: bindings port %0d export %0d queued %0d", ap.size(), bridge.size(),
          receiver.used());
      if (!receiver.try_get(first)) $fatal(1, "delivery missing");
      if (!receiver.try_get(second)) $fatal(1, "delivery missing");
      $display("UT: received %0d %0d remaining %0d", first, second, receiver.used());
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #30;
    $fatal(1, "test watchdog expired");
  end
endmodule
