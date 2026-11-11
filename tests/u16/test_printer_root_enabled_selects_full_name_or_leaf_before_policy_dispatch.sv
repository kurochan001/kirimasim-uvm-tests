/*
:name: test_printer_root_enabled_selects_full_name_or_leaf_before_policy_dispatch
:description: printer root enabled selects full name or leaf before policy dispatch
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.5.8 5.3.6.1 5.3.6.2 16.2.3.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_root_enabled_selects_full_name_or_leaf_before_policy_dispatch.expected
*/
// What it checks:
// 1. The default root control selects the full object name.
// 2. A disabled root control selects the leaf object name.
// 3. Re-enabling root control selects the full object name again.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.2.5.8 (UVM-PRINTER-AUDIT-ROOT-NAME-DEFAULT) gives rule 1
//    above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The root name
//    passed to print_object matches the selected full/leaf source without
//    fixing emitted text.
// 2. 1800.2-2020 16.2.5.8 (UVM-PRINTER-AUDIT-ROOT-NAME-LEAF) gives rule 2
//    above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The root name
//    passed to print_object matches the selected full/leaf source without
//    fixing emitted text.
// 3. 1800.2-2020 16.2.5.8 (UVM-PRINTER-AUDIT-ROOT-NAME-RESELECT) gives rule 3
//    above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The root name
//    passed to print_object matches the selected full/leaf source without
//    fixing emitted text.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_printer_root_enabled_selects_full_name_or_leaf_before_policy_dispatch;
  import uvm_pkg::*;
  class original_printer extends uvm_printer;
    string seen_name;
    virtual function void print_object(string name,uvm_object value,byte scope_separator=".");
      seen_name=name; super.print_object(name,value,scope_separator);
    endfunction
    virtual function string emit(); return "captured"; endfunction
  endclass
  class original_object extends uvm_object;
    function new(); super.new("leaf42"); endfunction
    virtual function string get_full_name(); return "scope.leaf42"; endfunction
  endclass
  initial begin
    automatic original_printer printer=new();
    automatic original_object value=new();
    string text;
    text=value.sprint(printer);
    $display("UT: root_default flag %0d full %0d",printer.get_root_enabled(),
             printer.seen_name=="scope.leaf42");
    printer.set_root_enabled(0); text=value.sprint(printer);
    $display("UT: root_disabled flag %0d leaf %0d",printer.get_root_enabled(),
             printer.seen_name=="leaf42");
    printer.set_root_enabled(1); text=value.sprint(printer);
    $display("UT: root_restored flag %0d full %0d",printer.get_root_enabled(),
             printer.seen_name=="scope.leaf42");
    $finish;
  end
endmodule
