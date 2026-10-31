/*
:name: test_sequence_randomize_enabled_defaults_and_updates_are_local
:description: sequence randomization enable controls default to one and update independently (IEEE 1800.2-2020 Section 14.2.2.2)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.2.2 14.2.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_randomize_enabled_defaults_and_updates_are_local.expected
*/
// Inspect only the enable controls. This case does not randomize data
// or claim to cover the macros that perform automatic randomization.

module test_sequence_randomize_enabled_defaults_and_updates_are_local;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class empty_sequence extends uvm_sequence#(uvm_sequence_item);
    `uvm_object_utils(empty_sequence)
    function new(string name="empty_sequence"); super.new(name); endfunction
    task body(); endtask
  endclass

  initial begin
    automatic empty_sequence first = new("first");
    automatic empty_sequence second = new("second");
    $display("UT: defaults %0d %0d", first.get_randomize_enabled(), second.get_randomize_enabled());
    first.set_randomize_enabled(0);
    $display("UT: first_disabled %0d %0d", first.get_randomize_enabled(),
        second.get_randomize_enabled());
    first.set_randomize_enabled(1);
    second.set_randomize_enabled(0);
    $display("UT: updated %0d %0d", first.get_randomize_enabled(), second.get_randomize_enabled());
    $finish;
  end
endmodule
