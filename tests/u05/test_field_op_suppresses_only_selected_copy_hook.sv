/*
:name: test_field_op_suppresses_only_selected_copy_hook
:description: a disabled copy hook is skipped and a later operation can enable it again (IEEE 1800.2-2020 Section 5.7.2.7)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.7.2.7 5.7.2.8 16.6.4.1 5.3.13 5.3.8.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_field_op_suppresses_only_selected_copy_hook.expected
*/
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
    probe source = new;
    probe target = new;
    uvm_copier copier = new;
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
