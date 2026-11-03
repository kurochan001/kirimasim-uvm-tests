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
