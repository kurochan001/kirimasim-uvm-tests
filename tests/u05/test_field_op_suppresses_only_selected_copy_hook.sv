/*
:name: test_field_op_suppresses_only_selected_copy_hook
:description: a disabled copy hook is skipped and a later operation can enable it again (IEEE 1800.2-2020 Section 5.7.2.7)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.7.2.7 5.7.2.8 16.6.4.1 5.3.13 5.3.8.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_field_op_suppresses_only_selected_copy_hook.expected
*/
// What it checks:
// 1. A fresh or reset field operation enables its user hook by default.
// 2. disable_user_hook prevents the selected operation from calling its user
//    hook.
// 3. The selected virtual copy hook copies rhs payload through its original
//    typed extension.
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
// 3. 1800.2-2020 5.3.8.2 (UVM-BASE-AUDIT-COPY-HOOK) gives rule 3 above. Setup:
//    Reassess the unchanged real copier fixture with disabled then enabled
//    user-hook phases. Expected: Suppression leaves payload three; the later
//    enabled hook copies twenty-nine once.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// do_execute_op can disable the following do_copy call. A later operation
// starts with the hook enabled and copies the new payload normally.

module test_field_op_suppresses_only_selected_copy_hook;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class probe extends uvm_object;
    `uvm_object_utils(probe)
    int payload = 0;
    int copies = 0;
    bit suppress = 1;
    bit initial_enabled = 0;
    function new(string name="probe"); super.new(name); endfunction
    function void do_execute_op(uvm_field_op op);
      super.do_execute_op(op);
      initial_enabled = op.user_hook_enabled();
      if (suppress) op.disable_user_hook();
    endfunction
    function void do_copy(uvm_object rhs);
      probe source;
      super.do_copy(rhs);
      if (!$cast(source, rhs)) $fatal(1, "unexpected copy type");
      copies++;
      payload = source.payload;
    endfunction
  endclass
  initial begin
    automatic probe source = new;
    automatic probe target = new;
    automatic uvm_copier copier = new;
    source.payload = 19;
    target.payload = 3;
    copier.copy_object(target, source);
    $display("UT: suppressed initial %0d copies %0d payload %0d", target.initial_enabled,
             target.copies, target.payload);
    target.suppress = 0;
    source.payload = 29;
    copier.copy_object(target, source);
    $display("UT: restored initial %0d copies %0d payload %0d", target.initial_enabled,
             target.copies, target.payload);
    $finish;
  end
endmodule
