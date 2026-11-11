/*
:name: test_policy_copier_default_wrappers_share_core_selection_and_restore_exact_identity
:description: policy copier default wrappers share core selection and restore exact identity
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.6.2.3 16.6.2.4 F.4.1.4.18 F.4.1.4.19 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_policy_copier_default_wrappers_share_core_selection_and_restore_exact_identity.expected
*/
// What it checks:
// 1. Setting the default copier through its wrapper selects the exact instance
//    in the core service.
// 2. The copier default getter returns the instance selected through the core
//    service and restores the saved selection.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.6.2.3 (UVM-POLICY-AUDIT-COPIER-SET-DEFAULT) gives rule 1
//    above. Setup: Use the selected original fixtures, explicit arguments and
//    stage observations in the linked anchors; each fresh policy and peer is
//    independently constructed. Expected: Setting the default copier through
//    its wrapper selects the exact instance in the core service.
// 2. 1800.2-2020 16.6.2.4 (UVM-POLICY-AUDIT-COPIER-GET-DEFAULT) gives rule 2
//    above. Setup: Use the selected original fixtures, explicit arguments and
//    stage observations in the linked anchors; each fresh policy and peer is
//    independently constructed. Expected: The copier default getter returns
//    the instance selected through the core service and restores the saved
//    selection.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_policy_copier_default_wrappers_share_core_selection_and_restore_exact_identity;
  import uvm_pkg::*;
  initial begin
    automatic uvm_coreservice_t core=uvm_coreservice_t::get();
    automatic uvm_copier saved=core.get_default_copier();
    automatic uvm_copier first=new("first");
    automatic uvm_copier second=new("second");
    uvm_copier::set_default(first);
    $display("UT: policy_default_selected wrapper %0d core %0d",uvm_copier::get_default()==first,
             core.get_default_copier()==first);
    core.set_default_copier(second);
    $display("UT: policy_default_reverse wrapper %0d core %0d",uvm_copier::get_default()==second,
             core.get_default_copier()==second);
    uvm_copier::set_default(saved);
    $display("UT: policy_default_restored %0d",core.get_default_copier()==saved);
    $finish;
  end
endmodule
