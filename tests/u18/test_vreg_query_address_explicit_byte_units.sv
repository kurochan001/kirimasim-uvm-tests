/*
:name: test_vreg_query_address_explicit_byte_units
:description: The virtual element external address uses the selected map address units.
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.2.15 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.4 18.6.3.1 18.6.3.2 18.9.1.1.1 18.9.1.1.2 18.2.4.6 18.6.4.16 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_query_address_explicit_byte_units.expected
:files: helpers70/vreg_query_fixture70.svh
*/
// What it checks:
// The virtual element external address uses the selected map address units.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.9.1.2.15 (UVM-VREG-QUERY-ADDRESS-EXPLICIT-BYTE-UNITS) gives
// the rule above. Setup: Use byte addressing: map base 0x1000, memory offset
// 0x80, element word offset 19 at two bytes each. Expected: The stated
// identity, count, policy, offset or diagnostic-presence observations match.
// It also supports, as a control, the setup or conditions of
// UVM-VREG-QUERY-ADDRESS-UNRELATED-MAP-WARNS-WITHOUT-PRESCRIBING-VALUE.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Independently derived model observations; original testbench setup.
module
  test_vreg_query_address_explicit_byte_units;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "vreg_query_fixture70.svh"
initial begin
    automatic model70 m=new(.word_mode(0));
    m.owner.lock_model();
    $display("UT: address_byte unit_bytes %0d address %0h",
      m.rw_map.get_addr_unit_bytes(),m.vr.get_address(2,m.rw_map));
    $finish;
  end
endmodule
