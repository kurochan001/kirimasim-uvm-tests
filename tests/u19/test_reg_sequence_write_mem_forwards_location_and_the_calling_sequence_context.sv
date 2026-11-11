/*
:name: test_reg_sequence_write_mem_forwards_location_and_the_calling_sequence_context
:description: convenience write_mem forwards location and calling sequence context (IEEE 1800.2-2020 Section 19.4.1.5.7)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.4.1.5.7 18.6.5.1 19.4.1.1 19.4.1.2 19.4.1.4.2 19.4.1.5 19.1.1.2.2 19.1.1.2.5 19.1.1.2.8 19.1.1.2.9 19.1.1.2.10 19.1.1.2.11 19.1.1.2.12 19.1.1.2.13 19.2.1.2.5 19.2.1.2.6 19.2.1.2.7 19.5.2.2 19.5.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 18.2.5.2 18.4.4.3 6.6.3.2 6.6.5 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_sequence_write_mem_forwards_location_and_the_calling_sequence_context.expected
*/
// What it checks:
// 1. write_mem sends data to the selected memory location.
// 2. The write_mem convenience method supplies the calling sequence as parent
//    and forwards explicit transaction metadata.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 19.4.1.5.7 (UVM-REG-SEQUENCE-WRITE-MEM) gives rule 1 above.
//    Setup: Write a5 hex at offset two through the map. Expected: Status is OK
//    and storage at physical address 42 hex contains a5.
// 2. 1800.2-2020 19.4.1.5.7 (UVM-REG-SEQUENCE-WRITE-MEM-CALL-CONTEXT) gives
//    rule 2 above. Setup: Observe the adapter item or user-backdoor item for
//    the access. Expected: Every observed item has the exact parent, element
//    and extension; frontdoor items retain map/priority 23, backdoor items
//    retain GATE kind, and memory items retain the selected offset.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Run the default specialization as a virtual test sequence without a
// sequencer. Maps supply the delayed bus; user backdoors model storage.
// Observe the implicit parent plus explicit metadata without RTL or DPI.
module test_reg_sequence_write_mem_forwards_location_and_the_calling_sequence_context;
  import uvm_pkg::*;

  `include "uvm_macros.svh"
  class token extends uvm_object;
    function new(); super.new("extension"); endfunction
  endclass
  class context_probe;
    uvm_sequence_base expected_parent;
    uvm_object expected_element;
    uvm_object expected_extension;
    uvm_reg_map expected_map;
    uvm_reg_addr_t expected_offset = 0;
    bit backdoor = 0;
    bit memory_access = 0;
    int calls = 0;
    bit matched = 1;
    function void observe(uvm_reg_item rw);
      calls++;
      if (rw == null) begin matched = 0; return; end
      matched &= rw.get_parent_sequence() == expected_parent &&
      rw.get_element() == expected_element && rw.get_extension() == expected_extension;
      matched &= rw.get_door() == (backdoor ? UVM_BACKDOOR : UVM_FRONTDOOR);
      if (backdoor) matched &= rw.get_bd_kind() == "GATE";
      else matched &= rw.get_map() == expected_map && rw.get_priority() == 23;
      if (memory_access) matched &= rw.get_offset() == expected_offset;
    endfunction
  endclass
  class error_probe extends uvm_report_catcher;
    int errors = 0;
    function new(); super.new("error_probe"); endfunction
    function action_e catch();
      if (get_severity() == UVM_ERROR) begin errors++; return CAUGHT; end
      return THROW;
    endfunction
  endclass
  class model_block extends uvm_reg_block;
    function new(); super.new("blk", UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(); super.new("r", 8, UVM_NO_COVERAGE); endfunction
  endclass
  class model_mem extends uvm_mem;
    function new(); super.new("memory", 4, 8, "RW", UVM_NO_COVERAGE); endfunction
  endclass
  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    uvm_access_e kind;
    uvm_reg_addr_t address;
    uvm_reg_data_t data;
    function new(string name="packet"); super.new(name); endfunction
  endclass
  class adapter_type extends uvm_reg_adapter;
    context_probe audit;
    function new(); super.new("adapter"); endfunction
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
      packet item = new(); audit.observe(get_item());
      item.kind = rw.kind; item.address = rw.addr; item.data = rw.data; return item;
    endfunction
    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
      packet item;
      if (!$cast(item, bus_item)) $fatal(1, "wrong packet type");
      rw.kind = item.kind; rw.addr = item.address; rw.data = item.data; rw.status = UVM_IS_OK;
    endfunction
  endclass
  class bus_driver extends uvm_driver#(packet);
    uvm_reg_data_t storage[uvm_reg_addr_t];
    uvm_reg_addr_t last_address = 0;
    int reads = 0;
    int writes = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      packet request;
      forever begin
        seq_item_port.get_next_item(request); #2; last_address = request.address;
        if (request.kind == UVM_WRITE) begin writes++; storage[request.address] = request.data; end
        else begin reads++;
        request.data = storage.exists(request.address) ? storage[request.address] : 0; end
        seq_item_port.item_done();
      end
    endtask
  endclass
  class storage_backdoor extends uvm_reg_backdoor;
    context_probe audit;
    uvm_reg_data_t storage = 'h11;
    int reads = 0;
    int writes = 0;
    function new(); super.new("backdoor"); endfunction
    virtual task read(uvm_reg_item rw);
      do_pre_read(rw); audit.observe(rw); reads++; #1;
      rw.set_value(storage); rw.set_status(UVM_IS_OK); do_post_read(rw);
    endtask
    virtual task write(uvm_reg_item rw);
      do_pre_write(rw); audit.observe(rw); writes++; #1;
      storage = rw.get_value(0); rw.set_status(UVM_IS_OK); do_post_write(rw);
    endtask
  endclass
  class accessor_sequence extends uvm_reg_sequence;
    model_reg rg;
    model_mem memory;
    uvm_reg_map mapping;
    token extension;
    context_probe audit;
    bus_driver driver;
    storage_backdoor bkdr;
    error_probe probe;
    function new(); super.new("accessor"); endfunction
    virtual task body();
      uvm_status_e status;
      uvm_reg_data_t value;
      int before_errors;

      write_mem(memory, status, 2, 'ha5, UVM_FRONTDOOR, mapping, 23, extension);
      $display("UT: memory_write ok %0d stored %0h address %0h", status == UVM_IS_OK,
      driver.storage['h42], driver.last_address);
      $display("UT: context calls %0d matched %0d writes %0d", audit.calls, audit.matched,
      driver.writes);

    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    model_block blk;
    model_reg rg;
    model_mem memory;
    uvm_reg_field field;
    uvm_reg_map mapping;
    adapter_type adapter;
    uvm_sequencer#(packet) sequencer;
    bus_driver driver;
    storage_backdoor bkdr;
    accessor_sequence sequence_value;
    context_probe audit;
    token extension;
    error_probe probe;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      blk = new(); blk.configure(); rg = new(); rg.configure(blk);
      field = new("value"); field.configure(rg, 8, 0, "RW", 0, 'h11, 1, 0, 1);
      memory = new(); memory.configure(blk);
      mapping = blk.create_map("bus", 0, 1, UVM_LITTLE_ENDIAN);
      mapping.add_reg(rg, 'h20); mapping.add_mem(memory, 'h40);
      sequencer = new("sequencer", this); driver = new("driver", this);
      audit = new(); adapter = new(); adapter.audit = audit;
      bkdr = new(); bkdr.audit = audit; rg.set_backdoor(bkdr);
      mapping.set_sequencer(sequencer, adapter); mapping.set_auto_predict(1);
      blk.lock_model(); blk.reset();
      extension = new(); probe = new(); sequence_value = new();
      sequence_value.model = blk; sequence_value.rg = rg; sequence_value.memory = memory;
      sequence_value.mapping = mapping; sequence_value.extension = extension;
      sequence_value.audit = audit; sequence_value.driver = driver;
      sequence_value.bkdr = bkdr; sequence_value.probe = probe;
      audit.expected_parent = sequence_value; audit.expected_element = memory;
      audit.expected_extension = extension; audit.expected_map = mapping;
      audit.backdoor = 0; audit.memory_access = 1; audit.expected_offset = 2;
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      uvm_report_cb::add(null, probe);
      sequence_value.start(null);
      uvm_report_cb::delete(null, probe);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "register convenience watchdog expired"); end

endmodule
