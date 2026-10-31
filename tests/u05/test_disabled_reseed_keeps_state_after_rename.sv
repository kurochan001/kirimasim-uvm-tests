/*
:name: test_disabled_reseed_keeps_state_after_rename
:description: disabled reseed leaves the object RNG state unchanged after a name change (IEEE 1800.2-2020 Section 5.3.3.3)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.3.3 5.3.3.2 5.3.4.1 5.3.4.2 1800-2023 6.21 18.13.3 18.13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_disabled_reseed_keeps_state_after_rename.expected
*/
// Take the RNG snapshot after renaming, then call the disabled reseed
// twice. Compare only the before and after state of this single object.

module test_disabled_reseed_keeps_state_after_rename;
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
    automatic item value = new("original");
    automatic bit saved = uvm_object::get_uvm_seeding();
    string before_state;
    uvm_object::set_uvm_seeding(0);
    value.srandom(97);
    value.set_name("renamed");
    before_state = value.get_randstate();
    value.reseed();
    value.reseed();
    $display("UT: name %s state_unchanged %0d", value.get_name(),
        value.get_randstate() == before_state);
    uvm_object::set_uvm_seeding(saved);
    $finish;
  end
endmodule
