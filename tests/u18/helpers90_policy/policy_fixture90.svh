class policy90 extends uvm_mem_mam_policy;
  uvm_reg_addr_t target,expected_min,expected_max;
  int unsigned expected_len;
  uvm_mem_region expected_regions[$];
  int pre_calls=0,post_calls=0;
  bit contradiction=0,context_ok=1;
  constraint target90 { start_offset==target; if (contradiction) start_offset<min_offset; }
  function void pre_randomize();
    bit found;
    super.pre_randomize();
    pre_calls++;
    context_ok &= len==expected_len && min_offset==expected_min && max_offset==expected_max;
    context_ok &= in_use.size()==expected_regions.size();
    foreach (expected_regions[i]) begin
      found=0;
      foreach (in_use[j]) if (in_use[j]==expected_regions[i]) found=1;
      context_ok &= found;
    end
  endfunction
  function void post_randomize(); super.post_randomize(); post_calls++; endfunction
endclass
function automatic bit membership90(uvm_mem_mam manager,uvm_mem_region live[$]);
  automatic uvm_mem_region item=manager.for_each(1);
  automatic bit seen[]=new[live.size()];
  automatic int count=0;
  while (item!=null && count<16) begin
    foreach (live[i]) if (item==live[i]) seen[i]=1;
    count++; item=manager.for_each();
  end
  if (item!=null || count!=live.size()) return 0;
  foreach (seen[i]) if (!seen[i]) return 0;
  return 1;
endfunction
function automatic void prepare90(policy90 policy,uvm_reg_addr_t target,
    uvm_reg_addr_t base,int unsigned locations,uvm_mem_region live[$]);
  policy.target=target; policy.start_offset=base+63;
  policy.expected_min=base; policy.expected_max=base+63;
  policy.expected_len=locations; policy.expected_regions=live;
endfunction
initial begin
  automatic uvm_mem_mam_cfg cfg=new();
  automatic policy90 selected=new();
  automatic policy90 blocked=new();
  automatic policy90 peer_policy=new();
  uvm_mem_mam manager,peer;
  uvm_mem_region live[$],peer_live[$],item;
  uvm_reg_addr_t starts[$],ends[$],base,target;
  int unsigned bytes_per_location,requested;
  int before_pre,before_post;
  bit expect_success,valid,retained,context_valid,randomized;
  bytes_per_location=LAYOUT==0 ? 1 : 2; base=LAYOUT==0 ? 0 : 64;
  cfg.n_bytes=bytes_per_location; cfg.start_offset=base; cfg.end_offset=base+63;
  cfg.mode=uvm_mem_mam::GREEDY; cfg.locality=uvm_mem_mam::BROAD;
  manager=new("manager90",cfg); peer=new("peer90",cfg);
  item=manager.reserve_region(base+54,4*bytes_per_location);
  if (item==null) $fatal(1,"policy90 initial reservation");
  live.push_back(item); starts.push_back(base+54); ends.push_back(base+57);
  prepare90(peer_policy,base+42,base,2,peer_live); peer.default_alloc=peer_policy;
  item=peer.request_region(2*bytes_per_location);
  if (item==null) $fatal(1,"policy90 peer reservation");
  peer_live.push_back(item);
  blocked.target=base+63;
  manager.default_alloc=MODE==2 ? blocked : selected;
  requested=3*bytes_per_location-(LAYOUT==1 ? 1 : 0);
  for (int round=0;round<3;round++) begin
    if (MODE==1 && round>0) begin selected=new(); manager.default_alloc=selected; end
    target=base+6+12*round;
    prepare90(selected,target,base,3,live);
    selected.contradiction=MODE==3 && round==1;
    before_pre=selected.pre_calls; before_post=selected.post_calls;
    if (MODE==2) item=manager.request_region(requested,selected,"explicit90",47+round);
    else if (round==0) item=manager.request_region(requested);
    else item=manager.request_region(requested,null,"default90",91+round);
    expect_success=!(MODE==3 && round==1);
    randomized=selected.pre_calls>before_pre &&
      (expect_success ? selected.post_calls>before_post : selected.post_calls==before_post);
    context_valid=selected.context_ok;
    valid=expect_success ? item!=null : item==null;
    if (item!=null) begin
      valid &= item.get_start_offset()==target && item.get_end_offset()==target+2 &&
        item.get_len()==3 && item.get_n_bytes()==3*bytes_per_location;
      foreach (live[i]) valid &= item.get_end_offset()<starts[i] || item.get_start_offset()>ends[i];
      live.push_back(item); starts.push_back(target); ends.push_back(target+2);
    end
    retained=membership90(manager,live);
    foreach (live[i]) retained &= live[i].get_start_offset()==starts[i] && live[i].get_end_offset()==ends[i];
    $display("UT: policy90 %s round %0d success %0d randomized %0d context %0d valid %0d retained %0d",
      CASE_NAME,round,item!=null,randomized,context_valid,valid,retained);
  end
  if (MODE==2) begin
    selected=new(); prepare90(selected,base+46,base,3,live); manager.default_alloc=selected;
    item=manager.request_region(requested);
    valid=item!=null;
    if (item!=null) begin
      valid &= item.get_start_offset()==base+46 && item.get_end_offset()==base+48;
      live.push_back(item);
    end
    retained=membership90(manager,live);
    foreach (starts[i]) retained &= live[i].get_start_offset()==starts[i] && live[i].get_end_offset()==ends[i];
    $display("UT: policy90 fallback selected %0d randomized %0d context %0d membership %0d",
      valid,selected.pre_calls>0 && selected.post_calls>0,selected.context_ok,retained);
  end
  manager.release_all_regions();
  $display("UT: policy90 cleanup %0d peer %0d",
    manager.for_each(1)==null,membership90(peer,peer_live) &&
    peer_live[0].get_start_offset()==base+42 && peer_live[0].get_end_offset()==base+43);
  $finish;
end
