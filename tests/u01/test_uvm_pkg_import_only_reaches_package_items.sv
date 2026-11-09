/*
:name: test_uvm_pkg_import_only_reaches_package_items
:description: Bring-up stage 0: a module that only imports uvm_pkg names a package-scope enumeration value through the import and through the package name, without creating a UVM object or calling run_test
:tags: u01 uvm
:type: simulation
:lrm: 1800.2-2020 1.4.5 F.2.2.4 1800-2023 26.3 6.19 21.2.1
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_uvm_pkg_import_only_reaches_package_items.expected
*/
// What it checks: the smallest use of the library. The module imports
// uvm_pkg, creates no UVM object and does not call run_test, so a simulator
// only has to compile and elaborate the package and run its static
// initialization (bring-up stage 0, docs/kirimasim-stages.md).
//
// How the expectation follows from the standard: 1.4.5 says that every item
// of UVM is exported through uvm_pkg and can be reached by import or by the
// scope resolution operator, and F.2.2.4 gives UVM_LOW the value 100. The
// imported name and the qualified name therefore both print 100.
module test_uvm_pkg_import_only_reaches_package_items;
  import uvm_pkg::*;

  initial begin
    $display("UT: stage0 imported %0d qualified %0d", UVM_LOW, uvm_pkg::UVM_LOW);
    $finish;
  end
endmodule
