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
// What it checks:
// 1. set_sequencer associates the selected sequencer and adapter pair with the
//    map.
// 2. Omitting the set_sequencer adapter argument supplies null for the
//    selected map.
// 3. Replacing a root map sequencer/adapter redirects the selected later
//    child-map transfers and preserves the old driver storage.
// 4. Explicit NO_HIER get_sequencer returns the selected local association.
// 5. Explicit HIER get_sequencer returns the selected system bus association.
// 6. Omitted get_sequencer hier follows the selected root association after
//    replacement while the explicit local and peer settings remain intact.
// 7. Explicit NO_HIER get_adapter returns the selected local association.
// 8. Explicit HIER get_adapter returns the selected system bus association.
// 9. Omitted get_adapter hier follows the selected root association after
//    replacement while the explicit local and peer settings remain intact.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.2.3.6 (UVM-MAP-SCOPE-SET-SEQUENCER-ADAPTER) gives rule 1
//    above. Setup: Use the selected getter-only map settings or the separate
//    original four-byte adapter/sequencer/driver path to a 32-bit RW child-map
//    register. In the real path both root sequencers connect to distinct live
//    original drivers, and replacement follows a completed write/read pair.
//    Adapter context and original stores independently observe selection.
//    Expected: set_sequencer associates the selected sequencer and adapter
//    pair with the map.
// 2. 1800.2-2020 18.2.3.6 (UVM-MAP-SCOPE-SET-OMITTED-ADAPTER) gives rule 2
//    above. Setup: Use the selected getter-only map settings or the separate
//    original four-byte adapter/sequencer/driver path to a 32-bit RW child-map
//    register. In the real path both root sequencers connect to distinct live
//    original drivers, and replacement follows a completed write/read pair.
//    Adapter context and original stores independently observe selection.
//    Expected: Omitting the set_sequencer adapter argument supplies null for
//    the selected map.
// 3. 1800.2-2020 18.2.3.6 (UVM-MAP-SCOPE-SET-REPLACEMENT) gives rule 3 above.
//    Setup: Use the selected getter-only map settings or the separate original
//    four-byte adapter/sequencer/driver path to a 32-bit RW child-map
//    register. In the real path both root sequencers connect to distinct live
//    original drivers, and replacement follows a completed write/read pair.
//    Adapter context and original stores independently observe selection.
//    Expected: Replacing a root map sequencer/adapter redirects the selected
//    later child-map transfers and preserves the old driver storage.
// 4. 1800.2-2020 18.2.4.8 (UVM-MAP-SCOPE-SEQUENCER-LOCAL) gives rule 4 above.
//    Setup: Original configured blocks, owned maps and selected explicit
//    public calls. Parent/child maps use valid ownership and are locked before
//    width-dependent queries. Getter-only observers do not override the
//    library algorithms. Expected: Explicit NO_HIER get_sequencer returns the
//    selected local association.
// 5. 1800.2-2020 18.2.4.8 (UVM-MAP-SCOPE-SEQUENCER-SYSTEM) gives rule 5 above.
//    Setup: Original configured blocks, owned maps and selected explicit
//    public calls. Parent/child maps use valid ownership and are locked before
//    width-dependent queries. Getter-only observers do not override the
//    library algorithms. Expected: Explicit HIER get_sequencer returns the
//    selected system bus association.
// 6. 1800.2-2020 18.2.4.8 (UVM-MAP-SCOPE-SEQUENCER-DEFAULT-AND-ISOLATION)
//    gives rule 6 above. Setup: Original configured blocks, owned maps and
//    selected explicit public calls. Parent/child maps use valid ownership and
//    are locked before width-dependent queries. Getter-only observers do not
//    override the library algorithms. Expected: Omitted get_sequencer hier
//    follows the selected root association after replacement while the
//    explicit local and peer settings remain intact.
// 7. 1800.2-2020 18.2.4.9 (UVM-MAP-SCOPE-ADAPTER-LOCAL) gives rule 7 above.
//    Setup: Original configured blocks, owned maps and selected explicit
//    public calls. Parent/child maps use valid ownership and are locked before
//    width-dependent queries. Getter-only observers do not override the
//    library algorithms. Expected: Explicit NO_HIER get_adapter returns the
//    selected local association.
// 8. 1800.2-2020 18.2.4.9 (UVM-MAP-SCOPE-ADAPTER-SYSTEM) gives rule 8 above.
//    Setup: Original configured blocks, owned maps and selected explicit
//    public calls. Parent/child maps use valid ownership and are locked before
//    width-dependent queries. Getter-only observers do not override the
//    library algorithms. Expected: Explicit HIER get_adapter returns the
//    selected system bus association.
// 9. 1800.2-2020 18.2.4.9 (UVM-MAP-SCOPE-ADAPTER-DEFAULT-AND-ISOLATION) gives
//    rule 9 above. Setup: Original configured blocks, owned maps and selected
//    explicit public calls. Parent/child maps use valid ownership and are
//    locked before width-dependent queries. Getter-only observers do not
//    override the library algorithms. Expected: Omitted get_adapter hier
//    follows the selected root association after replacement while the
//    explicit local and peer settings remain intact.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
    virtual function void bus2reg(uvm_sequence_item bus_item,ref uvm_reg_bus_op rw);
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
