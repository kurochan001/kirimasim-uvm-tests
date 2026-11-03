/*
:name: test_map_sequencer_and_adapter_queries_keep_local_and_system_settings_distinct_after_replacement
:description: map sequencer and adapter queries keep local and system settings distinct after replacement
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.3.6 18.2.4.8 18.2.4.9 18.2.3.5 18.1.2.3 18.1.2.2 18.1.2.6 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_map_sequencer_and_adapter_queries_keep_local_and_system_settings_distinct_after_replacement.expected
*/
module
  test_map_sequencer_and_adapter_queries_keep_local_and_system_settings_distinct_after_replacement;
  import uvm_pkg::*;
  class block_type extends uvm_reg_block;
    function new(string name); super.new(name,UVM_NO_COVERAGE); endfunction
  endclass

  class adapter_type extends uvm_reg_adapter;
    function new(string name);super.new(name);endfunction
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
      uvm_sequence_item item=new("unused51");return item;
    endfunction
    virtual function void bus2reg(uvm_sequence_item item,ref uvm_reg_bus_op rw);
      rw.status=UVM_NOT_OK;
    endfunction
  endclass

  initial begin
    automatic block_type root=new("root51");
    automatic block_type child=new("child51");
    automatic block_type peer=new("peer51");
    automatic uvm_sequencer#(uvm_sequence_item) system_seq=new("system51",null);
    automatic uvm_sequencer#(uvm_sequence_item) local_seq=new("local51",null);
    automatic uvm_sequencer#(uvm_sequence_item) next_seq=new("next51",null);
    automatic adapter_type system_adapter=new("system_adapter51");
    automatic adapter_type local_adapter=new("local_adapter51");
    automatic adapter_type next_adapter=new("next_adapter51");
    uvm_reg_map outer,inner,other;
    root.configure();child.configure(root);peer.configure();
    outer=root.create_map("outer51",0,4,UVM_LITTLE_ENDIAN);
    inner=child.create_map("inner51",0,4,UVM_LITTLE_ENDIAN);
    other=peer.create_map("peer51",0,4,UVM_LITTLE_ENDIAN);
    outer.add_submap(inner,'h40);
    outer.set_sequencer(system_seq,system_adapter);
    inner.set_sequencer(local_seq,local_adapter);other.set_sequencer(local_seq);
    root.lock_model();peer.lock_model();
    $display("UT: map_bus local_sequence %0d local_adapter %0d omitted_adapter %0d",
      inner.get_sequencer(UVM_NO_HIER)==local_seq,
      inner.get_adapter(UVM_NO_HIER)==local_adapter,other.get_adapter(UVM_NO_HIER)==null);
    $display("UT: map_bus system_sequence %0d system_adapter %0d explicit_hier %0d",
      inner.get_sequencer()==system_seq,inner.get_adapter()==system_adapter,
      inner.get_sequencer(UVM_HIER)==system_seq && inner.get_adapter(UVM_HIER)==system_adapter);
    outer.set_sequencer(next_seq,next_adapter);
    $display("UT: map_bus replace_sequence %0d replace_adapter %0d local_kept %0d peer_kept %0d",
      inner.get_sequencer()==next_seq,inner.get_adapter()==next_adapter,
      inner.get_sequencer(UVM_NO_HIER)==local_seq &&
      inner.get_adapter(UVM_NO_HIER)==local_adapter,other.get_sequencer()==local_seq);
    $finish;
  end
endmodule
