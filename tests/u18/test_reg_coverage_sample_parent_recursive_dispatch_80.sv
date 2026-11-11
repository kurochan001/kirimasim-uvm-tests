/*
:name: test_reg_coverage_sample_parent_recursive_dispatch_80
:description: Actual block sampling recursively reaches registers across branches without imposing visit order
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.7.8 18.1.4.7 18.4.2.2 18.4.4.1 18.4.4.2 18.5.3.2 18.5.5.1 18.1.2.2 1800-2023 6.21 8.18 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers80/coverage80.svh
:expected_exit: 0
:expected_stdout: @test_reg_coverage_sample_parent_recursive_dispatch_80.expected
*/
// What it checks:
// 1. Block sample_values recursively visits its registers and child blocks
//    only within the selected subtree.
// 2. Parent block sample_values invokes the sampling methods of registers
//    within its recursive subtree.
// 3. A register field-value sampling extension can observe the current modeled
//    field values when sampling is triggered.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.1.4.7 (UVM-BLOCK-SAMPLE-VALUES-RECURSIVE-SUBTREE) gives
//    rule 1 above. Setup: Overrides call super; invoke root then child with
//    local/deep registers and a separate peer. A separate case uses the actual
//    inherited block method over two branches, repeats with fresh values and
//    retains an outside peer. Expected: Root visits each descendant once; the
//    second call increments only child/grandchild/deep counts and never visits
//    the peer.
// 2. 1800.2-2020 18.4.7.8 (UVM-REG-COVERAGE-SAMPLE-PARENT-DISPATCH) gives rule
//    2 above. Setup: Original register overrides count sample_values calls and
//    capture current16-bit RW field desired values. Explicit user calls use an
//    actual uvm_reg base receiver; parent cases invoke the actual inherited
//    block method over two branches with an outside peer and repeat after
//    modeled values change. Expected: The actual inherited block method
//    reaches both branch registers on each invocation without calling the
//    outside peer or prescribing visit order.
// 3. 1800.2-2020 18.4.7.8 (UVM-REG-COVERAGE-SAMPLE-CURRENT-MODELED-FIELDS)
//    gives rule 3 above. Setup: Original register overrides count
//    sample_values calls and capture current16-bit RW field desired values.
//    Explicit user calls use an actual uvm_reg base receiver; parent cases
//    invoke the actual inherited block method over two branches with an
//    outside peer and repeat after modeled values change. Expected: Original
//    observers record fresh desired values after explicit set or direct
//    prediction on successive user and parent-triggered calls.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Coverage metadata or observer dispatch only; no bin, covergroup or HDL claim.
module test_reg_coverage_sample_parent_recursive_dispatch_80;
  import uvm_pkg::*;
  `include "coverage80.svh"
  initial begin
    automatic coverage_block80 root=new("root80");
    automatic coverage_block80 left=new("left80");
    automatic coverage_block80 right=new("right80");
    automatic coverage_block80 outside=new("outside80");
    automatic coverage_sample80 a=new("reg80");
    automatic coverage_sample80 b=new("reg80");
    automatic coverage_sample80 peer=new("reg80");
    root.configure(); left.configure(root); right.configure(root); outside.configure();
    a.configure(left); b.configure(right); peer.configure(outside);
    a.build_field(); b.build_field(); peer.build_field();
    a.set('h1234); b.set('h5678); peer.set('h9abc);
    a.calls=0; b.calls=0; peer.calls=0; root.sample_values();
    $display("UT: coverage80 parent first %0d values %0d peer %0d",
      a.calls==1 && b.calls==1,a.last_value=='h1234 && b.last_value=='h5678,peer.calls==0);
    a.set('h4321); b.set('h8765); root.sample_values();
    $display("UT: coverage80 parent repeat %0d fresh %0d peer %0d",
      a.calls==2 && b.calls==2,a.last_value=='h4321 && b.last_value=='h8765,
      peer.calls==0 && peer.get()=='h9abc);
    $finish;
  end
endmodule
