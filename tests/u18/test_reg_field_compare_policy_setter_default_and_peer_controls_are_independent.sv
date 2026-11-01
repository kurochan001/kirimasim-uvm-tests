/*
:name: test_reg_field_compare_policy_setter_default_and_peer_controls_are_independent
:description: explicit field compare settings and the setter default are instance local (IEEE 1800.2-2020 Section 18.5.5.15)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.5.15 18.5.5.14 17.2.2.3 18.5.3.1 18.5.3.2 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 18.5.5.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_field_compare_policy_setter_default_and_peer_controls_are_independent.expected
*/
// Model-only field metadata and desired/mirrored state. No bus, RTL or DPI
// is accessed, and policy controls do not establish physical side effects.
module test_reg_field_compare_policy_setter_default_and_peer_controls_are_independent;
  import uvm_pkg::*;

  class model_block extends uvm_reg_block;
    function new(string name="blk"); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(string name="r", int unsigned width=16);
      super.new(name, width, UVM_NO_COVERAGE);
    endfunction
  endclass
  model_block blk;
  model_reg first_reg, second_reg;
  uvm_reg_field first_field, neighbor, peer;
  function automatic void build_model(bit first_has_reset=1);
    blk = new("blk"); blk.configure();
    first_reg = new("first"); first_reg.configure(blk);
    second_reg = new("second"); second_reg.configure(blk);
    first_field = new("first_field"); neighbor = new("neighbor"); peer = new("peer");
    first_field.configure(first_reg, 8, 0, "RW", 0, 8'h11, first_has_reset, 0, 1);
    neighbor.configure(first_reg, 8, 8, "RW", 0, 8'h22, 1, 0, 1);
    peer.configure(second_reg, 8, 0, "RW", 0, 8'h33, 1, 0, 1);
    first_field.reset(); neighbor.reset(); peer.reset();
  endfunction

  initial begin

    build_model();

    first_field.set_compare(UVM_NO_CHECK); peer.set_compare(UVM_CHECK);
    $display("UT: explicit first_no_check %0d peer_check %0d",
    first_field.get_compare() == UVM_NO_CHECK, peer.get_compare() == UVM_CHECK);
    first_field.set_compare(); peer.set_compare(UVM_NO_CHECK);
    $display("UT: default first_check %0d peer_no_check %0d",
    first_field.get_compare() == UVM_CHECK, peer.get_compare() == UVM_NO_CHECK);
    $finish;
  end

endmodule
