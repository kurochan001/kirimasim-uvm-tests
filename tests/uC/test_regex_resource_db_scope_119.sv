/*
:name: test_regex_resource_db_scope_119
:description: resource scopes match lookups through a regular expression and the simplified plus (IEEE 1800.2-2020 Section C.2.4.3)
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.4.3 C.3.2.3.1 C.3.2.3.6 F.3.3.1 1800-2023 6.21
:uvm: 2020.3.1
:uvm_dpi: yes
:uvm_cmdline_backend: vpi
:uvm_cmdline_oracle: verilator@5.052
:uvm_defines: UVM_HDL_NO_DPI
:dpi_c: @../../tools/cmdline_backend/uvm_cmdline_vpi.cpp
:files: ../../tools/cmdline_backend/uvm_cmdline_regex.cpp ../../tools/cmdline_backend/malloc.h
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_regex_resource_db_scope_119.expected
*/
// What it checks:
// A resource whose scope is a regular expression or simplified plus is visible
// only from the scopes it describes.
//
// How the expected output follows from the standard:
// 1800.2-2020 C.2.4.3 (UVM-REGEX-RESOURCE-SCOPE) gives the rule above. Setup:
// Set one resource for /^top119\.(a|b)$/ and another for top119.slot+, then
// read both by name from matching and nonmatching scopes. Expected: Reads from
// a, b and slot2 find their values; reads from c and slot find none.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// One resource has a regular-expression scope with an alternation and another a
// simplified scope ending in plus. Reads by name must find each resource only
// from the scopes that its expression describes. The pinned regex DPI and the
// original command-line VPI bridge are enabled; the ordinary UVM_NO_DPI
// condition cannot evaluate regular expressions, so this case runs only in the
// command-line condition. Only the lines that begin with "UT: " are compared.
module test_regex_resource_db_scope_119;
  import uvm_pkg::*;

  initial begin
    automatic int value = 0;
    bit a, b, c, plus_one, plus_empty;
    uvm_resource_db #(int)::set("/^top119\\.(a|b)$/", "value119", 11);
    value = 0;
    a = uvm_resource_db #(int)::read_by_name("top119.a", "value119", value) && value == 11;
    value = 0;
    b = uvm_resource_db #(int)::read_by_name("top119.b", "value119", value) && value == 11;
    value = 0;
    c = uvm_resource_db #(int)::read_by_name("top119.c", "value119", value);
    uvm_resource_db #(int)::set("top119.slot+", "depth119", 4);
    value = 0;
    plus_one = uvm_resource_db #(int)::read_by_name("top119.slot2", "depth119", value) &&
             value == 4;
    value = 0;
    plus_empty = uvm_resource_db #(int)::read_by_name("top119.slot", "depth119", value);
    $display("UT: regex a %0d b %0d c %0d", a, b, c);
    $display("UT: plus one %0d empty %0d", plus_one, plus_empty);
    $finish;
  end
endmodule
