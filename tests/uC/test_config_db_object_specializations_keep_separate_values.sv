/*
:name: test_config_db_object_specializations_keep_separate_values
:description: base and derived class configuration specializations have separate typed entries (IEEE 1800.2-2020 Section C.4.2.1)
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.1 C.4.2.2.1 C.4.2.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_config_db_object_specializations_keep_separate_values.expected
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
// The resource type is selected by the config_db type parameter rather
// than the dynamic object type. Two class specializations keep separate values.

module test_config_db_object_specializations_keep_separate_values;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class item extends uvm_object;
    `uvm_object_utils(item)
    int payload = 0;
    function new(string name="item"); super.new(name); endfunction
  endclass

  initial begin
    automatic item general_value = new("general_value");
    automatic item specific_value = new("specific_value");
    uvm_object general_result;
    item specific_result;
    bit general_found;
    bit specific_found;
    uvm_config_db#(uvm_object)::set(null, "env", "packet", general_value);
    uvm_config_db#(item)::set(null, "env", "packet", specific_value);
    general_found = uvm_config_db#(uvm_object)::get(null, "env", "packet", general_result);
    specific_found = uvm_config_db#(item)::get(null, "env", "packet", specific_result);
    $display("UT: general found %0d same %0d", general_found, general_result == general_value);
    $display("UT: specific found %0d same %0d", specific_found, specific_result == specific_value);
    $finish;
  end
endmodule
