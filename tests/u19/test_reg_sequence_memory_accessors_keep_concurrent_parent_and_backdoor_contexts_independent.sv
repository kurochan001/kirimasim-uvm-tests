/*
:name: test_reg_sequence_memory_accessors_keep_concurrent_parent_and_backdoor_contexts_independent
:description: independent virtual memory accessor sequences retain their own calling contexts (IEEE 1800.2-2020 Section 19.4.1.5.10)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.4.1.5.10 19.4.1.5.9 18.6.5.5 18.6.5.6 19.4.1.1 19.4.1.2 19.4.1.4.2 19.5.2.2 19.5.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 19.1.1.2.1 19.1.1.2.2 19.1.1.2.3 19.1.1.2.5 19.1.1.2.9 19.1.1.2.10 19.1.1.2.12 19.1.1.2.13 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_sequence_memory_accessors_keep_concurrent_parent_and_backdoor_contexts_independent.expected
*/
// What it checks:
// Independent concurrent accessor sequences retain their own parent, extension
// and backdoor contexts.
//
// How the expected output follows from the standard:
// 1800.2-2020 19.4.1.5.10 (UVM-REG-SEQUENCE-MEM-CONCURRENT-CONTEXT-ISOLATION)
// gives the rule above. Setup: Run two virtual sequences against distinct
// memories/backdoors at the same offset. Expected: Each has one read/write,
// exact independent context and its own 5aa5/3cc3 hex value.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Default register-sequence specialization used as a virtual test sequence.
// User backdoors model 16-bit memory locations with required pre/post hooks.
// No HDL/DPI, physical bus, memory mirror or failed-read data is asserted.
// Only explicit abstraction kinds are compared; default-kind resolution is
// open.
module test_reg_sequence_memory_accessors_keep_concurrent_parent_and_backdoor_contexts_independent;
  import uvm_pkg::*;

  `include "uvm_macros.svh"
  class token extends uvm_object;
    function new(string name="token"); super.new(name); endfunction
  endclass
  class model_block extends uvm_reg_block;
    function new(); super.new("blk", UVM_NO_COVERAGE); endfunction
  endclass
  class storage_backdoor extends uvm_reg_backdoor;
    uvm_reg_data_t storage[uvm_reg_addr_t];
    uvm_sequence_base expected_parent;
    uvm_mem expected_memory;
    uvm_object expected_extension;
    uvm_reg_addr_t expected_offset = 0;
    bit check_kind = 1;
    bit matched = 1;
    int reads = 0;
    int writes = 0;
    uvm_status_e response_status = UVM_IS_OK;
    function new(string name); super.new(name); endfunction
    function void observe(uvm_reg_item rw, uvm_access_e access_kind);
      matched &= rw.get_element_kind() == UVM_MEM && rw.get_element() == expected_memory;
      matched &= rw.get_parent_sequence() == expected_parent;
      matched &= rw.get_extension() == expected_extension && rw.get_offset() == expected_offset;
      matched &= rw.get_door() == UVM_BACKDOOR && rw.get_kind() == access_kind;
      if (check_kind) matched &= rw.get_bd_kind() == "GATE";
    endfunction
    virtual task read(uvm_reg_item rw);
      do_pre_read(rw); observe(rw, UVM_READ); reads++; #1;
      if (response_status == UVM_IS_OK)
        rw.set_value(storage.exists(rw.get_offset()) ? storage[rw.get_offset()] : 0);
      rw.set_status(response_status); do_post_read(rw);
    endtask
    virtual task write(uvm_reg_item rw);
      do_pre_write(rw); observe(rw, UVM_WRITE); writes++; #1;
      if (response_status == UVM_IS_OK) storage[rw.get_offset()] = rw.get_value(0);
      rw.set_status(response_status); do_post_write(rw);
    endtask
  endclass
  class accessor_sequence extends uvm_reg_sequence;
    uvm_mem memory;
    storage_backdoor bkdr;
    uvm_object extension;
    uvm_reg_data_t deposit_value = 'h5aa5;
    uvm_reg_data_t returned_value;
    function new(string name); super.new(name); endfunction
    virtual task body();
      uvm_status_e status;
      uvm_reg_data_t value;

      poke_mem(memory, status, 1, deposit_value, "GATE", extension);
      peek_mem(memory, status, 1, returned_value, "GATE", extension);

    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    model_block blk;
    uvm_mem memory;
    uvm_mem peer_memory;
    uvm_reg_map mapping;
    storage_backdoor bkdr;
    storage_backdoor peer_bkdr;
    accessor_sequence first;
    accessor_sequence peer;
    token extension;
    token peer_extension;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      blk = new(); blk.configure();
      memory = new("memory", 4, 16, "RW", UVM_NO_COVERAGE); memory.configure(blk);
      peer_memory = new("peer_memory", 4, 16, "RW", UVM_NO_COVERAGE); peer_memory.configure(blk);
      mapping = blk.create_map("bus", 0, 2, UVM_LITTLE_ENDIAN);
      mapping.add_mem(memory, 'h40); mapping.add_mem(peer_memory, 'h80);
      bkdr = new("backdoor"); peer_bkdr = new("peer_backdoor");
      memory.set_backdoor(bkdr); peer_memory.set_backdoor(peer_bkdr);
      blk.lock_model(); blk.reset();
      extension = new("extension"); peer_extension = new("peer_extension");
      first = new("first"); peer = new("peer");
      first.model = blk; first.memory = memory; first.bkdr = bkdr; first.extension = extension;
      peer.model = blk; peer.memory = peer_memory; peer.bkdr = peer_bkdr;
      peer.extension = peer_extension;
      peer.deposit_value = 'h3cc3;
      bkdr.expected_parent = first; bkdr.expected_memory = memory;
      bkdr.expected_extension = extension; bkdr.expected_offset = 1;
      peer_bkdr.expected_parent = peer; peer_bkdr.expected_memory = peer_memory;
      peer_bkdr.expected_extension = peer_extension; peer_bkdr.expected_offset = 1;
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);

      fork first.start(null); peer.start(null); join
      $display("UT: independent first %0h peer %0h", first.returned_value, peer.returned_value);
      $display("UT: first_context %0d peer_context %0d reads %0d %0d writes %0d %0d",
      bkdr.matched, peer_bkdr.matched, bkdr.reads, peer_bkdr.reads, bkdr.writes, peer_bkdr.writes);

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "memory convenience watchdog expired"); end

endmodule
