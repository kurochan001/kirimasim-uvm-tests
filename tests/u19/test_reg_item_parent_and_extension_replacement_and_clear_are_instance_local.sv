/*
:name: test_reg_item_parent_and_extension_replacement_and_clear_are_instance_local
:description: register item parent sequence and extension retain exact selected handles (IEEE 1800.2-2020 Section 19.1.1.2.10)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.1.1.2.10 19.1.1.2.12 19.1.1.3.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_item_parent_and_extension_replacement_and_clear_are_instance_local.expected
*/
// What it checks:
// 1. Parent-sequence metadata retains exact replacement/null handles per
//    descriptor.
// 2. Extension metadata retains exact replacement/null object handles per
//    descriptor.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 19.1.1.2.10 (UVM-REG-ITEM-PARENT-REPLACEMENT-CLEAR) gives
//    rule 1 above. Setup: Select alpha, beta and null on first while peer
//    retains alpha. Expected: First follows all three selections and peer
//    still identifies alpha.
// 2. 1800.2-2020 19.1.1.2.12 (UVM-REG-ITEM-EXTENSION-REPLACEMENT-CLEAR) gives
//    rule 2 above. Setup: Select two tokens then null while peer retains the
//    first token. Expected: First follows both exact tokens and clears; peer
//    retains the original token.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Exercise the descriptor public API directly, without bus or DUT access.
// Undefined initial enum/data values are never observed. UVM_HAS_X here is
// an explicitly assigned status enum, not a four-state data observation.
module test_reg_item_parent_and_extension_replacement_and_clear_are_instance_local;
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
  class token extends uvm_object;
    function new(string name); super.new(name); endfunction
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

    automatic sequence_type alpha = new("alpha");
    automatic sequence_type beta = new("beta");
    automatic token first_token = new("first_token");
    automatic token second_token = new("second_token");


    peer.set_parent_sequence(alpha); peer.set_extension(first_token);
    first.set_parent_sequence(alpha); first.set_extension(first_token);
    $display("UT: initial parent %0d extension %0d", first.get_parent_sequence() == alpha,
    first.get_extension() == first_token);
    first.set_parent_sequence(beta); first.set_extension(second_token);
    $display("UT: replaced parent %0d extension %0d", first.get_parent_sequence() == beta,
    first.get_extension() == second_token);
    first.set_parent_sequence(null); first.set_extension(null);
    $display("UT: cleared parent %0d extension %0d peer_parent %0d peer_extension %0d",
    first.get_parent_sequence() == null, first.get_extension() == null,
    peer.get_parent_sequence() == alpha, peer.get_extension() == first_token);

    $finish;
  end

endmodule
