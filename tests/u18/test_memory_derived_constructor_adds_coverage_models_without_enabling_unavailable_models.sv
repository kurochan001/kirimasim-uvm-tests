/*
:name: test_memory_derived_constructor_adds_coverage_models_without_enabling_unavailable_models
:description: Derived memory constructors add available coverage models and measurement controls gate unavailable models
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.8.2 18.6.8.3 18.6.8.4 18.6.8.5 18.6.3.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_derived_constructor_adds_coverage_models_without_enabling_unavailable_models.expected
*/
// add_coverage is called only in a subsequently derived constructor.
module test_memory_derived_constructor_adds_coverage_models_without_enabling_unavailable_models;
  import uvm_pkg::*;
  class base_memory extends uvm_mem;
    function new(); super.new("memory56",4,8,"RW",UVM_CVR_REG_BITS); endfunction
  endclass
  class derived_memory extends base_memory;
    function new(); super.new(); add_coverage(UVM_CVR_ADDR_MAP); endfunction
  endclass
  initial begin
    automatic derived_memory memory=new();
    uvm_reg_cvr_t previous;
    $display("UT: added_models base %0d extra %0d union %0d unavailable %0d",
      memory.has_coverage(UVM_CVR_REG_BITS),memory.has_coverage(UVM_CVR_ADDR_MAP),
      memory.has_coverage(UVM_CVR_REG_BITS | UVM_CVR_ADDR_MAP),
      !memory.has_coverage(UVM_CVR_FIELD_VALS));
    previous=memory.set_coverage(UVM_NO_COVERAGE);
    previous=memory.set_coverage(UVM_CVR_ALL);
    $display("UT: enabled_models previous_none %0d union %0d unavailable_off %0d",
      previous==UVM_NO_COVERAGE,memory.get_coverage(UVM_CVR_REG_BITS | UVM_CVR_ADDR_MAP),
      !memory.get_coverage(UVM_CVR_FIELD_VALS));
    previous=memory.set_coverage(UVM_CVR_ADDR_MAP);
    $display("UT: changed_models previous_union %0d selected %0d base_off %0d",
      previous==(UVM_CVR_REG_BITS | UVM_CVR_ADDR_MAP),memory.get_coverage(UVM_CVR_ADDR_MAP),
      !memory.get_coverage(UVM_CVR_REG_BITS));
    $finish;
  end
endmodule
