/*
:name: test_policy_comparer_default_wrappers_share_core_selection_and_restore_exact_identity
:description: policy comparer default wrappers share core selection and restore exact identity
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.3.2.4 16.3.2.5 F.4.1.4.16 F.4.1.4.17 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_policy_comparer_default_wrappers_share_core_selection_and_restore_exact_identity.expected
*/
// What it checks:
// 1. Setting the default comparer through its wrapper selects the exact
//    instance in the core service.
// 2. The comparer default getter returns the instance selected through the
//    core service and restores the saved selection.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.3.2.4 (UVM-POLICY-AUDIT-COMPARER-SET-DEFAULT) gives rule 1
//    above. Setup: Use the selected original fixtures, explicit arguments and
//    stage observations in the linked anchors; each fresh policy and peer is
//    independently constructed. Expected: Setting the default comparer through
//    its wrapper selects the exact instance in the core service.
// 2. 1800.2-2020 16.3.2.5 (UVM-POLICY-AUDIT-COMPARER-GET-DEFAULT) gives rule 2
//    above. Setup: Use the selected original fixtures, explicit arguments and
//    stage observations in the linked anchors; each fresh policy and peer is
//    independently constructed. Expected: The comparer default getter returns
//    the instance selected through the core service and restores the saved
//    selection.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_policy_comparer_default_wrappers_share_core_selection_and_restore_exact_identity;
  import uvm_pkg::*;
  initial begin
    automatic uvm_coreservice_t core=uvm_coreservice_t::get();
    automatic uvm_comparer saved=core.get_default_comparer();
    automatic uvm_comparer first=new("first");
    automatic uvm_comparer second=new("second");
    uvm_comparer::set_default(first);
    $display("UT: policy_default_selected wrapper %0d core %0d",uvm_comparer::get_default()==first,
             core.get_default_comparer()==first);
    core.set_default_comparer(second);
    $display("UT: policy_default_reverse wrapper %0d core %0d",uvm_comparer::get_default()==second,
             core.get_default_comparer()==second);
    uvm_comparer::set_default(saved);
    $display("UT: policy_default_restored %0d",core.get_default_comparer()==saved);
    $finish;
  end
endmodule
