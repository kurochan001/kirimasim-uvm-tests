// Original plumbing for the 118th randomization profiles: an event log, a
// driver that logs each delivered item and a test base that starts one
// parent sequence through run118. Each test defines its items, sequences and
// the class t that extends test_base118.

class log118;
  static string events[$];

  static function void add(string what);
    events.push_back(what);
  endfunction
endclass

class driver118 extends uvm_driver #(uvm_sequence_item);
  `uvm_component_utils(driver118)
  int delivered;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    uvm_sequence_item item;
    forever begin
      seq_item_port.get_next_item(item);
      delivered++;
      log118::add("drive");
      seq_item_port.item_done();
    end
  endtask
endclass

class test_base118 extends uvm_test;
  uvm_sequencer #(uvm_sequence_item) sqr;
  driver118 drv;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sqr = new("sqr", this);
    drv = driver118::type_id::create("drv", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction

  virtual task run118();
  endtask

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    run118();
    phase.drop_objection(this);
  endtask
endclass
