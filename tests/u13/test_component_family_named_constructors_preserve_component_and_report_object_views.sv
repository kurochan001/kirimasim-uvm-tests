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
// What it checks:
// 1. A concrete component subtype is usable through uvm_report_object.
// 2. The component constructor preserves its selected legal leaf name.
// 3. A new component is registered under its supplied parent with the same
//    handle.
// 4. A legal concrete uvm_test subtype retains the component base.
// 5. The uvm_test constructor preserves its explicit name and component
//    parent.
// 6. A legal concrete uvm_env subtype retains the component base.
// 7. The uvm_env constructor preserves its explicit name and component parent.
// 8. A legal concrete uvm_agent subtype retains the component base.
// 9. The uvm_agent constructor preserves its explicit name and component
//    parent.
// 10. A legal concrete uvm_monitor subtype retains the component base.
// 11. The uvm_monitor constructor preserves its explicit name and component
//     parent.
// 12. A legal concrete uvm_scoreboard subtype retains the component base.
// 13. The uvm_scoreboard constructor preserves its explicit name and component
//     parent.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 13.1.1 (UVM-COMPONENT-AUDIT-REPORT-BASE-TYPE) gives rule 1
//    above. Setup: Use the selected original concrete component subtypes,
//    legal unique names, declared public types and linked observations.
//    Construct the hierarchy before phasing where phase callbacks are
//    observed. Expected: A concrete component subtype is usable through
//    uvm_report_object.
// 2. 1800.2-2020 13.1.2.1 (UVM-COMPONENT-AUDIT-CONSTRUCTOR-NAME) gives rule 2
//    above. Setup: Use the selected original concrete component subtypes,
//    legal unique names, declared public types and linked observations.
//    Construct the hierarchy before phasing where phase callbacks are
//    observed. Expected: The component constructor preserves its selected
//    legal leaf name.
// 3. 1800.2-2020 13.1.2.1 (UVM-COMPONENT-AUDIT-CONSTRUCTOR-CHILD-INSERTION)
//    gives rule 3 above. Setup: Use the selected original concrete component
//    subtypes, legal unique names, declared public types and linked
//    observations. Construct the hierarchy before phasing where phase
//    callbacks are observed. Expected: A new component is registered under its
//    supplied parent with the same handle.
// 4. 1800.2-2020 13.2.1 (UVM-COMPONENT-AUDIT-TEST-COMPONENT-BASE) gives rule 4
//    above. Setup: Use the selected original concrete component subtypes,
//    legal unique names, declared public types and linked observations.
//    Construct the hierarchy before phasing where phase callbacks are
//    observed. Expected: A legal concrete uvm_test subtype retains the
//    component base.
// 5. 1800.2-2020 13.2.2 (UVM-COMPONENT-AUDIT-TEST-NAMED-CONSTRUCTOR) gives
//    rule 5 above. Setup: Use the selected original concrete component
//    subtypes, legal unique names, declared public types and linked
//    observations. Construct the hierarchy before phasing where phase
//    callbacks are observed. Expected: The uvm_test constructor preserves its
//    explicit name and component parent.
// 6. 1800.2-2020 13.3.1 (UVM-COMPONENT-AUDIT-ENV-COMPONENT-BASE) gives rule 6
//    above. Setup: Use the selected original concrete component subtypes,
//    legal unique names, declared public types and linked observations.
//    Construct the hierarchy before phasing where phase callbacks are
//    observed. Expected: A legal concrete uvm_env subtype retains the
//    component base.
// 7. 1800.2-2020 13.3.2 (UVM-COMPONENT-AUDIT-ENV-NAMED-CONSTRUCTOR) gives rule
//    7 above. Setup: Use the selected original concrete component subtypes,
//    legal unique names, declared public types and linked observations.
//    Construct the hierarchy before phasing where phase callbacks are
//    observed. Expected: The uvm_env constructor preserves its explicit name
//    and component parent.
// 8. 1800.2-2020 13.4.1 (UVM-COMPONENT-AUDIT-AGENT-COMPONENT-BASE) gives rule
//    8 above. Setup: Use the selected original concrete component subtypes,
//    legal unique names, declared public types and linked observations.
//    Construct the hierarchy before phasing where phase callbacks are
//    observed. Expected: A legal concrete uvm_agent subtype retains the
//    component base.
// 9. 1800.2-2020 13.4.2.1 (UVM-COMPONENT-AUDIT-AGENT-NAMED-CONSTRUCTOR) gives
//    rule 9 above. Setup: Use the selected original concrete component
//    subtypes, legal unique names, declared public types and linked
//    observations. Construct the hierarchy before phasing where phase
//    callbacks are observed. Expected: The uvm_agent constructor preserves its
//    explicit name and component parent.
// 10. 1800.2-2020 13.5.1 (UVM-COMPONENT-AUDIT-MONITOR-COMPONENT-BASE) gives
//     rule 10 above. Setup: Use the selected original concrete component
//     subtypes, legal unique names, declared public types and linked
//     observations. Construct the hierarchy before phasing where phase
//     callbacks are observed. Expected: A legal concrete uvm_monitor subtype
//     retains the component base.
// 11. 1800.2-2020 13.5.2 (UVM-COMPONENT-AUDIT-MONITOR-NAMED-CONSTRUCTOR) gives
//     rule 11 above. Setup: Use the selected original concrete component
//     subtypes, legal unique names, declared public types and linked
//     observations. Construct the hierarchy before phasing where phase
//     callbacks are observed. Expected: The uvm_monitor constructor preserves
//     its explicit name and component parent.
// 12. 1800.2-2020 13.6.1 (UVM-COMPONENT-AUDIT-SCOREBOARD-COMPONENT-BASE) gives
//     rule 12 above. Setup: Use the selected original concrete component
//     subtypes, legal unique names, declared public types and linked
//     observations. Construct the hierarchy before phasing where phase
//     callbacks are observed. Expected: A legal concrete uvm_scoreboard
//     subtype retains the component base.
// 13. 1800.2-2020 13.6.2 (UVM-COMPONENT-AUDIT-SCOREBOARD-NAMED-CONSTRUCTOR)
//     gives rule 13 above. Setup: Use the selected original concrete component
//     subtypes, legal unique names, declared public types and linked
//     observations. Construct the hierarchy before phasing where phase
//     callbacks are observed. Expected: The uvm_scoreboard constructor
//     preserves its explicit name and component parent.
// It also supports, as a control, the setup or conditions of
// UVM-COMPONENT-AUDIT-TEST-ABSTRACT, UVM-COMPONENT-AUDIT-ENV-ABSTRACT,
// UVM-COMPONENT-AUDIT-AGENT-ABSTRACT, UVM-COMPONENT-AUDIT-MONITOR-ABSTRACT,
// UVM-COMPONENT-AUDIT-SCOREBOARD-ABSTRACT.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
