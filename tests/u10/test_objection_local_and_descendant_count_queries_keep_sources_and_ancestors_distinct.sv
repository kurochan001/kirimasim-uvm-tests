/*
:name: test_objection_local_and_descendant_count_queries_keep_sources_and_ancestors_distinct
:description: objection local and descendant count queries keep sources and ancestors distinct (IEEE 1800.2-2020 Section 10.5.1.5.3)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.5.1.5.3 10.5.1.5.4 10.5.1.3.3 10.5.1.3.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_objection_local_and_descendant_count_queries_keep_sources_and_ancestors_distinct.expected
*/
// Real source raises and partial/final drops distinguish local counts from
// descendant totals. The root is supplied explicitly; no undocumented null-
// query
// meaning, private maps, exact zero-delay optimization or drain race is
// inferred.
module test_objection_local_and_descendant_count_queries_keep_sources_and_ancestors_distinct;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class node extends uvm_component;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    node parent_value,left,right;
    uvm_objection subject;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase); parent_value = new("parent_value",this);
      left = new("left",parent_value); right = new("right",parent_value); subject = new("subject");
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      $display("UT: counts_initial local %0d total %0d",subject.get_objection_count(parent_value),
               subject.get_objection_total(parent_value));
      subject.raise_objection(left,"left",2); subject.raise_objection(right,"right",3);
      subject.raise_objection(parent_value,"parent",1);
      $display("UT: counts_held local %0d/%0d/%0d totals %0d/%0d/%0d root %0d",
               subject.get_objection_count(left),subject.get_objection_count(right),
               subject.get_objection_count(parent_value),subject.get_objection_total(left),
               subject.get_objection_total(right),subject.get_objection_total(parent_value),
               subject.get_objection_total(uvm_root::get()));
      subject.drop_objection(left,"partial",1);
      $display("UT: counts_partial local %0d/%0d/%0d total %0d root %0d",
               subject.get_objection_count(left),subject.get_objection_count(right),
               subject.get_objection_count(parent_value),subject.get_objection_total(parent_value),
               subject.get_objection_total(uvm_root::get()));
      subject.drop_objection(left); subject.drop_objection(right,"all",3);
      subject.drop_objection(parent_value); #2;
      $display("UT: counts_final local %0d total %0d root %0d",
               subject.get_objection_count(parent_value),subject.get_objection_total(parent_value),
               subject.get_objection_total(uvm_root::get()));
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1,"count-query watchdog expired"); end
endmodule
