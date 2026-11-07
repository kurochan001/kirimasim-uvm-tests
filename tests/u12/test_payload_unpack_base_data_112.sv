/*
:name: test_payload_unpack_base_data_112
:description: payload unpack values and first setter visits, base/data (IEEE 1800.2-2020 Section 12.3.4.2.5)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.5 12.3.4.2.4 12.3.4.2.15 12.3.4.2.23 12.3.4.2.17 12.3.4.2.27 12.3.4.2.34 12.3.4.2.25 12.3.4.2.37 12.3.4.2.33 12.3.4.2.31 12.3.4.2.29 12.3.4.2.24 12.3.4.2.30 12.3.4.2.43 12.3.4.2.44 12.3.4.5.4 12.3.4.1.1 12.3.4.1.2 16.5.4.9 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_payload_unpack_base_data_112.expected
:files: helpers112_unpack/payload_unpack112.svh
*/
// A typed public packer writer supplies independent field inputs.
// The observed interpretation follows the named setters in 12.3.4.2.5
// and virtual accessors in .15. Exact invocation counts are diagnostic.
// Only first visits are ordered; raw stream layout and unused array
// capacity are not oracles. This does not override do_unpack.
module test_payload_unpack_base_data_112;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam bit OBSERVE112=0;
  localparam bit EMPTY112=0;
  `include "payload_unpack112.svh"
  initial begin exercise112(); $finish; end
endmodule
