/*
:name: test_object_active_policy_push_null_uses_the_standard_public_interface
:description: Independent object-side active-policy push_null contract
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.14.1 6.6.3.2 6.6.5 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_active_policy_push_null_uses_the_standard_public_interface.expected
*/
// What it checks:
// Pushing a null policy generates an error.
//
// How the expected output follows from the standard:
// 1800.2-2020 5.3.14.1 (UVM-BASE-AUDIT-ACTIVE-NULL-ERROR) gives the rule
// above. Setup: Use original concrete objects and two legal copier policies;
// empty-only probes require no other stack method. Expected: The independent
// push-null fixture observes an error notification.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_object_active_policy_push_null_uses_the_standard_public_interface;
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
    uvm_report_cb::add(null,catcher); catcher.gated=1;
    value.push_active_policy(null); catcher.gated=0;
    $display("UT: null_policy error %0d",catcher.errors>0);
    uvm_report_cb::delete(null,catcher);
    $finish;
  end
  initial begin #100; $fatal(1,"base-class fixture watchdog expired"); end
endmodule
