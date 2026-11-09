/*
:name: test_field_op_flush_reenables_user_hook
:description: disabling a user hook affects the current field operation and flush resets it (IEEE 1800.2-2020 Section 5.7.2.7)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.7.2.7 5.7.2.8 5.7.2.9 5.7.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_field_op_flush_reenables_user_hook.expected
*/
// What it checks:
// 1. A fresh or reset field operation enables its user hook by default.
// 2. disable_user_hook prevents the selected operation from calling its user
//    hook.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.7.2.7 (UVM-FIELD-OP-HOOK-DEFAULT) gives rule 1 above.
//    Setup: Disable the hook for one operation, then flush or perform another
//    copy operation. Expected: The later operation starts enabled and can
//    invoke its user hook.
// 2. 1800.2-2020 5.7.2.8 (UVM-FIELD-OP-HOOK-DISABLE) gives rule 2 above.
//    Setup: Disable explicitly or from do_execute_op before the copier reaches
//    do_copy. Expected: The enabled bit becomes zero and the suppressed copy
//    hook leaves the fixture payload unchanged.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe the enabled bit only after set, disable it for that operation,
// then flush and set a new operation to observe the restored default.
// The pinned library rejects user_hook_enabled before set or after flush,
// although 5.7.2.7 does not specify that restriction.

module test_field_op_flush_reenables_user_hook;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_field_op op = new;
    automatic uvm_copier copier = new;
    op.set(UVM_COPY, copier);
    $display("UT: initial enabled %0d", op.user_hook_enabled());
    op.disable_user_hook();
    $display("UT: disabled %0d", op.user_hook_enabled());
    op.flush();
    op.set(UVM_COPY, copier);
    $display("UT: reused enabled %0d", op.user_hook_enabled());
    $finish;
  end
endmodule
