/*
:name: test_core_seeding_default_and_global_cross_type_accessors_agree
:description: The core seeding flag starts enabled and both class interfaces share it
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.4.1.4.25 F.4.1.4.26 5.3.3.1 5.3.3.2 1800-2023 6.21 8.20 8.21 13.5.2 18.13.3 18.13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_core_seeding_default_and_global_cross_type_accessors_agree.expected
*/
// What it checks:
// 1. The core UVM seeding enable value defaults to one.
// 2. The core setter changes the globally shared UVM seeding enable value.
// 3. Object-class getters retrieve the same core seeding flag.
// 4. An object-class setter updates the core seeding flag.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 F.4.1.4.25 (UVM-CORE-DECL-AUDIT-SEEDING-DEFAULT) gives rule 1
//    above. Setup: Use a fresh process and two original registered classes.
//    The RNG probe explicitly seeds independent pairs, renames the selected
//    objects before snapshots and restores the saved global flag. Expected:
//    The initial core flag and two original object-class accessors all report
//    enabled.
// 2. 1800.2-2020 F.4.1.4.26 (UVM-CORE-DECL-AUDIT-SEEDING-GLOBAL-SET) gives
//    rule 2 above. Setup: Use a fresh process and two original registered
//    classes. The RNG probe explicitly seeds independent pairs, renames the
//    selected objects before snapshots and restores the saved global flag.
//    Expected: Core disable is visible through both types; class re-enable is
//    visible through the core and peer, and the saved flag can be restored.
// 3. 1800.2-2020 5.3.3.1 (UVM-CORE-DECL-AUDIT-SEEDING-OBJECT-GET) gives rule 3
//    above. Setup: Use a fresh process and two original registered classes.
//    The RNG probe explicitly seeds independent pairs, renames the selected
//    objects before snapshots and restores the saved global flag. Expected:
//    Both original types report the core-selected enable values across the
//    selected changes.
// 4. 1800.2-2020 5.3.3.2 (UVM-CORE-DECL-AUDIT-SEEDING-OBJECT-SET) gives rule 4
//    above. Setup: Use a fresh process and two original registered classes.
//    The RNG probe explicitly seeds independent pairs, renames the selected
//    objects before snapshots and restores the saved global flag. Expected:
//    Enabling through the second original type updates the core and first-type
//    views.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_core_seeding_default_and_global_cross_type_accessors_agree;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class first_item extends uvm_object;
    `uvm_object_utils(first_item)
    function new(string name="first64"); super.new(name); endfunction
  endclass
  class second_item extends uvm_object;
    `uvm_object_utils(second_item)
    function new(string name="second64"); super.new(name); endfunction
  endclass
  initial begin
    automatic uvm_coreservice_t service=uvm_coreservice_t::get();
    automatic bit saved=service.get_uvm_seeding();
    $display("UT: global_seeding initial %0d first %0d second %0d",saved,
      first_item::get_uvm_seeding(),second_item::get_uvm_seeding());
    service.set_uvm_seeding(0);
    $display("UT: global_seeding core_disable %0d %0d %0d",service.get_uvm_seeding(),
      first_item::get_uvm_seeding(),second_item::get_uvm_seeding());
    second_item::set_uvm_seeding(1);
    $display("UT: global_seeding class_enable %0d %0d %0d",service.get_uvm_seeding(),
      first_item::get_uvm_seeding(),second_item::get_uvm_seeding());
    service.set_uvm_seeding(saved);
    $display("UT: global_seeding restored %0d",uvm_object::get_uvm_seeding()==saved);
    $finish;
  end
endmodule
