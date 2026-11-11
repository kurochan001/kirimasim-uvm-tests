/*
:name: test_enum_state_severity_generic_above_threshold_84
:description: Generic warning error and fatal delivery ignores verbosity while INFO obeys its limit
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
:expected_stdout: @test_enum_state_severity_generic_above_threshold_84.expected
*/
// What it checks:
// Public severity-specific and generic reporting preserve the selected message
// kind.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.2.2.1 (UVM-ENUM-STATE-SEVERITY-MESSAGE-KIND) gives the rule
// above. Setup: Original message execution observers receive actual public
// reporting API calls;the separate error-continuation input uses the
// unmodified default server with a positive100 quit limit. Standard INFO
// levels0/100/200/300/400 are tested with global,ID,severity-ID and
// independent reporter settings. Original unbound sequences expose actual
// state getters inside hooks,positive body delays,optional hook
// control,kill,peer isolation and restart. No UVM state is assigned by the
// fixture. Expected: Execution snapshots preserve the selected
// severity,origin,ID,body and default or explicitly supplied
// verbosity;non-INFO generic calls ignore the selected verbosity bound.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Standard-derived observations; no enum bit positions or report layout fixed.
module test_enum_state_severity_generic_above_threshold_84;
  import uvm_pkg::*;
  `include "report84.svh"
  initial begin
    automatic report_observer84 server=new();
    automatic uvm_report_object reporter=new("generic84");
    automatic uvm_severity kinds[3]='{UVM_WARNING,UVM_ERROR,UVM_FATAL};
    automatic bit fields=1;
    string id;
    uvm_report_server::set_server(server); reporter.set_report_verbosity_level(UVM_NONE);
    reporter.set_report_severity_action(UVM_INFO,UVM_DISPLAY);
    foreach(kinds[i]) reporter.set_report_severity_action(kinds[i],UVM_DISPLAY);
    reporter.uvm_report(UVM_INFO,"I84","filtered84",777);
    $display("UT: severity84 generic info_filtered %0d",server.calls==0);
    foreach(kinds[i]) begin
      id=$sformatf("N%0d",i); reporter.uvm_report(kinds[i],id,"body84",777);
      fields &= server.calls==i+1 && server.matches84(reporter,kinds[i],777,id,"body84");
    end
    $display("UT: severity84 generic noninfo %0d fields %0d",server.calls==3,fields);
    $finish;
  end
endmodule
