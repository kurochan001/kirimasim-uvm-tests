/*
:name: test_component_common_phases_dispatch_with_matching_callbacks_and_hierarchy_direction
:description: component common phases dispatch with matching callbacks and hierarchy direction
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.4 13.1.4.1.1 13.1.4.1.2 13.1.4.1.3 13.1.4.1.4 13.1.4.1.5 13.1.4.1.6 13.1.4.1.7 13.1.4.1.8 13.1.4.1.9 13.1.4.3.1 13.1.4.3.3 9.8.1 F.7.3.1 F.7.3.4 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_common_phases_dispatch_with_matching_callbacks_and_hierarchy_direction.expected
*/
// What it checks:
// 1. The common build phase invokes the matching component method between its
//    phase callbacks in the selected hierarchy. Its function traversal is
//    top-down.
// 2. The common connect phase invokes the matching component method between
//    its phase callbacks in the selected hierarchy. Its function traversal is
//    bottom-up.
// 3. The common end_of_elaboration phase invokes the matching component method
//    between its phase callbacks in the selected hierarchy. Its function
//    traversal is bottom-up.
// 4. The common start_of_simulation phase invokes the matching component
//    method between its phase callbacks in the selected hierarchy. Its
//    function traversal is bottom-up.
// 5. The common run phase invokes the matching component method between its
//    phase callbacks in the selected hierarchy.
// 6. The common extract phase invokes the matching component method between
//    its phase callbacks in the selected hierarchy. Its function traversal is
//    bottom-up.
// 7. The common check phase invokes the matching component method between its
//    phase callbacks in the selected hierarchy. Its function traversal is
//    bottom-up.
// 8. The common report phase invokes the matching component method between its
//    phase callbacks in the selected hierarchy. Its function traversal is
//    bottom-up.
// 9. The common final phase invokes the matching component method between its
//    phase callbacks in the selected hierarchy. Its function traversal is
//    top-down.
// 10. The selected common and run-time phase start callbacks identify their
//     phase before its component method.
// 11. The selected common and run-time phase end callbacks identify their
//     phase after its component method.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 13.1.4.1.1 (UVM-COMPONENT-AUDIT-COMMON-BUILD-DISPATCH) gives
//    rule 1 above. Setup: Use the selected original concrete component
//    subtypes, legal unique names, declared public types and linked
//    observations. Construct the hierarchy before phasing where phase
//    callbacks are observed. Expected: The common build phase invokes the
//    matching component method between its phase callbacks in the selected
//    hierarchy. Its function traversal is top-down.
// 2. 1800.2-2020 13.1.4.1.2 (UVM-COMPONENT-AUDIT-COMMON-CONNECT-DISPATCH)
//    gives rule 2 above. Setup: Use the selected original concrete component
//    subtypes, legal unique names, declared public types and linked
//    observations. Construct the hierarchy before phasing where phase
//    callbacks are observed. Expected: The common connect phase invokes the
//    matching component method between its phase callbacks in the selected
//    hierarchy. Its function traversal is bottom-up.
// 3. 1800.2-2020 13.1.4.1.3
//    (UVM-COMPONENT-AUDIT-COMMON-END-OF-ELABORATION-DISPATCH) gives rule 3
//    above. Setup: Use the selected original concrete component subtypes,
//    legal unique names, declared public types and linked observations.
//    Construct the hierarchy before phasing where phase callbacks are
//    observed. Expected: The common end_of_elaboration phase invokes the
//    matching component method between its phase callbacks in the selected
//    hierarchy. Its function traversal is bottom-up.
// 4. 1800.2-2020 13.1.4.1.4
//    (UVM-COMPONENT-AUDIT-COMMON-START-OF-SIMULATION-DISPATCH) gives rule 4
//    above. Setup: Use the selected original concrete component subtypes,
//    legal unique names, declared public types and linked observations.
//    Construct the hierarchy before phasing where phase callbacks are
//    observed. Expected: The common start_of_simulation phase invokes the
//    matching component method between its phase callbacks in the selected
//    hierarchy. Its function traversal is bottom-up.
// 5. 1800.2-2020 13.1.4.1.5 (UVM-COMPONENT-AUDIT-COMMON-RUN-DISPATCH) gives
//    rule 5 above. Setup: Use the selected original concrete component
//    subtypes, legal unique names, declared public types and linked
//    observations. Construct the hierarchy before phasing where phase
//    callbacks are observed. Expected: The common run phase invokes the
//    matching component method between its phase callbacks in the selected
//    hierarchy.
// 6. 1800.2-2020 13.1.4.1.6 (UVM-COMPONENT-AUDIT-COMMON-EXTRACT-DISPATCH)
//    gives rule 6 above. Setup: Use the selected original concrete component
//    subtypes, legal unique names, declared public types and linked
//    observations. Construct the hierarchy before phasing where phase
//    callbacks are observed. Expected: The common extract phase invokes the
//    matching component method between its phase callbacks in the selected
//    hierarchy. Its function traversal is bottom-up.
// 7. 1800.2-2020 13.1.4.1.7 (UVM-COMPONENT-AUDIT-COMMON-CHECK-DISPATCH) gives
//    rule 7 above. Setup: Use the selected original concrete component
//    subtypes, legal unique names, declared public types and linked
//    observations. Construct the hierarchy before phasing where phase
//    callbacks are observed. Expected: The common check phase invokes the
//    matching component method between its phase callbacks in the selected
//    hierarchy. Its function traversal is bottom-up.
// 8. 1800.2-2020 13.1.4.1.8 (UVM-COMPONENT-AUDIT-COMMON-REPORT-DISPATCH) gives
//    rule 8 above. Setup: Use the selected original concrete component
//    subtypes, legal unique names, declared public types and linked
//    observations. Construct the hierarchy before phasing where phase
//    callbacks are observed. Expected: The common report phase invokes the
//    matching component method between its phase callbacks in the selected
//    hierarchy. Its function traversal is bottom-up.
// 9. 1800.2-2020 13.1.4.1.9 (UVM-COMPONENT-AUDIT-COMMON-FINAL-DISPATCH) gives
//    rule 9 above. Setup: Use the selected original concrete component
//    subtypes, legal unique names, declared public types and linked
//    observations. Construct the hierarchy before phasing where phase
//    callbacks are observed. Expected: The common final phase invokes the
//    matching component method between its phase callbacks in the selected
//    hierarchy. Its function traversal is top-down.
// 10. 1800.2-2020 13.1.4.3.1 (UVM-COMPONENT-AUDIT-PHASE-START-CALLBACK) gives
//     rule 10 above. Setup: Use the selected original concrete component
//     subtypes, legal unique names, declared public types and linked
//     observations. Construct the hierarchy before phasing where phase
//     callbacks are observed. Expected: The selected common and run-time phase
//     start callbacks identify their phase before its component method.
// 11. 1800.2-2020 13.1.4.3.3 (UVM-COMPONENT-AUDIT-PHASE-END-CALLBACK) gives
//     rule 11 above. Setup: Use the selected original concrete component
//     subtypes, legal unique names, declared public types and linked
//     observations. Construct the hierarchy before phasing where phase
//     callbacks are observed. Expected: The selected common and run-time phase
//     end callbacks identify their phase after its component method.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_component_common_phases_dispatch_with_matching_callbacks_and_hierarchy_direction;
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
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase); mark(phase,id,"M");
      if ($time!=0) $fatal(1,"pre-run phase advanced time");
    endfunction
    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase); mark(phase,id,"M");
      if ($time!=0) $fatal(1,"pre-run phase advanced time");
    endfunction
    virtual function void end_of_elaboration_phase(uvm_phase phase);
      super.end_of_elaboration_phase(phase); mark(phase,id,"M");
      if ($time!=0) $fatal(1,"pre-run phase advanced time");
    endfunction
    virtual function void start_of_simulation_phase(uvm_phase phase);
      super.start_of_simulation_phase(phase); mark(phase,id,"M");
      if ($time!=0) $fatal(1,"pre-run phase advanced time");
    endfunction
    virtual task run_phase(uvm_phase phase);
      if (id=="A") phase.raise_objection(this);
      mark(phase,id,"M");
      if (id=="A") begin #2; phase.drop_objection(this); end
    endtask
    virtual function void extract_phase(uvm_phase phase);
      super.extract_phase(phase); mark(phase,id,"M");
    endfunction
    virtual function void check_phase(uvm_phase phase);
      super.check_phase(phase); mark(phase,id,"M");
    endfunction
    virtual function void report_phase(uvm_phase phase);
      super.report_phase(phase); mark(phase,id,"M");
    endfunction
    virtual function void final_phase(uvm_phase phase);
      super.final_phase(phase); mark(phase,id,"M");
    endfunction
  endclass
  initial begin
    // Preconstruct the chain so every node exists before phase_started(build).
    automatic phase_actor a=new("a46",null,"A");
    automatic phase_actor b=new("b",a,"B");
    automatic phase_actor c=new("c",b,"C");
    automatic uvm_coreservice_t service=uvm_coreservice_t::get();
    automatic uvm_root root=service.get_root();
    automatic string ids[3]='{"A","B","C"};
    automatic string phases[9]='{"build","connect","end_of_elaboration","start_of_simulation",
      "run","extract","check","report","final"};
    root.set_finish_on_completion(0); run_test();
    foreach (phases[i]) begin
      foreach (ids[j]) begin
        $display("UT: phase_trace %s %s %s",phases[i],ids[j],traces[{phases[i],"/",ids[j]}]);
      end
      if (phases[i]!="run")
        $display("UT: common_method_order %s %s",phases[i],method_order[phases[i]]);
    end

    $finish;
  end
  initial begin #100; $fatal(1,"phase observer watchdog"); end
endmodule
