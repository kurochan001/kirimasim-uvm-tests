/*
:name: test_transaction_event_pool_retrieval_preserves_added_event_identity_and_notification
:description: Associated event-pool retrieval carries an original delayed notification
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.4.2.13 10.4.1.2.4 10.1.1.2.2 10.1.1.2.4 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_transaction_event_pool_retrieval_preserves_added_event_identity_and_notification.expected
*/
// What it checks:
// Repeated associated-pool access retains an added event and its notification.
//
// How the expected output follows from the standard:
// 1800.2-2020 5.4.2.13 (UVM-BASE-AUDIT-TRANSACTION-EVENT-POOL) gives the rule
// above. Setup: Create one original custom event through the transaction pool;
// a positively delayed trigger releases a waiter reached through another
// getter view. Expected: Pool/event identity is stable and the waiter is
// pending before the trigger, resumed afterward.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// No initial pool membership or exclusive per-transaction ownership is assumed.
module test_transaction_event_pool_retrieval_preserves_added_event_identity_and_notification;
  import uvm_pkg::*;
  class transaction_type extends uvm_transaction;
    function new(string name="",uvm_component initiator=null);
      super.new(name,initiator);
    endfunction
    virtual function string get_type_name(); return "transaction_type61"; endfunction
    virtual function uvm_object create(string name="");
      transaction_type result;
      result=new(name); return result;
    endfunction
  endclass
  transaction_type value;
  bit resumed=0;
  initial begin
    uvm_event_pool first_pool,again;
    uvm_event#(uvm_object) selected,from_transaction;
    value=new(); first_pool=value.get_event_pool();
    selected=first_pool.get("custom61"); again=value.get_event_pool();
    from_transaction=again.get("custom61");
    $display("UT: transaction_pool same_pool %0d same_event %0d",
      first_pool==again,selected==from_transaction);
    fork begin from_transaction.wait_trigger(); resumed=1; end join_none
    #1;
    $display("UT: transaction_event pending %0d",!resumed);
    selected.trigger(); #1;
    $display("UT: transaction_event resumed %0d",resumed);
    $finish;
  end
  initial begin #50; $fatal(1,"transaction event watchdog expired"); end
endmodule
