/*
:name: test_memory_frontdoor_selection_is_per_map_and_debug_metadata_preserves_real_access
:description: Memory frontdoor setters select distinct map-local storage and preserve access under debug arguments
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.6.1 18.6.6.2 18.6.5.1 18.6.5.2 19.4.2.3 18.2.3.4 18.2.4.18 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_frontdoor_selection_is_per_map_and_debug_metadata_preserves_real_access.expected
*/
module test_memory_frontdoor_selection_is_per_map_and_debug_metadata_preserves_real_access;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class block_type extends uvm_reg_block;
    function new(string name="owner56"); super.new(name,UVM_NO_COVERAGE); endfunction
  endclass

  class frontdoor_type extends uvm_reg_frontdoor;
    uvm_reg_data_t words[uvm_reg_addr_t];
    uvm_object seen_element;
    uvm_reg_addr_t seen_offset;
    int calls=0;
    function new(string name); super.new(name); endfunction
    virtual task body();
      calls++; seen_element=rw_info.get_element(); seen_offset=rw_info.get_offset();
      #1;
      if (rw_info.get_kind()==UVM_WRITE) words[seen_offset]=rw_info.get_value(0);
      else rw_info.set_value(words[seen_offset]);
      rw_info.set_status(UVM_IS_OK);
    endtask
  endclass
  class test_type extends uvm_test;
    `uvm_component_utils(test_type)
    block_type owner;
    uvm_mem memory;
    uvm_reg_map first_map,second_map;
    frontdoor_type first_fd,second_fd;
    uvm_sequencer#(uvm_sequence_item) sequencer;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase); owner=new(); owner.configure();
      memory=new("memory56",4,16); memory.configure(owner);
      first_map=owner.create_map("first56",0,2,UVM_LITTLE_ENDIAN);
      second_map=owner.create_map("second56",'h100,2,UVM_LITTLE_ENDIAN);
      first_map.add_mem(memory,'h20); second_map.add_mem(memory,'h40);
      first_fd=new("first_fd56"); second_fd=new("second_fd56");
      sequencer=new("sequencer56",this);
      first_map.set_sequencer(sequencer); second_map.set_sequencer(sequencer);
      owner.lock_model();
    endfunction
    task run_phase(uvm_phase phase);
      uvm_status_e status; uvm_reg_data_t value; bit ok;
      phase.raise_objection(this);
      $display("UT: frontdoor_initial none %0d",
        memory.get_frontdoor(first_map)==null && memory.get_frontdoor(second_map)==null);
      memory.set_frontdoor(first_fd,first_map);
      for (int variant=0;variant<2;variant++) begin
        memory.set_frontdoor(second_fd,second_map,variant ? "debug56.sv" : "",variant ? 956 : 0);
        memory.write(status,1,'h5611,UVM_FRONTDOOR,first_map); ok=status==UVM_IS_OK;
        memory.write(status,1,'h5622,UVM_FRONTDOOR,second_map); ok &= status==UVM_IS_OK;
        memory.read(status,1,value,UVM_FRONTDOOR,first_map);
        ok &= status==UVM_IS_OK && value=='h5611;
        memory.read(status,1,value,UVM_FRONTDOOR,second_map);
        ok &= status==UVM_IS_OK && value=='h5622;
        $display("UT: selected_frontdoors debug %0d getters %0d access %0d isolated %0d",variant,
          memory.get_frontdoor(first_map)==first_fd && memory.get_frontdoor(second_map)==second_fd,
          ok,first_fd.words[1]=='h5611 && second_fd.words[1]=='h5622);
      end
      $display("UT: frontdoor_descriptors element %0d offset %0d both_used %0d",
        first_fd.seen_element==memory && second_fd.seen_element==memory,
        first_fd.seen_offset==1 && second_fd.seen_offset==1,first_fd.calls>0 && second_fd.calls>0);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("test_type");
  initial begin #100; $fatal(1,"frontdoor watchdog"); end
endmodule
