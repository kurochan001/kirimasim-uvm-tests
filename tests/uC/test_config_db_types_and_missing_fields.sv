/*
:name: test_config_db_types_and_missing_fields
:description: configuration lookups distinguish types and missing fields (IEEE 1800.2-2020 Section C.4.2.2.1)
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.2.1 C.4.2.2.2 C.4.2.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_config_db_types_and_missing_fields.expected
*/
// What it checks:
// Configuration lookup retrieves the setting for its API specialization and
// field.
//
// How the expected output follows from the standard:
// 1800.2-2020 C.4.2.2.2 (UVM-CONFIG-TYPED-GET) gives the rule above. Setup:
// Use the same field name under integer/string or base/derived class
// specializations. Expected: Each typed API retrieves its own value; an
// unmatched type lookup fails.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Configuration values of different types may share a field name.
// A lookup with an unmatched type or field fails; exists checks presence.

module test_config_db_types_and_missing_fields;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

initial begin
  automatic int number = -1;
  automatic string text = "untouched";
  bit found;
  uvm_config_db#(int)::set(null, "scope", "value", 19);
  uvm_config_db#(string)::set(null, "scope", "value", "ready");
  found = uvm_config_db#(int)::get(null, "scope", "value", number);
  $display("UT: integer %0d value %0d", found, number);
  found = uvm_config_db#(string)::get(null, "scope", "value", text);
  $display("UT: string %0d value %s", found, text);
  $display("UT: exists %0d missing %0d",
           uvm_config_db#(int)::exists(null, "scope", "value"),
           uvm_config_db#(int)::exists(null, "scope", "absent"));
  found = uvm_config_db#(bit)::exists(null, "scope", "value");
  $display("UT: other type %0d", found);
  $finish;
end
endmodule
