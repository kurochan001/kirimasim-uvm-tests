/*
:name: test_map_constructor_object_views_and_backdoor_singleton_are_distinct_from_real_maps
:description: map constructor object views and backdoor singleton are distinct from real maps
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.3.1 18.2.1 18.2.2 5.3.4.2 18.1.2.3 18.1.2.2 18.1.3.6 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_map_constructor_object_views_and_backdoor_singleton_are_distinct_from_real_maps.expected
*/
// What it checks:
// 1. An omitted map constructor name uses the declared uvm_reg_map default.
// 2. Constructed maps preserve the selected name and have distinct instance
//    identities.
// 3. A map instance is usable as an object and casts back to the same map
//    handle.
// 4. Repeated backdoor calls return the same nonnull pseudo-map, distinct from
//    the selected real address map.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.2.3.1 (UVM-MAP-SCOPE-NEW-DEFAULT) gives rule 1 above.
//    Setup: Original configured blocks, owned maps and selected explicit
//    public calls. Parent/child maps use valid ownership and are locked before
//    width-dependent queries. Getter-only observers do not override the
//    library algorithms. Expected: An omitted map constructor name uses the
//    declared uvm_reg_map default.
// 2. 1800.2-2020 18.2.3.1 (UVM-MAP-SCOPE-NEW-NAME-IDENTITY) gives rule 2
//    above. Setup: Original configured blocks, owned maps and selected
//    explicit public calls. Parent/child maps use valid ownership and are
//    locked before width-dependent queries. Getter-only observers do not
//    override the library algorithms. Expected: Constructed maps preserve the
//    selected name and have distinct instance identities.
// 3. 1800.2-2020 18.2.1 (UVM-MAP-SCOPE-OBJECT-BASE) gives rule 3 above. Setup:
//    Original configured blocks, owned maps and selected explicit public
//    calls. Parent/child maps use valid ownership and are locked before
//    width-dependent queries. Getter-only observers do not override the
//    library algorithms. Expected: A map instance is usable as an object and
//    casts back to the same map handle.
// 4. 1800.2-2020 18.2.2 (UVM-MAP-SCOPE-BACKDOOR-SINGLETON) gives rule 4 above.
//    Setup: Original configured blocks, owned maps and selected explicit
//    public calls. Parent/child maps use valid ownership and are locked before
//    width-dependent queries. Getter-only observers do not override the
//    library algorithms. Expected: Repeated backdoor calls return the same
//    nonnull pseudo-map, distinct from the selected real address map.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_map_constructor_object_views_and_backdoor_singleton_are_distinct_from_real_maps;
  import uvm_pkg::*;
  class block_type extends uvm_reg_block;
    function new(string name); super.new(name,UVM_NO_COVERAGE); endfunction
  endclass

  initial begin
    automatic uvm_reg_map unnamed=new();
    automatic uvm_reg_map named=new("chosen51");
    automatic block_type owner=new("owner51");
    uvm_reg_map real_map,first,second,roundtrip;
    uvm_object object_view;
    uvm_reg_map listed[$];
    owner.configure();real_map=owner.create_map("bus51",0,4,UVM_LITTLE_ENDIAN);
    object_view=named;
    $display("UT: map_new default_name %0d selected_name %0d distinct %0d object %0d",
      unnamed.get_name()=="uvm_reg_map",named.get_name()=="chosen51",unnamed!=named,
      $cast(roundtrip,object_view) && roundtrip==named);
    first=uvm_reg_map::backdoor();second=uvm_reg_map::backdoor();
    owner.get_maps(listed);
    $display("UT: map_backdoor nonnull %0d singleton %0d separate %0d real_list %0d",
      first!=null,first==second,first!=real_map,
      listed.size()==1 && listed[0]==real_map);
    $finish;
  end
endmodule
