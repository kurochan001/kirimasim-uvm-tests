/*
:name: test_register_element_access_and_hierarchy_symbols_are_typed_without_fixed_encodings
:description: register element access and hierarchy symbols are typed without fixed encodings (IEEE 1800.2-2020 Section 17.2.2.5)
:tags: u17 uvm
:type: simulation
:lrm: 1800.2-2020 17.2.2.5 17.2.2.6 17.2.2.7 1800-2023 6.21 6.19
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_element_access_and_hierarchy_symbols_are_typed_without_fixed_encodings.expected
*/
// What it checks:
// 1. uvm_elem_kind_e makes its documented named alternatives available.
// 2. uvm_access_e makes its documented named alternatives available.
// 3. uvm_hier_e makes its documented named alternatives available.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 17.2.2.5 (UVM-REG-GLOBAL-ELEMENT-SYMBOLS) gives rule 1 above.
//    Setup: Each documented alternative is assigned in turn to a variable of
//    the public enum type. Expected: The assigned enum value identifies the
//    selected symbol by its standard SystemVerilog name query.
// 2. 1800.2-2020 17.2.2.6 (UVM-REG-GLOBAL-ACCESS-SYMBOLS) gives rule 2 above.
//    Setup: Each documented alternative is assigned in turn to a variable of
//    the public enum type. Expected: The assigned enum value identifies the
//    selected symbol by its standard SystemVerilog name query.
// 3. 1800.2-2020 17.2.2.7 (UVM-REG-GLOBAL-HIERARCHY-SYMBOLS) gives rule 3
//    above. Setup: Each documented alternative is assigned in turn to a
//    variable of the public enum type. Expected: The assigned enum value
//    identifies the selected symbol by its standard SystemVerilog name query.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// This checks the named public declarations. Numeric values, enum cardinality
// and downstream access/search behavior are outside this oracle.
module test_register_element_access_and_hierarchy_symbols_are_typed_without_fixed_encodings;
  import uvm_pkg::*;
  initial begin
    uvm_elem_kind_e kind;
    uvm_access_e access_mode;
    uvm_hier_e hierarchy;
    kind = UVM_REG; $display("UT: kind %s", kind.name());
    kind = UVM_FIELD; $display("UT: kind %s", kind.name());
    kind = UVM_MEM; $display("UT: kind %s", kind.name());
    access_mode = UVM_READ; $display("UT: access %s", access_mode.name());
    access_mode = UVM_WRITE; $display("UT: access %s", access_mode.name());
    hierarchy = UVM_NO_HIER; $display("UT: hierarchy %s", hierarchy.name());
    hierarchy = UVM_HIER; $display("UT: hierarchy %s", hierarchy.name());
    $finish;
  end
endmodule
