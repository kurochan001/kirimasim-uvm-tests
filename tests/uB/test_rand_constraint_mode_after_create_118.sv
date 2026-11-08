/*
:name: test_rand_constraint_mode_after_create_118
:description: a class constraint disabled with constraint_mode after uvm_create stays disabled for uvm_rand_send while an untouched item keeps it (IEEE 1800.2-2020 Section B.3.1.1)
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.3.1.1 B.3.1.3 14.2.6.2 14.2.6.3 14.2.3.1 13.7 15.2.1.2.1 15.2.1.2.3 B.2.1.2 B.2.1.3 1800-2023 18.9 18.4.1 18.5 18.6.1 18.6.2 18.7 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_rand_constraint_mode_after_create_118.expected
:files: helpers118_rand/rand118.svh
*/
// Sixteen rounds each create two items. The first has its class constraint data
// < 16 disabled and is sent with the inline constraint data >= 200, which only
// a disabled class constraint allows; the second is sent unchanged and must
// satisfy the class constraint. Results are judged by properties, such as
// satisfied constraints, call order and counts, never by particular random
// values. Only the lines that begin with "UT: " are compared.
module test_rand_constraint_mode_after_create_118;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "rand118.svh"

  class bounded_item118 extends uvm_sequence_item;
    `uvm_object_utils(bounded_item118)
    rand bit [7:0] data;
    constraint small118 { data < 8'd16; }

    function new(string name = "bounded_item118");
      super.new(name);
    endfunction
  endclass

  class parent118 extends uvm_sequence #(uvm_sequence_item);
    `uvm_object_utils(parent118)
    int disabled_ok;
    int enabled_ok;

    function new(string name = "parent118");
      super.new(name);
    endfunction

    task body();
      bounded_item118 item;
      repeat (16) begin
        `uvm_create(item)
        item.small118.constraint_mode(0);
        `uvm_rand_send(item, -1, {data >= 8'd200;})
        disabled_ok += item.data >= 8'd200 && item.small118.constraint_mode() == 0;
        `uvm_create(item)
        `uvm_rand_send(item)
        enabled_ok += item.data < 8'd16 && item.small118.constraint_mode() == 1;
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
      $display("UT: disabled %0d enabled %0d delivered %0d", seq.disabled_ok, seq.enabled_ok,
               drv.delivered);
    endfunction
  endclass

  initial run_test("t");

  initial begin
    #1000;
    $fatal(1, "rand118 watchdog expired");
  end
endmodule
