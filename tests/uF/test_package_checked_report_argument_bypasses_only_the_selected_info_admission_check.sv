/*
:name: test_package_checked_report_argument_bypasses_only_the_selected_info_admission_check
:description: An explicitly prechecked global info report bypasses filtering while an unchecked high-verbosity control is dropped
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.3.2.3 6.3.3.3 6.3.8.2 6.4.7 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_package_checked_report_argument_bypasses_only_the_selected_info_admission_check.expected
*/
// What it checks:
// An explicitly prechecked package INFO report bypasses the admission query;
// the default unchecked call is filtered.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.3.2.3 (UVM-PACKAGE-AUDIT-CHECKED-INFO) gives the rule above.
// Setup: A standalone module temporarily installs an original root handler and
// restores the saved handler after the selected calls. Expected: The unchecked
// HIGH report has no handler call under NONE; the checked report arrives once
// with the original HIGH verbosity and payload.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_package_checked_report_argument_bypasses_only_the_selected_info_admission_check;
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
    uvm_report_handler saved;
    saved=root.get_report_handler(); root.set_report_handler(capture);
    capture.expected_origin=root; root.set_report_verbosity_level(UVM_NONE);
    uvm_report_info("checked57","hidden57",UVM_HIGH);
    $display("UT: unchecked_info filtered %0d",capture.count==0);
    uvm_report_info("checked57","admitted57",UVM_HIGH,"checked57.sv",957,"ctx57",1);
    $display("UT: checked_info calls %0d message %0d verbosity %0d root_origin %0d",
      capture.count,capture.last!=null && capture.last.get_message()=="admitted57",
      capture.last!=null && capture.last.get_verbosity()==UVM_HIGH,capture.fields_ok);
    root.set_report_handler(saved); $finish;
  end
endmodule
