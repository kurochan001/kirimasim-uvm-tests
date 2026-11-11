/*
:name: test_tlm2_payload_clear_extension_preserves_other_types
:description: clearing one generic payload extension preserves another extension type (IEEE 1800.2-2020 Section 12.3.4.2.45)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.45 12.3.4.2.43 12.3.4.2.44 12.3.4.2.42 12.3.4.5.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_clear_extension_preserves_other_types.expected
*/
// What it checks:
// 1. The extension count reflects distinct currently installed
//    instance-specific types.
// 2. Clearing one extension type removes that binding while preserving other
//    types.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.4.2.42 (UVM-GP-EXTENSION-COUNT) gives rule 1 above.
//    Setup: Insert, selectively clear, fully clear and reuse payload extension
//    bindings. Expected: Counts change with the observed current set and
//    remain local to each payload.
// 2. 1800.2-2020 12.3.4.2.45 (UVM-GP-SELECTIVE-EXTENSION-CLEAR) gives rule 2
//    above. Setup: Use two types and clear with either the static key or
//    another same-type instance key. Expected: The selected type is absent and
//    the other original handle remains bound.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use two different extension types and remove exactly one key.
// Compare stored handles instead of internal extension-map layout.

module test_tlm2_payload_clear_extension_preserves_other_types;
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
    automatic tag_extension tag = new("tag");
    automatic route_extension route = new("route");
    void'(payload.set_extension(tag));
    void'(payload.set_extension(route));
    $display("UT: initial_count %0d", payload.get_num_extensions());
    payload.clear_extension(tag_extension::ID());
    $display("UT: after_clear count %0d tag_absent %0d route_same %0d",
        payload.get_num_extensions(),
             payload.get_extension(tag_extension::ID()) == null,
                 payload.get_extension(route_extension::ID()) == route);
    $finish;
  end
endmodule
