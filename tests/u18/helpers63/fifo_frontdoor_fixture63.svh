`include "uvm_macros.svh"
class fifo_packet63 extends uvm_sequence_item;
  `uvm_object_utils(fifo_packet63)
  uvm_access_e kind;
  uvm_reg_addr_t address;
  uvm_reg_data_t data;
  uvm_status_e status=UVM_IS_OK;
  function new(string name=""); super.new(name); endfunction
endclass
class fifo_adapter63 extends uvm_reg_adapter;
  function new(); super.new("adapter63"); endfunction
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    fifo_packet63 result;
    result=new("packet63"); result.kind=rw.kind; result.address=rw.addr; result.data=rw.data;
    return result;
  endfunction
  virtual function void bus2reg(uvm_sequence_item bus_item,ref uvm_reg_bus_op rw);
    fifo_packet63 result;
    if (!$cast(result,bus_item)) $fatal(1,"wrong packet type");
    rw.kind=result.kind; rw.addr=result.address; rw.data=result.data; rw.status=result.status;
  endfunction
endclass
class fifo_block63 extends uvm_reg_block;
  function new(); super.new("owner63",UVM_NO_COVERAGE); endfunction
endclass
class fifo_reference63 extends uvm_reg;
  function new(); super.new("reference63",8,UVM_NO_COVERAGE); endfunction
endclass
class fifo_reports63 extends uvm_report_catcher;
  bit gated=0;
  int errors=0;
  virtual function action_e catch();
    if (gated && (get_severity()==UVM_ERROR || get_severity()==UVM_FATAL)) begin
      errors++; return CAUGHT;
    end
    return THROW;
  endfunction
endclass
class fifo_driver63 extends uvm_driver#(fifo_packet63);
  uvm_reg_data_t words[$];
  uvm_reg_data_t reference_value=0;
  int fifo_writes=0,fifo_reads=0,reference_calls=0;
  fifo_packet63 last;
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  task run_phase(uvm_phase phase);
    fifo_packet63 request;
    forever begin
      seq_item_port.get_next_item(request); #1;
      request.status=UVM_IS_OK; last=request;
      case (request.address)
        0: if (request.kind==UVM_WRITE) begin
          words.push_back(request.data); fifo_writes++;
        end else begin
          if (words.size()==0) $fatal(1,"original DUT FIFO unexpectedly empty");
          request.data=words.pop_front(); fifo_reads++;
        end
        4: begin
          reference_calls++;
          if (request.kind==UVM_WRITE) reference_value=request.data;
          else request.data=reference_value;
        end
        default: $fatal(1,"wrong bus address");
      endcase
      seq_item_port.item_done();
    end
  endtask
endclass
class fifo_env63 extends uvm_test;
  fifo_block63 owner;
  uvm_reg_fifo chosen;
  fifo_reference63 reference_reg;
  uvm_reg_map mapping;
  uvm_sequencer#(fifo_packet63) sequencer;
  fifo_adapter63 adapter;
  fifo_driver63 driver;
  fifo_reports63 reports;
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  virtual function bit include_fifo(); return 1; endfunction
  virtual function bit auto_prediction(); return 1; endfunction
  function void build_phase(uvm_phase phase);
    uvm_reg_field data_field;
    super.build_phase(phase); owner=new(); owner.configure();
    reference_reg=new(); reference_reg.configure(owner);
    data_field=new("reference_data63");
    data_field.configure(reference_reg,8,0,"RW",0,0,1,0,1);
    mapping=owner.create_map("bus63",0,1,UVM_LITTLE_ENDIAN);
    mapping.add_reg(reference_reg,4);
    if (include_fifo()) begin
      // Only listed construction/configuration APIs initialize the subject.
      // No unlisted build hook or substitute prediction body is invoked.
      chosen=new("fifo63",4,8,UVM_NO_COVERAGE); chosen.configure(owner);
      mapping.add_reg(chosen,0);
    end
    sequencer=new("sequencer63",this); adapter=new(); driver=new("driver63",this);
    mapping.set_sequencer(sequencer,adapter); mapping.set_auto_predict(auto_prediction());
    reports=new(); uvm_report_cb::add(null,reports); owner.lock_model();
  endfunction
  function void connect_phase(uvm_phase phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction
  virtual task exercise(); endtask
  task run_phase(uvm_phase phase);
    uvm_status_e status;
    uvm_reg_data_t value;
    bit first_ok;
    phase.raise_objection(this);
    reference_reg.write(status,'h63,UVM_FRONTDOOR,mapping); first_ok=status==UVM_IS_OK;
    reference_reg.read(status,value,UVM_FRONTDOOR,mapping);
    $display("UT: fifo_bus_control status %0d stored %0d calls %0d",
      first_ok && status==UVM_IS_OK,value=='h63 && driver.reference_value=='h63,
      driver.reference_calls==2);
    exercise(); phase.drop_objection(this);
  endtask
endclass
