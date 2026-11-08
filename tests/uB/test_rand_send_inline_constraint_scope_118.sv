/*
:name: test_rand_send_inline_constraint_scope_118
:description: an inline uvm_rand_send constraint resolves a name in the item first and in the sequence through local:: (IEEE 1800.2-2020 Section B.3.1.3)
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.3.1.3 B.3.1.1 14.2.6.2 14.2.6.3 14.2.3.1 13.7 15.2.1.2.1 15.2.1.2.3 B.2.1.2 B.2.1.3 1800-2023 18.7.1 18.4.1 18.5 18.6.1 18.6.2 18.7 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_rand_send_inline_constraint_scope_118.expected
:files: helpers118_rand/rand118.svh
*/
// The item and the sequence each declare limit, 20 in the item and 200 in the
// sequence. An unqualified limit in the inline constraint must use the item
// value and local::limit must use the sequence value, over sixteen rounds of
// each. Results are judged by properties, such as satisfied constraints, call
// order and counts, never by particular random values. Only the lines that
// begin with "UT: " are compared.
module test_rand_send_inline_constraint_scope_118;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "rand118.svh"

  class scoped_item118 extends uvm_sequence_item;
    `uvm_object_utils(scoped_item118)
    rand bit [7:0] data;
    bit [7:0] limit = 8'd20;

    function new(string name = "scoped_item118");
      super.new(name);
    endfunction
  endclass

  class parent118 extends uvm_sequence #(uvm_sequence_item);
    `uvm_object_utils(parent118)
    bit [7:0] limit = 8'd200;
    int object_scope;
    int caller_scope;

    function new(string name = "parent118");
      super.new(name);
    endfunction

    task body();
      scoped_item118 item;
      repeat (16) begin
        `uvm_create(item)
        `uvm_rand_send(item, -1, {data < limit;})
        object_scope += item.data < 8'd20;
        `uvm_create(item)
        `uvm_rand_send(item, -1, {data > local::limit;})
        caller_scope += item.data > 8'd200;
      end
    endtask
  endclass

  class t extends test_base118;
    `uvm_component_utils(t)
    parent118 seq;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    task run118();
      seq = parent118::type_id::create("seq");
      seq.start(sqr);
    endtask

    function void check_phase(uvm_phase phase);
      $display("UT: object_scope %0d caller_scope %0d delivered %0d", seq.object_scope,
               seq.caller_scope, drv.delivered);
    endfunction
  endclass

  initial run_test("t");

  initial begin
    #1000;
    $fatal(1, "rand118 watchdog expired");
  end
endmodule
