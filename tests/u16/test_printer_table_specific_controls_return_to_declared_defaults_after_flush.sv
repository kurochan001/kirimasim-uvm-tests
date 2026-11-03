/*
:name: test_printer_table_specific_controls_return_to_declared_defaults_after_flush
:description: printer table specific controls return to declared defaults after flush
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.10.3 16.2.4.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_table_specific_controls_return_to_declared_defaults_after_flush.expected
*/
module test_printer_table_specific_controls_return_to_declared_defaults_after_flush;
  import uvm_pkg::*;
  initial begin
    automatic uvm_table_printer selected=new();
    automatic uvm_table_printer peer=new();
    $display("UT: indent_default %0d",selected.get_indent()==2);
    selected.set_indent(5);
    $display("UT: indent_changed selected %0d peer %0d",selected.get_indent()==5,
             peer.get_indent()==2);
    selected.flush();
    $display("UT: indent_after_flush %0d",selected.get_indent()==2);
    $finish;
  end
endmodule
