/*
:name: test_rand_send_child_rand_mode_118
:description: uvm_rand_send keeps a child-sequence field whose rand_mode is off, constrains the other field, and randomizes before the child starts (IEEE 1800.2-2020 Section B.3.1.3)
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.3.1.3 B.3.1.1 14.2.2.2 14.2.3.2 14.2.3.3 14.2.3.6 14.2.3.8 14.2.3.9 14.2.6.2 14.2.6.3 14.2.3.1 13.7 15.2.1.2.1 15.2.1.2.3 B.2.1.2 B.2.1.3 1800-2023 18.8 18.4.1 18.5 18.6.1 18.6.2 18.7 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_rand_send_child_rand_mode_118.expected
:files: helpers118_rand/rand118.svh
*/
// What it checks:
// uvm_rand_send randomizes a child sequence before starting it and keeps a
// field whose rand_mode is off.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.3.1.3 (UVM-RAND-PROPERTY-CHILD-RAND-MODE) gives the rule
// above. Setup: Create eight child sequences, set one field and turn off its
// rand_mode, then send each with an inline constraint on the other field.
// Expected: The body sees the kept value and an in-range value, and each child
// logs pre_randomize, post_randomize, pre_start, body and post_start without
// body hooks.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Eight child sequences are created; one field is set and its rand_mode turned
// off, and the child is sent with an inline constraint on the other field. The
// body must see the kept value and an in-range value, and each child must log
// pre_randomize, post_randomize, pre_start, body and post_start, without body
// hooks. Results are judged by properties, such as satisfied constraints, call
// order and counts, never by particular random values. Only the lines that
// begin with "UT: " are compared.
module test_rand_send_child_rand_mode_118;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "rand118.svh"

  class child118 extends uvm_sequence #(uvm_sequence_item);
    `uvm_object_utils(child118)
    rand bit [7:0] kept;
    rand bit [7:0] chosen;
    bit [7:0] seen_kept;
    bit [7:0] seen_chosen;

    function new(string name = "child118");
      super.new(name);
    endfunction

    function void pre_randomize();
      log118::add("pre_randomize");
    endfunction

    function void post_randomize();
      log118::add("post_randomize");
    endfunction

    task pre_start();
      log118::add("pre_start");
    endtask

    task pre_body();
      log118::add("pre_body");
    endtask

    task body();
      seen_kept = kept;
      seen_chosen = chosen;
      log118::add("body");
    endtask

    task post_body();
      log118::add("post_body");
    endtask

    task post_start();
      log118::add("post_start");
    endtask
  endclass

  class parent118 extends uvm_sequence #(uvm_sequence_item);
    `uvm_object_utils(parent118)
    int children;
    int kept_ok;
    int chosen_ok;

    function new(string name = "parent118");
      super.new(name);
    endfunction

    task body();
      child118 child;
      repeat (8) begin
        `uvm_create(child)
        child.kept = 8'h5A;
        child.kept.rand_mode(0);
        `uvm_rand_send(child, -1, {chosen inside {[8'd100:8'd110]};})
        children++;
        kept_ok += child.seen_kept == 8'h5A && child.kept.rand_mode() == 0;
        chosen_ok += child.seen_chosen >= 8'd100 && child.seen_chosen <= 8'd110;
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
      string want[5] = '{"pre_randomize", "post_randomize", "pre_start", "body", "post_start"};
      bit order = log118::events.size() == 8 * 5;
      foreach (log118::events[i]) order &= log118::events[i] == want[i % 5];
      $display("UT: children %0d kept %0d chosen %0d order %0d", seq.children, seq.kept_ok,
               seq.chosen_ok, order);
    endfunction
  endclass

  initial run_test("t");

  initial begin
    #1000;
    $fatal(1, "rand118 watchdog expired");
  end
endmodule
