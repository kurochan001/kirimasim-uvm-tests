/*
:name: test_printer_tree_default_instance_replacement_and_null_recovery_are_stable
:description: printer tree default instance replacement and null recovery are stable
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.11.2.3 16.2.11.2.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_tree_default_instance_replacement_and_null_recovery_are_stable.expected
*/
// What it checks:
// 1. The kind-specific setter replaces its selected default instance.
// 2. The initial kind-specific getter used by the fixture returns a retained
//    nonnull instance of the requested printer kind.
// 3. The kind-specific getter returns the last explicitly selected instance.
// 4. A null kind-specific selection is recovered by creating and retaining an
//    instance.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.2.11.2.3 (UVM-PRINTER-AUDIT-TREE-DEFAULT-SET) gives rule 1
//    above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The selected
//    exact handles and stable nonnull class type match, and the saved instance
//    is restored.
// 2. 1800.2-2020 16.2.11.2.4 (UVM-PRINTER-AUDIT-TREE-DEFAULT-GET-INITIAL)
//    gives rule 2 above. Setup: Use the original selected fixtures and
//    explicit API arguments represented by the observation anchors. Expected:
//    The selected exact handles and stable nonnull class type match, and the
//    saved instance is restored.
// 3. 1800.2-2020 16.2.11.2.4 (UVM-PRINTER-AUDIT-TREE-DEFAULT-GET-STABLE) gives
//    rule 3 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The selected
//    exact handles and stable nonnull class type match, and the saved instance
//    is restored.
// 4. 1800.2-2020 16.2.11.2.4
//    (UVM-PRINTER-AUDIT-TREE-DEFAULT-GET-NULL-RECOVERY) gives rule 4 above.
//    Setup: Use the original selected fixtures and explicit API arguments
//    represented by the observation anchors. Expected: The selected exact
//    handles and stable nonnull class type match, and the saved instance is
//    restored.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_printer_tree_default_instance_replacement_and_null_recovery_are_stable;
  import uvm_pkg::*;
  initial begin
    automatic uvm_tree_printer saved=uvm_tree_printer::get_default();
    automatic uvm_tree_printer first=new("first");
    automatic uvm_tree_printer second=new("second");
    uvm_tree_printer recovered;
    $display("UT: kind_default_initial nonnull %0d stable %0d type %0d",saved!=null,
             uvm_tree_printer::get_default()==saved,
             saved.get_type_name()=="uvm_tree_printer");
    uvm_tree_printer::set_default(first);
    $display("UT: kind_default_first exact %0d stable %0d",
             uvm_tree_printer::get_default()==first,uvm_tree_printer::get_default()==first);
    uvm_tree_printer::set_default(second);
    $display("UT: kind_default_second exact %0d",uvm_tree_printer::get_default()==second);
    uvm_tree_printer::set_default(null); recovered=uvm_tree_printer::get_default();
    $display("UT: kind_default_recovered nonnull %0d new %0d stable %0d type %0d",recovered!=null,
             recovered!=first && recovered!=second && recovered!=saved,
             uvm_tree_printer::get_default()==recovered,
             recovered.get_type_name()=="uvm_tree_printer");
    uvm_tree_printer::set_default(saved);
    $display("UT: kind_default_restored %0d",uvm_tree_printer::get_default()==saved);
    $finish;
  end
endmodule
