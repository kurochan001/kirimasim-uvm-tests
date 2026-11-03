/*
:name: test_component_suspend_resume_dispatch_to_the_original_protocol_through_a_base_view
:description: component suspend resume dispatch to the original protocol through a base view
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.4.5.1 13.1.4.5.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_suspend_resume_dispatch_to_the_original_protocol_through_a_base_view.expected
*/
module test_component_suspend_resume_dispatch_to_the_original_protocol_through_a_base_view;
  import uvm_pkg::*;
  class protocol_actor extends uvm_component;
    bit paused=0;
    string trace="";
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    virtual task suspend(); paused=1; trace={trace,"S"}; endtask
    virtual task resume(); paused=0; trace={trace,"R"}; endtask
  endclass
  initial begin
    automatic protocol_actor selected=new("selected46",null);
    automatic protocol_actor peer=new("peer46",null);
    automatic uvm_component view=selected;
    view.suspend();
    $display("UT: protocol_suspended selected %0d peer %0d trace %s",
             selected.paused,peer.paused,selected.trace);
    view.resume();
    $display("UT: protocol_resumed selected %0d peer %0d trace %s",
             selected.paused,peer.paused,selected.trace);
    $finish;
  end
endmodule
