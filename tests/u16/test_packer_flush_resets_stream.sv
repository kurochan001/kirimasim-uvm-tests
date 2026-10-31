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
