/*
:name: test_copier_recursion_default_updates_and_flush_restore_the_declared_policy
:description: copier recursion default updates and flush restore the declared policy
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.6.3 16.1.2.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_copier_recursion_default_updates_and_flush_restore_the_declared_policy.expected
*/
module test_copier_recursion_default_updates_and_flush_restore_the_declared_policy;
  import uvm_pkg::*;
  initial begin
    automatic uvm_copier selected=new();
    automatic uvm_copier peer=new();
    $display("UT: copy_policy_default %0d",selected.get_recursion_policy()==UVM_DEFAULT_POLICY);
    selected.set_recursion_policy(UVM_SHALLOW);
    $display("UT: copy_policy_changed selected %0d peer %0d",
             selected.get_recursion_policy()==UVM_SHALLOW,
             peer.get_recursion_policy()==UVM_DEFAULT_POLICY);
    selected.flush();
    $display("UT: copy_policy_flushed %0d",selected.get_recursion_policy()==UVM_DEFAULT_POLICY);
    $finish;
  end
endmodule
