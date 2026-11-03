/*
:name: test_block_unregister_removes_one_maps_registers_and_memories_and_preserves_another_map
:description: block unregister removes a map and its register/memory members from block queries (18.1.2.11)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.2.11 18.1.3.6 18.1.3.7 18.1.3.9 18.2.3.3 18.2.3.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_unregister_removes_one_maps_registers_and_memories_and_preserves_another_map.expected
*/
module test_block_unregister_removes_one_maps_registers_and_memories_and_preserves_another_map;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class block_type extends uvm_reg_block;
    function new(string name); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass
  class reg_type extends uvm_reg;
    function new(string name); super.new(name, 8, UVM_NO_COVERAGE); endfunction
  endclass
  function automatic reg_type add_reg(block_type owner, uvm_reg_map map_value,
                                     string name, uvm_reg_addr_t offset);
    reg_type value = new(name);
    uvm_reg_field field_value = new("value");
    value.configure(owner);
    field_value.configure(value, 8, 0, "RW", 0, 0, 1, 0, 1);
    map_value.add_reg(value, offset, "RW");
    return value;
  endfunction
  initial begin
    automatic block_type owner = new("owner");
    automatic uvm_reg_map dropped, kept;
    automatic reg_type drop_reg, keep_reg;
    automatic uvm_mem drop_mem = new("drop_mem", 4, 8);
    automatic uvm_mem keep_mem = new("keep_mem", 4, 8);
    uvm_reg_map maps[$]; uvm_reg regs[$]; uvm_mem mems[$];
    owner.configure();
    dropped = owner.create_map("dropped", 0, 1, UVM_LITTLE_ENDIAN);
    kept = owner.create_map("kept", 0, 1, UVM_LITTLE_ENDIAN);
    drop_reg = add_reg(owner, dropped, "drop_reg", 0);
    keep_reg = add_reg(owner, kept, "keep_reg", 0);
    drop_mem.configure(owner); keep_mem.configure(owner);
    dropped.add_mem(drop_mem, 16); kept.add_mem(keep_mem, 16);
    owner.unregister(dropped);
    owner.get_maps(maps); owner.get_registers(regs, UVM_NO_HIER);
    owner.get_memories(mems, UVM_NO_HIER);
    $display("UT: maps count %0d exact_kept %0d", maps.size(),
             maps.size() == 1 && maps[0] == kept);
    $display("UT: registers count %0d exact_kept %0d", regs.size(),
             regs.size() == 1 && regs[0] == keep_reg);
    $display("UT: memories count %0d exact_kept %0d", mems.size(),
             mems.size() == 1 && mems[0] == keep_mem);
    $finish;
  end
endmodule
