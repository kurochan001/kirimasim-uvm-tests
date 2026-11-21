/*
:name: test_rtl_parameterized_agents_get_their_own_virtual_interface_136
:description: parameterized agents of two widths each get the virtual interface of their own parameterized type from the configuration database and drive their own RTL register (IEEE 1800.2-2020 Section C.4.2.2.2)
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.2.2 C.4.2.2.1 C.4.2.1 B.2.1.2 B.2.1.3 13.3 13.4 13.5 13.7 13.9 15.5 12.2.10.1 14.2.3.1 14.2.6.2 14.2.6.3 15.2.1.2.1 15.2.1.2.3 5.3.4.5 5.3.4.6 8.2.3.2.4 8.2.4.2.4 1800-2023 6.21 8.25 14.4 14.13 14.16 25.9 23.3.3.4
:uvm: 2020.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +UVM_TESTNAME=t
:expected_exit: 0
:expected_stdout: @test_rtl_parameterized_agents_get_their_own_virtual_interface_136.expected
:files: helpers136_rtl/px_rtl136.sv
*/
// What it checks:
// 1. A virtual interface of a parameterized interface is stored in and read
//    from the configuration database under its own type: an agent of one
//    width gets its interface, and a request for the other width's type at
//    the same scope finds nothing.
// 2. Parameterized items, sequences, drivers, monitors, agents and
//    subscribers of two widths work side by side, and the two item
//    specializations have their own factory proxies.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 C.4.2.2.2 (UVM-RTL-PARAM-VIF-CONFIG-TYPE) gives rule 1 with
//    C.4.2.2.1 and C.4.2.1: uvm_config_db#(T) reads the settings of its own
//    type T. Setup: set a virtual px_if136#(8) for the scope of the narrow
//    agent and a virtual px_if136#(12) for that of the wide agent. Expected:
//    both drivers get their interface, and a get of the 12-bit type at the
//    scope of the narrow driver returns 0. C.4.2.2.2 does not print what the
//    returned bit means for a setting of another type; that such a setting
//    is not found follows from C.4.2.1, which makes T the type of the
//    configuration that the class reads and writes.
// 2. 1800.2-2020 B.2.1.3 (UVM-RTL-PARAM-AGENT-SIDE-BY-SIDE) gives rule 2 with
//    B.2.1.2, 13.7, 13.5, 13.4, 13.9 and 15.5. Setup: each agent runs a
//    sequence that writes all ones and reads the register back, in parallel.
//    By the rules of the design in px_rtl136.sv the reads give 'hff and
//    'hfff. Expected: each subscriber receives the two transactions of its
//    own bus with a data width of 8 or 12 bits, the proxies of the two item
//    specializations differ, and each read item's get_object_type is the
//    proxy of its own specialization.
// These expectations come from the cited clauses and from the rules of the
// test's own design, not from the output of a simulator.
// The components are created through type_id of each specialization; the
// type name of a parameterized class is not observed.
module test_rtl_parameterized_agents_get_their_own_virtual_interface_136;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  logic clk = 1'b0;
  always #5 clk = ~clk;
  px_if136 #(8) bus_narrow(clk);
  px_if136 #(12) bus_wide(clk);
  px_dut136 #(8) dut_narrow(bus_narrow);
  px_dut136 #(12) dut_wide(bus_wide);

  class px_item #(int W = 8) extends uvm_sequence_item;
    `uvm_object_param_utils(px_item#(W))
    bit write;
    bit [W-1:0] data;

    function new(string name = "px_item");
      super.new(name);
    endfunction
  endclass

  class px_driver #(int W = 8) extends uvm_driver #(px_item#(W));
    `uvm_component_param_utils(px_driver#(W))
    virtual px_if136 #(W) vif;
    bit got_vif;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      got_vif = uvm_config_db #(virtual px_if136 #(W))::get(this, "", "vif", vif);
      if (!got_vif) `uvm_fatal("RTL136", "driver has no virtual interface")
    endfunction

    // A write occupies one clock and a read two.
    task run_phase(uvm_phase phase);
      px_item#(W) req;
      do @(vif.drv_cb);
      while (!vif.drv_cb.rst_n);
      forever begin
        seq_item_port.get_next_item(req);
        @(vif.drv_cb);
        vif.drv_cb.sel <= 1'b1;
        vif.drv_cb.write <= req.write;
        vif.drv_cb.wdata <= req.write ? req.data : '0;
        @(vif.drv_cb);
        vif.drv_cb.sel <= 1'b0;
        if (!req.write) begin
          @(vif.drv_cb);
          req.data = vif.drv_cb.rdata;
        end
        seq_item_port.item_done();
      end
    endtask
  endclass

  class px_monitor #(int W = 8) extends uvm_monitor;
    `uvm_component_param_utils(px_monitor#(W))
    virtual px_if136 #(W) vif;
    uvm_analysis_port #(px_item#(W)) ap;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      ap = new("ap", this);
      if (!uvm_config_db #(virtual px_if136 #(W))::get(this, "", "vif", vif))
        `uvm_fatal("RTL136", "monitor has no virtual interface")
    endfunction

    task run_phase(uvm_phase phase);
      px_item#(W) tr;
      forever begin
        @(vif.mon_cb);
        if (vif.mon_cb.rst_n && vif.mon_cb.sel) begin
          tr = px_item#(W)::type_id::create("observed");
          tr.write = vif.mon_cb.write;
          if (tr.write) begin
            tr.data = vif.mon_cb.wdata;
          end else begin
            @(vif.mon_cb);
            tr.data = vif.mon_cb.rdata;
          end
          ap.write(tr);
        end
      end
    endtask
  endclass

  class px_agent #(int W = 8) extends uvm_agent;
    `uvm_component_param_utils(px_agent#(W))
    uvm_sequencer #(px_item#(W)) sqr;
    px_driver#(W) drv;
    px_monitor#(W) mon;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sqr = new("sqr", this);
      drv = px_driver#(W)::type_id::create("drv", this);
      mon = px_monitor#(W)::type_id::create("mon", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
  endclass

  class px_collector #(int W = 8) extends uvm_subscriber #(px_item#(W));
    `uvm_component_param_utils(px_collector#(W))
    int unsigned seen;
    int unsigned data_bits;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void write(px_item#(W) t);
      seen++;
      data_bits = $bits(t.data);
    endfunction
  endclass

  class px_seq #(int W = 8) extends uvm_sequence #(px_item#(W));
    `uvm_object_param_utils(px_seq#(W))
    px_item#(W) read_item;

    function new(string name = "px_seq");
      super.new(name);
    endfunction

    task body();
      px_item#(W) write_item = px_item#(W)::type_id::create("write_item");
      read_item = px_item#(W)::type_id::create("read_item");
      write_item.write = 1'b1;
      write_item.data = '1;
      start_item(write_item);
      finish_item(write_item);
      start_item(read_item);
      finish_item(read_item);
    endtask
  endclass

  class px_env extends uvm_env;
    `uvm_component_utils(px_env)
    px_agent#(8) narrow;
    px_agent#(12) wide;
    px_collector#(8) narrow_seen;
    px_collector#(12) wide_seen;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      narrow = px_agent#(8)::type_id::create("narrow", this);
      wide = px_agent#(12)::type_id::create("wide", this);
      narrow_seen = px_collector#(8)::type_id::create("narrow_seen", this);
      wide_seen = px_collector#(12)::type_id::create("wide_seen", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      narrow.mon.ap.connect(narrow_seen.analysis_export);
      wide.mon.ap.connect(wide_seen.analysis_export);
    endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    px_env env;
    px_seq#(8) narrow_seq;
    px_seq#(12) wide_seq;
    bit crossed;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = px_env::type_id::create("env", this);
      narrow_seq = px_seq#(8)::type_id::create("narrow_seq");
      wide_seq = px_seq#(12)::type_id::create("wide_seq");
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
      virtual px_if136 #(12) probe;
      crossed = uvm_config_db #(virtual px_if136 #(12))::get(env.narrow.drv, "", "vif", probe);
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      fork
        narrow_seq.start(env.narrow.sqr);
        wide_seq.start(env.wide.sqr);
      join
      repeat (4) @(posedge clk);
      phase.drop_objection(this);
    endtask

    function void check_phase(uvm_phase phase);
      uvm_object_wrapper narrow_proxy = px_item#(8)::get_type();
      uvm_object_wrapper wide_proxy = px_item#(12)::get_type();
      $display("UT: vif own %0d %0d crossed %0d", env.narrow.drv.got_vif, env.wide.drv.got_vif,
               crossed);
      $display("UT: reads %0h %0h", narrow_seq.read_item.data, wide_seq.read_item.data);
      $display("UT: subscribers %0d %0d data_bits %0d %0d", env.narrow_seen.seen,
               env.wide_seen.seen, env.narrow_seen.data_bits, env.wide_seen.data_bits);
      $display("UT: item proxies differ %0d own %0d %0d", narrow_proxy != wide_proxy,
               narrow_seq.read_item.get_object_type() == narrow_proxy,
               wide_seq.read_item.get_object_type() == wide_proxy);
    endfunction
  endclass

  initial begin
    uvm_config_db #(virtual px_if136 #(8))::set(null, "uvm_test_top.env.narrow*", "vif",
                                                bus_narrow);
    uvm_config_db #(virtual px_if136 #(12))::set(null, "uvm_test_top.env.wide*", "vif",
                                                 bus_wide);
    run_test();
  end

  initial begin
    repeat (2) @(posedge clk);
    bus_narrow.rst_n <= 1'b1;
    bus_wide.rst_n <= 1'b1;
  end
endmodule
