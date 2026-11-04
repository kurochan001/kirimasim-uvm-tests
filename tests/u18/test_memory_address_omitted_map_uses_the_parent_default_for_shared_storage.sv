/*
:name: test_memory_address_omitted_map_uses_the_parent_default_for_shared_storage
:description: memory address omitted map uses the parent default for shared storage
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.4.16 18.6.4.17 18.6.4.5 18.6.3.2 18.2.3.4 18.1.2.4 18.1.2.5 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_address_omitted_map_uses_the_parent_default_for_shared_storage.expected
*/
module test_memory_address_omitted_map_uses_the_parent_default_for_shared_storage;
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
    uvm_reg_map first,second;
    uvm_reg_addr_t addresses[];
    int transfer_width;
    owner=new(); owner.configure(); memory=new("memory63",4,16); memory.configure(owner);
    first=owner.create_map("first63",'h100,2,UVM_LITTLE_ENDIAN);
    second=owner.create_map("second63",'h300,2,UVM_LITTLE_ENDIAN);
    first.add_mem(memory,'h10,"RO"); second.add_mem(memory,'h20,"RW");
    owner.set_default_map(second); owner.lock_model();
    $display("UT: memory_shared explicit %0d default_selected %0d rights %0d",
      memory.get_address(1,first)=='h112,memory.get_address(1)=='h322,
      memory.get_rights()=="RW" && memory.get_rights(first)=="RO");
    transfer_width=memory.get_addresses(.offset(1),.addr(addresses));
    $display("UT: memory_shared address_array %0d transfer_width %0d",
      addresses.size()==1 && addresses[0]=='h322,transfer_width==2);
    $finish;
  end
endmodule
