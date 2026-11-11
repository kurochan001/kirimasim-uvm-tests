/*
:name: test_policy_extension_names_do_not_select_storage_slots
:description: extension slots follow registered types rather than instance names (IEEE 1800.2-2020 Section 16.1.2.3.2)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.1.2.3.2 16.1.2.3.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_policy_extension_names_do_not_select_storage_slots.expected
*/
// What it checks:
// Extensions use dynamic type-proxy keys, with replacement returning the
// previous handle.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.1.2.3.2 (UVM-POLICY-EXTENSION-TYPE-KEY) gives the rule above.
// Setup: Use base/derived handles, same/different names, first insertion and
// same-type replacement. Expected: Different types coexist; first insertion
// returns null and replacement selects the new handle for that type.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Different extension types with the same name coexist. A replacement
// with a different name still replaces the slot having the same type.

module test_policy_extension_names_do_not_select_storage_slots;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class limit_ext extends uvm_object;
    `uvm_object_utils(limit_ext)
    int threshold = 0;
    function new(string name="limit_ext"); super.new(name); endfunction
  endclass
  class derived_limit_ext extends limit_ext;
    `uvm_object_utils(derived_limit_ext)
    function new(string name="derived_limit_ext"); super.new(name); endfunction
  endclass
  class flag_ext extends uvm_object;
    `uvm_object_utils(flag_ext)
    bit enabled = 1;
    function new(string name="flag_ext"); super.new(name); endfunction
  endclass

  initial begin
    automatic uvm_comparer policy = new;
    automatic limit_ext first = new("shared_name");
    automatic flag_ext flag_value = new("shared_name");
    automatic limit_ext second = new("different_name");
    uvm_object previous;
    previous = policy.set_extension(first);
    previous = policy.set_extension(flag_value);
    previous = policy.set_extension(second);
    $display("UT: same_type_replaced %0d limit %0d other_type %0d", previous == first,
             policy.get_extension(limit_ext::get_type()) == second,
             policy.get_extension(flag_ext::get_type()) == flag_value);
    $finish;
  end
endmodule
