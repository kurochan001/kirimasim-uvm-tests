/*
:name: test_reg_coverage_sample_user_base_dispatch_80
:description: Explicit user sampling dispatches virtually and observes current modeled field values
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.7.8 18.4.2.2 18.4.4.1 18.4.4.2 18.4.4.15 18.5.3.2 18.5.5.1 18.1.2.2 1800-2023 6.21 8.18 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers80/coverage80.svh
:expected_exit: 0
:expected_stdout: @test_reg_coverage_sample_user_base_dispatch_80.expected
*/
// What it checks:
// 1. A user can invoke register sample_values publicly through a base register
//    receiver and reach the register override.
// 2. A register field-value sampling extension can observe the current modeled
//    field values when sampling is triggered.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.4.7.8 (UVM-REG-COVERAGE-SAMPLE-USER-VIRTUAL-DISPATCH)
//    gives rule 1 above. Setup: Original register overrides count
//    sample_values calls and capture current16-bit RW field desired values.
//    Explicit user calls use an actual uvm_reg base receiver; parent cases
//    invoke the actual inherited block method over two branches with an
//    outside peer and repeat after modeled values change. Expected: Two
//    explicit calls reach the selected override once each while an independent
//    peer remains untouched.
// 2. 1800.2-2020 18.4.7.8 (UVM-REG-COVERAGE-SAMPLE-CURRENT-MODELED-FIELDS)
//    gives rule 2 above. Setup: Original register overrides count
//    sample_values calls and capture current16-bit RW field desired values.
//    Explicit user calls use an actual uvm_reg base receiver; parent cases
//    invoke the actual inherited block method over two branches with an
//    outside peer and repeat after modeled values change. Expected: Original
//    observers record fresh desired values after explicit set or direct
//    prediction on successive user and parent-triggered calls.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Coverage metadata or observer dispatch only; no bin, covergroup or HDL claim.
module test_reg_coverage_sample_user_base_dispatch_80;
  import uvm_pkg::*;
  `include "coverage80.svh"
  initial begin
    automatic coverage_block80 owner=new("owner80");
    automatic coverage_sample80 r=new("reg80");
    automatic coverage_sample80 peer=new("peer80");
    uvm_reg base_view;
    bit prediction_ok;
    owner.configure(); r.configure(owner); peer.configure(owner);
    r.build_field(); peer.build_field(); r.set('h1234); peer.set('h9abc);
    r.calls=0; peer.calls=0; base_view=r; base_view.sample_values();
    $display("UT: coverage80 user first %0d value %0d peer %0d",
      r.calls==1,r.last_value=='h1234,peer.calls==0);
    prediction_ok=r.predict('h5678,-1,UVM_PREDICT_DIRECT); base_view.sample_values();
    $display("UT: coverage80 user second %0d value %0d prediction %0d peer %0d",
      r.calls==2,r.last_value=='h5678,prediction_ok,peer.calls==0 && peer.get()=='h9abc);
    $finish;
  end
endmodule
