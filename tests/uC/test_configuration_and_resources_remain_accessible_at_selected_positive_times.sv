/*
:name: test_configuration_and_resources_remain_accessible_at_selected_positive_times
:description: configuration and resources remain accessible at selected positive times
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.1 C.4.1 C.4.2 C.4.2.2.1 C.4.2.2.2 C.3.2 C.3.2.3.1 C.3.2.3.6 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_configuration_and_resources_remain_accessible_at_selected_positive_times.expected
*/
// What it checks:
// 1. Selected type-specific resource and configuration access remains
//    available at positive simulation times.
// 2. The configuration convenience layer supplies a selected component
//    property through an explicit typed get.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 C.1 (UVM-RESOURCE-COLLECTION-DATABASE-ANYTIME) gives rule 1
//    above. Setup: Construct original parent/child/peer components and issue
//    explicit integer config and separate string resource requests after
//    positive delays. Expected: At times two and five the explicit APIs retain
//    the selected values and keep the unrelated peer unchanged.
// 2. 1800.2-2020 C.4.1 (UVM-RESOURCE-COLLECTION-CONFIG-COMPONENT-LAYER) gives
//    rule 2 above. Setup: Construct original parent/child/peer components and
//    issue explicit integer config and separate string resource requests after
//    positive delays. Expected: A child explicitly applies its absolute and
//    relative settings while an outside peer is unchanged.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_configuration_and_resources_remain_accessible_at_selected_positive_times;
  import uvm_pkg::*;
  // The component explicitly gets its setting; automatic field application
  // and run_test phase scheduling are not inferred from this original method.
  class consumer extends uvm_component;
    int payload=-1;
    function new(string name,uvm_component parent=null); super.new(name,parent); endfunction
    function bit apply_setting();
      return uvm_config_db#(int)::get(this,"","payload62",payload);
    endfunction
  endclass
  initial begin
    consumer parent,child,peer;
    bit first_get,second_get,resource_get;
    string text;
    parent=new("top62"); child=new("child62",parent); peer=new("peer62",parent);
    #2; uvm_config_db#(int)::set(null,"top62.child62","payload62",11);
    uvm_resource_db#(string)::set("scope62","shared62","first62");
    first_get=child.apply_setting();
    resource_get=uvm_resource_db#(string)::read_by_name("scope62","shared62",text);
    $display("UT: late_database first %0d resource %0d peer %0d",
      first_get && child.payload==11,resource_get && text=="first62",peer.payload==-1);
    #3; uvm_config_db#(int)::set(child,"","payload62",29);
    uvm_resource_db#(string)::set("other62","shared62","second62");
    second_get=child.apply_setting();
    $display("UT: late_database updated %0d positive_time %0d",
      second_get && child.payload==29 && peer.payload==-1,$time==5);
    $finish;
  end
endmodule
