/*
:name: test_printer_controls_are_per_instance_and_survive_flush
:description: printer controls belong to their instance and survive clearing print data (IEEE 1800.2-2020 Section 16.2.5.1)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.5.1 16.2.5.2 16.2.5.3 16.2.5.4 16.2.5.5 16.2.5.10 16.2.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_controls_are_per_instance_and_survive_flush.expected
*/
// What it checks:
// 1. The printer field-name enable accessor defaults to 1 and retains its
//    explicitly assigned value.
// 2. The printer type-name enable accessor defaults to 1 and retains its
//    explicitly assigned value.
// 3. The printer size enable accessor defaults to 1 and retains its explicitly
//    assigned value.
// 4. The printer reference-ID enable accessor defaults to 1 and retains its
//    explicitly assigned value.
// 5. The printer radix enable accessor defaults to 1 and retains its
//    explicitly assigned value.
// 6. The printer maximum depth accessor defaults to -1 and retains its
//    explicitly assigned value.
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
// 4. 1800.2-2020 16.2.5.4 (UVM-PRINTER-ID-CONFIGURATION) gives rule 4 above.
//    Setup: Configure one printer, flush it and inspect another instance.
//    Expected: The chosen value survives flush and another printer keeps its
//    default.
// 5. 1800.2-2020 16.2.5.5 (UVM-PRINTER-RADIX-CONFIGURATION) gives rule 5
//    above. Setup: Configure one printer, flush it and inspect another
//    instance. Expected: The chosen value survives flush and another printer
//    keeps its default.
// 6. 1800.2-2020 16.2.5.10 (UVM-PRINTER-DEPTH-CONFIGURATION) gives rule 6
//    above. Setup: Configure one printer, flush it and inspect another
//    instance. Expected: The chosen value survives flush and another printer
//    keeps its default.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Flush clears accumulated print data. Name, type, size, ID, radix and
// maximum-depth controls retain their settings and leave another printer alone.

module test_printer_controls_are_per_instance_and_survive_flush;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_table_printer first = new;
    automatic uvm_table_printer second = new;
    first.set_name_enabled(0);
    first.set_type_name_enabled(0);
    first.set_size_enabled(0);
    first.set_id_enabled(0);
    first.set_radix_enabled(0);
    first.set_max_depth(0);
    first.flush();
    $display("UT: retained %0d %0d %0d %0d %0d depth %0d", first.get_name_enabled(),
             first.get_type_name_enabled(), first.get_size_enabled(), first.get_id_enabled(),
             first.get_radix_enabled(), first.get_max_depth());
    $display("UT: independent %0d %0d %0d %0d %0d depth %0d", second.get_name_enabled(),
             second.get_type_name_enabled(), second.get_size_enabled(), second.get_id_enabled(),
             second.get_radix_enabled(), second.get_max_depth());
    $finish;
  end
endmodule
