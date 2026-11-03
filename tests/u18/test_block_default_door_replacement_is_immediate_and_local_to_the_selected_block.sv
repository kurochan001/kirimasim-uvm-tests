/*
:name: test_block_default_door_replacement_is_immediate_and_local_to_the_selected_block
:description: set_default_door replaces the selected block door and preserves an independent peer (18.1.5.2)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.5.2 18.1.5.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_default_door_replacement_is_immediate_and_local_to_the_selected_block.expected
*/
module test_block_default_door_replacement_is_immediate_and_local_to_the_selected_block;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class block_type extends uvm_reg_block;
    function new(string name); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass
  class reg_type extends uvm_reg;
    function new(string name); super.new(name, 8, UVM_NO_COVERAGE); endfunction
  endclass
  function automatic reg_type add_reg(block_type owner, uvm_reg_map map_value,
                                     string name, uvm_reg_addr_t offset);
    reg_type value = new(name);
    uvm_reg_field field_value = new("value");
    value.configure(owner);
    field_value.configure(value, 8, 0, "RW", 0, 0, 1, 0, 1);
    map_value.add_reg(value, offset, "RW");
    return value;
  endfunction
  initial begin
    automatic block_type owner = new("owner");
    automatic block_type peer = new("peer");
    owner.configure(); peer.configure();
    owner.set_default_door(UVM_BACKDOOR); peer.set_default_door(UVM_FRONTDOOR);
    $display("UT: first selected_backdoor %0d peer_frontdoor %0d",
             owner.get_default_door() == UVM_BACKDOOR, peer.get_default_door() == UVM_FRONTDOOR);
    owner.set_default_door(UVM_FRONTDOOR);
    $display("UT: replaced selected_frontdoor %0d peer_frontdoor %0d",
             owner.get_default_door() == UVM_FRONTDOOR, peer.get_default_door() == UVM_FRONTDOOR);
    owner.set_default_door(UVM_BACKDOOR);
    $display("UT: reused selected_backdoor %0d peer_frontdoor %0d",
             owner.get_default_door() == UVM_BACKDOOR, peer.get_default_door() == UVM_FRONTDOOR);
    $finish;
  end
endmodule
