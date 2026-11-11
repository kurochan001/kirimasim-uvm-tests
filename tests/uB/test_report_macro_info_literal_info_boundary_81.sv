/*
:name: test_report_macro_info_literal_info_boundary_81
:description: Actual uvm_info literal info boundary with independent message and context observers
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.1.1.1 B.1 6.3.3.2 6.3.3.3 6.3.4.3 6.3.5.2 6.5.1.2.16 6.2.3.1 6.2.4.5 6.2.4.6 6.2.4.7 F.3.2.3 1800-2023 6.21 8.20 22.5 22.13
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers81/report_macros81.svh
:expected_exit: 0
:expected_stdout: @test_report_macro_info_literal_info_boundary_81.expected
*/
// What it checks:
// 1. Each reporting macro expands to a complete SystemVerilog statement.
// 2. Reporting macros introduce no time-consuming statement.
// 3. Under the qualified literal lower-than macro reading, equal INFO
//    verbosity is filtered before formatting.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 B.1 (UVM-REPORT-MACRO-COMPLETE-STATEMENT) gives rule 1 above.
//    Setup: Actual basic/context reporting macros run in original
//    report-object functions. Explicit context objects have independent
//    verbosity/action configuration. An original report-server execution hook
//    snapshots scalar message fields and source identity without default
//    DISPLAY/COUNT/EXIT effects. MSG functions count formatting; disjoint IDs,
//    true/false unbraced branches and a positive simulation time expose
//    selected filtering, grammar and time behavior. Expected: The macro
//    compiles as an unbraced if branch paired with else; the false branch only
//    increments else and the true branch delivers once.
// 2. 1800.2-2020 B.1 (UVM-REPORT-MACRO-NO-TIME-CONSUMPTION) gives rule 2
//    above. Setup: Actual basic/context reporting macros run in original
//    report-object functions. Explicit context objects have independent
//    verbosity/action configuration. An original report-server execution hook
//    snapshots scalar message fields and source identity without default
//    DISPLAY/COUNT/EXIT effects. MSG functions count formatting; disjoint IDs,
//    true/false unbraced branches and a positive simulation time expose
//    selected filtering, grammar and time behavior. Expected: Class-function
//    use builds legally and all selected visible, filtered and statement-form
//    calls retain the positive caller simulation time.
// 3. 1800.2-2020 B.1.1.1 (UVM-REPORT-MACRO-INFO-LITERAL-STRICT-BOUNDARY) gives
//    rule 3 above. Setup: Actual basic/context reporting macros run in
//    original report-object functions. Explicit context objects have
//    independent verbosity/action configuration. An original report-server
//    execution hook snapshots scalar message fields and source identity
//    without default DISPLAY/COUNT/EXIT effects. MSG functions count
//    formatting; disjoint IDs, true/false unbraced branches and a positive
//    simulation time expose selected filtering, grammar and time behavior.
//    Expected: The equal boundary leaves execution/format counters zero; a
//    separate strictly lower call still routes once to the selected context.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Explicit report-object contexts; no optional-RO or default fatal-exit claim.
module test_report_macro_info_literal_info_boundary_81;
  timeunit 1ns; timeprecision 1ns;
  import uvm_pkg::*;
  `include "report_macros81.svh"
  initial begin
    automatic macro_reporter81 caller=new("caller81");
    automatic macro_reporter81 other=new("other81");
    automatic macro_statement81 statement=new();
    automatic macro_server81 server=new();
    automatic uvm_report_server saved=uvm_report_server::get_server();
    uvm_report_object target;
    time before_tick;
    bit quiet, cheap, same_time;
    target=caller;
    caller.set_report_verbosity_level(UVM_NONE);
    caller.set_report_severity_action(UVM_INFO,UVM_NO_ACTION);
    other.set_report_verbosity_level(UVM_NONE);
    other.set_report_severity_action(UVM_INFO,UVM_NO_ACTION);
    target.set_report_verbosity_level(UVM_HIGH);
    target.set_report_severity_action(UVM_INFO,UVM_DISPLAY);
    uvm_coreservice_t::get().set_report_server(server);
    #3;
    // Literal B.1.1.1 lower-than boundary, distinct from the <= API guard.
    target.set_report_verbosity_level(UVM_LOW);
    server.reset_observer81(); caller.formats=0; before_tick=$time;
    caller.emit_info(target,"boundary81",UVM_LOW);
    $display("UT: macro81 uvm_info boundary quiet %0d cheap %0d time %0d",
      server.calls==0,caller.formats==0,$time==before_tick);
    server.reset_observer81(); caller.formats=0; before_tick=$time;
    caller.emit_info(target,"below81",UVM_NONE);
    $display("UT: macro81 uvm_info below entry %0d origin %0d level %0d",
      server.calls==1 && caller.formats>0 && server.id=="below81",
      server.source==target,server.verbosity==UVM_NONE);
    statement.set_report_verbosity_level(UVM_HIGH);
    statement.set_report_severity_action(UVM_INFO,UVM_DISPLAY);
    other.set_report_verbosity_level(UVM_HIGH);
    other.set_report_severity_action(UVM_INFO,UVM_DISPLAY);
    statement.otherwise_count=0; statement.formats=0;
    server.reset_observer81(); before_tick=$time;
    statement.statement_info(statement,"statement81",UVM_LOW,0);
    quiet=server.calls==0 && statement.formats==0;
    statement.statement_info(statement,"statement81",UVM_LOW,1);
    $display("UT: macro81 uvm_info statement else %0d entry %0d quiet %0d time %0d",
      statement.otherwise_count==1,server.calls==1 && statement.formats>0,quiet,
      $time==before_tick);
    uvm_coreservice_t::get().set_report_server(saved); $finish;
  end
endmodule
