class owner87 extends uvm_reg_block;
  function new(); super.new("owner87",UVM_NO_COVERAGE); endfunction
endclass
class register87 extends uvm_reg;
  function new(string name); super.new(name,16,UVM_NO_COVERAGE); endfunction
endclass
class front87 extends uvm_reg_frontdoor;
  logic [15:0] word_value;
  int calls=0;
  function new(string name,bit[15:0] value); super.new(name); word_value=value; endfunction
  virtual task body();
    calls++; #1;
    if (rw_info.get_kind()==UVM_WRITE) word_value=rw_info.get_value(0);
    else rw_info.set_value(uvm_reg_data_t'(word_value));
    rw_info.set_status(UVM_IS_OK);
  endtask
endclass
class test87 extends uvm_test;
  `uvm_component_utils(test87)
  owner87 owner;
  register87 target,peer;
  uvm_reg_field target_field,peer_field;
  uvm_reg_map first_map,second_map,selected_map;
  front87 first_fd,second_fd,replacement,peer_first,peer_second;
  uvm_sequencer#(uvm_sequence_item) sequencer;
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  function uvm_reg_frontdoor selected(uvm_reg rg,uvm_reg_map map);
    if (MODE==0) return rg.get_frontdoor();
    return rg.get_frontdoor(map);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase); owner=new(); owner.configure();
    target=new("target87"); target.configure(owner); peer=new("peer87"); peer.configure(owner);
    target_field=new("target_value87"); target_field.configure(target,16,0,"RW",0,0,1,0,1);
    peer_field=new("peer_value87"); peer_field.configure(peer,16,0,"RW",0,0,1,0,1);
    first_map=owner.create_map("first87",0,2,UVM_LITTLE_ENDIAN);
    first_map.add_reg(target,'h20); first_map.add_reg(peer,'h40);
    if (MODE>=2) begin
      second_map=owner.create_map("second87",'h100,2,UVM_LITTLE_ENDIAN);
      second_map.add_reg(target,'h60); second_map.add_reg(peer,'h80);
    end
    first_fd=new("first87",'h2345); second_fd=new("second87",'h6789);
    replacement=new("replacement87",'h9abc);
    peer_first=new("peer_first87",'hdef0); peer_second=new("peer_second87",'h1357);
    selected_map=MODE==3 ? second_map : first_map;
    sequencer=new("sequencer87",this); first_map.set_sequencer(sequencer);
    if (MODE>=2) second_map.set_sequencer(sequencer);
    owner.lock_model();
  endfunction
  task run_phase(uvm_phase phase);
    uvm_status_e status;
    uvm_reg_data_t value;
    bit initial_none,queries,access_ok,peer_ok,isolated;
    phase.raise_objection(this);
    initial_none=selected(target,first_map)==null && selected(peer,first_map)==null;
    if (MODE>=2) initial_none &= selected(target,second_map)==null && selected(peer,second_map)==null;
    $display("UT: fd87 %s initial_none %0d",CASE_NAME,initial_none);
    if (MODE==0) begin target.set_frontdoor(first_fd); peer.set_frontdoor(peer_first); end
    else begin target.set_frontdoor(first_fd,first_map); peer.set_frontdoor(peer_first,first_map); end
    if (MODE>=2) begin
      target.set_frontdoor(second_fd,second_map); peer.set_frontdoor(peer_second,second_map);
    end
    queries=selected(target,first_map)==first_fd && selected(peer,first_map)==peer_first;
    if (MODE>=2) queries &= selected(target,second_map)==second_fd && selected(peer,second_map)==peer_second;
    target.read(status,value,UVM_FRONTDOOR,first_map); access_ok=status==UVM_IS_OK && value=='h2345;
    if (MODE>=2) begin
      target.read(status,value,UVM_FRONTDOOR,second_map); access_ok &= status==UVM_IS_OK && value=='h6789;
    end
    $display("UT: fd87 installed queries %0d access %0d",queries,access_ok);
    for (int debug_variant=0;debug_variant<3;debug_variant++) begin
      if (debug_variant==0) target.set_frontdoor(replacement,selected_map);
      else target.set_frontdoor(replacement,selected_map,debug_variant==1 ? "debug87.sv" : "other87.sv",debug_variant==1 ? 987 : 42);
      queries=selected(target,selected_map)==replacement;
      target.read(status,value,UVM_FRONTDOOR,selected_map); access_ok=status==UVM_IS_OK && value=='h9abc;
      isolated=first_fd.word_value==16'h2345 && second_fd.word_value==16'h6789;
      if (MODE>=2) begin
        if (MODE==3) begin
          queries &= selected(target,first_map)==first_fd;
          target.read(status,value,UVM_FRONTDOOR,first_map); isolated &= status==UVM_IS_OK && value=='h2345;
        end else begin
          queries &= selected(target,second_map)==second_fd;
          target.read(status,value,UVM_FRONTDOOR,second_map); isolated &= status==UVM_IS_OK && value=='h6789;
        end
      end
      peer.read(status,value,UVM_FRONTDOOR,first_map);
      peer_ok=status==UVM_IS_OK && value=='hdef0 && selected(peer,first_map)==peer_first;
      if (MODE>=2) begin
        peer.read(status,value,UVM_FRONTDOOR,second_map);
        peer_ok &= status==UVM_IS_OK && value=='h1357 && selected(peer,second_map)==peer_second;
      end
      $display("UT: fd87 debug %0d queries %0d access %0d isolated %0d peer %0d",
        debug_variant,queries,access_ok,isolated,peer_ok);
    end
    target.set_frontdoor(null,selected_map);
    queries=selected(target,selected_map)==null && selected(peer,first_map)==peer_first;
    if (MODE>=2) queries &= selected(target,MODE==3 ? first_map : second_map)==(MODE==3 ? first_fd : second_fd);
    $display("UT: fd87 cleared selected_null_and_peers %0d",queries);
    target.set_frontdoor(MODE==3 ? second_fd : first_fd,selected_map);
    target.read(status,value,UVM_FRONTDOOR,selected_map);
    $display("UT: fd87 restored query %0d access %0d",
      selected(target,selected_map)==(MODE==3 ? second_fd : first_fd),
      status==UVM_IS_OK && value==(MODE==3 ? 'h6789 : 'h2345));
    phase.drop_objection(this);
  endtask
endclass
