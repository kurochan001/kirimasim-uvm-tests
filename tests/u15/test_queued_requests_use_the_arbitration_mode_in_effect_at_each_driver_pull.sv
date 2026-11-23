/*
:name: test_queued_requests_use_the_arbitration_mode_in_effect_at_each_driver_pull
:description: Pending sequence requests follow the current arbitration mode when the driver requests each grant (IEEE 1800.2-2020 Section 15.3.2.19)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.2.19 15.5.2.3 15.3.2.18 F.2.4.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_queued_requests_use_the_arbitration_mode_in_effect_at_each_driver_pull.expected
*/
// Queue three items in known arrival order with strictly increasing
// priorities, without calling the driver. Switch from FIFO to STRICT_FIFO to
// select the newest highest priority. Switch back to FIFO while two requests
// remain; the oldest must now win. Check all identities and completion of all
// three sequences. No tie-breaking or simultaneous arrivals are involved.

module test_queued_requests_use_the_arbitration_mode_in_effect_at_each_driver_pull;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    int value;
    function new(int value); super.new("request"); this.value = value; endfunction
  endclass
  class client extends uvm_sequence #(packet);
    packet req;
    bit finished;
    function new(string name, int value);
      super.new(name);
      req = new(value);
    endfunction
    task body();
      start_item(req);
      finish_item(req);
      finished = 1;
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer #(packet) sqr;
    uvm_driver #(packet) driver;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sqr = new("sqr", this);
      driver = new("driver", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sqr.seq_item_export);
    endfunction
    task take(output packet result);
      driver.seq_item_port.get_next_item(result);
      if (result == null) $fatal(1, "missing driver request");
      driver.seq_item_port.item_done();
    endtask
    task run_phase(uvm_phase phase);
      client a = new("first", 11);
      client b = new("middle", 22);
      client c = new("last", 33);
      packet first, second, third;
      phase.raise_objection(this);
      sqr.set_arbitration(UVM_SEQ_ARB_FIFO);
      fork
        a.start(sqr, null, 10);
        begin #1; b.start(sqr, null, 20); end
        begin #2; c.start(sqr, null, 30); end
        begin
          #3;
          sqr.set_arbitration(UVM_SEQ_ARB_STRICT_FIFO);
          take(first);
          sqr.set_arbitration(UVM_SEQ_ARB_FIFO);
          take(second);
          take(third);
        end
      join
      $display("UT: strict highest %0d value %0d", first == c.req, first.value);
      $display("UT: fifo oldest %0d value %0d", second == a.req, second.value);
      $display("UT: remaining %0d value %0d completed %0d %0d %0d",
               third == b.req, third.value, a.finished, b.finished, c.finished);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin
    #100;
    $fatal(1, "arbitration watchdog expired");
  end
endmodule
