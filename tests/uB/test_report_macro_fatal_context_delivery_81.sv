/*
:name: test_report_macro_fatal_context_delivery_81
:description: Actual uvm_fatal_context delivery with independent message and context observers
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.1.1.8 B.1 6.3.3.2 6.3.3.3 6.3.4.3 6.3.5.2 6.5.1.2.16 6.2.3.1 6.2.4.5 6.2.4.6 6.2.4.7 F.3.2.3 1800-2023 6.21 8.20 22.5 22.13
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers81/report_macros81.svh
:expected_exit: 0
:expected_stdout: @test_report_macro_fatal_context_delivery_81.expected
*/
// Explicit report-object contexts; no optional-RO or default fatal-exit claim.
module test_report_macro_fatal_context_delivery_81;
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
    target=other;
    caller.set_report_verbosity_level(UVM_NONE);
    caller.set_report_severity_action(UVM_FATAL,UVM_NO_ACTION);
    other.set_report_verbosity_level(UVM_NONE);
    other.set_report_severity_action(UVM_FATAL,UVM_NO_ACTION);
    target.set_report_verbosity_level(UVM_HIGH);
    target.set_report_severity_action(UVM_FATAL,UVM_DISPLAY);
    uvm_coreservice_t::get().set_report_server(server);
    #3;
    server.reset_observer81(); caller.formats=0; before_tick=$time;
    caller.emit_fatal_context(target,"live81",UVM_LOW);
    $display("UT: macro81 uvm_fatal_context delivery fields %0d level %0d origin %0d",
      server.calls==1 && server.severity==UVM_FATAL &&
      server.id=="live81" && server.message=="body81",
      server.verbosity==UVM_NONE,server.source==target);
    $display("UT: macro81 uvm_fatal_context delivery location %0d format %0d time %0d",
      server.filename==caller.expected_file && server.line_number==caller.expected_line,
      caller.formats>0,$time==before_tick);
    statement.set_report_verbosity_level(UVM_HIGH);
    statement.set_report_severity_action(UVM_FATAL,UVM_DISPLAY);
    other.set_report_verbosity_level(UVM_HIGH);
    other.set_report_severity_action(UVM_FATAL,UVM_DISPLAY);
    statement.otherwise_count=0; statement.formats=0;
    server.reset_observer81(); before_tick=$time;
    statement.statement_fatal_context(other,"statement81",UVM_LOW,0);
    quiet=server.calls==0 && statement.formats==0;
    statement.statement_fatal_context(other,"statement81",UVM_LOW,1);
    $display("UT: macro81 uvm_fatal_context statement else %0d entry %0d quiet %0d time %0d",
      statement.otherwise_count==1,server.calls==1 && statement.formats>0,quiet,
      $time==before_tick);
    uvm_coreservice_t::get().set_report_server(saved); $finish;
  end
endmodule
