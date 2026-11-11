class fixed89 extends uvm_mem_mam_policy;
  uvm_reg_addr_t target;
  constraint selected89 { start_offset==target; }
endclass
function automatic uvm_mem_mam_cfg config89(uvm_reg_addr_t base,
    uvm_mem_mam::alloc_mode_e mode,uvm_mem_mam::locality_e locality);
  automatic uvm_mem_mam_cfg cfg=new();
  cfg.n_bytes=1;
  cfg.start_offset=base;
  cfg.end_offset=base+31;
  cfg.mode=mode;
  cfg.locality=locality;
  return cfg;
endfunction
function automatic bit valid89(uvm_mem_region item,uvm_reg_addr_t base);
  if (item==null) return 0;
  return item.get_len()==4 && item.get_n_bytes()==4 &&
    item.get_start_offset()>=base && item.get_end_offset()<=base+31 &&
    item.get_end_offset()==item.get_start_offset()+3;
endfunction
function automatic bit disjoint89(uvm_mem_region a,uvm_mem_region b);
  if (a==null || b==null) return 0;
  return a.get_end_offset()<b.get_start_offset() || b.get_end_offset()<a.get_start_offset();
endfunction
function automatic bit adjacent89(uvm_mem_region a,uvm_mem_region b);
  if (a==null || b==null) return 0;
  return a.get_end_offset()+1==b.get_start_offset() || b.get_end_offset()+1==a.get_start_offset();
endfunction
function automatic bit remaining89(uvm_mem_mam manager,uvm_mem_region a,uvm_mem_region b);
  automatic uvm_mem_region item=manager.for_each(1);
  automatic int count=0;
  automatic bit seen_a=0,seen_b=0;
  while (item!=null && count<8) begin
    count++;
    seen_a |= item==a;
    seen_b |= b!=null && item==b;
    item=manager.for_each();
  end
  return item==null && seen_a && count==(b==null ? 1 : 2) && (b==null || seen_b);
