/*
:name: test_reg_submap_uses_root_base_and_narrowest_bus_width
:description: hierarchical map addresses include parent offset and use the narrowest bus (IEEE 1800.2-2020 Section 18.2.3.5)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.3.5 18.2.4.4 18.2.4.5 18.2.4.1 18.2.4.3 18.4.3.15 18.1.2.3 18.1.2.6 17.2.2.7 18.5.3.2 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_submap_uses_root_base_and_narrowest_bus_width.expected
*/
// A four-byte child bus is exposed through a two-byte root bus. The child
// register therefore needs two physical addresses in the external map.
// Check effective width and the returned byte count independently of addresses.

module test_reg_submap_uses_root_base_and_narrowest_bus_width;
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
    automatic model_reg rg = new("r", 32);
    automatic uvm_reg_field field = new("value");
    uvm_reg_map outer;
    uvm_reg_map inner;
    uvm_reg_addr_t addresses[];
    automatic int transferred = 0;
    root.configure();
    child.configure(root);
    rg.configure(child);
    field.configure(rg, 32, 0, "RW", 0, 0, 1, 0, 1);
    outer = root.create_map("outer", 'h100, 2, UVM_LITTLE_ENDIAN);
    inner = child.create_map("inner", 0, 4, UVM_LITTLE_ENDIAN);
    inner.add_reg(rg, 8);
    outer.add_submap(inner, 'h40);
    root.lock_model();
    transferred = rg.get_addresses(inner, addresses);
    $display("UT: root %0d parent %0d base %0h local_width %0d effective_width %0d",
             inner.get_root_map() == outer, inner.get_parent_map() == outer,
             inner.get_base_addr(), inner.get_n_bytes(UVM_NO_HIER), inner.get_n_bytes());
    $display("UT: transfer %0d count %0d", transferred, addresses.size());
    if (addresses.size() == 2)
      $display("UT: addresses %0h %0h", addresses[0], addresses[1]);
    $finish;
  end
endmodule
