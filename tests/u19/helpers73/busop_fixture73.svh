// Original numeric-word bus. This does not implement the builtin TLM adapter.
function automatic uvm_reg_data_t valid_mask73(int width);
  if (width <= 0) return 0;
  if (width >= 64) return '1;
  return (uvm_reg_data_t'(1) << width) - 1;
endfunction
class packet73 extends uvm_sequence_item;
  `uvm_object_utils(packet73)
  uvm_access_e kind = UVM_READ;
  uvm_reg_addr_t address = 0;
  uvm_reg_data_t data = 0;
  int bits = 0;
  uvm_reg_byte_en_t enables = '1;
  uvm_status_e status = UVM_IS_OK;
  function new(string name = "packet73");
    super.new(name);
  endfunction
endclass
class word_adapter73 extends uvm_reg_adapter;
  uvm_reg_bus_op requests[$];
  int responses = 0;
  function new();
    super.new("word_adapter73");
  endfunction
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    packet73 item;
    item = new("bus73");
    requests.push_back(rw);
    item.kind = rw.kind;
    item.address = rw.addr;
    item.data = rw.data;
    item.bits = rw.n_bits;
    item.enables = rw.byte_en;
    return item;
  endfunction
  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    packet73 item;
    if (!$cast(item, bus_item) || item == null) $fatal(1, "wrong original bus item");
    responses++;
    rw.kind = item.kind;
    rw.addr = item.address;
    rw.data = item.data;
    rw.n_bits = item.bits;
    rw.byte_en = item.enables;
    rw.status = item.status;
  endfunction
  function void dump_requests(bit reading);
    uvm_reg_bus_op swap;
    // Sort only the completed observer copies, without prescribing bus order.
    foreach (requests[i]) begin
      for (int j = i + 1; j < requests.size(); j++) begin
        if (requests[j].addr < requests[i].addr) begin
          swap = requests[i];
          requests[i] = requests[j];
          requests[j] = swap;
        end
      end
    end
    foreach (requests[i]) begin
      if (reading)
        $display("UT: busop_request address %0h read %0d bits %0d", requests[i].addr,
                 requests[i].kind == UVM_READ, requests[i].n_bits);
      else
        $display("UT: busop_request address %0h read %0d bits %0d data %0h",
                 requests[i].addr, requests[i].kind == UVM_READ, requests[i].n_bits,
                 requests[i].data & valid_mask73(requests[i].n_bits));
    end
  endfunction
endclass
class model_block73 extends uvm_reg_block;
  function new();
    super.new("block73", UVM_NO_COVERAGE);
  endfunction
endclass
class model_register73 extends uvm_reg;
  function new(int width);
    super.new("register73", width, UVM_NO_COVERAGE);
  endfunction
endclass
class bus_driver73 extends uvm_driver#(packet73);
  uvm_reg_data_t storage[uvm_reg_addr_t];
  int calls = 0;
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
    packet73 request;
    forever begin
      seq_item_port.get_next_item(request);
      #1;
      if (request.kind == UVM_READ)
        request.data = storage.exists(request.address) ? storage[request.address] : 0;
      else
        storage[request.address] = request.data & valid_mask73(request.bits);
      request.status = UVM_IS_OK;
      calls++;
      seq_item_port.item_done();
    end
  endtask
endclass
