/*
:name: test_table_rows_1_93
:description: table 1 checks typed radix or table-row effects through original observers
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.10 16.2.3.1 16.2.3.4 16.2.4.1 16.2.5.1 16.2.5.2 16.2.5.3 5.3.6.2 5.3.6.3 1800-2023 6.16 6.19 6.21 8.20 8.21 21.2.1.1 21.2.1.2 21.2.1.3 21.2.2 21.3.3 21.3.4.3
:uvm: 2020.3.1
:files: helpers93_table/table_fixture93.svh
:incdirs: helpers93_table
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_table_rows_1_93.expected
*/
// Qualified short-cell reading of tabular output: four caller-supplied cell
// values remain row-associated. No fixed header,field order,column
// width,punctuation,indentation or universal multi-line/wrapping layout is
// asserted.
module test_table_rows_1_93;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int VARIANT=1;
  localparam int WIDTH93=65;
  localparam int TEXT_WIDTH93=32;
  localparam bit LITERAL93=0;
  localparam string CASE_NAME="table_1";
  `include "table_fixture93.svh"
  initial begin #5000; $fatal(1,"radix-table93 watchdog"); end
endmodule
