/*
:name: test_register_is_in_map_distinguishes_selected_member_unrelated_and_peer_maps
:description: register is in map distinguishes selected member unrelated and peer maps
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.3.4 18.4.2.5 18.2.3.3 18.1.2.3 18.4.2.2 18.5.3.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_is_in_map_distinguishes_selected_member_unrelated_and_peer_maps.expected
*/
// What it checks:
// 1. is_in_map distinguishes selected actual associations from an unrelated
//    map and peer-only association.
// 2. is_in_map no longer reports the removed selected association while
//    retaining the other one.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.4.3.4 (UVM-REGISTER-CONTRACT-MEMBERSHIP-EXPLICIT) gives
//    rule 1 above. Setup: Use the selected original register/block/file models
//    and explicit public calls. Constructor-only observations do not require
//    mapped physical hardware. Membership is queried through the register view
//    after selected legal registrations/removals; output queues start empty.
//    Expected: is_in_map distinguishes selected actual associations from an
//    unrelated map and peer-only association.
// 2. 1800.2-2020 18.4.3.4 (UVM-REGISTER-CONTRACT-MEMBERSHIP-AFTER-REMOVAL)
//    gives rule 2 above. Setup: Use the selected original register/block/file
//    models and explicit public calls. Constructor-only observations do not
//    require mapped physical hardware. Membership is queried through the
//    register view after selected legal registrations/removals; output queues
//    start empty. Expected: is_in_map no longer reports the removed selected
//    association while retaining the other one.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_register_is_in_map_distinguishes_selected_member_unrelated_and_peer_maps;
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
    build_model();first.add_reg(chosen,'h20);second.add_reg(chosen,'h20);
    $display("UT: register_in_map first %0d second %0d unused %0d peer_first %0d peer_second %0d",
      chosen.is_in_map(first),chosen.is_in_map(second),!chosen.is_in_map(unused),
      !peer.is_in_map(first),peer.is_in_map(second));
    chosen.unregister(first);
    $display("UT: register_in_map removed %0d other_kept %0d",
      !chosen.is_in_map(first),chosen.is_in_map(second));
    $finish;
  end
endmodule
