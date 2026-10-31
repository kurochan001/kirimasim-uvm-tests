/*
:name: test_object_ids_distinguish_live_objects
:description: live objects have distinct IDs while aliases have the same ID (IEEE 1800.2-2020 Section 5.3.4.4)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.4.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_ids_distinguish_live_objects.expected
*/
// Instance IDs distinguish live objects, even when their names are equal.
// Check only identity relationships, not allocation order or numeric values.

module test_object_ids_distinguish_live_objects;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class item extends uvm_object;
    `uvm_object_utils(item)
    function new(string name="item"); super.new(name); endfunction
  endclass

  initial begin
    item first = new("same");
    item second = new("same");
    item alias_handle = first;
    int saved_id = first.get_inst_id();
    $display("UT: distinct %0d alias %0d", first.get_inst_id() != second.get_inst_id(),
             alias_handle.get_inst_id() == first.get_inst_id());
    $display("UT: stable %0d", first.get_inst_id() == saved_id);
    $finish;
  end
endmodule
