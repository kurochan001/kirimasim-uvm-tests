/*
:name: test_callback_macro_method_refs_prepend_82
:description: Callback METHOD arguments preserve noncommutative reference updates in registration order
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.4.3 B.4.1 10.7.2.3.1 1800-2023 6.21 8.20 8.23 8.25 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers82/callbacks82.svh
:expected_exit: 0
:expected_stdout: @test_callback_macro_method_refs_prepend_82.expected
*/
// Original callback arithmetic/trace is stimulus; no private registration bits.
module test_callback_macro_method_refs_prepend_82;
  import uvm_pkg::*;
  `include "callbacks82.svh"
  initial begin
    automatic owner82 target=new();
    automatic callback82 a=new("A",3,1);
    automatic callback82 b=new("B",7,1);
    int acc;
    string trace;
    pool82::add(target,a); pool82::add(target,b,UVM_PREPEND);
    acc=5; trace=""; target.fire82(31,acc,trace);
    $display("UT: cb82 method_refs_prepend value %0d trace %0d calls %0d args %0d",
      acc==37,trace=="BA",a.calls==1 && b.calls==1,
      a.last_owner==target && b.last_owner==target &&
      a.last_token==31 && b.last_token==31);
    $finish;
  end
endmodule
