/*
:name: test_tlm2_payload_extension_insertion_uses_polymorphically_retrieved_key
:description: payload insertion through an extension base handle is retrievable by its polymorphic key (IEEE 1800.2-2020 Section 12.3.4.4.4)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.4.4 12.3.4.2.43 12.3.4.2.44 12.3.4.2.42 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_extension_insertion_uses_polymorphically_retrieved_key.expected
*/
// Insert through the common extension base type and retrieve using virtual
// type-handle dispatch, preserving the original instance handle.

module test_tlm2_payload_extension_insertion_uses_polymorphically_retrieved_key;
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
    automatic label_extension extension_value = new("extension_value");
    automatic uvm_tlm_extension_base view = extension_value;
    automatic uvm_tlm_extension_base key = view.get_type_handle();
    uvm_tlm_extension_base previous;
    previous = payload.set_extension(view);
    $display("UT: previous_null %0d same_instance %0d count %0d", previous == null,
             payload.get_extension(key) == view, payload.get_num_extensions());
    $finish;
  end
endmodule
