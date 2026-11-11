/*
:name: test_coverage_failed_write_does_not_sample_block_until_successful_retry
:description: failed writes do not sample the block before a successful retry (IEEE 1800.2-2020 Section 18.1.4.6)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.4.6 18.4.7.7 18.4.4.9 18.2.3.6 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_coverage_failed_write_does_not_sample_block_until_successful_retry.expected
*/
// What it checks:
// A rejected write does not sample the block; its successful retry does.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.1.4.6 (UVM-BLOCK-SAMPLE-SUCCESS-QUALIFIER) gives the rule
// above. Setup: Reject one write without committing storage, then retry
// successfully. Expected: Failure leaves zero block samples and an unchanged
// mirror/storage; retry produces one block/register sample and value 5a.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe coverage-control metadata and testbench sampling hooks only.
// These counters are not covergroups, bin coverage or a coverage percentage.
module test_coverage_failed_write_does_not_sample_block_until_successful_retry;
  import uvm_pkg::*;

  `include "uvm_macros.svh"
  int completed_bus_operations = 0;
  class model_reg extends uvm_reg;
    uvm_reg_field field;
    int samples = 0;
    int value_samples = 0;
    uvm_reg_data_t seen_data;
    uvm_reg_data_t seen_byte_en;
    uvm_reg_data_t mirror_before;
    bit seen_read;
    uvm_reg_map seen_map;
    int completed_at_sample;
    function new(string name="r", uvm_reg_cvr_t available=UVM_CVR_REG_BITS | UVM_CVR_FIELD_VALS);
      super.new(name, 8, available);
    endfunction
    function void build();
      field = new("value"); field.configure(this, 8, 0, "RW", 0, 0, 1, 0, 1);
    endfunction
    protected virtual function void sample(uvm_reg_data_t data, uvm_reg_data_t byte_en,
    bit is_read, uvm_reg_map map);
      samples++; seen_data = data; seen_byte_en = byte_en; seen_read = is_read;
      seen_map = map; mirror_before = get_mirrored_value();
      completed_at_sample = completed_bus_operations;
    endfunction
    virtual function void sample_values(); value_samples++; endfunction
  endclass
  class model_mem extends uvm_mem;
    int samples = 0;
    int reads = 0;
    int writes = 0;
    bit all_completed = 1;
    bit same_map = 1;
    uvm_reg_map expected_map;
    function new(string name="memory", uvm_reg_cvr_t available=UVM_CVR_ADDR_MAP);
      super.new(name, 4, 8, "RW", available);
    endfunction
    protected virtual function void sample(uvm_reg_addr_t offset, bit is_read, uvm_reg_map map);
      samples++; if (is_read) reads++; else writes++;
      all_completed &= completed_bus_operations >= samples;
      same_map &= map == expected_map;
    endfunction
  endclass
  class model_block extends uvm_reg_block;
    int samples = 0;
    int value_samples = 0;
    uvm_reg_addr_t offsets[$];
    bit directions[$];
    uvm_reg_map maps[$];
    function new(string name="blk", uvm_reg_cvr_t available=UVM_CVR_ADDR_MAP);
      super.new(name, available);
    endfunction
    protected virtual function void sample(uvm_reg_addr_t offset, bit is_read, uvm_reg_map map);
      samples++; offsets.push_back(offset); directions.push_back(is_read); maps.push_back(map);
    endfunction
    virtual function void sample_values(); value_samples++; super.sample_values(); endfunction
  endclass

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    uvm_access_e kind;
    uvm_reg_addr_t address;
    uvm_reg_data_t data;
    uvm_status_e status = UVM_IS_OK;
    function new(string name="packet"); super.new(name); endfunction
  endclass
  class adapter_type extends uvm_reg_adapter;
    function new(); super.new("adapter"); endfunction
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
      packet item = new(); item.kind = rw.kind; item.address = rw.addr; item.data = rw.data;
      return item;
    endfunction
    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
      packet item;
      if (!$cast(item, bus_item)) $fatal(1, "wrong packet type");
      rw.kind = item.kind; rw.addr = item.address; rw.data = item.data; rw.status = item.status;
    endfunction
  endclass
  class bus_driver extends uvm_driver#(packet);
    uvm_reg_data_t storage[uvm_reg_addr_t];
    uvm_reg_addr_t addresses[$];
    bit reject = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      packet request;
      forever begin
        seq_item_port.get_next_item(request); #2;
        addresses.push_back(request.address);
        request.status = reject ? UVM_NOT_OK : UVM_IS_OK;
        if (!reject) begin
          if (request.kind == UVM_WRITE) storage[request.address] = request.data;
          else request.data = storage.exists(request.address) ? storage[request.address] : 0;
        end
        completed_bus_operations++;
        seq_item_port.item_done();
      end
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    model_block blk;
    model_reg rg;
    model_reg other;
    model_mem memory;
    uvm_reg_map mapping;
    adapter_type adapter;
    uvm_sequencer#(packet) sequencer;
    bus_driver driver;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      blk = new(); blk.configure();
      rg = new(); rg.configure(blk); rg.build();
      other = new("other"); other.configure(blk); other.build();
      memory = new(); memory.configure(blk);
      mapping = blk.create_map("bus", 'h100, 1, UVM_LITTLE_ENDIAN);
      mapping.add_reg(rg, 'h20); mapping.add_reg(other, 'h30); mapping.add_mem(memory, 'h40);
      memory.expected_map = mapping;
      sequencer = new("sequencer", this); driver = new("driver", this); adapter = new();
      mapping.set_sequencer(sequencer, adapter); mapping.set_auto_predict(1);
      blk.lock_model(); blk.reset();
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      uvm_status_e status;
      uvm_reg_data_t value;
      phase.raise_objection(this);

      driver.reject = 1; rg.write(status, 'h5a, UVM_FRONTDOOR, mapping);
      $display("UT: rejected %0d block_samples %0d storage_absent %0d mirror %0h",
      status == UVM_NOT_OK, blk.samples, !driver.storage.exists('h120), rg.get_mirrored_value());
      driver.reject = 0; rg.write(status, 'h5a, UVM_FRONTDOOR, mapping);
      $display("UT: retry_ok %0d block_samples %0d register_samples %0d storage %0h mirror %0h",
      status == UVM_IS_OK, blk.samples, rg.samples, driver.storage['h120], rg.get_mirrored_value());

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "sampling watchdog expired"); end

endmodule
