/*
:name: test_enum_state_sequence_kill_post_hooks_literal_84
:description: The literal kill post-callback expectation remains separate from the observed stopped state
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.4.2 14.2.2.4 14.2.3.1 14.2.3.6 14.2.3.8 14.2.3.9 14.2.5.11 14.2.5.12 1800-2023 6.21 6.19.5 8.20 13.5.2
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers84_sequence/states84.svh
:expected_exit: 0
:expected_stdout: @test_enum_state_sequence_kill_post_hooks_literal_84.expected
*/
// Standard-derived observations; no enum bit positions or report layout fixed.
module test_enum_state_sequence_kill_post_hooks_literal_84;
  import uvm_pkg::*;
  `include "states84.svh"
  state_sequence84 value;
  initial begin
    value=new("literal84"); value.check_normal_post=0; value.post_pause=0;
    fork
      value.start(null);
      begin wait(value.in_body); #1; value.kill(); #6; end
    join
    $display("UT: state84 kill state %0d hook %0d late_write %0d",
      value.get_sequence_state()==UVM_STOPPED,value.kills==1,value.body_writes==0);
    $display("UT: state84 kill post_body %0d post_start %0d",value.hits[3]==1,value.hits[4]==1);
    $finish;
  end
  initial begin #80; $fatal(1,"state84 watchdog"); end
endmodule
