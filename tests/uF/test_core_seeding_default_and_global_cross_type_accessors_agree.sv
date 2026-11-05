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
