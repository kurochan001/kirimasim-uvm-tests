/*
:name: test_resource_pool_regex_alternation_filters_names_and_scopes_without_queue_order
:description: resource pool regex alternation filters names and scopes without queue order
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.4.4.7 C.2.4.3 C.2.4.3.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_pool_regex_alternation_filters_names_and_scopes_without_queue_order.expected
*/
// What it checks:
// The printed regular-expression lookup selects the two named alternatives
// within the visible scope.
//
// How the expected output follows from the standard:
// 1800.2-2020 C.2.4.4.7 (UVM-RESOURCE-COLLECTION-REGEX-ALTERNATION) gives the
// rule above. Setup: Use explicit anchors and alternation with red/blue/green
// names and a hidden same-name resource. Expected: Exactly the visible red and
// blue handles are present.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_resource_pool_regex_alternation_filters_names_and_scopes_without_queue_order;
  import uvm_pkg::*;
  // The printed interface takes a regular expression. This uses explicit
  // anchors/alternation, not a guess at a library-specific replacement API.
  initial begin
    uvm_resource_pool pool;
    uvm_resource#(int) red,blue,green,hidden;
    uvm_resource_types::rsrc_q_t found;
    bit have_red,have_blue;
    pool=new(); red=new("item62_red"); blue=new("item62_blue");
    green=new("item62_green"); hidden=new("item62_red");
    pool.set_scope(red,"visible62"); pool.set_scope(blue,"visible62");
    pool.set_scope(green,"visible62"); pool.set_scope(hidden,"hidden62");
    found=pool.lookup_regex("^item62_(red|blue)$","visible62");
    have_red=0; have_blue=0;
    for (int i=0;i<found.size();i++) begin
      have_red|=found.get(i)==red; have_blue|=found.get(i)==blue;
    end
    $display("UT: regex_alternation selected %0d",
      found.size()==2 && have_red && have_blue);
    $finish;
  end
endmodule
