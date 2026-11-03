/*
:name: test_block_unlock_model_allows_structural_additions_before_rebuilding_lookups
:description: unlock_model permits structural changes and relocking builds updated offset lookups (18.1.2.7)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.2.7 18.1.2.6 18.1.2.10 18.2.4.17 18.2.3.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_unlock_model_allows_structural_additions_before_rebuilding_lookups.expected
*/
module test_block_unlock_model_allows_structural_additions_before_rebuilding_lookups;
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
    automatic uvm_reg_map map_value;
    automatic reg_type first, second;
    owner.configure(); map_value = owner.create_map("map", 0, 1, UVM_LITTLE_ENDIAN);
    first = add_reg(owner, map_value, "first", 0); owner.lock_model();
    $display("UT: initial locked %0d lookup %0d",
             owner.is_locked(), map_value.get_reg_by_offset(0) == first);
    owner.unlock_model();
    $display("UT: unlocked %0d", !owner.is_locked());
    second = add_reg(owner, map_value, "second", 1); owner.lock_model();
    $display("UT: rebuilt locked %0d first %0d added %0d", owner.is_locked(),
             map_value.get_reg_by_offset(0) == first, map_value.get_reg_by_offset(1) == second);
    $finish;
  end
endmodule
