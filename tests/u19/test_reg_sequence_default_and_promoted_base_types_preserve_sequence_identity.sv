/*
:name: test_reg_sequence_default_and_promoted_base_types_preserve_sequence_identity
:description: reg sequence default and promoted base types preserve sequence identity (IEEE 1800.2-2020 Section 19.4.1.1)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.4.1.1 19.4.1.2 14.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_sequence_default_and_promoted_base_types_preserve_sequence_identity.expected
*/
// What it checks:
// 1. The omitted BASE selects a sequence of register items.
// 2. An original register sequence can promote BASE and extend a supplied user
//    base sequence.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 19.4.1.1 (UVM-REG-PIPELINE-SEQUENCE-DEFAULT-BASE) gives rule
//    1 above. Setup: Assign an original default specialization to the exact
//    uvm_sequence of uvm_reg_item type. Expected: The exact base view denotes
//    the same sequence.
// 2. 1800.2-2020 19.4.1.2 (UVM-REG-PIPELINE-SEQUENCE-PROMOTED-BASE) gives rule
//    2 above. Setup: Supply an original packet-typed sequence base with an
//    inherited marker. Expected: Exact custom and packet-sequence views retain
//    identity and the inherited marker.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Positive default and explicitly promoted BASE compatibility only. Real
// sequencer execution is checked in separate translation cases; malformed
// base types and arbitrary user inheritance chains are not certified.
module test_reg_sequence_default_and_promoted_base_types_preserve_sequence_identity;
  import uvm_pkg::*;
  class packet extends uvm_sequence_item; endclass
  class custom_base extends uvm_sequence#(packet);
    int marker = 47;
    function new(string name = "custom"); super.new(name); endfunction
    virtual task body(); endtask
  endclass
  class promoted #(type BASE = uvm_sequence#(uvm_reg_item)) extends uvm_reg_sequence#(BASE);
    function new(); super.new("promoted"); endfunction
    virtual task body(); endtask
  endclass
  initial begin
    automatic promoted#() first = new();
    automatic promoted#(custom_base) second = new();
    automatic uvm_sequence#(uvm_reg_item) default_view = first;
    automatic custom_base custom_view = second;
    automatic uvm_sequence#(packet) typed_view = second;
    $display("UT: reg_sequence_types default %0d custom %0d typed %0d marker %0d",
             default_view == first,custom_view == second,typed_view == second,custom_view.marker);
    $finish;
  end
endmodule
