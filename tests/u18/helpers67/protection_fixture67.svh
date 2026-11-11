// Original providers observe callback enforcement without physical HDL.
class model67 extends uvm_reg_block;
  function new();
    super.new("model67",UVM_NO_COVERAGE);
  endfunction
endclass
class register67 extends uvm_reg;
  function new(string name);
    super.new(name,16,UVM_NO_COVERAGE);
  endfunction
endclass
class frontdoor67 extends uvm_reg_frontdoor;
  uvm_reg_data_t word='h11ad;
  int reads=0,writes=0;
  function new(string name);
    super.new(name);
  endfunction
  virtual task body();
    #1;
    if(rw_info.get_kind()==UVM_WRITE)begin
      writes++;
      word=rw_info.get_value();
    end
    else begin
      reads++;
      rw_info.set_value(word);
    end
    rw_info.set_status(UVM_IS_OK);
  endtask
endclass
class backdoor67 extends uvm_reg_backdoor;
  uvm_reg_data_t word='h11ad;
  int reads=0,writes=0;
  function new(string name);
    super.new(name);
  endfunction
  virtual function void read_func(uvm_reg_item rw);
    reads++;
    rw.set_value(word);
    rw.set_status(UVM_IS_OK);
  endfunction
  virtual task read(uvm_reg_item rw);
    do_pre_read(rw);
    read_func(rw);
    do_post_read(rw);
  endtask
  virtual task write(uvm_reg_item rw);
    do_pre_write(rw);
    writes++;
    word=rw.get_value();
    rw.set_status(UVM_IS_OK);
    do_post_write(rw);
  endtask
endclass
class errors67 extends uvm_report_catcher;
  int errors=0;
  virtual function action_e catch();
    if(get_severity()==UVM_ERROR)begin
      errors++;
      return CAUGHT;
    end
    return THROW;
  endfunction
endclass
class sentinel67 extends uvm_reg_cbs;
  int writes=0,reads=0;
  virtual task pre_write(uvm_reg_item rw);
    writes++;
  endtask
  virtual task pre_read(uvm_reg_item rw);
    reads++;
  endtask
endclass
class prediction67 extends uvm_reg_cbs;
  int calls=0;
  uvm_reg_field seen_field;
  uvm_reg_data_t seen_previous,seen_value;
  uvm_predict_e seen_kind;
  uvm_door_e seen_path;
  uvm_reg_map seen_map;
  virtual function void post_predict(input uvm_reg_field fld,
      input uvm_reg_data_t previous,inout uvm_reg_data_t value,
      input uvm_predict_e kind,input uvm_door_e path,input uvm_reg_map map);
    calls++;
    seen_field=fld;
    seen_previous=previous;
    seen_value=value;
    seen_kind=kind;
    seen_path=path;
    seen_map=map;
    value='h63;
  endfunction
endclass
class fixture67 extends uvm_test;
  model67 model;
  register67 rg[2];
  uvm_reg_field low_field[2],high_field[2];
  frontdoor67 fd[2];
  backdoor67 bd[2];
  uvm_reg_map first_map,second_map;
  uvm_sequencer#(uvm_sequence_item) sequencer;
  errors67 catcher;
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    model=new();
    model.configure();
    first_map=model.create_map("first67",0,2,UVM_LITTLE_ENDIAN);
    second_map=model.create_map("second67",0,2,UVM_LITTLE_ENDIAN);
    for(int i=0;i<2;i++)begin
      rg[i]=new($sformatf("register%0d",i));
      rg[i].configure(model);
      low_field[i]=new("low67");
      high_field[i]=new("high67");
      low_field[i].configure(rg[i],8,0,"RW",0,'had,1,0,0);
      high_field[i].configure(rg[i],8,8,"RW",0,'h11,1,0,0);
      fd[i]=new($sformatf("frontdoor%0d",i));
      bd[i]=new($sformatf("backdoor%0d",i));
      first_map.add_reg(rg[i],i*2,"RW",0,fd[i]);
      second_map.add_reg(rg[i],i*2+32,"RW",0,fd[i]);
      rg[i].set_backdoor(bd[i]);
    end
    sequencer=new("sequencer67",this);
    first_map.set_sequencer(sequencer);
    second_map.set_sequencer(sequencer);
    first_map.set_auto_predict(1);
    second_map.set_auto_predict(1);
    model.lock_model();
    model.reset();
    catcher=new();
    uvm_report_cb::add(null,catcher);
  endfunction
  function void install67(int family,int which=0);
    if(family==0)uvm_reg_read_only_cbs::add(rg[which]);
    else uvm_reg_write_only_cbs::add(rg[which]);
  endfunction
  function void remove67(int family,int which=0);
    if(family==0)uvm_reg_read_only_cbs::remove(rg[which]);
    else uvm_reg_write_only_cbs::remove(rg[which]);
  endfunction
  function int members67(int family,int target,int which=0);
    uvm_reg_cbs values[$];
    uvm_reg_read_only_cbs ro;
    uvm_reg_write_only_cbs wo;
    int found=0;
    if(target==0)uvm_reg_cb::get_all(values,rg[which]);
    else if(target==1)uvm_reg_field_cb::get_all(values,low_field[which]);
    else uvm_reg_field_cb::get_all(values,high_field[which]);
    foreach(values[i])begin
      if(family==0 && $cast(ro,values[i]))found++;
      if(family==1 && $cast(wo,values[i]))found++;
    end
    return found;
  endfunction
  function bit has_sentinel67(int target,sentinel67 subject);
    uvm_reg_cbs values[$];
    if(target==0)uvm_reg_cb::get_all(values,rg[0]);
    else if(target==1)uvm_reg_field_cb::get_all(values,low_field[0]);
    else uvm_reg_field_cb::get_all(values,high_field[0]);
    foreach(values[i])if(values[i]==subject)return 1;
    return 0;
  endfunction
  function int transfers67(int which=0);
    return fd[which].reads+fd[which].writes+bd[which].reads+bd[which].writes;
  endfunction
  function bit storage67(int which=0);
    return fd[which].word=='h11ad && bd[which].word=='h11ad;
  endfunction
  task access67(int target,int which,bit write_access,uvm_door_e path,
      output uvm_status_e status,output uvm_reg_data_t value);
    uvm_reg_data_t supplied=target==0?'h3d72:(target==1?'h72:'h3d);
    if(write_access)begin
      if(target==0)rg[which].write(status,supplied,path,first_map);
      else if(target==1)low_field[which].write(status,supplied,path,first_map);
      else high_field[which].write(status,supplied,path,first_map);
    end
    else begin
      if(target==0)rg[which].read(status,value,path,first_map);
      else if(target==1)low_field[which].read(status,value,path,first_map);
      else high_field[which].read(status,value,path,first_map);
    end
  endtask
  function bit allowed67(int target,int which,bit write_access,uvm_door_e path,
      uvm_status_e status,uvm_reg_data_t value);
    uvm_reg_data_t word=path==UVM_FRONTDOOR?fd[which].word:bd[which].word;
    if(status!=UVM_IS_OK)return 0;
    if(!write_access)return value==(target==0?'h11ad:(target==1?'had:'h11));
    if(target==0)return word=='h3d72;
    if(target==1)return word[7:0]=='h72;
    return word[15:8]=='h3d;
  endfunction
endclass
