/*
:name: test_enum_state_verbosity_standard_matrix_84
:description: Direct INFO delivery includes equality at every standard configured verbosity level
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.2.4 6.3.3.3 6.3.4.3 6.3.5.2 6.5.1.2.16 6.5.1.2.19 1800-2023 6.21 6.19.5 8.20 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers84_report/report84.svh
:expected_exit: 0
:expected_stdout: @test_enum_state_verbosity_standard_matrix_84.expected
*/
// Standard-derived observations; no enum bit positions or report layout fixed.
module test_enum_state_verbosity_standard_matrix_84;
  import uvm_pkg::*;
  `include "report84.svh"
  initial begin
    automatic report_observer84 server=new();
    automatic uvm_report_object reporter=new("matrix84");
    automatic int levels[5]='{UVM_NONE,UVM_LOW,UVM_MEDIUM,UVM_HIGH,UVM_FULL};
    automatic bit delivery=1,fields=1;
    bit issued;
    int before_calls;
    string id;
    uvm_report_server::set_server(server);
    reporter.set_report_severity_action(UVM_INFO,UVM_DISPLAY);
    foreach(levels[t]) begin
      reporter.set_report_verbosity_level(levels[t]);
      foreach(levels[v]) begin
        before_calls=server.calls; id=$sformatf("M%0d_%0d",t,v);
        reporter.uvm_report_info(id,"matrix84",levels[v]); issued=levels[v]<=levels[t];
        delivery &= server.calls==before_calls+int'(issued);
        if(issued) fields &= server.matches84(reporter,UVM_INFO,levels[v],id,"matrix84");
      end
    end
    $display("UT: verbosity84 matrix delivery %0d fields %0d",delivery,fields);
    $finish;
  end
endmodule
