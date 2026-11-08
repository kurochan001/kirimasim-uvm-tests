// Original agent package for the 120th user-package profiles. It declares a
// sequence item, a driver that keeps one line per delivered item, a
// sequencer type and an agent that creates both children through type_id.
// It imports only uvm_pkg; the sequence, environment and extension packages
// import it, and it names none of their types.
`include "uvm_macros.svh"

package agent_pkg120;
  import uvm_pkg::*;

  class item120 extends uvm_sequence_item;
    `uvm_object_utils(item120)
    int unsigned data;

    function new(string name = "item120");
      super.new(name);
    endfunction
  endclass

  typedef uvm_sequencer #(item120) sequencer120;

  class driver120 extends uvm_driver #(item120);
    `uvm_component_utils(driver120)
    // "<driver type> <item type> <data>" for each item, in delivery order.
    string seen[$];

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      forever begin
        seq_item_port.get_next_item(req);
        seen.push_back($sformatf("%s %s %0d", get_type_name(), req.get_type_name(),
                                 req.data));
        seq_item_port.item_done();
      end
    endtask
  endclass

  class agent120 extends uvm_agent;
    `uvm_component_utils(agent120)
    sequencer120 sqr;
    driver120 drv;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sqr = sequencer120::type_id::create("sqr", this);
      drv = driver120::type_id::create("drv", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

    // One line for the agent and one per delivered item, in a fixed order.
    function void show120();
      string lines[$];
      $display("UT: %s %s drv %s", get_full_name(), get_type_name(), drv.get_type_name());
      lines = drv.seen;
      foreach (lines[i]) begin
        $display("UT: %s %s", drv.get_full_name(), lines[i]);
      end
    endfunction
  endclass
endpackage
