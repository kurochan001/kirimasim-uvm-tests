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
// What it checks:
// 1. The virtual-register callback facade and its legal subtype preserve a
//    uvm_callback base view.
// 2. A concrete subtype of the virtual-field callback facade preserves a
//    uvm_callback base view.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.9.2.1 (UVM-VREG-CALLBACK-REG-FACADE-BASE-86) gives rule 1
//    above. Setup: Use the exact listed facade type or minimal original
//    concrete subtype, without extra method bodies. The register facade is
//    printed class; the field facade is printed virtual class. Static widening
//    verifies callback-base compatibility. Direct virtual construction has
//    only a compile-diagnostic oracle and no runtime seed. Expected: The
//    virtual-register callback facade and its legal subtype preserve a
//    uvm_callback base view.
// 2. 1800.2-2020 18.10.6.1 (UVM-VREG-CALLBACK-FIELD-FACADE-BASE-86) gives rule
//    2 above. Setup: Use the exact listed facade type or minimal original
//    concrete subtype, without extra method bodies. The register facade is
//    printed class; the field facade is printed virtual class. Static widening
//    verifies callback-base compatibility. Direct virtual construction has
//    only a compile-diagnostic oracle and no runtime seed. Expected: A
//    concrete subtype of the virtual-field callback facade preserves a
//    uvm_callback base view.
// It also supports, as a control, the setup or conditions of
// UVM-VREG-CALLBACK-REG-FACADE-CONCRETE-86,
// UVM-VREG-CALLBACK-FIELD-FACADE-VIRTUAL-86.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
