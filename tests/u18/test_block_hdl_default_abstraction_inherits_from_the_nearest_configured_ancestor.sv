/*
:name: test_block_hdl_default_abstraction_inherits_from_the_nearest_configured_ancestor
:description: block HDL default abstraction follows the nearest configured ancestor and local overrides (IEEE 1800.2-2020 Section 18.1.6.9)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.6.9 18.1.2.1 18.1.2.2 18.1.6.4 18.1.6.5 18.1.6.6 18.1.6.7 18.1.6.8 18.1.6.10 18.1.6.11 18.1.6.12 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_hdl_default_abstraction_inherits_from_the_nearest_configured_ancestor.expected
*/
// The pinned library keeps a local RTL default instead of ancestor inheritance.
// Symbolic HDL path metadata only: no HDL access, RTL storage or DPI calls.
module test_block_hdl_default_abstraction_inherits_from_the_nearest_configured_ancestor;
  import uvm_pkg::*;
  class model_block extends uvm_reg_block;
    function new(string name="blk"); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(); super.new("r", 16, UVM_NO_COVERAGE); endfunction
  endclass
  initial begin

    automatic model_block root_block = new("root");
    automatic model_block child = new("child");
    automatic model_block grandchild = new("grandchild");
    automatic model_block sibling = new("sibling");
    root_block.configure(); child.configure(root_block); grandchild.configure(child);
    sibling.configure(root_block);
    $display("UT: initial %s %s %s", root_block.get_default_hdl_path(),
    child.get_default_hdl_path(),
             grandchild.get_default_hdl_path());
    root_block.set_default_hdl_path("GATE");
    $display("UT: inherited %s %s", child.get_default_hdl_path(),
    grandchild.get_default_hdl_path());
    child.set_default_hdl_path("RTL"); root_block.set_default_hdl_path("SYN");
    $display("UT: overridden child %s grandchild %s sibling %s", child.get_default_hdl_path(),
             grandchild.get_default_hdl_path(), sibling.get_default_hdl_path());

    $finish;
  end
endmodule
