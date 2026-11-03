/*
:name: test_comparer_threshold_default_updates_and_flush_restore_the_declared_boundary
:description: comparer threshold default updates and flush restore the declared boundary
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.3.6 16.3.2.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_comparer_threshold_default_updates_and_flush_restore_the_declared_boundary.expected
*/
module test_comparer_threshold_default_updates_and_flush_restore_the_declared_boundary;
  import uvm_pkg::*;
  initial begin
    automatic uvm_comparer selected=new();
    automatic uvm_comparer peer=new();
    $display("UT: threshold_default %0d",selected.get_threshold()==1);
    selected.set_threshold(0);
    $display("UT: threshold_zero selected %0d peer %0d",selected.get_threshold()==0,
             peer.get_threshold()==1);
    selected.set_threshold(5);
    $display("UT: threshold_five selected %0d peer %0d",selected.get_threshold()==5,
             peer.get_threshold()==1);
    selected.flush();
    $display("UT: threshold_flushed %0d",selected.get_threshold()==1);
    $finish;
  end
endmodule
