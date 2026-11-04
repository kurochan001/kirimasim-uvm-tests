/*
:name: test_phase_get_imp_prose_resolves_each_node_to_its_shared_singleton_implementation
:description: phase get imp prose resolves each node to its shared singleton implementation
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.6.7 9.3.1.1.1 9.3.1.1.2 9.3.1.4.4 9.3.1.6.1 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_phase_get_imp_prose_resolves_each_node_to_its_shared_singleton_implementation.expected
*/
// Keep the node-implementation prose and non-IMP-null sentence distinct.
module test_phase_get_imp_prose_resolves_each_node_to_its_shared_singleton_implementation;
  import uvm_pkg::*;
  class task_imp extends uvm_task_phase;
    static task_imp singleton;
    function new(string name="singleton53");super.new(name);endfunction
    static function task_imp get();
      if (singleton==null) singleton=new();return singleton;
    endfunction
    virtual task exec_task(uvm_component comp,uvm_phase phase);endtask
  endclass

  initial begin
    automatic task_imp imp=task_imp::get();
    automatic uvm_phase left=new("left53",UVM_PHASE_SCHEDULE);
    automatic uvm_phase right=new("right53",UVM_PHASE_SCHEDULE);
    uvm_phase first,second;
    left.add(imp);right.add(imp);first=left.find(imp);second=right.find(imp);
    if (first==null || second==null) $fatal(1,"missing implementation nodes");
    $display("UT: phase_imp_prose left %0d right %0d distinct_nodes %0d same_singleton %0d",
      first.get_imp()==imp,second.get_imp()==imp,first!=second,imp==task_imp::get());
    $finish;
  end
endmodule
