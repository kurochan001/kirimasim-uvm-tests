/*
:name: test_regex_config_db_scope_and_field_119
:description: configuration settings match lookups through regular-expression scopes and field names and the simplified plus (IEEE 1800.2-2020 Section C.4.2.2.1)
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.2.1 C.4.2.2.2 C.2.4.3 F.3.3.1 1800-2023 6.21
:uvm: 2020.3.1
:uvm_dpi: yes
:uvm_cmdline_backend: vpi
:uvm_defines: UVM_HDL_NO_DPI
:dpi_c: @../../tools/cmdline_backend/uvm_cmdline_vpi.cpp
:files: ../../tools/cmdline_backend/uvm_cmdline_regex.cpp ../../tools/cmdline_backend/malloc.h
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_regex_config_db_scope_and_field_119.expected
*/
// What it checks:
// 1. A configuration setting whose instance name is a regular expression or
//    simplified plus applies only to the scopes it describes.
// 2. A configuration setting whose field name is a regular expression applies
//    to the field names it describes.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 C.4.2.2.1 (UVM-REGEX-CONFIG-SCOPE) gives rule 1 above. Setup:
//    Set one value for /^top119\.env\.(left|right)$/ and another for
//    top119.u+, then look them up from matching and nonmatching scopes.
//    Expected: The left, right and u1 lookups find their values; the middle
//    and u lookups find none.
// 2. 1800.2-2020 C.4.2.2.1 (UVM-REGEX-CONFIG-FIELD-NAME) gives rule 2 above.
//    Setup: Set a value for the field /^limit[0-9]$/ in one scope, then look
//    up limit3 and limitx there. Expected: limit3 finds the value and limitx
//    does not.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// One setting uses a regular-expression scope with an alternation, one a
// regular-expression field name with a digit class, and one a simplified scope
// ending in plus. Only the lookups that the expressions describe may find a
// value. The pinned regex DPI and the original command-line VPI bridge are
// enabled; the ordinary UVM_NO_DPI condition cannot evaluate regular
// expressions, so this case runs only in the command-line condition. Only the
// lines that begin with "UT: " are compared.
module test_regex_config_db_scope_and_field_119;
  import uvm_pkg::*;

  initial begin
    automatic int value = 0;
    bit left, right, middle, digit, letter, plus_one, plus_empty;
    uvm_config_db #(int)::set(null, "/^top119\\.env\\.(left|right)$/", "gain", 7);
    value = 0;
    left = uvm_config_db #(int)::get(null, "top119.env.left", "gain", value) && value == 7;
    value = 0;
    right = uvm_config_db #(int)::get(null, "top119.env.right", "gain", value) && value == 7;
    value = 0;
    middle = uvm_config_db #(int)::get(null, "top119.env.middle", "gain", value);
    uvm_config_db #(int)::set(null, "top119.cfg", "/^limit[0-9]$/", 5);
    value = 0;
    digit = uvm_config_db #(int)::get(null, "top119.cfg", "limit3", value) && value == 5;
    value = 0;
    letter = uvm_config_db #(int)::get(null, "top119.cfg", "limitx", value);
    uvm_config_db #(int)::set(null, "top119.u+", "depth", 3);
    value = 0;
    plus_one = uvm_config_db #(int)::get(null, "top119.u1", "depth", value) && value == 3;
    value = 0;
    plus_empty = uvm_config_db #(int)::get(null, "top119.u", "depth", value);
    $display("UT: scope left %0d right %0d middle %0d", left, right, middle);
    $display("UT: field digit %0d letter %0d", digit, letter);
    $display("UT: plus one %0d empty %0d", plus_one, plus_empty);
    $finish;
  end
endmodule
