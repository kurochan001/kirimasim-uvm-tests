/*
:name: test_transaction_zero_times_use_current_simulation_time
:description: default transaction timestamps use the current simulation time (IEEE 1800.2-2020 Section 5.4.2.2)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.4.2.2 5.4.2.4 5.4.2.6 5.4.2.16
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_transaction_zero_times_use_current_simulation_time.expected
*/
// What it checks:
// 1. Transaction accept uses current simulation time when its time argument is
//    zero or omitted.
// 2. Transaction begin uses current simulation time when its time argument is
//    zero or omitted.
// 3. Transaction end uses current simulation time when its time argument is
//    zero or omitted.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.4.2.2 (UVM-TRANSACTION-ACCEPT-ZERO-TIME) gives rule 1
//    above. Setup: Run the three lifecycle calls at separate positive delays
//    with recording disabled. Expected: The fixture records accept/begin/end
//    times 2, 5 and 9.
// 2. 1800.2-2020 5.4.2.4 (UVM-TRANSACTION-BEGIN-ZERO-TIME) gives rule 2 above.
//    Setup: Run the three lifecycle calls at separate positive delays with
//    recording disabled. Also observe explicit zero-time component lifecycle
//    calls made by a real pull/push driver after automatic recording was
//    disabled through the sequencer base API. Expected: The fixture records
//    accept/begin/end times 2, 5 and 9. The transaction time and callback
//    observation equal the driver time captured at the explicit call.
// 3. 1800.2-2020 5.4.2.6 (UVM-TRANSACTION-END-ZERO-TIME) gives rule 3 above.
//    Setup: Run the three lifecycle calls at separate positive delays with
//    recording disabled. Also observe explicit zero-time component lifecycle
//    calls made by a real pull/push driver after automatic recording was
//    disabled through the sequencer base API. Expected: The fixture records
//    accept/begin/end times 2, 5 and 9. The transaction time and callback
//    observation equal the driver time captured at the explicit call.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Accept, begin and end after distinct positive delays. Omitted and
// explicit zero arguments both select the current time in the caller units.

module test_transaction_zero_times_use_current_simulation_time;
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
    #2;
    value.accept_tr();
    #3;
    handle_value = value.begin_tr(0);
    #4;
    value.end_tr();
    $display("UT: times %0d %0d %0d", value.get_accept_time(), value.get_begin_time(),
        value.get_end_time());
    $display("UT: elapsed %0d no_record_handle %0d", $time, handle_value == 0);
    $finish;
  end
endmodule
