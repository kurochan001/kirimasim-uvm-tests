/*
:name: test_memory_address_omitted_map_selects_the_sole_member_despite_another_parent_default
:description: memory address omitted map selects the sole member despite another parent default
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.4.16 18.6.3.1 18.6.3.2 18.2.3.4 18.1.2.4 18.1.2.5 18.1.2.3 18.1.2.6 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_address_omitted_map_selects_the_sole_member_despite_another_parent_default.expected
*/
module test_memory_address_omitted_map_selects_the_sole_member_despite_another_parent_default;
  import uvm_pkg::*;
  class block_type extends uvm_reg_block;
    function new(); super.new("owner63",UVM_NO_COVERAGE); endfunction
  endclass
  class reports extends uvm_report_catcher;
    bit gated=0;
    int warnings=0;
    virtual function action_e catch();
      if (gated && get_severity()==UVM_WARNING) begin warnings++; return CAUGHT; end
      return THROW;
    endfunction
  endclass

  initial begin
    block_type owner;
    uvm_mem memory;
    uvm_reg_map member_map,other_map;
    owner=new(); owner.configure(); memory=new("memory63",4,16); memory.configure(owner);
    member_map=owner.create_map("member63",'h100,2,UVM_LITTLE_ENDIAN);
    other_map=owner.create_map("other63",'h500,2,UVM_LITTLE_ENDIAN);
    member_map.add_mem(memory,'h20); owner.set_default_map(other_map); owner.lock_model();
    $display("UT: memory_sole default_other %0d one_member %0d explicit %0d",
      owner.get_default_map()==other_map,memory.get_n_maps()==1,
      memory.get_address(2,member_map)=='h124);
    $display("UT: memory_sole omitted_location %0d omitted_offset %0d",
      memory.get_address(2)=='h124,memory.get_address()=='h120);
    $finish;
  end
endmodule
