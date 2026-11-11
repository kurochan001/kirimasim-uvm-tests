/*
:name: test_vreg_callback_decl_register_concrete_86
:description: Listed callback facade declaration preserves construction and callback base views
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.2.1 18.10.6.1 1800-2023 6.21 8.12 8.13 8.17 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_callback_decl_register_concrete_86.expected
*/
// What it checks:
// 1. The listed nonvirtual virtual-register callback facade permits direct
//    construction.
// 2. The virtual-register callback facade and its legal subtype preserve a
//    uvm_callback base view.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.9.2.1 (UVM-VREG-CALLBACK-REG-FACADE-CONCRETE-86) gives
//    rule 1 above. Setup: Use the exact listed facade type or minimal original
//    concrete subtype, without extra method bodies. The register facade is
//    printed class; the field facade is printed virtual class. Static widening
//    verifies callback-base compatibility. Direct virtual construction has
//    only a compile-diagnostic oracle and no runtime seed. Expected: The
//    listed nonvirtual virtual-register callback facade permits direct
//    construction.
// 2. 1800.2-2020 18.9.2.1 (UVM-VREG-CALLBACK-REG-FACADE-BASE-86) gives rule 2
//    above. Setup: Use the exact listed facade type or minimal original
//    concrete subtype, without extra method bodies. The register facade is
//    printed class; the field facade is printed virtual class. Static widening
//    verifies callback-base compatibility. Direct virtual construction has
//    only a compile-diagnostic oracle and no runtime seed. Expected: The
//    virtual-register callback facade and its legal subtype preserve a
//    uvm_callback base view.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_vreg_callback_decl_register_concrete_86;
  import uvm_pkg::*;
  initial begin
    uvm_vreg_cbs facade;
    uvm_callback base_view;
    facade=new(); base_view=facade;
    $display("UT: vcb86 concrete nonnull %0d callback_view %0d",
      facade!=null,base_view==facade);
    $finish;
  end
endmodule
