/*
:name: test_phase_get_imp_literal_non_imp_null_rule_remains_separate_from_the_node_prose
:description: phase get imp literal non imp null rule remains separate from the node prose
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.6.7 9.3.1.1.1 9.3.1.1.2 9.3.1.4.4 9.3.1.6.1 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_phase_get_imp_literal_non_imp_null_rule_remains_separate_from_the_node_prose.expected
*/
// What it checks:
// Under the literal final sentence, a non-IMP phase returns null.
//
// How the expected output follows from the standard:
// 1800.2-2020 9.3.1.6.7 (UVM-PHASE-CONTRACT-GET-IMP-LITERAL-NULL) gives the
// rule above. Setup: A NODE is explicitly tested against the last sentence of
// get_imp, separately from its node-resolution prose. Expected: The explicit
// NODE satisfies non_imp_null.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Keep the node-implementation prose and non-IMP-null sentence distinct.
module test_phase_get_imp_literal_non_imp_null_rule_remains_separate_from_the_node_prose;
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
    $display("UT: phase_imp_literal node_type %0d non_imp_null %0d",
      first.get_phase_type()==UVM_PHASE_NODE,first.get_imp()==null);
    $finish;
  end
endmodule
