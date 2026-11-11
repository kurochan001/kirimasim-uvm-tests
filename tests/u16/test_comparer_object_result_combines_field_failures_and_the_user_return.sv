/*
:name: test_comparer_object_result_combines_field_failures_and_the_user_return
:description: comparer object result combines field failures and the user return
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.3.3.4 16.3.3.5 16.3.3.9 16.3.3.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_comparer_object_result_combines_field_failures_and_the_user_return.expected
*/
// What it checks:
// Comparison succeeds only when fields add no mismatch and the enabled user
// hook returns true.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.3.3.4 (UVM-POLICY-AUDIT-COMPARER-RESULT-GATE) gives the rule
// above. Setup: Use the selected original fixtures, explicit arguments and
// stage observations in the linked anchors; each fresh policy and peer is
// independently constructed. Expected: Comparison succeeds only when fields
// add no mismatch and the enabled user hook returns true.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_comparer_object_result_combines_field_failures_and_the_user_return;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class item extends uvm_object;
    `uvm_object_utils(item)
    bit field_failure=0,user_result=1;
    int fields_failed_before_user=0;
    function new(string name="item"); super.new(name); endfunction
    virtual function void do_execute_op(uvm_field_op op);
      uvm_comparer comparer;
      if (!$cast(comparer,op.get_policy())) $fatal(1,"wrong original policy");
      if (field_failure) void'(comparer.compare_field_int("field43",0,1,32));
    endfunction
    virtual function bit do_compare(uvm_object rhs,uvm_comparer comparer);
      fields_failed_before_user=comparer.get_result(); return user_result;
    endfunction
  endclass
  initial begin
    for (int i=0;i<3;i++) begin
      automatic uvm_comparer comparer=new();
      automatic item lhs=new("lhs");
      automatic item rhs=new("rhs");
      bit result,history;
      uvm_policy::recursion_state_e state;
      lhs.field_failure=i==0; lhs.user_result=i!=1;
      comparer.set_recursion_policy(UVM_DEEP);
      result=comparer.compare_object("selected",lhs,rhs);
      state=comparer.object_compared(lhs,rhs,UVM_DEEP,history);
      $display("UT: result_gate %0d field_failure %0d user %0d result %0d history %0d finished %0d",
               i,lhs.fields_failed_before_user,lhs.user_result,result,history,
               state==uvm_policy::FINISHED);
    end
    $finish;
  end
endmodule
