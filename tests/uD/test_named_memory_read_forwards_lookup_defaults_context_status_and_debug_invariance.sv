/*
:name: test_named_memory_read_forwards_lookup_defaults_context_status_and_debug_invariance
:description: named memory read forwards lookup defaults context status and debug invariance
:tags: uD uvm
:type: simulation
:lrm: 1800.2-2020 D.3.4 18.1.3.16 18.6.5.2 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.3 18.2.3.4 18.2.3.10 18.4.2.1 18.4.2.2 18.5.3.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_named_memory_read_forwards_lookup_defaults_context_status_and_debug_invariance.expected
*/
module test_named_memory_read_forwards_lookup_defaults_context_status_and_debug_invariance;
  import uvm_pkg::*;
  class original_block extends uvm_reg_block;
    function new(string name); super.new(name,UVM_NO_COVERAGE); endfunction
  endclass
  class context_sequence extends uvm_sequence#(uvm_sequence_item);
    function new(); super.new("parent49"); endfunction
    virtual task body(); endtask
  endclass
  class extension_token extends uvm_object; endclass
  class target_probe extends uvm_mem;
    int calls=0;
    bit completed=0;
    uvm_reg_data_t seen_data;
    uvm_reg_addr_t seen_offset;
    uvm_door_e seen_path;
    uvm_reg_map seen_map;
    uvm_sequence_base seen_parent;
    int seen_prior;
    uvm_object seen_extension;
    uvm_status_e response=UVM_IS_OK;
    uvm_reg_data_t response_data='h49C1;
    function new(string name); super.new(name,16,32,"RW",UVM_NO_COVERAGE); endfunction
    virtual task read(output uvm_status_e status,input uvm_reg_addr_t offset,
                      output uvm_reg_data_t value,
                      input uvm_door_e path=UVM_DEFAULT_DOOR,input uvm_reg_map map=null,
                      input uvm_sequence_base parent=null,input int prior=-1,
                      input uvm_object extension=null,input string fname="",input int lineno=0);
      calls++; completed=0; seen_path=path; seen_map=map;
      seen_parent=parent; seen_prior=prior; seen_extension=extension;
      seen_offset=offset;
      #2;
      value=response_data;
      status=response; completed=1;
    endtask
  endclass
  initial begin
    automatic original_block root=new("root49");
    automatic original_block child=new("child49");
    automatic target_probe local_target=new("chosen49");
    automatic target_probe peer=new("peer49");
    automatic target_probe conflict=new("chosen49");
    automatic target_probe deep=new("deep49");
    automatic context_sequence parent=new();
    automatic extension_token extension=new();
    automatic uvm_reg_block view=root;
    uvm_reg_map root_map,child_map;
    uvm_status_e status;
    uvm_reg_data_t value;
    time before_call;
    bit good;
    root.configure(); child.configure(root);
    local_target.configure(root); peer.configure(root);
    conflict.configure(child); deep.configure(child);
    root_map=root.create_map("root_map49",'h100,4,UVM_LITTLE_ENDIAN);
    child_map=child.create_map("child_map49",0,4,UVM_LITTLE_ENDIAN);
    root_map.add_mem(local_target,0); root_map.add_mem(peer,'h40);
    child_map.add_mem(conflict,0); child_map.add_mem(deep,'h40);
    root_map.add_submap(child_map,'h100); root.lock_model();
    before_call=$time;
    view.read_mem_by_name(status,"chosen49",5,value);
    $display("UT: named_mem_read local %0d peer %0d conflict %0d blocked %0d status %0d",
             local_target.calls==1,peer.calls==0,conflict.calls==0,
             local_target.completed && $time-before_call>=2,status==UVM_IS_OK);
    $display("UT: named_mem_read defaults path %0d map %0d parent %0d priority %0d extension %0d",
             local_target.seen_path==UVM_DEFAULT_DOOR,local_target.seen_map==null,
             local_target.seen_parent==null,local_target.seen_prior== -1,
             local_target.seen_extension==null);
    $display("UT: named_mem_read data %0d",value=='h49C1);
    $display("UT: named_mem_read offset %0d",local_target.seen_offset==5);
    view.read_mem_by_name(status,"deep49",5,value,UVM_BACKDOOR,child_map,parent,17,extension);
    $display("UT: named_mem_read nested %0d path %0d map %0d parent %0d priority %0d extension %0d",
             deep.calls==1 && local_target.calls==1 && peer.calls==0 && conflict.calls==0,
             deep.seen_path==UVM_BACKDOOR,deep.seen_map==child_map,
             deep.seen_parent==parent,deep.seen_prior==17,deep.seen_extension==extension);
    deep.response=UVM_NOT_OK;
    view.read_mem_by_name(status,"deep49",5,value,UVM_BACKDOOR,child_map,parent,17,extension);
    $display("UT: named_mem_read failure %0d calls %0d",status==UVM_NOT_OK,deep.calls==2);
    // Failed read data has no oracle. Supply success for a new call.
    deep.response=UVM_IS_OK;
    view.read_mem_by_name(status,"deep49",5,value,UVM_BACKDOOR,child_map,parent,17,extension);
    $display("UT: named_mem_read retry %0d data %0d",status==UVM_IS_OK,value=='h49C1);
    view.read_mem_by_name(status,"deep49",5,value,UVM_BACKDOOR,child_map,parent,17,extension,"",0);
    good=status==UVM_IS_OK && deep.seen_path==UVM_BACKDOOR;
    good &= deep.seen_map==child_map && deep.seen_parent==parent;
    good &= deep.seen_prior==17 && deep.seen_extension==extension;
    good &= value=='h49C1 && deep.seen_offset==5;
    $display("UT: named_mem_read debug 0 invariant %0d",good);
    view.read_mem_by_name(status,"deep49",5,value,
      UVM_BACKDOOR,child_map,parent,17,extension,"debug49.sv",431);
    good=status==UVM_IS_OK && deep.seen_path==UVM_BACKDOOR;
    good &= deep.seen_map==child_map && deep.seen_parent==parent;
    good &= deep.seen_prior==17 && deep.seen_extension==extension;
    good &= value=='h49C1 && deep.seen_offset==5;
    $display("UT: named_mem_read debug 1 invariant %0d",good);
    $finish;
  end
endmodule
