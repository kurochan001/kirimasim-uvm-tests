/*
:name: test_tlm_fifo_availability_queries_preserve_object_head_and_peer_storage
:description: tlm fifo availability queries preserve object head and peer storage (IEEE 1800.2-2020 Section 12.2.4.2.7)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.4.2.7 12.2.4.2.9 12.2.4.2.2 12.2.4.2.3 12.2.4.2.4 12.2.8.1.3 12.2.8.1.4 12.2.8.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_fifo_availability_queries_preserve_object_head_and_peer_storage.expected
*/
// Actual put/get/peek ports bind the combined FIFO interfaces. Repeated
// availability queries must not consume the object head or alter a peer.
// Object identity follows ordinary handle values. No failing output argument,
// peek-analysis notification or simultaneous competing reader is asserted.
module test_tlm_fifo_availability_queries_preserve_object_head_and_peer_storage;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class packet extends uvm_object;
    int value;
    function new(int selected); super.new("packet"); value = selected; endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_fifo#(packet) subject,peer;
    uvm_put_port#(packet) writer;
    uvm_get_port#(packet) reader;
    uvm_peek_port#(packet) peeker;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase); subject = new("subject",this,2); peer = new("peer",this,2);
      writer = new("writer",this); reader = new("reader",this); peeker = new("peeker",this);
    endfunction
    function void connect_phase(uvm_phase phase);
      writer.connect(subject.put_export); reader.connect(subject.get_peek_export);
      peeker.connect(subject.get_peek_export);
    endfunction
    task run_phase(uvm_phase phase);
      automatic packet first = new(13);
      automatic packet second = new(27);
      automatic packet peer_value = new(71);
      packet head,removed;
      bit accepted,available;
      phase.raise_objection(this); accepted = peer.try_put(peer_value);
      $display("UT: fifo_availability_empty get %0d peek %0d used %0d",
               reader.can_get(),peeker.can_peek(),subject.used());
      accepted &= writer.try_put(first); available = 1;
      repeat (3) available &= reader.can_get() && peeker.can_peek();
      peeker.peek(head); first.value = 35;
      $display("UT: fifo_availability_held accepted %0d available %0d used %0d head %0d live %0d",
               accepted,available,subject.used(),head == first,head.value);
      reader.get(removed);
      $display("UT: fifo_availability_removed identity %0d get %0d peek %0d used %0d peer %0d",
               removed == first,reader.can_get(),peeker.can_peek(),subject.used(),peer.used());
      writer.put(second); reader.get(removed);
      $display("UT: fifo_availability_reused identity %0d value %0d empty %0d peer %0d",
               removed == second,removed.value,subject.is_empty(),peer.used());
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1,"FIFO availability watchdog expired"); end
endmodule
