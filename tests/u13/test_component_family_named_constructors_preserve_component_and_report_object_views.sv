/*
:name: test_component_family_named_constructors_preserve_component_and_report_object_views
:description: component family named constructors preserve component and report object views
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.2.1 13.1.1 13.2.1 13.2.2 13.3.1 13.3.2 13.4.1 13.4.2.1 13.5.1 13.5.2 13.6.1 13.6.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_family_named_constructors_preserve_component_and_report_object_views.expected
*/
module test_component_family_named_constructors_preserve_component_and_report_object_views;
  import uvm_pkg::*;
  class actor extends uvm_component;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
  endclass
  class local_test extends uvm_test;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
  endclass
  class local_env extends uvm_env;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
  endclass
  class local_agent extends uvm_agent;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
  endclass
  class local_monitor extends uvm_monitor;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
  endclass
  class local_scoreboard extends uvm_scoreboard;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
  endclass
  initial begin
    automatic actor owner=new("owner46",null);
    automatic actor base_value=new("base46",owner);
    automatic local_test test_value=new("test46",owner);
    automatic local_env env_value=new("env46",owner);
    automatic local_agent agent_value=new("agent46",owner);
    automatic local_monitor monitor_value=new("monitor46",owner);
    automatic local_scoreboard scoreboard_value=new("scoreboard46",owner);
    automatic uvm_component views[6]='{base_value,test_value,env_value,agent_value,
                                      monitor_value,scoreboard_value};
    automatic string names[6]='{"base46","test46","env46","agent46","monitor46","scoreboard46"};
    uvm_report_object report_view;
    foreach (views[i]) begin
      report_view=views[i];
      $display("UT: component_family %0d name %0d parent %0d registered %0d report_base %0d",i,
               views[i].get_name()==names[i],views[i].get_parent()==owner,
               owner.get_child(names[i])==views[i],report_view==views[i]);
    end
    $finish;
  end
endmodule
