/*
:name: test_payload_unpack_observed_data_112
:description: payload unpack values and first setter visits, observed/data (IEEE 1800.2-2020 Section 12.3.4.2.5)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.5 12.3.4.2.4 12.3.4.2.15 12.3.4.2.23 12.3.4.2.17 12.3.4.2.27 12.3.4.2.34 12.3.4.2.25 12.3.4.2.37 12.3.4.2.33 12.3.4.2.31 12.3.4.2.29 12.3.4.2.24 12.3.4.2.30 12.3.4.2.43 12.3.4.2.44 12.3.4.5.4 12.3.4.1.1 12.3.4.1.2 16.5.4.9 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_payload_unpack_observed_data_112.expected
:files: helpers112_unpack/payload_unpack112.svh
*/
// What it checks:
// 1. Default generic-payload unpacking leaves preinstalled destination
//    extensions untouched.
// 2. Default generic-payload unpack applies the incoming listed scalar fields
//    and active data/enable prefixes.
// 3. Under the literal named-setter reading, default payload unpack visits the
//    nine virtual setters in the listed order.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.4.2.5 (UVM-GP-DEFAULT-UNPACK-PRESERVES-EXTENSIONS) gives
//    rule 1 above. Setup: Unpack ordinary payload fields into a target with an
//    existing valued extension. In additional independent profiles, apply a
//    hand-written typed packer stream to a plain or original observed payload,
//    with empty/nonempty active arrays, retained extension value 63 and two
//    rounds on the same target. Expected: Address updates while extension
//    identity/value remain and its unpack hook is not called. After each added
//    unpack, the original extension handle and value 63 remain and its unpack
//    hook has not run, while ordinary scalar and active-prefix fields receive
//    the incoming values.
// 2. 1800.2-2020 12.3.4.2.5 (UVM-GP-UNPACK-TYPED-FIELDS-112) gives rule 2
//    above. Setup: Write the nine logical fields with public typed packer
//    operations using their declared widths/order, then call the actual
//    inherited do_unpack through a payload base handle. Use plain/observed
//    targets, empty/nonempty arrays, distinct sentinels and two target-reuse
//    rounds. Expected: Address, command, data length, DMI, response, enable
//    length and streaming width match the incoming values; every active
//    data/enable byte matches. The previous sentinel values are replaced in
//    both rounds.
// 3. 1800.2-2020 12.3.4.2.5 (UVM-GP-UNPACK-LISTED-SETTER-FIRST-ORDER-112)
//    gives rule 3 above. Setup: An original subtype overrides the exact nine
//    public setter signatures and forwards to super without overriding
//    do_unpack. Calibrate direct base-view calls in reverse order, clear the
//    observer, then invoke actual inherited unpack for empty/nonempty
//    independent streams over two rounds. Plain targets are controls.
//    Expected: Each setter is visited at least once and first visits follow
//    address, command, data length, DMI, data, response, enable length,
//    enables and width. The separate direct-call calibration follows its
//    explicit reverse order.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A typed public packer writer supplies independent field inputs.
// The observed interpretation follows the named setters in 12.3.4.2.5
// and virtual accessors in .15. Exact invocation counts are diagnostic.
// Only first visits are ordered; raw stream layout and unused array
// capacity are not oracles. This does not override do_unpack.
module test_payload_unpack_observed_data_112;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam bit OBSERVE112=1;
  localparam bit EMPTY112=0;
  `include "payload_unpack112.svh"
  initial begin exercise112(); $finish; end
endmodule
