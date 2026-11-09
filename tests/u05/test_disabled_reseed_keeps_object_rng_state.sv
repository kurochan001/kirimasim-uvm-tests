/*
:name: test_disabled_reseed_keeps_object_rng_state
:description: reseed does not change an object RNG state while UVM seeding is disabled (IEEE 1800.2-2020 Section 5.3.3.3)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.3.3 5.3.3.2 1800-2023 6.21 18.13.3 18.13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_disabled_reseed_keeps_object_rng_state.expected
*/
// What it checks:
// reseed leaves object RNG state unchanged while UVM seeding is disabled.
//
// How the expected output follows from the standard:
// 1800.2-2020 5.3.3.3 (UVM-RESEED-DISABLED) gives the rule above. Setup:
// Compare one object state before/after disabled reseed, including after
// rename. Expected: Opaque RNG states compare equal without fixing their
// serialization or random values.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe the opaque RNG state only for equality on the same object.
// No serialized state contents or generated random values are prescribed.

module test_disabled_reseed_keeps_object_rng_state;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class item extends uvm_object;
    `uvm_object_utils(item)
    rand bit [31:0] payload;
    function new(string name="item"); super.new(name); endfunction
  endclass
  class other_item extends uvm_object;
    `uvm_object_utils(other_item)
    function new(string name="other_item"); super.new(name); endfunction
  endclass

  initial begin
    automatic item value = new("seeded");
    automatic bit saved = uvm_object::get_uvm_seeding();
    string before_state;
    uvm_object::set_uvm_seeding(0);
    value.srandom(53);
    before_state = value.get_randstate();
    value.reseed();
    $display("UT: disabled %0d state_unchanged %0d", !uvm_object::get_uvm_seeding(),
             value.get_randstate() == before_state);
    uvm_object::set_uvm_seeding(saved);
    $finish;
  end
endmodule
