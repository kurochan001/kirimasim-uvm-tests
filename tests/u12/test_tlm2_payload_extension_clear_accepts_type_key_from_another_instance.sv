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
