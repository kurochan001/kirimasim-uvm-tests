/*
:name: test_event_raw_persistent_wait_is_immediate_in_slice_but_waits_in_a_later_slice
:description: event raw persistent wait is immediate in slice but waits in a later slice (IEEE 1800.2-2020 Section 10.1.1.2.5)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.1.1.2.5 10.1.1.2.10 10.1.2.2.4 10.1.2.2.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_event_raw_persistent_wait_is_immediate_in_slice_but_waits_in_a_later_slice.expected
*/
// Call the raw persistent wait in the triggering process, then in a later
// positive time slice. An on event is not an indefinitely persistent trigger.
// No arbitrary scheduling order, four-state payload or reset wakeup is tested.
module test_event_raw_persistent_wait_is_immediate_in_slice_but_waits_in_a_later_slice;
  import uvm_pkg::*;
  uvm_event#(int) subject;
  bit later_returned = 0;
  time started;
  initial begin
    subject = new("subject"); #2; subject.trigger(13);
    started = $time; subject.wait_ptrigger();
    $display("UT: raw_persistent same_slice %0d waiters %0d",$time == started,
             subject.get_num_waiters());
    #1;
    fork
      begin subject.wait_ptrigger(); later_returned = 1; end
      begin
        #1;
        $display("UT: raw_persistent_later blocked %0d waiters %0d on %0d",!later_returned,
                 subject.get_num_waiters(),subject.is_on());
        #2; subject.trigger(27);
      end
    join
    $display("UT: raw_persistent_final returned %0d waiters %0d data %0d",later_returned,
             subject.get_num_waiters(),subject.get_trigger_data());
    $finish;
  end
  initial begin #50; $fatal(1,"persistent trigger watchdog expired"); end
endmodule
