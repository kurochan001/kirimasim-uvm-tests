/*
:name: test_radix_unsigned_literal_1_93
:description: unsigned literal 1 checks typed radix or table-row effects through original observers
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.1.5 B.2.2 B.2.2.1.1 B.2.2.1.3 B.2.2.1.4 B.2.2.1.5 5.3.6.2 5.3.6.3 16.2.3.8 16.2.3.9 16.2.3.10 16.2.3.11 16.2.3.12 16.2.5.5 16.2.5.6 16.2.5.7 16.2.7.2 16.2.7.3 1800-2023 6.16 6.19 6.21 8.20 8.21 21.2.1.1 21.2.1.2 21.2.1.3 21.2.2 21.3.3 21.3.4.3
:uvm: 2020.3.1
:files: helpers93_numeric/numeric_fixture93.svh
:incdirs: helpers93_numeric
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_radix_unsigned_literal_1_93.expected
*/
// Original typed field macros and public stack/recording observers. Numeric
// formats are parsed,not matched as a full layout. Unsigned decimal prose
// versus literal %u is qualified;literal controls cannot pass the textual
// original. Raw2/raw4 recording only checks typed metadata/data transport,not
// a binary DB or X/Z rendering. Real notation is selected via typed real macro
// flags. Time representation is compared within the same UVM package
// context;absolute units and rounding remain open. No enum numeric encoding is
// imposed.
module test_radix_unsigned_literal_1_93;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int VARIANT=1;
  localparam int WIDTH93=64;
  localparam int TEXT_WIDTH93=32;
  localparam bit LITERAL93=1;
  localparam string CASE_NAME="unsigned_literal_1";
  `include "numeric_fixture93.svh"
  initial begin #5000; $fatal(1,"radix-table93 watchdog"); end
endmodule
