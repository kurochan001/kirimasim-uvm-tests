/*
:name: test_custom_phase_specializations_dispatch_extended_hooks_through_shared_base_views
:description: custom phase specializations delegate extended component hooks through homogeneous base views
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.1.1 9.3.1.5.1 9.7.2.3 9.3.1.6.1 9.3.1.4.4 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_custom_phase_specializations_dispatch_extended_hooks_through_shared_base_views.expected
*/
module test_custom_phase_specializations_dispatch_extended_hooks_through_shared_base_views;
  import uvm_pkg::*;
  uvm_phase wanted;
  class worker extends uvm_component;
    int calls=0;
    bit context_ok=1;
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    virtual function void custom_hook(uvm_phase phase);
      calls++;context_ok &= phase==wanted;
    endfunction
  endclass
  class left_worker extends worker;
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
  endclass
  class right_worker extends worker;
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
  endclass
  class specialized_proxy #(type COMP=worker) extends uvm_topdown_phase;
    typedef specialized_proxy#(COMP) this_type;
    static this_type singleton;
    function new();super.new("specialized54");endfunction
    static function this_type get();
      if (singleton==null) singleton=new();return singleton;
    endfunction
    virtual function void exec_func(uvm_component comp,uvm_phase phase);
      COMP typed;
      if (!$cast(typed,comp)) $fatal(1,"invalid fixture specialization");
      typed.custom_hook(phase);
    endfunction
  endclass
  initial begin
    automatic left_worker left=new("left54",null);
    automatic right_worker right=new("right54",null);
    automatic uvm_phase schedule=new("specialized_schedule54",UVM_PHASE_SCHEDULE);
    uvm_topdown_phase left_proxy,right_proxy;
    uvm_phase left_node,right_node;
    left_proxy=specialized_proxy#(left_worker)::get();
    right_proxy=specialized_proxy#(right_worker)::get();
    schedule.add(left_proxy);schedule.add(right_proxy);
    left_node=schedule.find(left_proxy);right_node=schedule.find(right_proxy);
    wanted=left_node;left_proxy.execute(left,left_node);
    wanted=right_node;right_proxy.execute(right,right_node);
    $display("UT: specialized_proxy left %0d right %0d contexts %0d",
      left.calls==1,right.calls==1,left.context_ok && right.context_ok);
    $display("UT: specialized_proxy singleton %0d separate_types %0d nodes %0d",
      left_proxy==specialized_proxy#(left_worker)::get(),left_proxy!=right_proxy,
      left_node!=null && right_node!=null && left_node!=right_node);
    $finish;
  end
endmodule
