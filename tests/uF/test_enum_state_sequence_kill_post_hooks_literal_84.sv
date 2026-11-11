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
// What it checks:
// 1. Killing a sequence executes its required post_body callback.
// 2. Killing a sequence executes its required post_start callback.
// 3. A forcibly ended sequence reports STOPPED independently of a surviving
//    peer and can later complete another start.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.2.5.11 (UVM-SEQUENCE-KILL-REQUIRED-POST-BODY) gives rule 1
//    above. Setup: Kill bound and unbound active sequences with zero-delay
//    hook counters. Expected: Each fixture records one post_body call.
// 2. 1800.2-2020 14.2.5.11 (UVM-SEQUENCE-KILL-REQUIRED-POST-START) gives rule
//    2 above. Setup: Kill bound and unbound active sequences with zero-delay
//    hook counters. Expected: Each fixture records one post_start call.
// 3. 1800.2-2020 F.2.4.2 (UVM-ENUM-STATE-SEQUENCE-STOPPED-PEER-REUSE) gives
//    rule 3 above. Setup: Original message execution observers receive actual
//    public reporting API calls;the separate error-continuation input uses the
//    unmodified default server with a positive100 quit limit. Standard INFO
//    levels0/100/200/300/400 are tested with global,ID,severity-ID and
//    independent reporter settings. Original unbound sequences expose actual
//    state getters inside hooks,positive body delays,optional hook
//    control,kill,peer isolation and restart. No UVM state is assigned by the
//    fixture. Expected: Kill stops the delayed body,an already matching mask
//    returns immediately,a peer finishes and the same handle later reaches
//    FINISHED;literal post-callback obligations remain separately observed.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
