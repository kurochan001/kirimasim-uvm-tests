/*
:name: test_rand_send_randc_item_cycles_118
:description: repeated uvm_rand_send of one item cycles its randc field through every value before repeating (IEEE 1800.2-2020 Section B.3.1.3)
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.3.1.3 B.3.1.1 14.2.6.2 14.2.6.3 14.2.3.1 13.7 15.2.1.2.1 15.2.1.2.3 B.2.1.2 B.2.1.3 1800-2023 18.4.2 18.4.1 18.5 18.6.1 18.6.2 18.7 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_rand_send_randc_item_cycles_118.expected
:files: helpers118_rand/rand118.svh
*/
// One item with a two-bit randc field is created once and sent eight times
// without inline constraints. Each block of four consecutive values must be a
// permutation of 0 to 3. Results are judged by properties, such as satisfied
// constraints, call order and counts, never by particular random values. Only
// the lines that begin with "UT: " are compared.
module test_rand_send_randc_item_cycles_118;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "rand118.svh"

  class cyclic_item118 extends uvm_sequence_item;
    `uvm_object_utils(cyclic_item118)
    randc bit [1:0] lane;

    function new(string name = "cyclic_item118");
      super.new(name);
    endfunction
  endclass

  class parent118 extends uvm_sequence #(uvm_sequence_item);
    `uvm_object_utils(parent118)
    bit [1:0] lanes[$];

    function new(string name = "parent118");
      super.new(name);
    endfunction

    task body();
      cyclic_item118 item;
      `uvm_create(item)
      repeat (8) begin
        `uvm_rand_send(item)
        lanes.push_back(item.lane);
      end
    endtask

    function bit cycle118(int first);
      bit seen[4];
      for (int i = first; i < first + 4; i++) seen[lanes[i]] = 1;
      return lanes.size() >= first + 4 && seen[0] && seen[1] && seen[2] && seen[3];
    endfunction
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
      $display("UT: sends %0d first_cycle %0d second_cycle %0d delivered %0d", seq.lanes.size(),
               seq.cycle118(0), seq.cycle118(4), drv.delivered);
    endfunction
  endclass

  initial run_test("t");

  initial begin
    #1000;
    $fatal(1, "rand118 watchdog expired");
  end
endmodule
