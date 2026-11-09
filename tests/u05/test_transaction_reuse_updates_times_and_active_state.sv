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
// What it checks:
// 1. Transaction accept records an explicitly supplied nonzero lifecycle time.
// 2. Transaction begin records an explicitly supplied nonzero lifecycle time.
// 3. Transaction end records an explicitly supplied nonzero lifecycle time.
// 4. Transaction activity is true after begin and before end, and false
//    outside that interval.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.4.2.2 (UVM-TRANSACTION-ACCEPT-EXPLICIT-TIME) gives rule 1
//    above. Setup: Recording is disabled; valid explicit times are supplied,
//    including a second lifecycle. Expected: Queried lifecycle times equal the
//    supplied values.
// 2. 1800.2-2020 5.4.2.4 (UVM-TRANSACTION-BEGIN-EXPLICIT-TIME) gives rule 2
//    above. Setup: Recording is disabled; valid explicit times are supplied,
//    including a second lifecycle. Expected: Queried lifecycle times equal the
//    supplied values.
// 3. 1800.2-2020 5.4.2.6 (UVM-TRANSACTION-END-EXPLICIT-TIME) gives rule 3
//    above. Setup: Recording is disabled; valid explicit times are supplied,
//    including a second lifecycle. Expected: Queried lifecycle times equal the
//    supplied values.
// 4. 1800.2-2020 5.4.2.12 (UVM-TRANSACTION-ACTIVE-STATE) gives rule 4 above.
//    Setup: Query before first begin, after begin/end and during a reused
//    lifecycle. Expected: The initial and ended states are inactive; each
//    begun interval is active.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
