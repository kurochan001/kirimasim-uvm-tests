/*
:name: test_package_generic_report_defaults_preserve_severity_specific_verbosity_and_message_fields
:description: The generic package report delegates all four severities with their declared verbosity and field defaults
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.3.2.3 6.3.3.3 6.3.8.2 6.4.7 6.2.4.1 6.2.4.4 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_package_generic_report_defaults_preserve_severity_specific_verbosity_and_message_fields.expected
*/
// What it checks:
// 1. The generic package report uses MEDIUM for omitted INFO verbosity and
//    NONE for the other severities.
// 2. The generic package report forwards ID/payload and empty filename/context
//    plus line zero defaults.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 F.3.2.3 (UVM-PACKAGE-AUDIT-GENERIC-DEFAULTS) gives rule 1
//    above. Setup: A standalone module temporarily installs an original root
//    handler and restores the saved handler after the selected calls.
//    Expected: All four captured severities have their prescribed default
//    verbosity.
// 2. 1800.2-2020 F.3.2.3 (UVM-PACKAGE-AUDIT-GENERIC-MESSAGE-DEFAULTS) gives
//    rule 2 above. Setup: A standalone module temporarily installs an original
//    root handler and restores the saved handler after the selected calls.
//    Expected: Each captured message retains its requested fields/defaults and
//    root origin.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// An original handler captures delegation before server actions or emission.
module test_package_generic_report_defaults_preserve_severity_specific_verbosity_and_message_fields;
  import uvm_pkg::*;

  class capture_handler extends uvm_report_handler;
    int count=0;
    uvm_report_message last;
    uvm_severity severities[$];
    int verbosity_values[$];
    bit fields_ok=1;
    uvm_report_object expected_origin;
    function new(); super.new("capture57"); endfunction
    virtual function void process_report_message(uvm_report_message message);
      count++; last=message;
      severities.push_back(message.get_severity());
      verbosity_values.push_back(message.get_verbosity());
      fields_ok &= message.get_report_object()==expected_origin;
    endfunction
  endclass

  initial begin
    automatic uvm_root root=uvm_root::get();
    automatic capture_handler capture=new();
    automatic uvm_severity selected[4]='{UVM_INFO,UVM_WARNING,UVM_ERROR,UVM_FATAL};
    automatic bit defaults_ok=1,fields_ok=1;
    uvm_report_handler saved;
    saved=root.get_report_handler(); root.set_report_handler(capture);
    capture.expected_origin=root; root.set_report_verbosity_level(UVM_DEBUG);
    foreach (selected[i]) begin
      uvm_report(selected[i],"generic57","payload57");
      $display("UT: generic_default row %0d verbosity %0d",i,capture.last.get_verbosity());
      defaults_ok &= capture.last!=null &&
        capture.last.get_verbosity()==(i==0 ? UVM_MEDIUM : UVM_NONE);
      fields_ok &= capture.last!=null && capture.last.get_severity()==selected[i] &&
        capture.last.get_id()=="generic57" && capture.last.get_message()=="payload57" &&
        capture.last.get_filename()=="" &&
        capture.last.get_line()==0 && capture.last.get_context()=="";
    end
    $display("UT: generic_reports calls %0d verbosity_defaults %0d fields %0d root_origin %0d",
      capture.count,defaults_ok,fields_ok,capture.fields_ok);
    root.set_report_handler(saved); $finish;
  end
endmodule
