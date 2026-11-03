/*
:name: test_reg_virtual_sequence_model_selects_the_accessed_block_without_a_sequencer
:description: reg virtual sequence model selects the accessed block without a sequencer (IEEE 1800.2-2020 Section 19.4.1.3.1)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.4.1.3.1 19.4.1.1 19.4.1.2 19.4.1.5.1 19.4.1.5.2 18.1.3.14 19.5.2.6 19.5.2.7 19.5.2.8 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_virtual_sequence_model_selects_the_accessed_block_without_a_sequencer.expected
*/
// The user-defined body obtains its target from the public model property and
// uses real convenience APIs and independent user-backed registers. The same
// default-BASE sequence runs virtually on two selected blocks. Model selection
// is original body logic, not an automatic library discovery algorithm; no
// physical HDL, body translation, factory creation or active reconfiguration
// is asserted.
module test_reg_virtual_sequence_model_selects_the_accessed_block_without_a_sequencer;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class model_block extends uvm_reg_block;
    function new(string name); super.new(name,UVM_NO_COVERAGE); endfunction
  endclass
  class model_register extends uvm_reg;
    function new(); super.new("reg_value",8,UVM_NO_COVERAGE); endfunction
  endclass
  class storage_backdoor extends uvm_reg_backdoor;
    uvm_reg_data_t storage = 0;
    function new(); super.new("storage"); endfunction
    virtual function void read_func(uvm_reg_item rw);
      rw.set_value(storage); rw.set_status(UVM_IS_OK);
    endfunction
    virtual task write(uvm_reg_item rw);
      do_pre_write(rw); storage = rw.get_value(0); rw.set_status(UVM_IS_OK); do_post_write(rw);
    endtask
  endclass
  class test_sequence extends uvm_reg_sequence;
    uvm_reg_data_t selected;
    bit ok = 1;
    function new(); super.new("subject"); endfunction
    virtual task body();
      uvm_status_e status;
      uvm_reg_data_t actual;
      automatic uvm_reg target = model.get_reg_by_name("reg_value");
      if (target == null) $fatal(1,"missing selected model register");
      write_reg(target,status,selected,UVM_BACKDOOR); ok &= status == UVM_IS_OK;
      read_reg(target,status,actual,UVM_BACKDOOR);
      ok &= status == UVM_IS_OK && actual == selected && get_sequencer() == null;
    endtask
  endclass
  initial begin
    automatic model_block left = new("left");
    automatic model_block right = new("right");
    automatic model_register left_value = new();
    automatic model_register right_value = new();
    automatic storage_backdoor left_storage = new();
    automatic storage_backdoor right_storage = new();
    automatic uvm_reg_field left_field = new("field_value");
    automatic uvm_reg_field right_field = new("field_value");
    automatic uvm_reg_map left_map,right_map;
    automatic test_sequence subject = new();
    left.configure(); right.configure(); left_value.configure(left); right_value.configure(right);
    left_field.configure(left_value,8,0,"RW",0,0,1,0,1);
    right_field.configure(right_value,8,0,"RW",0,0,1,0,1);
    left_map = left.create_map("map_value",0,1,UVM_LITTLE_ENDIAN);
    right_map = right.create_map("map_value",0,1,UVM_LITTLE_ENDIAN);
    left_map.add_reg(left_value,0); right_map.add_reg(right_value,0);
    left_value.set_backdoor(left_storage); right_value.set_backdoor(right_storage);
    left.lock_model(); right.lock_model(); left.reset(); right.reset();
    subject.model = left; subject.selected = 'h13; subject.start(null);
    $display("UT: model_first left %0h right %0h ok %0d",
             left_storage.storage,right_storage.storage,subject.ok);
    subject.model = right; subject.selected = 'h27; subject.start(null);
    $display("UT: model_second left %0h right %0h ok %0d",
             left_storage.storage,right_storage.storage,subject.ok);
    $finish;
  end
endmodule
