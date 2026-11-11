/*
:name: test_block_has_hdl_path_uses_nearest_explicit_ancestor_kind_without_changing_explicit_queries
:description: block has hdl path uses nearest explicit ancestor kind without changing explicit queries
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.6.6 18.1.6.9 18.1.6.10 18.1.6.5 18.1.6.1 18.1.2.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_has_hdl_path_uses_nearest_explicit_ancestor_kind_without_changing_explicit_queries.expected
*/
// What it checks:
// 1. An omitted has_hdl_path kind uses the nearest explicitly configured
//    ancestor default kind.
// 2. A nearer explicitly configured default kind changes the omitted
//    descendant presence query without changing an explicit other-kind query.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.1.6.6 (UVM-BLOCK-CONFIG-HAS-HDL-ANCESTOR-DEFAULT) gives
//    rule 1 above. Setup: Original root, flattened intermediate and leaf
//    blocks use selected symbolic path strings. Only metadata getters are
//    called; explicit RTL is used unless the fixture deliberately tests
//    default-kind inheritance. Expected: An omitted has_hdl_path kind uses the
//    nearest explicitly configured ancestor default kind.
// 2. 1800.2-2020 18.1.6.6 (UVM-BLOCK-CONFIG-HAS-HDL-NEAREST-DEFAULT) gives
//    rule 2 above. Setup: Original root, flattened intermediate and leaf
//    blocks use selected symbolic path strings. Only metadata getters are
//    called; explicit RTL is used unless the fixture deliberately tests
//    default-kind inheritance. Expected: A nearer explicitly configured
//    default kind changes the omitted descendant presence query without
//    changing an explicit other-kind query.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Symbolic kind selection only; retain the independent ancestor-default oracle.
module
  test_block_has_hdl_path_uses_nearest_explicit_ancestor_kind_without_changing_explicit_queries;
  import uvm_pkg::*;
class block_type extends uvm_reg_block;
  function new(string name="",int available=UVM_NO_COVERAGE);
    super.new(name,available);
  endfunction
endclass

initial begin
  automatic block_type root=new("root50");
  automatic block_type child=new("child50");
  automatic block_type deep=new("deep50");
  root.configure(); child.configure(root); deep.configure(child);
  child.add_hdl_path("child_gate50","GATE50");
  deep.add_hdl_path("deep_gate50","GATE50");
  root.set_default_hdl_path("GATE50");
  $display("UT: has_hdl_inherited child_kind %0d deep_kind %0d child_has %0d deep_has %0d",
    child.get_default_hdl_path()=="GATE50",deep.get_default_hdl_path()=="GATE50",
    child.has_hdl_path(),deep.has_hdl_path());
  child.set_default_hdl_path("EMPTY50");
  $display("UT: has_hdl_inherited nearest_kind %0d omitted_absent %0d explicit_gate %0d",
    deep.get_default_hdl_path()=="EMPTY50",!deep.has_hdl_path(),deep.has_hdl_path("GATE50"));
  $finish;
end
endmodule
