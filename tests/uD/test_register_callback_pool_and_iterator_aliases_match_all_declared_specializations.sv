/*
:name: test_register_callback_pool_and_iterator_aliases_match_all_declared_specializations
:description: register callback pool and iterator aliases match all declared specializations
:tags: uD uvm
:type: simulation
:lrm: 1800.2-2020 D.4.5 D.4.5.1 D.4.5.2 D.4.5.3 D.4.5.4 D.4.5.5 D.4.5.6 D.4.5.7 D.4.5.8 D.4.5.9 D.4.5.10 D.4.5.11 D.4.5.12 10.7.2.1 D.1.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_callback_pool_and_iterator_aliases_match_all_declared_specializations.expected
*/
// What it checks:
// 1. The declared uvm_reg_cb alias retains its exact object/callback
//    specialization.
// 2. The declared uvm_reg_cb_iter alias retains its exact object/callback
//    specialization.
// 3. The declared uvm_reg_bd_cb alias retains its exact object/callback
//    specialization.
// 4. The declared uvm_reg_bd_cb_iter alias retains its exact object/callback
//    specialization.
// 5. The declared uvm_mem_cb alias retains its exact object/callback
//    specialization.
// 6. The declared uvm_mem_cb_iter alias retains its exact object/callback
//    specialization.
// 7. The declared uvm_reg_field_cb alias retains its exact object/callback
//    specialization.
// 8. The declared uvm_reg_field_cb_iter alias retains its exact
//    object/callback specialization.
// 9. The declared uvm_vreg_cb alias retains its exact object/callback
//    specialization.
// 10. The declared uvm_vreg_cb_iter alias retains its exact object/callback
//     specialization.
// 11. The declared uvm_vreg_field_cb alias retains its exact object/callback
//     specialization.
// 12. The declared uvm_vreg_field_cb_iter alias retains its exact
//     object/callback specialization.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 D.4.5.1 (UVM-RECORDING-AUDIT-ALIAS-UVM-REG-CB) gives rule 1
//    above. Setup: Use the linked original fixtures, selected public
//    arguments, explicit declared types and exact expected observations. The
//    recording backend is original in-memory setup, not an
//    implementation-derived oracle. Expected: The declared uvm_reg_cb alias
//    retains its exact object/callback specialization.
// 2. 1800.2-2020 D.4.5.2 (UVM-RECORDING-AUDIT-ALIAS-UVM-REG-CB-ITER) gives
//    rule 2 above. Setup: Use the linked original fixtures, selected public
//    arguments, explicit declared types and exact expected observations. The
//    recording backend is original in-memory setup, not an
//    implementation-derived oracle. Expected: The declared uvm_reg_cb_iter
//    alias retains its exact object/callback specialization.
// 3. 1800.2-2020 D.4.5.3 (UVM-RECORDING-AUDIT-ALIAS-UVM-REG-BD-CB) gives rule
//    3 above. Setup: Use the linked original fixtures, selected public
//    arguments, explicit declared types and exact expected observations. The
//    recording backend is original in-memory setup, not an
//    implementation-derived oracle. Expected: The declared uvm_reg_bd_cb alias
//    retains its exact object/callback specialization.
// 4. 1800.2-2020 D.4.5.4 (UVM-RECORDING-AUDIT-ALIAS-UVM-REG-BD-CB-ITER) gives
//    rule 4 above. Setup: Use the linked original fixtures, selected public
//    arguments, explicit declared types and exact expected observations. The
//    recording backend is original in-memory setup, not an
//    implementation-derived oracle. Expected: The declared uvm_reg_bd_cb_iter
//    alias retains its exact object/callback specialization.
// 5. 1800.2-2020 D.4.5.5 (UVM-RECORDING-AUDIT-ALIAS-UVM-MEM-CB) gives rule 5
//    above. Setup: Use the linked original fixtures, selected public
//    arguments, explicit declared types and exact expected observations. The
//    recording backend is original in-memory setup, not an
//    implementation-derived oracle. Expected: The declared uvm_mem_cb alias
//    retains its exact object/callback specialization.
// 6. 1800.2-2020 D.4.5.6 (UVM-RECORDING-AUDIT-ALIAS-UVM-MEM-CB-ITER) gives
//    rule 6 above. Setup: Use the linked original fixtures, selected public
//    arguments, explicit declared types and exact expected observations. The
//    recording backend is original in-memory setup, not an
//    implementation-derived oracle. Expected: The declared uvm_mem_cb_iter
//    alias retains its exact object/callback specialization.
// 7. 1800.2-2020 D.4.5.7 (UVM-RECORDING-AUDIT-ALIAS-UVM-REG-FIELD-CB) gives
//    rule 7 above. Setup: Use the linked original fixtures, selected public
//    arguments, explicit declared types and exact expected observations. The
//    recording backend is original in-memory setup, not an
//    implementation-derived oracle. Expected: The declared uvm_reg_field_cb
//    alias retains its exact object/callback specialization.
// 8. 1800.2-2020 D.4.5.8 (UVM-RECORDING-AUDIT-ALIAS-UVM-REG-FIELD-CB-ITER)
//    gives rule 8 above. Setup: Use the linked original fixtures, selected
//    public arguments, explicit declared types and exact expected
//    observations. The recording backend is original in-memory setup, not an
//    implementation-derived oracle. Expected: The declared
//    uvm_reg_field_cb_iter alias retains its exact object/callback
//    specialization.
// 9. 1800.2-2020 D.4.5.9 (UVM-RECORDING-AUDIT-ALIAS-UVM-VREG-CB) gives rule 9
//    above. Setup: Use the linked original fixtures, selected public
//    arguments, explicit declared types and exact expected observations. The
//    recording backend is original in-memory setup, not an
//    implementation-derived oracle. Expected: The declared uvm_vreg_cb alias
//    retains its exact object/callback specialization.
// 10. 1800.2-2020 D.4.5.10 (UVM-RECORDING-AUDIT-ALIAS-UVM-VREG-CB-ITER) gives
//     rule 10 above. Setup: Use the linked original fixtures, selected public
//     arguments, explicit declared types and exact expected observations. The
//     recording backend is original in-memory setup, not an
//     implementation-derived oracle. Expected: The declared uvm_vreg_cb_iter
//     alias retains its exact object/callback specialization.
// 11. 1800.2-2020 D.4.5.11 (UVM-RECORDING-AUDIT-ALIAS-UVM-VREG-FIELD-CB) gives
//     rule 11 above. Setup: Use the linked original fixtures, selected public
//     arguments, explicit declared types and exact expected observations. The
//     recording backend is original in-memory setup, not an
//     implementation-derived oracle. Expected: The declared uvm_vreg_field_cb
//     alias retains its exact object/callback specialization.
// 12. 1800.2-2020 D.4.5.12 (UVM-RECORDING-AUDIT-ALIAS-UVM-VREG-FIELD-CB-ITER)
//     gives rule 12 above. Setup: Use the linked original fixtures, selected
//     public arguments, explicit declared types and exact expected
//     observations. The recording backend is original in-memory setup, not an
//     implementation-derived oracle. Expected: The declared
//     uvm_vreg_field_cb_iter alias retains its exact object/callback
//     specialization.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_register_callback_pool_and_iterator_aliases_match_all_declared_specializations;
  import uvm_pkg::*;
  // The called generic function checks both implicit class conversions.
  // Null equality is a completion marker, not a callback-behavior oracle.
  class alias_probe #(type EXACT=uvm_object,type ALIAS=uvm_object);
    static function EXACT through_alias(ALIAS value);
      EXACT exact_view;
      ALIAS back_view;
      exact_view=value; back_view=exact_view;
      return back_view;
    endfunction
  endclass
  initial begin
    automatic uvm_reg_cb alias_0=null;
    automatic uvm_callbacks#(uvm_reg,uvm_reg_cbs) exact_0=
      alias_probe#(uvm_callbacks#(uvm_reg,uvm_reg_cbs),
                   uvm_reg_cb)::through_alias(alias_0);
    automatic uvm_reg_cb_iter alias_1=null;
    automatic uvm_callback_iter#(uvm_reg,uvm_reg_cbs) exact_1=
      alias_probe#(uvm_callback_iter#(uvm_reg,uvm_reg_cbs),
                   uvm_reg_cb_iter)::through_alias(alias_1);
    automatic uvm_reg_bd_cb alias_2=null;
    automatic uvm_callbacks#(uvm_reg_backdoor,uvm_reg_cbs) exact_2=
      alias_probe#(uvm_callbacks#(uvm_reg_backdoor,uvm_reg_cbs),
                   uvm_reg_bd_cb)::through_alias(alias_2);
    automatic uvm_reg_bd_cb_iter alias_3=null;
    automatic uvm_callback_iter#(uvm_reg_backdoor,uvm_reg_cbs) exact_3=
      alias_probe#(uvm_callback_iter#(uvm_reg_backdoor,uvm_reg_cbs),
                   uvm_reg_bd_cb_iter)::through_alias(alias_3);
    automatic uvm_mem_cb alias_4=null;
    automatic uvm_callbacks#(uvm_mem,uvm_reg_cbs) exact_4=
      alias_probe#(uvm_callbacks#(uvm_mem,uvm_reg_cbs),
                   uvm_mem_cb)::through_alias(alias_4);
    automatic uvm_mem_cb_iter alias_5=null;
    automatic uvm_callback_iter#(uvm_mem,uvm_reg_cbs) exact_5=
      alias_probe#(uvm_callback_iter#(uvm_mem,uvm_reg_cbs),
                   uvm_mem_cb_iter)::through_alias(alias_5);
    automatic uvm_reg_field_cb alias_6=null;
    automatic uvm_callbacks#(uvm_reg_field,uvm_reg_cbs) exact_6=
      alias_probe#(uvm_callbacks#(uvm_reg_field,uvm_reg_cbs),
                   uvm_reg_field_cb)::through_alias(alias_6);
    automatic uvm_reg_field_cb_iter alias_7=null;
    automatic uvm_callback_iter#(uvm_reg_field,uvm_reg_cbs) exact_7=
      alias_probe#(uvm_callback_iter#(uvm_reg_field,uvm_reg_cbs),
                   uvm_reg_field_cb_iter)::through_alias(alias_7);
    automatic uvm_vreg_cb alias_8=null;
    automatic uvm_callbacks#(uvm_vreg,uvm_vreg_cbs) exact_8=
      alias_probe#(uvm_callbacks#(uvm_vreg,uvm_vreg_cbs),
                   uvm_vreg_cb)::through_alias(alias_8);
    automatic uvm_vreg_cb_iter alias_9=null;
    automatic uvm_callback_iter#(uvm_vreg,uvm_vreg_cbs) exact_9=
      alias_probe#(uvm_callback_iter#(uvm_vreg,uvm_vreg_cbs),
                   uvm_vreg_cb_iter)::through_alias(alias_9);
    automatic uvm_vreg_field_cb alias_10=null;
    automatic uvm_callbacks#(uvm_vreg_field,uvm_vreg_field_cbs) exact_10=
      alias_probe#(uvm_callbacks#(uvm_vreg_field,uvm_vreg_field_cbs),
                   uvm_vreg_field_cb)::through_alias(alias_10);
    automatic uvm_vreg_field_cb_iter alias_11=null;
    automatic uvm_callback_iter#(uvm_vreg_field,uvm_vreg_field_cbs) exact_11=
      alias_probe#(uvm_callback_iter#(uvm_vreg_field,uvm_vreg_field_cbs),
                   uvm_vreg_field_cb_iter)::through_alias(alias_11);
    $display("UT: declared_callback_alias uvm_reg_cb compatible %0d",exact_0==alias_0);
    $display("UT: declared_callback_alias uvm_reg_cb_iter compatible %0d",exact_1==alias_1);
    $display("UT: declared_callback_alias uvm_reg_bd_cb compatible %0d",exact_2==alias_2);
    $display("UT: declared_callback_alias uvm_reg_bd_cb_iter compatible %0d",exact_3==alias_3);
    $display("UT: declared_callback_alias uvm_mem_cb compatible %0d",exact_4==alias_4);
    $display("UT: declared_callback_alias uvm_mem_cb_iter compatible %0d",exact_5==alias_5);
    $display("UT: declared_callback_alias uvm_reg_field_cb compatible %0d",exact_6==alias_6);
    $display("UT: declared_callback_alias uvm_reg_field_cb_iter compatible %0d",exact_7==alias_7);
    $display("UT: declared_callback_alias uvm_vreg_cb compatible %0d",exact_8==alias_8);
    $display("UT: declared_callback_alias uvm_vreg_cb_iter compatible %0d",exact_9==alias_9);
    $display("UT: declared_callback_alias uvm_vreg_field_cb compatible %0d",exact_10==alias_10);
    $display(
      "UT: declared_callback_alias uvm_vreg_field_cb_iter compatible %0d",exact_11==alias_11);
    $finish;
  end
endmodule
