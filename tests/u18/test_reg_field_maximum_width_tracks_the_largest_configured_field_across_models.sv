/*
:name: test_reg_field_maximum_width_tracks_the_largest_configured_field_across_models
:description: the static maximum field width retains the largest configured width (IEEE 1800.2-2020 Section 18.5.4.4)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.4.4 18.5.4.3 18.5.3.1 18.5.3.2 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 18.5.5.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_field_maximum_width_tracks_the_largest_configured_field_across_models.expected
*/
// Model-only field metadata and desired/mirrored state. No bus, RTL or DPI
// is accessed, and policy controls do not establish physical side effects.
module test_reg_field_maximum_width_tracks_the_largest_configured_field_across_models;
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
    model_reg wide_reg;
    uvm_reg_field wide_field;
    uvm_reg_field small_field;
    int before_width;
    int expected_width;
    build_model();

    before_width = uvm_reg_field::get_max_size();
    wide_reg = new("wide", 32); wide_reg.configure(blk);
    wide_field = new("wide_field"); wide_field.configure(wide_reg, 20, 0, "RW", 0, 0, 0, 0, 0);
    expected_width = before_width > 20 ? before_width : 20;
    $display("UT: largest matched %0d local_width %0d",
    uvm_reg_field::get_max_size() == expected_width, wide_field.get_n_bits());
    small_field = new("small_field"); small_field.configure(wide_reg, 4, 24, "RW", 0, 0, 0, 0, 0);
    $display("UT: retained %0d small_width %0d peer_width %0d",
    uvm_reg_field::get_max_size() == expected_width, small_field.get_n_bits(), peer.get_n_bits());
    $finish;
  end

endmodule
