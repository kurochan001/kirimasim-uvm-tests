/*
:name: test_sequence_relevance_relevant_peer_releases_only_eligible_requests
:description: relevance waits resume arbitration for selected pending or restarted requests (IEEE 1800.2-2020 Section 14.2.5.4)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.5.4 14.2.5.3 14.2.3.1 14.2.6.2 14.2.6.3 15.5.2.2 15.5.2.3 15.5.2.5 15.3.2.22 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_relevance_relevant_peer_releases_only_eligible_requests.expected
*/
// Queue requests before the delayed driver arbitrates. Gates and positive
// delays establish order; exact internal polling/wait counts are not fixed.
module test_sequence_relevance_relevant_peer_releases_only_eligible_requests;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class packet extends uvm_sequence_item;
    int value;
    function new(); super.new("packet"); endfunction
  endclass
  class gated_sequence extends uvm_sequence#(packet);
    bit relevant = 0;
    int label;
    int wait_calls = 0, finished_runs = 0;
    function new(string name="gated"); super.new(name); endfunction
    virtual function bit is_relevant(); return relevant; endfunction
    virtual task wait_for_relevant(); wait_calls++; wait (relevant); endtask
    virtual task body();
      automatic packet item = new();
      item.value = label; start_item(item); finish_item(item); finished_runs++;
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(packet) sequencer;
    uvm_driver#(packet) driver;
    gated_sequence first, second;
    packet observed;
    int values[$];
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this); sequencer.disable_auto_item_recording();
      driver = new("driver", this); first = new("first"); second = new("second");
      first.label = 11; second.label = 22;
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      int before_waits;
      phase.raise_objection(this);
      second.relevant = 1;
      fork
        first.start(sequencer);
        second.start(sequencer);
        begin
          #2;
          repeat (2) begin
            driver.seq_item_port.get_next_item(observed); values.push_back(observed.value);
            #1; driver.seq_item_port.item_done();
          end
        end
        begin
          wait (second.finished_runs == 1); #1;
          $display("UT: peer_finished received %0d first %0d second %0d", values.size(),
                   first.finished_runs, second.finished_runs);
          wait (first.wait_calls > 0);
          $display("UT: pending_wait %0d", first.wait_calls > 0);
          first.relevant = 1;
        end
      join
      $display("UT: finished first %0d second %0d order %0d %0d", first.finished_runs,
               second.finished_runs, values[0], values[1]);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "relevance watchdog expired"); end
endmodule
