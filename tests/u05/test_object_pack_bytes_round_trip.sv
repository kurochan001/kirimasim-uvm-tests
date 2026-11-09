/*
:name: test_object_pack_bytes_round_trip
:description: object packing and unpacking preserve fields through a bytes stream (IEEE 1800.2-2020 Section 5.3.10.1)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.10.1 5.3.10.2 5.3.11.1 5.3.11.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_pack_bytes_round_trip.expected
*/
// What it checks:
// Object unpack restores fields from a matching packed stream using the
// specified field order.
//
// How the expected output follows from the standard:
// 1800.2-2020 5.3.11.1 (UVM-OBJECT-UNPACK-FIELDS) gives the rule above. Setup:
// Use paired custom pack/unpack hooks with bit and byte arrays. Expected:
// Selected payloads round-trip and packed/unpacked bit counts are positive and
// equal.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The fixed entry points invoke the user pack and unpack hooks.
// Observe field values and returned bit counts, without fixing stream layout.

module test_object_pack_bytes_round_trip;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_object;
    `uvm_object_utils(packet)
    int address = 0;
    int payload = 0;
    function new(string name="packet"); super.new(name); endfunction
    function void do_pack(uvm_packer packer);
      super.do_pack(packer);
      packer.pack_field_int(address, 12);
      packer.pack_field_int(payload, 8);
    endfunction
    function void do_unpack(uvm_packer packer);
      super.do_unpack(packer);
      address = int'(packer.unpack_field_int(12));
      payload = int'(packer.unpack_field_int(8));
    endfunction
  endclass

  initial begin
    automatic packet source = new("source");
    automatic packet target = new("target");
    automatic uvm_packer packer = new;
    byte unsigned stream[];
    int packed_count;
    int unpacked_count;
    source.address = 'habc;
    source.payload = 'hfe;
    packed_count = source.pack_bytes(stream, packer);
    unpacked_count = target.unpack_bytes(stream, packer);
    $display("UT: counts positive %0d %0d equal %0d", packed_count > 0,
             unpacked_count > 0, packed_count == unpacked_count);
    $display("UT: values %0h %0h", target.address, target.payload);
    $finish;
  end
endmodule
