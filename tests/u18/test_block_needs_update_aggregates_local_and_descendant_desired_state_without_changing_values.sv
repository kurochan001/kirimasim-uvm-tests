/*
:name: test_block_needs_update_aggregates_local_and_descendant_desired_state_without_changing_values
:description: block needs update aggregates local and descendant desired state without changing values
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.5.4 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.3 18.2.3.10 18.4.2.1 18.4.2.2 18.4.4.1 18.4.4.2 18.4.4.3 18.4.4.4 18.4.4.5 18.5.3.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_needs_update_aggregates_local_and_descendant_desired_state_without_changing_values.expected
*/
// What it checks:
// 1. Block needs_update returns true for a selected changed local register or
//    descendant register.
// 2. Block needs_update returns false when the selected root and child model
//    have no changed register.
// 3. Selected block needs_update queries preserve mirror values and the
//    untouched register state.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.1.5.4 (UVM-BLOCK-ACCESS-NEEDS-ANY) gives rule 1 above.
//    Setup: Use the selected original hierarchical register/memory models and
//    their explicit public calls. Named wrapper observations call through a
//    block base view and genuine configured lookup; actual frontdoor cases use
//    the original adapter, sequencer and driver storage. Expected: Block
//    needs_update returns true for a selected changed local register or
//    descendant register.
// 2. 1800.2-2020 18.1.5.4 (UVM-BLOCK-ACCESS-NEEDS-NONE) gives rule 2 above.
//    Setup: Use the selected original hierarchical register/memory models and
//    their explicit public calls. Named wrapper observations call through a
//    block base view and genuine configured lookup; actual frontdoor cases use
//    the original adapter, sequencer and driver storage. Expected: Block
//    needs_update returns false when the selected root and child model have no
//    changed register.
// 3. 1800.2-2020 18.1.5.4 (UVM-BLOCK-ACCESS-NEEDS-MIRROR-PRESERVATION) gives
//    rule 3 above. Setup: Use the selected original hierarchical
//    register/memory models and their explicit public calls. Named wrapper
//    observations call through a block base view and genuine configured
//    lookup; actual frontdoor cases use the original adapter, sequencer and
//    driver storage. Expected: Selected block needs_update queries preserve
//    mirror values and the untouched register state.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module
  test_block_needs_update_aggregates_local_and_descendant_desired_state_without_changing_values;
  import uvm_pkg::*;
  class aggregate_block extends uvm_reg_block;
    function new(string name); super.new(name,UVM_NO_COVERAGE); endfunction
  endclass
  class aggregate_reg extends uvm_reg;
    function new(string name); super.new(name,32,UVM_NO_COVERAGE); endfunction
  endclass
  function automatic void configure_reg(aggregate_reg value,aggregate_block owner);
    uvm_reg_field field_value;
    value.configure(owner); field_value=new("bits49");
    field_value.configure(value,32,0,"RW",0,0,1,0,0); field_value.set_compare(UVM_CHECK);
  endfunction
  initial begin
    automatic aggregate_block root=new("root49");
    automatic aggregate_block child=new("child49");
    automatic aggregate_reg selected=new("selected49");
    automatic aggregate_reg peer=new("peer49");
    automatic aggregate_reg deep=new("deep49");
    uvm_reg_map root_map,child_map;
    bit root_needed,child_needed;
    root.configure(); child.configure(root);
    configure_reg(selected,root); configure_reg(peer,root); configure_reg(deep,child);
    root_map=root.create_map("root_map49",'h100,4,UVM_LITTLE_ENDIAN);
    child_map=child.create_map("child_map49",0,4,UVM_LITTLE_ENDIAN);
    root_map.add_reg(selected,0); root_map.add_reg(peer,4); child_map.add_reg(deep,0);
    root_map.add_submap(child_map,'h80); root.lock_model(); root.reset();
    $display(
      "UT: block_needs baseline root %0d child %0d",root.needs_update(),child.needs_update());
    selected.set('h49A1); root_needed=root.needs_update(); child_needed=child.needs_update();
    $display("UT: block_needs local root %0d child %0d desired %0d mirror %0d peer %0d",
             root_needed,child_needed,selected.get()=='h49A1,
             selected.get_mirrored_value()==0,peer.get()==0 && peer.get_mirrored_value()==0);
    selected.reset(); deep.set('h49D1);
    root_needed=root.needs_update(); child_needed=child.needs_update();
    $display("UT: block_needs nested root %0d child %0d desired %0d mirror %0d local %0d",
             root_needed,child_needed,deep.get()=='h49D1,deep.get_mirrored_value()==0,
             selected.get()==0 && selected.get_mirrored_value()==0);
    deep.reset();
    $display("UT: block_needs cleared root %0d child %0d",root.needs_update(),child.needs_update());
    $finish;
  end
endmodule
