/*
:name: test_reg_block_reset_recurses_into_child_registers
:description: block reset restores registers in both the root and a child block (IEEE 1800.2-2020 Section 18.1.5.3)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.5.3 18.1.5.4 18.4.4.5 18.4.4.15 18.4.4.2 18.4.4.1 18.4.4.3 18.5.3.2 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_block_reset_recurses_into_child_registers.expected
*/
// The root contains one register and one configured child containing another.
// Observe recursive dirty state before reset and both values afterwards.

module test_reg_block_reset_recurses_into_child_registers;
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
    automatic model_reg outer = new("outer", 8);
    automatic model_reg inner = new("inner", 8);
    automatic uvm_reg_field outer_field = new("value");
    automatic uvm_reg_field inner_field = new("value");
    automatic bit accepted = 0;
    root.configure();
    child.configure(root);
    outer.configure(root);
    inner.configure(child);
    outer_field.configure(outer, 8, 0, "RW", 0, 8'h12, 1, 0, 1);
    inner_field.configure(inner, 8, 0, "RW", 0, 8'h34, 1, 0, 1);
    accepted = outer.predict(8'haa) && inner.predict(8'hbb);
    inner.set(8'hcc);
    $display("UT: predicted %0d root_update %0d child_update %0d", accepted,
             root.needs_update(), child.needs_update());
    root.reset();
    $display("UT: outer %0h %0h inner %0h %0h update %0d", outer.get(),
             outer.get_mirrored_value(), inner.get(), inner.get_mirrored_value(),
             root.needs_update());
    $finish;
  end
endmodule
