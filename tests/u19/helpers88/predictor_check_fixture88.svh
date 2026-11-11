class packet88 extends uvm_sequence_item;
  uvm_reg_addr_t address;
  uvm_reg_data_t value;
  function new();
    super.new("packet88");
  endfunction
endclass
class adapter88 extends uvm_reg_adapter;
  function new();
    super.new("adapter88");
  endfunction
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    return null;
  endfunction
  virtual function void bus2reg(uvm_sequence_item bus_item,ref uvm_reg_bus_op rw);
    packet88 item;
    if (!$cast(item,bus_item)) $fatal(1,"original predictor packet type");
    rw.kind=UVM_WRITE;
    rw.addr=item.address;
    rw.data=item.value;
    rw.n_bits=16;
    rw.byte_en='1;
    rw.status=UVM_IS_OK;
  endfunction
endclass
class owner88 extends uvm_reg_block;
  function new(string name);
    super.new(name,UVM_NO_COVERAGE);
  endfunction
endclass
class register88 extends uvm_reg;
  function new(string name);
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction
endclass
class diagnostic88 extends uvm_report_catcher;
  int calls=0,errors=0;
  function new();
    super.new("diagnostic88");
  endfunction
  virtual function action_e catch();
    calls++;
    if (get_severity() inside {UVM_ERROR,UVM_FATAL}) errors++;
    return CAUGHT;
  endfunction
endclass
class sink88 extends uvm_subscriber#(uvm_reg_item);
  int calls=0;
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  virtual function void write(uvm_reg_item item);
    calls++;
  endfunction
endclass
class predictor_test88 extends uvm_test;
  `uvm_component_utils(predictor_test88)
  owner88 owner[2];
  register88 rg[2][2];
  uvm_reg_field field[2][2];
  uvm_reg_map maps[2];
  adapter88 adapters[2];
  uvm_reg_predictor#(packet88) predictors[2];
  uvm_analysis_port#(packet88) monitor[2];
  sink88 sinks[2];
  diagnostic88 diagnostics[2];
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    for (int b=0;b<2;b++) begin
      owner[b]=new($sformatf("owner88_%0d",b));
      owner[b].configure();
      maps[b]=owner[b].create_map("map88",0,2,BIG_ENDIAN ? UVM_BIG_ENDIAN : UVM_LITTLE_ENDIAN);
      for (int i=0;i<2;i++) begin
        rg[b][i]=new($sformatf("register88_%0d",i));
        rg[b][i].configure(owner[b]);
        field[b][i]=new("value88");
        field[b][i].configure(rg[b][i],32,0,"RW",0,0,1,0,1);
        maps[b].add_reg(rg[b][i],i ? 'h40 : 'h20);
      end
      maps[b].set_auto_predict(0);
      owner[b].lock_model();
      owner[b].reset();
      adapters[b]=new();
      predictors[b]=new($sformatf("predictor88_%0d",b),this);
      predictors[b].map=maps[b];
      predictors[b].adapter=adapters[b];
      predictors[b].set_report_verbosity_level(UVM_DEBUG);
      diagnostics[b]=new();
      uvm_report_cb::add(predictors[b],diagnostics[b]);
      monitor[b]=new($sformatf("monitor88_%0d",b),this);
      sinks[b]=new($sformatf("sink88_%0d",b),this);
    end
  endfunction
  virtual function void connect_phase(uvm_phase phase);
    for (int b=0;b<2;b++) begin
      monitor[b].connect(predictors[b].bus_in);
      predictors[b].reg_ap.connect(sinks[b].analysis_export);
    end
  endfunction
  function void observe(int b,int index,bit last);
    automatic packet88 item=new();
    item.address=(index ? 'h40 : 'h20)+(last ? 2 : 0);
    item.value=last ? 'h1122 : 'h3344;
    monitor[b].write(item);
  endfunction
  virtual task run_phase(uvm_phase phase);
    int before_calls,before_errors;
    bit clean_ok,partial_ok;
    uvm_reg_data_t want;
    phase.raise_objection(this);
    // Complete control uses a different predictor, block and register instances.
    for (int i=0;i<2;i++) begin
      observe(1,i,0);
      observe(1,i,1);
    end
    want=BIG_ENDIAN ? 'h33441122 : 'h11223344;
    clean_ok=rg[1][0].get_mirrored_value()==want && rg[1][1].get_mirrored_value()==want && sinks[1].calls==2;
    before_errors=diagnostics[1].errors;
    predictors[1].check_phase(uvm_check_phase::get());
    clean_ok &= diagnostics[1].errors==before_errors;
    for (int i=0;i<PENDING_REGISTERS;i++) observe(0,i,0);
    partial_ok=rg[0][0].get_mirrored_value()==0 && rg[0][1].get_mirrored_value()==0 && sinks[0].calls==0;
    before_calls=diagnostics[0].calls;
    predictors[0].check_phase(uvm_check_phase::get());
    $display("UT: predictor88 %s clean %0d partial %0d pending_report %0d",CASE_NAME,
      clean_ok,partial_ok,diagnostics[0].calls>before_calls);
    phase.drop_objection(this);
  endtask
endclass
initial run_test("predictor_test88");
