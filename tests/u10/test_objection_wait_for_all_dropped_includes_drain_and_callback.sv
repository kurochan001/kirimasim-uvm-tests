/*
:name: test_objection_wait_for_all_dropped_includes_drain_and_callback
:description: an all-dropped waiter resumes after source drain time and callback delay (IEEE 1800.2-2020 Section 10.5.1.5.2)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.5.1.5.2 10.5.1.4.3 10.5.1.3.7 10.5.1.3.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:args: +UVM_TESTNAME=t
:expected_stdout: @test_objection_wait_for_all_dropped_includes_drain_and_callback.expected
*/
// What it checks:
// Waiting for all_dropped returns after corresponding callbacks for that event
// finish.
//
// How the expected output follows from the standard:
// 1800.2-2020 10.5.1.5.2 (UVM-OBJECTION-WAIT-ALL-DROPPED) gives the rule
// above. Setup: Arm the waiter before a positive-delay producer triggers the
// selected event. Expected: The waiter returns at time 4 only after the drain
// and delayed callback complete.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The source drops at time one, drains for two units, and its callback
// consumes one further unit before the matching event releases the waiter.

module test_objection_wait_for_all_dropped_includes_drain_and_callback;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class item extends uvm_object;
    `uvm_object_utils(item)
    function new(string name="item"); super.new(name); endfunction
  endclass

  class probe_objection extends uvm_objection;
    `uvm_object_utils(probe_objection)
    bit raised_seen = 0;
    bit dropped_seen = 0;
    bit all_dropped_seen = 0;
    function new(string name="probe_objection"); super.new(name); endfunction
    function void raised(uvm_object obj, uvm_object source_obj, string description, int count);
      if (obj == source_obj) raised_seen = 1;
      super.raised(obj, source_obj, description, count);
    endfunction
    function void dropped(uvm_object obj, uvm_object source_obj, string description, int count);
      if (obj == source_obj) dropped_seen = 1;
      super.dropped(obj, source_obj, description, count);
    endfunction
    task all_dropped(uvm_object obj, uvm_object source_obj, string description, int count);
      if (obj == source_obj) begin
        #1;
        all_dropped_seen = 1;
      end
      super.all_dropped(obj, source_obj, description, count);
    endtask
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      probe_objection objection = new;
      item source = new("source");
      phase.raise_objection(this);
      objection.set_drain_time(source, 2);
      objection.raise_objection(source);
      fork
        begin
          objection.wait_for(UVM_ALL_DROPPED, source);
          $display("UT: all_dropped callback %0d source_total %0d elapsed %0d",
                   objection.all_dropped_seen, objection.get_objection_total(source), $time);
        end
        begin
          #1;
          objection.drop_objection(source);
        end
      join
      objection.clear();
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test();

  initial begin
    #20;
    $fatal(1, "test watchdog expired");
  end
endmodule
