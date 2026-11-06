function automatic bit describes_live90(uvm_mem_mam manager,uvm_mem_region a,uvm_mem_region b);
  automatic uvm_mem_region item=manager.for_each(1);
  automatic bit seen_a=0,seen_b=0;
  automatic int count=0;
  while (item!=null && count<8) begin
    seen_a |= item==a; seen_b |= item==b; count++; item=manager.for_each();
  end
  return item==null && seen_a && (b==null ? count==1 : seen_b && count==2);
endfunction
initial begin
  automatic uvm_mem_mam_cfg cfg=new();
  uvm_mem_mam manager;
  uvm_mem_region a,b;
  uvm_reg_addr_t base;
  int unsigned width;
  string one,two,remaining;
  bit type_ok,states_ok,preserved;
  base=MODE==0 ? 0 : 64; width=MODE==0 ? 1 : 2;
  cfg.n_bytes=width; cfg.start_offset=base; cfg.end_offset=base+63;
  cfg.mode=uvm_mem_mam::GREEDY; cfg.locality=uvm_mem_mam::BROAD;
  manager=new("description90",cfg);
  a=manager.reserve_region(base+3,3*width);
  if (a==null) $fatal(1,"description90 first reservation");
  type_ok=$typename(manager.convert2string())=="string";
  one=manager.convert2string();
  preserved=describes_live90(manager,a,null) && a.get_start_offset()==base+3 && a.get_end_offset()==base+5;
  b=manager.reserve_region(base+27,5*width);
  if (b==null) $fatal(1,"description90 second reservation");
  two=manager.convert2string();
  preserved &= describes_live90(manager,a,b) && a.get_start_offset()==base+3 && a.get_end_offset()==base+5 &&
    b.get_start_offset()==base+27 && b.get_end_offset()==base+31;
  a.release_region(); remaining=manager.convert2string();
  preserved &= describes_live90(manager,b,null) && b.get_start_offset()==base+27 && b.get_end_offset()==base+31;
  states_ok=one.len()>0 && two.len()>0 && remaining.len()>0 && one!=two && two!=remaining;
  $display("UT: description90 %s string_type %0d nonempty_and_changed %0d reservations %0d",
    CASE_NAME,type_ok,states_ok,preserved);
  manager.release_all_regions();
  $display("UT: description90 cleanup %0d",manager.for_each(1)==null);
  $finish;
end
