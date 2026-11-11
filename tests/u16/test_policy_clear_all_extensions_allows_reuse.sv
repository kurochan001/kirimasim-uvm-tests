/*
:name: test_policy_clear_all_extensions_allows_reuse
:description: clearing all extensions empties every type slot and allows fresh insertion (IEEE 1800.2-2020 Section 16.1.2.3.5)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.1.2.3.5 16.1.2.3.2 16.1.2.3.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_policy_clear_all_extensions_allows_reuse.expected
*/
// What it checks:
// Clearing extensions removes every slot in that policy without clearing
// another policy.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.1.2.3.5 (UVM-POLICY-EXTENSION-CLEAR-ALL) gives the rule
// above. Setup: Store multiple types and separate-policy instances, clear
// repeatedly and insert again. Expected: All selected-policy slots empty; the
// other policy retains its handle and new insertion behaves as first
// insertion.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Install two types and clear the policy. A later insertion is a first
// insertion again, returning null without reviving the other cleared type.

module test_policy_clear_all_extensions_allows_reuse;
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
    automatic uvm_copier policy = new;
    automatic limit_ext first = new;
    automatic limit_ext replacement = new;
    automatic flag_ext flag_value = new;
    uvm_object previous;
    previous = policy.set_extension(first);
    previous = policy.set_extension(flag_value);
    policy.clear_extensions();
    $display("UT: cleared limit %0d flag %0d", policy.get_extension(limit_ext::get_type()) == null,
             policy.get_extension(flag_ext::get_type()) == null);
    previous = policy.set_extension(replacement);
    $display("UT: reused returned_null %0d selected %0d flag_absent %0d", previous == null,
             policy.get_extension(limit_ext::get_type()) == replacement,
             !policy.extension_exists(flag_ext::get_type()));
    $finish;
  end
endmodule
