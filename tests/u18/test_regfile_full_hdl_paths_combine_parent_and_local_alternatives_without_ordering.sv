/*
:name: test_regfile_full_hdl_paths_combine_parent_and_local_alternatives_without_ordering
:description: full register file HDL paths include all parent and local path alternatives (18.3.4.5)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.3.4.5 18.3.4.4 18.3.4.2 18.3.2.2 18.1.2.2 18.1.6.5 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_regfile_full_hdl_paths_combine_parent_and_local_alternatives_without_ordering.expected
*/
// Symbolic path strings only: no HDL lookup, DPI, bus or DUT access.
// Queues are fresh and compared by membership without an enumeration order.
module test_regfile_full_hdl_paths_combine_parent_and_local_alternatives_without_ordering;
  import uvm_pkg::*;
  class block_type extends uvm_reg_block;
    function new(string name); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass

  initial begin
    automatic block_type root_block = new("root");
    automatic uvm_reg_file outer_file = new("outer");
    automatic uvm_reg_file inner_file = new("inner");
    string full_paths[$], local_paths[$];
    automatic string roots[2] = '{"dut", "shadow"};
    automatic string banks[2] = '{"bank_a", "bank_b"};
    automatic string leaves[2] = '{"leaf_a", "leaf_b"};
    automatic int members = 0;
    root_block.configure(null, "dut"); root_block.add_hdl_path("shadow");
    outer_file.configure(root_block, null, "bank_a"); outer_file.add_hdl_path("bank_b");
    inner_file.configure(root_block, outer_file, "leaf_a"); inner_file.add_hdl_path("leaf_b");
    inner_file.get_full_hdl_path(full_paths); inner_file.get_hdl_path(local_paths);
    foreach (full_paths[i])
      foreach (roots[r]) foreach (banks[b]) foreach (leaves[l])
        if (full_paths[i] == {roots[r], ".", banks[b], ".", leaves[l]})
          members |= 1 << (r * 4 + b * 2 + l);
    $display("UT: full_count %0d members %0d local_count %0d", full_paths.size(), members,
             local_paths.size());
    $finish;
  end
endmodule
