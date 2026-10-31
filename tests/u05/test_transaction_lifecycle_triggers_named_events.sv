/*
:name: test_transaction_lifecycle_triggers_named_events
:description: transaction acceptance beginning and ending trigger their named pool events (IEEE 1800.2-2020 Section 5.4.2.13)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.4.2.13 5.4.2.2 5.4.2.4 5.4.2.6 10.1.1.2.7
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_transaction_lifecycle_triggers_named_events.expected
*/
// Obtain the three events from the transaction event pool before use.
// Observe their persistent on state after each matching lifecycle operation.

module test_transaction_lifecycle_triggers_named_events;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class transaction extends uvm_transaction;
    `uvm_object_utils(transaction)
    int accept_calls = 0;
    int begin_calls = 0;
    int end_calls = 0;
    function new(string name="transaction", uvm_component initiator=null);
      super.new(name, initiator);
    endfunction
    protected function void do_accept_tr();
      super.do_accept_tr();
      accept_calls++;
    endfunction
    protected function void do_begin_tr();
      super.do_begin_tr();
      begin_calls++;
    endfunction
    protected function void do_end_tr();
      super.do_end_tr();
      end_calls++;
    endfunction
  endclass

  initial begin
    automatic transaction value = new;
    automatic uvm_event_pool pool = value.get_event_pool();
    automatic uvm_event#(uvm_object) accepted = pool.get("accept");
    automatic uvm_event#(uvm_object) begun = pool.get("begin");
    automatic uvm_event#(uvm_object) ended = pool.get("end");
    int handle_value;
    value.disable_recording();
    value.accept_tr(2);
    $display("UT: accepted %0d begun %0d ended %0d", accepted.is_on(), begun.is_on(),
        ended.is_on());
    handle_value = value.begin_tr(3);
    $display("UT: begun %0d ended %0d", begun.is_on(), ended.is_on());
    value.end_tr(4);
    $display("UT: ended %0d same_pool %0d", ended.is_on(), value.get_event_pool() == pool);
    $finish;
  end
endmodule
