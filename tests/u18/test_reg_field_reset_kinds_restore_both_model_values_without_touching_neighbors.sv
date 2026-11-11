/*
:name: test_reg_field_reset_kinds_restore_both_model_values_without_touching_neighbors
:description: field resets restore both desired and mirror for one kind and ignore unknown kinds (IEEE 1800.2-2020 Section 18.5.5.4)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.5.4 18.5.5.7 18.5.5.1 18.5.5.2 18.5.5.3 18.5.5.17 18.5.3.1 18.5.3.2 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_field_reset_kinds_restore_both_model_values_without_touching_neighbors.expected
*/
// What it checks:
// 1. Reset with an undefined kind leaves desired and mirrored field values
//    unchanged.
// 2. A configured field reset restores both desired and mirrored values for
//    its selected kind.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.5.5.4 (UVM-FIELD-UNKNOWN-RESET-PRESERVES-STATE) gives rule
//    1 above. Setup: Use an unknown kind with divergent values or delete HARD
//    before its default reset. Expected: Unknown reset preserves desired
//    73/mirror 42; deleted HARD preserves equal values 42.
// 2. 1800.2-2020 18.5.5.4 (UVM-FIELD-KIND-RESET-RESTORES-STATE) gives rule 2
//    above. Setup: Apply SOFT then default HARD with independent neighboring
//    fields. Expected: Both values become 29 for SOFT and 11 for HARD, without
//    resetting neighbors or peers.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Model-only field metadata and desired/mirrored state. No bus, RTL or DPI
// is accessed, and policy controls do not establish physical side effects.
module test_reg_field_reset_kinds_restore_both_model_values_without_touching_neighbors;
  import uvm_pkg::*;

  class model_block extends uvm_reg_block;
    function new(string name="blk"); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(string name="r", int unsigned width=16);
      super.new(name, width, UVM_NO_COVERAGE);
    endfunction
  endclass
  model_block blk;
  model_reg first_reg, second_reg;
  uvm_reg_field first_field, neighbor, peer;
  function automatic void build_model(bit first_has_reset=1);
    blk = new("blk"); blk.configure();
    first_reg = new("first"); first_reg.configure(blk);
    second_reg = new("second"); second_reg.configure(blk);
    first_field = new("first_field"); neighbor = new("neighbor"); peer = new("peer");
    first_field.configure(first_reg, 8, 0, "RW", 0, 8'h11, first_has_reset, 0, 1);
    neighbor.configure(first_reg, 8, 8, "RW", 0, 8'h22, 1, 0, 1);
    peer.configure(second_reg, 8, 0, "RW", 0, 8'h33, 1, 0, 1);
    first_field.reset(); neighbor.reset(); peer.reset();
  endfunction

  initial begin
    bit result_value;
    build_model();

    first_field.set_reset(8'h29, "SOFT"); result_value = first_field.predict(8'h42);
    first_field.set(8'h73); first_field.reset("UNKNOWN");
    $display("UT: unknown desired %0h mirror %0h", first_field.get(),
    first_field.get_mirrored_value());
    first_field.reset("SOFT");
    $display("UT: soft desired %0h mirror %0h neighbor %0h", first_field.get(),
    first_field.get_mirrored_value(), neighbor.get_mirrored_value());
    first_field.set(8'h55); first_field.reset();
    $display("UT: hard desired %0h mirror %0h peer %0h", first_field.get(),
    first_field.get_mirrored_value(), peer.get_mirrored_value());
    $finish;
  end

endmodule
