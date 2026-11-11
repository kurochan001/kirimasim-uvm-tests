// Original bounded public snapshots of one memory manager before and after a
// reconfiguration that moves both address-space bounds. Membership counts
// each expected descriptor without assuming an iterator order.
function automatic uvm_mem_mam_cfg config115(uvm_reg_addr_t first,last);
  automatic uvm_mem_mam_cfg cfg=new;
  cfg.n_bytes=1;
  cfg.start_offset=first;
  cfg.end_offset=last;
  cfg.mode=uvm_mem_mam::GREEDY;
  cfg.locality=uvm_mem_mam::BROAD;
  return cfg;
endfunction
function automatic bit members115(uvm_mem_mam manager,uvm_mem_region r0,r1,r2);
  automatic int unsigned seen=0,want=0,count=0;
  automatic bit unknown=0;
  automatic uvm_mem_region value=manager.for_each(1);
  if(r0!=null) want|=1;
  if(r1!=null) want|=2;
  if(r2!=null) want|=4;
  while(value!=null && count<8) begin
    count++;
    if(r0!=null && value==r0) seen|=1;
    else if(r1!=null && value==r1) seen|=2;
    else if(r2!=null && value==r2) seen|=4;
    else unknown=1;
    value=manager.for_each();
  end
  return value==null && !unknown && seen==want && count==$countones(want);
endfunction
// 0: no region, 1: exactly four locations at first, 2: any other region.
function automatic int code115(uvm_mem_region r,uvm_reg_addr_t first);
  if(r==null) return 0;
  return r.get_start_offset()==first && r.get_end_offset()==first+3 &&
         r.get_len()==4 ? 1 : 2;
endfunction
class start115 extends uvm_mem_mam_policy;
  uvm_reg_addr_t target,expected_min,expected_max;
  int calls=0;
  bit min_ok=1,max_ok=1,len_ok=1;
  constraint fixed115 { start_offset==target; }
  function void pre_randomize();
    super.pre_randomize();
    calls++;
    min_ok&=min_offset==expected_min;
    max_ok&=max_offset==expected_max;
    len_ok&=len==4;
  endfunction
endclass
function automatic uvm_mem_region take115(uvm_mem_mam manager,start115 policy,
    uvm_reg_addr_t first);
  if(!REQUEST115) return manager.reserve_region(first,4);
  policy.target=first;
  return manager.request_region(4,policy);
endfunction
task automatic exercise115();
  // EXPAND115 widens 8..23 to 4..27; otherwise 4..27 narrows to 8..23.
  automatic uvm_reg_addr_t o0=EXPAND115 ? 8 : 4;
  automatic uvm_reg_addr_t o1=EXPAND115 ? 23 : 27;
  automatic uvm_reg_addr_t n0=EXPAND115 ? 4 : 8;
  automatic uvm_reg_addr_t n1=EXPAND115 ? 27 : 23;
  automatic uvm_mem_mam_cfg first_cfg=config115(o0,o1);
  automatic uvm_mem_mam_cfg next_cfg=config115(n0,n1);
  automatic uvm_mem_mam manager=new("reconfigured",first_cfg);
  automatic start115 early115=new;
  automatic start115 late115=new;
  uvm_mem_mam_cfg previous,current;
  uvm_mem_region held,low,high,probe;
  int before_code[2],outside_code[2],edge_calls;
  held=manager.reserve_region(12,4);
  if(held==null) $fatal(1,"mam115 missing held region");
  $display("UT: setup held %0d",code115(held,12)==1 && members115(manager,held,null,null));
  // Locations 4..7 and 24..27 change management; any probe is released.
  for(int side=0;side<2;side++) begin
    probe=take115(manager,early115,side==0 ? 4 : 24);
    before_code[side]=code115(probe,side==0 ? 4 : 24);
    if(probe!=null) manager.release_region(probe);
  end
  $display("UT: before low %0d high %0d",before_code[0],before_code[1]);
  previous=manager.reconfigure(next_cfg);
  current=manager.reconfigure();
  $display("UT: reconfigured previous %0d current %0d held %0d",
           previous!=null && previous.start_offset==o0 && previous.end_offset==o1,
           current!=null && current.start_offset==n0 && current.end_offset==n1,
           code115(held,12)==1 && members115(manager,held,null,null));
  late115.expected_min=n0;
  late115.expected_max=n1;
  low=take115(manager,late115,n0);
  high=take115(manager,late115,n1-3);
  edge_calls=late115.calls;
  // The four locations just outside each new bound.
  for(int side=0;side<2;side++) begin
    probe=take115(manager,late115,side==0 ? n0-4 : n1+1);
    outside_code[side]=code115(probe,side==0 ? n0-4 : n1+1);
    if(probe!=null) manager.release_region(probe);
  end
  $display("UT: after edges %0d %0d outside %0d %0d",code115(low,n0),code115(high,n1-3),
           outside_code[0],outside_code[1]);
  if(REQUEST115)
    $display("UT: policy min %0d max %0d len %0d",
             late115.min_ok && edge_calls>=2,late115.max_ok && edge_calls>=2,
             late115.len_ok && edge_calls>=2);
  $display("UT: members %0d",members115(manager,held,low,high));
endtask
