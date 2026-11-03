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
