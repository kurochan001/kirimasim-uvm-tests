/*
:name: test_reg_tlm_adapter_frontdoor_reads_use_fresh_payloads_and_operation_context
:description: standard TLM adapter integrates with the frontdoor driver and scoped operation context (IEEE 1800.2-2020 Section 19.2.1.2.7)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.2.1.2.7 19.2.2.2.1 19.2.2.2.2 19.1.2.2 19.1.2.3 19.1.2.6 18.4.4.10 18.2.5.2 18.2.3.3 18.2.3.6 18.4.4.3 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 18.5.3.2 19.1.1.2.2 19.1.1.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_tlm_adapter_frontdoor_reads_use_fresh_payloads_and_operation_context.expected
*/
// What it checks:
// 1. The standard-adapter extension sees the abstract read context during
//    reg2bus.
// 2. get_item is null during bus2reg and after the operation.
// 3. The frontdoor sends the fresh objects returned by standard reg2bus to the
//    driver.
// 4. Frontdoor reads through the standard TLM adapter return driver response
//    data.
// 5. Auto-prediction updates mirrors from standard-adapter reads.
// 6. The physical payload address corresponds to the mapped register.
// 7. A generic frontdoor read produces a TLM READ payload.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 19.2.1.2.7 (UVM-TLM-ADAPTER-FRONTDOOR-CONTEXT) gives rule 1
//    above. Setup: A sixteen-bit model uses the standard adapter, in-place
//    driver responses and a two-byte map. Expected: Context is non-null,
//    identifies the model register and has READ kind.
// 2. 1800.2-2020 19.2.1.2.7 (UVM-TLM-ADAPTER-FRONTDOOR-OUTSIDE-CONTEXT) gives
//    rule 2 above. Setup: A sixteen-bit model uses the standard adapter,
//    in-place driver responses and a two-byte map. Expected: Every
//    response-side and outside query returns null.
// 3. 1800.2-2020 19.2.2.2.1 (UVM-TLM-ADAPTER-FRONTDOOR-PAYLOAD-IDENTITY) gives
//    rule 3 above. Setup: A sixteen-bit model uses the standard adapter,
//    in-place driver responses and a two-byte map. Expected: Two distinct
//    generated handles match the two received payload handles.
// 4. 1800.2-2020 18.4.4.10 (UVM-TLM-ADAPTER-FRONTDOOR-READ-DATA) gives rule 4
//    above. Setup: A sixteen-bit model uses the standard adapter, in-place
//    driver responses and a two-byte map. Expected: Reads succeed with 0x3c3c
//    then 0x9292.
// 5. 1800.2-2020 18.2.5.2 (UVM-TLM-ADAPTER-FRONTDOOR-PREDICTION) gives rule 5
//    above. Setup: A sixteen-bit model uses the standard adapter, in-place
//    driver responses and a two-byte map. Expected: Mirrors become 0x3c3c then
//    0x9292.
// 6. 1800.2-2020 19.1.2.2 (UVM-TLM-ADAPTER-FRONTDOOR-ADDRESS) gives rule 6
//    above. Setup: A sixteen-bit model uses the standard adapter, in-place
//    driver responses and a two-byte map. Expected: Both requests use address
//    0x20.
// 7. 1800.2-2020 19.2.2.2.1 (UVM-TLM-ADAPTER-FRONTDOOR-COMMAND) gives rule 7
//    above. Setup: A sixteen-bit model uses the standard adapter, in-place
//    driver responses and a two-byte map. Expected: Both received payloads
//    identify READ.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The standard adapter performs conversions; the original driver supplies
// uniform response bytes in place. No HDL storage or byte-order assumption
// is introduced, and get_item is queried only through its public API.
module test_reg_tlm_adapter_frontdoor_reads_use_fresh_payloads_and_operation_context;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class adapter_type extends uvm_reg_tlm_adapter;
    uvm_object expected_element;
    uvm_sequence_item generated[$];
    bit context_ok = 1, outside_ok = 1;
    int conversions = 0;
    function new();
      super.new("adapter"); provides_responses = 0; supports_byte_enable = 1;
    endfunction
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
      uvm_reg_item context_item;
      uvm_sequence_item item;
      context_item = get_item();
      if (context_item == null) context_ok = 0;
      else context_ok &= context_item.get_element() == expected_element &&
                         context_item.get_kind() == UVM_READ;
      item = super.reg2bus(rw); generated.push_back(item); return item;
    endfunction
    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
      outside_ok &= get_item() == null; conversions++; super.bus2reg(bus_item, rw);
    endfunction
  endclass
  class model_block extends uvm_reg_block;
    function new(); super.new("blk", UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(); super.new("r", 16, UVM_NO_COVERAGE); endfunction
  endclass
  class bus_driver extends uvm_driver#(uvm_tlm_gp);
    uvm_tlm_gp requests[$];
    byte unsigned next_value = 'h3c;
    bit read_commands = 1, addresses = 1;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      uvm_tlm_gp item;
      byte unsigned bytes[];
      forever begin
        seq_item_port.get_next_item(item); #2;
        requests.push_back(item); read_commands &= item.is_read();
        addresses &= item.get_address() == 'h20;
        bytes = new[2]; bytes[0] = next_value; bytes[1] = next_value;
        item.set_data(bytes); item.set_response_status(UVM_TLM_OK_RESPONSE);
        seq_item_port.item_done();
      end
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    model_block blk;
    model_reg rg;
    uvm_reg_field field;
    uvm_reg_map mapping;
    adapter_type adapter;
    uvm_sequencer#(uvm_tlm_gp) sequencer;
    bus_driver driver;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      blk = new(); blk.configure(); rg = new(); rg.configure(blk);
      field = new("value"); field.configure(rg, 16, 0, "RW", 0, 'h1122, 1, 0, 1);
      mapping = blk.create_map("bus", 0, 2, UVM_LITTLE_ENDIAN); mapping.add_reg(rg, 'h20);
      adapter = new(); adapter.expected_element = rg;
      sequencer = new("sequencer", this); driver = new("driver", this);
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
      rg.read(status, value, UVM_FRONTDOOR, mapping);
      $display("UT: first ok %0d value %0h mirror %0h", status == UVM_IS_OK,
               value, rg.get_mirrored_value());
      driver.next_value = 'h92; rg.read(status, value, UVM_FRONTDOOR, mapping);
      $display("UT: second ok %0d value %0h mirror %0h", status == UVM_IS_OK,
               value, rg.get_mirrored_value());
      $display("UT: requests %0d conversions %0d fresh %0d identity %0d",
               driver.requests.size(), adapter.conversions,
               adapter.generated[0] != adapter.generated[1],
               adapter.generated[0] == driver.requests[0] &&
               adapter.generated[1] == driver.requests[1]);
      $display("UT: context %0d outside %0d read_commands %0d addresses %0d",
               adapter.context_ok, adapter.outside_ok && adapter.get_item() == null,
               driver.read_commands, driver.addresses);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "TLM-adapter frontdoor watchdog expired"); end
endmodule
