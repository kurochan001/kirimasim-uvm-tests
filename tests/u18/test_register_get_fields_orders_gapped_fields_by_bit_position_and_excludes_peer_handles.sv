/*
:name: test_register_get_fields_orders_gapped_fields_by_bit_position_and_excludes_peer_handles
:description: register get fields orders gapped fields by bit position and excludes peer handles
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.3.11 18.4.3.12 18.5.3.2 18.4.2.2 18.1.2.2 18.1.2.6 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_get_fields_orders_gapped_fields_by_bit_position_and_excludes_peer_handles.expected
*/
module test_register_get_fields_orders_gapped_fields_by_bit_position_and_excludes_peer_handles;
  import uvm_pkg::*;
  class block_type extends uvm_reg_block;
    function new(string name);super.new(name,UVM_NO_COVERAGE);endfunction
  endclass
  class register_type extends uvm_reg;
    function new(string name,int unsigned width=16,int coverage_models=UVM_NO_COVERAGE);
      super.new(name,width,coverage_models);
    endfunction
  endclass

  initial begin
    automatic block_type owner=new("owner52");
    automatic register_type chosen=new("chosen52",24);
    automatic register_type peer=new("peer52",8);
    automatic uvm_reg_field high=uvm_reg_field::type_id::create("high52");
    automatic uvm_reg_field low=uvm_reg_field::type_id::create("low52");
    automatic uvm_reg_field middle=uvm_reg_field::type_id::create("middle52");
    automatic uvm_reg_field other=uvm_reg_field::type_id::create("high52");
    uvm_reg_field fields[$];
    owner.configure();chosen.configure(owner);peer.configure(owner);
    high.configure(chosen,8,16,"RW",0,0,1,0,0);
    low.configure(chosen,4,0,"RW",0,0,1,0,0);
    middle.configure(chosen,4,8,"RW",0,0,1,0,0);other.configure(peer,8,0,"RW",0,0,1,0,0);
    chosen.get_fields(fields);
    $display("UT: register_fields count %0d low %0d middle %0d high %0d",
      fields.size(),fields[0]==low,fields[1]==middle,fields[2]==high);
    $display("UT: register_fields name_local %0d peer_distinct %0d missing_null %0d",
      chosen.get_field_by_name("high52")==high,peer.get_field_by_name("high52")==other,
      chosen.get_field_by_name("missing52")==null);
    owner.lock_model();
    $display("UT: register_fields locked_control chosen %0d peer %0d",
      chosen.get_field_by_name("high52")==high,peer.get_field_by_name("high52")==other);
    $finish;
  end
endmodule
