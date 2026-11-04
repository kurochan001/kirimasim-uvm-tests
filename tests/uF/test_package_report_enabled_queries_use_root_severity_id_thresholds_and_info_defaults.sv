/*
:name: test_package_report_enabled_queries_use_root_severity_id_thresholds_and_info_defaults
:description: Package report-enabled queries select root configuration with severity/id/default arguments
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.3.2.2 F.3.2.1 6.3.4.1 6.3.4.2 6.3.4.3 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_package_report_enabled_queries_use_root_severity_id_thresholds_and_info_defaults.expected
*/
module test_package_report_enabled_queries_use_root_severity_id_thresholds_and_info_defaults;
  import uvm_pkg::*;
  initial begin
    automatic uvm_root root=uvm_root::get();
    automatic uvm_report_object peer=new("peer57");
    root.set_report_verbosity_level(UVM_LOW);
    root.set_report_id_verbosity("selected57",UVM_HIGH);
    root.set_report_severity_id_verbosity(UVM_WARNING,"selected57",UVM_MEDIUM);
    peer.set_report_verbosity_level(UVM_DEBUG);
    $display("UT: global_enabled general_edge %0d general_above %0d default_info %0d",
      uvm_report_enabled(UVM_LOW),!uvm_report_enabled(UVM_LOW+1),
      uvm_report_enabled(UVM_HIGH,UVM_INFO,"selected57"));
    $display("UT: global_enabled pair_edge %0d pair_above %0d local_isolated %0d",
      uvm_report_enabled(UVM_MEDIUM,UVM_WARNING,"selected57"),
      !uvm_report_enabled(UVM_MEDIUM+1,UVM_WARNING,"selected57"),
      peer.uvm_report_enabled(UVM_DEBUG) && !uvm_report_enabled(UVM_DEBUG));
    $finish;
  end
endmodule
