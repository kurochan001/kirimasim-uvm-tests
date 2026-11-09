/*
:name: test_sequencer_zero_time_relevance_default_limit
:description: Zero-time irrelevant callbacks exercise sequencer zero time relevance default limit
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.2.21 14.2.5.3 14.2.5.4 15.2.1.2.1 14.2.6.2 6.6.3.2 6.6.5 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_zero_time_relevance_default_limit.expected
*/
// What it checks:
// The omitted zero-time relevance maximum is ten.
//
// How the expected output follows from the standard:
// 1800.2-2020 15.3.2.21 (UVM-SEQUENCER-AUDIT-ZERO-TIME-DEFAULT) gives the rule
// above. Setup: No setter is called; one always-irrelevant sequence returns
// from wait_for_relevant without advancing time at time zero. Expected: The
// error is observed at the selected boundary in the same simulation time,
// without fallback, grant or driver receipt; the original override count
// matches the call route.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The maximum bounds completed zero-time relevance callbacks. Notification at
// the limit or first excess is accepted; no exact report ID/text is assumed.
// A stopped/fallback callback blocks, allowing the positive-time owner to run.
// No post-error recovery, counter reset, or negative-limit meaning is asserted.
module test_sequencer_zero_time_relevance_default_limit;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    function new(string name="packet"); super.new(name); endfunction
  endclass
  class observation extends uvm_object;
    int calls=0, diagnostic_calls=0;
    int limit=10;
    bit halted=0, fallback=0, diagnostic=0, gated=0;
    time first_time=0, diagnostic_time=0;
    function new(); super.new("observation"); endfunction
  endclass
  class reports extends uvm_report_catcher;
    observation state;
    function new(observation value); super.new("reports"); state=value; endfunction
    virtual function action_e catch();
      if (state.gated && (get_severity()==UVM_ERROR || get_severity()==UVM_FATAL)) begin
        if (!state.diagnostic) begin
          state.diagnostic=1; state.diagnostic_calls=state.calls;
          state.diagnostic_time=$time;
        end
        state.halted=1;
        return CAUGHT;
      end
      return THROW;
    endfunction
  endclass
  class waiting_sequence extends uvm_sequence#(packet);
    observation state;
    bit granted=0;
    function new(observation value); super.new("waiting_sequence"); state=value; endfunction
    virtual function bit is_relevant(); return 0; endfunction
    virtual task wait_for_relevant();
      if (state.halted) wait (0);
      state.calls++;
      if (state.calls==1) state.first_time=$time;
      if (state.calls>state.limit+3) begin
        state.fallback=1; state.halted=1;
        wait (0);
      end
    endtask
    virtual task body();
      packet request;
      request=new("request"); start_item(request); granted=1; finish_item(request);
    endtask
  endclass
  class selected_sequencer extends uvm_sequencer#(packet);
    int dispatches=0;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    virtual function void set_max_zero_time_wait_relevant_count(int new_val);
      dispatches++;
      super.set_max_zero_time_wait_relevant_count(new_val);
    endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    selected_sequencer sequencer;
    uvm_driver#(packet) driver;
    waiting_sequence worker;
    observation state;
    reports catcher;
    bit received=0;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer=new("sequencer",this); driver=new("driver",this);
      state=new(); worker=new(state); catcher=new(state);
      sequencer.disable_auto_item_recording();
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    virtual task run_phase(uvm_phase phase);
      packet request;
      uvm_sequencer_base view;
      phase.raise_objection(this);

      view=sequencer;

      uvm_report_cb::add(null,catcher); state.gated=1;
      fork
        worker.start(sequencer);
        begin driver.seq_item_port.get_next_item(request); received=1; end
      join_none
      #1;
      state.gated=0;
      $display("DETAIL: relevance calls %0d diagnostic_calls %0d first %0t report %0t",
        state.calls,state.diagnostic_calls,state.first_time,state.diagnostic_time);
      $display("UT: zero_time error %0d bounded %0d same_time %0d fallback %0d",
        state.diagnostic,
        state.diagnostic_calls>=state.limit && state.diagnostic_calls<=state.limit+1,
        state.diagnostic && state.diagnostic_time==state.first_time,state.fallback);
      $display("UT: irrelevant not_granted %0d not_received %0d",
        !worker.granted,!received);
      $display("UT: setter dispatch %0d",sequencer.dispatches==0);
      disable fork;
      sequencer.stop_sequences(); uvm_report_cb::delete(null,catcher);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #80; $fatal(1,"relevance guard watchdog expired"); end
endmodule
