/*
:name: test_selected_core_root_is_the_implicit_top_and_retains_live_hierarchy_identity
:description: The selected core root agrees with public root and report-object accessors
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.4.1.4.1 F.4 F.4.1.3 F.7.2.2 F.3.2.1 13.1.2.1 1800-2023 6.21 8.20 8.21 13.5.2 18.13.3 18.13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_selected_core_root_is_the_implicit_top_and_retains_live_hierarchy_identity.expected
*/
// What it checks:
// 1. The selected core service is a common access point for the implicit root.
// 2. Repeated core retrieval retains the selected initialized service.
// 3. The selected service returns the implicit root instance.
// 4. The root static accessor wraps the core root instance.
// 5. The package report-object accessor retains the implicit root view.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 F.4 (UVM-CORE-DECL-AUDIT-GLOBAL-ROOT-POINT) gives rule 1
//    above. Setup: Use fresh simulation state, exact public base views and
//    original objects; do not install an extra custom global service or assume
//    an implementation default concrete type. Expected:
//    Core/root/report-object accessors agree and repeated retrieval retains
//    the live original child.
// 2. 1800.2-2020 F.4.1.3 (UVM-CORE-DECL-AUDIT-SELECTED-SERVICE-STABLE) gives
//    rule 2 above. Setup: Use fresh simulation state, exact public base views
//    and original objects; do not install an extra custom global service or
//    assume an implementation default concrete type. Expected: The service and
//    root handles remain identical after a real child is created and changed.
// 3. 1800.2-2020 F.4.1.4.1 (UVM-CORE-DECL-AUDIT-SELECTED-ROOT-IDENTITY) gives
//    rule 3 above. Setup: Use fresh simulation state, exact public base views
//    and original objects; do not install an extra custom global service or
//    assume an implementation default concrete type. Expected: The exact root
//    handle owns the selected original top-level child and sees its live
//    state.
// 4. 1800.2-2020 F.7.2.2 (UVM-CORE-DECL-AUDIT-ROOT-STATIC-WRAPPER) gives rule
//    4 above. Setup: Use fresh simulation state, exact public base views and
//    original objects; do not install an extra custom global service or assume
//    an implementation default concrete type. Expected: uvm_root::get and
//    service.get_root return the same object before and after child mutation.
// 5. 1800.2-2020 F.3.2.1 (UVM-CORE-DECL-AUDIT-REPORT-ROOT-VIEW) gives rule 5
//    above. Setup: Use fresh simulation state, exact public base views and
//    original objects; do not install an extra custom global service or assume
//    an implementation default concrete type. Expected: Its handle is the same
//    selected root instance used by the hierarchy.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_selected_core_root_is_the_implicit_top_and_retains_live_hierarchy_identity;
  import uvm_pkg::*;
  class original_child extends uvm_component;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
  endclass
  initial begin
    automatic uvm_coreservice_t service=uvm_coreservice_t::get();
    automatic uvm_root root=service.get_root();
    automatic original_child child=new("core_child64",null);
    $display("UT: selected_root exact %0d reporter %0d parent %0d child %0d",
      root==uvm_root::get(),uvm_get_report_object()==root,child.get_parent()==root,
      root.get_child("core_child64")==child);
    child.set_report_verbosity_level(UVM_HIGH);
    $display("UT: selected_root live_child %0d stable %0d",
      service.get_root().get_child("core_child64").get_report_verbosity_level()==UVM_HIGH,
      service==uvm_coreservice_t::get() && service.get_root()==root);
    $finish;
  end
endmodule
