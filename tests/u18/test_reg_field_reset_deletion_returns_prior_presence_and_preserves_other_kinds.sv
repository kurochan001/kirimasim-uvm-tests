/*
:name: test_reg_field_reset_deletion_returns_prior_presence_and_preserves_other_kinds
:description: deleting one reset kind reports prior presence without changing live or peer state (IEEE 1800.2-2020 Section 18.5.5.5)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.5.5 18.5.5.6 18.5.5.7 18.5.5.17 18.5.5.1 18.5.5.3 18.5.3.1 18.5.3.2 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 18.5.5.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_field_reset_deletion_returns_prior_presence_and_preserves_other_kinds.expected
*/
// Model-only field metadata and desired/mirrored state. No bus, RTL or DPI
// is accessed, and policy controls do not establish physical side effects.
module test_reg_field_reset_deletion_returns_prior_presence_and_preserves_other_kinds;
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
    bit deleted;
    build_model();

    first_field.set_reset(8'h29, "SOFT"); result_value = first_field.predict(8'h42);
    deleted = first_field.has_reset("HARD", 1);
    $display("UT: deleted prior %0d hard %0d soft %0d peer %0d", deleted, first_field.has_reset(),
    first_field.has_reset("SOFT"), peer.has_reset());
    first_field.reset();
    $display("UT: removed_kind desired %0h mirror %0h soft_value %0h", first_field.get(),
    first_field.get_mirrored_value(), first_field.get_reset("SOFT"));
    $display("UT: absent_delete %0d peer_value %0h", first_field.has_reset("HARD", 1),
    peer.get_reset());
    $finish;
  end

endmodule
