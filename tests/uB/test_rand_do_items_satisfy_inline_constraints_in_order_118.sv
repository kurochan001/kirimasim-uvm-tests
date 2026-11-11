/*
:name: test_rand_do_items_satisfy_inline_constraints_in_order_118
:description: every item created by uvm_do satisfies its inline constraint, is randomized once, and follows the start, randomize and finish order (IEEE 1800.2-2020 Section B.3.1.4)
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.3.1.4 B.3.1.1 B.3.1.3 14.2.3.4 14.2.3.5 14.2.3.7 14.2.6.2 14.2.6.3 14.2.3.1 13.7 15.2.1.2.1 15.2.1.2.3 B.2.1.2 B.2.1.3 1800-2023 18.4.1 18.5 18.6.1 18.6.2 18.7 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_rand_do_items_satisfy_inline_constraints_in_order_118.expected
:files: helpers118_rand/rand118.svh
*/
// What it checks:
// 1. For each item, randomization falls between the start_item and finish_item
//    steps, before driver delivery.
// 2. Every item created and sent by uvm_do satisfies its inline constraint and
//    is randomized once.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 B.3.1.3 (UVM-RAND-PROPERTY-DO-ITEM-ORDER) gives rule 1 above.
//    Setup: Twenty-four uvm_do calls log pre_do, pre_randomize,
//    post_randomize, mid_do, the driver delivery and post_do. Expected: The
//    log repeats those six events in that order for every item, and
//    twenty-four items are delivered.
// 2. 1800.2-2020 B.3.1.4 (UVM-RAND-PROPERTY-DO-INLINE-CONSTRAINT) gives rule 2
//    above. Setup: Twenty-four uvm_do calls use an inline constraint that
//    refers to sequence bounds 10 and 20. Expected: All twenty-four items lie
//    within the bounds, and each calls pre_randomize and post_randomize once.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Twenty-four uvm_do calls use an inline constraint that refers to the sequence
// bounds 10 and 20. Every item must lie within them and be randomized exactly
// once, and each item must log pre_do, pre_randomize, post_randomize, mid_do,
// the driver delivery and post_do in that order. Results are judged by
// properties, such as satisfied constraints, call order and counts, never by
// particular random values. Only the lines that begin with "UT: " are compared.
module test_rand_do_items_satisfy_inline_constraints_in_order_118;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "rand118.svh"

  class counted_item118 extends uvm_sequence_item;
    `uvm_object_utils(counted_item118)
    rand bit [7:0] data;
    int pre_calls;
    int post_calls;

    function new(string name = "counted_item118");
      super.new(name);
    endfunction

    function void pre_randomize();
      pre_calls++;
      log118::add("pre_randomize");
    endfunction

    function void post_randomize();
      post_calls++;
      log118::add("post_randomize");
    endfunction
  endclass

  class parent118 extends uvm_sequence #(uvm_sequence_item);
    `uvm_object_utils(parent118)
    bit [7:0] lo = 8'd10;
    bit [7:0] hi = 8'd20;
    int items;
    int in_range;
    int single;

    function new(string name = "parent118");
      super.new(name);
    endfunction

    task pre_do(bit is_item);
      if (is_item) log118::add("pre_do");
    endtask

    function void mid_do(uvm_sequence_item this_item);
      log118::add("mid_do");
    endfunction

    function void post_do(uvm_sequence_item this_item);
      log118::add("post_do");
    endfunction

    task body();
      counted_item118 item;
      repeat (24) begin
        `uvm_do(item, get_sequencer(), -1, {data inside {[lo:hi]};})
        items++;
        in_range += item.data >= lo && item.data <= hi;
        single += item.pre_calls == 1 && item.post_calls == 1;
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
      string want[6] = '{"pre_do", "pre_randomize", "post_randomize", "mid_do", "drive",
                         "post_do"};
      bit order = log118::events.size() == 24 * 6;
      foreach (log118::events[i]) order &= log118::events[i] == want[i % 6];
      $display("UT: items %0d in_range %0d single_randomization %0d order %0d", seq.items,
               seq.in_range, seq.single, order);
      $display("UT: delivered %0d", drv.delivered);
    endfunction
  endclass

  initial run_test("t");

  initial begin
    #1000;
    $fatal(1, "rand118 watchdog expired");
  end
endmodule
