/*
:name: test_vreg_field_name_lookup_preserves_handle_and_returns_null_for_missing_name
:description: vreg field name lookup preserves handle and returns null for missing name (IEEE 1800.2-2020 Section 18.9.1.2.13)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.2.13 18.10.2.1 18.10.2.2 18.9.1.1.1 18.9.1.1.2 18.1.2.1 18.1.2.2 18.6.3.1 18.6.3.2 18.1.2.3 18.1.2.6 18.2.3.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_field_name_lookup_preserves_handle_and_returns_null_for_missing_name.expected
*/
// What it checks:
// Virtual-field named lookup preserves found identity and returns null for a
// missing name.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.9.1.2.13 (UVM-VREG-FIELD-NAMED-LOOKUP) gives the rule above.
// Setup: Look up one configured field and one missing name. Expected: The
// found handle is exact and the missing handle is null.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The lookup finds the configured field by its local name and returns null for
// an absent name. No diagnostic severity is prescribed for the miss.

module test_vreg_field_name_lookup_preserves_handle_and_returns_null_for_missing_name;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class model_block extends uvm_reg_block;
    function new(); super.new("blk", UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(); super.new("r", 8, UVM_NO_COVERAGE); endfunction
  endclass

  initial begin
    automatic model_block blk = new();
    automatic uvm_mem mem = new("mem", 64, 8, "RW", UVM_NO_COVERAGE);
    automatic uvm_vreg vr = new("vr", 16);
    automatic uvm_vreg_field low;
    automatic uvm_vreg_field middle;
    automatic uvm_vreg_field high;
    automatic uvm_vreg_field fields[$];
    automatic uvm_reg_map mapping;
    automatic uvm_reg_map maps[$];
    blk.configure();
    mem.configure(blk);
    mapping = blk.create_map("bus", 'h100, 1, UVM_LITTLE_ENDIAN);
    mapping.add_mem(mem, 'h20);
    vr.configure(blk, mem, 3, 2, 0);
    middle = uvm_vreg_field::type_id::create("middle");
    middle.configure(vr, 5, 7);
    blk.lock_model();
    $display("UT: found %0d missing %0d", vr.get_field_by_name("middle") == middle,
             vr.get_field_by_name("missing") == null);
    $finish;
  end
endmodule
