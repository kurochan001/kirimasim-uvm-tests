/*
:name: test_register_has_reset_aggregates_any_field_and_deletes_only_the_selected_reset_kind
:description: register has reset aggregates any field and deletes only the selected reset kind
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.4.7 18.4.4.8 18.4.4.6 18.5.5.5 18.4.4.5 18.4.2.2 18.5.3.2 18.1.2.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_has_reset_aggregates_any_field_and_deletes_only_the_selected_reset_kind.expected
*/
// What it checks:
// 1. Register has_reset returns true when at least one selected field has the
//    requested reset.
// 2. Register has_reset returns false for the selected kind absent from all
//    its fields.
// 3. Omitted has_reset kind queries HARD without deleting that selected
//    definition.
// 4. Explicit delete removes the selected kind from both fields and reports
//    prior presence while other reset kinds and the peer remain.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.4.4.7 (UVM-REGISTER-CONTRACT-RESET-HAS-ANY) gives rule 1
//    above. Setup: Two original full-width 16-bit RW register models have two
//    eight-bit fields each. Selected HARD/SOFT definitions, model predictions
//    and desired values are set explicitly; the any-field case deliberately
//    omits one HARD field reset. No physical access is performed by these
//    metadata fixtures. Expected: Register has_reset returns true when at
//    least one selected field has the requested reset.
// 2. 1800.2-2020 18.4.4.7 (UVM-REGISTER-CONTRACT-RESET-HAS-ABSENT) gives rule
//    2 above. Setup: Two original full-width 16-bit RW register models have
//    two eight-bit fields each. Selected HARD/SOFT definitions, model
//    predictions and desired values are set explicitly; the any-field case
//    deliberately omits one HARD field reset. No physical access is performed
//    by these metadata fixtures. Expected: Register has_reset returns false
//    for the selected kind absent from all its fields.
// 3. 1800.2-2020 18.4.4.7 (UVM-REGISTER-CONTRACT-RESET-HAS-DEFAULTS) gives
//    rule 3 above. Setup: Two original full-width 16-bit RW register models
//    have two eight-bit fields each. Selected HARD/SOFT definitions, model
//    predictions and desired values are set explicitly; the any-field case
//    deliberately omits one HARD field reset. No physical access is performed
//    by these metadata fixtures. Expected: Omitted has_reset kind queries HARD
//    without deleting that selected definition.
// 4. 1800.2-2020 18.4.4.7 (UVM-REGISTER-CONTRACT-RESET-HAS-DELETE) gives rule
//    4 above. Setup: Two original full-width 16-bit RW register models have
//    two eight-bit fields each. Selected HARD/SOFT definitions, model
//    predictions and desired values are set explicitly; the any-field case
//    deliberately omits one HARD field reset. No physical access is performed
//    by these metadata fixtures. Expected: Explicit delete removes the
//    selected kind from both fields and reports prior presence while other
//    reset kinds and the peer remain.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_register_has_reset_aggregates_any_field_and_deletes_only_the_selected_reset_kind;
  import uvm_pkg::*;
  class block_type extends uvm_reg_block;
    function new(string name);super.new(name,UVM_NO_COVERAGE);endfunction
  endclass
  class register_type extends uvm_reg;
    function new(string name,int unsigned width=16,int coverage_models=UVM_NO_COVERAGE);
      super.new(name,width,coverage_models);
    endfunction
  endclass

  block_type owner;
  register_type chosen,peer;
  uvm_reg_field low_bits,high_bits,peer_low,peer_high;
  function automatic void build_model(bit high_reset=1);
    owner=new("owner52");owner.configure();chosen=new("chosen52");peer=new("peer52");
    chosen.configure(owner);peer.configure(owner);
    low_bits=uvm_reg_field::type_id::create("low52");
    high_bits=uvm_reg_field::type_id::create("high52");
    peer_low=uvm_reg_field::type_id::create("low52");
    peer_high=uvm_reg_field::type_id::create("high52");
    low_bits.configure(chosen,8,0,"RW",0,'h11,1,0,0);
    high_bits.configure(chosen,8,8,"RW",0,'hAA,high_reset,0,0);
    peer_low.configure(peer,8,0,"RW",0,'h77,1,0,0);
    peer_high.configure(peer,8,8,"RW",0,'h77,1,0,0);
    chosen.reset();peer.reset();
  endfunction

  initial begin
    bit deleted;
    build_model(0);
    $display("UT: register_reset_presence any_hard %0d one_missing %0d absent_soft %0d",
      chosen.has_reset(),!high_bits.has_reset(),!chosen.has_reset("SOFT"));
    chosen.set_reset('hBEEF,"SOFT");deleted=chosen.has_reset("SOFT",1);
    $display("UT: register_reset_presence delete_prior %0d low_absent %0d high_absent %0d hard %0d",
      deleted,!low_bits.has_reset("SOFT"),!high_bits.has_reset("SOFT"),chosen.has_reset());
    $display("UT: register_reset_presence query_keeps_hard %0d peer_kept %0d peer_value %0h",
      chosen.has_reset(),peer.has_reset(),peer.get_reset());
    $finish;
  end
endmodule
