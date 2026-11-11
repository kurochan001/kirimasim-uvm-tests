/*
:name: test_pool_global_barrier_returned_handle_shares_real_synchronization
:description: The globally returned item participates in synchronization with its stored reference.
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.4.2.2.3 10.4.2.1 10.4.2.2.1 10.4.2.2.2 10.4.2.2.4 11.2.1 11.2.2.3 11.2.2.5 11.2.2.7 11.2.2.8 5.3.4.1 5.3.4.2 10.1.1.2.7 10.1.1.2.8 10.1.1.2.10 10.1.2.2.4 10.3.2.1 10.3.2.2 10.3.2.5 10.3.2.6 10.3.2.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pool_global_barrier_returned_handle_shares_real_synchronization.expected
*/
// What it checks:
// The globally returned item participates in synchronization with its stored
// reference.
//
// How the expected output follows from the standard:
// 1800.2-2020 10.4.2.2.3 (UVM-GLOBAL-AUDIT-POOL-GLOBAL-BARRIER-RETURNED-
// HANDLE-SHARES-REAL-SYNCHRONIZATION) gives the rule above. Setup: Start a
// static-handle waiter at time two, inspect it at four and release via the
// stored handle at five. Expected: The linked static-admission, identity,
// live-state or bounded-wait observations match.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original observations; printed pool/item return premises stay separate.
module
  test_pool_global_barrier_returned_handle_shares_real_synchronization;
  timeunit 1ns;timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  initial begin
    automatic uvm_barrier_pool global_pool=uvm_barrier_pool::get_global_pool();
    automatic uvm_barrier subject=new("subject71",2);
    automatic uvm_barrier selected;
    automatic bit first_returned=0,second_returned=0;
    automatic time first_time,second_time;
    global_pool.add("selected71",subject);selected=uvm_barrier_pool::get_global("selected71");
    fork
      begin #2;selected.wait_for();first_time=$time;first_returned=1;end
      begin
        #4;$display("UT: barrier_global_wait before %0d",subject.get_num_waiters());
        #1;subject.wait_for();second_time=$time;second_returned=1;
      end
    join
    $display("UT: barrier_global_wait returned %0d times %0d/%0d",
      int'(first_returned)+int'(second_returned),first_time,second_time);
    $finish;
  end
  initial begin #100;$fatal(1,"barrier global wait71 watchdog");end
endmodule
