bit active86=0,write86=0;
int serial86=0,first86[10],last86[10];
bit indices86=1;
longint unsigned selected86;
uvm_reg_map second86;
uvm_vreg target_reg86;
uvm_vreg_field target_field86;
int slot86;

function void mark86(int role,longint unsigned idx,bit check_idx=1,bit write_event=0);
  if (!active86 || write_event!=write86) return;
  serial86++;
  if (first86[role]==0) first86[role]=serial86;
  last86[role]=serial86;
  if (check_idx) indices86 &= idx==selected86;
endfunction
function bit before86(int a,int b);
  return first86[a]>0 && first86[b]>0 && last86[a]<first86[b];
endfunction
function uvm_reg_data_t original86(int bank,int slot);
  case (bank)
    0: return slot==0 ? 'h1a25 : 'h2d94;
    1: return slot==0 ? 'h5b6c : 'h4e18;
    default: return slot==0 ? 'hc73e : 'ha569;
  endcase
endfunction
function uvm_reg_data_t input86(int slot);
  return slot==0 ? 'h62d3 : 'hb187;
endfunction
function uvm_reg_data_t reg_edit86(int slot);
  return slot==0 ? 'h4a79 : 'h85e6;
endfunction
function uvm_reg_data_t read_edit86(int slot);
  return slot==0 ? 'h9e41 : 'h6b27;
endfunction
function uvm_reg_data_t field_edit86(int slot);
  return slot==0 ? 'ha : 'h5;
endfunction
function uvm_reg_data_t field_result86(int slot);
  return slot==0 ? 'h1aa5 : 'h2d54;
endfunction

class block86 extends uvm_reg_block;
  function new(); super.new("owner86",UVM_NO_COVERAGE); endfunction
endclass
class memory86 extends uvm_mem;
  function new(); super.new("memory86",32,16,"RW",UVM_NO_COVERAGE); endfunction
  virtual task pre_write(uvm_reg_item rw); if (write86) mark86(4,0,0,1); endtask
  virtual task post_write(uvm_reg_item rw); if (write86) mark86(5,0,0,1); endtask
  virtual task pre_read(uvm_reg_item rw); if (!write86) mark86(4,0,0); endtask
  virtual task post_read(uvm_reg_item rw); if (!write86) mark86(5,0,0); endtask
endclass

