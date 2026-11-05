/*
:name: test_printer_table_textual_columns_follow_controls_before_collection
:description: table column visibility uses controls set before collection (IEEE 1800.2-2020 Section 16.2.5.2)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.5.2 16.2.5.1 16.2.5.3 16.2.3.1 16.2.3.4 16.2.4.1 16.2.4.2 16.2.7 5.3.6.2 5.3.6.3 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers75/printer_columns75.svh
:expected_exit: 0
:expected_stdout: @test_printer_table_textual_columns_follow_controls_before_collection.expected
*/
// Exact caller-supplied strings avoid assuming numeric size rendering.
// Visibility checks prescribe no rows, columns, widths or punctuation.
module test_printer_table_textual_columns_follow_controls_before_collection;
  import uvm_pkg::*;
  `include "printer_columns75.svh"
  initial begin
    automatic subject75 subject = new;
    automatic uvm_printer printer = make_printer75(0);
    automatic uvm_printer peer = make_printer75(0);
    string text;
    $display("UT: p75_peer name %0b type %0b size %0b", peer.get_name_enabled(),
             peer.get_type_name_enabled(), peer.get_size_enabled());
    for (int mask = 0; mask < 8; mask++) begin
      subject.revision = mask;
      configure75(printer, mask);
      text = subject.sprint(printer);
      observe75(mask, text, subject, peer);
    end
    $finish;
  end
endmodule
