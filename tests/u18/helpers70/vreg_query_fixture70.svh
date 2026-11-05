// Original model-only setup; no physical HDL or storage transfer is claimed.
class block70 extends uvm_reg_block;
  function new(string name="block70");super.new(name,UVM_NO_COVERAGE);endfunction
endclass
class model70;
  block70 owner;
  uvm_mem mem,peer;
  uvm_vreg vr;
  uvm_reg_map rw_map,ro_map,wo_map,peer_map;
  function new(int reg_bits=40,int mem_bits=16,bit shared_maps=1,
      bit word_mode=0,bit dynamic_mode=0,int stride=7,int elements=3);
    owner=new();owner.configure();
    mem=new("mem70",128,mem_bits,"RW",UVM_NO_COVERAGE);mem.configure(owner);
    peer=new("peer70",128,mem_bits,"RW",UVM_NO_COVERAGE);peer.configure(owner);
    rw_map=owner.create_map("rw70",word_mode?'h200:'h1000,2,
      UVM_LITTLE_ENDIAN,!word_mode);
    rw_map.add_mem(mem,word_mode?'h40:'h80,"RW");
    if(shared_maps)begin
      ro_map=owner.create_map("ro70",'h2000,2,UVM_LITTLE_ENDIAN);
      ro_map.add_mem(mem,'h40,"RO");
      wo_map=owner.create_map("wo70",'h3000,2,UVM_LITTLE_ENDIAN);
      wo_map.add_mem(mem,'h20,"WO");
    end
    peer_map=owner.create_map("peer_map70",'h7000,2,UVM_LITTLE_ENDIAN);
    peer_map.add_mem(peer,'h10,"RW");
    vr=new("virtual70",reg_bits);
    if(dynamic_mode)begin
      vr.configure(owner);
      if(!vr.implement(elements,mem,5,stride))$fatal(1,"dynamic setup70 failed");
    end
    else vr.configure(owner,mem,elements,5,stride);
  endfunction
endclass
class query_catcher70 extends uvm_report_catcher;
  bit observing=0;
  int errors=0,warnings=0;
  function new();super.new("query_catcher70");endfunction
  virtual function action_e catch();
    if(observing && get_severity()==UVM_ERROR)begin errors++;return CAUGHT;end
    if(observing && get_severity()==UVM_WARNING)begin warnings++;return CAUGHT;end
    return THROW;
  endfunction
endclass
function automatic int map_count70(uvm_reg_map maps[$],uvm_reg_map selected);
  int count;
  count=0;foreach(maps[i])if(maps[i]==selected)count++;
  return count;
endfunction
