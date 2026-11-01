/*
:name: test_reg_item_access_metadata_overwrites_are_independent_of_peer_and_value
:description: register item offset priority backdoor kind and source metadata retain latest values (IEEE 1800.2-2020 Section 19.1.1.2.14)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.1.1.2.14 19.1.1.2.5 19.1.1.2.11 19.1.1.2.13 19.1.1.2.15 19.1.1.2.4 19.1.1.3.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_item_access_metadata_overwrites_are_independent_of_peer_and_value.expected
*/
// Exercise the descriptor public API directly, without bus or DUT access.
// Undefined initial enum/data values are never observed. UVM_HAS_X here is
// an explicitly assigned status enum, not a four-state data observation.
module test_reg_item_access_metadata_overwrites_are_independent_of_peer_and_value;
  import uvm_pkg::*;

  `include "uvm_macros.svh"
  class block_type extends uvm_reg_block;
    function new(); super.new("blk", UVM_NO_COVERAGE); endfunction
  endclass
  class reg_type extends uvm_reg;
    function new(); super.new("r", 8, UVM_NO_COVERAGE); endfunction
  endclass
  class mem_type extends uvm_mem;
    function new(); super.new("m", 4, 8, "RW", UVM_NO_COVERAGE); endfunction
  endclass
  class sequence_type extends uvm_sequence;
    function new(string name); super.new(name); endfunction
    virtual task body(); endtask
  endclass
  class warning_probe extends uvm_report_catcher;
    int warnings = 0;
    function new(); super.new("warning_probe"); endfunction
    function action_e catch();
      if (get_severity() == UVM_WARNING) begin warnings++; return CAUGHT; end
      return THROW;
    endfunction
  endclass
  initial begin
    automatic uvm_reg_item first = new("first");
    automatic uvm_reg_item peer = new("peer");


    peer.set_offset(7); peer.set_priority(9); peer.set_bd_kind("RTL"); peer.set_fname("peer.sv");
    peer.set_line(12);
    first.set_value('h5a); first.set_offset(3); first.set_priority(17); first.set_bd_kind("RTL");
    first.set_fname("before.sv"); first.set_line(21);
    $display("UT: initial offset %0d priority %0d kind %s file %s line %0d", first.get_offset(),
    first.get_priority(), first.get_bd_kind(), first.get_fname(), first.get_line());
    first.set_offset('h12345); first.set_priority(31); first.set_bd_kind("GATE");
    first.set_fname("after.sv"); first.set_line(47);
    $display("UT: latest offset %0h priority %0d kind %s file %s line %0d value %0h",
    first.get_offset(), first.get_priority(), first.get_bd_kind(), first.get_fname(),
    first.get_line(), first.get_value());
    $display("UT: peer offset %0d priority %0d kind %s file %s line %0d", peer.get_offset(),
    peer.get_priority(), peer.get_bd_kind(), peer.get_fname(), peer.get_line());

    $finish;
  end

endmodule
