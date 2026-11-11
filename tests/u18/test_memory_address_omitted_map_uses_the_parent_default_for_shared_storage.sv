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
// What it checks:
// 1. A shared memory omitted-map address query selects its parent default map.
// 2. An omitted-map address-array query selects the parent default for shared
//    memory.
// 3. An omitted-map rights query selects the shared memory parent default.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.6.4.16 (UVM-MEM-FIFO-AUDIT-MEM-ADDRESS-SHARED-DEFAULT)
//    gives rule 1 above. Setup: Construct valid memory maps, configure the
//    parent default explicitly and lock before querying; distinguish
//    sole-member and shared-memory cases. Expected: The explicit first map
//    returns 0x112 and the omitted map returns the second map address 0x322.
// 2. 1800.2-2020 18.6.4.17 (UVM-MEM-FIFO-AUDIT-MEM-ADDRESSES-SHARED-DEFAULT)
//    gives rule 2 above. Setup: Construct valid memory maps, configure the
//    parent default explicitly and lock before querying; distinguish
//    sole-member and shared-memory cases. Expected: Location one returns the
//    single address 0x322 and a two-byte transfer width.
// 3. 1800.2-2020 18.6.4.5 (UVM-MEM-FIFO-AUDIT-MEM-RIGHTS-SHARED-DEFAULT) gives
//    rule 3 above. Setup: Construct valid memory maps, configure the parent
//    default explicitly and lock before querying; distinguish sole-member and
//    shared-memory cases. Expected: The selected default reports RW while the
//    explicit first map remains RO.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
