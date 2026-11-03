/*
:name: test_component_hierarchical_recording_calls_virtual_setters_and_preserves_outside_state
:description: component hierarchical recording calls virtual setters and preserves outside state
:tags: uD uvm
:type: simulation
:lrm: 1800.2-2020 D.2.3 13.1.7.13 13.1.7.14 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_hierarchical_recording_calls_virtual_setters_and_preserves_outside_state.expected
*/
module test_component_hierarchical_recording_calls_virtual_setters_and_preserves_outside_state;
  import uvm_pkg::*;
  class recording_actor extends uvm_component;
    int calls=0;
    bit last_enabled=0;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    virtual function void set_recording_enabled(bit enabled);
      calls++; last_enabled=enabled; super.set_recording_enabled(enabled);
    endfunction
  endclass
  initial begin
    automatic recording_actor branch=new("branch47",null);
    automatic recording_actor child=new("child",branch);
    automatic recording_actor leaf=new("leaf",child);
    automatic recording_actor peer=new("peer47",null);
    branch.set_recording_enabled_hier(1);
    $display("UT: hierarchy_record_enabled values %0d calls %0d peer %0d",
             branch.get_recording_enabled() && child.get_recording_enabled() &&
             leaf.get_recording_enabled(),branch.calls==1 && child.calls==1 && leaf.calls==1,
             !peer.get_recording_enabled() && peer.calls==0);
    child.set_recording_enabled_hier(0);
    $display("UT: hierarchy_record_narrowed values %0d calls %0d arguments %0d peer %0d",
             branch.get_recording_enabled() && !child.get_recording_enabled() &&
             !leaf.get_recording_enabled(),branch.calls==1 && child.calls==2 && leaf.calls==2,
             branch.last_enabled && !child.last_enabled && !leaf.last_enabled,
             !peer.get_recording_enabled() && peer.calls==0);
    $finish;
  end
endmodule
