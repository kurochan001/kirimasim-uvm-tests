/*
:name: test_printer_radix_defaults_updates_and_instance_isolation_follow_defined_radices
:description: printer radix defaults updates and instance isolation follow defined radices
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.5.6 16.2.5.7 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_radix_defaults_updates_and_instance_isolation_follow_defined_radices.expected
*/
// What it checks:
// 1. A fresh printer reports 'd as the defined DEC prefix.
// 2. A fresh printer reports 'b as the defined BIN prefix.
// 3. A fresh printer reports 'o as the defined OCT prefix.
// 4. A fresh printer reports 'd as the defined UNSIGNED prefix.
// 5. A fresh printer reports 'h as the defined HEX prefix.
// 6. Prefix updates are selected by radix and printer instance.
// 7. A new printer defaults its unspecified integral radix to HEX.
// 8. The default-radix setter updates only its selected printer.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.2.5.6 (UVM-PRINTER-AUDIT-DEFAULT-RADIX-STRING-DEC) gives
//    rule 1 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The selected
//    defined-radix getter matches its declared prefix before configuration.
// 2. 1800.2-2020 16.2.5.6 (UVM-PRINTER-AUDIT-DEFAULT-RADIX-STRING-BIN) gives
//    rule 2 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The selected
//    defined-radix getter matches its declared prefix before configuration.
// 3. 1800.2-2020 16.2.5.6 (UVM-PRINTER-AUDIT-DEFAULT-RADIX-STRING-OCT) gives
//    rule 3 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The selected
//    defined-radix getter matches its declared prefix before configuration.
// 4. 1800.2-2020 16.2.5.6 (UVM-PRINTER-AUDIT-DEFAULT-RADIX-STRING-UNSIGNED)
//    gives rule 4 above. Setup: Use the original selected fixtures and
//    explicit API arguments represented by the observation anchors. Expected:
//    The selected defined-radix getter matches its declared prefix before
//    configuration.
// 5. 1800.2-2020 16.2.5.6 (UVM-PRINTER-AUDIT-DEFAULT-RADIX-STRING-HEX) gives
//    rule 5 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The selected
//    defined-radix getter matches its declared prefix before configuration.
// 6. 1800.2-2020 16.2.5.6 (UVM-PRINTER-AUDIT-RADIX-STRING-UPDATE-ISOLATION)
//    gives rule 6 above. Setup: Use the original selected fixtures and
//    explicit API arguments represented by the observation anchors. Expected:
//    HEX/DEC updates leave BIN/UNSIGNED and an independent peer at their
//    original prefixes.
// 7. 1800.2-2020 16.2.5.7 (UVM-PRINTER-AUDIT-DEFAULT-RADIX-HEX) gives rule 7
//    above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: Default HEX,
//    selected BIN and unchanged peer HEX getters match.
// 8. 1800.2-2020 16.2.5.7 (UVM-PRINTER-AUDIT-DEFAULT-RADIX-UPDATE) gives rule
//    8 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: Default HEX,
//    selected BIN and unchanged peer HEX getters match.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_printer_radix_defaults_updates_and_instance_isolation_follow_defined_radices;
  import uvm_pkg::*;
  initial begin
    automatic uvm_table_printer first=new();
    automatic uvm_table_printer peer=new();
    $display("UT: radix_defaults dec %0d bin %0d oct %0d unsigned %0d hex %0d default %0d",
             first.get_radix_string(UVM_DEC)=="'d",first.get_radix_string(UVM_BIN)=="'b",
             first.get_radix_string(UVM_OCT)=="'o",first.get_radix_string(UVM_UNSIGNED)=="'d",
             first.get_radix_string(UVM_HEX)=="'h",first.get_default_radix()==UVM_HEX);
    first.set_radix_string(UVM_HEX,"HEX42:"); first.set_radix_string(UVM_DEC,"DEC42:");
    first.set_default_radix(UVM_BIN);
    $display("UT: radix_updates hex %0d dec %0d bin %0d unsigned %0d default %0d",
             first.get_radix_string(UVM_HEX)=="HEX42:",first.get_radix_string(UVM_DEC)=="DEC42:",
             first.get_radix_string(UVM_BIN)=="'b",first.get_radix_string(UVM_UNSIGNED)=="'d",
             first.get_default_radix()==UVM_BIN);
    $display("UT: radix_peer hex %0d dec %0d default %0d",peer.get_radix_string(UVM_HEX)=="'h",
             peer.get_radix_string(UVM_DEC)=="'d",peer.get_default_radix()==UVM_HEX);
    $finish;
  end
endmodule
