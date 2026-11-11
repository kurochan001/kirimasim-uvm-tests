/*
:name: test_register_local_map_resolves_explicit_and_ancestor_maps_without_selecting_an_unrelated_map
:description: register local map resolves explicit and ancestor maps without selecting an unrelated map
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.3.6 18.4.3.5 18.1.2.4 18.2.3.3 18.2.3.5 18.1.2.2 18.1.2.3 18.4.2.2 18.5.3.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_local_map_resolves_explicit_and_ancestor_maps_without_selecting_an_unrelated_map.expected
*/
// What it checks:
// 1. A get_local_map argument already in get_maps is returned unchanged.
// 2. An ancestor map argument resolves to the selected contained local map.
// 3. An unrelated map with no selected local association resolves to null.
// 4. A null get_local_map argument selects the parent block default among
//    multiple registered maps.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.4.3.6 (UVM-REGISTER-CONTRACT-LOCAL-MAP-EXPLICIT) gives
//    rule 1 above. Setup: Use the selected original register/block/file models
//    and explicit public calls. Constructor-only observations do not require
//    mapped physical hardware. Membership is queried through the register view
//    after selected legal registrations/removals; output queues start empty.
//    Expected: A get_local_map argument already in get_maps is returned
//    unchanged.
// 2. 1800.2-2020 18.4.3.6 (UVM-REGISTER-CONTRACT-LOCAL-MAP-ANCESTOR) gives
//    rule 2 above. Setup: Use the selected original register/block/file models
//    and explicit public calls. Constructor-only observations do not require
//    mapped physical hardware. Membership is queried through the register view
//    after selected legal registrations/removals; output queues start empty.
//    Expected: An ancestor map argument resolves to the selected contained
//    local map.
// 3. 1800.2-2020 18.4.3.6 (UVM-REGISTER-CONTRACT-LOCAL-MAP-NONE) gives rule 3
//    above. Setup: Use the selected original register/block/file models and
//    explicit public calls. Constructor-only observations do not require
//    mapped physical hardware. Membership is queried through the register view
//    after selected legal registrations/removals; output queues start empty.
//    Expected: An unrelated map with no selected local association resolves to
//    null.
// 4. 1800.2-2020 18.4.3.6 (UVM-REGISTER-CONTRACT-LOCAL-MAP-MAPPED-DEFAULT)
//    gives rule 4 above. Setup: Use the selected original register/block/file
//    models and explicit public calls. Constructor-only observations do not
//    require mapped physical hardware. Membership is queried through the
//    register view after selected legal registrations/removals; output queues
//    start empty. Expected: A null get_local_map argument selects the parent
//    block default among multiple registered maps.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module
  test_register_local_map_resolves_explicit_and_ancestor_maps_without_selecting_an_unrelated_map;
  import uvm_pkg::*;
  class block_type extends uvm_reg_block;
    function new(string name);super.new(name,UVM_NO_COVERAGE);endfunction
  endclass
  class register_type extends uvm_reg;
    function new(string name,int unsigned width=16,int coverage_models=UVM_NO_COVERAGE);
      super.new(name,width,coverage_models);
    endfunction
  endclass

  initial begin
    automatic block_type root=new("root52");
    automatic block_type child=new("child52");
    automatic register_type chosen=new("chosen52");
    automatic uvm_reg_field f=uvm_reg_field::type_id::create("bits52");
    uvm_reg_map outer,first,second,unrelated;
    root.configure();child.configure(root);chosen.configure(child);
    f.configure(chosen,16,0,"RW",0,0,1,0,0);
    outer=root.create_map("outer52",0,2,UVM_LITTLE_ENDIAN);
    first=child.create_map("first52",0,2,UVM_LITTLE_ENDIAN);
    second=child.create_map("second52",'h100,2,UVM_LITTLE_ENDIAN);
    unrelated=root.create_map("unrelated52",'h200,2,UVM_LITTLE_ENDIAN);
    first.add_reg(chosen,'h20);second.add_reg(chosen,'h20);outer.add_submap(first,'h40);
    child.set_default_map(second);
    $display("UT: register_local_map first %0d second %0d ancestor %0d unrelated_null %0d",
      chosen.get_local_map(first)==first,chosen.get_local_map(second)==second,
      chosen.get_local_map(outer)==first,chosen.get_local_map(unrelated)==null);
    $display("UT: register_local_map default %0d",chosen.get_local_map(null)==second);
    $finish;
  end
endmodule
