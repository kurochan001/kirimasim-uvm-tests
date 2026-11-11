/*
:name: test_memory_backdoor_local_and_inherited_selection_drives_access_failure_and_retry
:description: Memory backdoor inheritance and local override select real original storage and preserve failure status
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.7.1 18.6.7.2 18.6.5.5 18.6.5.6 18.1.6.2 19.5.2.3 19.5.2.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_backdoor_local_and_inherited_selection_drives_access_failure_and_retry.expected
*/
// What it checks:
// 1. Memory backdoor lookup defaults to inheritance while a local-only lookup
//    suppresses it.
// 2. A memory-specific backdoor supersedes the inherited mechanism.
// 3. Backdoor setter debug filename/line do not change functional
//    selection/access.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.6.7.1 (UVM-MEMORY-AUDIT-BACKDOOR-INHERITANCE) gives rule 1
//    above. Setup: One configured memory first inherits its parent block
//    backdoor, then receives a local backdoor under empty/nonempty debug
//    arguments. Original storage supplies poke/peek success, rejection and
//    retry. Expected: Initially absent; after parent selection
//    default/explicit-one return the parent and zero returns null; inherited
//    poke/peek reaches that storage.
// 2. 1800.2-2020 18.6.7.2 (UVM-MEMORY-AUDIT-BACKDOOR-LOCAL) gives rule 2
//    above. Setup: One configured memory first inherits its parent block
//    backdoor, then receives a local backdoor under empty/nonempty debug
//    arguments. Original storage supplies poke/peek success, rejection and
//    retry. Expected: Local/default getters return the local handle and
//    poke/peek uses local storage, leaving the parent value unchanged.
// 3. 1800.2-2020 18.6.7.2 (UVM-MEMORY-AUDIT-BACKDOOR-DEBUG) gives rule 3
//    above. Setup: One configured memory first inherits its parent block
//    backdoor, then receives a local backdoor under empty/nonempty debug
//    arguments. Original storage supplies poke/peek success, rejection and
//    retry. Expected: Both debug variants select the same local mechanism and
//    recover the same successful data.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_memory_backdoor_local_and_inherited_selection_drives_access_failure_and_retry;
  import uvm_pkg::*;

  class block_type extends uvm_reg_block;
    function new(string name="owner56"); super.new(name,UVM_NO_COVERAGE); endfunction
  endclass

  class storage_type extends uvm_reg_backdoor;
    uvm_reg_data_t words[uvm_reg_addr_t];
    bit reject=0;
    int reads=0,writes=0;
    uvm_sequence_base seen_parent;
    uvm_object seen_extension,seen_element;
    function new(string name); super.new(name); endfunction
    virtual task write(uvm_reg_item rw);
      writes++; seen_parent=rw.get_parent_sequence(); seen_extension=rw.get_extension();
      seen_element=rw.get_element();
      #1;
      if (!reject) words[rw.get_offset()]=rw.get_value(0);
      rw.set_status(reject ? UVM_NOT_OK : UVM_IS_OK);
    endtask
    virtual task read(uvm_reg_item rw);
      reads++; seen_parent=rw.get_parent_sequence(); seen_extension=rw.get_extension();
      seen_element=rw.get_element();
      #1;
      if (!reject) rw.set_value(words[rw.get_offset()]);
      rw.set_status(reject ? UVM_NOT_OK : UVM_IS_OK);
    endtask
  endclass

  initial begin
    automatic block_type owner=new();
    automatic uvm_mem memory=new("memory56",4,16);
    automatic storage_type inherited=new("inherited56");
    automatic storage_type local_bd=new("local56");
    uvm_status_e status; uvm_reg_data_t value; bit ok;
    owner.configure(); memory.configure(owner);
    $display("UT: backdoor_initial absent %0d",memory.get_backdoor()==null);
    owner.set_backdoor(inherited);
    $display("UT: inherited_selection default %0d explicit %0d local_absent %0d",
      memory.get_backdoor()==inherited,memory.get_backdoor(1)==inherited,
      memory.get_backdoor(0)==null);
    memory.poke(status,1,'h5611); ok=status==UVM_IS_OK;
    memory.peek(status,1,value);
    $display("UT: inherited_access status_data %0d used %0d",
      ok && status==UVM_IS_OK && value=='h5611,inherited.writes>0 && inherited.reads>0);
    for (int variant=0;variant<2;variant++) begin
      memory.set_backdoor(local_bd,variant ? "debug56.sv" : "",variant ? 956 : 0);
      memory.poke(status,2,'h5622); ok=status==UVM_IS_OK;
      memory.peek(status,2,value);
      $display("UT: local_access debug %0d selected %0d data %0d inherited_unchanged %0d",variant,
        memory.get_backdoor()==local_bd && memory.get_backdoor(0)==local_bd,
        ok && status==UVM_IS_OK && value=='h5622,inherited.words[1]=='h5611);
    end
    local_bd.reject=1; memory.poke(status,2,'h56ee);
    $display("UT: backdoor_write_failure status %0d unchanged %0d",
      status==UVM_NOT_OK,local_bd.words[2]=='h5622);
    memory.peek(status,2,value);
    $display("UT: backdoor_read_failure status %0d",status==UVM_NOT_OK);
    local_bd.reject=0; memory.poke(status,2,'h5633); ok=status==UVM_IS_OK;
    memory.peek(status,2,value);
    $display("UT: backdoor_retry data %0d",ok && status==UVM_IS_OK && value=='h5633);
    $finish;
  end
endmodule
