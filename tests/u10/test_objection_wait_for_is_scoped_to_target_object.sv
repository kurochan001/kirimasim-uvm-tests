/*
:name: test_objection_wait_for_is_scoped_to_target_object
:description: a drop on another source does not release a target-specific waiter (IEEE 1800.2-2020 Section 10.5.1.5.2)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.5.1.5.2 10.5.1.3.4 10.5.1.5.3
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:args: +UVM_TESTNAME=t
:expected_stdout: @test_objection_wait_for_is_scoped_to_target_object.expected
*/
// Both sources retain nonzero counts after their drops. Inspect the
// waiter one time unit after the unrelated drop and before the matching drop.

module test_objection_wait_for_is_scoped_to_target_object;
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
      item first = new("first");
      item second = new("second");
      bit awakened = 0;
      phase.raise_objection(this);
      objection.raise_objection(first, "first", 2);
      objection.raise_objection(second, "second", 2);
      fork
        begin
          objection.wait_for(UVM_DROPPED, first);
          awakened = 1;
        end
        begin
          #1;
          objection.drop_objection(second);
          #1;
          $display("UT: after unrelated drop awakened %0d", awakened);
          #1;
          objection.drop_objection(first);
        end
      join
      $display("UT: matching drop awakened %0d counts %0d %0d elapsed %0d", awakened,
               objection.get_objection_count(first), objection.get_objection_count(second), $time);
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
