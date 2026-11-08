/*
:name: test_fourstate_field_int_copy_117
:description: field-macro copy and clone of logic properties preserve four-state X and Z bits (IEEE 1800.2-2020 Section B.2.2.1.1)
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.2.2.1.1 B.2.1.2 5.3.8.1 5.3.5.2 1800-2023 5.7.1 6.3.1 6.11 11.4.5 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_fourstate_field_int_copy_117.expected
*/
// An object with narrow and wide logic fields holding X and Z bits is copied
// into another instance and cloned. Both results must hold the same bits,
// compared with case equality. The expectation comes from the cited clauses; a
// two-state simulator cannot represent X or Z, so this case is spec-only. Only
// the lines that begin with "UT: " are compared.
module test_fourstate_field_int_copy_117;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class fields117 extends uvm_object;
    logic [7:0] narrow;
    logic [99:0] wide;
    `uvm_object_utils_begin(fields117)
      `uvm_field_int(narrow, UVM_DEFAULT)
      `uvm_field_int(wide, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "fields117");
      super.new(name);
    endfunction
  endclass

  initial begin
    automatic fields117 source = new("source117");
    automatic fields117 target = new("target117");
    fields117 duplicate;
    source.narrow = 8'b1x0z_z0x1;
    source.wide = {4'bxz01, 92'h0, 4'b10zx};
    target.narrow = 8'h00;
    target.wide = '0;
    target.copy(source);
    $display("UT: copy narrow %0d wide %0d", target.narrow === 8'b1x0z_z0x1,
             target.wide === {4'bxz01, 92'h0, 4'b10zx});
    if (!$cast(duplicate, source.clone())) $fatal(1, "fourstate117 clone type");
    $display("UT: clone narrow %0d wide %0d", duplicate.narrow === 8'b1x0z_z0x1,
             duplicate.wide === {4'bxz01, 92'h0, 4'b10zx});
    $finish;
  end
endmodule
