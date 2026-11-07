// Original explicit-map access profiles; no storage transfer or HDL is used.
class block104 extends uvm_reg_block;
  function new(string name);super.new(name,UVM_NO_COVERAGE);endfunction
endclass
block104 owner104;
uvm_mem memory104,peer104;
uvm_reg_map maps104[2];
function automatic void observe104(int stage);
  $display("UT: access104 %0d stage %0d A access %s rights %s maps %0d default_A %0d",
    CASE104,stage,memory104.get_access(maps104[0]),memory104.get_rights(maps104[0]),
    memory104.get_n_maps(),owner104.get_default_map()==maps104[0]);
  if(SHARED104)
    $display("UT: access104 %0d stage %0d B access %s rights %s maps %0d default_B %0d",
      CASE104,stage,memory104.get_access(maps104[1]),memory104.get_rights(maps104[1]),
      memory104.get_n_maps(),owner104.get_default_map()==maps104[1]);
  $display("UT: access104 %0d stage %0d peer access %s rights %s maps %0d",
    CASE104,stage,peer104.get_access(maps104[1]),peer104.get_rights(maps104[1]),
    peer104.get_n_maps());
endfunction
initial begin
  string map_rights;
  owner104=new("owner104");owner104.configure();
  memory104=new("memory104",SIZE104,WIDTH104,ROM104?"RO":"RW",UVM_NO_COVERAGE);
  peer104=new("peer104",2,WIDTH104,"RW",UVM_NO_COVERAGE);
  memory104.configure(owner104);peer104.configure(owner104);
  maps104[0]=owner104.create_map("a104",'h100,4,UVM_LITTLE_ENDIAN);
  maps104[1]=owner104.create_map("b104",'h900,4,UVM_LITTLE_ENDIAN);
  if(CASE104==4)map_rights="RW";
  else if(CASE104==5 || CASE104%2==0)map_rights="RO";
  else map_rights="WO";
  maps104[0].add_mem(memory104,'h20,map_rights);
  if(SHARED104)maps104[1].add_mem(memory104,'h80,"RW");
  maps104[1].add_mem(peer104,'h400,"RW");
  owner104.set_default_map(maps104[0]);owner104.lock_model();observe104(0);
  owner104.set_default_map(maps104[1]);observe104(1);
  owner104.set_default_map(maps104[0]);observe104(2);
  $finish;
end
