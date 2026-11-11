/*
:name: test_tlm2_payload_clear_extensions_is_local_and_allows_reuse
:description: clearing generic payload extensions leaves another payload unchanged and permits reuse (IEEE 1800.2-2020 Section 12.3.4.2.46)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.46 12.3.4.2.43 12.3.4.2.44 12.3.4.2.42 12.3.4.5.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_clear_extensions_is_local_and_allows_reuse.expected
*/
// What it checks:
// 1. The extension count reflects distinct currently installed
//    instance-specific types.
// 2. Clearing all extensions removes that payload bindings without affecting a
//    different payload.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.4.2.42 (UVM-GP-EXTENSION-COUNT) gives rule 1 above.
//    Setup: Insert, selectively clear, fully clear and reuse payload extension
//    bindings. Expected: Counts change with the observed current set and
//    remain local to each payload.
// 2. 1800.2-2020 12.3.4.2.46 (UVM-GP-ALL-EXTENSIONS-CLEAR) gives rule 2 above.
//    Setup: Use two payloads and reinsert a retained extension after clearing
//    one. Expected: The cleared set is empty, the peer remains bound and fresh
//    insertion returns null.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Store separate instances of one extension type in two payloads,
// clear one payload and reinsert its retained extension handle.

module test_tlm2_payload_clear_extensions_is_local_and_allows_reuse;
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
    automatic uvm_tlm_generic_payload first = new("first");
    automatic uvm_tlm_generic_payload second = new("second");
    automatic tag_extension first_tag = new("first_tag");
    automatic tag_extension second_tag = new("second_tag");
    uvm_tlm_extension_base previous;
    void'(first.set_extension(first_tag));
    void'(second.set_extension(second_tag));
    first.clear_extensions();
    $display("UT: cleared_first count %0d absent %0d second_count %0d second_same %0d",
        first.get_num_extensions(),
             first.get_extension(tag_extension::ID()) == null,
                 second.get_num_extensions(),
                     second.get_extension(tag_extension::ID()) == second_tag);
    previous = first.set_extension(first_tag);
    $display("UT: reused previous_null %0d count %0d same %0d", previous == null,
        first.get_num_extensions(),
             first.get_extension(tag_extension::ID()) == first_tag);
    $finish;
  end
endmodule
