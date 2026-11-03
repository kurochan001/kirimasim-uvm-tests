/*
:name: test_map_memory_lookup_byte_units_cover_interior_and_last_locations_and_exclude_gaps
:description: map memory lookup byte units cover interior and last locations and exclude gaps
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.4.18 18.2.3.4 18.2.4.6 18.1.2.3 18.1.2.2 18.1.2.6 18.6.3.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_map_memory_lookup_byte_units_cover_interior_and_last_locations_and_exclude_gaps.expected
*/
module test_map_memory_lookup_byte_units_cover_interior_and_last_locations_and_exclude_gaps;
  import uvm_pkg::*;
  class block_type extends uvm_reg_block;
    function new(string name); super.new(name,UVM_NO_COVERAGE); endfunction
  endclass

  initial begin
    automatic block_type owner=new("owner51");
    automatic uvm_mem chosen=new("chosen51",4,16,"RW",UVM_NO_COVERAGE);
    automatic uvm_mem peer=new("peer51",4,16,"RW",UVM_NO_COVERAGE);
    uvm_reg_map selected,other;
    owner.configure();chosen.configure(owner);peer.configure(owner);
    selected=owner.create_map("selected51",0,1,UVM_LITTLE_ENDIAN,1);
    other=owner.create_map("other51",0,1,UVM_LITTLE_ENDIAN,1);
    selected.add_mem(chosen,'h40);other.add_mem(peer,'h40);owner.lock_model();
    $display("UT: mem_lookup_byte first %0d interior %0d last %0d",
      selected.get_mem_by_offset('h40)==chosen,
      selected.get_mem_by_offset('h43)==chosen,
      selected.get_mem_by_offset('h47)==chosen);
    $display("UT: mem_lookup_byte before_null %0d after_null %0d other_map %0d",
      selected.get_mem_by_offset('h3f)==null,
      selected.get_mem_by_offset('h48)==null,other.get_mem_by_offset('h40)==peer);
    $finish;
  end
endmodule
