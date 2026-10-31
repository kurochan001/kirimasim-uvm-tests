/*
:name: test_object_rename_updates_identity
:description: renaming a plain object updates its name and full name (IEEE 1800.2-2020 Section 5.3.4.1)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.4.1 5.3.4.2 5.3.4.3
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_rename_updates_identity.expected
*/
// The name accessors follow set_name. A plain object has no component
// hierarchy, so its full name follows its instance name as well.

module test_object_rename_updates_identity;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class named_object extends uvm_object;
    `uvm_object_utils(named_object)
    function new(string name=""); super.new(name); endfunction
  endclass
initial begin
    named_object item = new("before");
  $display("UT: initial %s %s", item.get_name(), item.get_full_name());
  item.set_name("after");
  $display("UT: renamed %s %s", item.get_name(), item.get_full_name());
  $finish;
end
endmodule
