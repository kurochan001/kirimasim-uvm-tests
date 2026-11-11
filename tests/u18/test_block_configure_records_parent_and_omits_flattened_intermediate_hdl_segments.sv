/*
:name: test_block_configure_records_parent_and_omits_flattened_intermediate_hdl_segments
:description: block configure records parent and omits flattened intermediate hdl segments
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.2.2 18.1.3.1 18.1.6.8 18.1.6.7 18.1.6.5 18.1.2.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_configure_records_parent_and_omits_flattened_intermediate_hdl_segments.expected
*/
// What it checks:
// 1. configure records the supplied parent block and treats an omitted parent
//    as a root.
// 2. A configured leaf contributes its selected HDL segment beneath its parent
//    path.
// 3. An omitted intermediate HDL path contributes no extra segment to the
//    selected descendant full path.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.1.2.2 (UVM-BLOCK-CONFIG-CONFIGURE-PARENT) gives rule 1
//    above. Setup: Original root, flattened intermediate and leaf blocks use
//    selected symbolic path strings. Only metadata getters are called;
//    explicit RTL is used unless the fixture deliberately tests default-kind
//    inheritance. Expected: configure records the supplied parent block and
//    treats an omitted parent as a root.
// 2. 1800.2-2020 18.1.2.2 (UVM-BLOCK-CONFIG-CONFIGURE-HDL-CONTRIBUTION) gives
//    rule 2 above. Setup: Original root, flattened intermediate and leaf
//    blocks use selected symbolic path strings. Only metadata getters are
//    called; explicit RTL is used unless the fixture deliberately tests
//    default-kind inheritance. Expected: A configured leaf contributes its
//    selected HDL segment beneath its parent path.
// 3. 1800.2-2020 18.1.2.2 (UVM-BLOCK-CONFIG-CONFIGURE-FLATTENED) gives rule 3
//    above. Setup: Original root, flattened intermediate and leaf blocks use
//    selected symbolic path strings. Only metadata getters are called;
//    explicit RTL is used unless the fixture deliberately tests default-kind
//    inheritance. Expected: An omitted intermediate HDL path contributes no
//    extra segment to the selected descendant full path.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Symbolic path metadata; no HDL transport or DPI behavior is claimed.
module test_block_configure_records_parent_and_omits_flattened_intermediate_hdl_segments;
  import uvm_pkg::*;
class block_type extends uvm_reg_block;
  function new(string name="",int available=UVM_NO_COVERAGE);
    super.new(name,available);
  endfunction
endclass

initial begin
  automatic block_type root=new("root50");
  automatic block_type flat=new("flat50");
  automatic block_type leaf=new("leaf50");
  automatic block_type peer=new("peer50");
  string paths[$];
  root.configure(null,"dut50"); flat.configure(root);
  leaf.configure(flat,"bank50"); peer.configure();
  $display("UT: configure parents root %0d flat %0d leaf %0d peer %0d",
    root.get_parent()==null,flat.get_parent()==root,
    leaf.get_parent()==flat,peer.get_parent()==null);
  leaf.get_full_hdl_path(paths,"RTL");
  $display("UT: configure flattened count %0d no_segment %0d",
    paths.size(),paths.size()==1 && paths[0]=="dut50.bank50");
  paths.delete(); flat.get_full_hdl_path(paths,"RTL","/");
  $display("UT: configure flat_parent count %0d value %0d",
    paths.size(),paths.size()==1 && paths[0]=="dut50");
  $finish;
end
endmodule
