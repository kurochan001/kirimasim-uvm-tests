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
