/*
:name: test_memory_backdoor_read_only_write_preserves_storage_while_poke_deposits
:description: Backdoor write respects ROM access while poke deposits directly and read forwards request context
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.5.1 18.6.5.2 18.6.5.5 18.6.5.6 18.6.7.2 19.1.1.2.4 19.1.1.2.5 19.1.1.2.6 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_backdoor_read_only_write_preserves_storage_while_poke_deposits.expected
*/
// What it checks:
// A modeled backdoor write respects ROM policy while poke deposits directly.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.6.5.1 (UVM-MEMORY-AUDIT-ROM-WRITE-VS-POKE) gives the rule
// above. Setup: An explicit RO memory/map uses original user storage, selected
// and peer words, a parent sequence/extension and debug arguments. Expected:
// write leaves the ROM word unchanged, poke changes it, read/peek return it
// and the successful read descriptor retains parent, extension and memory
// identity.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_memory_backdoor_read_only_write_preserves_storage_while_poke_deposits;
  import uvm_pkg::*;

  class block_type extends uvm_reg_block;
    function new(string name="owner56"); super.new(name,UVM_NO_COVERAGE); endfunction
  endclass

  class quiet_probe extends uvm_report_catcher;
    virtual function action_e catch();
      if (get_severity() inside {UVM_WARNING,UVM_ERROR}) return CAUGHT;
      return THROW;
    endfunction
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

  class parent_type extends uvm_sequence#(uvm_sequence_item);
    function new(); super.new("parent56"); endfunction
    virtual task body(); endtask
  endclass
  class token_type extends uvm_object;
    function new(); super.new("token56"); endfunction
  endclass
  initial begin
    automatic block_type owner=new();
    automatic uvm_mem memory=new("rom56",4,16,"RO");
    automatic storage_type storage=new("storage56");
    automatic parent_type parent=new();
    automatic token_type token=new();
    automatic quiet_probe quiet=new();
    uvm_reg_map mapping; uvm_status_e status; uvm_reg_data_t value;
    bit ok;
    uvm_report_cb::add(null,quiet);
    owner.configure(); memory.configure(owner); memory.set_backdoor(storage);
    mapping=owner.create_map("bus56",0,2,UVM_LITTLE_ENDIAN);
    mapping.add_mem(memory,0); owner.lock_model();
    storage.words[1]='h5611; storage.words[2]='h56aa;
    memory.write(.status(status),.offset(1),.value('h5622),.path(UVM_BACKDOOR),.map(mapping),
      .parent(parent),.extension(token),.fname("write56.sv"),.lineno(956));
    $display("UT: rom_write unchanged %0d peer %0d",
      storage.words[1]=='h5611,storage.words[2]=='h56aa);
    memory.poke(.status(status),.offset(1),.value('h5633),.parent(parent),.extension(token));
    ok=status==UVM_IS_OK;
    memory.peek(.status(status),.offset(1),.value(value),.parent(parent),.extension(token));
    $display("UT: rom_poke data %0d peer %0d",ok && status==UVM_IS_OK && value=='h5633,
      storage.words[2]=='h56aa);
    memory.read(.status(status),.offset(1),.value(value),.path(UVM_BACKDOOR),.map(mapping),
      .parent(parent),.extension(token),.fname("read56.sv"),.lineno(957));
    $display("UT: rom_read data %0d parent %0d extension %0d element %0d",
      status==UVM_IS_OK && value=='h5633,storage.seen_parent==parent,
      storage.seen_extension==token,storage.seen_element==memory);
    $finish;
  end
endmodule
