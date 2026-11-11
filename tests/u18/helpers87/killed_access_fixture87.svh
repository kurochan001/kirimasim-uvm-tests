class owner87 extends uvm_reg_block;
  function new();
    super.new("owner87",UVM_NO_COVERAGE);
  endfunction
endclass
class storage87 extends uvm_reg_backdoor;
  logic [15:0] words[32];
  bit block_enabled=0,block_write=0,entered=0;
  uvm_reg_addr_t block_offset;
  function new();
    super.new("storage87");
  endfunction
  virtual task write(uvm_reg_item rw);
    if (block_enabled && block_write && rw.get_offset()==block_offset) begin
      entered=1;
      wait(!block_enabled);
    end
    #1;
    words[rw.get_offset()]=rw.get_value(0);
    rw.set_status(UVM_IS_OK);
  endtask
  virtual task read(uvm_reg_item rw);
    if (block_enabled && !block_write && rw.get_offset()==block_offset) begin
      entered=1;
      wait(!block_enabled);
    end
    #1;
    rw.set_value(uvm_reg_data_t'(words[rw.get_offset()]));
    rw.set_status(UVM_IS_OK);
  endtask
endclass
class test87 extends uvm_test;
  `uvm_component_utils(test87)
  owner87 owner;
  uvm_mem memory;
  uvm_vreg target,peer;
  uvm_vreg_field target_field,peer_field;
  storage87 storage;
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    owner=new();
    owner.configure();
    memory=new("memory87",32,16,"RW",UVM_NO_COVERAGE);
    memory.configure(owner);
    storage=new();
    memory.set_backdoor(storage);
    owner.default_map=owner.create_map("map87",0,2,UVM_LITTLE_ENDIAN);
    owner.default_map.add_mem(memory,0);
    target=new("target87",16);
    target.configure(owner,memory,3,3,4);
    peer=new("peer87",16);
    peer.configure(owner,memory,1,20,1);
    target_field=new("target_value87");
    target_field.configure(target,16,0);
    peer_field=new("peer_value87");
    peer_field.configure(peer,16,0);
    owner.lock_model();
  endfunction
  task run_phase(uvm_phase phase);
    process victim;
    uvm_status_e status,victim_status;
    uvm_reg_data_t value,victim_value,prior[32];
    longint unsigned selected,next_index;
    int address,next_address;
    bit controls,victim_returned,completed,raw_ok,reset_preserved,follow_ok;
    phase.raise_objection(this);
    for (int round=0;round<2;round++) begin
      selected=round==0 ? 0 : 2;
      next_index=round==0 ? 2 : 0;
      address=3+4*selected;
      next_address=3+4*next_index;
      for (int i=0;i<32;i++) begin
        storage.words[i]=16'h1700 ^ (i*16'h43);
        prior[i]=storage.words[i];
      end
      storage.block_enabled=0;
      target.read(selected,status,value,UVM_BACKDOOR);
      controls=status==UVM_IS_OK && value==prior[address];
      target.read(next_index,status,value,UVM_BACKDOOR);
      controls &= status==UVM_IS_OK && value==prior[next_address];
      peer.read(0,status,value,UVM_BACKDOOR);
      controls &= status==UVM_IS_OK && value==prior[20];
      storage.block_offset=address;
      storage.block_write=MODE>=2;
      storage.entered=0;
      storage.block_enabled=1;
      victim_returned=0;
      fork
        begin
          victim=process::self();
          if (MODE>=2) target.write(selected,victim_status,'h7be9,UVM_BACKDOOR);
          else target.read(selected,victim_status,victim_value,UVM_BACKDOOR);
          victim_returned=1;
        end
      join_none
      wait(storage.entered);
      #2;
      $display("UT: reset87 %s idx %0d controls %0d entered %0d pending %0d",
        CASE_NAME,selected,controls,storage.entered,!victim_returned);
      victim.kill();
      storage.block_enabled=0;
      #2;
      raw_ok=1;
      for (int i=0;i<32;i++) raw_ok &= storage.words[i]==prior[i];
      // A distinct array proves the shared memory/backdoor remains usable.
      peer.write(0,status,'he8c7,UVM_BACKDOOR);
      controls=status==UVM_IS_OK && storage.words[20]==16'he8c7;
      peer.read(0,status,value,UVM_BACKDOOR);
      controls &= status==UVM_IS_OK && value==16'he8c7;
      prior[20]='he8c7;
      if (EXPLICIT_KIND) target.reset("HARD");
      else target.reset();
      reset_preserved=1;
      for (int i=0;i<32;i++) reset_preserved &= storage.words[i]==prior[i];
      completed=0;
      fork
        begin
          if (MODE inside {1,3}) target.write(next_index,status,'hb62a,UVM_BACKDOOR);
          else target.read(next_index,status,value,UVM_BACKDOOR);
          completed=1;
        end
        begin #30; end
      join_any
      disable fork;
      follow_ok=completed && status==UVM_IS_OK;
      if (MODE inside {1,3}) begin
        follow_ok &= storage.words[next_address]==16'hb62a;
        prior[next_address]='hb62a;
      end else follow_ok &= value==prior[next_address];
      $display("UT: reset87 killed %0d raw %0d peer %0d reset_storage %0d",
        !victim_returned,raw_ok,controls,reset_preserved);
      $display("UT: reset87 recovery complete %0d status_data %0d",completed,follow_ok);
      if (!completed) begin
        phase.drop_objection(this);
        return;
      end
      target.read(selected,status,value,UVM_BACKDOOR);
      controls=status==UVM_IS_OK && value==prior[address];
      raw_ok=1;
      for (int i=0;i<32;i++) raw_ok &= storage.words[i]==prior[i];
      $display("UT: reset87 original_index %0d storage %0d",controls,raw_ok);
    end
    phase.drop_objection(this);
  endtask
endclass
