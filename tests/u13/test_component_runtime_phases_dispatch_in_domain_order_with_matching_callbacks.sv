/*
:name: test_component_runtime_phases_dispatch_in_domain_order_with_matching_callbacks
:description: component runtime phases dispatch in domain order with matching callbacks
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.4.2 13.1.4.2.1 13.1.4.2.2 13.1.4.2.3 13.1.4.2.4 13.1.4.2.5 13.1.4.2.6 13.1.4.2.7 13.1.4.2.8 13.1.4.2.9 13.1.4.2.10 13.1.4.2.11 13.1.4.2.12 13.1.4.3.1 13.1.4.3.3 9.8.2 F.7.3.1 F.7.3.4 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_runtime_phases_dispatch_in_domain_order_with_matching_callbacks.expected
*/
// What it checks:
// 1. The run-time pre_reset phase invokes the matching component task between
//    its phase callbacks.
// 2. The run-time reset phase invokes the matching component task between its
//    phase callbacks.
// 3. The run-time post_reset phase invokes the matching component task between
//    its phase callbacks.
// 4. The run-time pre_configure phase invokes the matching component task
//    between its phase callbacks.
// 5. The run-time configure phase invokes the matching component task between
//    its phase callbacks.
// 6. The run-time post_configure phase invokes the matching component task
//    between its phase callbacks.
// 7. The run-time pre_main phase invokes the matching component task between
//    its phase callbacks.
// 8. The run-time main phase invokes the matching component task between its
//    phase callbacks.
// 9. The run-time post_main phase invokes the matching component task between
//    its phase callbacks.
// 10. The run-time pre_shutdown phase invokes the matching component task
//     between its phase callbacks.
// 11. The run-time shutdown phase invokes the matching component task between
//     its phase callbacks.
// 12. The run-time post_shutdown phase invokes the matching component task
//     between its phase callbacks.
// 13. The selected common and run-time phase start callbacks identify their
//     phase before its component method.
// 14. The selected common and run-time phase end callbacks identify their
//     phase after its component method.
// 15. The selected default-domain runtime tasks dispatch in the prescribed
//     phase order.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 13.1.4.2.1 (UVM-COMPONENT-AUDIT-RUNTIME-PRE-RESET-DISPATCH)
//    gives rule 1 above. Setup: Use the selected original concrete component
//    subtypes, legal unique names, declared public types and linked
//    observations. Construct the hierarchy before phasing where phase
//    callbacks are observed. Expected: The run-time pre_reset phase invokes
//    the matching component task between its phase callbacks.
// 2. 1800.2-2020 13.1.4.2.2 (UVM-COMPONENT-AUDIT-RUNTIME-RESET-DISPATCH) gives
//    rule 2 above. Setup: Use the selected original concrete component
//    subtypes, legal unique names, declared public types and linked
//    observations. Construct the hierarchy before phasing where phase
//    callbacks are observed. Expected: The run-time reset phase invokes the
//    matching component task between its phase callbacks.
// 3. 1800.2-2020 13.1.4.2.3 (UVM-COMPONENT-AUDIT-RUNTIME-POST-RESET-DISPATCH)
//    gives rule 3 above. Setup: Use the selected original concrete component
//    subtypes, legal unique names, declared public types and linked
//    observations. Construct the hierarchy before phasing where phase
//    callbacks are observed. Expected: The run-time post_reset phase invokes
//    the matching component task between its phase callbacks.
// 4. 1800.2-2020 13.1.4.2.4
//    (UVM-COMPONENT-AUDIT-RUNTIME-PRE-CONFIGURE-DISPATCH) gives rule 4 above.
//    Setup: Use the selected original concrete component subtypes, legal
//    unique names, declared public types and linked observations. Construct
//    the hierarchy before phasing where phase callbacks are observed.
//    Expected: The run-time pre_configure phase invokes the matching component
//    task between its phase callbacks.
// 5. 1800.2-2020 13.1.4.2.5 (UVM-COMPONENT-AUDIT-RUNTIME-CONFIGURE-DISPATCH)
//    gives rule 5 above. Setup: Use the selected original concrete component
//    subtypes, legal unique names, declared public types and linked
//    observations. Construct the hierarchy before phasing where phase
//    callbacks are observed. Expected: The run-time configure phase invokes
//    the matching component task between its phase callbacks.
// 6. 1800.2-2020 13.1.4.2.6
//    (UVM-COMPONENT-AUDIT-RUNTIME-POST-CONFIGURE-DISPATCH) gives rule 6 above.
//    Setup: Use the selected original concrete component subtypes, legal
//    unique names, declared public types and linked observations. Construct
//    the hierarchy before phasing where phase callbacks are observed.
//    Expected: The run-time post_configure phase invokes the matching
//    component task between its phase callbacks.
// 7. 1800.2-2020 13.1.4.2.7 (UVM-COMPONENT-AUDIT-RUNTIME-PRE-MAIN-DISPATCH)
//    gives rule 7 above. Setup: Use the selected original concrete component
//    subtypes, legal unique names, declared public types and linked
//    observations. Construct the hierarchy before phasing where phase
//    callbacks are observed. Expected: The run-time pre_main phase invokes the
//    matching component task between its phase callbacks.
// 8. 1800.2-2020 13.1.4.2.8 (UVM-COMPONENT-AUDIT-RUNTIME-MAIN-DISPATCH) gives
//    rule 8 above. Setup: Use the selected original concrete component
//    subtypes, legal unique names, declared public types and linked
//    observations. Construct the hierarchy before phasing where phase
//    callbacks are observed. Expected: The run-time main phase invokes the
//    matching component task between its phase callbacks.
// 9. 1800.2-2020 13.1.4.2.9 (UVM-COMPONENT-AUDIT-RUNTIME-POST-MAIN-DISPATCH)
//    gives rule 9 above. Setup: Use the selected original concrete component
//    subtypes, legal unique names, declared public types and linked
//    observations. Construct the hierarchy before phasing where phase
//    callbacks are observed. Expected: The run-time post_main phase invokes
//    the matching component task between its phase callbacks.
// 10. 1800.2-2020 13.1.4.2.10
//     (UVM-COMPONENT-AUDIT-RUNTIME-PRE-SHUTDOWN-DISPATCH) gives rule 10 above.
//     Setup: Use the selected original concrete component subtypes, legal
//     unique names, declared public types and linked observations. Construct
//     the hierarchy before phasing where phase callbacks are observed.
//     Expected: The run-time pre_shutdown phase invokes the matching component
//     task between its phase callbacks.
// 11. 1800.2-2020 13.1.4.2.11 (UVM-COMPONENT-AUDIT-RUNTIME-SHUTDOWN-DISPATCH)
//     gives rule 11 above. Setup: Use the selected original concrete component
//     subtypes, legal unique names, declared public types and linked
//     observations. Construct the hierarchy before phasing where phase
//     callbacks are observed. Expected: The run-time shutdown phase invokes
//     the matching component task between its phase callbacks.
// 12. 1800.2-2020 13.1.4.2.12
//     (UVM-COMPONENT-AUDIT-RUNTIME-POST-SHUTDOWN-DISPATCH) gives rule 12
//     above. Setup: Use the selected original concrete component subtypes,
//     legal unique names, declared public types and linked observations.
//     Construct the hierarchy before phasing where phase callbacks are
//     observed. Expected: The run-time post_shutdown phase invokes the
//     matching component task between its phase callbacks.
// 13. 1800.2-2020 13.1.4.3.1 (UVM-COMPONENT-AUDIT-PHASE-START-CALLBACK) gives
//     rule 13 above. Setup: Use the selected original concrete component
//     subtypes, legal unique names, declared public types and linked
//     observations. Construct the hierarchy before phasing where phase
//     callbacks are observed. Expected: The selected common and run-time phase
//     start callbacks identify their phase before its component method.
// 14. 1800.2-2020 13.1.4.3.3 (UVM-COMPONENT-AUDIT-PHASE-END-CALLBACK) gives
//     rule 14 above. Setup: Use the selected original concrete component
//     subtypes, legal unique names, declared public types and linked
//     observations. Construct the hierarchy before phasing where phase
//     callbacks are observed. Expected: The selected common and run-time phase
//     end callbacks identify their phase after its component method.
// 15. 1800.2-2020 9.8.2 (UVM-COMPONENT-AUDIT-RUNTIME-DOMAIN-ORDER) gives rule
//     15 above. Setup: Use the selected original concrete component subtypes,
//     legal unique names, declared public types and linked observations.
//     Construct the hierarchy before phasing where phase callbacks are
//     observed. Expected: The selected default-domain runtime tasks dispatch
//     in the prescribed phase order.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_component_runtime_phases_dispatch_in_domain_order_with_matching_callbacks;
  import uvm_pkg::*;
  string traces[string];
  string method_order[string];
  string phase_order="";
  bit runtime_done=0;
  function automatic void mark(uvm_phase phase,string id,string event_code);
    automatic string key={phase.get_name(),"/",id};
    if (!traces.exists(key)) traces[key]="";
    traces[key]={traces[key],event_code};
    if (event_code=="M") begin
      if (!method_order.exists(phase.get_name())) method_order[phase.get_name()]="";
      method_order[phase.get_name()]={method_order[phase.get_name()],id};
      if (id=="A") phase_order={phase_order,phase.get_name(),"/"};
    end
  endfunction
  class phase_actor extends uvm_component;
    string id;
    function new(string name,uvm_component parent,string selected_id);
      super.new(name,parent); id=selected_id;
    endfunction
    virtual function void phase_started(uvm_phase phase);
      super.phase_started(phase); mark(phase,id,"S");
    endfunction
    virtual function void phase_ended(uvm_phase phase);
      super.phase_ended(phase); mark(phase,id,"E");
    endfunction
    virtual task run_phase(uvm_phase phase);
      if (id=="A") begin
        phase.raise_objection(this); wait(runtime_done); phase.drop_objection(this);
      end
    endtask
    virtual task pre_reset_phase(uvm_phase phase);
      if (id=="A") phase.raise_objection(this);
      mark(phase,id,"M");
      if (id=="A") begin
        #1;
        phase.drop_objection(this);
      end
    endtask
    virtual task reset_phase(uvm_phase phase);
      if (id=="A") phase.raise_objection(this);
      mark(phase,id,"M");
      if (id=="A") begin
        #1;
        phase.drop_objection(this);
      end
    endtask
    virtual task post_reset_phase(uvm_phase phase);
      if (id=="A") phase.raise_objection(this);
      mark(phase,id,"M");
      if (id=="A") begin
        #1;
        phase.drop_objection(this);
      end
    endtask
    virtual task pre_configure_phase(uvm_phase phase);
      if (id=="A") phase.raise_objection(this);
      mark(phase,id,"M");
      if (id=="A") begin
        #1;
        phase.drop_objection(this);
      end
    endtask
    virtual task configure_phase(uvm_phase phase);
      if (id=="A") phase.raise_objection(this);
      mark(phase,id,"M");
      if (id=="A") begin
        #1;
        phase.drop_objection(this);
      end
    endtask
    virtual task post_configure_phase(uvm_phase phase);
      if (id=="A") phase.raise_objection(this);
      mark(phase,id,"M");
      if (id=="A") begin
        #1;
        phase.drop_objection(this);
      end
    endtask
    virtual task pre_main_phase(uvm_phase phase);
      if (id=="A") phase.raise_objection(this);
      mark(phase,id,"M");
      if (id=="A") begin
        #1;
        phase.drop_objection(this);
      end
    endtask
    virtual task main_phase(uvm_phase phase);
      if (id=="A") phase.raise_objection(this);
      mark(phase,id,"M");
      if (id=="A") begin
        #1;
        phase.drop_objection(this);
      end
    endtask
    virtual task post_main_phase(uvm_phase phase);
      if (id=="A") phase.raise_objection(this);
      mark(phase,id,"M");
      if (id=="A") begin
        #1;
        phase.drop_objection(this);
      end
    endtask
    virtual task pre_shutdown_phase(uvm_phase phase);
      if (id=="A") phase.raise_objection(this);
      mark(phase,id,"M");
      if (id=="A") begin
        #1;
        phase.drop_objection(this);
      end
    endtask
    virtual task shutdown_phase(uvm_phase phase);
      if (id=="A") phase.raise_objection(this);
      mark(phase,id,"M");
      if (id=="A") begin
        #1;
        phase.drop_objection(this);
      end
    endtask
    virtual task post_shutdown_phase(uvm_phase phase);
      if (id=="A") phase.raise_objection(this);
      mark(phase,id,"M");
      if (id=="A") begin
        #1;
        runtime_done=1;
        phase.drop_objection(this);
      end
    endtask
  endclass
  initial begin
    // Preconstruct the chain so every node exists before phase_started(build).
    automatic phase_actor a=new("a46",null,"A");
    automatic phase_actor b=new("b",a,"B");
    automatic phase_actor c=new("c",b,"C");
    automatic uvm_coreservice_t service=uvm_coreservice_t::get();
    automatic uvm_root root=service.get_root();
    automatic string ids[3]='{"A","B","C"};
    automatic string phases[12]='{"pre_reset","reset","post_reset","pre_configure",
      "configure","post_configure","pre_main","main",
      "post_main","pre_shutdown","shutdown","post_shutdown"};
    root.set_finish_on_completion(0); run_test();
    foreach (phases[i]) begin
      foreach (ids[j]) begin
        $display("UT: phase_trace %s %s %s",phases[i],ids[j],traces[{phases[i],"/",ids[j]}]);
      end

    end
    $display("UT: runtime_method_sequence %s",phase_order);
    $finish;
  end
  initial begin #100; $fatal(1,"phase observer watchdog"); end
endmodule
