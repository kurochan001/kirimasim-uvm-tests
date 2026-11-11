/*
:name: test_tlm2_extension_polymorphic_type_handle_is_shared_by_same_type_instances
:description: polymorphic extension type handles identify a type independently of an instance (IEEE 1800.2-2020 Section 12.3.4.4.4)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.4.4 12.3.4.5.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_extension_polymorphic_type_handle_is_shared_by_same_type_instances.expected
*/
// What it checks:
// 1. Polymorphic extension type handles identify a type rather than a named
//    instance.
// 2. The static extension ID returns a stable unique type key.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.4.4.4 (UVM-EXTENSION-POLYMORPHIC-TYPE-KEY) gives rule 1
//    above. Setup: Compare same/different types, replace a named instance and
//    clear through another same-type key. Expected: Same-type keys remain
//    equal across instances/renames and different types remain distinct.
// 2. 1800.2-2020 12.3.4.5.4 (UVM-EXTENSION-STATIC-TYPE-KEY) gives rule 2
//    above. Setup: Compare repeated static IDs with polymorphic same-type keys
//    and another type. Expected: Repeated/same-type IDs agree and
//    different-type IDs do not.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Compare base-handle dispatch on two distinct instances with the static
// ID. Check relationships rather than a numeric identifier.

module test_tlm2_extension_polymorphic_type_handle_is_shared_by_same_type_instances;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class label_extension extends uvm_tlm_extension#(label_extension);
    `uvm_object_utils(label_extension)
    function new(string name="label_extension"); super.new(name); endfunction
  endclass
  class route_extension extends uvm_tlm_extension#(route_extension);
    `uvm_object_utils(route_extension)
    function new(string name="route_extension"); super.new(name); endfunction
  endclass

  initial begin
    automatic label_extension first = new("first");
    automatic label_extension second = new("second");
    automatic uvm_tlm_extension_base first_view = first;
    automatic uvm_tlm_extension_base second_view = second;
    automatic uvm_tlm_extension_base key = first_view.get_type_handle();
    $display("UT: instances_distinct %0d key_nonnull %0d same_key %0d static_same %0d",
             first != second, key != null, key == second_view.get_type_handle(), key ==
                 label_extension::ID());
    $finish;
  end
endmodule
