/*
:name: test_memory_full_hdl_paths_expand_ancestor_duplicates_and_custom_separators
:description: Memory full HDL paths form the ancestor cross product with the specified separator
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.7.9 18.6.7.4 18.6.7.7 18.1.6.5 18.1.6.10 18.6.3.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_full_hdl_paths_expand_ancestor_duplicates_and_custom_separators.expected
*/
// Path strings and coordinates only, with no physical HDL/DPI claim.
module test_memory_full_hdl_paths_expand_ancestor_duplicates_and_custom_separators;
  import uvm_pkg::*;

  class block_type extends uvm_reg_block;
    function new(string name="owner56"); super.new(name,UVM_NO_COVERAGE); endfunction
  endclass

  initial begin
    automatic block_type root=new("root56");
    automatic block_type child=new("child56");
    automatic uvm_mem memory=new("memory56",4,16);
    uvm_hdl_path_concat paths[$];
    int counts[string]; automatic bit coordinates=1;
    root.configure(null,"dut_a56"); root.add_hdl_path("dut_b56");
    child.configure(root,"bank_a56"); child.add_hdl_path("bank_b56");
    memory.configure(child,"cells56");
    memory.get_full_hdl_path(paths,"RTL","/");
    foreach (paths[i]) begin
      coordinates &= paths[i].slices.size()==1;
      if (paths[i].slices.size()==1) begin
        counts[paths[i].slices[0].path]++;
        coordinates &= paths[i].slices[0].offset==-1 && paths[i].slices[0].size==-1;
      end
    end
    $display("UT: full_paths count %0d cross_product %0d coordinates %0d",paths.size(),
      counts.num()==4 && counts["dut_a56/bank_a56/cells56"]==1 &&
      counts["dut_a56/bank_b56/cells56"]==1 && counts["dut_b56/bank_a56/cells56"]==1 &&
      counts["dut_b56/bank_b56/cells56"]==1,coordinates);
    $finish;
  end
endmodule
