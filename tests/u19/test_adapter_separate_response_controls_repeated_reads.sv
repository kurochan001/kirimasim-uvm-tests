/*
:name: test_adapter_separate_response_controls_repeated_reads
:description: separate response status and data override contradictory request state (IEEE 1800.2-2020 Section 19.2.1.2.3)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.2.1.2.3 19.2.1.2.6 19.2.1.2.5 19.2.1.2.7 14.1.2.4 15.5.2.5 18.2.5.2 18.4.4.9 18.4.4.10 18.4.4.3 18.2.3.6 18.1.2.1 18.1.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_adapter_separate_response_controls_repeated_reads.expected
*/
// The driver returns fresh response objects with copied routing IDs.
// Only response state is authoritative; failed read values are not asserted.
module test_adapter_separate_response_controls_repeated_reads;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class packet extends uvm_sequence_item;
    uvm_access_e kind;
    uvm_reg_addr_t address;
    uvm_reg_data_t data;
    int bits;
    uvm_reg_byte_en_t enables;
    uvm_status_e status;
    function new(string name="packet"); super.new(name); endfunction
  endclass
  class adapter_type extends uvm_reg_adapter;
    packet converted[$];
    bit outside = 1;
    function new(); super.new("adapter"); provides_responses = 1; endfunction
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
      packet item = new("request");
      item.kind = rw.kind; item.address = rw.addr; item.data = rw.data;
      item.bits = rw.n_bits; item.enables = rw.byte_en; item.status = UVM_IS_OK;
      return item;
    endfunction
    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
      packet item;
      if (!$cast(item, bus_item) || item == null) $fatal(1, "wrong response type");
      converted.push_back(item); outside &= get_item() == null;
      rw.kind = item.kind; rw.addr = item.address; rw.data = item.data;
      rw.n_bits = item.bits; rw.byte_en = item.enables; rw.status = item.status;
    endfunction
  endclass
  class model_block extends uvm_reg_block;
    function new(); super.new("blk", UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(); super.new("r", 8, UVM_NO_COVERAGE); endfunction
  endclass
  class bus_driver extends uvm_driver#(packet);
    packet requests[$], responses[$];
    uvm_reg_data_t storage[uvm_reg_addr_t];
    uvm_status_e next_status = UVM_IS_OK;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      packet request, response;
      forever begin
        seq_item_port.get_next_item(request); #2;
        requests.push_back(request);
        response = new("response"); response.set_id_info(request);
        response.kind = request.kind; response.address = request.address;
        response.bits = request.bits; response.enables = request.enables;
        response.status = next_status;
        if (request.kind == UVM_WRITE && next_status == UVM_IS_OK)
          storage[request.address] = request.data;
        response.data = storage.exists(request.address) ? storage[request.address] : 0;
        // Deliberately contradictory request state detects in-place reuse.
        request.status = next_status == UVM_IS_OK ? UVM_NOT_OK : UVM_IS_OK;
        request.data = 'hee;
        responses.push_back(response); seq_item_port.item_done(response);
      end
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    model_block blk;
    model_reg rg; uvm_reg_field field;
    uvm_reg_map mapping;
    adapter_type adapter;
    uvm_sequencer#(packet) sequencer;
    bus_driver driver;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      blk = new(); blk.configure();
      rg = new(); rg.configure(blk); field = new("value");
      field.configure(rg, 8, 0, "RW", 0, 'h11, 1, 0, 1);
      mapping = blk.create_map("bus", 0, 1, UVM_LITTLE_ENDIAN);
      mapping.add_reg(rg, 'h20);
      sequencer = new("sequencer", this); adapter = new(); driver = new("driver", this);
      mapping.set_sequencer(sequencer, adapter); mapping.set_auto_predict(1);
      blk.lock_model(); blk.reset();
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    function bit exact_responses();
      if (adapter.converted.size() != driver.responses.size()) return 0;
      foreach (adapter.converted[i])
        if (adapter.converted[i] != driver.responses[i] ||
            adapter.converted[i] == driver.requests[i]) return 0;
      return adapter.outside;
    endfunction
    task run_phase(uvm_phase phase);
      uvm_status_e status;
      uvm_reg_data_t value;
      phase.raise_objection(this);
      driver.storage['h20] = 'h42;
      rg.read(status, value, UVM_FRONTDOOR, mapping);
      $display("UT: first ok %0d value %0h mirror %0h", status == UVM_IS_OK,
               value, rg.get_mirrored_value());
      driver.storage['h20] = 'h73;
      rg.read(status, value, UVM_FRONTDOOR, mapping);
      $display("UT: second ok %0d value %0h mirror %0h fresh %0d", status == UVM_IS_OK,
               value, rg.get_mirrored_value(), driver.responses[0] != driver.responses[1]);
      $display("UT: converted %0d exact_responses %0d", adapter.converted.size(),
               exact_responses());
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "separate-response watchdog expired"); end
endmodule
