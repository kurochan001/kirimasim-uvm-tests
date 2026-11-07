// Original model-only hierarchy; lookup is observed both before and after lock.
class block101 extends uvm_reg_block;
  function new(string name);super.new(name,UVM_NO_COVERAGE);endfunction
endclass
class reg101 extends uvm_reg;
  function new(string name,int width=8);super.new(name,width,UVM_NO_COVERAGE);endfunction
endclass
block101 owner101,child101,peer101;
uvm_reg_map owner_map101,child_map101,peer_map101;
reg101 regs101[6];
uvm_mem mems101[6];
uvm_reg_field fields101[2][2];
string model_names101[6],field_names101[2];
function automatic void show_model101(int stage);
  bit names,missing,scope,order_ok;names=1;missing=1;scope=1;order_ok=1;
  if(FAMILY101==0) begin
    for(int i=0;i<4;i++) names &= owner101.get_reg_by_name(model_names101[i])==regs101[i];
    for(int i=2;i<4;i++) names &= child101.get_reg_by_name(model_names101[i])==regs101[i];
    missing=owner101.get_reg_by_name("ITEM101")==null;
    scope=child101.get_reg_by_name(model_names101[0])==null &&
      owner101.get_reg_by_name(model_names101[4])==null;
  end else if(FAMILY101==1) begin
    for(int i=0;i<4;i++) names &= owner101.get_mem_by_name(model_names101[i])==mems101[i];
    for(int i=2;i<4;i++) names &= child101.get_mem_by_name(model_names101[i])==mems101[i];
    missing=owner101.get_mem_by_name("ITEM101")==null;
    scope=child101.get_mem_by_name(model_names101[0])==null &&
      owner101.get_mem_by_name(model_names101[4])==null;
  end else begin
    for(int i=0;i<2;i++) begin
      uvm_reg_field q[$];
      names &= regs101[i].get_field_by_name(field_names101[0])==fields101[i][0] &&
        regs101[i].get_field_by_name(field_names101[1])==fields101[i][1];
      missing &= regs101[i].get_field_by_name("LANE101")==null;
      regs101[i].get_fields(q);order_ok &= q.size()==2;
      if(q.size()==2) order_ok &= q[0]==fields101[i][0] && q[1]==fields101[i][1];
      scope &= fields101[i][0]!=fields101[1-i][0] && fields101[i][1]!=fields101[1-i][1];
    end
  end
  $display("UT: case101 model %0d %0d stage %0d names %0d missing %0d scope %0d",
    FAMILY101,VARIANT101,stage,names,missing,scope);
  if(FAMILY101==2) $display("UT: case101 model 2 %0d stage %0d field_order %0d",
    VARIANT101,stage,order_ok);
endfunction
initial begin
  owner101=new("owner101");child101=new("nested101");peer101=new("peer101");
  owner101.configure();child101.configure(owner101);peer101.configure();
  owner_map101=owner101.create_map("map101",0,4,UVM_LITTLE_ENDIAN);
  child_map101=child101.create_map("map101",0,4,UVM_LITTLE_ENDIAN);
  peer_map101=peer101.create_map("map101",0,4,UVM_LITTLE_ENDIAN);
  owner_map101.add_submap(child_map101,64);
  model_names101[0]="item101";model_names101[1]="Item101";
  model_names101[2]="leaf101";model_names101[3]="Leaf101";
  model_names101[4]="peer101";model_names101[5]="Peer101";
  field_names101[0]="lane101";field_names101[1]="Lane101";
  if(FAMILY101==2) begin
    for(int j=0;j<2;j++) begin
      automatic int i=VARIANT101==0?j:1-j;
      regs101[i]=new(model_names101[i],16);regs101[i].configure(owner101);
      owner_map101.add_reg(regs101[i],i*4,"RW");
      for(int k=0;k<2;k++) begin
        automatic int f=VARIANT101==0?1-k:k;
        fields101[i][f]=new(field_names101[f]);
        fields101[i][f].configure(regs101[i],8,f*8,"RW",0,0,1,0,1);
      end
    end
  end else for(int j=0;j<6;j++) begin
    automatic int i=VARIANT101==0?j:5-j;
    block101 parent;
    uvm_reg_map map;
    if(i<2) begin parent=owner101;map=owner_map101;end
    else if(i<4) begin parent=child101;map=child_map101;end
    else begin parent=peer101;map=peer_map101;end
    if(FAMILY101==0) begin
      uvm_reg_field field;
      regs101[i]=new(model_names101[i]);regs101[i].configure(parent);
      field=new("payload101");field.configure(regs101[i],8,0,"RW",0,0,1,0,1);
      map.add_reg(regs101[i],(i%2)*16,"RW");
    end else begin
      mems101[i]=new(model_names101[i],4,8,"RW",UVM_NO_COVERAGE);
      mems101[i].configure(parent);map.add_mem(mems101[i],(i%2)*16,"RW");
    end
  end
  show_model101(0);owner101.lock_model();peer101.lock_model();
  show_model101(1);show_model101(2);$finish;
end
