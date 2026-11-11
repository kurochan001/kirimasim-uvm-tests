/*
:name: test_printer_array_header_range_and_footer_keep_nested_element_structure
:description: printer array header range and footer keep nested element structure
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.3.5 16.2.3.6 16.2.3.7 16.2.7 16.2.9.2.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_array_header_range_and_footer_keep_nested_element_structure.expected
*/
// What it checks:
// 1. An array header opens a nested element with default type array.
// 2. An explicit array type is passed into the opened array element.
// 3. A skipped array range adds an ellipsis element and restores the active
//    array.
// 4. The array footer completes the nested array and restores its enclosing
//    element.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.2.3.5 (UVM-PRINTER-AUDIT-ARRAY-HEADER-DEFAULT-TYPE) gives
//    rule 1 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The selected
//    array type, parent identity, one range push/pop, ellipsis and three
//    immediate children match without fixing footer text.
// 2. 1800.2-2020 16.2.3.5 (UVM-PRINTER-AUDIT-ARRAY-HEADER-EXPLICIT-TYPE) gives
//    rule 2 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The selected
//    array type, parent identity, one range push/pop, ellipsis and three
//    immediate children match without fixing footer text.
// 3. 1800.2-2020 16.2.3.6 (UVM-PRINTER-AUDIT-ARRAY-RANGE-ELLIPSIS) gives rule
//    3 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The selected
//    array type, parent identity, one range push/pop, ellipsis and three
//    immediate children match without fixing footer text.
// 4. 1800.2-2020 16.2.3.7 (UVM-PRINTER-AUDIT-ARRAY-FOOTER-RESTORE) gives rule
//    4 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The selected
//    array type, parent identity, one range push/pop, ellipsis and three
//    immediate children match without fixing footer text.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_printer_array_header_range_and_footer_keep_nested_element_structure;
  import uvm_pkg::*;
  class stack_printer extends uvm_printer;
    int pushes=0,pops=0;
    uvm_printer_element latest;
    function uvm_printer_element top(); return get_top_element(); endfunction
    function uvm_printer_element bottom(); return get_bottom_element(); endfunction
    virtual function void push_element(string name,string type_name,string size,string value="");
      pushes++; super.push_element(name,type_name,size,value); latest=get_top_element();
    endfunction
    virtual function void pop_element(); pops++; super.pop_element(); endfunction
    virtual function string emit(); return ""; endfunction
  endclass
  initial begin
    automatic stack_printer printer=new();
    automatic uvm_printer_element_proxy proxy=new();
    uvm_printer_element parent,array_value,children[$];
    string range_value;
    bit ellipsis;
    printer.push_element("root","object","",""); parent=printer.top();
    printer.print_array_header("values",10); array_value=printer.top();
    $display("UT: array_header different %0d root %0d default_type %0d",
             array_value!=parent,printer.bottom()==parent,
             array_value.get_element_type_name()=="array");
    printer.print_field_int("[0]",1,8);
    printer.pushes=0; printer.pops=0; printer.print_array_range(1,8);
    range_value=printer.latest.get_element_value(); ellipsis=0;
    for (int i=0;i+3<=range_value.len();i++)
      if (range_value.substr(i,i+2)=="...") ellipsis=1;
    $display("UT: array_range push %0d pop %0d parent %0d ellipsis %0d",
             printer.pushes,printer.pops,printer.top()==array_value,ellipsis);
    printer.print_field_int("[9]",9,8); printer.print_array_footer();
    proxy.get_immediate_children(array_value,children);
    $display("UT: array_footer restored %0d children %0d",printer.top()==parent,children.size());
    printer.print_array_header("next",0,"queue");
    $display("UT: explicit_array_type %0d",printer.top().get_element_type_name()=="queue");
    printer.print_array_footer(0);
    $display("UT: explicit_footer restored %0d",printer.top()==parent);
    $finish;
  end
endmodule
