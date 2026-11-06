/*
:name: test_enum_state_error_count_continuation_84
:description: Configured count actions preserve error delivery and permit continued simulation below a positive quit limit
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.2.1 6.3.3.3 6.3.4.3 6.3.5.2 6.5.1.2.3 6.5.1.2.4 6.5.1.2.5 6.5.1.2.6 6.5.1.2.19 F.2.2.2 1800-2023 6.21 6.19.5 8.20 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_enum_state_error_count_continuation_84.expected
*/
// Standard-derived observations; no enum bit positions or report layout fixed.
module test_enum_state_error_count_continuation_84;
  import uvm_pkg::*;
  initial begin
    automatic uvm_default_report_server server=new();
    automatic uvm_report_object reporter=new("continue84");
    int before_errors;
    uvm_report_server::set_server(server);
    server.set_max_quit_count(100); server.set_quit_count(0);
    before_errors=server.get_severity_count(UVM_ERROR);
    reporter.set_report_verbosity_level(UVM_NONE);
    reporter.set_report_severity_action(UVM_ERROR,UVM_COUNT);
    reporter.uvm_report_error("C84a","first84",777);
    reporter.uvm_report_error("C84b","second84",999);
    $display("UT: severity84 error continued 1 counted %0d quit %0d",
      server.get_severity_count(UVM_ERROR)==before_errors+2,server.get_quit_count()==2);
    $finish;
  end
endmodule
