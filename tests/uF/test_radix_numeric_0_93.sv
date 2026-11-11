/*
:name: test_radix_numeric_0_93
:description: numeric 0 checks typed radix or table-row effects through original observers
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.1.5 B.2.2 B.2.2.1.1 B.2.2.1.3 B.2.2.1.4 B.2.2.1.5 5.3.6.2 5.3.6.3 16.2.3.8 16.2.3.9 16.2.3.10 16.2.3.11 16.2.3.12 16.2.5.5 16.2.5.6 16.2.5.7 16.2.7.2 16.2.7.3 1800-2023 6.16 6.19 6.21 8.20 8.21 21.2.1.1 21.2.1.2 21.2.1.3 21.2.2 21.3.3 21.3.4.3
:uvm: 2020.3.1
:files: helpers93_numeric/numeric_fixture93.svh
:incdirs: helpers93_numeric
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_radix_numeric_0_93.expected
*/
// What it checks:
// 1. UVM_BIN selects binary integral formatting.
// 2. UVM_OCT selects octal integral formatting.
// 3. UVM_HEX selects hexadecimal integral formatting.
// 4. UVM_DEC selects decimal integral formatting under the selected
//    unsigned-property reading.
// 5. UVM_UNSIGNED selects unsigned-decimal integral formatting under the
//    textual reading.
// 6. UVM_NORADIX selects the selected printer default when radix information
//    is absent.
// 7. One named radix flag combined with UVM_PRINT governs the selected
//    compatible scalar property operation.
//
// Variant: Input 0 uses 32-bit values and 16-character text; input 1 uses
// 65-bit values, 32-character text and other values, from a separate
// wide-value helper, with binary instead of hex as the printer's default
// radix.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 F.2.1.5 (UVM-RADIX-BIN-93) gives rule 1 above. Setup:
//    Original scalar field macros use one named radix with UVM_PRINT and
//    mutable properties of the appropriate type. A derived printer observes
//    public element values through push_element and get_top_element,after
//    explicitly setting empty radix prefixes. Two inputs choose different
//    values,widths or format histories;no complete emitted layout is fixed.
//    Expected: The selected binary text parses to the original unsigned value.
// 2. 1800.2-2020 F.2.1.5 (UVM-RADIX-OCT-93) gives rule 2 above. Setup:
//    Original scalar field macros use one named radix with UVM_PRINT and
//    mutable properties of the appropriate type. A derived printer observes
//    public element values through push_element and get_top_element,after
//    explicitly setting empty radix prefixes. Two inputs choose different
//    values,widths or format histories;no complete emitted layout is fixed.
//    Expected: The selected octal text parses to the original unsigned value.
// 3. 1800.2-2020 F.2.1.5 (UVM-RADIX-HEX-93) gives rule 3 above. Setup:
//    Original scalar field macros use one named radix with UVM_PRINT and
//    mutable properties of the appropriate type. A derived printer observes
//    public element values through push_element and get_top_element,after
//    explicitly setting empty radix prefixes. Two inputs choose different
//    values,widths or format histories;no complete emitted layout is fixed.
//    Expected: The selected hexadecimal text parses to the original unsigned
//    value without fixing case or padding.
// 4. 1800.2-2020 F.2.1.5 (UVM-RADIX-DEC-93) gives rule 4 above. Setup:
//    Original scalar field macros use one named radix with UVM_PRINT and
//    mutable properties of the appropriate type. A derived printer observes
//    public element values through push_element and get_top_element,after
//    explicitly setting empty radix prefixes. Two inputs choose different
//    values,widths or format histories;no complete emitted layout is fixed.
//    Expected: The decimal text parses to the original
//    declared-unsigned32/65bit value.
// 5. 1800.2-2020 F.2.1.5 (UVM-RADIX-UNSIGNED-93) gives rule 5 above. Setup:
//    Original scalar field macros use one named radix with UVM_PRINT and
//    mutable properties of the appropriate type. A derived printer observes
//    public element values through push_element and get_top_element,after
//    explicitly setting empty radix prefixes. Two inputs choose different
//    values,widths or format histories;no complete emitted layout is fixed.
//    Expected: The decimal text preserves the selected high-bit unsigned
//    value.
// 6. 1800.2-2020 F.2.1.5 (UVM-RADIX-NORADIX-93) gives rule 6 above. Setup:
//    Original scalar field macros use one named radix with UVM_PRINT and
//    mutable properties of the appropriate type. A derived printer observes
//    public element values through push_element and get_top_element,after
//    explicitly setting empty radix prefixes. Two inputs choose different
//    values,widths or format histories;no complete emitted layout is fixed.
//    Expected: Explicit NORADIX and omission use the selectedHEX/BIN default
//    and leave the untouched peer atHEX.
// 7. 1800.2-2020 B.2.2 (UVM-SCALAR-MACRO-TYPED-RADIX-SELECTION-93) gives rule
//    7 above. Setup: Original scalar field macros use one named radix with
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
module test_radix_numeric_0_93;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int VARIANT=0;
  localparam int WIDTH93=32;
  localparam int TEXT_WIDTH93=16;
  localparam bit LITERAL93=0;
  localparam string CASE_NAME="numeric_0";
  `include "numeric_fixture93.svh"
  initial begin #5000; $fatal(1,"radix-table93 watchdog"); end
endmodule
