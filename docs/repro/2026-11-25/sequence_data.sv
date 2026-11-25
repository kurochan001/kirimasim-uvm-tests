module repro;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  typedef struct {int x; int y;} pair_t;

  class producer extends uvm_sequence #(uvm_sequence_item);
    string label_value = "default";
    real ratio = 2.25;
    int data[];
    int fixed_values[2] = '{16, 17};
    pair_t pair_value = '{18, 19};

    function void observe(int stage, int i);
      $display("UT: stage=%0d request=%0d string=%s ratio=%0.2f dynamic=%0d fixed=%0d/%0d pair=%0d/%0d",
               stage, i, this.label_value, this.ratio, this.data.size(),
               this.fixed_values[0], this.fixed_values[1], this.pair_value.x, this.pair_value.y);
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
      uvm_sequence_item request;
      phase.raise_objection(this);
      worker.label_value = "configured";
      worker.ratio = 0.25;
      worker.data = new[2];
      worker.data[0] = 42;
      worker.fixed_values = '{4, 5};
      worker.pair_value = '{6, 7};
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
