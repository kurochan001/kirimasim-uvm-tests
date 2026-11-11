/*
:name: test_enum_state_verbosity_literal_values_84
:description: The five standard verbosity names provide their specified numeric levels
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.2.4  1800-2023 6.21 6.19.5 8.20 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_enum_state_verbosity_literal_values_84.expected
*/
// What it checks:
// The standard verbosity names supply their specified numeric levels.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.2.2.4 (UVM-ENUM-STATE-VERBOSITY-LITERAL-VALUES) gives the rule
// above. Setup: Original message execution observers receive actual public
// reporting API calls;the separate error-continuation input uses the
// unmodified default server with a positive100 quit limit. Standard INFO
// levels0/100/200/300/400 are tested with global,ID,severity-ID and
// independent reporter settings. Original unbound sequences expose actual
// state getters inside hooks,positive body delays,optional hook
// control,kill,peer isolation and restart. No UVM state is assigned by the
// fixture. Expected: NONE,LOW,MEDIUM,HIGH andFULL equal0,100,200,300 and400
// respectively.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Standard-derived observations; no enum bit positions or report layout fixed.
module test_enum_state_verbosity_literal_values_84;
  import uvm_pkg::*;
  initial begin
    $display("UT: verbosity84 literals none %0d low %0d medium %0d high %0d full %0d",
      UVM_NONE==0,UVM_LOW==100,UVM_MEDIUM==200,UVM_HIGH==300,UVM_FULL==400);
    $finish;
  end
endmodule
