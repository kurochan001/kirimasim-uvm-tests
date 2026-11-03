/*
:name: test_regfile_default_hdl_abstraction_follows_nearest_ancestor_and_local_override
:description: register file default abstraction queries follow the nearest explicit ancestor (18.3.4.6)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.3.4.6 18.3.4.7 18.3.2.2 18.1.6.10 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_regfile_default_hdl_abstraction_follows_nearest_ancestor_and_local_override.expected
*/
// Design-abstraction strings are control metadata, not proof of any HDL object.
// The pinned default_hdl_path starts as RTL and hides inherited defaults.
// Explicit local overrides remain independent matching controls.
module test_regfile_default_hdl_abstraction_follows_nearest_ancestor_and_local_override;
  import uvm_pkg::*;
  class block_type extends uvm_reg_block;
    function new(string name); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass

  initial begin
    automatic block_type root_block = new("root");
    automatic uvm_reg_file outer_file = new("outer");
    automatic uvm_reg_file inner_file = new("inner");
    automatic uvm_reg_file peer = new("peer");
    root_block.configure(); outer_file.configure(root_block, null);
    inner_file.configure(root_block, outer_file); peer.configure(root_block, null);
    $display("UT: initial %s %s %s", outer_file.get_default_hdl_path(),
             inner_file.get_default_hdl_path(), peer.get_default_hdl_path());
    root_block.set_default_hdl_path("GATE");
    $display("UT: block_default %s %s %s", outer_file.get_default_hdl_path(),
             inner_file.get_default_hdl_path(), peer.get_default_hdl_path());
    outer_file.set_default_hdl_path("TLM"); inner_file.set_default_hdl_path("RTL");
    root_block.set_default_hdl_path("CPU");
    $display("UT: nearest %s %s %s", outer_file.get_default_hdl_path(),
             inner_file.get_default_hdl_path(), peer.get_default_hdl_path());
    $finish;
  end
endmodule
