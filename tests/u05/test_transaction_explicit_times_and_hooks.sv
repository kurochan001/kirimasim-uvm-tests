/*
:name: test_transaction_explicit_times_and_hooks
:description: explicit transaction times and lifecycle hooks retain their specified values (IEEE 1800.2-2020 Section 5.4.2.2)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.4.2.2 5.4.2.3 5.4.2.4 5.4.2.5 5.4.2.6 5.4.2.7 5.4.2.12 5.4.2.16
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_transaction_explicit_times_and_hooks.expected
*/
// What it checks:
// 1. Transaction accept records an explicitly supplied nonzero lifecycle time.
// 2. Transaction begin records an explicitly supplied nonzero lifecycle time.
// 3. Transaction end records an explicitly supplied nonzero lifecycle time.
// 4. Transaction activity is true after begin and before end, and false
//    outside that interval.
// 5. The accept transaction operation invokes the corresponding user lifecycle
//    hook.
// 6. The begin transaction operation invokes the corresponding user lifecycle
//    hook.
// 7. The end transaction operation invokes the corresponding user lifecycle
//    hook.
// 8. The accept-time query returns the timestamp recorded by the corresponding
//    lifecycle operation.
// 9. The begin-time query returns the timestamp recorded by the corresponding
//    lifecycle operation.
// 10. The end-time query returns the timestamp recorded by the corresponding
//     lifecycle operation.
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
// 5. 1800.2-2020 5.4.2.3 (UVM-TRANSACTION-ACCEPT-HOOK-INVOCATION) gives rule 5
//    above. Setup: An unchanged fixture disables recording and performs one
//    accept, begin and end with explicit valid times. Expected: Each selected
//    hook is invoked once.
// 6. 1800.2-2020 5.4.2.5 (UVM-TRANSACTION-BEGIN-HOOK-INVOCATION) gives rule 6
//    above. Setup: An unchanged fixture disables recording and performs one
//    accept, begin and end with explicit valid times. Expected: Each selected
//    hook is invoked once.
// 7. 1800.2-2020 5.4.2.7 (UVM-TRANSACTION-END-HOOK-INVOCATION) gives rule 7
//    above. Setup: An unchanged fixture disables recording and performs one
//    accept, begin and end with explicit valid times. Expected: Each selected
//    hook is invoked once.
// 8. 1800.2-2020 5.4.2.16 (UVM-TRANSACTION-ACCEPT-TIME-QUERY) gives rule 8
//    above. Setup: The existing nonrecording fixture uses explicit
//    accept/begin/end times 17/23/29. Expected: The selected getter returns
//    17.
// 9. 1800.2-2020 5.4.2.16 (UVM-TRANSACTION-BEGIN-TIME-QUERY) gives rule 9
//    above. Setup: The existing nonrecording fixture uses explicit
//    accept/begin/end times 17/23/29. Expected: The selected getter returns
//    23.
// 10. 1800.2-2020 5.4.2.16 (UVM-TRANSACTION-END-TIME-QUERY) gives rule 10
//     above. Setup: The existing nonrecording fixture uses explicit
//     accept/begin/end times 17/23/29. Expected: The selected getter returns
//     29.
// It also supports, as a control, the setup or conditions of
// UVM-ABSTRACT-TRANSACTION-DIRECT-CONSTRUCTION.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Disable recording before acceptance. Explicit nonzero times need not
// match simulation time; each lifecycle operation calls its user hook once.

module test_transaction_explicit_times_and_hooks;
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
    value.accept_tr(17);
    handle_value = value.begin_tr(23);
    $display("UT: begin active %0d no_record_handle %0d", value.is_active(), handle_value == 0);
    value.end_tr(29);
    $display("UT: times %0d %0d %0d", value.get_accept_time(), value.get_begin_time(),
        value.get_end_time());
    $display("UT: hooks %0d %0d %0d inactive %0d", value.accept_calls, value.begin_calls,
             value.end_calls, !value.is_active());
    $finish;
  end
endmodule
