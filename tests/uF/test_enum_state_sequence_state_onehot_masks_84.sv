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
