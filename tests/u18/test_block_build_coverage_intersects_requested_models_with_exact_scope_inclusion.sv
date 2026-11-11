/*
:name: test_block_build_coverage_intersects_requested_models_with_exact_scope_inclusion
:description: block build coverage intersects requested models with exact scope inclusion
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.4.1 18.4.7.1 18.1.2.2 18.1.2.1 17.2.2.9 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_build_coverage_intersects_requested_models_with_exact_scope_inclusion.expected
*/
// What it checks:
// 1. build_coverage observes the selected exact hierarchical inclusion scope
//    set by uvm_reg::include_coverage.
// 2. Only requested models included for the selected block are returned by
//    build_coverage.
// 3. Different selected scope inclusions remain independent and excluded
//    requested models yield no coverage.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.1.4.1 (UVM-BLOCK-CONFIG-BUILD-SCOPE) gives rule 1 above.
//    Setup: Use the selected original block subclasses and public calls.
//    Protected coverage construction is exposed only by a selected original
//    subtype; add_coverage is called only in its constructor. Ignore
//    set_coverage return values, whose independent previous-mask oracle
//    remains unchanged. Expected: build_coverage observes the selected exact
//    hierarchical inclusion scope set by uvm_reg::include_coverage.
// 2. 1800.2-2020 18.1.4.1 (UVM-BLOCK-CONFIG-BUILD-INTERSECTION) gives rule 2
//    above. Setup: Use the selected original block subclasses and public
//    calls. Protected coverage construction is exposed only by a selected
//    original subtype; add_coverage is called only in its constructor. Ignore
//    set_coverage return values, whose independent previous-mask oracle
//    remains unchanged. Expected: Only requested models included for the
//    selected block are returned by build_coverage.
// 3. 1800.2-2020 18.1.4.1 (UVM-BLOCK-CONFIG-BUILD-INDEPENDENCE) gives rule 3
//    above. Setup: Use the selected original block subclasses and public
//    calls. Protected coverage construction is exposed only by a selected
//    original subtype; add_coverage is called only in its constructor. Ignore
//    set_coverage return values, whose independent previous-mask oracle
//    remains unchanged. Expected: Different selected scope inclusions remain
//    independent and excluded requested models yield no coverage.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_block_build_coverage_intersects_requested_models_with_exact_scope_inclusion;
  import uvm_pkg::*;
class block_type extends uvm_reg_block;
  function new(string name); super.new(name,UVM_NO_COVERAGE); endfunction
  function uvm_reg_cvr_t selected(uvm_reg_cvr_t requested);
    return build_coverage(requested);
  endfunction
endclass
initial begin
  automatic block_type root=new("root50");
  automatic block_type child=new("child50");
  automatic block_type peer=new("peer50");
  uvm_reg_cvr_t got;
  root.configure(); child.configure(root); peer.configure();
  uvm_reg::include_coverage("root50.child50",UVM_CVR_REG_BITS|UVM_CVR_FIELD_VALS);
  uvm_reg::include_coverage("peer50",UVM_CVR_ADDR_MAP);
  got=child.selected(UVM_CVR_REG_BITS|UVM_CVR_ADDR_MAP|UVM_CVR_FIELD_VALS);
  $display("UT: build_coverage scope %0d requested_subset %0d",
    got==(UVM_CVR_REG_BITS|UVM_CVR_FIELD_VALS),
    child.selected(UVM_CVR_REG_BITS|UVM_CVR_ADDR_MAP)==UVM_CVR_REG_BITS);
  $display("UT: build_coverage peer %0d excluded %0d repeat %0d",
    peer.selected(UVM_CVR_REG_BITS|UVM_CVR_ADDR_MAP)==UVM_CVR_ADDR_MAP,
    child.selected(UVM_CVR_ADDR_MAP)==UVM_NO_COVERAGE,
    child.selected(UVM_CVR_FIELD_VALS)==UVM_CVR_FIELD_VALS);
  $finish;
end
endmodule
