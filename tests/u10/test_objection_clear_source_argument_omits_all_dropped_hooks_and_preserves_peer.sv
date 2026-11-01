/*
:name: test_objection_clear_source_argument_omits_all_dropped_hooks_and_preserves_peer
:description: a clear source argument changes neither global clearing nor dropped-hook suppression (IEEE 1800.2-2020 Section 10.5.1.3.5)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.5.1.3.5 10.5.1.3.3 10.5.1.3.4 10.5.1.4.2 10.5.2.2.2 D.4.2 10.5.1.5.3 10.5.1.5.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_objection_clear_source_argument_omits_all_dropped_hooks_and_preserves_peer.expected
*/
// Clear two sources while another objection instance stays raised.
// Normal partial drops on both sources establish a working callback control.
module test_objection_clear_source_argument_omits_all_dropped_hooks_and_preserves_peer;
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
    uvm_objection peer;
    drop_probe callback;
    item first;
    item second;
    objection = new();
    peer = new("peer");
    callback = new();
    first = new("first");
    second = new("second");
    uvm_objection_cbs_t::add(objection, callback);
    objection.raise_objection(first, "first", 2);
    objection.raise_objection(second, "second", 3);
    peer.raise_objection(first);
    objection.clear(first);
    #1;
    $display("UT: sources %0d %0d total %0d hooks %0d %0d peer %0d",
             objection.get_objection_count(first), objection.get_objection_count(second),
             objection.get_objection_total(), objection.source_drops, callback.source_drops,
             peer.get_objection_count(first));
    objection.raise_objection(first, "first control", 2);
    objection.raise_objection(second, "second control", 2);
    objection.drop_objection(first);
    objection.drop_objection(second);
    $display("UT: control total %0d hooks %0d %0d", objection.get_objection_total(),
             objection.source_drops, callback.source_drops);
    objection.clear(second);
    peer.clear();
    #1;
    $display("UT: final total %0d hooks %0d %0d", objection.get_objection_total(),
             objection.source_drops, callback.source_drops);
    uvm_objection_cbs_t::delete(objection, callback);
    $finish;
  end
endmodule
