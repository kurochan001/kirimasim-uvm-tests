/*
:name: test_printer_line_specific_controls_return_to_declared_defaults_after_flush
:description: printer line specific controls return to declared defaults after flush
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.12.3 16.2.4.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_line_specific_controls_return_to_declared_defaults_after_flush.expected
*/
module test_printer_line_specific_controls_return_to_declared_defaults_after_flush;
  import uvm_pkg::*;
  initial begin
    automatic uvm_line_printer selected=new();
    automatic uvm_line_printer peer=new();
    $display("UT: separators_default %0d",selected.get_separators()=="{}");
    selected.set_separators("[]");
    $display("UT: separators_changed selected %0d peer %0d",selected.get_separators()=="[]",
             peer.get_separators()=="{}");
    selected.flush();
    $display("UT: separators_after_flush %0d",selected.get_separators()=="{}");
    $finish;
  end
endmodule
