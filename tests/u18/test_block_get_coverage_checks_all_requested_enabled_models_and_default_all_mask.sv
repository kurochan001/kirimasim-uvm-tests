/*
:name: test_block_get_coverage_checks_all_requested_enabled_models_and_default_all_mask
:description: block get coverage checks all requested enabled models and default all mask
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.4.4 18.1.4.5 18.1.4.3 18.1.2.1 17.2.2.9 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_get_coverage_checks_all_requested_enabled_models_and_default_all_mask.expected
*/
// What it checks:
// 1. get_coverage requires every requested measurement model to be enabled.
// 2. Omitted get_coverage is_on uses UVM_CVR_ALL, matching the explicit
//    all-model query.
// 3. Disabling selected coverage measurement changes get_coverage without
//    removing advertised availability.
// 4. Enabling the selected block does not enable an explicitly disabled
//    independent peer.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.1.4.4 (UVM-BLOCK-CONFIG-GET-ALL-REQUESTED) gives rule 1
//    above. Setup: Use the selected original block subclasses and public
//    calls. Protected coverage construction is exposed only by a selected
//    original subtype; add_coverage is called only in its constructor. Ignore
//    set_coverage return values, whose independent previous-mask oracle
//    remains unchanged. Expected: get_coverage requires every requested
//    measurement model to be enabled.
// 2. 1800.2-2020 18.1.4.4 (UVM-BLOCK-CONFIG-GET-DEFAULT-ALL) gives rule 2
//    above. Setup: Use the selected original block subclasses and public
//    calls. Protected coverage construction is exposed only by a selected
//    original subtype; add_coverage is called only in its constructor. Ignore
//    set_coverage return values, whose independent previous-mask oracle
//    remains unchanged. Expected: Omitted get_coverage is_on uses UVM_CVR_ALL,
//    matching the explicit all-model query.
// 3. 1800.2-2020 18.1.4.4 (UVM-BLOCK-CONFIG-GET-AVAILABLE-VERSUS-ON) gives
//    rule 3 above. Setup: Use the selected original block subclasses and
//    public calls. Protected coverage construction is exposed only by a
//    selected original subtype; add_coverage is called only in its
//    constructor. Ignore set_coverage return values, whose independent
//    previous-mask oracle remains unchanged. Expected: Disabling
//    selected coverage measurement changes get_coverage without removing
//    advertised availability.
// 4. 1800.2-2020 18.1.4.4 (UVM-BLOCK-CONFIG-GET-LOCAL-PEER) gives rule 4
//    above. Setup: Use the selected original block subclasses and public
//    calls. Protected coverage construction is exposed only by a selected
//    original subtype; add_coverage is called only in its constructor. Ignore
//    set_coverage return values, whose independent previous-mask oracle
//    remains unchanged. Expected: Enabling the selected block does not enable
//    an explicitly disabled independent peer.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Coverage metadata only; ignore set_coverage return, audited separately.
module test_block_get_coverage_checks_all_requested_enabled_models_and_default_all_mask;
  import uvm_pkg::*;
class block_type extends uvm_reg_block;
  function new(string name="",int available=UVM_NO_COVERAGE);
    super.new(name,available);
  endfunction
endclass

initial begin
  automatic block_type subset=new("subset50",UVM_CVR_REG_BITS|UVM_CVR_FIELD_VALS);
  automatic block_type all_models=new("all50",UVM_CVR_ALL);
  automatic block_type peer=new("peer50",UVM_CVR_REG_BITS|UVM_CVR_FIELD_VALS);
  void'(peer.set_coverage(UVM_NO_COVERAGE));
  void'(subset.set_coverage(UVM_CVR_REG_BITS));
  $display("UT: get_coverage subset enabled %0d combined_off %0d default_all_off %0d",
    subset.get_coverage(UVM_CVR_REG_BITS),
    !subset.get_coverage(UVM_CVR_REG_BITS|UVM_CVR_FIELD_VALS),!subset.get_coverage());
  void'(subset.set_coverage(UVM_CVR_REG_BITS|UVM_CVR_FIELD_VALS));
  void'(all_models.set_coverage(UVM_CVR_ALL));
  $display("UT: get_coverage combined_on %0d default_equals_all %0d all_on %0d peer_off %0d",
    subset.get_coverage(UVM_CVR_REG_BITS|UVM_CVR_FIELD_VALS),
    all_models.get_coverage()==all_models.get_coverage(UVM_CVR_ALL),
    all_models.get_coverage(),!peer.get_coverage(UVM_CVR_REG_BITS));
  void'(subset.set_coverage(UVM_NO_COVERAGE));
  $display("UT: get_coverage disabled %0d still_available %0d",
    !subset.get_coverage(UVM_CVR_REG_BITS),subset.has_coverage(UVM_CVR_REG_BITS));
  $finish;
end
endmodule
