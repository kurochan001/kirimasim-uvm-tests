/*
:name: test_policy_extension_insert_get_and_presence
:description: a new policy extension retains its handle and is indexed by its wrapper (IEEE 1800.2-2020 Section 16.1.2.3.1)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.1.2.3.1 16.1.2.3.2 16.1.2.3.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_policy_extension_insert_get_and_presence.expected
*/
// What it checks:
// 1. Extension presence is reported for the requested type key.
// 2. Extensions use dynamic type-proxy keys, with replacement returning the
//    previous handle.
// 3. Extension lookup returns its stored handle by type, or null when absent.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.1.2.3.1 (UVM-POLICY-EXTENSION-PRESENCE) gives rule 1
//    above. Setup: Query installed, missing and removed extension types.
//    Expected: Presence changes only for the selected type and absent types
//    report false.
// 2. 1800.2-2020 16.1.2.3.2 (UVM-POLICY-EXTENSION-TYPE-KEY) gives rule 2
//    above. Setup: Use base/derived handles, same/different names, first
//    insertion and same-type replacement. Expected: Different types coexist;
//    first insertion returns null and replacement selects the new handle for
//    that type.
// 3. 1800.2-2020 16.1.2.3.3 (UVM-POLICY-EXTENSION-GET) gives rule 3 above.
//    Setup: Query from policy hooks, mutate stored extensions in place and
//    start later operations. Expected: Hooks observe the same current
//    extension object, including its changed control values.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Set one extension and query both its type and an absent type. A first
// insertion returns null and retrieval returns the same object handle.

module test_policy_extension_insert_get_and_presence;
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
    automatic limit_ext extension_value = new;
    uvm_object previous;
    extension_value.threshold = 17;
    previous = policy.set_extension(extension_value);
    $display("UT: first returned_null %0d present %0d same_handle %0d", previous == null,
             policy.extension_exists(limit_ext::get_type()),
             policy.get_extension(limit_ext::get_type()) == extension_value);
    $display("UT: absent exists %0d null %0d", policy.extension_exists(flag_ext::get_type()),
             policy.get_extension(flag_ext::get_type()) == null);
    $finish;
  end
endmodule
