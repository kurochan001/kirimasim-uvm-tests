/*
:name: test_radix_time_enum_1_93
:description: time enum 1 checks typed radix or table-row effects through original observers
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.1.5 B.2.2 B.2.2.1.1 B.2.2.1.3 B.2.2.1.4 B.2.2.1.5 5.3.6.2 5.3.6.3 16.2.3.8 16.2.3.9 16.2.3.10 16.2.3.11 16.2.3.12 16.2.5.5 16.2.5.6 16.2.5.7 16.2.7.2 16.2.7.3 1800-2023 6.16 6.19 6.21 8.20 8.21 21.2.1.1 21.2.1.2 21.2.1.3 21.2.2 21.3.3 21.3.4.3
:uvm: 2020.3.1
:files: helpers93_time_enum/time_enum_fixture93.svh
:incdirs: helpers93_time_enum
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_radix_time_enum_1_93.expected
*/
// What it checks:
// 1. UVM_TIME selects the same-package time representation of the selected
//    typed macro field.
// 2. UVM_ENUM selects the name representation of the selected typed
//    enumeration property.
// 3. One named radix flag combined with UVM_PRINT governs the selected
//    compatible scalar property operation.
//
// Variant: Input 0 uses 32-bit values and 16-character text; input 1 uses
// 65-bit values, 32-character text and other values (time 31 and BETA93
// instead of 19 and ALPHA93).
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 F.2.1.5 (UVM-RADIX-TIME-93) gives rule 1 above. Setup:
//    Original scalar field macros use one named radix with UVM_PRINT and
//    mutable properties of the appropriate type. A derived printer observes
//    public element values through push_element and get_top_element,after
//    explicitly setting empty radix prefixes. Two inputs choose different
//    values,widths or format histories;no complete emitted layout is fixed.
//    Expected: The macro value equals the publicprint_time control for the
//    same input and includes the explicit globaltimeformat suffix.
// 2. 1800.2-2020 F.2.1.5 (UVM-RADIX-ENUM-93) gives rule 2 above. Setup:
//    Original scalar field macros use one named radix with UVM_PRINT and
//    mutable properties of the appropriate type. A derived printer observes
//    public element values through push_element and get_top_element,after
//    explicitly setting empty radix prefixes. Two inputs choose different
//    values,widths or format histories;no complete emitted layout is fixed.
//    Expected: Opposite declared enum values print their actual names rather
//    than a fixed numeric encoding.
// 3. 1800.2-2020 B.2.2 (UVM-SCALAR-MACRO-TYPED-RADIX-SELECTION-93) gives rule
//    3 above. Setup: Original scalar field macros use one named radix with
//    UVM_PRINT and mutable properties of the appropriate type. A derived
//    printer observes public element values through push_element and
//    get_top_element,after explicitly setting empty radix prefixes. Two inputs
//    choose different values,widths or format histories;no complete emitted
//    layout is fixed. Expected: The selected integer,string,real,time and
//    enumeration properties produce the expected named-format
//    observations;omission is equivalent toNORADIX for the selected defaults.
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
module test_radix_time_enum_1_93;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int VARIANT=1;
  localparam int WIDTH93=65;
  localparam int TEXT_WIDTH93=32;
  localparam bit LITERAL93=0;
  localparam string CASE_NAME="time_enum_1";
  `include "time_enum_fixture93.svh"
  initial begin #5000; $fatal(1,"radix-table93 watchdog"); end
endmodule
