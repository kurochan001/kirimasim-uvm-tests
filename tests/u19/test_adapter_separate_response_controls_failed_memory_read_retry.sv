/*
:name: test_adapter_separate_response_controls_failed_memory_read_retry
:description: separate response status and data override contradictory request state (IEEE 1800.2-2020 Section 19.2.1.2.3)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.2.1.2.3 19.2.1.2.6 19.2.1.2.5 19.2.1.2.7 14.1.2.4 15.5.2.5 18.2.5.2 18.6.5.2 18.6.3.1 18.6.3.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_adapter_separate_response_controls_failed_memory_read_retry.expected
*/
// What it checks:
// 1. With provides_responses selected, the register layer consumes the
//    separate driver response.
// 2. bus2reg is given the separate response object for the selected response
//    path.
// 3. get_item returns null during response-side bus2reg conversion.
// 4. A failed separate memory response is returned as a failed read status.
// 5. A subsequent memory read returns data from its fresh response at the new
//    location.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 19.2.1.2.3 (UVM-ADAPTER-SEPARATE-FAILED-MEMORY-READ-RETRY)
//    gives rule 1 above. Setup: A failed memory read at offset 3 precedes a
//    successful read at offset 9. Expected: The failed response produces
//    failure; the fresh successful response returns 0x9c.
// 2. 1800.2-2020 19.2.1.2.6 (UVM-ADAPTER-BUS2REG-SEPARATE-IDENTITY) gives rule
//    2 above. Setup: Four write/read/retry fixtures capture original request,
//    returned response and converted object handles. Expected: Each converted
//    object is the exact returned response and differs from its request.
// 3. 1800.2-2020 19.2.1.2.7
//    (UVM-ADAPTER-GET-ITEM-NULL-DURING-SEPARATE-BUS2REG) gives rule 3 above.
//    Setup: The adapter queries get_item in every bus2reg call across the four
//    separate-response fixtures. Expected: All conversion-time queries are
//    null.
// 4. 1800.2-2020 18.6.5.2 (UVM-SEPARATE-RESPONSE-MEMORY-FAILURE-STATUS) gives
//    rule 4 above. Setup: Offset 3 receives NOT_OK in the response while the
//    request says IS_OK. Expected: The first read reports failure without
//    constraining its undefined returned data.
// 5. 1800.2-2020 18.6.5.2 (UVM-SEPARATE-RESPONSE-MEMORY-RETRY-DATA) gives rule
//    5 above. Setup: After a failed offset-3 read, offset 9 contains 0x9c.
//    Expected: The second read succeeds at bus address 0x29 and returns 0x9c.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The driver returns fresh response objects with copied routing IDs.
// Only response state is authoritative; failed read values are not asserted.
module test_adapter_separate_response_controls_failed_memory_read_retry;
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
    uvm_mem mem;
    uvm_reg_map mapping;
    adapter_type adapter;
    uvm_sequencer#(packet) sequencer;
    bus_driver driver;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      blk = new(); blk.configure();
      mem = new("mem", 16, 8, "RW", UVM_NO_COVERAGE); mem.configure(blk);
      mapping = blk.create_map("bus", 0, 1, UVM_LITTLE_ENDIAN, 1);
      mapping.add_mem(mem, 'h20);
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
      driver.storage['h23] = 'h42; driver.storage['h29] = 'h9c;
      driver.next_status = UVM_NOT_OK;
      mem.read(status, 3, value, UVM_FRONTDOOR, mapping);
      $display("UT: failed %0d address %0h", status == UVM_NOT_OK,
               driver.requests[0].address);
      driver.next_status = UVM_IS_OK;
      mem.read(status, 9, value, UVM_FRONTDOOR, mapping);
      $display("UT: retry ok %0d value %0h address %0h fresh %0d", status == UVM_IS_OK,
               value, driver.requests[1].address, driver.responses[0] != driver.responses[1]);
      $display("UT: converted %0d exact_responses %0d", adapter.converted.size(),
               exact_responses());
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "separate-response watchdog expired"); end
endmodule
