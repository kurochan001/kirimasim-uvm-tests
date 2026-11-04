/*
:name: test_memory_reads_follow_external_storage_changes_at_distinct_contiguous_locations
:description: memory reads follow external storage changes at distinct contiguous locations
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6 18.6.5.2 18.6.7.2 19.5.2.2 19.5.2.3 19.5.2.6 19.5.2.7 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_reads_follow_external_storage_changes_at_distinct_contiguous_locations.expected
*/
module test_memory_reads_follow_external_storage_changes_at_distinct_contiguous_locations;
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

  class storage_type extends uvm_reg_backdoor;
    uvm_reg_data_t words[4];
    int reads=0;
    function new(); super.new("storage63"); endfunction
    virtual task read(uvm_reg_item rw);
      do_pre_read(rw); #1; reads++;
      rw.set_value(words[rw.get_offset()]); rw.set_status(UVM_IS_OK);
      do_post_read(rw);
    endtask
  endclass
  initial begin
    block_type owner;
    uvm_mem memory;
    storage_type storage;
    uvm_reg_map mapping;
    uvm_status_e status;
    uvm_reg_data_t value;
    bit first_ok,second_ok;
    owner=new(); owner.configure(); memory=new("memory63",4,8); memory.configure(owner);
    storage=new(); memory.set_backdoor(storage);
    mapping=owner.create_map("bus63",0,1,UVM_LITTLE_ENDIAN); mapping.add_mem(memory,0);
    owner.lock_model(); storage.words[1]='h11; storage.words[2]='h22;
    memory.read(status,1,value,UVM_BACKDOOR,mapping); first_ok=status==UVM_IS_OK && value=='h11;
    storage.words[1]='h39;
    memory.read(status,1,value,UVM_BACKDOOR,mapping); second_ok=status==UVM_IS_OK && value=='h39;
    memory.read(status,2,value,UVM_BACKDOOR,mapping);
    $display("UT: memory_external initial %0d refreshed %0d adjacent %0d reads %0d",
      first_ok,second_ok,status==UVM_IS_OK && value=='h22,storage.reads==3);
    $finish;
  end
endmodule
