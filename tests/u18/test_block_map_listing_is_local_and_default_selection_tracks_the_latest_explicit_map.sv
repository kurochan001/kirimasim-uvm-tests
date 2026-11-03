/*
:name: test_block_map_listing_is_local_and_default_selection_tracks_the_latest_explicit_map
:description: get_maps stays local while default selection follows first creation and explicit changes (18.1.3.6)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.3.6 18.1.2.4 18.1.2.5 18.1.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_map_listing_is_local_and_default_selection_tracks_the_latest_explicit_map.expected
*/
module test_block_map_listing_is_local_and_default_selection_tracks_the_latest_explicit_map;
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
    automatic block_type owner = new("owner");
    automatic block_type child = new("child");
    automatic uvm_reg_map first, second, nested;
    automatic bit seen_first = 0, seen_second = 0, seen_nested = 0;
    uvm_reg_map maps[$];
    owner.configure(); child.configure(owner);
    $display("UT: initially_null %0d", owner.get_default_map() == null);
    first = owner.create_map("first", 0, 1, UVM_LITTLE_ENDIAN);
    second = owner.create_map("second", 16, 1, UVM_LITTLE_ENDIAN);
    nested = child.create_map("nested", 0, 1, UVM_LITTLE_ENDIAN);
    owner.get_maps(maps);
    foreach (maps[i]) begin
      seen_first |= maps[i] == first; seen_second |= maps[i] == second;
      seen_nested |= maps[i] == nested;
    end
    $display("UT: maps count %0d exact_local %0d nested_excluded %0d first_default %0d",
             maps.size(), seen_first && seen_second, !seen_nested,
             owner.get_default_map() == first);
    owner.set_default_map(second);
    $display("UT: replaced %0d child_retained %0d", owner.get_default_map() == second,
             child.get_default_map() == nested);
    owner.set_default_map(first);
    $display("UT: reselected %0d", owner.get_default_map() == first);
    $finish;
  end
endmodule
