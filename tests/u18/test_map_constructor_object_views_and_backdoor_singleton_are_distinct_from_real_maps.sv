/*
:name: test_map_constructor_object_views_and_backdoor_singleton_are_distinct_from_real_maps
:description: map constructor object views and backdoor singleton are distinct from real maps
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.3.1 18.2.1 18.2.2 5.3.4.2 18.1.2.3 18.1.2.2 18.1.3.6 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_map_constructor_object_views_and_backdoor_singleton_are_distinct_from_real_maps.expected
*/
module test_map_constructor_object_views_and_backdoor_singleton_are_distinct_from_real_maps;
  import uvm_pkg::*;
  class block_type extends uvm_reg_block;
    function new(string name); super.new(name,UVM_NO_COVERAGE); endfunction
  endclass

  initial begin
    automatic uvm_reg_map unnamed=new();
    automatic uvm_reg_map named=new("chosen51");
    automatic block_type owner=new("owner51");
    uvm_reg_map real_map,first,second,roundtrip;
    uvm_object object_view;
    uvm_reg_map listed[$];
    owner.configure();real_map=owner.create_map("bus51",0,4,UVM_LITTLE_ENDIAN);
    object_view=named;
    $display("UT: map_new default_name %0d selected_name %0d distinct %0d object %0d",
      unnamed.get_name()=="uvm_reg_map",named.get_name()=="chosen51",unnamed!=named,
      $cast(roundtrip,object_view) && roundtrip==named);
    first=uvm_reg_map::backdoor();second=uvm_reg_map::backdoor();
    owner.get_maps(listed);
    $display("UT: map_backdoor nonnull %0d singleton %0d separate %0d real_list %0d",
      first!=null,first==second,first!=real_map,
      listed.size()==1 && listed[0]==real_map);
    $finish;
  end
endmodule
