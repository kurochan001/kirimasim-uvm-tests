/*
:name: test_printer_tree_textual_columns_follow_controls_before_collection
:description: tree column visibility uses controls set before collection (IEEE 1800.2-2020 Section 16.2.5.2)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.5.2 16.2.5.1 16.2.5.3 16.2.3.1 16.2.3.4 16.2.4.1 16.2.4.2 16.2.7 5.3.6.2 5.3.6.3 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers75/printer_columns75.svh
:expected_exit: 0
:expected_stdout: @test_printer_tree_textual_columns_follow_controls_before_collection.expected
*/
// What it checks:
// 1. The printer field-name enable accessor defaults to 1 and retains its
//    explicitly assigned value.
// 2. The printer type-name enable accessor defaults to 1 and retains its
//    explicitly assigned value.
// 3. The printer size enable accessor defaults to 1 and retains its explicitly
//    assigned value.
// 4. The field-name enable control affects inclusion of field names during
//    printer emission.
// 5. Field type-name emission follows the current type-name enable control.
// 6. Field size emission follows the current size enable control.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.2.5.1 (UVM-PRINTER-NAME-CONFIGURATION) gives rule 1 above.
//    Setup: Configure one printer, flush it and inspect another instance.
//    Additional actual table/tree/line fixtures query all three fresh peer
//    settings before any peer setter; four explicit-enable controls retain a
//    distinct premise. Expected: The chosen value survives flush and another
//    printer keeps its default.
// 2. 1800.2-2020 16.2.5.2 (UVM-PRINTER-TYPE-CONFIGURATION) gives rule 2 above.
//    Setup: Configure one printer, flush it and inspect another instance.
//    Additional actual table/tree/line fixtures query all three fresh peer
//    settings before any peer setter; four explicit-enable controls retain a
//    distinct premise. Expected: The chosen value survives flush and another
//    printer keeps its default.
// 3. 1800.2-2020 16.2.5.3 (UVM-PRINTER-SIZE-CONFIGURATION) gives rule 3 above.
//    Setup: Configure one printer, flush it and inspect another instance.
//    Additional actual table/tree/line fixtures query all three fresh peer
//    settings before any peer setter; four explicit-enable controls retain a
//    distinct premise. Expected: The chosen value survives flush and another
//    printer keeps its default.
// 4. 1800.2-2020 16.2.5.1 (UVM-PRINTER-NAME-EMISSION) gives rule 4 above.
//    Setup: Emit equivalent fields with name printing enabled and disabled.
//    Two fields use distinct caller-supplied textual name/type/size/value
//    attributes through print_generic_element. Actual table/tree/line printers
//    each exercise all eight name/type/size masks. One path sets controls
//    before object sprint; another collects under the opposite mask and
//    changes controls only before emit. Reuse changes values and checks an
//    independent fresh peer policy. Default-peer inputs retain their
//    omitted-setting premise. Four separately named tree/line controls
//    explicitly enable peer settings; their matches cannot pass the
//    default-peer inputs. Expected: The enabled form includes names and the
//    disabled form omits them.
// 5. 1800.2-2020 16.2.5.2 (UVM-PRINTER-TYPE-EMISSION) gives rule 5 above.
//    Setup: Two fields use distinct caller-supplied textual
//    name/type/size/value attributes through print_generic_element. Actual
//    table/tree/line printers each exercise all eight name/type/size masks.
//    One path sets controls before object sprint; another collects under the
//    opposite mask and changes controls only before emit. Reuse changes values
//    and checks an independent fresh peer policy. Default-peer inputs retain
//    their omitted-setting premise. Four separately named tree/line controls
//    explicitly enable peer settings; their matches cannot pass the
//    default-peer inputs. Expected: Both supplied attributes are present when
//    enabled and both absent when disabled, even after collection; current
//    values remain and prior values are absent, while the independent peer
//    keeps its enabled defaults.
// 6. 1800.2-2020 16.2.5.3 (UVM-PRINTER-SIZE-EMISSION) gives rule 6 above.
//    Setup: Two fields use distinct caller-supplied textual
//    name/type/size/value attributes through print_generic_element. Actual
//    table/tree/line printers each exercise all eight name/type/size masks.
//    One path sets controls before object sprint; another collects under the
//    opposite mask and changes controls only before emit. Reuse changes values
//    and checks an independent fresh peer policy. Default-peer inputs retain
//    their omitted-setting premise. Four separately named tree/line controls
//    explicitly enable peer settings; their matches cannot pass the
//    default-peer inputs. Expected: Both supplied attributes are present when
//    enabled and both absent when disabled, even after collection; current
//    values remain and prior values are absent, while the independent peer
//    keeps its enabled defaults.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Exact caller-supplied strings avoid assuming numeric size rendering.
// Visibility checks prescribe no rows, columns, widths or punctuation.
module test_printer_tree_textual_columns_follow_controls_before_collection;
  import uvm_pkg::*;
  `include "printer_columns75.svh"
  initial begin
    automatic subject75 subject = new;
    automatic uvm_printer printer = make_printer75(1);
    automatic uvm_printer peer = make_printer75(1);
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
