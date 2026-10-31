/*
:name: test_sequence_starting_phase_and_objection_controls_are_per_instance
:description: sequence starting phase and automatic-objection controls retain assigned instance values (IEEE 1800.2-2020 Section 14.2.4.1)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.4.1 14.2.4.2 14.2.4.3 14.2.4.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_starting_phase_and_objection_controls_are_per_instance.expected
*/
// Assign controls before reading them because getters may lock their
// values. Do not execute a sequence against these isolated phase handles.

module test_sequence_starting_phase_and_objection_controls_are_per_instance;
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
    automatic uvm_phase first_phase = new("first_phase", UVM_PHASE_SCHEDULE);
    automatic uvm_phase second_phase = new("second_phase", UVM_PHASE_SCHEDULE);
    first.set_starting_phase(first_phase);
    second.set_starting_phase(second_phase);
    first.set_automatic_phase_objection(1);
    second.set_automatic_phase_objection(0);
    $display("UT: phases_same %0d %0d", first.get_starting_phase() == first_phase,
        second.get_starting_phase() == second_phase);
    $display("UT: auto_objections %0d %0d", first.get_automatic_phase_objection(),
        second.get_automatic_phase_objection());
    $finish;
  end
endmodule
