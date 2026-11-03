/*
:name: test_agent_activity_accepts_independent_string_configuration_before_build
:description: agent activity accepts independent string configuration before build
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.4.2.2 C.4.2.3.2 C.4.2.2.1 C.4.2.2.2 F.2.1.7 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_agent_activity_accepts_independent_string_configuration_before_build.expected
*/
module test_agent_activity_accepts_independent_string_configuration_before_build;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class status_agent extends uvm_agent;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
  endclass
  class original_test extends uvm_test;
    `uvm_component_utils(original_test)
    status_agent passive_agent;
    status_agent active_agent;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      uvm_config_db#(string)::set(this,"passive_agent","is_active","UVM_PASSIVE");
      uvm_config_db#(string)::set(this,"active_agent","is_active","UVM_ACTIVE");
      passive_agent=new("passive_agent",this); active_agent=new("active_agent",this);
    endfunction
    virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      $display("UT: string_activity passive %0d active %0d",
               passive_agent.get_is_active()==UVM_PASSIVE,active_agent.get_is_active()==UVM_ACTIVE);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("original_test");
  initial begin #100; $fatal(1,"agent string watchdog"); end
endmodule
