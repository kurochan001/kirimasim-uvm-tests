/*
:name: test_radix_record_1_93
:description: record 1 checks typed radix or table-row effects through original observers
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.1.5 16.4.6.1 16.4.6.2 16.4.2.3 16.4.7.4 16.4.7.5 7.1.3.1 7.1.4.1 7.1.6.1 7.1.6.2 7.1.6.3 7.2.5.1 7.2.7.1 1800-2023 6.16 6.19 6.21 8.20 8.21 21.2.1.1 21.2.1.2 21.2.1.3 21.2.2 21.3.3 21.3.4.3
:uvm: 2020.3.1
:files: helpers93_record/record_fixture93.svh
:incdirs: helpers93_record
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_radix_record_1_93.expected
*/
// What it checks:
// 1. Recording a wide integral field forwards its supplied name and value to
//    its hook.
// 2. Recording a small integral field forwards its supplied name and value to
//    its hook.
// 3. UVM_UNFORMAT2 designates the selected unformatted two-value recording
//    representation.
// 4. UVM_UNFORMAT4 designates the selected unformatted four-value recording
//    representation.
//
// Variant: Input 0 uses 32-bit values and 16-character text; input 1 uses
// 65-bit values, 32-character text and other values, with UVM_DEC instead of
// UVM_OCT as the default radix and 64-bit instead of 32-bit integral values.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.4.6.1 (UVM-RECORDER-FIELD-ATTRIBUTE-HOOK) gives rule 1
//    above. Setup: Use one opened recorder and explicit width/radix or type
//    metadata where applicable. Expected: The selected implementation hook
//    observes the expected name, value and applicable metadata.
// 2. 1800.2-2020 16.4.6.2 (UVM-RECORDER-FIELD-INT-ATTRIBUTE-HOOK) gives rule 2
//    above. Setup: Use one opened recorder and explicit width/radix or type
//    metadata where applicable. Expected: The selected implementation hook
//    observes the expected name, value and applicable metadata.
// 3. 1800.2-2020 F.2.1.5 (UVM-RADIX-UNFORMAT2-93) gives rule 3 above. Setup:
//    Original live recorder subtypes receive explicit named format parameters
//    through actualrecord_field and record_field_int. Two inputs use128/192bit
//    wide values and32/64bit integral values,with an untouched recorder peer.
//    Expected: The selected format designator reaches both implementation
//    hooks together with the unmodified name,value and width,and exactly one
//    call per requested operation.
// 4. 1800.2-2020 F.2.1.5 (UVM-RADIX-UNFORMAT4-93) gives rule 4 above. Setup:
//    Original live recorder subtypes receive explicit named format parameters
//    through actualrecord_field and record_field_int. Two inputs use128/192bit
//    wide values and32/64bit integral values,with an untouched recorder peer.
//    Expected: The selected format designator reaches both implementation
//    hooks together with the unmodified name,value and width,and exactly one
//    call per requested operation.
// It also supports, as a control, the setup or conditions of UVM-RADIX-BIN-93,
// UVM-RADIX-OCT-93, UVM-RADIX-HEX-93, UVM-RADIX-DEC-93, UVM-RADIX-UNSIGNED-93,
// UVM-RADIX-NORADIX-93, UVM-RADIX-STRING-93, UVM-RADIX-REAL-93,
// UVM-RADIX-REAL-DEC-93, UVM-RADIX-REAL-EXP-93, UVM-RADIX-TIME-93,
// UVM-RADIX-ENUM-93.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original typed field macros and public stack/recording observers. Numeric
// formats are parsed,not matched as a full layout. Unsigned decimal prose
// versus literal %u is qualified;literal controls cannot pass the textual
// original. Raw2/raw4 recording only checks typed metadata/data transport,not
// a binary DB or X/Z rendering. Real notation is selected via typed real macro
// flags. Time representation is compared within the same UVM package
// context;absolute units and rounding remain open. No enum numeric encoding is
// imposed.
module test_radix_record_1_93;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int VARIANT=1;
  localparam int WIDTH93=65;
  localparam int TEXT_WIDTH93=32;
  localparam bit LITERAL93=0;
  localparam string CASE_NAME="record_1";
  `include "record_fixture93.svh"
  initial begin #5000; $fatal(1,"radix-table93 watchdog"); end
endmodule
