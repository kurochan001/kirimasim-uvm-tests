/*
:name: test_block_unregister_removes_virtual_registers_backed_by_the_selected_maps_memory
:description: block unregister removes virtual registers belonging to the selected memory map (18.1.2.11)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.2.11 18.1.3.10 18.9.1.1.2 18.2.3.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_unregister_removes_virtual_registers_backed_by_the_selected_maps_memory.expected
*/
// What it checks:
// 1. Block unregister removes virtual registers belonging to the removed map
//    content.
// 2. The block virtual-register query reflects the currently retained virtual
//    registers.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.1.2.11 (UVM-BLOCK-UNREGISTER-VIRTUAL-REGISTER-MEMBERSHIP)
//    gives rule 1 above. Setup: Create one static virtual-register overlay on
//    each mapped memory, then remove one map. Expected: The two-entry virtual
//    register listing becomes one exact kept overlay.
// 2. 1800.2-2020 18.1.3.10 (UVM-BLOCK-VIRTUAL-REGISTER-QUERY-AFTER-UNREGISTER)
//    gives rule 2 above. Setup: Query before and after removing one mapped
//    static overlay. Expected: The local queue changes from two entries to the
//    one exact remaining handle.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_block_unregister_removes_virtual_registers_backed_by_the_selected_maps_memory;
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
    automatic uvm_mem drop_mem = new("drop_mem", 8, 8);
    automatic uvm_mem keep_mem = new("keep_mem", 8, 8);
    automatic uvm_vreg drop_vreg = new("drop_vreg", 8);
    automatic uvm_vreg keep_vreg = new("keep_vreg", 8);
    uvm_vreg before_regs[$], after_regs[$];
    owner.configure();
    dropped = owner.create_map("dropped", 0, 1, UVM_LITTLE_ENDIAN);
    kept = owner.create_map("kept", 0, 1, UVM_LITTLE_ENDIAN);
    drop_mem.configure(owner); keep_mem.configure(owner);
    dropped.add_mem(drop_mem, 0); kept.add_mem(keep_mem, 0);
    drop_vreg.configure(owner, drop_mem, 1, 0, 1);
    keep_vreg.configure(owner, keep_mem, 1, 0, 1);
    owner.get_virtual_registers(before_regs, UVM_NO_HIER);
    $display("UT: before_count %0d", before_regs.size());
    owner.unregister(dropped);
    owner.get_virtual_registers(after_regs, UVM_NO_HIER);
    $display("UT: after_count %0d exact_kept %0d", after_regs.size(),
             after_regs.size() == 1 && after_regs[0] == keep_vreg);
    $finish;
  end
endmodule
