/*
:name: test_resource_modified_waiters_ignore_equal_values_and_all_wake_for_a_changed_write
:description: Changed resource writes release all pending waiters while equal-value writes produce no modification
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.3.4 C.2.5.4.2 C.3.2.3.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_modified_waiters_ignore_equal_values_and_all_wake_for_a_changed_write.expected
*/
// set_default performs no initial write; its two-state bit value is zero.
module test_resource_modified_waiters_ignore_equal_values_and_all_wake_for_a_changed_write;
  import uvm_pkg::*;
  typedef bit [7:0] word_type;
  uvm_resource#(word_type) resource;
  int woke=0;
  initial begin
    resource=uvm_resource_db#(word_type)::set_default("scope58","modified58");
    if (resource==null) $fatal(1,"missing default resource");
    fork
      begin resource.wait_modified(); woke++; end
      begin resource.wait_modified(); woke++; end
    join_none
    #1; $display("UT: resource_wait initial_blocked %0d",woke==0);
    resource.write(0); #1;
    $display("UT: resource_wait equal_write_blocked %0d",woke==0);
    resource.write('h58); #1;
    $display("UT: resource_wait all_released %0d value %0d",woke==2,resource.read()=='h58);
    disable fork; $finish;
  end
endmodule
