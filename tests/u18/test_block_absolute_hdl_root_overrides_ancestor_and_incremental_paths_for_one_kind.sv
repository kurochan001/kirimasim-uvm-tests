/*
:name: test_block_absolute_hdl_root_overrides_ancestor_and_incremental_paths_for_one_kind
:description: an absolute block HDL root overrides ancestors for only its selected abstraction (IEEE 1800.2-2020 Section 18.1.6.11)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.6.11 18.1.2.1 18.1.2.2 18.1.6.4 18.1.6.5 18.1.6.6 18.1.6.7 18.1.6.8 18.1.6.9 18.1.6.10 18.1.6.12 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_absolute_hdl_root_overrides_ancestor_and_incremental_paths_for_one_kind.expected
*/
// Symbolic HDL path metadata only: no HDL access, RTL storage or DPI calls.
module test_block_absolute_hdl_root_overrides_ancestor_and_incremental_paths_for_one_kind;
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
    string paths[$];
    root_block.configure(null, "dut"); child.configure(root_block, "sub");
    grandchild.configure(child, "leaf");
    root_block.add_hdl_path("gate_dut", "GATE"); child.add_hdl_path("gate_sub", "GATE");
    grandchild.add_hdl_path("gate_leaf", "GATE");
    grandchild.get_full_hdl_path(paths, "RTL");
    $display("UT: before paths %0d value %s", paths.size(), paths[0]);
    child.set_hdl_path_root("absolute", "RTL"); root_block.add_hdl_path("other_dut", "RTL");
    paths.delete(); grandchild.get_full_hdl_path(paths, "RTL");
    $display("UT: rooted rtl %0d gate %0d paths %0d value %s", child.is_hdl_path_root("RTL"),
             child.is_hdl_path_root("GATE"), paths.size(), paths[0]);
    paths.delete(); grandchild.get_full_hdl_path(paths, "GATE");
    $display("UT: other_kind paths %0d value %s", paths.size(), paths[0]);

    $finish;
  end
endmodule
