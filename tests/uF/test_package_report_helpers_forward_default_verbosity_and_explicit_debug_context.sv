/*
:name: test_package_report_helpers_forward_default_verbosity_and_explicit_debug_context
:description: Package severity helpers delegate default verbosity and explicit message/debug/context fields
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.3.2.3 6.3.3.3 6.3.8.2 6.4.7 6.2.4.1 6.2.4.4 6.2.4.5 6.2.4.6 6.2.4.7 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_package_report_helpers_forward_default_verbosity_and_explicit_debug_context.expected
*/
// What it checks:
// 1. Package severity helpers use their declared default verbosity.
// 2. All four package severity helpers forward explicit payload, verbosity,
//    filename, line and context.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 F.3.2.3 (UVM-PACKAGE-AUDIT-HELPER-DEFAULTS) gives rule 1
//    above. Setup: A standalone module temporarily installs an original root
//    handler and restores the saved handler after the selected calls.
//    Expected: INFO uses MEDIUM and WARNING/ERROR/FATAL use NONE through the
//    root handler.
// 2. 1800.2-2020 F.3.2.3 (UVM-PACKAGE-AUDIT-HELPER-EXPLICIT-FIELDS) gives rule
//    2 above. Setup: A standalone module temporarily installs an original root
//    handler and restores the saved handler after the selected calls.
//    Expected: Every explicit row has its requested severity and fields and
//    reaches the root handler.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_package_report_helpers_forward_default_verbosity_and_explicit_debug_context;
  import uvm_pkg::*;

  class capture_handler extends uvm_report_handler;
    int count=0;
    uvm_report_message last;
    uvm_severity severities[$];
    int verbosity_values[$];
    bit fields_ok=1;
    uvm_report_object expected_origin;
    function new(); super.new("capture57"); endfunction
    virtual function void process_report_message(uvm_report_message report_message);
      count++; last=report_message;
      severities.push_back(report_message.get_severity());
      verbosity_values.push_back(report_message.get_verbosity());
      fields_ok &= report_message.get_report_object()==expected_origin;
    endfunction
  endclass

  initial begin
    automatic uvm_root root=uvm_root::get();
    automatic capture_handler capture=new();
    automatic uvm_severity expected[4]='{UVM_INFO,UVM_WARNING,UVM_ERROR,UVM_FATAL};
    automatic bit defaults_ok=1,fields_ok=1;
    uvm_report_handler saved;
    saved=root.get_report_handler(); root.set_report_handler(capture);
    capture.expected_origin=root; root.set_report_verbosity_level(UVM_DEBUG);
    uvm_report_info("helper57","payload57"); uvm_report_warning("helper57","payload57");
    uvm_report_error("helper57","payload57"); uvm_report_fatal("helper57","payload57");
    foreach (expected[i]) begin
      defaults_ok &= capture.severities[i]==expected[i] &&
        capture.verbosity_values[i]==(i==0 ? UVM_MEDIUM : UVM_NONE);
      $display("UT: helper_default row %0d verbosity %0d",i,capture.verbosity_values[i]);
    end
    foreach (expected[i]) begin
      case (i)
        0: uvm_report_info("helper57","explicit57",UVM_LOW,"source57.sv",957,"context57");
        1: uvm_report_warning("helper57","explicit57",UVM_LOW,"source57.sv",957,"context57");
        2: uvm_report_error("helper57","explicit57",UVM_LOW,"source57.sv",957,"context57");
        3: uvm_report_fatal("helper57","explicit57",UVM_LOW,"source57.sv",957,"context57");
      endcase
      fields_ok &= capture.last!=null && capture.last.get_severity()==expected[i] &&
        capture.last.get_id()=="helper57" && capture.last.get_message()=="explicit57" &&
        capture.last.get_verbosity()==UVM_LOW && capture.last.get_filename()=="source57.sv" &&
        capture.last.get_line()==957 && capture.last.get_context()=="context57";
    end
    $display(
      "UT: report_helpers calls %0d severity_defaults %0d explicit_fields %0d root_origin %0d",
      capture.count,defaults_ok,fields_ok,capture.fields_ok);
    root.set_report_handler(saved); $finish;
  end
endmodule
