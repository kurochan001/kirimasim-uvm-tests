/*
:name: test_enum_state_sequence_optional_hooks_skipped_84
:description: Actual sequence hooks expose the selected default or disabled optional-state profile
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.4.2 14.2.2.4 14.2.2.5 14.2.3.1 14.2.3.2 14.2.3.3 14.2.3.6 14.2.3.8 14.2.3.9 1800-2023 6.21 6.19.5 8.20 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers84_sequence/states84.svh
:expected_exit: 0
:expected_stdout: @test_enum_state_sequence_optional_hooks_skipped_84.expected
*/
// Standard-derived observations; no enum bit positions or report layout fixed.
module test_enum_state_sequence_optional_hooks_skipped_84;
  import uvm_pkg::*;
  `include "states84.svh"
  state_sequence84 value;
  initial begin
    time before_tick;
    value=new();
    before_tick=$time; value.wait_for_sequence_state(UVM_CREATED|UVM_FINISHED);
    $display("UT: state84 skip created %0d immediate %0d",
      value.get_sequence_state()==UVM_CREATED,$time==before_tick);
    value.start(null,null,-1,0);
    before_tick=$time; value.wait_for_sequence_state(UVM_FINISHED|UVM_STOPPED);
    $display("UT: state84 skip finished %0d immediate %0d hooks %0d mask %0d",
      value.get_sequence_state()==UVM_FINISHED,$time==before_tick,
      value.hooks_ok &&
        value.hits[0]==1 &&
        value.hits[1]==0 &&
        value.hits[2]==1 &&
        value.hits[3]==0 &&
        value.hits[4]==1,
      value.seen==(UVM_PRE_START|
        UVM_BODY|
        UVM_POST_START));
    $finish;
  end
  initial begin #80; $fatal(1,"state84 watchdog"); end
endmodule
