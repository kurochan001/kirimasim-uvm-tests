/*
:name: test_pool_global_event_returned_handle_shares_real_synchronization
:description: The globally returned item participates in synchronization with its stored reference.
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.4.1.2.3 10.4.1.1 10.4.1.2.1 10.4.1.2.2 10.4.1.2.4 11.2.1 11.2.2.3 11.2.2.5 11.2.2.7 11.2.2.8 5.3.4.1 5.3.4.2 10.1.1.2.7 10.1.1.2.8 10.1.1.2.10 10.1.2.2.4 10.3.2.1 10.3.2.2 10.3.2.5 10.3.2.6 10.3.2.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pool_global_event_returned_handle_shares_real_synchronization.expected
*/
// Original observations; printed pool/item return premises stay separate.
module
  test_pool_global_event_returned_handle_shares_real_synchronization;
  timeunit 1ns;timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  initial begin
    automatic uvm_event_pool global_pool=uvm_event_pool::get_global_pool();
    automatic uvm_event subject=new("subject71");
    automatic uvm_event selected;
    automatic bit returned=0;
    automatic time when_returned;
    global_pool.add("selected71",subject);selected=uvm_event_pool::get_global("selected71");
    fork
      begin #2;selected.wait_on();when_returned=$time;returned=1;end
      begin
        #4;$display("UT: event_global_wait before %0d",subject.get_num_waiters());
        #1;subject.trigger();
      end
    join
    $display("UT: event_global_wait returned %0d at %0d",returned,when_returned);
    $finish;
  end
  initial begin #100;$fatal(1,"event global wait71 watchdog");end
endmodule
