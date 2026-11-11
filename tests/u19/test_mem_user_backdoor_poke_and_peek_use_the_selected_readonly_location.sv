/*
:name: test_mem_user_backdoor_poke_and_peek_use_the_selected_readonly_location
:description: mem user backdoor poke and peek use the selected readonly location (IEEE 1800.2-2020 Section 19.5.2.6)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.5.2.6 19.5.2.7 18.6.5.5 18.6.5.6 19.5.1 19.5.2.1 19.5.2.2 19.5.2.3 19.5.2.4 19.5.2.5 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.6.3.1 18.6.3.2 18.6.7.2 18.2.3.4 1800-2023 6.21 8.19
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_mem_user_backdoor_poke_and_peek_use_the_selected_readonly_location.expected
*/
// What it checks:
// 1. Memory poke deposits the supplied value as-is at the selected location.
// 2. Memory peek returns the selected stored value.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.6.5.5 (UVM-MEMORY-BACKDOOR-POKE) gives rule 1 above.
//    Setup: Use explicit locations in a read-only memory with a user backdoor.
//    Expected: Read-only storage takes a6 while its neighboring location stays
//    33.
// 2. 1800.2-2020 18.6.5.6 (UVM-MEMORY-BACKDOOR-PEEK) gives rule 2 above.
//    Setup: Use explicit locations in a read-only memory with a user backdoor.
//    Expected: The selected peek succeeds and returns a6.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Memory poke/peek use the selected location without enforcing the read-only
// physical access policy. The memory keeps no per-location UVM mirror.

module test_mem_user_backdoor_poke_and_peek_use_the_selected_readonly_location;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class model_block extends uvm_reg_block;
    function new(); super.new("blk", UVM_NO_COVERAGE); endfunction
  endclass

  class storage_backdoor extends uvm_reg_backdoor;
    uvm_reg_data_t storage[uvm_reg_addr_t];
    uvm_status_e response_status = UVM_IS_OK;
    int reads = 0;
    int writes = 0;
    function new(string name="backdoor"); super.new(name); endfunction
    virtual task read(uvm_reg_item rw);
      uvm_reg_addr_t location;
      do_pre_read(rw);
      reads++;
      location = rw.get_element_kind() == UVM_MEM ? rw.get_offset() : 0;
      #1;
      if (response_status == UVM_IS_OK)
        rw.set_value(storage.exists(location) ? storage[location] : 0);
      rw.set_status(response_status);
      do_post_read(rw);
    endtask
    virtual task write(uvm_reg_item rw);
      uvm_reg_addr_t location;
      do_pre_write(rw);
      writes++;
      location = rw.get_element_kind() == UVM_MEM ? rw.get_offset() : 0;
      #1;
      if (response_status == UVM_IS_OK) storage[location] = rw.get_value(0);
      rw.set_status(response_status);
      do_post_write(rw);
    endtask
  endclass
  class model_reg extends uvm_reg;
    function new(); super.new("r", 8, UVM_NO_COVERAGE); endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    model_block blk;
    uvm_mem mem;
    uvm_reg_map mapping;
    storage_backdoor bkdr;
    storage_backdoor local_bkdr;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      blk = new();
      blk.configure();
      mem = new("mem", 16, 8, "RO", UVM_NO_COVERAGE);
      mem.configure(blk);
      mapping = blk.create_map("bus", 0, 1, UVM_LITTLE_ENDIAN);
      mapping.add_mem(mem, 'h20);
      bkdr = new();
      local_bkdr = new("local_backdoor");
      mem.set_backdoor(bkdr);
      blk.lock_model();
      blk.reset();
    endfunction
    task run_phase(uvm_phase phase);
      uvm_status_e status;
      uvm_reg_data_t value;
      phase.raise_objection(this);
      bkdr.storage[4] = 'h33;
      mem.poke(status, 5, 'ha6);
      $display("UT: poke_ok %0d stored %0h neighbor %0h", status == UVM_IS_OK,
               bkdr.storage[5], bkdr.storage[4]);
      mem.peek(status, 5, value);
      $display("UT: peek_ok %0d value %0h", status == UVM_IS_OK, value);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "user backdoor watchdog expired"); end
endmodule