endfunction
initial begin
  uvm_mem_mam_cfg cfg,next_cfg,peer_cfg,previous;
  uvm_mem_mam manager,peer;
  uvm_mem_region held[2],recent,item;
  uvm_mem_mam::alloc_mode_e selected_mode;
  uvm_mem_mam::locality_e selected_locality;
  uvm_reg_addr_t base,old_start,desired,held_start[2],held_end[2];
  fixed89 policy;
  bit controls,valid,preference,held_ok,cleanup,queries;
  if (MODE<2) begin
    selected_mode=MODE==0 ? uvm_mem_mam::GREEDY : uvm_mem_mam::THRIFTY;
    selected_locality=MODE==0 ? uvm_mem_mam::BROAD : uvm_mem_mam::NEARBY;
    cfg=config89(64,selected_mode,selected_locality);
    peer_cfg=config89(64,selected_mode,selected_locality);
    manager=new("manager89",cfg);
    peer=new("peer89",peer_cfg);
    held[0]=manager.reserve_region(72,4);
    if (held[0]==null) $fatal(1,"configuration control reservation");
    queries=manager.reconfigure()==cfg && peer.reconfigure()==peer_cfg;
    next_cfg=config89(64,MODE==0 ? uvm_mem_mam::THRIFTY : uvm_mem_mam::GREEDY,
      MODE==0 ? uvm_mem_mam::NEARBY : uvm_mem_mam::BROAD);
    previous=manager.reconfigure(next_cfg);
    $display("UT: mam89 %s initial %0d previous %0d current %0d peer %0d",
      CASE_NAME,queries,previous==cfg,manager.reconfigure()==next_cfg,
      peer.reconfigure()==peer_cfg && peer_cfg.mode==selected_mode &&
      peer_cfg.locality==selected_locality);
    $display("UT: mam89 mode %0d locality %0d literals %0d region %0d",
      next_cfg.mode==(MODE==0 ? uvm_mem_mam::THRIFTY : uvm_mem_mam::GREEDY),
      next_cfg.locality==(MODE==0 ? uvm_mem_mam::NEARBY : uvm_mem_mam::BROAD),
      uvm_mem_mam::GREEDY!=uvm_mem_mam::THRIFTY && uvm_mem_mam::BROAD!=uvm_mem_mam::NEARBY,
      held[0].get_start_offset()==72 && held[0].get_end_offset()==75 &&
      remaining89(manager,held[0],null));
  end else begin
    for (int trial=0;trial<8;trial++) begin
      base=(MODE%2)==0 ? 0 : 64;
      selected_mode=MODE inside {4,5} ? uvm_mem_mam::THRIFTY : uvm_mem_mam::GREEDY;
      selected_locality=MODE inside {6,7} ? uvm_mem_mam::NEARBY : uvm_mem_mam::BROAD;
      cfg=config89(base,selected_mode,selected_locality);
      manager=new("manager89",cfg);
      held[1]=null;
      controls=1;
      if (MODE<6) begin
        held[0]=manager.reserve_region(base+12,4);
        old_start=base+((MODE%2)==0 ? 0 : 24);
        recent=manager.reserve_region(old_start,4);
        controls=valid89(recent,base) && valid89(held[0],base) && disjoint89(recent,held[0]);
        if (!controls) $fatal(1,"history control reservation");
        manager.release_region(recent);
        controls &= remaining89(manager,held[0],null);
        for (int i=0;i<2;i++) if (held[i]!=null) begin
          held_start[i]=held[i].get_start_offset();
          held_end[i]=held[i].get_end_offset();
        end
        item=manager.request_region(4);
      end else if (MODE<8) begin
        held[0]=manager.reserve_region(base+(MODE==6 ? 12 : 4),4);
        if (MODE==7) held[1]=manager.reserve_region(base+20,4);
        controls=valid89(held[0],base) && (MODE==6 || valid89(held[1],base));
        if (!controls) $fatal(1,"locality control reservation");
        for (int i=0;i<2;i++) if (held[i]!=null) begin
          held_start[i]=held[i].get_start_offset();
          held_end[i]=held[i].get_end_offset();
        end
        item=manager.request_region(4);
      end else begin
        held[0]=manager.reserve_region(base,4);
        held[1]=manager.reserve_region(base+28,4);
        controls=valid89(held[0],base) && valid89(held[1],base);
        if (!controls) $fatal(1,"broad control reservation");
        desired=base+(MODE==8 ? 12 : 20);
        policy=new();
        policy.target=desired;
        for (int i=0;i<2;i++) if (held[i]!=null) begin
          held_start[i]=held[i].get_start_offset();
          held_end[i]=held[i].get_end_offset();
        end
        item=manager.request_region(4,policy);
      end
      valid=valid89(item,base) && disjoint89(item,held[0]);
      if (held[1]!=null) valid &= disjoint89(item,held[1]);
      preference=0;
      if (item!=null) begin
        if (MODE inside {2,3})
          preference=item.get_end_offset()<old_start || item.get_start_offset()>old_start+3;
        else if (MODE inside {4,5}) preference=item.get_start_offset()==old_start;
        else if (MODE inside {6,7})
          preference=adjacent89(item,held[0]) || adjacent89(item,held[1]);
        else preference=item.get_start_offset()==desired && !adjacent89(item,held[0]) &&
          !adjacent89(item,held[1]) && policy.start_offset==desired;
      end
      held_ok=valid89(held[0],base) && (held[1]==null || valid89(held[1],base));
      for (int i=0;i<2;i++) if (held[i]!=null)
        held_ok &= held[i].get_start_offset()==held_start[i] && held[i].get_end_offset()==held_end[i];
      if (item!=null) manager.release_region(item);
      cleanup=remaining89(manager,held[0],held[1]);
      $display("UT: mam89 %s trial %0d controls %0d valid %0d preference %0d held %0d cleanup %0d",
        CASE_NAME,trial,controls,valid,preference,held_ok,cleanup);
    end
  end
  $finish;
end
