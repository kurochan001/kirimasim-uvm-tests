/*
:name: test_uvm_seeding_enable_is_shared_across_types
:description: the UVM seeding enable setting is shared across object types (IEEE 1800.2-2020 Section 5.3.3.1)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.3.1 5.3.3.2 F.4.1.4.25 F.4.1.4.26 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_uvm_seeding_enable_is_shared_across_types.expected
*/
// The accessors are static helpers for one core-service setting. Toggle
// through different object types and restore the initial value afterwards.

module test_uvm_seeding_enable_is_shared_across_types;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class item extends uvm_object;
    `uvm_object_utils(item)
    rand bit [31:0] payload;
    function new(string name="item"); super.new(name); endfunction
  endclass
  class other_item extends uvm_object;
    `uvm_object_utils(other_item)
    function new(string name="other_item"); super.new(name); endfunction
  endclass

  initial begin
    automatic bit saved = uvm_object::get_uvm_seeding();
    item::set_uvm_seeding(0);
    $display("UT: disabled base %0d other %0d", uvm_object::get_uvm_seeding(),
        other_item::get_uvm_seeding());
    other_item::set_uvm_seeding(1);
    $display("UT: enabled base %0d item %0d", uvm_object::get_uvm_seeding(),
        item::get_uvm_seeding());
    uvm_object::set_uvm_seeding(saved);
    $display("UT: restored %0d", uvm_object::get_uvm_seeding() == saved);
    $finish;
  end
endmodule
