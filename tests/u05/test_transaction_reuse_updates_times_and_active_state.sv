/*
:name: test_transaction_reuse_updates_times_and_active_state
:description: a completed transaction can begin a second lifecycle with new timestamps (IEEE 1800.2-2020 Section 5.4.2.2)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.4.2.2 5.4.2.4 5.4.2.6 5.4.2.12 5.4.2.16
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_transaction_reuse_updates_times_and_active_state.expected
*/
// A second begin makes a previously ended transaction active again.
// Observe the new lifecycle times rather than an internal inactive sentinel.

module test_transaction_reuse_updates_times_and_active_state;
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
    int handle_value;
    value.disable_recording();
    value.accept_tr(2);
    handle_value = value.begin_tr(3);
    value.end_tr(4);
    $display("UT: first inactive %0d", !value.is_active());
    value.accept_tr(5);
    handle_value = value.begin_tr(7);
    $display("UT: second active %0d", value.is_active());
    value.end_tr(9);
    $display("UT: second times %0d %0d %0d inactive %0d", value.get_accept_time(),
             value.get_begin_time(), value.get_end_time(), !value.is_active());
    $display("UT: hooks %0d %0d %0d", value.accept_calls, value.begin_calls, value.end_calls);
    $finish;
  end
endmodule
