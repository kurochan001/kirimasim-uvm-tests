class location90 extends uvm_mem_mam_policy;
  uvm_reg_addr_t target;
  constraint target90 { start_offset==target; }
endclass
function automatic bit region_set90(uvm_mem_mam manager,uvm_mem_region a,uvm_mem_region b);
  automatic uvm_mem_region item=manager.for_each(1);
  automatic int count=0;
  automatic bit seen_a=0,seen_b=0;
  while (item!=null && count<8) begin
    count++;
    seen_a |= item==a;
    seen_b |= item==b;
    item=manager.for_each();
  end
  return item==null && seen_a && (b==null ? count==1 : seen_b && count==2);
endfunction
initial begin
  automatic uvm_mem_mam_cfg cfg=new();
  automatic location90 policy=new();
  uvm_mem memory;
  uvm_mem_mam manager,peer;
  uvm_mem_region a,b,again,peer_region;
  uvm_reg_addr_t base;
  int unsigned width;
  bit identity,descriptors,preservation;
  width=MODE==0 ? 1 : 2;
  base=MODE==0 ? 0 : 64;
  cfg.n_bytes=width;
  cfg.start_offset=base;
  cfg.end_offset=base+63;
  cfg.mode=uvm_mem_mam::GREEDY;
  cfg.locality=uvm_mem_mam::BROAD;
  memory=new("memory90",256,8*width);
  manager=new("attached90",cfg,memory);
  peer=new("detached90",cfg);
  a=manager.reserve_region(base+4,3*width);
  peer_region=peer.reserve_region(base+4,3*width);
  policy.target=base+16;
  b=manager.request_region(5*width,policy);
  if (a==null || b==null || peer_region==null) $fatal(1,"region90 initial allocation");
  identity=a!=b && a!=peer_region && b!=peer_region && a.get_memory()==memory &&
    b.get_memory()==memory && peer_region.get_memory()==null;
  descriptors=a.get_start_offset()==base+4 && a.get_end_offset()==base+6 && a.get_len()==3 &&
    a.get_n_bytes()==3*width && b.get_start_offset()==base+16 && b.get_end_offset()==base+20 &&
    b.get_len()==5 && b.get_n_bytes()==5*width && region_set90(manager,a,b);
  $display("UT: region90 %s identity %0d descriptors %0d virtual %0d",CASE_NAME,identity,descriptors,
    a.get_virtual_registers()==null && b.get_virtual_registers()==null);
  a.release_region();
  preservation=region_set90(manager,b,null) && b.get_start_offset()==base+16 && b.get_end_offset()==base+20;
  again=manager.reserve_region(base+4,3*width);
  $display("UT: region90 release_preserves %0d available_again %0d peer %0d",preservation,
    again!=null && again.get_start_offset()==base+4 && again.get_end_offset()==base+6 &&
    again.get_len()==3 && again.get_n_bytes()==3*width && region_set90(manager,b,again),region_set90(peer,peer_region,null) &&
    peer_region.get_start_offset()==base+4 && peer_region.get_end_offset()==base+6);
  manager.release_all_regions();
  $display("UT: region90 cleanup %0d peer %0d",manager.for_each(1)==null,region_set90(peer,peer_region,null));
  $finish;
end
