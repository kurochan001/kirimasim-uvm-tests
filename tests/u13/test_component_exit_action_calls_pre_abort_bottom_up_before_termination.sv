/*
:name: test_component_exit_action_calls_pre_abort_bottom_up_before_termination
:description: component exit action calls pre abort bottom up before termination
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.4.6 F.7.3.2 F.2.2.2 6.3.5.2 6.3.3.3 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_exit_action_calls_pre_abort_bottom_up_before_termination.expected
*/
module test_component_exit_action_calls_pre_abort_bottom_up_before_termination;
  import uvm_pkg::*;
  class abort_actor extends uvm_component;
    string id;
    function new(string name,uvm_component parent,string selected_id);
      super.new(name,parent); id=selected_id;
    endfunction
    virtual function void pre_abort();
      $display("UT: pre_abort %s",id); super.pre_abort();
    endfunction
  endclass
  initial begin
    automatic abort_actor a=new("a46",null,"A");
    automatic abort_actor b=new("b",a,"B");
    automatic abort_actor c=new("c",b,"C");
    a.set_report_id_action("EXIT46",UVM_EXIT);
    a.uvm_report_info("EXIT46","original exit action probe",UVM_NONE);
    $fatal(1,"exit action unexpectedly returned");
  end
endmodule
