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
