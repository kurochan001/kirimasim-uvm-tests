// Original access providers and observers; no physical HDL is exercised.
string trace66="";
typedef enum {NONE66,VALUE66,MAP66,BACK66,ABORT66,STATUS66} change66;
class field_probe66 extends uvm_reg_field;
  change66 pre_write_change=NONE66,pre_read_change=NONE66;
  change66 post_write_change=NONE66,post_read_change=NONE66;
  uvm_reg_data_t replacement='h63;
  uvm_reg_map redirect;
  function new(string name="uvm_reg_field");
    super.new(name);
  endfunction
  virtual task pre_write(uvm_reg_item rw);
    trace66={trace66,"F"};
    case(pre_write_change)
      VALUE66:rw.set_value(replacement);
      MAP66:rw.set_map(redirect);
      BACK66:rw.set_door(UVM_BACKDOOR);
      ABORT66:rw.set_status(UVM_NOT_OK);
      default:;
    endcase
  endtask
  virtual task pre_read(uvm_reg_item rw);
    trace66={trace66,"F"};
    case(pre_read_change)
      MAP66:rw.set_map(redirect);
      BACK66:rw.set_door(UVM_BACKDOOR);
      ABORT66:rw.set_status(UVM_NOT_OK);
      default:;
    endcase
  endtask
  virtual task post_write(uvm_reg_item rw);
    trace66={trace66,"f"};
    if(post_write_change==STATUS66)rw.set_status(UVM_NOT_OK);
  endtask
  virtual task post_read(uvm_reg_item rw);
    trace66={trace66,"f"};
    if(post_read_change==VALUE66)rw.set_value(replacement);
    if(post_read_change==STATUS66)rw.set_status(UVM_NOT_OK);
  endtask
endclass
class register_probe66 extends uvm_reg;
  function new(int width=8);
    super.new("register66",width,UVM_NO_COVERAGE);
  endfunction
  virtual task pre_write(uvm_reg_item rw);
    trace66={trace66,"R"};
  endtask
  virtual task pre_read(uvm_reg_item rw);
    trace66={trace66,"R"};
  endtask
  virtual task post_write(uvm_reg_item rw);
    trace66={trace66,"r"};
  endtask
  virtual task post_read(uvm_reg_item rw);
    trace66={trace66,"r"};
  endtask
endclass
class callback_probe66 extends uvm_reg_cbs;
  bit field_role=1;
  change66 pre_write_change=NONE66,pre_read_change=NONE66;
  change66 post_write_change=NONE66,post_read_change=NONE66;
  uvm_reg_data_t replacement='h73;
  int pre_writes=0,pre_reads=0,post_writes=0,post_reads=0;
  function new(string name="callback66");
    super.new(name);
  endfunction
  virtual task pre_write(uvm_reg_item rw);
    pre_writes++;
    trace66={trace66,field_role?"D":"C"};
    if(pre_write_change==VALUE66)rw.set_value(replacement);
    if(pre_write_change==ABORT66)rw.set_status(UVM_NOT_OK);
  endtask
  virtual task pre_read(uvm_reg_item rw);
    pre_reads++;
    trace66={trace66,field_role?"D":"C"};
    if(pre_read_change==ABORT66)rw.set_status(UVM_NOT_OK);
  endtask
  virtual task post_write(uvm_reg_item rw);
    post_writes++;
    trace66={trace66,field_role?"d":"c"};
    if(post_write_change==STATUS66)rw.set_status(UVM_NOT_OK);
  endtask
  virtual task post_read(uvm_reg_item rw);
    post_reads++;
    trace66={trace66,field_role?"d":"c"};
    if(post_read_change==VALUE66)rw.set_value(replacement);
    if(post_read_change==STATUS66)rw.set_status(UVM_NOT_OK);
  endtask
