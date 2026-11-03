/*
:name: test_block_unregister_preserves_a_same_named_map_and_register_in_a_child_block
:description: unregister uses exact map identity without changing same-named child maps or registers (18.1.2.11)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.2.11 18.1.3.6 18.1.3.7 18.2.3.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_unregister_preserves_a_same_named_map_and_register_in_a_child_block.expected
*/
module test_block_unregister_preserves_a_same_named_map_and_register_in_a_child_block;
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
    automatic block_type child = new("child");
    automatic uvm_reg_map dropped, child_map;
    automatic reg_type drop_reg, child_reg;
    uvm_reg_map owner_maps[$], child_maps[$];
    uvm_reg local_regs[$], child_regs[$], hierarchical_regs[$];
    owner.configure(); child.configure(owner);
    dropped = owner.create_map("same_map", 0, 1, UVM_LITTLE_ENDIAN);
    child_map = child.create_map("same_map", 0, 1, UVM_LITTLE_ENDIAN);
    drop_reg = add_reg(owner, dropped, "same_reg", 0);
    child_reg = add_reg(child, child_map, "same_reg", 0);
    owner.unregister(dropped);
    owner.get_maps(owner_maps); child.get_maps(child_maps);
    owner.get_registers(local_regs, UVM_NO_HIER);
    child.get_registers(child_regs, UVM_NO_HIER); owner.get_registers(hierarchical_regs);
    $display("UT: owner_maps %0d owner_registers %0d child_map_kept %0d",
             owner_maps.size(), local_regs.size(),
             child_maps.size() == 1 && child_maps[0] == child_map);
    $display("UT: child_register_kept %0d hierarchical_register_kept %0d parent_kept %0d",
             child_regs.size() == 1 && child_regs[0] == child_reg,
             hierarchical_regs.size() == 1 && hierarchical_regs[0] == child_reg,
             child.get_parent() == owner);
    $finish;
  end
endmodule
