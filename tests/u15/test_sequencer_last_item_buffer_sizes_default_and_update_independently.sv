/*
:name: test_sequencer_last_item_buffer_sizes_default_and_update_independently
:description: sequencer last request and response buffer controls default to one and update independently (IEEE 1800.2-2020 Section 15.3.3.2.1)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.3.2.1 15.3.3.2.2 15.3.4.2.1 15.3.4.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_last_item_buffer_sizes_default_and_update_independently.expected
*/
// Use in-range buffer sizes including zero and inspect two separate
// sequencers. This case does not claim to inspect buffer contents.

module test_sequencer_last_item_buffer_sizes_default_and_update_independently;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    int payload = 0;
    function new(string name="packet"); super.new(name); endfunction
  endclass

  initial begin
    automatic uvm_sequencer#(packet) first = new("first", null);
    automatic uvm_sequencer#(packet) second = new("second", null);
    $display("UT: defaults %0d %0d %0d %0d", first.get_num_last_reqs(), first.get_num_last_rsps(),
             second.get_num_last_reqs(), second.get_num_last_rsps());
    first.set_num_last_reqs(3);
    first.set_num_last_rsps(2);
    second.set_num_last_reqs(0);
    second.set_num_last_rsps(4);
    $display("UT: configured %0d %0d %0d %0d", first.get_num_last_reqs(), first.get_num_last_rsps(),
             second.get_num_last_reqs(), second.get_num_last_rsps());
    $finish;
  end
endmodule
