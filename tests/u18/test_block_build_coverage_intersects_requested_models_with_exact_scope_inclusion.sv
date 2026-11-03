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
