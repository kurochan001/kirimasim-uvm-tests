/*
:name: test_bit_bash_wrapper_live_protected_slot_routes_each_register_target
:description: Factory-selected original children expose live declared slot and selected target routing
:tags: uE uvm
:type: simulation
:lrm: 1800.2-2020 E.2.2.2.2 E.2.2.3.2 E.2.2 8.3.1.4.2 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.3 18.2.3.4 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_bit_bash_wrapper_live_protected_slot_routes_each_register_target.expected
*/
// A factory-selected original child audits the wrapper's live protected slot
// and target routing. Payload algorithms, ordering and allocation counts are
// deliberately not inferred from this delegation-only probe.
module test_bit_bash_wrapper_live_protected_slot_routes_each_register_target;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class block_type extends uvm_reg_block;
    function new(string name); super.new(name,UVM_NO_COVERAGE); endfunction
  endclass
  class register_type extends uvm_reg;
    function new(string name); super.new(name,8,UVM_NO_COVERAGE); endfunction
  endclass
  class memory_type extends uvm_mem;
    function new(string name); super.new(name,4,8,"RW",UVM_NO_COVERAGE); endfunction
  endclass

  typedef class observed_wrapper;
  observed_wrapper active_wrapper;
  uvm_reg targets[2];
  uvm_mem memory_targets[2];
  bit reg_slot_ok=1,mem_slot_ok=1,wrong_target=0;
  bit [1:0] reg_seen=0,mem_seen=0;
  class register_probe extends uvm_reg_single_bit_bash_seq;
    `uvm_object_utils(register_probe)
    function new(string name="register_probe"); super.new(name); endfunction
    virtual task body();
      reg_slot_ok &= active_wrapper.register_child()==this;
      if (rg==targets[0]) reg_seen[0]=1;
      else if (rg==targets[1]) reg_seen[1]=1;
      else wrong_target=1;
      #1;
    endtask
  endclass
  class observed_wrapper extends uvm_reg_bit_bash_seq;
    function new(); super.new("observed_wrapper"); endfunction
    function uvm_reg_single_bit_bash_seq register_child(); return reg_seq; endfunction
  endclass
  initial begin
    block_type block_model;
    register_type first_reg,second_reg;
    memory_type first_mem,second_mem;
    uvm_reg_field first_field,second_field;
    uvm_reg_map first_map,second_map;
    uvm_factory factory;
    time started;
    block_model=new("block60"); block_model.configure();
    first_map=block_model.create_map("first60",0,1,UVM_LITTLE_ENDIAN);
    second_map=block_model.create_map("second60",256,1,UVM_LITTLE_ENDIAN);
    first_reg=new("first60"); second_reg=new("second60");
    first_reg.configure(block_model); second_reg.configure(block_model);
    first_field=new("first_field"); second_field=new("second_field");
    first_field.configure(first_reg,8,0,"RW",0,0,1,1,0);
    second_field.configure(second_reg,8,0,"RW",0,0,1,1,0);
    first_map.add_reg(first_reg,0,"RW"); first_map.add_reg(second_reg,1,"RW");
    second_map.add_reg(first_reg,0,"RW"); second_map.add_reg(second_reg,1,"RW");
    targets[0]=first_reg; targets[1]=second_reg;
    block_model.lock_model(); active_wrapper=new(); active_wrapper.model=block_model;
    factory=uvm_factory::get();
    factory.set_type_override_by_type(uvm_reg_single_bit_bash_seq::get_type(),
      register_probe::get_type());
    started=$time; active_wrapper.start(null);
    $display("UT: live_register_slot agrees %0d both_targets %0d no_foreign_target %0d delayed %0d",
      reg_slot_ok,reg_seen==2'b11,!wrong_target,$time>started);
    $finish;
  end
  initial begin #100; $fatal(1,"wrapper routing watchdog expired"); end
endmodule
