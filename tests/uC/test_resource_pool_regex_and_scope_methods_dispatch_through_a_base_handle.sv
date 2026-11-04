/*
:name: test_resource_pool_regex_and_scope_methods_dispatch_through_a_base_handle
:description: resource pool regex and scope methods dispatch through a base handle
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.4.4.7 C.2.4.4.8 C.2.4.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_pool_regex_and_scope_methods_dispatch_through_a_base_handle.expected
*/
module test_resource_pool_regex_and_scope_methods_dispatch_through_a_base_handle;
  import uvm_pkg::*;
  // Original overrides observe dispatch, not collection algorithms.
  class original_pool extends uvm_resource_pool;
    int regex_calls=0,scope_calls=0;
    string seen_re,seen_scope;
    uvm_resource_types::rsrc_q_t result;
    function new(); super.new(); result=new(); endfunction
    virtual function uvm_resource_types::rsrc_q_t lookup_regex(string re,string scope);
      regex_calls++; seen_re=re; seen_scope=scope; return result;
    endfunction
    virtual function uvm_resource_types::rsrc_q_t lookup_scope(string scope);
      scope_calls++; seen_scope=scope; return result;
    endfunction
  endclass
  initial begin
    original_pool concrete;
    uvm_resource_pool base;
    uvm_resource_types::rsrc_q_t found;
    concrete=new(); base=concrete; found=base.lookup_regex("selected62","first62");
    $display("UT: pool_virtual regex %0d",
      concrete.regex_calls==1 && concrete.seen_re=="selected62" &&
      concrete.seen_scope=="first62" && found==concrete.result);
    $display("DETAIL: regex calls %0d re <%s> scope <%s> same_queue %0d",
      concrete.regex_calls,concrete.seen_re,concrete.seen_scope,found==concrete.result);
    found=base.lookup_scope("second62");
    $display("UT: pool_virtual scope %0d",
      concrete.scope_calls==1 && concrete.seen_scope=="second62" && found==concrete.result);
    $display("DETAIL: scope calls %0d scope <%s> same_queue %0d",
      concrete.scope_calls,concrete.seen_scope,found==concrete.result);
    $finish;
  end
endmodule
