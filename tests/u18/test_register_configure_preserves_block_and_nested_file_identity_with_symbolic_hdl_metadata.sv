/*
:name: test_register_configure_preserves_block_and_nested_file_identity_with_symbolic_hdl_metadata
:description: register configure preserves block and nested file identity with symbolic hdl metadata
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.2.2 18.4.3.1 18.4.3.2 18.4.6.6 18.3.1 18.3.2.1 18.3.2.2 18.1.2.2 18.4.2.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_configure_preserves_block_and_nested_file_identity_with_symbolic_hdl_metadata.expected
*/
// What it checks:
// 1. configure records the selected parent block independently for a direct
//    and a file-placed register.
// 2. configure records the selected nested parent file while the omitted file
//    argument denotes a directly block-instantiated register.
// 3. The selected single-variable hdl_path configuration establishes an RTL
//    path description.
// 4. The selected register file is usable through an object view and casts
//    back to its configured file handle.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.4.2.2 (UVM-REGISTER-CONTRACT-CONFIGURE-BLOCK) gives rule 1
//    above. Setup: Use the selected original register/block/file models and
//    explicit public calls. Constructor-only observations do not require
//    mapped physical hardware. Membership is queried through the register view
//    after selected legal registrations/removals; output queues start empty.
//    Expected: configure records the selected parent block independently for a
//    direct and a file-placed register.
// 2. 1800.2-2020 18.4.2.2 (UVM-REGISTER-CONTRACT-CONFIGURE-FILE) gives rule 2
//    above. Setup: Use the selected original register/block/file models and
//    explicit public calls. Constructor-only observations do not require
//    mapped physical hardware. Membership is queried through the register view
//    after selected legal registrations/removals; output queues start empty.
//    Expected: configure records the selected nested parent file while the
//    omitted file argument denotes a directly block-instantiated register.
// 3. 1800.2-2020 18.4.2.2 (UVM-REGISTER-CONTRACT-CONFIGURE-SYMBOLIC-HDL) gives
//    rule 3 above. Setup: Use the selected original register/block/file models
//    and explicit public calls. Constructor-only observations do not require
//    mapped physical hardware. Membership is queried through the register view
//    after selected legal registrations/removals; output queues start empty.
//    Expected: The selected single-variable hdl_path configuration establishes
//    an RTL path description.
// 4. 1800.2-2020 18.3.1 (UVM-REGISTER-CONTRACT-REGFILE-OBJECT-BASE) gives rule
//    4 above. Setup: Use the selected original register/block/file models and
//    explicit public calls. Constructor-only observations do not require
//    mapped physical hardware. Membership is queried through the register view
//    after selected legal registrations/removals; output queues start empty.
//    Expected: The selected register file is usable through an object view and
//    casts back to its configured file handle.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Symbolic path presence only; no physical HDL or path-string oracle.
module test_register_configure_preserves_block_and_nested_file_identity_with_symbolic_hdl_metadata;
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
    automatic block_type owner=new("owner52");
    automatic block_type other=new("other52");
    automatic uvm_reg_file outer=new("outer52");
    automatic uvm_reg_file inner=new("inner52");
    automatic register_type direct=new("direct52");
    automatic register_type placed=new("placed52");
    automatic register_type peer=new("peer52");
    uvm_object file_object;
    uvm_reg_file file_back;
    owner.configure();other.configure();
    outer.configure(owner,null);inner.configure(owner,outer);
    direct.configure(owner);placed.configure(owner,inner,"symbol52");peer.configure(other);
    file_object=inner;
    $display("UT: register_configure block %0d file %0d direct_null %0d peer %0d",
      placed.get_parent()==owner,placed.get_regfile()==inner,
      direct.get_regfile()==null,peer.get_parent()==other);
    $display("UT: register_configure file_object %0d symbolic_path %0d",
      $cast(file_back,file_object) && file_back==inner,placed.has_hdl_path("RTL"));
    $finish;
  end
endmodule
