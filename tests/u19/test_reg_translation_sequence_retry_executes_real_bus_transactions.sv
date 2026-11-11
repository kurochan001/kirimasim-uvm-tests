/*
:name: test_reg_translation_sequence_retry_executes_real_bus_transactions
:description: reg translation sequence retry executes real bus transactions (IEEE 1800.2-2020 Section 19.4.1.4.3)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.4.1.4.3 19.4.1.1 19.4.1.2 19.4.1.3.2 19.4.1.3.3 19.2.1.2.5 19.2.1.2.6 19.1.1.2.2 19.1.1.2.3 19.1.1.2.4 19.1.1.2.6 19.1.1.2.7 19.1.1.2.8 19.1.1.2.9 15.1.1 15.2.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_translation_sequence_retry_executes_real_bus_transactions.expected
*/
// What it checks:
// 1. A translation sequence uses a BASE compatible with its bus sequencer item
//    type.
// 2. Translated operation results propagate back to supplied register items
//    across a failed write and later retry.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 19.4.1.2 (UVM-REG-PIPELINE-BUS-COMPATIBLE-BASE) gives rule 1
//    above. Setup: Bind a register sequence over a packet sequence to the
//    actual packet bus sequencer. Expected: The delayed driver receives
//    correctly routed packet transfers and execution completes.
// 2. 1800.2-2020 19.4.1.4.3 (UVM-REG-PIPELINE-DIRECT-FAILURE-AND-RETRY) gives
//    rule 2 above. Setup: Fail the first original driver write, then perform a
//    read, successful retry write and read. Expected: The failed status is
//    preserved, the first read sees old storage and the second sees the
//    successful retry value.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Exercise real bus sequencer/driver handshakes and a configured standard
// translation sequence. An original XOR protocol makes selected adapter use
// observable. The layered case pulls actual upstream register items; direct
// cases invoke do_reg_item. Original storage/status are independent of any
// simulator implementation. No physical DUT, arbitration fairness, arbitrary
// width/endianness or required kill post-hook coverage is claimed.
module test_reg_translation_sequence_retry_executes_real_bus_transactions;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    uvm_access_e kind;
    uvm_reg_addr_t address;
    uvm_reg_data_t data;
    uvm_status_e status;
    function new(string name = "packet"); super.new(name); endfunction
  endclass
  class model_block extends uvm_reg_block;
    function new(); super.new("block",UVM_NO_COVERAGE); endfunction
  endclass
  class model_register extends uvm_reg;
    function new(); super.new("reg_value",8,UVM_NO_COVERAGE); endfunction
  endclass
  class operations;
    uvm_reg_item items[$];
    model_register element;
    uvm_reg_map mapping;
    function void append(uvm_access_e kind,uvm_reg_data_t value);
      automatic uvm_reg_item rw = new("operation");
      rw.set_element_kind(UVM_REG); rw.set_element(element); rw.set_kind(kind);
      rw.set_map(mapping); rw.set_local_map(mapping); rw.set_door(UVM_FRONTDOOR);
      rw.set_offset(0); rw.set_value(value); rw.set_status(UVM_IS_OK);
      items.push_back(rw);
    endfunction
  endclass
  class converter extends uvm_reg_adapter;
    int conversions = 0;
    uvm_reg_data_t mask = 'h5a;
    function new(); super.new("converter"); endfunction
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
      automatic packet item = new(); conversions++;
      item.kind = rw.kind; item.address = rw.addr; item.data = rw.data ^ mask;
      item.status = UVM_IS_OK; return item;
    endfunction
    virtual function void bus2reg(uvm_sequence_item value,ref uvm_reg_bus_op rw);
      packet item;
      if (!$cast(item,value) || item == null) $fatal(1,"wrong original packet");
      rw.kind = item.kind; rw.addr = item.address; rw.data = item.data ^ mask;
      rw.status = item.status; rw.n_bits = 8; rw.byte_en = 1;
    endfunction
  endclass
  class bus_driver extends uvm_driver#(packet);
    uvm_reg_data_t storage = 'h55;
    uvm_reg_data_t mask = 'h5a;
    bit fail_first_write = 0, routed = 1;
    int reads = 0,writes = 0;
    uvm_sequencer_base expected_sequencer;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    task run_phase(uvm_phase phase);
      packet request;
      forever begin
        seq_item_port.get_next_item(request); #2;
        routed &= request.get_sequencer() == expected_sequencer && request.address == 'h20;
        request.status = UVM_IS_OK;
        if (request.kind == UVM_WRITE) begin
          writes++;
          if (fail_first_write && writes == 1) request.status = UVM_NOT_OK;
          else storage = request.data ^ mask;
        end
        else begin reads++; request.data = storage ^ mask; end
        seq_item_port.item_done();
      end
    endtask
  endclass
  class translator_type extends uvm_reg_sequence#(uvm_sequence#(packet));
    operations control;
    function new(string name); super.new(name); endfunction
    virtual task body();
      foreach (control.items[i]) do_reg_item(control.items[i]);
    endtask
  endclass
  class producer_type extends uvm_sequence#(uvm_reg_item);
    operations control;
    virtual task body();
      foreach (control.items[i]) begin
        start_item(control.items[i]); finish_item(control.items[i]);
      end
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    model_block block;
    model_register value;
    uvm_reg_field field_value;
    uvm_reg_map mapping;
    converter adapter_value;
    uvm_sequencer#(packet) bus;
    uvm_sequencer#(uvm_reg_item) upstream;
    bus_driver driver;
    operations control;
    translator_type translation;
    producer_type producer;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase); block = new(); block.configure(); value = new();
      value.configure(block); field_value = new("field_value");
      field_value.configure(value,8,0,"RW",0,0,1,0,1);
      mapping = block.create_map("map_value",0,1,UVM_LITTLE_ENDIAN);
      mapping.add_reg(value,'h20); bus = new("bus",this);
      upstream = new("upstream",this); driver = new("driver",this);
      adapter_value = new(); driver.expected_sequencer = bus;
      mapping.set_sequencer(bus,adapter_value); block.lock_model(); block.reset();
      control = new(); control.element = value; control.mapping = mapping;
      control.append(UVM_WRITE,'h13); control.append(UVM_READ,0);
      control.append(UVM_WRITE,'h27); control.append(UVM_READ,0);
      driver.fail_first_write = 1;
      translation = new("translation"); translation.adapter = adapter_value;
      producer = new(); producer.control = control;
      translation.control = control;
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(bus.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      translation.start(bus);
      $display("UT: translation_retry failed %0d first_read %0h retry %0d second_read %0h",
               control.items[0].get_status() == UVM_NOT_OK,control.items[1].get_value(0),
               control.items[2].get_status() == UVM_IS_OK,control.items[3].get_value(0));
      $display("UT: translation_bus writes %0d reads %0d stored %0h conversions %0d routed %0d",
               driver.writes,driver.reads,driver.storage,adapter_value.conversions,driver.routed);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1,"translation watchdog expired"); end
endmodule
