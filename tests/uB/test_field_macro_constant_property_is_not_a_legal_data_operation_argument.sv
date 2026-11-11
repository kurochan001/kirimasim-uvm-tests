/*
:name: test_field_macro_constant_property_is_not_a_legal_data_operation_argument
:description: A field macro argument cannot be a const class property
:tags: uB uvm
:type: elaboration
:lrm: 1800.2-2020 B.2.2 B.2.2.1.1 1800-2023 6.21 8.20 8.21 7.4 7.8 7.9 8.19
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: field macro ARG must be a nonconstant variable, not a const property
:expected_stderr_regex: (?i)^(?=.*test_field_macro_constant_property_is_not_a_legal_data_operation_argument\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:const|constant|read.only)\b).*error
*/
// What it checks:
// A field macro ARG must not be a const property.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.2.2 (UVM-FIELD-MACRO-AUDIT-CONSTANT-ARGUMENT) gives the rule
// above. Setup: Declare one const integral class property and pass it to the
// COPY field macro in an otherwise original utils-registered class. Expected:
// Compilation rejects this fixture with a diagnostic identifying its
// const/constant restriction; no runtime binary is executed.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_field_macro_constant_property_is_not_a_legal_data_operation_argument;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class illegal_packet extends uvm_object;
    const int immutable=17;
    `uvm_object_utils_begin(illegal_packet)
      `uvm_field_int(immutable,UVM_COPY)
    `uvm_object_utils_end
    function new(string name="illegal65"); super.new(name); endfunction
  endclass
  initial begin illegal_packet value; value=new(); end
endmodule
