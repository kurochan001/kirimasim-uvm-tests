/*
:name: test_register_unregister_removes_only_selected_associations_and_reaches_zero_membership
:description: register unregister removes only selected associations and reaches zero membership
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.2.5 18.4.3.3 18.4.3.4 18.2.3.3 18.1.2.3 18.4.2.2 18.5.3.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_unregister_removes_only_selected_associations_and_reaches_zero_membership.expected
*/
module test_register_unregister_removes_only_selected_associations_and_reaches_zero_membership;
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
    build_model();
    $display("UT: register_unregister initial %0d peer %0d",chosen.get_n_maps(),peer.get_n_maps());
    first.add_reg(chosen,'h20);
    $display("UT: register_unregister added_one %0d",chosen.get_n_maps());
    second.add_reg(chosen,'h20);
    $display("UT: register_unregister added_two %0d",chosen.get_n_maps());
    chosen.unregister(first);
    $display("UT: register_unregister selected_removed %0d kept %0d count %0d peer %0d",
      !chosen.is_in_map(first),chosen.is_in_map(second),chosen.get_n_maps(),peer.is_in_map(second));
    chosen.unregister(second);
    $display("UT: register_unregister empty %0d peer_kept %0d",
      chosen.get_n_maps()==0,peer.get_n_maps()==1);
    $finish;
  end
endmodule
