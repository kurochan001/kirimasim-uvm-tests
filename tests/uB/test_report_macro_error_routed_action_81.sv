/*
:name: test_report_macro_error_routed_action_81
:description: Actual uvm_error routed action with independent message and context observers
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.1.1.3 B.1 6.3.3.2 6.3.3.3 6.3.4.3 6.3.5.2 6.5.1.2.16 6.2.3.1 6.2.4.5 6.2.4.6 6.2.4.7 F.3.2.3 1800-2023 6.21 8.20 22.5 22.13
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers81/report_macros81.svh
:expected_exit: 0
:expected_stdout: @test_report_macro_error_routed_action_81.expected
*/
// What it checks:
// 1. Reporting macros supply the source filename and line of the macro
//    invocation.
// 2. Warning, error and fatal macros enforce UVM_NONE as their message
//    verbosity.
// 3. Each reporting macro expands to a complete SystemVerilog statement.
// 4. Reporting macros introduce no time-consuming statement.
// 5. uvm_error delegates its ID, message and severity to the associated
//    reporting context.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 B.1 (UVM-REPORT-MACRO-AUTOMATIC-SOURCE-LOCATION) gives rule 1
//    above. Setup: Actual basic/context reporting macros run in original
//    report-object functions. Explicit context objects have independent
//    verbosity/action configuration. An original report-server execution hook
//    snapshots scalar message fields and source identity without default
//    DISPLAY/COUNT/EXIT effects. MSG functions count formatting; disjoint IDs,
//    true/false unbraced branches and a positive simulation time expose
//    selected filtering, grammar and time behavior. Expected: Executed
//    messages match independently captured file and next-line tokens at the
//    actual caller for basic and explicit-context macros.
// 2. 1800.2-2020 B.1 (UVM-REPORT-MACRO-NONINFO-NONE-VERBOSITY) gives rule 2
//    above. Setup: Actual basic/context reporting macros run in original
//    report-object functions. Explicit context objects have independent
//    verbosity/action configuration. An original report-server execution hook
//    snapshots scalar message fields and source identity without default
//    DISPLAY/COUNT/EXIT effects. MSG functions count formatting; disjoint IDs,
//    true/false unbraced branches and a positive simulation time expose
//    selected filtering, grammar and time behavior. Expected: All six
//    ordinary/context severity forms deliver UVM_NONE under both uniform and
//    ID-specific admission conditions.
// 3. 1800.2-2020 B.1 (UVM-REPORT-MACRO-COMPLETE-STATEMENT) gives rule 3 above.
//    Setup: Actual basic/context reporting macros run in original
//    report-object functions. Explicit context objects have independent
//    verbosity/action configuration. An original report-server execution hook
//    snapshots scalar message fields and source identity without default
//    DISPLAY/COUNT/EXIT effects. MSG functions count formatting; disjoint IDs,
//    true/false unbraced branches and a positive simulation time expose
//    selected filtering, grammar and time behavior. Expected: The macro
//    compiles as an unbraced if branch paired with else; the false branch only
//    increments else and the true branch delivers once.
// 4. 1800.2-2020 B.1 (UVM-REPORT-MACRO-NO-TIME-CONSUMPTION) gives rule 4
//    above. Setup: Actual basic/context reporting macros run in original
//    report-object functions. Explicit context objects have independent
//    verbosity/action configuration. An original report-server execution hook
//    snapshots scalar message fields and source identity without default
//    DISPLAY/COUNT/EXIT effects. MSG functions count formatting; disjoint IDs,
//    true/false unbraced branches and a positive simulation time expose
//    selected filtering, grammar and time behavior. Expected: Class-function
//    use builds legally and all selected visible, filtered and statement-form
//    calls retain the positive caller simulation time.
// 5. 1800.2-2020 B.1.1.3 (UVM-REPORT-MACRO-UVM-ERROR-DELEGATION) gives rule 5
//    above. Setup: Actual basic/context reporting macros run in original
//    report-object functions. Explicit context objects have independent
//    verbosity/action configuration. An original report-server execution hook
//    snapshots scalar message fields and source identity without default
//    DISPLAY/COUNT/EXIT effects. MSG functions count formatting; disjoint IDs,
//    true/false unbraced branches and a positive simulation time expose
//    selected filtering, grammar and time behavior. Expected: The actual
//    execution hook receives one ERROR message with the supplied ID/body and
//    the calling report-object origin.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Explicit report-object contexts; no optional-RO or default fatal-exit claim.
module test_report_macro_error_routed_action_81;
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
    caller.set_report_severity_action(UVM_ERROR,UVM_NO_ACTION);
    other.set_report_verbosity_level(UVM_NONE);
    other.set_report_severity_action(UVM_ERROR,UVM_NO_ACTION);
    target.set_report_verbosity_level(UVM_HIGH);
    target.set_report_severity_action(UVM_ERROR,UVM_DISPLAY);
    uvm_coreservice_t::get().set_report_server(server);
    #3;
    target.set_report_severity_action(UVM_ERROR,UVM_NO_ACTION);
    target.set_report_severity_id_action(UVM_ERROR,"live81",UVM_DISPLAY);
    server.reset_observer81(); caller.formats=0; before_tick=$time;
    caller.emit_error(target,"hidden81",UVM_LOW);
    quiet=server.calls==0; cheap=caller.formats==0; same_time=$time==before_tick;
    // Early MSG suppression is required only for INFO.
    $display("UT: macro81 uvm_error action quiet %0d time %0d",
      quiet,same_time);
    server.reset_observer81(); caller.formats=0; before_tick=$time;
    caller.emit_error(target,"live81",UVM_LOW);
    $display("UT: macro81 uvm_error routed_action fields %0d level %0d origin %0d",
      server.calls==1 && server.severity==UVM_ERROR &&
      server.id=="live81" && server.message=="body81",
      server.verbosity==UVM_NONE,server.source==target);
    $display("UT: macro81 uvm_error routed_action location %0d format %0d time %0d",
      server.filename==caller.expected_file && server.line_number==caller.expected_line,
      caller.formats>0,$time==before_tick);
    statement.set_report_verbosity_level(UVM_HIGH);
    statement.set_report_severity_action(UVM_ERROR,UVM_DISPLAY);
    other.set_report_verbosity_level(UVM_HIGH);
    other.set_report_severity_action(UVM_ERROR,UVM_DISPLAY);
    statement.otherwise_count=0; statement.formats=0;
    server.reset_observer81(); before_tick=$time;
    statement.statement_error(statement,"statement81",UVM_LOW,0);
    quiet=server.calls==0 && statement.formats==0;
    statement.statement_error(statement,"statement81",UVM_LOW,1);
    $display("UT: macro81 uvm_error statement else %0d entry %0d quiet %0d time %0d",
      statement.otherwise_count==1,server.calls==1 && statement.formats>0,quiet,
      $time==before_tick);
    uvm_coreservice_t::get().set_report_server(saved); $finish;
  end
endmodule
