/*
:name: test_rtl_active_and_passive_agents_share_a_bus_under_a_virtual_sequence_134
:description: two active agents and a passive agent on RTL register files run under a virtual sequence with p_sequencer, and a scoreboard with two analysis imps pairs the two monitors of one bus (IEEE 1800.2-2020 Section 13.4.2.2)
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.4.2.2 13.4 13.3 13.5 13.6 13.7 F.2.1.7 14.2.3.1 14.2.3.6 14.1.2.5 14.1.2.7 B.3.3 15.5 B.5.22 12.2.10.1 12.2.10.2 14.2.6.2 14.2.6.3 15.2.1.2.1 15.2.1.2.3 C.4.2.2.1 C.4.2.2.2 1800-2023 6.21 14.4 14.13 14.16 25.9 9.3.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +UVM_TESTNAME=t
:expected_exit: 0
:expected_stdout: @test_rtl_active_and_passive_agents_share_a_bus_under_a_virtual_sequence_134.expected
:files: ../u19/helpers116_rtl/rf_rtl116.sv ../u19/helpers116_rtl/rf_env116.svh
*/
// What it checks:
// 1. An agent reports through get_is_active whether it is active, and a
//    passive agent is built with a monitor only.
// 2. A virtual sequence started on a virtual sequencer runs one child sequence
//    on each of two bus sequencers, reached through p_sequencer, and each
//    child is a child of the virtual sequence on the sequencer it was given.
// 3. A scoreboard with two analysis imps receives every bus transaction from
//    the monitor of the active agent and from that of the passive agent.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 13.4.2.2 (UVM-RTL-AGENT-ACTIVE-PASSIVE) gives rule 1 with
//    F.2.1.7. Setup: the agent of this test overrides get_is_active from its
//    own setting and creates its driver and sequencer only when it returns
//    UVM_ACTIVE. Expected: the two driving agents return UVM_ACTIVE, the third
//    returns UVM_PASSIVE and has neither a driver nor a sequencer. The
//    standard does not say how an agent learns its setting, so this line
//    shows the shape of the testbench: it reads back the test's own override
//    and does not exercise the library's uvm_agent.
// 2. 1800.2-2020 14.2.3.1 (UVM-RTL-VIRTUAL-SEQUENCE-CHILDREN) gives rule 2
//    with B.3.3, 14.1.2.5 and 14.1.2.7. Setup: the virtual sequence casts its
//    sequencer into the p_sequencer that `uvm_declare_p_sequencer declares
//    and starts both children with itself as the parent, in parallel.
//    Expected: each child returns the virtual sequence from
//    get_parent_sequence and its own bus sequencer from get_sequencer. Bus A
//    writes 'h11 to CTRL and 'h22 to DATA and reads CTRL, COUNT and ID; by the
//    rules of the design in rf_rtl116.sv the reads give 'h11, 2 accepted
//    writes and the constant 'ha5. Bus B writes 'h33 to DATA and reads DATA,
//    CTRL and COUNT, which give 'h33, the reset value 0 and 1.
// 3. 1800.2-2020 B.5.22 (UVM-RTL-IMP-DECL-SCOREBOARD) gives rule 3 with
//    12.2.10.1 and 12.2.10.2. Setup: both monitors of bus A sample the same
//    clocking block and write to the imps declared with
//    `uvm_analysis_imp_decl. Expected: each imp receives the 5 transactions
//    of bus A, and the 5 pairs agree in direction, address, data and cycle.
//    B.5.22 calls the implementation "the write function" and does not
//    print its name; write followed by the suffix is the name that the
//    pinned library's macro calls, and the test would not compile otherwise.
// These expectations come from the cited clauses and from the rules of the
// test's own design, not from the output of a simulator.
// The two histories are compared by position after the run, so the order in
// which the two monitors write within one time step does not matter.
module test_rtl_active_and_passive_agents_share_a_bus_under_a_virtual_sequence_134;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "rf_env116.svh"

  logic clk = 1'b0;
  always #5 clk = ~clk;
  rf_if116 bus_a(clk);
  rf_if116 bus_b(clk);
  rf_dut116 dut_a(bus_a);
  rf_dut116 dut_b(bus_b);

  class bus_agent extends uvm_agent;
    `uvm_component_utils(bus_agent)
    bit passive;
    uvm_sequencer #(rf_item116) sqr;
    rf_driver116 drv;
    rf_monitor116 mon;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    virtual function uvm_active_passive_enum get_is_active();
      return passive ? UVM_PASSIVE : UVM_ACTIVE;
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      mon = rf_monitor116::type_id::create("mon", this);
      if (get_is_active() == UVM_ACTIVE) begin
        sqr = new("sqr", this);
        drv = rf_driver116::type_id::create("drv", this);
      end
    endfunction

    function void connect_phase(uvm_phase phase);
      if (get_is_active() == UVM_ACTIVE) drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
  endclass

  class virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(virtual_sequencer)
    uvm_sequencer #(rf_item116) sqr_a;
    uvm_sequencer #(rf_item116) sqr_b;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass

  `uvm_analysis_imp_decl(_active)
  `uvm_analysis_imp_decl(_passive)

  class pair_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(pair_scoreboard)
    uvm_analysis_imp_active #(rf_item116, pair_scoreboard) active_export;
    uvm_analysis_imp_passive #(rf_item116, pair_scoreboard) passive_export;
    rf_item116 from_active[$];
    rf_item116 from_passive[$];

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      active_export = new("active_export", this);
      passive_export = new("passive_export", this);
    endfunction

    function void write_active(rf_item116 t);
      from_active.push_back(t);
    endfunction

    function void write_passive(rf_item116 t);
      from_passive.push_back(t);
    endfunction

    function int unsigned paired();
      int unsigned count;
      foreach (from_active[i]) begin
        if (i < from_passive.size() && from_active[i].write == from_passive[i].write
            && from_active[i].addr == from_passive[i].addr
            && from_active[i].data == from_passive[i].data
            && from_active[i].seen_cycle == from_passive[i].seen_cycle) count++;
      end
      return count;
    endfunction
  endclass

  class bus_env extends uvm_env;
    `uvm_component_utils(bus_env)
    bus_agent agent_a;
    bus_agent agent_b;
    bus_agent agent_p;
    virtual_sequencer vsqr;
    pair_scoreboard sb;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      agent_a = bus_agent::type_id::create("agent_a", this);
      agent_b = bus_agent::type_id::create("agent_b", this);
      agent_p = bus_agent::type_id::create("agent_p", this);
      agent_p.passive = 1;
      vsqr = virtual_sequencer::type_id::create("vsqr", this);
      sb = pair_scoreboard::type_id::create("sb", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      vsqr.sqr_a = agent_a.sqr;
      vsqr.sqr_b = agent_b.sqr;
      agent_a.mon.ap.connect(sb.active_export);
      agent_p.mon.ap.connect(sb.passive_export);
    endfunction
  endclass

  class both_buses_seq extends uvm_sequence;
    `uvm_object_utils(both_buses_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)
    rf_seq116 seq_a;
    rf_seq116 seq_b;

    function new(string name = "both_buses_seq");
      super.new(name);
    endfunction

    task body();
      if (!$cast(p_sequencer, get_sequencer())) `uvm_fatal("RTL134", "not the virtual sequencer")
      fork
        seq_a.start(p_sequencer.sqr_a, this);
        seq_b.start(p_sequencer.sqr_b, this);
      join
    endtask
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    bus_env env;
    both_buses_seq vseq;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = bus_env::type_id::create("env", this);
      vseq = both_buses_seq::type_id::create("vseq");
      vseq.seq_a = rf_seq116::type_id::create("seq_a");
      vseq.seq_b = rf_seq116::type_id::create("seq_b");
      vseq.seq_a.add116(1, 0, 8'h11);
      vseq.seq_a.add116(1, 1, 8'h22);
      vseq.seq_a.add116(0, 0, 8'h00);
      vseq.seq_a.add116(0, 2, 8'h00);
      vseq.seq_a.add116(0, 3, 8'h00);
      vseq.seq_b.add116(1, 1, 8'h33);
      vseq.seq_b.add116(0, 1, 8'h00);
      vseq.seq_b.add116(0, 0, 8'h00);
      vseq.seq_b.add116(0, 2, 8'h00);
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      vseq.start(env.vsqr);
      repeat (4) @(posedge clk);
      phase.drop_objection(this);
    endtask

    function void check_phase(uvm_phase phase);
      $display("UT: agents active %0d %0d passive %0d passive_driver %0d passive_sequencer %0d",
               env.agent_a.get_is_active() == UVM_ACTIVE,
               env.agent_b.get_is_active() == UVM_ACTIVE,
               env.agent_p.get_is_active() == UVM_PASSIVE, env.agent_p.drv != null,
               env.agent_p.sqr != null);
      $display("UT: children parent %0d %0d sequencer %0d %0d",
               vseq.seq_a.get_parent_sequence() == vseq,
               vseq.seq_b.get_parent_sequence() == vseq,
               vseq.seq_a.get_sequencer() == env.agent_a.sqr,
               vseq.seq_b.get_sequencer() == env.agent_b.sqr);
      $display("UT: bus_a reads %0h %0h %0h bus_b reads %0h %0h %0h", vseq.seq_a.ops[2].data,
               vseq.seq_a.ops[3].data, vseq.seq_a.ops[4].data, vseq.seq_b.ops[1].data,
               vseq.seq_b.ops[2].data, vseq.seq_b.ops[3].data);
      $display("UT: scoreboard active %0d passive %0d paired %0d", env.sb.from_active.size(),
               env.sb.from_passive.size(), env.sb.paired());
    endfunction
  endclass

  initial begin
    uvm_config_db #(virtual rf_if116)::set(null, "uvm_test_top.env.agent_a*", "vif", bus_a);
    uvm_config_db #(virtual rf_if116)::set(null, "uvm_test_top.env.agent_p*", "vif", bus_a);
    uvm_config_db #(virtual rf_if116)::set(null, "uvm_test_top.env.agent_b*", "vif", bus_b);
    run_test();
  end

  initial begin
    repeat (2) @(posedge clk);
    bus_a.rst_n <= 1'b1;
    bus_b.rst_n <= 1'b1;
  end
endmodule
