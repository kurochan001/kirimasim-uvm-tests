/*
:name: test_block_wait_for_lock_blocks_before_locking_and_returns_for_a_locked_model
:description: wait_for_lock releases preexisting waiters after model locking and lookup construction (18.1.2.9)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.2.9 18.1.2.6 18.1.2.10 18.2.4.17 18.2.3.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_wait_for_lock_blocks_before_locking_and_returns_for_a_locked_model.expected
*/
module test_block_wait_for_lock_blocks_before_locking_and_returns_for_a_locked_model;
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
  // Register both waiters before completion. The specification does not
  // explicitly define a new wait that starts after completion, so omit it.
  initial begin
    automatic block_type owner = new("owner");
    automatic uvm_reg_map map_value;
    automatic reg_type register_value;
    automatic bit [1:0] returned = 0;
    automatic bit [1:0] ready = 0;
    owner.configure(); map_value = owner.create_map("map", 0, 1, UVM_LITTLE_ENDIAN);
    register_value = add_reg(owner, map_value, "register_value", 0);
    fork
      begin
        owner.wait_for_lock();
        ready[0] = owner.is_locked() && map_value.get_reg_by_offset(0) == register_value;
        returned[0] = 1;
      end
      begin
        owner.wait_for_lock();
        ready[1] = owner.is_locked() && map_value.get_reg_by_offset(0) == register_value;
        returned[1] = 1;
      end
      begin
        #1; $display("UT: before_lock blocked %0d", returned == 0);
        #1; owner.lock_model();
      end
    join
    $display("UT: after_lock both_returned %0d locked %0d lookup_ready %0d",
             &returned, owner.is_locked(), &ready);
    $finish;
  end
  initial begin #20; $fatal(1, "lock wait watchdog expired"); end
endmodule
