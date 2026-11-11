/*
:name: test_coverage_register_and_memory_controls_return_the_previously_enabled_models
:description: register and memory coverage controls return previously enabled models (IEEE 1800.2-2020 Section 18.4.7.6)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.7.6 18.4.7.4 18.4.7.5 18.6.8.3 18.6.8.4 18.6.8.5 17.2.2.9 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_coverage_register_and_memory_controls_return_the_previously_enabled_models.expected
*/
// What it checks:
// 1. Register availability queries require every requested model to be
//    present.
// 2. Register coverage queries reflect enabled available models and
//    independent peers.
// 3. Register set_coverage returns the previously enabled mask.
// 4. Memory coverage availability reflects the constructor models.
// 5. Memory coverage queries distinguish enabled available models from absent
//    models.
// 6. Memory set_coverage returns the previously enabled mask.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.4.7.4 (UVM-REG-COVERAGE-AVAILABLE-MODELS) gives rule 1
//    above. Setup: Declare REG_BITS/FIELD_VALS but not ADDR_MAP. Expected: The
//    pair is present and ADDR_MAP is absent.
// 2. 1800.2-2020 18.4.7.5 (UVM-REG-COVERAGE-ENABLE-ONLY-AVAILABLE) gives rule
//    2 above. Setup: Enable bits plus unavailable addresses, then replace the
//    mask with fields. Expected: Only bits then only fields are enabled; the
//    peer remains off.
// 3. 1800.2-2020 18.4.7.6 (UVM-REG-COVERAGE-PREVIOUS-MASK-RETURN) gives rule 3
//    above. Setup: Change from off to bits and then from bits to fields. Also
//    observe the off-to-all transition of two constructor-extended register
//    instances after explicitly clearing measurement. Expected: Return masks
//    are NO_COVERAGE then REG_BITS.
// 4. 1800.2-2020 18.6.8.3 (UVM-MEM-COVERAGE-AVAILABLE-MODELS) gives rule 4
//    above. Setup: Construct a memory declaring ADDR_MAP. Expected: The
//    address-map model is available.
// 5. 1800.2-2020 18.6.8.4 (UVM-MEM-COVERAGE-ENABLE-ONLY-AVAILABLE) gives rule
//    5 above. Setup: Request addresses plus unavailable bits, then disable
//    all. Expected: Only addresses turn on and then turn off.
// 6. 1800.2-2020 18.6.8.5 (UVM-MEM-COVERAGE-PREVIOUS-MASK-RETURN) gives rule 6
//    above. Setup: Change from off to addresses and back to off. Expected:
//    Return masks are NO_COVERAGE then ADDR_MAP.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The pinned library returns the new enabled mask. Retain the standard
// requirement to return the previously enabled mask, including on disable.
// Observe coverage-control metadata and testbench sampling hooks only.
// These counters are not covergroups, bin coverage or a coverage percentage.
module test_coverage_register_and_memory_controls_return_the_previously_enabled_models;
  import uvm_pkg::*;

  `include "uvm_macros.svh"
  int completed_bus_operations = 0;
  class model_reg extends uvm_reg;
    uvm_reg_field field;
    int samples = 0;
    int value_samples = 0;
    uvm_reg_data_t seen_data;
    uvm_reg_data_t seen_byte_en;
    uvm_reg_data_t mirror_before;
    bit seen_read;
    uvm_reg_map seen_map;
    int completed_at_sample;
    function new(string name="r", uvm_reg_cvr_t available=UVM_CVR_REG_BITS | UVM_CVR_FIELD_VALS);
      super.new(name, 8, available);
    endfunction
    function void build();
      field = new("value"); field.configure(this, 8, 0, "RW", 0, 0, 1, 0, 1);
    endfunction
    protected virtual function void sample(uvm_reg_data_t data, uvm_reg_data_t byte_en,
    bit is_read, uvm_reg_map map);
      samples++; seen_data = data; seen_byte_en = byte_en; seen_read = is_read;
      seen_map = map; mirror_before = get_mirrored_value();
      completed_at_sample = completed_bus_operations;
    endfunction
    virtual function void sample_values(); value_samples++; endfunction
  endclass
  class model_mem extends uvm_mem;
    int samples = 0;
    int reads = 0;
    int writes = 0;
    bit all_completed = 1;
    bit same_map = 1;
    uvm_reg_map expected_map;
    function new(string name="memory", uvm_reg_cvr_t available=UVM_CVR_ADDR_MAP);
      super.new(name, 4, 8, "RW", available);
    endfunction
    protected virtual function void sample(uvm_reg_addr_t offset, bit is_read, uvm_reg_map map);
      samples++; if (is_read) reads++; else writes++;
      all_completed &= completed_bus_operations >= samples;
      same_map &= map == expected_map;
    endfunction
  endclass
  class model_block extends uvm_reg_block;
    int samples = 0;
    int value_samples = 0;
    uvm_reg_addr_t offsets[$];
    bit directions[$];
    uvm_reg_map maps[$];
    function new(string name="blk", uvm_reg_cvr_t available=UVM_CVR_ADDR_MAP);
      super.new(name, available);
    endfunction
    protected virtual function void sample(uvm_reg_addr_t offset, bit is_read, uvm_reg_map map);
      samples++; offsets.push_back(offset); directions.push_back(is_read); maps.push_back(map);
    endfunction
    virtual function void sample_values(); value_samples++; super.sample_values(); endfunction
  endclass

  initial begin
    automatic model_reg rg = new();
    automatic model_reg peer = new("peer");
    automatic model_mem memory = new();
    uvm_reg_cvr_t previous;
    $display("UT: available reg %0d absent %0d memory %0d initially_off %0d",
    rg.has_coverage(UVM_CVR_REG_BITS | UVM_CVR_FIELD_VALS), rg.has_coverage(UVM_CVR_ADDR_MAP),
    memory.has_coverage(UVM_CVR_ADDR_MAP), !rg.get_coverage(UVM_CVR_REG_BITS) &&
    !memory.get_coverage(UVM_CVR_ADDR_MAP));
    previous = rg.set_coverage(UVM_CVR_REG_BITS | UVM_CVR_ADDR_MAP);
    $display("UT: reg previous_off %0d bits %0d unavailable %0d peer_off %0d",
    previous == UVM_NO_COVERAGE, rg.get_coverage(UVM_CVR_REG_BITS),
    rg.get_coverage(UVM_CVR_ADDR_MAP), !peer.get_coverage(UVM_CVR_REG_BITS));
    previous = rg.set_coverage(UVM_CVR_FIELD_VALS);
    $display("UT: reg previous_bits %0d fields %0d bits_off %0d", previous == UVM_CVR_REG_BITS,
    rg.get_coverage(UVM_CVR_FIELD_VALS), !rg.get_coverage(UVM_CVR_REG_BITS));
    previous = memory.set_coverage(UVM_CVR_ADDR_MAP | UVM_CVR_REG_BITS);
    $display("UT: memory previous_off %0d address %0d unavailable %0d",
    previous == UVM_NO_COVERAGE, memory.get_coverage(UVM_CVR_ADDR_MAP),
    memory.get_coverage(UVM_CVR_REG_BITS));
    previous = memory.set_coverage(UVM_NO_COVERAGE);
    $display("UT: memory previous_address %0d disabled %0d", previous == UVM_CVR_ADDR_MAP,
    !memory.get_coverage(UVM_CVR_ADDR_MAP));
    $finish;
  end

endmodule
