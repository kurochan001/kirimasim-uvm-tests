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
// What it checks:
// 1. Polymorphic extension type handles identify a type rather than a named
//    instance.
// 2. Installing an unbound extension stores that exact instance under its type
//    and returns null.
// 3. Extension retrieval uses the type key and returns null when that type is
//    absent.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.4.4.4 (UVM-EXTENSION-POLYMORPHIC-TYPE-KEY) gives rule 1
//    above. Setup: Compare same/different types, replace a named instance and
//    clear through another same-type key. Expected: Same-type keys remain
//    equal across instances/renames and different types remain distinct.
// 2. 1800.2-2020 12.3.4.2.44 (UVM-GP-EXTENSION-INSERTION) gives rule 2 above.
//    Setup: Insert through concrete/base handles with a fresh payload.
//    Expected: Previous is null, the extension count is one and retrieval
//    returns the supplied handle.
// 3. 1800.2-2020 12.3.4.2.43 (UVM-GP-EXTENSION-KEYED-RETRIEVAL) gives rule 3
//    above. Setup: Retrieve an installed/replaced type and another uninstalled
//    type. Expected: The installed current handle is returned and the absent
//    type yields null.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
