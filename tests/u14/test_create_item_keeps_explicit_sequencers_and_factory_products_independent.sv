/*
:name: test_create_item_keeps_explicit_sequencers_and_factory_products_independent
:description: Direct create_item calls use the factory and bind each new item to the supplied sequencer (IEEE 1800.2-2020 Section 14.2.6.1)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.6.1 14.1.2.5 14.1.2.6 8.3.1.4.2 8.3.1.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_create_item_keeps_explicit_sequencers_and_factory_products_independent.expected
*/
// Call the protected API from a derived sequence with two explicit
// sequencers. The factory replaces the requested item class each time. Both
// items must keep their own sequencer, names and payload state when the
// second call finishes. The parent is not running on either target and no
// driver is involved.

module test_create_item_keeps_explicit_sequencers_and_factory_products_independent;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    int payload = 0;
    function new(string name="packet");
      super.new(name);
    endfunction
  endclass
  class special_packet extends packet;
    `uvm_object_utils(special_packet)
    function new(string name="special_packet");
      super.new(name);
    endfunction
  endclass

  class maker extends uvm_sequence #(packet);
    function uvm_sequence_item make(uvm_sequencer_base target, string name);
      return create_item(packet::get_type(), target, name);
    endfunction
  endclass

  initial begin
    automatic uvm_sequencer #(packet) left = new("left", null);
    automatic uvm_sequencer #(packet) right = new("right", null);
    automatic maker seqr_client = new;
    uvm_sequence_item a, b;
    special_packet first, second;
    bit ok_a, ok_b;
    packet::type_id::set_type_override(special_packet::get_type());
    a = seqr_client.make(left, "first");
    ok_a = $cast(first, a);
    if (!ok_a || first == null) $fatal(1, "first factory product missing");
    first.payload = 37;
    b = seqr_client.make(right, "second");
    ok_b = $cast(second, b);
    if (!ok_b || second == null) $fatal(1, "second factory product missing");
    $display("UT: types %0d %0d names %s %s", ok_a, ok_b, a.get_name(), b.get_name());
    $display("UT: independent %0d contexts %0d %0d payloads %0d %0d",
             a != b, a.get_sequencer() == left, b.get_sequencer() == right,
             first.payload, second.payload);
    $finish;
  end
endmodule
