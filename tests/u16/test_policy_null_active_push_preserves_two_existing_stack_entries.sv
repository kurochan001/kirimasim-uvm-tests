/*
:name: test_policy_null_active_push_preserves_two_existing_stack_entries
:description: null active-object push reports ERROR and leaves the existing stack unchanged (IEEE 1800.2-2020 Section 16.1.3.1)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.1.3.1 16.1.3.2 16.1.3.3 16.1.3.4 6.6.3.2 6.6.5 D.4.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_policy_null_active_push_preserves_two_existing_stack_entries.expected
*/
// What it checks:
// Pushing null onto the active-object stack reports an error and ignores the
// request.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.1.3.1 (UVM-POLICY-NULL-ACTIVE-PUSH) gives the rule above.
// Setup: Push null into empty and nonempty policy stacks. Expected: An error
// occurs and the stack retains its previous objects/depth.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Count the original ERROR severity without changing it or constraining IDs.
// Public policy-side stack queries and real pops establish ignored insertion.
module test_policy_null_active_push_preserves_two_existing_stack_entries;
  import uvm_pkg::*;

  class item extends uvm_object;
    int payload = 0;
    function new(string name="item"); super.new(name); endfunction
    virtual function void do_copy(uvm_object rhs);
      item source;
      if (!$cast(source, rhs)) $fatal(1, "unexpected copy fixture type");
      payload = source.payload;
    endfunction
  endclass
  class error_probe extends uvm_report_catcher;
    int errors = 0;
    function new(string name="error_probe"); super.new(name); endfunction
    virtual function action_e catch();
      if (get_severity() == UVM_ERROR) begin
        errors++;
        return CAUGHT;
      end
      return THROW;
    endfunction
  endclass

  initial begin
    uvm_copier policy;
    error_probe probe;
    item first;
    item second;
    uvm_object popped;
    policy = new();
    probe = new();
    first = new("first");
    second = new("second");
    uvm_report_cb::add(null, probe);
    policy.push_active_object(first);
    policy.push_active_object(second);
    policy.push_active_object(null);
    $display("UT: error %0d depth %0d top_second %0d", probe.errors > 0,
             policy.get_active_object_depth(), policy.get_active_object() == second);
    popped = policy.pop_active_object();
    $display("UT: pop_second %0d top_first %0d depth %0d", popped == second,
             policy.get_active_object() == first, policy.get_active_object_depth());
    popped = policy.pop_active_object();
    $display("UT: pop_first %0d empty %0d", popped == first,
             policy.get_active_object_depth() == 0 && policy.get_active_object() == null);
    uvm_report_cb::delete(null, probe);
    $finish;
  end
endmodule
