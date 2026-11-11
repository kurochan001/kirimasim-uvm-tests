/*
:name: test_regfile_constructor_names_and_configured_parents_are_instance_local
:description: register file names and configured block/file parent handles remain instance local (18.3.2.1)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.3.2.1 18.3.2.2 18.3.3.1 18.3.3.2 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_regfile_constructor_names_and_configured_parents_are_instance_local.expected
*/
// What it checks:
// 1. The register file constructor uses its specified default name when the
//    name argument is omitted.
// 2. The register file constructor preserves an explicitly supplied instance
//    name.
// 3. Register-file configuration records the supplied block and optional
//    containing register file.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.3.2.1 (UVM-REGFILE-CONSTRUCTOR-DEFAULT-NAME) gives rule 1
//    above. Setup: Independent instances are constructed with omitted and
//    explicit name arguments. Expected: The omitted-name instance has an empty
//    name.
// 2. 1800.2-2020 18.3.2.1 (UVM-REGFILE-CONSTRUCTOR-EXPLICIT-NAME) gives rule 2
//    above. Setup: Independent instances are constructed with omitted and
//    explicit name arguments. Expected: Named files retain outer and inner.
// 3. 1800.2-2020 18.3.2.2 (UVM-REGFILE-CONFIGURED-PARENT-RELATIONSHIPS) gives
//    rule 3 above. Setup: Root-level and nested files are configured once with
//    valid same-block ancestry and a separate peer block. Expected: Exact
//    block/file handles match; top-level files report a null containing file
//    and the peer stays independent.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Configure each file once with a valid block/file relationship.
// No reparenting, unconfigured parent query or address-map access is inferred.
module test_regfile_constructor_names_and_configured_parents_are_instance_local;
  import uvm_pkg::*;
  class block_type extends uvm_reg_block;
    function new(string name); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass

  initial begin
    automatic block_type root_block = new("root");
    automatic block_type peer_block = new("peer");
    automatic uvm_reg_file empty_name = new();
    automatic uvm_reg_file outer_file = new("outer");
    automatic uvm_reg_file inner_file = new("inner");
    automatic uvm_reg_file peer_file = new("peer_file");
    root_block.configure(); peer_block.configure();
    outer_file.configure(root_block, null, "outer_path");
    inner_file.configure(root_block, outer_file, "inner_path");
    peer_file.configure(peer_block, null, "peer_path");
    $display("UT: names default_empty %0d explicit %s %s", empty_name.get_name() == "",
             outer_file.get_name(), inner_file.get_name());
    $display("UT: block_parents %0d %0d %0d", outer_file.get_parent() == root_block,
             inner_file.get_parent() == root_block, peer_file.get_parent() == peer_block);
    $display("UT: file_parents %0d %0d %0d", outer_file.get_regfile() == null,
             inner_file.get_regfile() == outer_file, peer_file.get_regfile() == null);
    $finish;
  end
endmodule
