/*
:name: test_copier_user_hook_sees_configured_policy
:description: the copy hook observes the configured mode and active object of its copier (IEEE 1800.2-2020 Section 16.6.3)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.6.3 16.6.4.1 5.3.8.2 16.1.3.1 16.1.3.2 16.1.3.3 16.1.3.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_copier_user_hook_sees_configured_policy.expected
*/
// What it checks:
// Copying makes the target active in its policy during the copy hook and
// restores the stack afterwards.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.6.4.1 (UVM-COPIER-ACTIVE-TARGET) gives the rule above. Setup:
// Expose a shallow-configured copier to the target hook and inspect depth
// before/during/after. Expected: The hook sees the target at depth 1 with its
// configured mode, then depth returns to zero.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// copy_object pushes the target onto its policy's active-object stack.
// Give the hook a handle to that policy so it can observe the active target,
// stack depth and configured recursion mode while copying a scalar payload.
// This case avoids the field macro's shallow-copy and object-policy APIs.

module test_copier_user_hook_sees_configured_policy;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class probe extends uvm_object;
    `uvm_object_utils(probe)
    int payload = 0;
    uvm_copier configured_policy;
    bit seen_target = 0;
    bit seen_shallow = 0;
    int seen_depth = 0;
    function new(string name="probe"); super.new(name); endfunction
    function void do_copy(uvm_object rhs);
      probe source;
      super.do_copy(rhs);
      if (!$cast(source, rhs)) $fatal(1, "unexpected copy type");
      if (configured_policy == null) $fatal(1, "missing fixture copier");
      seen_target = configured_policy.get_active_object() == this;
      seen_depth = configured_policy.get_active_object_depth();
      seen_shallow = configured_policy.get_recursion_policy() == UVM_SHALLOW;
      payload = source.payload;
    endfunction
  endclass

  initial begin
    automatic probe source = new("source");
    automatic probe target = new("target");
    automatic uvm_copier copier = new;
    source.payload = 55;
    target.configured_policy = copier;
    copier.set_recursion_policy(UVM_SHALLOW);
    $display("UT: before depth %0d", copier.get_active_object_depth());
    copier.copy_object(target, source);
    $display("UT: hook target %0d shallow %0d depth %0d payload %0d", target.seen_target,
             target.seen_shallow, target.seen_depth, target.payload);
    $display("UT: after depth %0d", copier.get_active_object_depth());
    $finish;
  end
endmodule