// These three banks are original testbench storage, not HDL or a bus model.
class front86 extends uvm_reg_frontdoor;
  logic [15:0] words[32];
  function new(string name); super.new(name); endfunction
  virtual task body();
    uvm_reg_addr_t address;
    address=rw_info.get_offset();
    #1;
    if (address>=32) begin rw_info.set_status(UVM_NOT_OK); return; end
    if (rw_info.get_kind()==UVM_WRITE) words[address]=rw_info.get_value(0);
    else rw_info.set_value(uvm_reg_data_t'(words[address]));
    rw_info.set_status(UVM_IS_OK);
  endtask
endclass
class back86 extends uvm_reg_backdoor;
  logic [15:0] words[32];
  function new(); super.new("back86"); endfunction
  virtual task write(uvm_reg_item rw);
    #1;
    if (rw.get_offset()>=32) begin rw.set_status(UVM_NOT_OK); return; end
    words[rw.get_offset()]=rw.get_value(0); rw.set_status(UVM_IS_OK);
  endtask
  virtual task read(uvm_reg_item rw);
    #1;
    if (rw.get_offset()>=32) begin rw.set_status(UVM_NOT_OK); return; end
    rw.set_value(uvm_reg_data_t'(words[rw.get_offset()])); rw.set_status(UVM_IS_OK);
  endtask
endclass

class reg86 extends uvm_vreg;
  function new(); super.new("reg86",16); endfunction
  virtual task pre_write(longint unsigned idx,ref uvm_reg_data_t wdat,
      ref uvm_door_e path,ref uvm_reg_map map);
    mark86(2,idx,1,1);
    if (active86 && MODE==0) wdat=reg_edit86(slot86);
    if (active86 && MODE==1) path=UVM_BACKDOOR;
  endtask
  virtual task pre_read(longint unsigned idx,ref uvm_door_e path,ref uvm_reg_map map);
    mark86(2,idx);
    if (active86 && MODE==2) map=second86;
    if (active86 && MODE==3) path=UVM_BACKDOOR;
  endtask
  virtual task post_write(longint unsigned idx,uvm_reg_data_t wdat,
      uvm_door_e path,uvm_reg_map map,ref uvm_status_e status);
    mark86(7,idx,1,1);
    if (active86 && MODE==4) status=UVM_NOT_OK;
  endtask
  virtual task post_read(longint unsigned idx,ref uvm_reg_data_t rdat,
      input uvm_door_e path,input uvm_reg_map map,ref uvm_status_e status);
    mark86(7,idx);
    if (active86 && MODE==5) begin rdat=read_edit86(slot86); status=UVM_NOT_OK; end
  endtask
endclass
class field86 extends uvm_vreg_field;
  `uvm_object_utils(field86)
  function new(string name="field86"); super.new(name); endfunction
  virtual task pre_write(longint unsigned idx,ref uvm_reg_data_t wdat,
      ref uvm_door_e path,ref uvm_reg_map map); mark86(0,idx,1,1); endtask
  virtual task pre_read(longint unsigned idx,ref uvm_door_e path,ref uvm_reg_map map);
    mark86(0,idx);
    if (active86 && MODE==8) map=second86;
  endtask
  virtual task post_write(longint unsigned idx,uvm_reg_data_t wdat,
      uvm_door_e path,uvm_reg_map map,ref uvm_status_e status);
    mark86(9,idx,1,1);
    if (active86 && MODE inside {6,15}) status=UVM_NOT_OK;
  endtask
  virtual task post_read(longint unsigned idx,ref uvm_reg_data_t rdat,
      uvm_door_e path,uvm_reg_map map,ref uvm_status_e status);
    mark86(9,idx);
    if (active86 && MODE inside {7,16}) begin
      rdat=field_edit86(slot86); status=UVM_NOT_OK;
    end
  endtask
endclass
class reg_cb86 extends uvm_vreg_cbs;
  function new(); super.new(); endfunction
  virtual task pre_write(uvm_vreg rg,longint unsigned idx,ref uvm_reg_data_t wdat,
      ref uvm_door_e path,ref uvm_reg_map map);
    mark86(3,idx,1,1); if (active86 && write86) indices86 &= rg==target_reg86;
  endtask
  virtual task pre_read(uvm_vreg rg,longint unsigned idx,
      ref uvm_door_e path,ref uvm_reg_map map);
    mark86(3,idx); if (active86 && !write86) indices86 &= rg==target_reg86;
    if (active86 && MODE==9) map=second86;
  endtask
  virtual task post_write(uvm_vreg rg,longint unsigned idx,uvm_reg_data_t wdat,
      uvm_door_e path,uvm_reg_map map,ref uvm_status_e status);
    mark86(6,idx,1,1); if (active86 && write86) indices86 &= rg==target_reg86;
  endtask
  virtual task post_read(uvm_vreg rg,longint unsigned idx,ref uvm_reg_data_t rdat,
      input uvm_door_e path,input uvm_reg_map map,ref uvm_status_e status);
    mark86(6,idx); if (active86 && !write86) indices86 &= rg==target_reg86;
  endtask
endclass
class field_cb86 extends uvm_vreg_field_cbs;
  function new(); super.new(); endfunction
  virtual task pre_write(uvm_vreg_field field,longint unsigned idx,
      ref uvm_reg_data_t wdat,ref uvm_door_e path,ref uvm_reg_map map);
    mark86(1,idx,1,1); if (active86 && write86) indices86 &= field==target_field86;
  endtask
  virtual task pre_read(uvm_vreg_field field,longint unsigned idx,
      ref uvm_door_e path,ref uvm_reg_map map);
    mark86(1,idx); if (active86 && !write86) indices86 &= field==target_field86;
    if (active86 && MODE==10) path=UVM_BACKDOOR;
  endtask
  virtual task post_write(uvm_vreg_field field,longint unsigned idx,uvm_reg_data_t wdat,
      uvm_door_e path,uvm_reg_map map,ref uvm_status_e status);
    mark86(8,idx,1,1); if (active86 && write86) indices86 &= field==target_field86;
  endtask
  virtual task post_read(uvm_vreg_field field,longint unsigned idx,ref uvm_reg_data_t rdat,
      uvm_door_e path,uvm_reg_map map,ref uvm_status_e status);
    mark86(8,idx); if (active86 && !write86) indices86 &= field==target_field86;
  endtask
endclass

class test86 extends uvm_test;
  `uvm_component_utils(test86)
  block86 owner;
  memory86 memory;
  reg86 vr;
  field86 vf;
  front86 first_fd,second_fd;
  back86 back;
  uvm_reg_map first_map,second_map;
  reg_cb86 reg_cb;
  field_cb86 field_cb;
  uvm_sequencer#(uvm_sequence_item) sequencer;
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    owner=new(); owner.configure(); memory=new(); memory.configure(owner);
    vr=new(); vr.configure(owner,memory,3,3,4);
    vf=field86::type_id::create("selected86"); vf.configure(vr,4,4);
    reg_cb=new(); field_cb=new();
    uvm_vreg_cb::add(vr,reg_cb); uvm_vreg_field_cb::add(vf,field_cb);
    target_reg86=vr; target_field86=vf;
    first_map=owner.create_map("first86",0,2,UVM_LITTLE_ENDIAN);
    second_map=owner.create_map("second86",'h100,2,UVM_LITTLE_ENDIAN);
    first_map.add_mem(memory,'h20); second_map.add_mem(memory,'h40);
    first_fd=new("first86"); second_fd=new("second86"); back=new();
    memory.set_backdoor(back);
    sequencer=new("sequencer86",this);
    first_map.set_sequencer(sequencer); second_map.set_sequencer(sequencer);
    second86=second_map;
    owner.lock_model();
  endfunction
  task run_phase(uvm_phase phase);
    uvm_status_e status,want_status;
    uvm_reg_data_t value,want,prior_a[32],prior_b[32],prior_c[32];
    int address,bank,target_role;
    bit controls,writing,data_ok,storage_ok,pre_ok,post_ok,present;
    phase.raise_objection(this);
    memory.set_frontdoor(first_fd,first_map); memory.set_frontdoor(second_fd,second_map);
    for (int slot=0;slot<2;slot++) begin
      slot86=slot; selected86=(slot==0 ? 0 : 2); address=3+4*selected86;
      for (int i=0;i<32;i++) begin
        first_fd.words[i]=16'h1000 ^ (i*16'h31);
        second_fd.words[i]=16'h5000 ^ (i*16'h53);
        back.words[i]=16'hc000 ^ (i*16'h79);
      end
      first_fd.words[address]=original86(0,slot);
      second_fd.words[address]=original86(1,slot);
      back.words[address]=original86(2,slot);
      active86=0;
      vr.read(selected86,status,value,UVM_FRONTDOOR,first_map);
      controls=status==UVM_IS_OK && (value & 'hffff)==original86(0,slot);
      vr.read(selected86,status,value,UVM_FRONTDOOR,second_map);
      controls &= status==UVM_IS_OK && (value & 'hffff)==original86(1,slot);
      vr.read(selected86,status,value,UVM_BACKDOOR,first_map);
      controls &= status==UVM_IS_OK && (value & 'hffff)==original86(2,slot);
      for (int i=0;i<32;i++) begin
        prior_a[i]=first_fd.words[i]; prior_b[i]=second_fd.words[i]; prior_c[i]=back.words[i];
      end
      serial86=0; indices86=1;
      foreach (first86[i]) begin first86[i]=0; last86[i]=0; end
      writing=MODE inside {0,1,4,6,11,15}; write86=writing;
      active86=1;
      if (MODE==15)
        vf.write(selected86,status,field_edit86(slot),UVM_FRONTDOOR,first_map);
      else if (MODE==16) vf.read(selected86,status,value,UVM_FRONTDOOR,first_map);
      else if (writing) vr.write(selected86,status,input86(slot),UVM_FRONTDOOR,first_map);
      else vr.read(selected86,status,value,UVM_FRONTDOOR,first_map);
      active86=0;
      want_status=(MODE inside {4,5,6,7,15,16}) ? UVM_NOT_OK : UVM_IS_OK;
      bank=(MODE==1 ? 2 : 0);
      want=input86(slot);
      if (MODE==0) want=reg_edit86(slot);
      if (MODE==15) want=field_result86(slot);
      if (writing)
        data_ok=(bank==0 ? uvm_reg_data_t'(first_fd.words[address]) :
          uvm_reg_data_t'(back.words[address]))==want;
      else begin
        want=original86(0,slot);
        if (MODE inside {2,8,9}) want=original86(1,slot);
        if (MODE inside {3,10}) want=original86(2,slot);
        if (MODE==5) want=read_edit86(slot);
        if (MODE==7) want=field_result86(slot);
        if (MODE==16) want=field_edit86(slot);
        data_ok=(value & (MODE==16 ? 'hf : 'hffff))==want;
      end
      storage_ok=1;
      for (int i=0;i<32;i++) begin
        if (!(writing && bank==0 && i==address))
          storage_ok &= first_fd.words[i]==prior_a[i];
        storage_ok &= second_fd.words[i]==prior_b[i];
        if (!(writing && bank==2 && i==address)) storage_ok &= back.words[i]==prior_c[i];
      end
      target_role=2;
      if (MODE inside {4,5}) target_role=7;
      if (MODE inside {6,7,15,16}) target_role=9;
      if (MODE inside {8,13}) target_role=0;
      if (MODE==9) target_role=3;
      if (MODE inside {10,14}) target_role=1;
      $display("UT: vcb86 %s idx %0d controls %0d",CASE_NAME,selected86,controls);
      $display("UT: vcb86 status %0d data %0d storage %0d",
        status==want_status,data_ok,storage_ok);
      $display("UT: vcb86 hook %0d indices %0d",first86[target_role]>0,indices86);
      if (MODE inside {11,12,13,14}) begin
        present=1; foreach (first86[i]) present &= first86[i]>0;
        pre_ok=before86(0,1) && before86(1,2) && before86(2,3) && before86(3,4);
        if (MODE==13)
          pre_ok=before86(2,0) && before86(3,0) && before86(0,1) && before86(1,4);
        if (MODE==14)
          pre_ok=before86(2,1) && before86(3,1) && before86(0,1) && before86(1,4);
        post_ok=before86(5,6) && before86(6,7) && before86(7,8) && before86(8,9);
        $display("UT: vcb86 present %0d pre_order %0d post_order %0d",
          present,pre_ok,post_ok);
      end
    end
    phase.drop_objection(this);
  endtask
endclass
