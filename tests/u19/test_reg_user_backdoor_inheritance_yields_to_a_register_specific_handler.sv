/*
:name: test_reg_user_backdoor_inheritance_yields_to_a_register_specific_handler
:description: reg user backdoor inheritance yields to a register specific handler (IEEE 1800.2-2020 Section 19.5.2.7)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.5.2.7 18.4.6.1 18.4.6.2 18.1.6.3 18.4.4.12 19.5.1 19.5.2.1 19.5.2.2 19.5.2.3 19.5.2.4 19.5.2.5 19.5.2.6 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.4.2.1 18.4.2.2 18.5.3.2 18.2.3.3 1800-2023 6.21 8.19
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_user_backdoor_inheritance_yields_to_a_register_specific_handler.expected
*/
// Without a local handler the register uses its block backdoor. A local handler
// then takes precedence for subsequent peeks.

module test_reg_user_backdoor_inheritance_yields_to_a_register_specific_handler;
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
    model_reg rg;
    uvm_reg_field field;
    uvm_reg_map mapping;
    storage_backdoor bkdr;
    storage_backdoor local_bkdr;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      blk = new();
      blk.configure();
      rg = new();
      rg.configure(blk);
      field = new("value");
      field.configure(rg, 8, 0, "RW", 0, 'h11, 1, 0, 1);
      mapping = blk.create_map("bus", 0, 1, UVM_LITTLE_ENDIAN);
      mapping.add_reg(rg, 'h20);
      bkdr = new();
      local_bkdr = new("local_backdoor");
      blk.set_backdoor(bkdr);
      blk.lock_model();
      blk.reset();
    endfunction
    task run_phase(uvm_phase phase);
      uvm_status_e status;
      uvm_reg_data_t value;
      phase.raise_objection(this);
      bkdr.storage[0] = 'hbc;
      local_bkdr.storage[0] = 'h77;
      rg.peek(status, value);
      $display("UT: inherited_ok %0d value %0h inherited %0d", status == UVM_IS_OK,
               value, rg.get_backdoor() == bkdr);
      rg.set_backdoor(local_bkdr);
      rg.peek(status, value);
      $display("UT: local_ok %0d value %0h selected %0d reads %0d %0d", status == UVM_IS_OK,
               value, rg.get_backdoor() == local_bkdr, bkdr.reads, local_bkdr.reads);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "user backdoor watchdog expired"); end
endmodule
