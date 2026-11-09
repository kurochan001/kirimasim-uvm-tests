/*
:name: test_cmdline_singleton_shared_state_1_100
:description: Current singleton accessors share identity and report state across ordinary no-DPI caller views
:tags: uG uvm
:type: simulation
:lrm: 1800.2-2020 G.1.2 G.1.1 1.4.5 5.3.4.4 6.3.4.2 6.3.4.3 1800-2023 6.16 6.16.2 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_cmdline_singleton_shared_state_1_100.expected
*/
// What it checks:
// Current singleton accessors share object identity and mutable report state
// across independent caller functions.
//
// Variant: The two inputs differ only in order. Input 1 swaps which accessor
// fills each view slot and starts the alternating updates from the other slot,
// so each accessor is updated at the opposite steps.
//
// How the expected output follows from the standard:
// 1800.2-2020 G.1.2 (UVM-CMDLINE-SINGLETON-SHARED-STATE-100) gives the rule
// above. Setup: Use imported/qualified accessors under the ordinary no-DPI
// setup, reverse caller order, alternate four explicit report verbosity
// settings, and keep a separate report-object peer. Expected: Accessor views
// retain the same lifetime identity and see each assigned verbosity while the
// independent peer remains unchanged.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_cmdline_singleton_shared_state_1_100;
  import uvm_pkg::*;
  function automatic uvm_cmdline_processor first100();
    return uvm_cmdline_processor::get_inst();
  endfunction
  function automatic uvm_cmdline_processor second100();
    return uvm_pkg::uvm_cmdline_processor::get_inst();
  endfunction
  initial begin
    uvm_cmdline_processor views[2];
    uvm_report_object peer;
    int saved_id,old_verbosity,wanted;
    peer=new("peer100");peer.set_report_verbosity_level(113);
    views[1]=first100();views[0]=second100();
    if(views[0]==null || views[1]==null) $fatal(1,"singleton missing");
    saved_id=views[0].get_inst_id();old_verbosity=views[0].get_report_max_verbosity_level();
    for(int step=0;step<4;step++) begin
      automatic int selected=(step+1)%2;
      wanted=step%2?77:31;views[selected].set_report_verbosity_level(wanted);
      views[1-selected]=second100();
      $display("UT: singleton100 1 step %0d identity %0d state %0d peer %0d",step,
        views[0]==views[1] && views[0].get_inst_id()==saved_id,
        views[0].get_report_max_verbosity_level()==wanted &&
          views[1].get_report_max_verbosity_level()==wanted,
        peer.get_report_max_verbosity_level()==113);
    end
    views[0].set_report_verbosity_level(old_verbosity);$finish;
  end
endmodule
