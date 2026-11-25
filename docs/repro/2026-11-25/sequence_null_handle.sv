module repro;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class token;
    int value;
    function new(int value);
      this.value = value;
    endfunction
  endclass

  class producer extends uvm_sequence #(uvm_sequence_item);
    token previously_set = new(101);
    token configured = new(102);
    token initially_null;
    token expected_handle;

    function void observe(int stage, int i);
      $display("UT: stage=%0d request=%0d still_null=%0d replaced=%0d assigned=%0d",
               stage, i, this.previously_set == null, this.configured == this.expected_handle,
               this.initially_null == this.expected_handle);
    endfunction

    task body();
      observe(0, 0);
      for (int i = 1; i <= 2; i++) begin
        uvm_sequence_item request = new("request");
        start_item(request);
        observe(1, i);
        finish_item(request);
        observe(2, i);
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
      token mine = new(201);
      uvm_sequence_item request;
      phase.raise_objection(this);
      worker.previously_set = null;
      worker.configured = mine;
      worker.initially_null = mine;
      worker.expected_handle = mine;
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
