/*
:name: test_register_set_reset_replaces_one_kind_and_distributes_values_to_each_field
:description: register set reset replaces one kind and distributes values to each field
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.4.8 18.4.4.6 18.4.4.5 18.4.4.1 18.4.4.3 18.4.2.2 18.5.3.2 18.1.2.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_set_reset_replaces_one_kind_and_distributes_values_to_each_field.expected
*/
module test_register_set_reset_replaces_one_kind_and_distributes_values_to_each_field;
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
  uvm_reg_field low_bits,high_bits,peer_low,peer_high;
  function automatic void build_model(bit high_reset=1);
    owner=new("owner52");owner.configure();chosen=new("chosen52");peer=new("peer52");
    chosen.configure(owner);peer.configure(owner);
    low_bits=uvm_reg_field::type_id::create("low52");
    high_bits=uvm_reg_field::type_id::create("high52");
    peer_low=uvm_reg_field::type_id::create("low52");
    peer_high=uvm_reg_field::type_id::create("high52");
    low_bits.configure(chosen,8,0,"RW",0,'h11,1,0,0);
    high_bits.configure(chosen,8,8,"RW",0,'hAA,high_reset,0,0);
    peer_low.configure(peer,8,0,"RW",0,'h77,1,0,0);
    peer_high.configure(peer,8,8,"RW",0,'h77,1,0,0);
    chosen.reset();peer.reset();
  endfunction

  initial begin
    build_model();chosen.set_reset('hBEEF,"SOFT");chosen.set_reset('hDEAD);
    $display("UT: register_reset_set hard %0h soft %0h desired_still %0h mirror_still %0h",
      chosen.get_reset(),chosen.get_reset("SOFT"),chosen.get(),chosen.get_mirrored_value());
    chosen.set_reset('hCAFE);chosen.reset();
    $display("UT: register_reset_set replaced %0h desired %0h mirror %0h soft_kept %0h peer %0h",
      chosen.get_reset(),chosen.get(),chosen.get_mirrored_value(),
      chosen.get_reset("SOFT"),peer.get_reset());
    $finish;
  end
endmodule
