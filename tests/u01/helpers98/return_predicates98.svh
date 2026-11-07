// Original model-only predicates: raw values, valid explicit handles.
class block98 extends uvm_reg_block;
  function new(string name);super.new(name,UVM_NO_COVERAGE);endfunction
endclass
class reg98 extends uvm_reg;
  function new(string name);super.new(name,8,UVM_NO_COVERAGE);endfunction
endclass
class mem98 extends uvm_mem;
  function new(string name);super.new(name,32,8,"RW",UVM_NO_COVERAGE);endfunction
endclass
class virtual98 extends uvm_vreg;
  function new(string name);super.new(name,16);endfunction
endclass
class field98 extends uvm_reg_field;
  function new(string name);super.new(name);endfunction
endclass
block98 owner98;
uvm_reg_map maps98[2];
reg98 regs98[2];
field98 fields98[2];
mem98 memories98[2];
virtual98 virtuals98[2];
int selected98,peer98;

function automatic int member98(int object_index,int map_index);
  case(FAMILY98)
    1:return regs98[object_index].is_in_map(maps98[map_index]);
    2:return memories98[object_index].is_in_map(maps98[map_index]);
    3:return virtuals98[object_index].is_in_map(maps98[map_index]);
  endcase
  return 0;
endfunction
function automatic uvm_reg_map leaf_map98(block98 leaf,string name);
  reg98 value;
  field98 field_value;
  uvm_reg_map map_value;
  map_value=leaf.create_map(name,0,1,UVM_LITTLE_ENDIAN);
  value=new("leaf_reg98");value.configure(leaf);
  field_value=new("leaf_field98");
  field_value.configure(value,8,0,"RW",0,0,1,0,1);
  map_value.add_reg(value,0,"RW");
  return map_value;
endfunction
function automatic void add98(int object_index,int map_index,uvm_reg_addr_t offset);
  if(FAMILY98==1) maps98[map_index].add_reg(regs98[object_index],offset,"RW");
  else maps98[map_index].add_mem(memories98[object_index],offset,"RW");
endfunction
function automatic void show98(string stage);
  $display("UT: return98 %s %0d %s selected %0d %0d peer %0d %0d",
    FAMILY_NAME98,VARIANT98,stage,
    member98(selected98,selected98),member98(selected98,peer98),
    member98(peer98,selected98),member98(peer98,peer98));
endfunction

initial begin
  block98 a,b,ca,cb,selected_block,peer_block,selected_child,peer_child;
  uvm_reg_map a_map,b_map,ca_map,cb_map;
  int success;
  selected98=VARIANT98;peer98=1-VARIANT98;
  if(FAMILY98==0) begin
    if(VARIANT98==0) begin a=new("cedar98");b=new("birch98");end
    else begin b=new("birch98");a=new("cedar98");end
    ca=new("branch98");cb=new("branch98");
    a.configure();b.configure();ca.configure(a);cb.configure(b);
    a_map=leaf_map98(a,"a_map98");b_map=leaf_map98(b,"b_map98");
    ca_map=leaf_map98(ca,"ca_map98");cb_map=leaf_map98(cb,"cb_map98");
    a_map.add_submap(ca_map,'h100);b_map.add_submap(cb_map,'h100);
    selected_block=VARIANT98==0?a:b;peer_block=VARIANT98==0?b:a;
    selected_child=VARIANT98==0?ca:cb;peer_child=VARIANT98==0?cb:ca;
    $display("UT: return98 lock %0d initial selected %0d %0d peer %0d %0d",VARIANT98,
      selected_block.is_locked(),selected_child.is_locked(),
      peer_block.is_locked(),peer_child.is_locked());
    selected_block.lock_model();
    $display("UT: return98 lock %0d first selected %0d %0d peer %0d %0d",VARIANT98,
      selected_block.is_locked(),selected_child.is_locked(),
      peer_block.is_locked(),peer_child.is_locked());
    peer_block.lock_model();selected_block.unlock_model();
    $display("UT: return98 lock %0d unlocked selected %0d %0d peer %0d %0d",VARIANT98,
      selected_block.is_locked(),selected_child.is_locked(),
      peer_block.is_locked(),peer_child.is_locked());
    selected_block.lock_model();peer_block.unlock_model();
    $display("UT: return98 lock %0d reused selected %0d %0d peer %0d %0d",VARIANT98,
      selected_block.is_locked(),selected_child.is_locked(),
      peer_block.is_locked(),peer_child.is_locked());
  end else begin
    owner98=new("owner98");owner98.configure();
    if(VARIANT98==0) begin
      maps98[0]=owner98.create_map("fern98",0,1,UVM_LITTLE_ENDIAN);
      maps98[1]=owner98.create_map("reed98",'h1000,1,UVM_BIG_ENDIAN);
    end else begin
      maps98[1]=owner98.create_map("reed98",'h1000,1,UVM_BIG_ENDIAN);
      maps98[0]=owner98.create_map("fern98",0,1,UVM_LITTLE_ENDIAN);
    end
    for(int j=0;j<2;j++) begin
      automatic int i=VARIANT98==0?j:1-j;
      if(FAMILY98==1) begin
        regs98[i]=new($sformatf("reg98_%0d",i));regs98[i].configure(owner98);
        fields98[i]=new("payload98");
        fields98[i].configure(regs98[i],8,0,"RW",0,0,1,0,1);
      end else begin
        memories98[i]=new($sformatf("memory98_%0d",i));memories98[i].configure(owner98);
        if(FAMILY98==3) begin
          virtuals98[i]=new($sformatf("virtual98_%0d",i));
          if(VARIANT98==0) virtuals98[i].configure(owner98,memories98[i],3,5,3);
          else begin
            virtuals98[i].configure(owner98);
            success=virtuals98[i].implement(3,memories98[i],5,3);
            if(success!=1) $fatal(1,"return98 legal virtual setup failed");
          end
        end
      end
    end
    show98("initial");
    add98(selected98,selected98,0);show98("first");
    add98(peer98,peer98,0);show98("separate");
    add98(selected98,peer98,'h80);show98("expanded");
    owner98.lock_model();show98("locked");
  end
  $finish;
end
