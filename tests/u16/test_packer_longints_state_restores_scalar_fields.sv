/*
:name: test_packer_longints_state_restores_scalar_fields
:description: a longints state snapshot restores scalar fields in a compatible packer (IEEE 1800.2-2020 Section 16.5.3.1)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.5.3.1 16.5.3.2 16.5.3.3 16.5.4.9 16.5.4.17 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_packer_longints_state_restores_scalar_fields.expected
*/
// What it checks:
// 1. Typed packer state assignment preserves data for compatible same-type
//    stream operations.
// 2. Typed packer state retrieval preserves data for compatible same-type
//    stream operations.
// 3. get_packed_size reports the remaining number of unpackable bits.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.5.3.1 (UVM-PACKER-STATE-ASSIGN) gives rule 1 above. Setup:
//    Transfer bit/byte/int/longint snapshots between instances of one packer
//    implementation. Expected: The consumer restores fields in order without
//    consuming the producer state.
// 2. 1800.2-2020 16.5.3.2 (UVM-PACKER-STATE-RETRIEVE) gives rule 2 above.
//    Setup: Transfer bit/byte/int/longint snapshots between instances of one
//    packer implementation. Expected: The consumer restores fields in order
//    without consuming the producer state.
// 3. 1800.2-2020 16.5.3.3 (UVM-PACKER-AVAILABLE-BITS) gives rule 3 above.
//    Setup: Inspect producers and consumers before/after field reads.
//    Expected: Only the consumer size decreases with reads, reaching zero
//    after all fields are consumed.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Both instances use the same packer implementation. Its own typed
// state snapshot is transferred without prescribing array size or encoding.

module test_packer_longints_state_restores_scalar_fields;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_packer producer = new;
    automatic uvm_packer consumer = new;
    longint unsigned stream[];
    uvm_integral_t first;
    uvm_integral_t second;
    producer.pack_field_int(64'h8123456789, 40);
    producer.pack_field_int(64'h12ab, 13);
    consumer.pack_field_int(5, 3);
    producer.get_packed_longints(stream);
    consumer.set_packed_longints(stream);
    $display("UT: available producer %0d consumer %0d", producer.get_packed_size(),
        consumer.get_packed_size());
    first = consumer.unpack_field_int(40);
    second = consumer.unpack_field_int(13);
    $display("UT: values %0h %0h", first[39:0], second[12:0]);
    $display("UT: remaining consumer %0d producer %0d", consumer.get_packed_size(),
        producer.get_packed_size());
    $finish;
  end
endmodule
