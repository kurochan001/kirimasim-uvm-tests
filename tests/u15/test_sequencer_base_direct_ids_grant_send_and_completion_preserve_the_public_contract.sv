/*
:name: test_sequencer_base_direct_ids_grant_send_and_completion_preserve_the_public_contract
:description: sequencer base direct ids grant send and completion preserve the public contract
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.2.7 15.3.2.6 15.3.2.20 15.5.2.3 15.5.2.5 15.3.2.22 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_base_direct_ids_grant_send_and_completion_preserve_the_public_contract.expected
*/
// What it checks:
// Direct completion waits distinguish the two selected transaction IDs.
//
// How the expected output follows from the standard:
// 1800.2-2020 15.3.2.7 (UVM-SQR-AUDIT-BASE-DONE-IDENTIFIED) gives the rule
// above. Setup: Use the selected original fixture, declared type arguments,
// public endpoint/base views and linked stage observations. Requests satisfy
// the grant precondition before send_request and response IDs are copied from
// the actual request. Expected: Direct completion waits distinguish the two
// selected transaction IDs.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_sequencer_base_direct_ids_grant_send_and_completion_preserve_the_public_contract;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class packet extends uvm_sequence_item;
    rand int code;
    int randomizations=0;
    constraint selected_code {code==145;}
    function new(string name="packet"); super.new(name); endfunction
    function void post_randomize(); randomizations++; endfunction
  endclass
  class producer extends uvm_sequence#(packet);
    packet sent[$];
    int entered=0,granted=0,completed=0;
    bit done=0;
    function new(string name="producer"); super.new(name); endfunction
    virtual task body();
      uvm_sequencer_base target;
      packet item;
      target=get_sequencer();
      for (int i=0;i<2;i++) begin
        item=new("sent45"); item.code=37+i;
        item.set_item_context(this,target); item.set_transaction_id(451+i);
        sent.push_back(item); entered++;
        target.wait_for_grant(this);
        granted++;
        target.send_request(this,item);
        target.wait_for_item_done(this,451+i);
        completed++;

      end
      done=1;
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(packet) sequencer;
    uvm_driver#(packet) driver;
    producer worker;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase); sequencer=new("sequencer",this);
      driver=new("driver",this); worker=new(); sequencer.disable_auto_item_recording();
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    virtual task run_phase(uvm_phase phase);
      packet observed;
      phase.raise_objection(this);
      fork worker.start(sequencer); join_none
      #1;
      $display("UT: base_grant_wait entered %0d granted %0d",worker.entered,worker.granted);
      for (int i=0;i<2;i++) begin
        driver.seq_item_port.get_next_item(observed); #1;
        $display("UT: base_request %0d same %0d code %0d randomized %0d completed %0d lock %0d",
                 i,observed==worker.sent[i],observed.code,observed.randomizations>0,
                 worker.completed,sequencer.has_lock(worker));
        driver.seq_item_port.item_done();
      end
      wait (worker.done);
      $display("UT: base_completion granted %0d completed %0d locked %0d",
               worker.granted,worker.completed,sequencer.has_lock(worker));
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #80; $fatal(1,"test watchdog expired"); end
endmodule
