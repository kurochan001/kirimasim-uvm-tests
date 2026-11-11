/*
:name: test_coverage_block_control_recurses_through_nested_models_and_preserves_peer
:description: block coverage control recurses through nested models and preserves peers (IEEE 1800.2-2020 Section 18.1.4.5)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.4.5 18.1.4.3 18.1.4.4 18.4.7.5 18.6.8.4 17.2.2.9 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_coverage_block_control_recurses_through_nested_models_and_preserves_peer.expected
*/
// What it checks:
// 1. Block coverage control reaches descendant blocks, registers and memories
//    while respecting availability.
// 2. Block set_coverage returns the previously enabled local mask.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.1.4.5 (UVM-BLOCK-COVERAGE-RECURSIVE-CONTROL) gives rule 1
//    above. Setup: Enable address/field models at a root with two nested
//    blocks, a register, memory and separate peer. Expected: Each available
//    descendant model turns on and off; the peer stays off and the root lacks
//    FIELD_VALS.
// 2. 1800.2-2020 18.1.4.5 (UVM-BLOCK-COVERAGE-PREVIOUS-MASK-RETURN) gives rule
//    2 above. Setup: Enable and then disable the root address-map model.
//    Expected: The previous masks are NO_COVERAGE then ADDR_MAP.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The pinned library returns the new enabled mask. Retain the standard
// requirement to return the previously enabled mask, including on disable.
// Observe coverage-control metadata and testbench sampling hooks only.
// These counters are not covergroups, bin coverage or a coverage percentage.
module test_coverage_block_control_recurses_through_nested_models_and_preserves_peer;
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
    automatic model_block root = new("root");
    automatic model_block child = new("child");
    automatic model_block grandchild = new("grandchild");
    automatic model_block peer = new("peer");
    automatic model_reg rg = new("r", UVM_CVR_FIELD_VALS);
    automatic model_mem memory = new();
    uvm_reg_cvr_t previous;
    root.configure(); child.configure(root); grandchild.configure(child); peer.configure();
    rg.configure(grandchild); rg.build(); memory.configure(child);
    previous = root.set_coverage(UVM_CVR_ADDR_MAP | UVM_CVR_FIELD_VALS);
    $display("UT: enable previous_off %0d root %0d child %0d grandchild %0d",
    previous == UVM_NO_COVERAGE, root.get_coverage(UVM_CVR_ADDR_MAP),
    child.get_coverage(UVM_CVR_ADDR_MAP), grandchild.get_coverage(UVM_CVR_ADDR_MAP));
    $display("UT: descendants register %0d memory %0d peer_off %0d unavailable %0d",
    rg.get_coverage(UVM_CVR_FIELD_VALS), memory.get_coverage(UVM_CVR_ADDR_MAP),
    !peer.get_coverage(UVM_CVR_ADDR_MAP), root.get_coverage(UVM_CVR_FIELD_VALS));
    previous = root.set_coverage(UVM_NO_COVERAGE);
    $display(
    "UT: disable previous_address %0d root %0d child %0d grandchild %0d register %0d memory %0d",
    previous == UVM_CVR_ADDR_MAP, !root.get_coverage(UVM_CVR_ADDR_MAP),
    !child.get_coverage(UVM_CVR_ADDR_MAP), !grandchild.get_coverage(UVM_CVR_ADDR_MAP),
    !rg.get_coverage(UVM_CVR_FIELD_VALS), !memory.get_coverage(UVM_CVR_ADDR_MAP));
    $finish;
  end

endmodule
