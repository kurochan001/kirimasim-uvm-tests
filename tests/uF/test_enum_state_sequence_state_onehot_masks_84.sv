/*
:name: test_enum_state_sequence_state_onehot_masks_84
:description: The nine declared sequence states have distinct one-hot values and retain all selected integer masks
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.4.2 14.2.2.5 1800-2023 6.21 6.19.5 8.20 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_enum_state_sequence_state_onehot_masks_84.expected
*/
// What it checks:
// The declared sequence states have distinct one-hot encodings usable in state
// masks.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.2.4.2 (UVM-ENUM-STATE-SEQUENCE-ONEHOT-MASKS) gives the rule
// above. Setup: Original message execution observers receive actual public
// reporting API calls;the separate error-continuation input uses the
// unmodified default server with a positive100 quit limit. Standard INFO
// levels0/100/200/300/400 are tested with global,ID,severity-ID and
// independent reporter settings. Original unbound sequences expose actual
// state getters inside hooks,positive body delays,optional hook
// control,kill,peer isolation and restart. No UVM state is assigned by the
// fixture. Expected: Each of nine named states is one-hot,and all512 selected
// subsets retain independent membership in the public integer-mask
// representation.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Standard-derived observations; no enum bit positions or report layout fixed.
module test_enum_state_sequence_state_onehot_masks_84;
  import uvm_pkg::*;
  typedef int unsigned mask84;
  typedef bit [$bits(uvm_sequence_state_enum)+31:0] wide84;
  initial begin
    automatic uvm_sequence_state_enum states[9]='{UVM_CREATED,UVM_PRE_START,UVM_PRE_BODY,
      UVM_BODY,UVM_ENDED,UVM_POST_BODY,UVM_POST_START,UVM_STOPPED,UVM_FINISHED};
    automatic bit onehot=1,distinct=1,masks=1;
    wide84 raw;
    mask84 stored;
    foreach(states[i]) begin
      onehot &= $countones(states[i])==1;
      foreach(states[j]) if(i!=j) distinct &= (states[i]&states[j])==0;
    end
    for(int subset=0;subset<512;subset++) begin
      raw='0;
      foreach(states[i]) if((subset>>i)&1) raw |= {states[i]};
      stored=mask84'(raw); masks &= wide84'(stored)==raw;
      foreach(states[i]) masks &= ((stored&mask84'(states[i]))!=0)==(((subset>>i)&1)!=0);
    end
    $display("UT: state84 encodings onehot %0d distinct %0d masks %0d",onehot,distinct,masks);
    $finish;
  end
endmodule
