// Original UVM environment for the 116th RTL integration profiles.
// The driver and monitor reach the design only through the clocking blocks
// of the virtual interface that the test top places in the configuration
// database. A register model with an original adapter, an optional explicit
// predictor, a collector and an analysis-FIFO scoreboard share the monitor.

class rf_item116 extends uvm_sequence_item;
  `uvm_object_utils(rf_item116)
  bit write;
  bit [1:0] addr;
  bit [7:0] data;
  // Sampled cycle stamps. Zero means not recorded; reset lasts two edges.
  int unsigned drive_cycle;
  int unsigned done_cycle;
  int unsigned seen_cycle;

  function new(string name = "rf_item116");
    super.new(name);
  endfunction
endclass

class rf_driver116 extends uvm_driver #(rf_item116);
  `uvm_component_utils(rf_driver116)
  virtual rf_if116 vif;
  bit got_vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    got_vif = uvm_config_db #(virtual rf_if116)::get(this, "", "vif", vif);
    if (!got_vif) `uvm_fatal("RF116", "driver has no virtual interface")
  endfunction

  // A write occupies one clock and a read two; the read data is sampled on
  // the clock after the design registers it.
  task run_phase(uvm_phase phase);
    rf_item116 req;
    do @(vif.drv_cb);
    while (!vif.drv_cb.rst_n);
    forever begin
      seq_item_port.get_next_item(req);
      @(vif.drv_cb);
      req.drive_cycle = vif.drv_cb.cycle;
      vif.drv_cb.sel <= 1'b1;
      vif.drv_cb.write <= req.write;
      vif.drv_cb.addr <= req.addr;
      vif.drv_cb.wdata <= req.write ? req.data : 8'h00;
      @(vif.drv_cb);
      vif.drv_cb.sel <= 1'b0;
      if (!req.write) begin
        @(vif.drv_cb);
        req.data = vif.drv_cb.rdata;
      end
      req.done_cycle = vif.drv_cb.cycle;
      seq_item_port.item_done();
    end
  endtask
endclass

class rf_monitor116 extends uvm_monitor;
  `uvm_component_utils(rf_monitor116)
  virtual rf_if116 vif;
  bit got_vif;
  uvm_analysis_port #(rf_item116) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    got_vif = uvm_config_db #(virtual rf_if116)::get(this, "", "vif", vif);
    if (!got_vif) `uvm_fatal("RF116", "monitor has no virtual interface")
  endfunction

  task run_phase(uvm_phase phase);
    rf_item116 tr;
    forever begin
      @(vif.mon_cb);
      if (vif.mon_cb.rst_n && vif.mon_cb.sel) begin
        tr = rf_item116::type_id::create("observed116");
        tr.write = vif.mon_cb.write;
        tr.addr = vif.mon_cb.addr;
        tr.seen_cycle = vif.mon_cb.cycle;
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

class rf_agent116 extends uvm_agent;
  `uvm_component_utils(rf_agent116)
  uvm_sequencer #(rf_item116) sqr;
  rf_driver116 drv;
  rf_monitor116 mon;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sqr = new("sqr", this);
    drv = rf_driver116::type_id::create("drv", this);
    mon = rf_monitor116::type_id::create("mon", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction
endclass

class rf_collector116 extends uvm_subscriber #(rf_item116);
  `uvm_component_utils(rf_collector116)
  rf_item116 seen[$];

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void write(rf_item116 t);
    seen.push_back(t);
  endfunction
endclass

class rf_reg_counter116 extends uvm_subscriber #(uvm_reg_item);
  `uvm_component_utils(rf_reg_counter116)
  int unsigned items;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void write(uvm_reg_item t);
    items++;
  endfunction
endclass

// The reference model applies the design rules to each monitored item.
class rf_scoreboard116 extends uvm_scoreboard;
  `uvm_component_utils(rf_scoreboard116)
  uvm_tlm_analysis_fifo #(rf_item116) fifo;
  bit [7:0] expected[4];
  bit hold;
  bit outside_got;
  int unsigned drained;
  int unsigned reads;
  int unsigned matched;
  int unsigned mismatches;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // The scoreboard lies outside the configured interface scope.
  function void build_phase(uvm_phase phase);
    virtual rf_if116 probe;
    super.build_phase(phase);
    fifo = new("fifo", this);
    expected[3] = 8'hA5;
    outside_got = uvm_config_db #(virtual rf_if116)::get(this, "", "vif", probe);
  endfunction

  task run_phase(uvm_phase phase);
    rf_item116 tr;
    while (hold) #10;
    forever begin
      fifo.get(tr);
      drained++;
      if (tr.write) begin
        if (tr.addr < 2) begin
          expected[tr.addr] = tr.data;
          expected[2] += 8'd1;
        end
      end else begin
        reads++;
        if (tr.data == expected[tr.addr]) matched++;
        else mismatches++;
      end
    end
  endtask
endclass

class rf_reg116 extends uvm_reg;
  `uvm_object_utils(rf_reg116)
  uvm_reg_field value;

  function new(string name = "rf_reg116");
    super.new(name, 8, UVM_NO_COVERAGE);
  endfunction

  function void setup116(string access, bit volatile_value, uvm_reg_data_t reset);
    value = uvm_reg_field::type_id::create("value");
    value.configure(this, 8, 0, access, volatile_value, reset, 1, 0, 1);
  endfunction
endclass

class rf_block116 extends uvm_reg_block;
  `uvm_object_utils(rf_block116)
  rf_reg116 ctrl;
  rf_reg116 data;
  rf_reg116 count;
  rf_reg116 id;
  uvm_reg_map bus_map;

  function new(string name = "rf_block116");
    super.new(name, UVM_NO_COVERAGE);
  endfunction

  function rf_reg116 add116(string name, string access, bit volatile_value,
                            uvm_reg_data_t reset, uvm_reg_addr_t offset);
    rf_reg116 r;
    r = rf_reg116::type_id::create(name);
    r.configure(this);
    r.setup116(access, volatile_value, reset);
    bus_map.add_reg(r, offset, access);
    return r;
  endfunction

  function void build116();
    bus_map = create_map("bus_map", 0, 1, UVM_LITTLE_ENDIAN);
    ctrl = add116("CTRL", "RW", 0, 8'h00, 0);
    data = add116("DATA", "RW", 0, 8'h00, 1);
    count = add116("COUNT", "RO", 1, 8'h00, 2);
    id = add116("ID", "RO", 0, 8'hA5, 3);
    lock_model();
    reset();
  endfunction
endclass

class rf_adapter116 extends uvm_reg_adapter;
  `uvm_object_utils(rf_adapter116)

  function new(string name = "rf_adapter116");
    super.new(name);
    supports_byte_enable = 0;
    provides_responses = 0;
  endfunction

  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    rf_item116 item;
    item = rf_item116::type_id::create("bus116");
    item.write = rw.kind == UVM_WRITE;
    item.addr = rw.addr[1:0];
    item.data = rw.data[7:0];
    return item;
  endfunction

  // The driver stores read data in the request before item_done.
  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    rf_item116 item;
    if (!$cast(item, bus_item)) `uvm_fatal("RF116", "unexpected bus item")
    rw.kind = item.write ? UVM_WRITE : UVM_READ;
    rw.addr = item.addr;
    rw.data = item.data;
    rw.n_bits = 8;
    rw.status = UVM_IS_OK;
  endfunction
endclass

class rf_env116 extends uvm_env;
  `uvm_component_utils(rf_env116)
  rf_agent116 agent;
  rf_collector116 collector;
  rf_scoreboard116 sb;
  rf_block116 model;
  rf_adapter116 adapter;
  uvm_reg_predictor #(rf_item116) predictor;
  rf_reg_counter116 reg_items;
  bit use_predictor;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = rf_agent116::type_id::create("agent", this);
    collector = rf_collector116::type_id::create("collector", this);
    sb = rf_scoreboard116::type_id::create("sb", this);
    model = rf_block116::type_id::create("model");
    model.build116();
    adapter = rf_adapter116::type_id::create("adapter");
    if (use_predictor) begin
      predictor = new("predictor", this);
      reg_items = rf_reg_counter116::type_id::create("reg_items", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    model.bus_map.set_sequencer(agent.sqr, adapter);
    agent.mon.ap.connect(collector.analysis_export);
    agent.mon.ap.connect(sb.fifo.analysis_export);
    if (use_predictor) begin
      predictor.map = model.bus_map;
      predictor.adapter = adapter;
      agent.mon.ap.connect(predictor.bus_in);
      predictor.reg_ap.connect(reg_items.analysis_export);
    end
  endfunction

  task idle116(int unsigned cycles);
    repeat (cycles) @(agent.drv.vif.drv_cb);
  endtask

  function void report116();
    $display("UT: scoreboard reads %0d matches %0d mismatches %0d",
             sb.reads, sb.matched, sb.mismatches);
  endfunction
endclass

// Raw bus traffic that bypasses the register model.
class rf_seq116 extends uvm_sequence #(rf_item116);
  `uvm_object_utils(rf_seq116)
  rf_item116 ops[$];
  bit done_at_return[$];

  function new(string name = "rf_seq116");
    super.new(name);
  endfunction

  function void add116(bit write, bit [1:0] addr, bit [7:0] data);
    rf_item116 op;
    op = rf_item116::type_id::create($sformatf("op%0d", ops.size()));
    op.write = write;
    op.addr = addr;
    op.data = data;
    ops.push_back(op);
  endfunction

  task body();
    foreach (ops[i]) begin
      start_item(ops[i]);
      finish_item(ops[i]);
      done_at_return.push_back(ops[i].done_cycle != 0);
    end
  endtask
endclass
