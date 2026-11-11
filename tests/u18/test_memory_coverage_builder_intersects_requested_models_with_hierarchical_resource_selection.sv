/*
:name: test_memory_coverage_builder_intersects_requested_models_with_hierarchical_resource_selection
:description: Memory protected coverage builder uses hierarchical include resources and intersects requested models
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.8.1 18.4.7.1 18.6.3.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_coverage_builder_intersects_requested_models_with_hierarchical_resource_selection.expected
*/
// What it checks:
// The memory coverage builder returns requested models selected by
// include_coverage resources.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.6.8.1 (UVM-MEMORY-AUDIT-COVERAGE-BUILD-SELECTION) gives the
// rule above. Setup: Configured sibling memories use exact hierarchical
// include scopes; an original public wrapper calls the protected nonvirtual
// builder after configuration. Expected: The selected memory returns the
// selected union and requested intersection; the explicitly excluded sibling
// returns no models.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Coverage availability metadata only; no covergroup/bin completion claim.
module
  test_memory_coverage_builder_intersects_requested_models_with_hierarchical_resource_selection;
  import uvm_pkg::*;

  class block_type extends uvm_reg_block;
    function new(string name="owner56"); super.new(name,UVM_NO_COVERAGE); endfunction
  endclass

  class memory_type extends uvm_mem;
    function new(string name); super.new(name,4,8); endfunction
    function uvm_reg_cvr_t selected(uvm_reg_cvr_t requested);
      return build_coverage(requested);
    endfunction
  endclass
  initial begin
    automatic block_type owner=new();
    automatic memory_type selected_mem=new("selected56");
    automatic memory_type excluded_mem=new("excluded56");
    owner.configure(); selected_mem.configure(owner); excluded_mem.configure(owner);
    uvm_reg::include_coverage("owner56.selected56",UVM_CVR_ADDR_MAP | UVM_CVR_REG_BITS);
    uvm_reg::include_coverage("owner56.excluded56",UVM_NO_COVERAGE);
    $display("UT: coverage_builder selected %0d intersection %0d excluded %0d",
      selected_mem.selected(UVM_CVR_ALL)==(UVM_CVR_ADDR_MAP | UVM_CVR_REG_BITS),
      selected_mem.selected(UVM_CVR_REG_BITS | UVM_CVR_FIELD_VALS)==UVM_CVR_REG_BITS,
      excluded_mem.selected(UVM_CVR_ALL)==UVM_NO_COVERAGE);
    $finish;
  end
endmodule
