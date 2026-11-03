/*
:name: test_register_map_listing_returns_exact_registered_handles_before_and_after_selected_removal
:description: register map listing returns exact registered handles before and after selected removal
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.3.5 18.4.2.5 18.4.3.3 18.2.3.3 18.1.2.3 18.4.2.2 18.5.3.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_map_listing_returns_exact_registered_handles_before_and_after_selected_removal.expected
*/
module test_register_map_listing_returns_exact_registered_handles_before_and_after_selected_removal;
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

  function automatic int members(uvm_reg_map maps[$]);
    int bits=0;
    foreach (maps[i]) begin
      if (maps[i]==first) bits|=1;if (maps[i]==second) bits|=2;if (maps[i]==unused) bits|=4;
    end
    return bits;
  endfunction
  initial begin
    uvm_reg_map maps[$];
    build_model();chosen.get_maps(maps);
    $display("UT: register_maps initial_count %0d",maps.size());
    first.add_reg(chosen,'h20);second.add_reg(chosen,'h20);maps.delete();chosen.get_maps(maps);
    $display("UT: register_maps listed %0d members %0d",maps.size(),members(maps));
    chosen.unregister(first);maps.delete();chosen.get_maps(maps);
    $display("UT: register_maps removed_count %0d remaining_members %0d",maps.size(),members(maps));
    $finish;
  end
endmodule
