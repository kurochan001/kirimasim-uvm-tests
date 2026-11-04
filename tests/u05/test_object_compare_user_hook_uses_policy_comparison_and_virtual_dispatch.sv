/*
:name: test_object_compare_user_hook_uses_policy_comparison_and_virtual_dispatch
:description: The original virtual compare hook uses the supplied public policy field operation
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.9.2 5.3.9 5.3.9.1 16.3.3.4 16.3.3.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_compare_user_hook_uses_policy_comparison_and_virtual_dispatch.expected
*/
module test_object_compare_user_hook_uses_policy_comparison_and_virtual_dispatch;
  import uvm_pkg::*;
  class original_object extends uvm_object;
    function new(string name=""); super.new(name); endfunction
    virtual function string get_type_name(); return "original_object61"; endfunction
    virtual function uvm_object create(string name="");
      original_object result;
      result=new(name); return result;
    endfunction
  endclass
  class comparable extends original_object;
    int payload=0,calls=0;
    uvm_comparer expected_policy;
    bit policy_ok=1;
    function new(); super.new("comparable61"); endfunction
    virtual function bit do_compare(uvm_object rhs,uvm_comparer comparer);
      comparable source;
      calls++; policy_ok &= comparer==expected_policy;
      if (!$cast(source,rhs)) return 0;
      return comparer.compare_field_int("payload61",payload,source.payload,8,UVM_HEX);
    endfunction
    virtual function string get_type_name(); return "comparable61"; endfunction
    virtual function uvm_object create(string name="");
      comparable result;
      result=new(); result.set_name(name); return result;
    endfunction
  endclass
  initial begin
    comparable left,right;
    uvm_comparer policy;
    uvm_object view;
    bit same,different;
    left=new(); right=new(); policy=new(); view=left;
    left.expected_policy=policy; left.payload=37; right.payload=37;
    same=view.compare(right,policy);
    right.payload=61; different=view.compare(right,policy);
    $display("UT: compare_hook equal %0d unequal %0d policy %0d two_hooks %0d",
      same,!different,left.policy_ok,left.calls==2);
    $finish;
  end
  initial begin #100; $fatal(1,"base hook fixture watchdog expired"); end
endmodule
