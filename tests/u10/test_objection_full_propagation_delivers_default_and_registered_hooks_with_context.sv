/*
:name: test_objection_full_propagation_delivers_default_and_registered_hooks_with_context
:description: objection full propagation delivers default and registered hooks with context (IEEE 1800.2-2020 Section 10.5.1.4.1)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.5.1.4.1 10.5.1.3.1 10.5.1.3.3 10.5.1.3.4 10.5.1.3.7 10.5.1.4.2 10.5.1.4.3 10.5.1.5.3 10.5.1.5.4 10.5.2.2.1 10.5.2.2.2 10.5.2.2.3 D.4.2 13.1.6.1 13.1.6.2 13.1.6.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_objection_full_propagation_delivers_default_and_registered_hooks_with_context.expected
*/
// Use the actual default objection hooks, original component hooks and a
// registered callback, with source/description/count identity and real drain
// and callback delays. Mode zero skips intermediate callbacks; the public
// total
// query still describes the source plus descendants. No relative ordering
// between component and registered callback bodies or private maps is
// asserted.
module test_objection_full_propagation_delivers_default_and_registered_hooks_with_context;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  uvm_objection expected_objection;
  uvm_object expected_source;
  string expected_description;
  int expected_count;
  bit component_metadata = 1,drain_order_ok = 1;
  class node extends uvm_component;
    int raises = 0,drops = 0,all_drops = 0;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void raised(uvm_objection objection,uvm_object source,string description,int count);
      if (objection == expected_objection) begin
        raises++; component_metadata &= source == expected_source;
        component_metadata &= description == expected_description && count == expected_count;
      end
    endfunction
    function void dropped(uvm_objection objection,uvm_object source,string description,int count);
      if (objection == expected_objection) begin
        drops++; component_metadata &= source == expected_source;
        component_metadata &= description == expected_description && count == expected_count;
      end
    endfunction
    task all_dropped(uvm_objection objection,uvm_object source,string description,int count);
      if (objection == expected_objection) begin
        if (this == expected_source) begin
          drain_order_ok &= $time >= 2; #1;
          drain_order_ok &= expected_objection.get_objection_total(uvm_root::get()) == 1;
        end
        all_drops++; component_metadata &= source == expected_source;
        component_metadata &= description == expected_description && count == expected_count;
      end
    endtask
  endclass
  class registered_probe extends uvm_objection_callback;
    int r[uvm_object],d[uvm_object],a[uvm_object];
    bit metadata_ok = 1;
    function new();
      super.new("registered"); void'(callback_mode(1));
    endfunction
    function int raised_at(uvm_object obj); return r.exists(obj) ? r[obj] : 0; endfunction
    function int dropped_at(uvm_object obj); return d.exists(obj) ? d[obj] : 0; endfunction
    function int all_at(uvm_object obj); return a.exists(obj) ? a[obj] : 0; endfunction
    function void raised(uvm_objection objection,uvm_object obj,uvm_object source,
                         string description,int count);
      r[obj] = raised_at(obj) + 1;
      metadata_ok &= objection == expected_objection && source == expected_source;
      metadata_ok &= description == expected_description && count == expected_count;
    endfunction
    function void dropped(uvm_objection objection,uvm_object obj,uvm_object source,
                          string description,int count);
      d[obj] = dropped_at(obj) + 1;
      metadata_ok &= objection == expected_objection && source == expected_source;
      metadata_ok &= description == expected_description && count == expected_count;
    endfunction
    task all_dropped(uvm_objection objection,uvm_object obj,uvm_object source,
                     string description,int count);
      if (obj == expected_source) begin
        drain_order_ok &= $time >= 2; #2;
        drain_order_ok &= expected_objection.get_objection_total(uvm_root::get()) == 1;
      end
      a[obj] = all_at(obj) + 1;
      metadata_ok &= objection == expected_objection && source == expected_source;
      metadata_ok &= description == expected_description && count == expected_count;
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    node parent_value,middle,leaf;
    uvm_objection subject;
    registered_probe probe;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase); parent_value = new("parent_value",this);
      middle = new("middle",parent_value); leaf = new("leaf",middle);
      subject = new("subject"); probe = new();
      expected_objection = subject; expected_source = leaf;
      subject.set_drain_time(leaf,2); uvm_objection_cbs_t::add(subject,probe);

    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      expected_description = "held"; expected_count = 2;
      subject.raise_objection(leaf,"held",2);
      $display("UT: objection_raised_totals %0d/%0d/%0d/%0d local %0d/%0d",
               subject.get_objection_total(leaf),subject.get_objection_total(middle),
               subject.get_objection_total(parent_value),
             subject.get_objection_total(uvm_root::get()),
               subject.get_objection_count(leaf),subject.get_objection_count(middle));
      expected_description = "partial"; expected_count = 1;
      subject.drop_objection(leaf,"partial",1);
      $display("UT: objection_partial_totals %0d/%0d/%0d/%0d local %0d/%0d",
               subject.get_objection_total(leaf),subject.get_objection_total(middle),
               subject.get_objection_total(parent_value),
             subject.get_objection_total(uvm_root::get()),
               subject.get_objection_count(leaf),subject.get_objection_count(middle));
      expected_description = "final"; subject.drop_objection(leaf,"final",1); #10;
      $display("UT: component_hooks raised %0d/%0d/%0d dropped %0d/%0d/%0d all %0d/%0d/%0d",
               leaf.raises,middle.raises,parent_value.raises,leaf.drops,middle.drops,
               parent_value.drops,leaf.all_drops,middle.all_drops,parent_value.all_drops);
      $display("UT: registered_hooks raised %0d/%0d/%0d/%0d dropped %0d/%0d/%0d/%0d",
               probe.raised_at(leaf),probe.raised_at(middle),probe.raised_at(parent_value),
               probe.raised_at(uvm_root::get()),probe.dropped_at(leaf),probe.dropped_at(middle),
               probe.dropped_at(parent_value),probe.dropped_at(uvm_root::get()));
      $display("UT: registered_all %0d/%0d/%0d/%0d meta %0d/%0d totals %0d/%0d drain %0d",
               probe.all_at(leaf),probe.all_at(middle),probe.all_at(parent_value),
               probe.all_at(uvm_root::get()),component_metadata,probe.metadata_ok,
               subject.get_objection_total(leaf),subject.get_objection_total(uvm_root::get()),
               drain_order_ok);
      uvm_objection_cbs_t::delete(subject,probe); phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1,"objection hierarchy watchdog expired"); end
endmodule
