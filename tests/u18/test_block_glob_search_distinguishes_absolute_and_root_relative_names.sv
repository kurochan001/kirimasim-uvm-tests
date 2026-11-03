/*
:name: test_block_glob_search_distinguishes_absolute_and_root_relative_names
:description: find_blocks and find_block select absolute/relative glob matches with exact returned handles (18.1.3.3)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.3.3 18.1.3.4 18.1.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_glob_search_distinguishes_absolute_and_root_relative_names.expected
*/
module test_block_glob_search_distinguishes_absolute_and_root_relative_names;
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
    automatic block_type first = new("first");
    automatic block_type second = new("second");
    automatic block_type branch = new("branch");
    automatic block_type peer_branch = new("branch");
    automatic block_type leaf = new("leaf");
    automatic int absolute_count, relative_count, absent_count;
    automatic bit branch_seen = 0, leaf_seen = 0, peer_seen = 0;
    uvm_reg_block absolute_matches[$], relative_matches[$], absent[$];
    first.configure(); second.configure(); branch.configure(first);
    peer_branch.configure(second); leaf.configure(branch);
    absolute_count = uvm_reg_block::find_blocks("first.*", absolute_matches);
    foreach (absolute_matches[i]) begin
      branch_seen |= absolute_matches[i] == branch;
      leaf_seen |= absolute_matches[i] == leaf;
      peer_seen |= absolute_matches[i] == peer_branch;
    end
    relative_count = uvm_reg_block::find_blocks("branch.*", relative_matches, first);
    absent_count = uvm_reg_block::find_blocks("missing*", absent, first);
    $display("UT: absolute count %0d exact_membership %0d peer_excluded %0d", absolute_count,
             branch_seen && leaf_seen && absolute_matches.size() == 2, !peer_seen);
    $display("UT: relative count %0d exact_leaf %0d missing_count %0d empty %0d", relative_count,
             relative_matches.size() == 1 && relative_matches[0] == leaf,
             absent_count, absent.size() == 0);
    $display("UT: single exact_branch %0d missing_null %0d",
             uvm_reg_block::find_block("branch", first) == branch,
             uvm_reg_block::find_block("missing", first) == null);
    $finish;
  end
endmodule
