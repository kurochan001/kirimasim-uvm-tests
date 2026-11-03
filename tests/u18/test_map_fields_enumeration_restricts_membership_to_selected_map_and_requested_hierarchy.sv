/*
:name: test_map_fields_enumeration_restricts_membership_to_selected_map_and_requested_hierarchy
:description: map fields enumeration restricts membership to selected map and requested hierarchy
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.4.12 18.2.3.5 18.2.3.3 18.2.3.4 18.1.2.2 18.1.2.3 18.1.2.6 18.4.2.2 18.5.3.2 18.6.3.2 18.9.1.1.2 18.10.2.2 18.10.2.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_map_fields_enumeration_restricts_membership_to_selected_map_and_requested_hierarchy.expected
*/
// Counts and handle sets are checked without assigning enumeration order.
module test_map_fields_enumeration_restricts_membership_to_selected_map_and_requested_hierarchy;
  import uvm_pkg::*;
  class block_type extends uvm_reg_block;
    function new(string name); super.new(name,UVM_NO_COVERAGE); endfunction
  endclass

  class reg_type extends uvm_reg;
    uvm_reg_field low_bits,high_bits;
    function new(string name);super.new(name,16,UVM_NO_COVERAGE);endfunction
    function void place(block_type owner,uvm_reg_map m);
      configure(owner);low_bits=new("low51");high_bits=new("high51");
      low_bits.configure(this,8,0,"RW",0,0,1,0,0);
      high_bits.configure(this,8,8,"RW",0,0,1,0,0);m.add_reg(this,'h20);
    endfunction
  endclass
  block_type root,child,deep;
  uvm_reg_map top_map,child_map,deep_map,alternative;
  reg_type root_reg,child_reg,deep_reg,alt_reg;
  uvm_mem root_mem,child_mem,deep_mem,alt_mem;
  uvm_vreg root_virtual,child_virtual,deep_virtual,alt_virtual;
  uvm_vreg_field root_field,child_field,deep_field,alt_field;
  function automatic void build_model();
    root=new("root51");child=new("child51");deep=new("deep51");
    root.configure();child.configure(root);deep.configure(child);
    top_map=root.create_map("top51",'h1000,1,UVM_LITTLE_ENDIAN);
    alternative=root.create_map("alternative51",'h8000,1,UVM_LITTLE_ENDIAN);
    child_map=child.create_map("child_map51",0,1,UVM_LITTLE_ENDIAN);
    deep_map=deep.create_map("deep_map51",0,1,UVM_LITTLE_ENDIAN);
    root_reg=new("r51");child_reg=new("r51");deep_reg=new("r51");alt_reg=new("alt51");
    root_reg.place(root,top_map);child_reg.place(child,child_map);
    deep_reg.place(deep,deep_map);alt_reg.place(root,alternative);
    root_mem=new("m51",16,8,"RW",UVM_NO_COVERAGE);
    child_mem=new("m51",16,8,"RW",UVM_NO_COVERAGE);
    deep_mem=new("m51",16,8,"RW",UVM_NO_COVERAGE);
    alt_mem=new("alt51",16,8,"RW",UVM_NO_COVERAGE);
    root_mem.configure(root);child_mem.configure(child);
    deep_mem.configure(deep);alt_mem.configure(root);
    top_map.add_mem(root_mem,'h100);child_map.add_mem(child_mem,'h100);
    deep_map.add_mem(deep_mem,'h100);alternative.add_mem(alt_mem,'h100);
    root_virtual=new("v51",8);child_virtual=new("v51",8);
    deep_virtual=new("v51",8);alt_virtual=new("alt51",8);
    root_virtual.configure(root,root_mem,1,1,1);
    child_virtual.configure(child,child_mem,1,1,1);
    deep_virtual.configure(deep,deep_mem,1,1,1);
    alt_virtual.configure(root,alt_mem,1,1,1);
    root_field=uvm_vreg_field::type_id::create("f51");
    child_field=uvm_vreg_field::type_id::create("f51");
    deep_field=uvm_vreg_field::type_id::create("f51");
    alt_field=uvm_vreg_field::type_id::create("alt51");
    root_field.configure(root_virtual,8,0);child_field.configure(child_virtual,8,0);
    deep_field.configure(deep_virtual,8,0);alt_field.configure(alt_virtual,8,0);
    top_map.add_submap(child_map,'h400);child_map.add_submap(deep_map,'h400);
    root.lock_model();
  endfunction
  function automatic int members(uvm_reg_field values[$]);
    int bits=0;
    foreach (values[i]) begin
      if (values[i]==root_reg.low_bits) bits |= 1;
      if (values[i]==root_reg.high_bits) bits |= 2;
      if (values[i]==child_reg.low_bits) bits |= 4;
      if (values[i]==child_reg.high_bits) bits |= 8;
      if (values[i]==deep_reg.low_bits) bits |= 16;
      if (values[i]==deep_reg.high_bits) bits |= 32;
      if (values[i]==alt_reg.low_bits) bits |= 64;
      if (values[i]==alt_reg.high_bits) bits |= 128;
    end
    return bits;
  endfunction

  initial begin
    uvm_reg_field local_items[$],recursive_items[$],default_items[$],child_items[$];
    build_model();
    top_map.get_fields(local_items,UVM_NO_HIER);
    top_map.get_fields(recursive_items,UVM_HIER);
    top_map.get_fields(default_items);
    child_map.get_fields(child_items);
    $display("UT: map_fields local_count %0d local_members %0d",
      local_items.size(),members(local_items));
    $display("UT: map_fields recursive_count %0d recursive_members %0d",
      recursive_items.size(),members(recursive_items));
    $display("UT: map_fields default_count %0d default_members %0d",
      default_items.size(),members(default_items));
    $display("UT: map_fields child_count %0d child_members %0d",
      child_items.size(),members(child_items));
    $finish;
  end
endmodule
