/*
:name: test_enum_state_verbosity_id_limits_and_peer_84
:description: Named levels use the effective ID or severity-ID limit while a separate reporter retains its own limit
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.2.4 6.3.3.3 6.3.4.3 6.3.4.4 6.4.3.1 6.4.3.3 6.3.5.2 6.5.1.2.16 6.5.1.2.19 1800-2023 6.21 6.19.5 8.20 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers84_report/report84.svh
:expected_exit: 0
:expected_stdout: @test_enum_state_verbosity_id_limits_and_peer_84.expected
*/
// What it checks:
// Named verbosity levels use the effective report-specific configured limit.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.2.2.4 (UVM-ENUM-STATE-INFO-EFFECTIVE-LIMITS) gives the rule
// above. Setup: Original message execution observers receive actual public
// reporting API calls;the separate error-continuation input uses the
// unmodified default server with a positive100 quit limit. Standard INFO
// levels0/100/200/300/400 are tested with global,ID,severity-ID and
// independent reporter settings. Original unbound sequences expose actual
// state getters inside hooks,positive body delays,optional hook
// control,kill,peer isolation and restart. No UVM state is assigned by the
// fixture. Expected: Selected severity-ID,ID-only and global limits route the
// named levels as configured,while another reporter remains independent.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Standard-derived observations; no enum bit positions or report layout fixed.
module test_enum_state_verbosity_id_limits_and_peer_84;
  import uvm_pkg::*;
  `include "report84.svh"
  initial begin
    automatic report_observer84 server=new();
    automatic uvm_report_object reporter=new("local84");
    automatic uvm_report_object peer=new("peer84");
    automatic string ids[3]='{"A84","B84","C84"};
    automatic int limits[3]='{UVM_MEDIUM,UVM_FULL,UVM_LOW};
    automatic int levels[5]='{UVM_NONE,UVM_LOW,UVM_MEDIUM,UVM_HIGH,UVM_FULL};
    automatic bit delivery=1,fields=1;
    bit issued;
    int before_calls;
    uvm_report_server::set_server(server);
    reporter.set_report_severity_action(UVM_INFO,UVM_DISPLAY);
    peer.set_report_severity_action(UVM_INFO,UVM_DISPLAY);
    reporter.set_report_verbosity_level(UVM_LOW); peer.set_report_verbosity_level(UVM_NONE);
    reporter.set_report_id_verbosity("A84",UVM_FULL);
    reporter.set_report_severity_id_verbosity(UVM_INFO,"A84",UVM_MEDIUM);
    reporter.set_report_id_verbosity("B84",UVM_FULL);
    foreach(ids[i]) foreach(levels[v]) begin
      before_calls=server.calls; reporter.uvm_report_info(ids[i],"local84",levels[v]);
      issued=levels[v]<=limits[i]; delivery &= server.calls==before_calls+int'(issued);
      if(issued) fields &= server.matches84(reporter,UVM_INFO,levels[v],ids[i],"local84");
      before_calls=server.calls; peer.uvm_report_info(ids[i],"peer84",levels[v]);
      issued=levels[v]==UVM_NONE; delivery &= server.calls==before_calls+int'(issued);
      if(issued) fields &= server.matches84(peer,UVM_INFO,levels[v],ids[i],"peer84");
    end
    $display("UT: verbosity84 limits delivery %0d fields %0d",delivery,fields);
    $finish;
  end
endmodule
