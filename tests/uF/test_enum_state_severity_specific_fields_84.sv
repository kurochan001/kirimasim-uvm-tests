/*
:name: test_enum_state_severity_specific_fields_84
:description: The four severity-specific APIs deliver their declared kinds and default verbosity fields
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.2.1 6.3.3.3 6.3.4.3 6.3.5.2 6.5.1.2.16 6.5.1.2.19 1800-2023 6.21 6.19.5 8.20 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers84_report/report84.svh
:expected_exit: 0
:expected_stdout: @test_enum_state_severity_specific_fields_84.expected
*/
// Standard-derived observations; no enum bit positions or report layout fixed.
module test_enum_state_severity_specific_fields_84;
  import uvm_pkg::*;
  `include "report84.svh"
  initial begin
    automatic report_observer84 server=new();
    automatic uvm_report_object reporter=new("typed84");
    automatic uvm_severity kinds[4]='{UVM_INFO,UVM_WARNING,UVM_ERROR,UVM_FATAL};
    automatic bit distinct=1,fields=1;
    uvm_report_server::set_server(server);
    reporter.set_report_verbosity_level(UVM_FULL);
    foreach(kinds[i]) begin
      reporter.set_report_severity_action(kinds[i],UVM_DISPLAY);
      foreach(kinds[j]) if(i!=j) distinct &= kinds[i]!=kinds[j];
    end
    reporter.uvm_report_info("I84","info84");
    fields &= server.calls==1 && server.matches84(reporter,UVM_INFO,UVM_MEDIUM,"I84","info84");
    reporter.uvm_report_warning("W84","warning84");
    fields &= server.calls==2 && server.matches84(reporter,UVM_WARNING,UVM_NONE,"W84","warning84");
    reporter.uvm_report_error("E84","error84");
    fields &= server.calls==3 && server.matches84(reporter,UVM_ERROR,UVM_NONE,"E84","error84");
    reporter.uvm_report_fatal("F84","fatal84");
    fields &= server.calls==4 && server.matches84(reporter,UVM_FATAL,UVM_NONE,"F84","fatal84");
    $display("UT: severity84 typed distinct %0d fields %0d",distinct,fields);
    $finish;
  end
endmodule
