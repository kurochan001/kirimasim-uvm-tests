/*
:name: test_domain_add_uvm_phases_appends_runtime_nodes_after_selected_existing_content
:description: domain add uvm phases appends runtime nodes after selected existing content
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.4.2.3 9.3.1.6.1 9.3.1.4.4 9.3.1.4.6 9.8.2.1 9.8.2.2 9.8.2.3 9.8.2.4 9.8.2.5 9.8.2.6 9.8.2.7 9.8.2.8 9.8.2.9 9.8.2.10 9.8.2.11 9.8.2.12 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_domain_add_uvm_phases_appends_runtime_nodes_after_selected_existing_content.expected
*/
// What it checks:
// 1. add_uvm_phases appends the selected built-in runtime phases.
// 2. Appending preserves the selected existing prefix before the runtime
//    order.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 9.4.2.3 (UVM-PHASE-CONTRACT-DOMAIN-APPEND-NODES) gives rule 1
//    above. Setup: A schedule already containing one custom phase receives the
//    built-in runtime phase set. Expected: All twelve runtime nodes are found
//    and the custom node remains.
// 2. 1800.2-2020 9.4.2.3 (UVM-PHASE-CONTRACT-DOMAIN-APPEND-ORDER) gives rule 2
//    above. Setup: A schedule already containing one custom phase receives the
//    built-in runtime phase set. Expected: The custom node precedes pre_reset
//    and the twelve runtime nodes remain ordered.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Selected runtime subset only; extra common-phase applicability remains open.
module test_domain_add_uvm_phases_appends_runtime_nodes_after_selected_existing_content;
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
    automatic uvm_phase schedule=new("append53",UVM_PHASE_SCHEDULE);
    automatic task_imp existing=task_imp::get();
    uvm_phase imps[12],nodes[12],prior;
    bit present,ordered;
    schedule.add(existing);prior=schedule.find(existing);
    imps[0]=uvm_pre_reset_phase::get();
    imps[1]=uvm_reset_phase::get();
    imps[2]=uvm_post_reset_phase::get();
    imps[3]=uvm_pre_configure_phase::get();
    imps[4]=uvm_configure_phase::get();
    imps[5]=uvm_post_configure_phase::get();
    imps[6]=uvm_pre_main_phase::get();
    imps[7]=uvm_main_phase::get();
    imps[8]=uvm_post_main_phase::get();
    imps[9]=uvm_pre_shutdown_phase::get();
    imps[10]=uvm_shutdown_phase::get();
    imps[11]=uvm_post_shutdown_phase::get();
    uvm_domain::add_uvm_phases(schedule);present=1;ordered=1;
    foreach (imps[i]) begin
      nodes[i]=schedule.find(imps[i]);present &= nodes[i]!=null;
      if (nodes[i]!=null) begin
        ordered &= prior.is_before(nodes[i]);prior=nodes[i];
      end
    end
    $display("UT: domain_append runtime_nodes %0d runtime_order %0d existing_kept %0d",
      present,ordered,schedule.find(existing)!=null);
    $finish;
  end
endmodule
