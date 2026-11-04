/*
:name: test_package_preformed_report_processing_delegates_the_exact_message_and_rebinds_root_origin
:description: Package preformed reporting delegates the same public message and selects the implicit root as origin
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.3.2.3 6.3.3.4 6.3.8.2 6.4.7 6.2.3.1 6.2.4.10 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_package_preformed_report_processing_delegates_the_exact_message_and_rebinds_root_origin.expected
*/
module test_package_preformed_report_processing_delegates_the_exact_message_and_rebinds_root_origin;
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
    automatic uvm_report_object obsolete=new("obsolete57");
    automatic capture_handler capture=new();
    automatic uvm_report_message message=uvm_report_message::new_report_message("input57");
    uvm_report_handler saved;
    saved=root.get_report_handler(); root.set_report_handler(capture); capture.expected_origin=root;
    message.set_report_message(UVM_INFO,"input57","payload57",UVM_LOW,"source57.sv",957,"ctx57");
    message.set_report_object(obsolete); uvm_process_report_message(message);
    $display("UT: preformed_global calls %0d same %0d root_origin %0d fields %0d",capture.count,
      capture.last==message,message.get_report_object()==root && capture.fields_ok,
      message.get_id()=="input57" && message.get_message()=="payload57" &&
      message.get_verbosity()==UVM_LOW && message.get_filename()=="source57.sv" &&
      message.get_line()==957 && message.get_context()=="ctx57");
    root.set_report_handler(saved); $finish;
  end
endmodule
