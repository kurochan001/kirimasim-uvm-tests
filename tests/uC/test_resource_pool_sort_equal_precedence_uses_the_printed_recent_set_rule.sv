/*
:name: test_resource_pool_sort_equal_precedence_uses_the_printed_recent_set_rule
:description: resource pool sort equal precedence uses the printed recent set rule
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.4.4.3 C.2.4.3.1 C.2.4.5.6 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_pool_sort_equal_precedence_uses_the_printed_recent_set_rule.expected
*/
module test_resource_pool_sort_equal_precedence_uses_the_printed_recent_set_rule;
  import uvm_pkg::*;
  // Qualified reading: recent set is the observed set_scope insertion order.
  // The supplied queue is deliberately oldest first; no private clock is read.
  initial begin
    uvm_resource_pool pool;
    uvm_resource#(int) oldest,middle,newest;
    uvm_resource_types::rsrc_q_t values;
    pool=uvm_resource_pool::get(); oldest=new("slot62"); middle=new("slot62");
    newest=new("slot62"); values=new();
    pool.set_scope(oldest,"scope62"); pool.set_precedence(oldest,7);
    #1; pool.set_scope(middle,"scope62"); pool.set_precedence(middle,7);
    #1; pool.set_scope(newest,"scope62"); pool.set_precedence(newest,7);
    values.push_back(oldest); values.push_back(middle); values.push_back(newest);
    uvm_resource_pool::sort_by_precedence(values);
    $display("UT: sort_equal count %0d recently_set_first %0d",
      values.size()==3,
      values.get(0)==newest && values.get(1)==middle && values.get(2)==oldest);
    $display("DETAIL: original_positions oldest %0d middle %0d newest %0d",
      values.get(0)==oldest,values.get(1)==middle,values.get(2)==newest);
    $finish;
  end
endmodule
