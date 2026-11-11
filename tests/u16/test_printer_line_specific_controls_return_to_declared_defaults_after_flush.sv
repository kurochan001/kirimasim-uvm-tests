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
// What it checks:
// 1. The line separator getter starts at braces and updates independently.
// 2. A line printer flush restores its declared separator default.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.2.12.3 (UVM-PRINTER-AUDIT-LINE-SEPARATORS-GET-SET) gives
//    rule 1 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The selected
//    separators change to [] while its peer remains {}.
// 2. 1800.2-2020 16.2.12.3 (UVM-PRINTER-AUDIT-LINE-SEPARATORS-FLUSH) gives
//    rule 2 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: Without
//    another separator setter after flush, the getter returns {}.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
