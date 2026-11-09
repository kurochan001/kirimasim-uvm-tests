/*
:name: test_object_active_policy_lifo_uses_the_standard_public_interface
:description: Independent object-side active-policy lifo contract
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.14.1 5.3.14.2 5.3.14.3 6.6.3.2 6.6.5 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_active_policy_lifo_uses_the_standard_public_interface.expected
*/
// What it checks:
// 1. Push makes the selected policy current and ignores a null request after
//    reporting.
// 2. Pop returns the most recently pushed policy and restores its predecessor.
// 3. The active-policy getter tracks the selected object stack head.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.3.14.1 (UVM-BASE-AUDIT-ACTIVE-PUSH-HEAD) gives rule 1
//    above. Setup: Use original concrete objects and two legal copier
//    policies; empty-only probes require no other stack method. Expected: The
//    second policy is current; null reports without changing that head and the
//    peer remains empty.
// 2. 1800.2-2020 5.3.14.2 (UVM-BASE-AUDIT-ACTIVE-POP-LIFO) gives rule 2 above.
//    Setup: Use original concrete objects and two legal copier policies;
//    empty-only probes require no other stack method. Expected: Second then
//    first are returned; the final extra pop is null.
// 3. 1800.2-2020 5.3.14.3 (UVM-BASE-AUDIT-ACTIVE-QUERY-HEAD) gives rule 3
//    above. Setup: Use original concrete objects and two legal copier
//    policies; empty-only probes require no other stack method. Expected:
//    Queries follow the second/first/empty transitions independently of a peer
//    object.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_object_active_policy_lifo_uses_the_standard_public_interface;
  import uvm_pkg::*;
  class original_object extends uvm_object;
    function new(string name=""); super.new(name); endfunction
    virtual function string get_type_name(); return "original_object61"; endfunction
    virtual function uvm_object create(string name="");
      original_object result;
      result=new(name); return result;
    endfunction
  endclass
  class reports extends uvm_report_catcher;
    bit gated=0;
    int errors=0;
    virtual function action_e catch();
      if (gated && (get_severity()==UVM_ERROR || get_severity()==UVM_FATAL)) begin
        errors++; return CAUGHT;
      end
      return THROW;
    endfunction
  endclass
  initial begin
    original_object value,peer;
    uvm_policy result;
    uvm_copier first,second;
    reports catcher;
    value=new("value61"); peer=new("peer61"); first=new(); second=new(); catcher=new();
    value.push_active_policy(first); value.push_active_policy(second);
    $display("UT: policy_push latest %0d peer_empty %0d",
      value.get_active_policy()==second,peer.get_active_policy()==null);
    uvm_report_cb::add(null,catcher); catcher.gated=1;
    value.push_active_policy(null); catcher.gated=0;
    $display("UT: null_policy_preserved error %0d same_top %0d",
      catcher.errors>0,value.get_active_policy()==second);
    result=value.pop_active_policy();
    $display("UT: policy_pop second %0d first_restored %0d",
      result==second,value.get_active_policy()==first);
    result=value.pop_active_policy();
    $display("UT: policy_empty first %0d empty %0d extra_null %0d",
      result==first,value.get_active_policy()==null,value.pop_active_policy()==null);
    uvm_report_cb::delete(null,catcher);
    $finish;
  end
  initial begin #100; $fatal(1,"base-class fixture watchdog expired"); end
endmodule
