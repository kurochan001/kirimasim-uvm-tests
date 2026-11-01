/*
:name: test_coverage_sample_values_recurses_only_through_the_selected_subtree
:description: sample_values recurses through the selected block subtree (IEEE 1800.2-2020 Section 18.1.4.7)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.4.7 18.4.7.8 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_coverage_sample_values_recurses_only_through_the_selected_subtree.expected
*/
// Observe coverage-control metadata and testbench sampling hooks only.
// These counters are not covergroups, bin coverage or a coverage percentage.
module test_coverage_sample_values_recurses_only_through_the_selected_subtree;
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
    automatic model_reg local_reg = new("local_reg");
    automatic model_reg deep_reg = new("deep_reg");
    root.configure(); child.configure(root); grandchild.configure(child); peer.configure();
    local_reg.configure(root); local_reg.build(); deep_reg.configure(grandchild); deep_reg.build();
    root.sample_values();
    $display("UT: root_call root %0d child %0d grandchild %0d local %0d deep %0d peer %0d",
    root.value_samples, child.value_samples, grandchild.value_samples, local_reg.value_samples,
    deep_reg.value_samples, peer.value_samples);
    child.sample_values();
    $display("UT: child_call root %0d child %0d grandchild %0d local %0d deep %0d peer %0d",
    root.value_samples, child.value_samples, grandchild.value_samples, local_reg.value_samples,
    deep_reg.value_samples, peer.value_samples);
    $finish;
  end

endmodule
