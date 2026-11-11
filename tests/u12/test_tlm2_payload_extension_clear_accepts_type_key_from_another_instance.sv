/*
:name: test_tlm2_payload_extension_clear_accepts_type_key_from_another_instance
:description: clearing by a polymorphic key from another same-type instance preserves unrelated extensions (IEEE 1800.2-2020 Section 12.3.4.4.4)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.4.4 12.3.4.2.43 12.3.4.2.44 12.3.4.2.45 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_extension_clear_accepts_type_key_from_another_instance.expected
*/
// What it checks:
// 1. Polymorphic extension type handles identify a type rather than a named
//    instance.
// 2. Clearing one extension type removes that binding while preserving other
//    types.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.4.4.4 (UVM-EXTENSION-POLYMORPHIC-TYPE-KEY) gives rule 1
//    above. Setup: Compare same/different types, replace a named instance and
//    clear through another same-type key. Expected: Same-type keys remain
//    equal across instances/renames and different types remain distinct.
// 2. 1800.2-2020 12.3.4.2.45 (UVM-GP-SELECTIVE-EXTENSION-CLEAR) gives rule 2
//    above. Setup: Use two types and clear with either the static key or
//    another same-type instance key. Expected: The selected type is absent and
//    the other original handle remains bound.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Retrieve the type key from an uninserted same-type instance and clear
// that key. Only the matching type is removed; the other type stays bound.

module test_tlm2_payload_extension_clear_accepts_type_key_from_another_instance;
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
    automatic uvm_tlm_generic_payload payload = new("payload");
    automatic label_extension installed = new("installed");
    automatic label_extension other_instance = new("other_instance");
    automatic route_extension route = new("route");
    uvm_tlm_extension_base previous;
    previous = payload.set_extension(installed);
    previous = payload.set_extension(route);
    payload.clear_extension(other_instance.get_type_handle());
    $display("UT: label_absent %0d route_same %0d count %0d",
             payload.get_extension(installed.get_type_handle()) == null,
             payload.get_extension(route.get_type_handle()) == route, payload.get_num_extensions());
    $finish;
  end
endmodule
