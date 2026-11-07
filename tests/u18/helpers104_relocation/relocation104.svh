// Original flat-map address/offset observations; no transfer or HDL backend.
// DIAG104 lookup coordinates are investigative only,not an expected oracle.
class block104 extends uvm_reg_block;
  function new(string name);super.new(name,UVM_NO_COVERAGE);endfunction
endclass
block104 owner104;
uvm_mem memory104,peer104;
uvm_reg_map maps104[2];
function automatic void observe104(int stage);
  for(int n=0;n<3;n++)begin
    int location;
    location=n==2?SIZE104-1:n;
    $display("UT: relocation104 %0d %0d stage %0d loc %0d off %0h addr %0h alt_off %0h alt_addr %0h peer_off %0h peer_addr %0h units %0d %0d",
      SHAPE104,BYTEA104,stage,location,
      memory104.get_offset(location,maps104[0]),
      memory104.get_address(location,maps104[0]),
      memory104.get_offset(location,maps104[1]),
      memory104.get_address(location,maps104[1]),
      peer104.get_offset(0,maps104[0]),peer104.get_address(0,maps104[0]),
      maps104[0].get_addr_unit_bytes(),maps104[1].get_addr_unit_bytes());
  end
  begin
    uvm_reg_addr_t local_coordinate,external_coordinate;
    local_coordinate=memory104.get_offset(0,maps104[0])+STRIDEA104;
    external_coordinate=memory104.get_address(1,maps104[0]);
    $display("DIAG104: lookup %0d %0d stage %0d local_coord %0h local_hit %0d external_coord %0h external_hit %0d",
      SHAPE104,BYTEA104,stage,local_coordinate,
      maps104[0].get_mem_by_offset(local_coordinate)==memory104,
      external_coordinate,maps104[0].get_mem_by_offset(external_coordinate)==memory104);
  end
endfunction
initial begin
  owner104=new("owner104");owner104.configure();
  memory104=new("memory104",SIZE104,WIDTH104,"RW",UVM_NO_COVERAGE);
  peer104=new("peer104",2,WIDTH104,"RW",UVM_NO_COVERAGE);
  memory104.configure(owner104);peer104.configure(owner104);
  if(BYTEA104)begin
    maps104[0]=owner104.create_map("a104",BASEA104,BUS104,UVM_LITTLE_ENDIAN,1);
    maps104[1]=owner104.create_map("b104",BASEB104,BUS104,UVM_LITTLE_ENDIAN,0);
  end else begin
    maps104[1]=owner104.create_map("b104",BASEB104,BUS104,UVM_LITTLE_ENDIAN,1);
    maps104[0]=owner104.create_map("a104",BASEA104,BUS104,UVM_LITTLE_ENDIAN,0);
  end
  maps104[0].add_mem(memory104,FIRST104);maps104[1].add_mem(memory104,ALT104);
  maps104[0].add_mem(peer104,HOME104);maps104[1].add_mem(peer104,ALTHOME104);
  owner104.set_default_map(maps104[1]);owner104.lock_model();observe104(0);
  memory104.set_offset(maps104[0],NEXT104);observe104(1);
  peer104.set_offset(maps104[0],FIRST104);observe104(2);
  memory104.set_offset(maps104[0],LAST104);observe104(3);
  peer104.set_offset(maps104[0],HOME104);
  memory104.set_offset(maps104[0],FIRST104);observe104(4);
  $finish;
end
