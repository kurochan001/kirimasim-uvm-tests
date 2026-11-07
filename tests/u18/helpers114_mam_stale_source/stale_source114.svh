// Original bounded public snapshots: a descriptor from a request or from a
// virtual-register implementation becomes stale after a valid release and is
// then released through its manager. Membership counts each expected
// descriptor without assuming an iterator order.
function automatic uvm_mem_mam_cfg config114();
  automatic uvm_mem_mam_cfg cfg=new;
  cfg.n_bytes=1; cfg.start_offset=0; cfg.end_offset=31;
  cfg.mode=uvm_mem_mam::GREEDY; cfg.locality=uvm_mem_mam::BROAD;
  return cfg;
endfunction
function automatic bit members114(uvm_mem_mam manager,
    uvm_mem_region r0,r1,int unsigned expected);
  automatic int unsigned seen=0,count=0;
  automatic bit unknown=0;
  automatic uvm_mem_region value=manager.for_each(1);
  while(value!=null && count<8) begin
    count++;
    if (r0!=null && value==r0) seen|=1;
    else if (r1!=null && value==r1) seen|=2;
    else unknown=1;
    value=manager.for_each();
  end
  return value==null && !unknown && seen==expected && count==$countones(expected);
endfunction
class start114 extends uvm_mem_mam_policy;
  uvm_reg_addr_t chosen;
  constraint fixed114 { start_offset==chosen; }
endclass
class error_probe114 extends uvm_report_catcher;
  int errors=0;
  virtual function action_e catch();
    if (get_severity()==UVM_ERROR) begin errors++; return CAUGHT; end
    return THROW;
  endfunction
endclass
class block114 extends uvm_reg_block;
  function new(string name="block114"); super.new(name,UVM_NO_COVERAGE); endfunction
endclass
task automatic exercise114();
  automatic error_probe114 probe=new;
  automatic start114 policy=new;
  uvm_mem_mam manager;
  uvm_vreg vr;
  uvm_mem_region target,peer,again;
  uvm_reg_addr_t first,last;
  int unsigned len,bytes;
  int before_errors;
  bit descriptor_ok,reuse_ok;
  // SOURCE114: 0/1 request then manager/region release; 2/3 virtual-register
  // implement/allocate then virtual-register release.
  if (SOURCE114<2) begin
    automatic uvm_mem_mam_cfg cfg=config114();
    manager=new("selected",cfg);
    peer=manager.reserve_region(0,4);
    policy.chosen=12;
    target=manager.request_region(4,policy);
    if(peer==null || target==null) $fatal(1,"mam114 missing request setup");
    descriptor_ok=target.get_start_offset()==12 && target.get_end_offset()==15 &&
                  target.get_len()==4;
  end
  else begin
    automatic block114 blk=new;
    automatic uvm_mem mem=new("mem114",64,8,"RW",UVM_NO_COVERAGE);
    vr=new("vr114",16);
    blk.configure();
    mem.configure(blk);
    vr.configure(blk);
    // The memory's own manager; reuse below uses the saved byte count.
    manager=mem.mam;
    peer=manager.reserve_region(40,4);
    if(peer==null) $fatal(1,"mam114 missing peer reservation");
    if(SOURCE114==2) begin
      if(!vr.implement(2,mem,2)) $fatal(1,"mam114 implementation failed");
      target=vr.get_region();
    end
    else begin
      policy.chosen=10;
      target=vr.allocate(3,manager,policy);
    end
    if(target==null) $fatal(1,"mam114 missing virtual-register region");
    // The existing virtual-owner test asserts the owner query; here it is
    // diagnostic, and only the getter's descriptor identity is checked.
    descriptor_ok=vr.get_region()==target;
    $display("DIAG114: owner_same %0d owner_null %0d",
             target.get_virtual_registers()==vr,target.get_virtual_registers()==null);
  end
  first=target.get_start_offset(); last=target.get_end_offset();
  len=target.get_len(); bytes=target.get_n_bytes();
  $display("UT: setup members %0d distinct %0d descriptor %0d",
           members114(manager,target,peer,3),target!=peer,descriptor_ok);
  // The valid release that makes the saved descriptor stale.
  if(SOURCE114==0) manager.release_region(target);
  else if(SOURCE114==1) target.release_region();
  else vr.release_region();
  if(SOURCE114<2) $display("UT: released members %0d",members114(manager,target,peer,2));
  else $display("UT: released members %0d unimplemented %0d",
                members114(manager,target,peer,2),vr.get_region()==null);
  // Reuse is observed only while this manager is still in a valid state.
  again=manager.reserve_region(first,bytes);
  if(again==null) $fatal(1,"mam114 valid range reuse failed");
  reuse_ok=again.get_start_offset()==first && again.get_end_offset()==last &&
           again.get_len()==len;
  manager.release_region(again);
  $display("UT: reuse geometry %0d released_again %0d",reuse_ok,
           members114(manager,target,peer,2));
  // The saved descriptor is no longer allocated and its range is free.
  // No allocation follows on this manager; later checks use a new one.
  uvm_report_cb::add(null,probe);
  before_errors=probe.errors;
  manager.release_region(target);
  $display("UT: stale_error %0d",probe.errors>before_errors);
  $display("DIAG114: error_notifications %0d",probe.errors-before_errors);
  uvm_report_cb::delete(null,probe);
  // Do not inspect or reuse manager, vr, target, peer or again after the bad call.
  begin
    automatic uvm_mem_mam_cfg control_cfg=config114();
    automatic uvm_mem_mam control=new("independent",control_cfg);
    uvm_mem_region valid,whole;
    bit empty,full;
    valid=control.reserve_region(8,8);
    if(valid==null) $fatal(1,"mam114 independent reservation failed");
    control.release_region(valid);
    empty=members114(control,null,null,0);
    whole=control.reserve_region(0,32);
    if(whole==null) $fatal(1,"mam114 independent full-pool reservation failed");
    full=whole.get_start_offset()==0 && whole.get_end_offset()==31 && whole.get_len()==32 &&
         members114(control,whole,null,1);
    $display("UT: independent empty %0d full_pool %0d",empty,full);
  end
endtask
