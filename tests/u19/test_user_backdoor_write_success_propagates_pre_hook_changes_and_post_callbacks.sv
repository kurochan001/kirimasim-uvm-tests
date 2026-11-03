/*
:name: test_user_backdoor_write_success_propagates_pre_hook_changes_and_post_callbacks
:description: user backdoor write success propagates pre hook changes and post callbacks (IEEE 1800.2-2020 Section 19.5.2.6)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.5.2.6 19.5.2.4 19.5.2.5 19.5.2.11 19.5.2.12 18.11.2.2 18.11.2.3 D.4.5.3 18.4.4.9 18.1.2.1 18.1.2.2 18.1.2.6 18.2.3.3 18.4.2.1 18.4.2.2 18.5.3.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_user_backdoor_write_success_propagates_pre_hook_changes_and_post_callbacks.expected
*/
// Invoke the original user write through public register access. Its first
// statement calls the standard protected pre helper and its last calls the
// post helper. Only original storage, callback order and propagated status are
// observed. No default base-write algorithm, physical HDL, access-modifier
// interpretation or encode/decode-array behavior is certified.
module test_user_backdoor_write_success_propagates_pre_hook_changes_and_post_callbacks;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  string trace = "";
  uvm_reg_item expected_item;
  uvm_object expected_element;
  bit identity_ok = 1, pre_ok = 1, body_ok = 1, post_ok = 1;
  class callback_probe extends uvm_reg_cbs;
    virtual task pre_write(uvm_reg_item rw);
      trace = {trace,"C"}; identity_ok &= rw == expected_item;
      pre_ok &= rw.get_value(0) == 'h23; rw.set_value(rw.get_value(0) ^ 3);
    endtask
    virtual task post_write(uvm_reg_item rw);
      trace = {trace,"c"}; identity_ok &= rw == expected_item;
      post_ok &= rw.get_value(0) == 'h20;
    endtask
  endclass
  class storage_backdoor extends uvm_reg_backdoor;
    uvm_reg_data_t storage = 'h55;
    bit fail_write = 0;
    int writes = 0;
    function new(); super.new("backdoor"); endfunction
    virtual function void read_func(uvm_reg_item rw);
      rw.set_value(storage); rw.set_status(UVM_IS_OK);
    endfunction
    virtual task pre_write(uvm_reg_item rw);
      trace = {trace,"W"}; expected_item = rw;
      identity_ok &= rw.get_element() == expected_element;
      rw.set_value(rw.get_value(0) + 'h10);
    endtask
    virtual task post_write(uvm_reg_item rw);
      trace = {trace,"w"}; identity_ok &= rw == expected_item;
      post_ok &= rw.get_value(0) == 'h20;
    endtask
    virtual task write(uvm_reg_item rw);
      do_pre_write(rw);
      trace = {trace,"B"}; writes++; identity_ok &= rw == expected_item;
      body_ok &= rw.get_value(0) == 'h20;
      if (!fail_write) storage = rw.get_value(0);
      rw.set_status(fail_write ? UVM_NOT_OK : UVM_IS_OK);
      do_post_write(rw);
    endtask
  endclass
  class model_block extends uvm_reg_block;
    function new(); super.new("block", UVM_NO_COVERAGE); endfunction
  endclass
  class model_register extends uvm_reg;
    function new(); super.new("reg_value", 8, UVM_NO_COVERAGE); endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    model_block block;
    model_register value;
    uvm_reg_field field_value;
    uvm_reg_map mapping;
    storage_backdoor backdoor;
    callback_probe callback_value;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase); block = new(); block.configure(); value = new();
      value.configure(block); field_value = new("field_value");
      field_value.configure(value, 8, 0, "RW", 0, 0, 1, 0, 1);
      mapping = block.create_map("map_value", 0, 1, UVM_LITTLE_ENDIAN);
      mapping.add_reg(value, 0); backdoor = new(); callback_value = new();
      value.set_backdoor(backdoor); block.lock_model(); block.reset();
      expected_element = value; uvm_reg_bd_cb::add(backdoor, callback_value);

    endfunction
    task run_phase(uvm_phase phase);
      uvm_status_e status;
      phase.raise_objection(this);
      value.write(status, 'h13, UVM_BACKDOOR, mapping);
      $display("UT: write_trace %s identity %0d pre %0d body %0d post %0d", trace,
               identity_ok, pre_ok, body_ok, post_ok);
      $display("UT: write_result ok %0d failed %0d stored %0h writes %0d", status == UVM_IS_OK,
               status == UVM_NOT_OK, backdoor.storage, backdoor.writes);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "write-hook watchdog expired"); end
endmodule
