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
// What it checks:
// 1. The object seeding query reads the core-service enable setting.
// 2. The object seeding setter updates the shared core-service setting.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.3.3.1 (UVM-SEEDING-GET) gives rule 1 above. Setup: Toggle
//    the setting through different object types and the core service.
//    Expected: Every query observes the same setting; the original setting can
//    be restored.
// 2. 1800.2-2020 5.3.3.2 (UVM-SEEDING-SET) gives rule 2 above. Setup: Set
//    through one object type and query through another API. Expected:
//    Disabling and enabling are visible across those accessors.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
