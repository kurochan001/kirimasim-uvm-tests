/*
:name: test_objection_clear_omits_dropped_hooks_before_and_after_partial_drop
:description: clear resets state without method or registered dropped callbacks (IEEE 1800.2-2020 Section 10.5.1.3.5)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.5.1.3.5 10.5.1.3.3 10.5.1.3.4 10.5.1.4.2 10.5.2.2.2 D.4.2 10.5.1.5.3 10.5.1.5.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_objection_clear_omits_dropped_hooks_before_and_after_partial_drop.expected
*/
// What it checks:
// Clearing objection state does not execute the normal dropped callback.
//
// How the expected output follows from the standard:
// 1800.2-2020 10.5.1.3.5 (UVM-OBJECTION-CLEAR-NO-DROPPED-CALLBACK) gives the
// rule above. Setup: Install a dropped-callback probe, raise objections and
// then clear directly. Expected: State resets while the dropped callback count
// stays unchanged.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A normal partial drop proves both probes are connected. Positive delays
// also expose callbacks incorrectly deferred beyond clear's return.
module test_objection_clear_omits_dropped_hooks_before_and_after_partial_drop;
  import uvm_pkg::*;

  class item extends uvm_object;
    function new(string name="item"); super.new(name); endfunction
  endclass
  class probe_objection extends uvm_objection;
    int source_drops = 0;
    function new(string name="objection"); super.new(name); endfunction
    virtual function void dropped(uvm_object obj, uvm_object source_obj,
                                  string description, int count);
      if (obj == source_obj) source_drops++;
      super.dropped(obj, source_obj, description, count);
    endfunction
  endclass
  class drop_probe extends uvm_objection_callback;
    int source_drops = 0;
    function new(string name="drop_probe"); super.new(name); endfunction
    virtual function void dropped(uvm_objection objection, uvm_object obj,
                                  uvm_object source_obj, string description, int count);
      if (obj == source_obj) source_drops++;
    endfunction
  endclass

  initial begin
    probe_objection objection;
    drop_probe callback;
    item source;
    objection = new();
    callback = new();
    source = new("source");
    uvm_objection_cbs_t::add(objection, callback);
    objection.raise_objection(source, "initial", 2);
    objection.clear();
    #1;
    $display("UT: cleared source %0d total %0d hooks %0d %0d",
             objection.get_objection_count(source), objection.get_objection_total(),
             objection.source_drops, callback.source_drops);
    objection.raise_objection(source, "control", 2);
    objection.drop_objection(source, "partial", 1);
    $display("UT: control remaining %0d hooks %0d %0d", objection.get_objection_count(source),
             objection.source_drops, callback.source_drops);
    objection.clear();
    #1;
    $display("UT: recleared total %0d hooks %0d %0d", objection.get_objection_total(),
             objection.source_drops, callback.source_drops);
    uvm_objection_cbs_t::delete(objection, callback);
    $finish;
  end
endmodule
