/*
:name: test_reg_block_default_map_selection_and_recursive_model_lock
:description: block default-map selection is explicit and locking reaches child blocks (IEEE 1800.2-2020 Section 18.1.2.5)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.2.5 18.1.2.4 18.1.2.3 18.1.2.6 18.1.2.10 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_block_default_map_selection_and_recursive_model_lock.expected
*/
// What it checks:
// Default map selection and model locking preserve the configured block
// hierarchy.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.1.2.5 (UVM-REG-BLOCK-DEFAULT-MAP-RECURSIVE-LOCK) gives the
// rule above. Setup: Create two maps, select the second explicitly and lock a
// root with one child. Expected: No initial default exists, first creation
// supplies it, explicit selection wins and root/child become locked.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe null before creation, first-created default, and explicit selection.
// No null-map register lookup or unlock API is used.

module test_reg_block_default_map_selection_and_recursive_model_lock;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class model_block extends uvm_reg_block;
    function new(string name="blk");
      super.new(name, UVM_NO_COVERAGE);
    endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(string name="r", int unsigned width=16);
      super.new(name, width, UVM_NO_COVERAGE);
    endfunction
  endclass

  initial begin
    automatic model_block root = new("root");
    automatic model_block child = new("child");
    uvm_reg_map first_map;
    uvm_reg_map second_map;
    root.configure();
    child.configure(root);
    $display("UT: no_default %0d unlocked %0d %0d", root.get_default_map() == null,
             !root.is_locked(), !child.is_locked());
    first_map = root.create_map("first", 0, 4, UVM_LITTLE_ENDIAN);
    second_map = root.create_map("second", 'h100, 4, UVM_LITTLE_ENDIAN);
    $display("UT: first_default %0d", root.get_default_map() == first_map);
    root.set_default_map(second_map);
    root.lock_model();
    $display("UT: selected %0d locked %0d %0d", root.get_default_map() == second_map,
             root.is_locked(), child.is_locked());
    $finish;
  end
endmodule
