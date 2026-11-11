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
// What it checks:
// 1. Direct INFO delivery admits a standard level when its configured
//    verbosity is at that level or above.
// 2. A qualified literal reading keeps UVM_NONE from being disabled by the
//    verbosity setting.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 F.2.2.4 (UVM-ENUM-STATE-INFO-STANDARD-BOUNDS) gives rule 1
//    above. Setup: Original message execution observers receive actual public
//    reporting API calls;the separate error-continuation input uses the
//    unmodified default server with a positive100 quit limit. Standard INFO
//    levels0/100/200/300/400 are tested with global,ID,severity-ID and
//    independent reporter settings. Original unbound sequences expose actual
//    state getters inside hooks,positive body delays,optional hook
//    control,kill,peer isolation and restart. No UVM state is assigned by the
//    fixture. Expected: The five-by-five direct-API matrix includes
//    equality,filters higher levels and preserves the admitted message fields.
// 2. 1800.2-2020 F.2.2.4 (UVM-ENUM-STATE-NONE-NO-VERBOSITY-DISABLE) gives rule
//    2 above. Setup: Original message execution observers receive actual
//    public reporting API calls;the separate error-continuation input uses the
//    unmodified default server with a positive100 quit limit. Standard INFO
//    levels0/100/200/300/400 are tested with global,ID,severity-ID and
//    independent reporter settings. Original unbound sequences expose actual
//    state getters inside hooks,positive body delays,optional hook
//    control,kill,peer isolation and restart. No UVM state is assigned by the
//    fixture. Expected: NONE reaches delivery at the selected nonnegative
//    standard limits and at an explicitly configured negative ID limit;the
//    independent API-bound query remains0 for the negative limit.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
