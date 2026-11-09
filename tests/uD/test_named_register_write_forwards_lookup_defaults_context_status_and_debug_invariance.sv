/*
:name: test_named_register_write_forwards_lookup_defaults_context_status_and_debug_invariance
:description: named register write forwards lookup defaults context status and debug invariance
:tags: uD uvm
:type: simulation
:lrm: 1800.2-2020 D.3.1 18.1.3.14 18.4.4.9 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.3 18.2.3.4 18.2.3.10 18.4.2.1 18.4.2.2 18.5.3.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_named_register_write_forwards_lookup_defaults_context_status_and_debug_invariance.expected
*/
// What it checks:
// 1. The named register write chooses the local simple-name match before a
//    same-name descendant.
// 2. The named register write finds the selected descendant when the local
//    block has no such name.
// 3. The named register write preserves the selected supplied data.
// 4. The wrapper forwards UVM_DEFAULT_DOOR when omitted and the selected
//    explicit door when supplied.
// 5. The wrapper forwards the omitted null map or the selected explicit map
//    handle.
// 6. The wrapper forwards omitted null or the exact supplied parent-sequence
//    handle.
// 7. The wrapper forwards the omitted priority minus one and the supplied
//    explicit priority.
// 8. The wrapper forwards omitted null or the exact supplied extension handle.
// 9. The named task waits for the selected delayed target task to complete
//    before returning.
// 10. The named wrapper returns the selected target failure status.
// 11. A later valid named access returns the new successful target status and
//     selected data.
// 12. Changing the debug-only filename and line number preserves the selected
//     named access functional outcome.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 D.3.1 (UVM-BLOCK-ACCESS-REG-WRITE-LOCAL-LOOKUP) gives rule 1
//    above. Setup: Use the selected original hierarchical register/memory
//    models and their explicit public calls. Named wrapper observations call
//    through a block base view and genuine configured lookup; actual frontdoor
//    cases use the original adapter, sequencer and driver storage. Expected:
//    The named register write chooses the local simple-name match before a
//    same-name descendant.
// 2. 1800.2-2020 D.3.1 (UVM-BLOCK-ACCESS-REG-WRITE-NESTED-LOOKUP) gives rule 2
//    above. Setup: Use the selected original hierarchical register/memory
//    models and their explicit public calls. Named wrapper observations call
//    through a block base view and genuine configured lookup; actual frontdoor
//    cases use the original adapter, sequencer and driver storage. Expected:
//    The named register write finds the selected descendant when the local
//    block has no such name.
// 3. 1800.2-2020 D.3.1 (UVM-BLOCK-ACCESS-REG-WRITE-DATA) gives rule 3 above.
//    Setup: Use the selected original hierarchical register/memory models and
//    their explicit public calls. Named wrapper observations call through a
//    block base view and genuine configured lookup; actual frontdoor cases use
//    the original adapter, sequencer and driver storage. Expected: The named
//    register write preserves the selected supplied data.
// 4. 1800.2-2020 D.3.1 (UVM-BLOCK-ACCESS-REG-WRITE-PATH) gives rule 4 above.
//    Setup: Use the selected original hierarchical register/memory models and
//    their explicit public calls. Named wrapper observations call through a
//    block base view and genuine configured lookup; actual frontdoor cases use
//    the original adapter, sequencer and driver storage. Expected: The wrapper
//    forwards UVM_DEFAULT_DOOR when omitted and the selected explicit door
//    when supplied.
// 5. 1800.2-2020 D.3.1 (UVM-BLOCK-ACCESS-REG-WRITE-MAP) gives rule 5 above.
//    Setup: Use the selected original hierarchical register/memory models and
//    their explicit public calls. Named wrapper observations call through a
//    block base view and genuine configured lookup; actual frontdoor cases use
//    the original adapter, sequencer and driver storage. Expected: The wrapper
//    forwards the omitted null map or the selected explicit map handle.
// 6. 1800.2-2020 D.3.1 (UVM-BLOCK-ACCESS-REG-WRITE-PARENT) gives rule 6 above.
//    Setup: Use the selected original hierarchical register/memory models and
//    their explicit public calls. Named wrapper observations call through a
//    block base view and genuine configured lookup; actual frontdoor cases use
//    the original adapter, sequencer and driver storage. Expected: The wrapper
//    forwards omitted null or the exact supplied parent-sequence handle.
// 7. 1800.2-2020 D.3.1 (UVM-BLOCK-ACCESS-REG-WRITE-PRIORITY) gives rule 7
//    above. Setup: Use the selected original hierarchical register/memory
//    models and their explicit public calls. Named wrapper observations call
//    through a block base view and genuine configured lookup; actual frontdoor
//    cases use the original adapter, sequencer and driver storage. Expected:
//    The wrapper forwards the omitted priority minus one and the supplied
//    explicit priority.
// 8. 1800.2-2020 D.3.1 (UVM-BLOCK-ACCESS-REG-WRITE-EXTENSION) gives rule 8
//    above. Setup: Use the selected original hierarchical register/memory
//    models and their explicit public calls. Named wrapper observations call
//    through a block base view and genuine configured lookup; actual frontdoor
//    cases use the original adapter, sequencer and driver storage. Expected:
//    The wrapper forwards omitted null or the exact supplied extension handle.
// 9. 1800.2-2020 D.3.1 (UVM-BLOCK-ACCESS-REG-WRITE-BLOCKING) gives rule 9
//    above. Setup: Use the selected original hierarchical register/memory
//    models and their explicit public calls. Named wrapper observations call
//    through a block base view and genuine configured lookup; actual frontdoor
//    cases use the original adapter, sequencer and driver storage. Expected:
//    The named task waits for the selected delayed target task to complete
//    before returning.
// 10. 1800.2-2020 D.3.1 (UVM-BLOCK-ACCESS-REG-WRITE-FAILURE-STATUS) gives rule
//     10 above. Setup: Use the selected original hierarchical register/memory
//     models and their explicit public calls. Named wrapper observations call
//     through a block base view and genuine configured lookup; actual
//     frontdoor cases use the original adapter, sequencer and driver storage.
//     Expected: The named wrapper returns the selected target failure status.
// 11. 1800.2-2020 D.3.1 (UVM-BLOCK-ACCESS-REG-WRITE-RETRY) gives rule 11
//     above. Setup: Use the selected original hierarchical register/memory
//     models and their explicit public calls. Named wrapper observations call
//     through a block base view and genuine configured lookup; actual
//     frontdoor cases use the original adapter, sequencer and driver storage.
//     Expected: A later valid named access returns the new successful target
//     status and selected data.
// 12. 1800.2-2020 D.3.1 (UVM-BLOCK-ACCESS-REG-WRITE-DEBUG-INVARIANCE) gives
//     rule 12 above. Setup: Use the selected original hierarchical
//     register/memory models and their explicit public calls. Named wrapper
//     observations call through a block base view and genuine configured
//     lookup; actual frontdoor cases use the original adapter, sequencer and
//     driver storage. Expected: Changing the debug-only filename and line
//     number preserves the selected named access functional outcome.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_named_register_write_forwards_lookup_defaults_context_status_and_debug_invariance;
  import uvm_pkg::*;
  class original_block extends uvm_reg_block;
    function new(string name); super.new(name,UVM_NO_COVERAGE); endfunction
  endclass
  class context_sequence extends uvm_sequence#(uvm_sequence_item);
    function new(); super.new("parent49"); endfunction
    virtual task body(); endtask
  endclass
  class extension_token extends uvm_object; endclass
  class target_probe extends uvm_reg;
    int calls=0;
    bit completed=0;
    uvm_reg_data_t seen_data;
    uvm_reg_addr_t seen_offset;
    uvm_door_e seen_path;
    uvm_reg_map seen_map;
    uvm_sequence_base seen_parent;
    int seen_prior;
    uvm_object seen_extension;
    uvm_status_e response=UVM_IS_OK;
    uvm_reg_data_t response_data='h49C1;
    function new(string name); super.new(name,32,UVM_NO_COVERAGE); endfunction
    virtual task write(output uvm_status_e status, input uvm_reg_data_t value,
                      input uvm_door_e path=UVM_DEFAULT_DOOR,input uvm_reg_map map=null,
                      input uvm_sequence_base parent=null,input int prior=-1,
                      input uvm_object extension=null,input string fname="",input int lineno=0);
      calls++; completed=0; seen_path=path; seen_map=map;
      seen_parent=parent; seen_prior=prior; seen_extension=extension;
      seen_data=value;
      #2;

      status=response; completed=1;
    endtask
  endclass
  function automatic void configure_target(target_probe target,original_block owner);
    uvm_reg_field field_value;
    target.configure(owner); field_value=new("bits49");
    field_value.configure(target,32,0,"RW",0,0,1,0,0);
  endfunction
  initial begin
    automatic original_block root=new("root49");
    automatic original_block child=new("child49");
    automatic target_probe local_target=new("chosen49");
    automatic target_probe peer=new("peer49");
    automatic target_probe conflict=new("chosen49");
    automatic target_probe deep=new("deep49");
    automatic context_sequence parent=new();
    automatic extension_token extension=new();
    automatic uvm_reg_block view=root;
    uvm_reg_map root_map,child_map;
    uvm_status_e status;
    uvm_reg_data_t value;
    time before_call;
    bit good;
    root.configure(); child.configure(root);
    configure_target(local_target,root); configure_target(peer,root);
    configure_target(conflict,child); configure_target(deep,child);
    root_map=root.create_map("root_map49",'h100,4,UVM_LITTLE_ENDIAN);
    child_map=child.create_map("child_map49",0,4,UVM_LITTLE_ENDIAN);
    root_map.add_reg(local_target,0); root_map.add_reg(peer,4);
    child_map.add_reg(conflict,0); child_map.add_reg(deep,4);
    root_map.add_submap(child_map,'h100); root.lock_model();
    before_call=$time;
    view.write_reg_by_name(status,"chosen49",'h49A0);
    $display("UT: named_reg_write local %0d peer %0d conflict %0d blocked %0d status %0d",
             local_target.calls==1,peer.calls==0,conflict.calls==0,
             local_target.completed && $time-before_call>=2,status==UVM_IS_OK);
    $display("UT: named_reg_write defaults path %0d map %0d parent %0d priority %0d extension %0d",
             local_target.seen_path==UVM_DEFAULT_DOOR,local_target.seen_map==null,
             local_target.seen_parent==null,local_target.seen_prior== -1,
             local_target.seen_extension==null);
    $display("UT: named_reg_write data %0d",local_target.seen_data=='h49A0);
    view.write_reg_by_name(status,"deep49",'h49A0,UVM_BACKDOOR,child_map,parent,17,extension);
    $display(
      "UT: named_reg_write nested %0d path %0d map %0d parent %0d priority %0d extension %0d",
             deep.calls==1 && local_target.calls==1 && peer.calls==0 && conflict.calls==0,
             deep.seen_path==UVM_BACKDOOR,deep.seen_map==child_map,
             deep.seen_parent==parent,deep.seen_prior==17,deep.seen_extension==extension);
    deep.response=UVM_NOT_OK;
    view.write_reg_by_name(status,"deep49",'h49A0,UVM_BACKDOOR,child_map,parent,17,extension);
    $display("UT: named_reg_write failure %0d calls %0d",status==UVM_NOT_OK,deep.calls==2);
    // Failed read data has no oracle. Supply success for a new call.
    deep.response=UVM_IS_OK;
    view.write_reg_by_name(status,"deep49",'h49A0,UVM_BACKDOOR,child_map,parent,17,extension);
    $display("UT: named_reg_write retry %0d data %0d",status==UVM_IS_OK,deep.seen_data=='h49A0);
    view.write_reg_by_name(status,"deep49",'h49A0,UVM_BACKDOOR,child_map,parent,17,extension,"",0);
    good=status==UVM_IS_OK && deep.seen_path==UVM_BACKDOOR;
    good &= deep.seen_map==child_map && deep.seen_parent==parent;
    good &= deep.seen_prior==17 && deep.seen_extension==extension;
    good &= deep.seen_data=='h49A0;
    $display("UT: named_reg_write debug 0 invariant %0d",good);
    view.write_reg_by_name(status,"deep49",'h49A0,
      UVM_BACKDOOR,child_map,parent,17,extension,"debug49.sv",431);
    good=status==UVM_IS_OK && deep.seen_path==UVM_BACKDOOR;
    good &= deep.seen_map==child_map && deep.seen_parent==parent;
    good &= deep.seen_prior==17 && deep.seen_extension==extension;
    good &= deep.seen_data=='h49A0;
    $display("UT: named_reg_write debug 1 invariant %0d",good);
    $finish;
  end
endmodule
