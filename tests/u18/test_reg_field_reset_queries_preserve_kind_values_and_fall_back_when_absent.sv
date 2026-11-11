/*
:name: test_reg_field_reset_queries_preserve_kind_values_and_fall_back_when_absent
:description: reset queries retain kind-specific values and return current state when no value is defined (IEEE 1800.2-2020 Section 18.5.5.6)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.5.6 18.5.5.5 18.5.5.7 18.5.5.17 18.5.5.1 18.5.5.3 18.5.3.1 18.5.3.2 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 18.5.5.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_field_reset_queries_preserve_kind_values_and_fall_back_when_absent.expected
*/
// What it checks:
// 1. Reset queries return the configured kind value or current field value for
//    an absent kind.
// 2. Setting reset metadata retains separate kind values without applying a
//    reset.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.5.5.6 (UVM-FIELD-RESET-VALUE-QUERY-FALLBACK) gives rule 1
//    above. Setup: Predict equal current values, query an absent kind, then
//    define HARD and SOFT metadata. Expected: Absent kind returns 42 and
//    configured kinds return 17/29, independently of live data.
// 2. 1800.2-2020 18.5.5.7 (UVM-FIELD-RESET-METADATA-ASSIGNMENT) gives rule 2
//    above. Setup: Set default HARD and explicit SOFT values after prediction.
//    Expected: Queries return the new reset values while desired and mirror
//    remain 42 and the peer retains 33.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Model-only field metadata and desired/mirrored state. No bus, RTL or DPI
// is accessed, and policy controls do not establish physical side effects.
module test_reg_field_reset_queries_preserve_kind_values_and_fall_back_when_absent;
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
    build_model(0);

    result_value = first_field.predict(8'h42);
    $display("UT: absent has %0d value %0h current %0h", first_field.has_reset("MISSING"),
    first_field.get_reset("MISSING"), first_field.get());
    first_field.set_reset(8'h17); first_field.set_reset(8'h29, "SOFT");
    $display("UT: metadata hard %0h soft %0h peer %0h", first_field.get_reset(),
    first_field.get_reset("SOFT"), peer.get_reset());
    $display("UT: unchanged desired %0h mirror %0h", first_field.get(),
    first_field.get_mirrored_value());
    $finish;
  end

endmodule
