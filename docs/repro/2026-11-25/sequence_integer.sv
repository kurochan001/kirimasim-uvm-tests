module repro;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class producer extends uvm_sequence #(uvm_sequence_item);
    int receive_limit = 2;

    task body();
      $display("UT: entry limit=%0d", this.receive_limit);
      for (int i = 0; i < 2; i++) begin
        uvm_sequence_item request = new("request");
        start_item(request);
        $display("UT: before finish n=%0d limit=%0d", i + 1, this.receive_limit);
        finish_item(request);
        $display("UT: after finish n=%0d limit=%0d", i + 1, this.receive_limit);
        if (this.receive_limit !== 0)
          $fatal(1, "sequence setting changed during the request handshake");
      end
    endtask
  endclass

  class test_t extends uvm_test;
    `uvm_component_utils(test_t)
    uvm_sequencer #(uvm_sequence_item) sqr;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sqr = new("sqr", this);
      sqr.disable_auto_item_recording();
    endfunction

    task run_phase(uvm_phase phase);
      producer worker = new;
      uvm_sequence_item request;
      phase.raise_objection(this);
      worker.receive_limit = 0;
      fork
        worker.start(sqr);
        begin
          repeat (2) begin
            sqr.get_next_item(request);
            #1;
            sqr.item_done();
          end
        end
      join
      $display("UT: completed");
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("test_t");
  initial begin #80; $fatal(1, "watchdog"); end
endmodule
