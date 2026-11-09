/*
:name: test_object_names_are_independent
:description: setting one object name leaves another object unchanged (IEEE 1800.2-2020 Section 5.3.4.1)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.4.1 5.3.4.2 5.3.4.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_names_are_independent.expected
*/
// What it checks:
// 1. set_name replaces the selected object instance name.
// 2. A plain object full name follows its instance name.
// 3. get_name returns an empty string after explicit clearing.
// 4. A peer retains its own supplied instance name.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.3.4.1 (UVM-OBJECT-RENAME) gives rule 1 above. Setup: Rename
//    or clear one object name while another has the same original name.
//    Expected: Only the selected object name changes.
// 2. 1800.2-2020 5.3.4.3 (UVM-OBJECT-PLAIN-FULL-NAME) gives rule 2 above.
//    Setup: Use objects without component hierarchy and change their names.
//    Expected: get_name and get_full_name agree, including the empty name.
// 3. 1800.2-2020 5.3.4.2 (UVM-OBJECT-TRAIT-EXISTING-EMPTY-NAME) gives rule 3
//    above. Setup: An unchanged fixture clears one of two equally named
//    objects. Expected: The cleared name is empty.
// 4. 1800.2-2020 5.3.4.2 (UVM-OBJECT-TRAIT-EXISTING-PEER-NAME) gives rule 4
//    above. Setup: Only the other object is renamed. Expected: The peer still
//    returns shared.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Names belong to individual objects. Clearing one name changes both of
// its accessors, without renaming another object that shared the old name.

module test_object_names_are_independent;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class named_object extends uvm_object;
    `uvm_object_utils(named_object)
    function new(string name=""); super.new(name); endfunction
  endclass
initial begin
    automatic named_object first = new("shared");
    automatic named_object second = new("shared");
  first.set_name("");
  $display("UT: first empty %0d %0d", first.get_name() == "", first.get_full_name() == "");
  $display("UT: second %s %s", second.get_name(), second.get_full_name());
  $finish;
end
endmodule
