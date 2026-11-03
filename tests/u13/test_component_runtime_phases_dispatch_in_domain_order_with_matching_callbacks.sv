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