endclass
class frontdoor66 extends uvm_reg_frontdoor;
  uvm_reg_data_t word='h11;
  int calls=0;
  function new(string name="frontdoor66");
    super.new(name);
  endfunction
  virtual task body();
    calls++;
    trace66={trace66,"B"};
    #1;
    if(rw_info.get_kind()==UVM_WRITE)word=rw_info.get_value(0);
    else rw_info.set_value(word);
    rw_info.set_status(UVM_IS_OK);
  endtask
endclass
class backdoor66 extends uvm_reg_backdoor;
  uvm_reg_data_t word='h55;
  int reads=0,writes=0;
  bit fail_read=0,fail_write=0;
  uvm_object read_extension,write_extension;
  function new();
    super.new("backdoor66");
  endfunction
  virtual function void read_func(uvm_reg_item rw);
    reads++;
    read_extension=rw.get_extension();
    if(!fail_read)rw.set_value(word);
    rw.set_status(fail_read?UVM_NOT_OK:UVM_IS_OK);
  endfunction
  virtual task read(uvm_reg_item rw);
    do_pre_read(rw);
    read_func(rw);
    do_post_read(rw);
  endtask
  virtual task write(uvm_reg_item rw);
    do_pre_write(rw);
    writes++;
    write_extension=rw.get_extension();
    if(!fail_write)word=rw.get_value(0);
    rw.set_status(fail_write?UVM_NOT_OK:UVM_IS_OK);
    do_post_write(rw);
  endtask
endclass
class block66 extends uvm_reg_block;
  function new();
    super.new("block66",UVM_NO_COVERAGE);
  endfunction
endclass
class token66 extends uvm_sequence_item;
  `uvm_object_utils(token66)
  function new(string name="token66");
    super.new(name);
  endfunction
endclass
class errors66 extends uvm_report_catcher;
  int count=0;
  virtual function action_e catch();
    if(get_severity()==UVM_ERROR)begin
      count++;
      return CAUGHT;
    end
    return THROW;
  endfunction
endclass
class fixture66 extends uvm_test;
  block66 model;
  register_probe66 rg;
  field_probe66 selected;
  uvm_reg_field low_peer,high_peer;
  uvm_reg_map first_map,second_map;
  frontdoor66 first_fd,second_fd;
  backdoor66 bd;
  callback_probe66 field_cb,register_cb;
  token66 extension;
  uvm_sequencer#(uvm_sequence_item) sequencer;
  int width66=8,size66=8,lsb66=0;
  string access66="RW";
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  virtual function void settings66();endfunction
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    settings66();
    model=new();
    model.configure();
    rg=new(width66);
    rg.configure(model);
    selected=new("selected66");
    selected.configure(rg,size66,lsb66,access66,0,'h11,1,1,0);
    if(lsb66>0)begin
      low_peer=new("low66");
      low_peer.configure(rg,lsb66,0,"RW",0,3,1,0,0);
    end
    if(lsb66+size66<width66)begin
      high_peer=new("high66");
      high_peer.configure(rg,width66-lsb66-size66,lsb66+size66,"RW",0,'ha,1,0,0);
    end
    first_map=model.create_map("first66",0,2,UVM_LITTLE_ENDIAN);
    second_map=model.create_map("second66",0,2,UVM_LITTLE_ENDIAN);
    first_fd=new("first66");
    second_fd=new("second66");
    bd=new();
    first_map.add_reg(rg,'h20,"RW",0,first_fd);
    second_map.add_reg(rg,'h40,"RW",0,second_fd);
    sequencer=new("sequencer66",this);
    first_map.set_sequencer(sequencer);
    second_map.set_sequencer(sequencer);
    first_map.set_auto_predict(1);
    second_map.set_auto_predict(1);
    selected.redirect=second_map;
    rg.set_backdoor(bd);
    field_cb=new("field_callback66");
    register_cb=new("register_callback66");
    register_cb.field_role=0;
    extension=new();
    model.lock_model();
    model.reset();
  endfunction
endclass
