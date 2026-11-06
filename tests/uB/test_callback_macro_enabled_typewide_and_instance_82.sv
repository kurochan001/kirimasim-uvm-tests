/*
:name: test_callback_macro_enabled_typewide_and_instance_82
:description: Dispatch combines applicable callbacks and responds to explicit enable state changes
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.4.3 B.4.1 10.7.1.2.2 10.7.2.3.1 10.7.2.4.1 1800-2023 6.21 8.20 8.23 8.25 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers82/callbacks82.svh
:expected_exit: 0
:expected_stdout: @test_callback_macro_enabled_typewide_and_instance_82.expected
*/
// Original callback arithmetic/trace is stimulus; no private registration bits.
module test_callback_macro_enabled_typewide_and_instance_82;
  import uvm_pkg::*;
  `include "callbacks82.svh"
  initial begin
    automatic owner82 left=new("left82");
    automatic owner82 right=new("right82");
    automatic callback82 global_cb=new("G",1);
    automatic callback82 a=new("A",3);
    automatic callback82 b=new("B",5);
    automatic callback82 dormant=new("D",7);
    int acc;
    string trace;
    pool82::add(null,global_cb); pool82::add(left,a); pool82::add(left,dormant);
    pool82::add(right,b); void'(dormant.callback_mode(0));
    acc=0; trace=""; left.fire82(41,acc,trace);
    $display("UT: cb82 enabled left %0d counts %0d dormant %0d",
      acc==4,global_cb.calls==1 && a.calls==1 && b.calls==0,dormant.calls==0);
    acc=0; trace=""; right.fire82(43,acc,trace);
    $display("UT: cb82 enabled right %0d counts %0d scope %0d",
      acc==6,global_cb.calls==2 && a.calls==1 && b.calls==1,
      global_cb.last_owner==right && b.last_owner==right);
    void'(dormant.callback_mode(1)); acc=0; trace=""; left.fire82(47,acc,trace);
    $display("UT: cb82 enabled resumed %0d counts %0d args %0d",
      acc==11,global_cb.calls==3 && a.calls==2 && dormant.calls==1 && b.calls==1,
      dormant.last_owner==left && dormant.last_token==47);
    $finish;
  end
endmodule
