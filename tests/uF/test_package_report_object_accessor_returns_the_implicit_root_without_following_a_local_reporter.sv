/*
:name: test_package_report_object_accessor_returns_the_implicit_root_without_following_a_local_reporter
:description: The package reporter accessor returns the implicit root and preserves singleton identity
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.3.2.1 F.7.2.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_package_report_object_accessor_returns_the_implicit_root_without_following_a_local_reporter.expected
*/
module
  test_package_report_object_accessor_returns_the_implicit_root_without_following_a_local_reporter;
  import uvm_pkg::*;
  initial begin
    automatic uvm_report_object local_reporter=new("local57");
    automatic uvm_root root=uvm_root::get();
    automatic uvm_report_object root_view=root;
    $display("UT: global_reporter root %0d stable %0d local_distinct %0d",
      uvm_get_report_object()==root_view,uvm_get_report_object()==uvm_get_report_object(),
      uvm_get_report_object()!=local_reporter);
    $finish;
  end
endmodule
