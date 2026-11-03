/*
:name: test_sequence_parent_reassignment_updates_calculated_depth_root_and_path
:description: parent changes update automatic sequence hierarchy queries after earlier observations (14.1.2.8)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.1.2.8 14.1.2.7 14.1.2.9 14.1.2.12 14.1.2.13 14.1.2.14 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_parent_reassignment_updates_calculated_depth_root_and_path.expected
*/
// The pinned get_depth cache survives parent replacement and clearing.
// With no explicit set_depth, retain the current-chain depth requirement.
module test_sequence_parent_reassignment_updates_calculated_depth_root_and_path;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class empty_sequence extends uvm_sequence#(uvm_sequence_item);
    function new(string name); super.new(name); endfunction
    task body(); endtask
  endclass
  // Without a set_depth override, the current parent chain defines depth.
  initial begin
    automatic empty_sequence first = new("first");
    automatic empty_sequence middle = new("middle");
    automatic empty_sequence second = new("second");
    automatic empty_sequence leaf = new("leaf");
    middle.set_parent_sequence(first); leaf.set_parent_sequence(middle);
    $display("UT: initial depth %0d root %0d path %s", leaf.get_depth(),
             leaf.get_root_sequence() == first, leaf.get_sequence_path());
    leaf.set_parent_sequence(second);
    $display("UT: changed depth %0d parent %0d root %0d root_name %s path %s",
             leaf.get_depth(), leaf.get_parent_sequence() == second,
             leaf.get_root_sequence() == second, leaf.get_root_sequence_name(),
             leaf.get_sequence_path());
    leaf.set_parent_sequence(null);
    $display("UT: detached depth %0d parent_null %0d", leaf.get_depth(),
             leaf.get_parent_sequence() == null);
    $finish;
  end
endmodule
