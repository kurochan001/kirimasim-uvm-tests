/*
:name: test_reg_field_custom_access_registration_normalizes_names_and_distinguishes_builtins
:description: custom access registration is case insensitive and does not make a custom policy built in (IEEE 1800.2-2020 Section 18.5.4.7)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.4.7 18.5.4.6 18.5.4.5 18.5.4.8 18.5.3.1 18.5.3.2 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 18.5.5.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_field_custom_access_registration_normalizes_names_and_distinguishes_builtins.expected
*/
// Model-only field metadata and desired/mirrored state. No bus, RTL or DPI
// is accessed, and policy controls do not establish physical side effects.
module test_reg_field_custom_access_registration_normalizes_names_and_distinguishes_builtins;
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
    bit first_result;
    bit duplicate_result;
    bit builtin_result;
    string previous;
    build_model();

    first_result = uvm_reg_field::define_access("local_policy");
    duplicate_result = uvm_reg_field::define_access("LOCAL_POLICY");
    builtin_result = uvm_reg_field::define_access("RW");
    previous = first_field.set_access("local_policy");
    $display("UT: registration new %0d duplicate %0d builtin %0d", first_result, duplicate_result,
    builtin_result);
    $display("UT: custom previous %s current %s known %0d", previous, first_field.get_access(),
    first_field.is_known_access());
    previous = first_field.set_access("RW");
    $display("UT: restored previous %s known %0d peer_known %0d", previous,
             first_field.is_known_access(), peer.is_known_access());
    $finish;
  end

endmodule
