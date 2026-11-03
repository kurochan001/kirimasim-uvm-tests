/*
:name: test_register_local_map_null_uses_parent_default_even_with_one_registered_map
:description: register local map null uses parent default even with one registered map
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.3.6 18.1.2.4 18.1.2.5 18.2.3.3 18.1.2.3 18.4.2.2 18.5.3.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_local_map_null_uses_parent_default_even_with_one_registered_map.expected
*/
// Preserve the literal null/default rule, distinct from sole-member selection.
module test_register_local_map_null_uses_parent_default_even_with_one_registered_map;
  import uvm_pkg::*;
  class block_type extends uvm_reg_block;
    function new(string name);super.new(name,UVM_NO_COVERAGE);endfunction
  endclass
  class register_type extends uvm_reg;
    function new(string name,int unsigned width=16,int coverage_models=UVM_NO_COVERAGE);
      super.new(name,width,coverage_models);
    endfunction
  endclass

  block_type owner;
  register_type chosen,peer;
  uvm_reg_map first,second,unused;
  function automatic void build_model();
    uvm_reg_field chosen_bits,peer_bits;
    owner=new("owner52");owner.configure();
    chosen=new("chosen52");peer=new("peer52");
    chosen.configure(owner);peer.configure(owner);
    chosen_bits=uvm_reg_field::type_id::create("chosen_bits52");
    peer_bits=uvm_reg_field::type_id::create("peer_bits52");
    chosen_bits.configure(chosen,16,0,"RW",0,0,1,0,0);
    peer_bits.configure(peer,16,0,"RW",0,0,1,0,0);
    first=owner.create_map("first52",0,2,UVM_LITTLE_ENDIAN);
    second=owner.create_map("second52",'h100,2,UVM_LITTLE_ENDIAN);
    unused=owner.create_map("unused52",'h200,2,UVM_LITTLE_ENDIAN);
    second.add_reg(peer,'h24);
  endfunction

  initial begin
    build_model();first.add_reg(chosen,'h20);owner.set_default_map(second);
    $display("UT: register_local_default parent_default %0d only_member %0d explicit_member %0d",
      owner.get_default_map()==second,chosen.get_n_maps()==1,chosen.get_local_map(first)==first);
    $display("UT: register_local_default null_selects_parent_default %0d",
      chosen.get_local_map(null)==second);
    $finish;
  end
endmodule
