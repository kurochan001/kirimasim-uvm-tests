// Original bounded public snapshots of one memory manager; the membership
// check counts each expected descriptor without assuming an iterator order.
function automatic uvm_mem_mam_cfg config113();
  automatic uvm_mem_mam_cfg cfg=new;
  cfg.n_bytes=1; cfg.start_offset=0; cfg.end_offset=31;
  cfg.mode=uvm_mem_mam::GREEDY; cfg.locality=uvm_mem_mam::BROAD;
  return cfg;
endfunction
function automatic bit members113(uvm_mem_mam manager,
    uvm_mem_region r0,r1,r2,int unsigned expected);
  automatic int unsigned seen=0,count=0;
  automatic bit unknown=0;
  automatic uvm_mem_region value=manager.for_each(1);
  while(value!=null && count<8) begin
    count++;
    if (value==r0) seen|=1;
    else if (value==r1) seen|=2;
    else if (value==r2) seen|=4;
    else unknown=1;
    value=manager.for_each();
  end
  return value==null && !unknown && seen==expected && count==$countones(expected);
endfunction
class error_probe113 extends uvm_report_catcher;
  int errors=0;
  virtual function action_e catch();
    if (get_severity()==UVM_ERROR) begin errors++; return CAUGHT; end
    return THROW;
  endfunction
endclass
task automatic exercise113();
  automatic error_probe113 probe=new;
  for(int round=1;round<=2;round++) begin
    automatic uvm_mem_mam_cfg cfg=config113();
    automatic uvm_mem_mam manager=new("selected",cfg);
    uvm_mem_region regions[3];
    uvm_mem_region again;
    int unsigned remaining;
    int before_errors;
    bit setup_ok,released_ok,reuse_ok,again_released;
    // PICK113 is the allocation-call position of the stale descriptor.
    for(int i=0;i<3;i++) regions[i]=manager.reserve_region(4+8*i,4);
    foreach(regions[i]) if(regions[i]==null) $fatal(1,"mam113 missing initial region");
    setup_ok=members113(manager,regions[0],regions[1],regions[2],7);
    $display("UT: round %0d setup members %0d distinct %0d",round,setup_ok,
             regions[0]!=regions[1] && regions[0]!=regions[2] && regions[1]!=regions[2]);
    if (BULK113) begin manager.release_all_regions(); remaining=0; end
    else begin regions[PICK113].release_region(); remaining=7^(1<<PICK113); end
    released_ok=members113(manager,regions[0],regions[1],regions[2],remaining);
    $display("UT: round %0d released members %0d",round,released_ok);
    // Reuse is observed only while this manager is still in a valid state.
    if(BULK113) again=manager.reserve_region(0,32);
    else again=manager.reserve_region(4+8*PICK113,4);
    if(again==null) $fatal(1,"mam113 valid range reuse failed");
    reuse_ok=again.get_start_offset()==(BULK113 ? 0 : 4+8*PICK113) &&
             again.get_end_offset()==(BULK113 ? 31 : 7+8*PICK113) &&
             again.get_len()==(BULK113 ? 32 : 4);
    manager.release_region(again);
    again_released=members113(manager,regions[0],regions[1],regions[2],remaining);
    $display("UT: round %0d reuse geometry %0d released_again %0d",round,
             reuse_ok,again_released);
    // The saved descriptor is no longer allocated and its range is free.
    // No allocation follows on this manager; later checks use a new one.
    uvm_report_cb::add(null,probe);
    before_errors=probe.errors;
    manager.release_region(regions[PICK113]);
    $display("UT: round %0d stale_error %0d",round,probe.errors>before_errors);
    $display("DIAG113: round %0d error_notifications %0d",round,probe.errors-before_errors);
    uvm_report_cb::delete(null,probe);
    // Do not inspect or reuse manager/regions/again after the bad call.
    begin
      automatic uvm_mem_mam_cfg control_cfg=config113();
      automatic uvm_mem_mam control=new("independent",control_cfg);
      uvm_mem_region valid,whole;
      bit empty,full;
      valid=control.reserve_region(8,8);
      if(valid==null) $fatal(1,"mam113 independent reservation failed");
      control.release_region(valid);
      empty=members113(control,null,null,null,0);
      whole=control.reserve_region(0,32);
      if(whole==null) $fatal(1,"mam113 independent full-pool reservation failed");
      full=whole.get_start_offset()==0 && whole.get_end_offset()==31 && whole.get_len()==32 &&
           members113(control,whole,null,null,1);
      $display("UT: round %0d independent empty %0d full_pool %0d",round,empty,full);
    end
  end
endtask
