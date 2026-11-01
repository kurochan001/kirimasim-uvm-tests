/*
:name: test_block_full_hdl_paths_expand_parent_duplicates_and_preserve_a_custom_separator
:description: block full HDL paths include every duplicated ancestor path with the chosen separator (IEEE 1800.2-2020 Section 18.1.6.8)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.6.8 18.1.2.1 18.1.2.2 18.1.6.4 18.1.6.5 18.1.6.6 18.1.6.7 18.1.6.9 18.1.6.10 18.1.6.11 18.1.6.12 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_full_hdl_paths_expand_parent_duplicates_and_preserve_a_custom_separator.expected
*/
// Symbolic HDL path metadata only: no HDL access, RTL storage or DPI calls.
module test_block_full_hdl_paths_expand_parent_duplicates_and_preserve_a_custom_separator;
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
    bit seen[string];
    bit valid;
    root_block.configure(null, "dut0"); root_block.add_hdl_path("dut1");
    child.configure(root_block, "bank0"); child.add_hdl_path("bank1");
    grandchild.configure(child, "leaf0"); grandchild.add_hdl_path("leaf1");
    grandchild.get_full_hdl_path(paths);
    foreach (paths[i]) seen[paths[i]] = 1;
    valid = seen.exists("dut0.bank0.leaf0") && seen.exists("dut0.bank0.leaf1") &&
            seen.exists("dut0.bank1.leaf0") && seen.exists("dut0.bank1.leaf1") &&
            seen.exists("dut1.bank0.leaf0") && seen.exists("dut1.bank0.leaf1") &&
            seen.exists("dut1.bank1.leaf0") && seen.exists("dut1.bank1.leaf1");
    $display("UT: dotted paths %0d unique %0d combinations %0d", paths.size(), seen.num(), valid);
    paths.delete(); seen.delete(); grandchild.get_full_hdl_path(paths, "RTL", "/");
    foreach (paths[i]) seen[paths[i]] = 1;
    valid = seen.exists("dut0/bank0/leaf0") && seen.exists("dut0/bank0/leaf1") &&
            seen.exists("dut0/bank1/leaf0") && seen.exists("dut0/bank1/leaf1") &&
            seen.exists("dut1/bank0/leaf0") && seen.exists("dut1/bank0/leaf1") &&
            seen.exists("dut1/bank1/leaf0") && seen.exists("dut1/bank1/leaf1");
    $display("UT: custom paths %0d unique %0d combinations %0d", paths.size(), seen.num(), valid);

    $finish;
  end
endmodule
