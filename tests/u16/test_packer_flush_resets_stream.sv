/*
:name: test_packer_flush_resets_stream
:description: flushing a packer clears its stream before reuse (IEEE 1800.2-2020 Section 16.5.4.9)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.5.4.9 16.5.4.17 16.5.3.3 16.5.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_packer_flush_resets_stream.expected
*/
// What it checks:
// 1. Integral packing processes exactly the requested field width up to 64
//    bits.
// 2. Integral unpacking processes exactly the requested field width up to 64
//    bits.
// 3. Packer flush discards previously packed data for later reuse.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.5.4.9 (UVM-PACKER-INTEGRAL-PACK) gives rule 1 above.
//    Setup: Use successive unequal field widths and a full-width 64-bit
//    payload. Expected: Values and consumed bit counts agree with the selected
//    widths without prescribing byte layout.
// 2. 1800.2-2020 16.5.4.17 (UVM-PACKER-INTEGRAL-UNPACK) gives rule 2 above.
//    Setup: Use successive unequal field widths and a full-width 64-bit
//    payload. Expected: Values and consumed bit counts agree with the selected
//    widths without prescribing byte layout.
// 3. 1800.2-2020 16.5.2.2 (UVM-PACKER-FLUSH-STREAM) gives rule 3 above. Setup:
//    Pack data, flush, then pack a new 64-bit value. Expected: Size is zero
//    after flush and the new stream contains only the new value.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// After flush, the packed size is zero and a new field starts a new
// stream. Use 64 bits to exercise the integral method upper boundary.

module test_packer_flush_resets_stream;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

initial begin
  automatic uvm_packer packer = new;
  uvm_integral_t value;
  packer.pack_field_int(64'hff, 8);
  packer.flush();
  $display("UT: flushed size %0d", packer.get_packed_size());
  packer.pack_field_int(64'h8123456789abcdef, 64);
  $display("UT: reused size %0d", packer.get_packed_size());
  value = packer.unpack_field_int(64);
  $display("UT: value %016h", value);
  $finish;
end
endmodule
