/*
:name: test_printer_constructors_and_builtin_type_names_preserve_declared_names_and_bases
:description: printer constructors and builtin type names preserve declared names and bases
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.2.1 16.2.1 16.2.10.1 16.2.10.2.1 16.2.10.2.2 16.2.11.1 16.2.11.2.1 16.2.11.2.2 16.2.12.1 16.2.12.2.1 16.2.12.2.2 16.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_constructors_and_builtin_type_names_preserve_declared_names_and_bases.expected
*/
// What it checks:
// 1. The declared printer base is compatible with uvm_policy through a legal
//    concrete subtype.
// 2. The printer constructor defaults to unnamed and preserves forwarded
//    explicit/empty names.
// 3. The table printer is usable through the declared printer base.
// 4. The table printer constructor accepts default, named and empty names.
// 5. The table printer returns its specified type-name string.
// 6. The tree printer is usable through the declared printer base.
// 7. The tree printer constructor accepts default, named and empty names.
// 8. The tree printer returns its specified type-name string.
// 9. The line printer is usable through the declared printer base.
// 10. The line printer constructor accepts default, named and empty names.
// 11. The line printer returns its specified type-name string.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.2.1 (UVM-PRINTER-AUDIT-PRINTER-POLICY-BASE) gives rule 1
//    above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The
//    corresponding default/named/empty and exact base identity observations
//    match.
// 2. 1800.2-2020 16.2.2.1 (UVM-PRINTER-AUDIT-PRINTER-CONSTRUCTOR) gives rule 2
//    above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The
//    corresponding default/named/empty and exact base identity observations
//    match.
// 3. 1800.2-2020 16.2.10.1 (UVM-PRINTER-AUDIT-TABLE-BASE) gives rule 3 above.
//    Setup: Use the original selected fixtures and explicit API arguments
//    represented by the observation anchors. Expected: All selected
//    constructor-name, type-name and base identity observations match.
// 4. 1800.2-2020 16.2.10.2.1 (UVM-PRINTER-AUDIT-TABLE-CONSTRUCTOR) gives rule
//    4 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: All selected
//    constructor-name, type-name and base identity observations match.
// 5. 1800.2-2020 16.2.10.2.2 (UVM-PRINTER-AUDIT-TABLE-TYPE-NAME) gives rule 5
//    above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: All selected
//    constructor-name, type-name and base identity observations match.
// 6. 1800.2-2020 16.2.11.1 (UVM-PRINTER-AUDIT-TREE-BASE) gives rule 6 above.
//    Setup: Use the original selected fixtures and explicit API arguments
//    represented by the observation anchors. Expected: All selected
//    constructor-name, type-name and base identity observations match.
// 7. 1800.2-2020 16.2.11.2.1 (UVM-PRINTER-AUDIT-TREE-CONSTRUCTOR) gives rule 7
//    above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: All selected
//    constructor-name, type-name and base identity observations match.
// 8. 1800.2-2020 16.2.11.2.2 (UVM-PRINTER-AUDIT-TREE-TYPE-NAME) gives rule 8
//    above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: All selected
//    constructor-name, type-name and base identity observations match.
// 9. 1800.2-2020 16.2.12.1 (UVM-PRINTER-AUDIT-LINE-BASE) gives rule 9 above.
//    Setup: Use the original selected fixtures and explicit API arguments
//    represented by the observation anchors. Expected: All selected
//    constructor-name, type-name and base identity observations match.
// 10. 1800.2-2020 16.2.12.2.1 (UVM-PRINTER-AUDIT-LINE-CONSTRUCTOR) gives rule
//     10 above. Setup: Use the original selected fixtures and explicit API
//     arguments represented by the observation anchors. Expected: All selected
//     constructor-name, type-name and base identity observations match.
// 11. 1800.2-2020 16.2.12.2.2 (UVM-PRINTER-AUDIT-LINE-TYPE-NAME) gives rule 11
//     above. Setup: Use the original selected fixtures and explicit API
//     arguments represented by the observation anchors. Expected: All selected
//     constructor-name, type-name and base identity observations match.
// It also supports, as a control, the setup or conditions of
// UVM-PRINTER-AUDIT-UVM-PRINTER-DIRECT-CONSTRUCTION.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_printer_constructors_and_builtin_type_names_preserve_declared_names_and_bases;
  import uvm_pkg::*;
  class omitted_printer extends uvm_printer;
    virtual function string emit(); return ""; endfunction
  endclass
  class named_printer extends uvm_printer;
    function new(string name); super.new(name); endfunction
    virtual function string emit(); return ""; endfunction
  endclass
  initial begin
    automatic omitted_printer omitted=new();
    automatic named_printer named=new("selected");
    automatic named_printer empty=new("");
    automatic uvm_policy base_view=named;
    automatic uvm_table_printer table_default=new();
    automatic uvm_table_printer table_named=new("table");
    automatic uvm_table_printer table_empty=new("");
    automatic uvm_tree_printer tree_default=new();
    automatic uvm_tree_printer tree_named=new("tree");
    automatic uvm_tree_printer tree_empty=new("");
    automatic uvm_line_printer line_default=new();
    automatic uvm_line_printer line_named=new("line");
    automatic uvm_line_printer line_empty=new("");
    automatic uvm_printer views[3]='{table_named,tree_named,line_named};
    $display("UT: base_printer_names default %0d named %0d empty %0d base %0d",
             omitted.get_name()=="",named.get_name()=="selected",empty.get_name()=="",
             base_view==named);
    $display("UT: table_printer_names default %0d named %0d empty %0d type %0d base %0d",
             table_default.get_name()=="",table_named.get_name()=="table",
             table_empty.get_name()=="",
             table_named.get_type_name()=="uvm_table_printer",views[0]==table_named);
    $display("UT: tree_printer_names default %0d named %0d empty %0d type %0d base %0d",
             tree_default.get_name()=="",tree_named.get_name()=="tree",tree_empty.get_name()=="",
             tree_named.get_type_name()=="uvm_tree_printer",views[1]==tree_named);
    $display("UT: line_printer_names default %0d named %0d empty %0d type %0d base %0d",
             line_default.get_name()=="",line_named.get_name()=="line",line_empty.get_name()=="",
             line_named.get_type_name()=="uvm_line_printer",views[2]==line_named);
    $finish;
  end
endmodule
