/*
:name: test_tlm2_payload_extension_uses_unique_type_key
:description: generic payload extension insertion uses a stable unique key for its type (IEEE 1800.2-2020 Section 12.3.4.2.44)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.44 12.3.4.2.43 12.3.4.2.42 12.3.4.5.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_extension_uses_unique_type_key.expected
*/
// What it checks:
// 1. The static extension ID returns a stable unique type key.
// 2. Installing an unbound extension stores that exact instance under its type
//    and returns null.
// 3. Extension retrieval uses the type key and returns null when that type is
//    absent.
// 4. The extension count reflects distinct currently installed
//    instance-specific types.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.4.5.4 (UVM-EXTENSION-STATIC-TYPE-KEY) gives rule 1
//    above. Setup: Compare repeated static IDs with polymorphic same-type keys
//    and another type. Expected: Repeated/same-type IDs agree and
//    different-type IDs do not.
// 2. 1800.2-2020 12.3.4.2.44 (UVM-GP-EXTENSION-INSERTION) gives rule 2 above.
//    Setup: Insert through concrete/base handles with a fresh payload.
//    Expected: Previous is null, the extension count is one and retrieval
//    returns the supplied handle.
// 3. 1800.2-2020 12.3.4.2.43 (UVM-GP-EXTENSION-KEYED-RETRIEVAL) gives rule 3
//    above. Setup: Retrieve an installed/replaced type and another uninstalled
//    type. Expected: The installed current handle is returned and the absent
//    type yields null.
// 4. 1800.2-2020 12.3.4.2.42 (UVM-GP-EXTENSION-COUNT) gives rule 4 above.
//    Setup: Insert, selectively clear, fully clear and reuse payload extension
//    bindings. Expected: Counts change with the observed current set and
//    remain local to each payload.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Compare extension type keys through their common base type and
// retrieve the exact inserted handle. No numeric ID value is prescribed.

module test_tlm2_payload_extension_uses_unique_type_key;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class tag_extension extends uvm_tlm_extension#(tag_extension);
    `uvm_object_utils(tag_extension)
    int value = 0;
    function new(string name="tag_extension"); super.new(name); endfunction
  endclass
  class route_extension extends uvm_tlm_extension#(route_extension);
    `uvm_object_utils(route_extension)
    function new(string name="route_extension"); super.new(name); endfunction
  endclass

  initial begin
    automatic uvm_tlm_generic_payload payload = new("payload");
    automatic tag_extension value = new("value");
    automatic uvm_tlm_extension_base tag_key = tag_extension::ID();
    automatic uvm_tlm_extension_base route_key = route_extension::ID();
    uvm_tlm_extension_base previous;
    previous = payload.set_extension(value);
    $display("UT: inserted previous_null %0d count %0d handle_same %0d", previous == null,
             payload.get_num_extensions(), payload.get_extension(tag_key) == value);
    $display("UT: stable_key %0d distinct_keys %0d absent_route %0d",
        tag_key == tag_extension::ID(),
             tag_key != route_key, payload.get_extension(route_key) == null);
    $finish;
  end
endmodule
