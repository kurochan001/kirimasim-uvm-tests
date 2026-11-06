/*
:name: test_enum_state_sequence_stopped_peer_and_reuse_84
:description: A killed sequence reports STOPPED while its peer finishes and a later start reuses the same handle
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.4.2 14.2.2.4 14.2.2.5 14.2.3.1 14.2.3.6 14.2.5.11 14.2.5.12 1800-2023 6.21 6.19.5 8.20 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers84_sequence/states84.svh
:expected_exit: 0
:expected_stdout: @test_enum_state_sequence_stopped_peer_and_reuse_84.expected
*/
// Standard-derived observations; no enum bit positions or report layout fixed.
module test_enum_state_sequence_stopped_peer_and_reuse_84;
  import uvm_pkg::*;
  `include "states84.svh"
  state_sequence84 value,peer;
  initial begin
    time before_tick;
    value=new("canceled84"); peer=new("peer84");
    value.check_normal_post=0; value.post_pause=0;
    fork
      value.start(null);
      peer.start(null);
      begin wait(value.in_body); #1; value.kill(); end
    join
    before_tick=$time; value.wait_for_sequence_state(UVM_STOPPED|UVM_FINISHED);
    $display("UT: state84 stopped state %0d immediate %0d peer %0d late_write %0d",
      value.get_sequence_state()==UVM_STOPPED,$time==before_tick,
      peer.get_sequence_state()==UVM_FINISHED,value.body_writes==0);
    value.prepare84(); value.start(null);
    $display("UT: state84 reused finished %0d hooks %0d completed %0d",
      value.get_sequence_state()==UVM_FINISHED,value.hooks_ok,value.body_writes==1);
    $finish;
  end
  initial begin #80; $fatal(1,"state84 watchdog"); end
endmodule
