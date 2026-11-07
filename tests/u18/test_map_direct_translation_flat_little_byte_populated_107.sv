/*
:name: test_map_direct_translation_flat_little_byte_populated_107
:description: direct physical-address translation checks flat_little_byte_populated full-beat widths, data order and reused result arrays (IEEE 1800.2-2020 Section 18.2.4.16)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.4.16 17.2.2.4 18.2.4.5 18.2.4.6 18.2.4.4 18.2.4.1 18.2.4.3 18.1.2.3 18.1.2.6 18.1.2.1 18.1.2.2 18.2.3.2 18.2.3.3 18.4.2.1 18.4.2.2 18.5.3.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_map_direct_translation_flat_little_byte_populated_107.expected
:files: helpers107_map_translation/translation107.svh
*/
// Expectations are frozen from the cited standard before measurement.
// Empty and populated shapes have the same API obligations; added registers
// are unrelated setup controls, not an invented translation prerequisite.
// Full-beat return widths are checked independently of address enumeration.
// Partial return widths, when printed as DIAG107, are not an oracle.
module test_map_direct_translation_flat_little_byte_populated_107;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "translation107.svh"
  initial begin
    exercise107(4, 4, UVM_LITTLE_ENDIAN, 1,
                0, 1, 0, 1);
    $finish;
  end
endmodule
