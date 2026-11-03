/*
:name: test_block_root_listing_contains_independent_roots_and_excludes_descendants
:description: get_root_blocks identifies roots without promoting their descendants (18.1.3.2)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.3.2 18.1.3.1 18.1.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_root_listing_contains_independent_roots_and_excludes_descendants.expected
*/
module test_block_root_listing_contains_independent_roots_and_excludes_descendants;
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
    automatic block_type child = new("child");
    automatic block_type deep = new("deep");
    automatic bit seen_first = 0, seen_second = 0, seen_child = 0, seen_deep = 0;
    uvm_reg_block roots[$];
    first.configure(); second.configure(); child.configure(first); deep.configure(child);
    uvm_reg_block::get_root_blocks(roots);
    foreach (roots[i]) begin
      seen_first |= roots[i] == first; seen_second |= roots[i] == second;
      seen_child |= roots[i] == child; seen_deep |= roots[i] == deep;
    end
    $display("UT: roots_present %0d %0d descendants_excluded %0d %0d",
             seen_first, seen_second, !seen_child, !seen_deep);
    $display("UT: parents %0d %0d %0d %0d", first.get_parent() == null,
             second.get_parent() == null, child.get_parent() == first, deep.get_parent() == child);
    $finish;
  end
endmodule
