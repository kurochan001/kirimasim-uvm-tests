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
