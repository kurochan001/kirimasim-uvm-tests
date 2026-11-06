/*
:name: test_vreg_callback_decl_derived_views_86
:description: Listed callback facade declaration preserves construction and callback base views
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.10.6.1 18.9.2.1 1800-2023 6.21 8.12 8.13 8.17 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_callback_decl_derived_views_86.expected
*/
module test_vreg_callback_decl_derived_views_86;
  import uvm_pkg::*;
  class reg_child86 extends uvm_vreg_cbs;
    function new(); super.new(); endfunction
  endclass
  class field_child86 extends uvm_vreg_field_cbs;
    function new(); super.new(); endfunction
  endclass
  initial begin
    automatic reg_child86 r=new();
    automatic field_child86 f=new();
    uvm_callback rbase,fbase;
    rbase=r; fbase=f;
    $display("UT: vcb86 derived register %0d field %0d",
      r!=null && rbase==r,f!=null && fbase==f);
    $finish;
  end
endmodule
