// Original one-byte bus protocol and required-parent clone bridge.
class packet76 extends uvm_sequence_item;
  `uvm_object_utils(packet76)
  uvm_access_e kind = UVM_READ;
  uvm_reg_addr_t address = 0;
  uvm_reg_data_t data = 0;
  int bits = 0;
  uvm_reg_byte_en_t enables = '1;
  uvm_status_e status = UVM_IS_OK;
  function new(string name = "packet76");
    super.new(name);
  endfunction
endclass
virtual class required_parent76 extends uvm_sequence#(packet76);
  int tag = 0;
  function new(string name = "required_parent76");
    super.new(name);
  endfunction
  pure virtual function int family76();
  pure virtual function required_parent76 do_clone();
  virtual function uvm_object clone();
    return do_clone();
  endfunction
  virtual task body(); endtask
endclass
class parent_a76 extends required_parent76;
  `uvm_object_utils(parent_a76)
  function new(string name = "parent_a76");
    super.new(name);
  endfunction
  virtual function int family76();
    return 1;
  endfunction
  virtual function required_parent76 do_clone();
    parent_a76 value;
    value = new(get_name());
    value.tag = tag;
    return value;
  endfunction
endclass
class parent_b76 extends required_parent76;
  `uvm_object_utils(parent_b76)
  function new(string name = "parent_b76");
    super.new(name);
  endfunction
  virtual function int family76();
    return 2;
  endfunction
  virtual function required_parent76 do_clone();
    parent_b76 value;
    value = new(get_name());
    value.tag = tag;
    return value;
  endfunction
endclass
class adapter76 extends uvm_reg_adapter;
  function new();
    super.new("adapter76");
    supports_byte_enable = 1;
    provides_responses = 0;
  endfunction
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    packet76 value;
    value = new;
    value.kind = rw.kind;
    value.address = rw.addr;
    value.data = rw.data;
    value.bits = rw.n_bits;
    value.enables = rw.byte_en;
    return value;
  endfunction
  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    packet76 value;
    if (!$cast(value, bus_item) || value == null) $fatal(1, "wrong original bus item");
    rw.kind = value.kind;
    rw.addr = value.address;
    rw.data = value.data;
    rw.n_bits = value.bits;
    rw.byte_en = value.enables;
    rw.status = value.status;
  endfunction
endclass
class block76 extends uvm_reg_block;
  `uvm_object_utils(block76)
  function new(string name = "block76");
    super.new(name, UVM_NO_COVERAGE);
  endfunction
endclass
class register76 extends uvm_reg;
  `uvm_object_utils(register76)
  function new(string name = "register76");
    super.new(name, 8, UVM_NO_COVERAGE);
  endfunction
endclass
class driver76 extends uvm_driver#(packet76);
  uvm_reg_data_t storage[uvm_reg_addr_t];
  int expected_family = 0;
  bit required = 0;
  int seen_family = -1, seen_tag = -1;
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  virtual task run_phase(uvm_phase phase);
    packet76 request;
    required_parent76 parent;
    forever begin
      seq_item_port.get_next_item(request);
      required = $cast(parent, request.get_parent_sequence()) && parent != null;
      if (required) begin
        seen_family = parent.family76();
        seen_tag = parent.tag;
        required &= seen_family == expected_family;
      end
      #1;
      if (!required) request.status = UVM_NOT_OK;
      else begin
        if (request.kind == UVM_READ)
          request.data = storage.exists(request.address) ? storage[request.address] : 0;
        else storage[request.address] = request.data;
        request.status = UVM_IS_OK;
      end
      seq_item_port.item_done();
    end
  endtask
endclass
class route76 extends uvm_component;
  block76 block_value;
  register76 reg_value;
  uvm_reg_field field_value;
  uvm_mem mem_value;
  uvm_reg_map mapping;
  adapter76 adapter;
  uvm_sequencer#(packet76) sequencer;
  driver76 driver;
  uvm_status_e last_status = UVM_NOT_OK;
  uvm_reg_data_t last_value = 0;
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    block_value = new({get_name(), "_block76"});
    block_value.configure();
    reg_value = new;
    reg_value.configure(block_value);
    field_value = new("payload76");
    field_value.configure(reg_value, 8, 0, "RW", 0, 0, 1, 0, 1);
    mem_value = new("memory76", 4, 8, "RW", UVM_NO_COVERAGE);
    mem_value.configure(block_value);
    mapping = block_value.create_map("map76", 0, 1, UVM_LITTLE_ENDIAN, 1);
    mapping.add_reg(reg_value, 'h10);
    mapping.add_mem(mem_value, 'h40);
    mapping.set_auto_predict(0);
    mapping.set_check_on_read(0);
    block_value.lock_model();
    block_value.reset();
    adapter = new;
    sequencer = new("sequencer76", this);
    driver = new("driver76", this);
    mapping.set_sequencer(sequencer, adapter);
  endfunction
  virtual function void connect_phase(uvm_phase phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction
  task transfer76(bit memory_access, bit reading, int step,
                  required_parent76 prototype, int family, uvm_reg_data_t data);
    uvm_reg_addr_t address;
    address = memory_access ? 'h40 + step : 'h10;
    adapter.parent_sequence = prototype;
    driver.expected_family = family;
    driver.required = 0;
    driver.seen_family = -1;
    driver.seen_tag = -1;
    if (reading) driver.storage[address] = data;
    last_status = UVM_NOT_OK;
    last_value = 0;
    if (memory_access) begin
      if (reading)
        mem_value.read(last_status, step, last_value, UVM_FRONTDOOR, mapping);
      else mem_value.write(last_status, step, data, UVM_FRONTDOOR, mapping);
    end
    else begin
      if (reading) reg_value.read(last_status, last_value, UVM_FRONTDOOR, mapping);
      else reg_value.write(last_status, data, UVM_FRONTDOOR, mapping);
    end
    if (!reading) last_value = driver.storage[address];
  endtask
  function void dump76(int step);
    $display("UT: parent76 %s %0d required %0b kind %0d tag %0d ok %0b value %02h",
             get_name(), step, driver.required, driver.seen_family, driver.seen_tag,
             last_status == UVM_IS_OK, last_value);
  endfunction
endclass
class t76 extends uvm_test;
  `uvm_component_utils(t76)
  route76 focus, peer;
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    focus = new("focus", this);
    peer = new("peer", this);
  endfunction
  virtual task run_phase(uvm_phase phase);
    automatic parent_a76 a = new;
    automatic parent_b76 b = new;
    automatic parent_b76 peer_prototype = new;
    required_parent76 picked;
    phase.raise_objection(this);
    peer_prototype.tag = 119;
    for (int step = 0; step < 3; step++) begin
      picked = (step == 1) ? required_parent76'(b) : required_parent76'(a);
      picked.tag = 17 * (step + 1);
      if (PAIRED76) begin
        fork
          focus.transfer76(MEMORY76, READING76, step, picked,
                           (step == 1) ? 2 : 1, 'h31 + step * 'h21);
          peer.transfer76(MEMORY76, READING76, step, peer_prototype, 2,
                          'ha1 + step * 'h11);
        join
      end
      else focus.transfer76(MEMORY76, READING76, step, picked,
                            (step == 1) ? 2 : 1, 'h31 + step * 'h21);
      focus.dump76(step);
      if (PAIRED76) peer.dump76(step);
    end
    phase.drop_objection(this);
  endtask
endclass
