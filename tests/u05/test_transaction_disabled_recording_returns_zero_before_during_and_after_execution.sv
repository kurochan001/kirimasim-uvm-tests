/*
:name: test_transaction_disabled_recording_returns_zero_before_during_and_after_execution
:description: Disabled transaction recording has no handle throughout a timed lifecycle
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.4.2.8 5.4.2.10 5.4.2.11 5.4.2.4 5.4.2.6 5.4.2.12 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_transaction_disabled_recording_returns_zero_before_during_and_after_execution.expected
*/
// What it checks:
// A nonrecording transaction has a zero transaction handle before/during/after
// execution.
//
// How the expected output follows from the standard:
// 1800.2-2020 5.4.2.8 (UVM-BASE-AUDIT-DISABLED-HANDLE) gives the rule above.
// Setup: Use fresh original transactions and legally opened streams, positive
// begin/end times and exact original recorder identities. Expected: The begin
// return and handle getter are zero while selected lifecycle-state
// observations remain separate.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_transaction_disabled_recording_returns_zero_before_during_and_after_execution;
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
  initial begin
    transaction_type value;
    int handle_value;
    value=new(); value.disable_recording();
    $display("UT: disabled_before no_handle %0d disabled %0d inactive %0d",
      value.get_tr_handle()==0,!value.is_recording_enabled(),!value.is_active());
    #2; handle_value=value.begin_tr();
    $display("UT: disabled_during return_zero %0d no_handle %0d active %0d",
      handle_value==0,value.get_tr_handle()==0,value.is_active());
    #2; value.end_tr();
    $display("UT: disabled_after no_handle %0d inactive %0d",
      value.get_tr_handle()==0,!value.is_active());
    $finish;
  end
  initial begin #100; $fatal(1,"base-class fixture watchdog expired"); end
endmodule
