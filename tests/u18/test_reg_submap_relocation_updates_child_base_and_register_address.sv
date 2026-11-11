/*
:name: test_reg_submap_relocation_updates_child_base_and_register_address
:description: moving a submap updates its effective base and child register address (IEEE 1800.2-2020 Section 18.2.3.8)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.3.8 18.2.3.7 18.2.3.5 18.2.4.4 18.4.3.14 18.4.2.2 18.5.3.2 18.1.2.3 18.2.3.3 18.1.2.6 18.1.2.1 18.1.2.2 18.4.2.1 18.6.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_submap_relocation_updates_child_base_and_register_address.expected
*/
// What it checks:
// 1. Changing a submap offset relocates its child base and descendant external
//    register address.
// 2. A child map base includes the parent base and the child map offset.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.2.3.8 (UVM-SUBMAP-OFFSET-RELOCATION) gives rule 1 above.
//    Setup: Move the child offset from 40 to 80 under the same root. Expected:
//    The child base becomes 180 and the register external address changes from
//    150 to 190.
// 2. 1800.2-2020 18.2.4.4 (UVM-MAP-HIERARCHICAL-BASE) gives rule 2 above.
//    Setup: Query a nonzero root base and relocate a child offset in another
//    fixture. Expected: The base includes both offsets and tracks relocation.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Equal parent and child bus widths isolate relocation from the known
// narrower-root width difference. The register keeps its local offset.

module test_reg_submap_relocation_updates_child_base_and_register_address;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class model_block extends uvm_reg_block;
    function new(string name="blk"); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(string name="r", int unsigned width=8);
      super.new(name, width, UVM_NO_COVERAGE);
    endfunction
  endclass
  class model_mem extends uvm_mem;
    function new(string name="mem", longint unsigned size=4,
                 int unsigned width=16, string access="RW");
      super.new(name, size, width, access, UVM_NO_COVERAGE);
    endfunction
  endclass

  initial begin
    automatic model_block blk = new("blk");
    automatic model_reg rg = new("r", 8);
    automatic uvm_reg_field field = new("value");
    uvm_reg_map mapping;
    automatic model_block child = new("child");
    uvm_reg_map inner;
    blk.configure();
    child.configure(blk);
    rg.configure(child);
    field.configure(rg, 8, 0, "RW", 0, 0, 1, 0, 1);
    mapping = blk.create_map("outer", 'h100, 4, UVM_LITTLE_ENDIAN);
    inner = child.create_map("inner", 0, 4, UVM_LITTLE_ENDIAN);
    inner.add_reg(rg, 'h10);
    mapping.add_submap(inner, 'h40);
    blk.lock_model();
    $display("UT: before %0h offset %0h", rg.get_address(inner),
             mapping.get_submap_offset(inner));
    mapping.set_submap_offset(inner, 'h80);
    $display("UT: after %0h base %0h offset %0h", rg.get_address(inner),
             inner.get_base_addr(), mapping.get_submap_offset(inner));
    $finish;
  end
endmodule
