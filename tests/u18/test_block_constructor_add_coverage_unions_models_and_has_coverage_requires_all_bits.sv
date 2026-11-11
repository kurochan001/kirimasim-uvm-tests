/*
:name: test_block_constructor_add_coverage_unions_models_and_has_coverage_requires_all_bits
:description: block constructor add coverage unions models and has coverage requires all bits
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.4.2 18.1.4.3 18.1.2.1 17.2.2.9 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_constructor_add_coverage_unions_models_and_has_coverage_requires_all_bits.expected
*/
// What it checks:
// 1. Constructor-only add_coverage preserves earlier available models and adds
//    the selected new models.
// 2. Adding a previously included coverage bit together with another bit
//    retains the selected union.
// 3. has_coverage returns true only when all selected requested coverage
//    models are available.
// 4. Coverage availability added to one instance does not add it to the
//    selected peer.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.1.4.2 (UVM-BLOCK-CONFIG-ADD-UNION) gives rule 1 above.
//    Setup: Use the selected original block subclasses and public calls.
//    Protected coverage construction is exposed only by a selected original
//    subtype; add_coverage is called only in its constructor. Ignore
//    set_coverage return values, whose independent previous-mask oracle
//    remains unchanged. Expected: Constructor-only add_coverage preserves
//    earlier available models and adds the selected new models.
// 2. 1800.2-2020 18.1.4.2 (UVM-BLOCK-CONFIG-ADD-REPEATED-BIT) gives rule 2
//    above. Setup: Use the selected original block subclasses and public
//    calls. Protected coverage construction is exposed only by a selected
//    original subtype; add_coverage is called only in its constructor. Ignore
//    set_coverage return values, whose independent previous-mask oracle
//    remains unchanged. Expected: Adding a previously included coverage bit
//    together with another bit retains the selected union.
// 3. 1800.2-2020 18.1.4.3 (UVM-BLOCK-CONFIG-HAS-ALL) gives rule 3 above.
//    Setup: Use the selected original block subclasses and public calls.
//    Protected coverage construction is exposed only by a selected original
//    subtype; add_coverage is called only in its constructor. Ignore
//    set_coverage return values, whose independent previous-mask oracle
//    remains unchanged. Expected: has_coverage returns true only when all
//    selected requested coverage models are available.
// 4. 1800.2-2020 18.1.4.3 (UVM-BLOCK-CONFIG-HAS-INSTANCE-LOCAL) gives rule 4
//    above. Setup: Use the selected original block subclasses and public
//    calls. Protected coverage construction is exposed only by a selected
//    original subtype; add_coverage is called only in its constructor. Ignore
//    set_coverage return values, whose independent previous-mask oracle
//    remains unchanged. Expected: Coverage availability added to one instance
//    does not add it to the selected peer.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_block_constructor_add_coverage_unions_models_and_has_coverage_requires_all_bits;
  import uvm_pkg::*;
class block_type extends uvm_reg_block;
  function new(string name,bit extra);
    super.new(name,UVM_CVR_REG_BITS);
    if (extra) begin
      add_coverage(UVM_CVR_ADDR_MAP);
      add_coverage(UVM_CVR_ADDR_MAP|UVM_CVR_FIELD_VALS);
    end
  endfunction
endclass
initial begin
  automatic block_type selected=new("chosen50",1);
  automatic block_type peer=new("peer50",0);
  $display("UT: add_coverage original %0d added %0d union %0d",
    selected.has_coverage(UVM_CVR_REG_BITS),selected.has_coverage(UVM_CVR_ADDR_MAP),
    selected.has_coverage(UVM_CVR_REG_BITS|UVM_CVR_ADDR_MAP|UVM_CVR_FIELD_VALS));
  $display("UT: has_coverage peer_single %0d peer_all_missing %0d unchanged %0d",
    peer.has_coverage(UVM_CVR_REG_BITS),
    !peer.has_coverage(UVM_CVR_REG_BITS|UVM_CVR_FIELD_VALS),
    !peer.has_coverage(UVM_CVR_ADDR_MAP));
  $finish;
end
endmodule
