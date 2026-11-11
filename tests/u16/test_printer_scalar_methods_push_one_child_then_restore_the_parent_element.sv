/*
:name: test_printer_scalar_methods_push_one_child_then_restore_the_parent_element
:description: printer scalar methods push one child then restore the parent element
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.7 16.2.3.3 16.2.3.4 16.2.3.8 16.2.3.9 16.2.3.10 16.2.3.11 16.2.3.12 16.2.7.1 16.2.7.2 16.2.9.2.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_scalar_methods_push_one_child_then_restore_the_parent_element.expected
*/
// What it checks:
// 1. The selected GENERIC print API creates one child element then restores
//    its parent.
// 2. The selected GENERIC-ELEMENT print API creates one child element then
//    restores its parent.
// 3. The selected FIELD print API creates one child element then restores its
//    parent.
// 4. The selected FIELD-INT print API creates one child element then restores
//    its parent.
// 5. The selected STRING print API creates one child element then restores its
//    parent.
// 6. The selected TIME print API creates one child element then restores its
//    parent.
// 7. The selected REAL print API creates one child element then restores its
//    parent.
// 8. print_generic_element preserves the four caller-supplied textual
//    attributes in the child element.
// 9. Scalar printing preserves root encapsulation while accumulating new
//    children.
// 10. The bottom-element accessor continues to identify the outermost root.
// 11. The top-element accessor returns the restored current parent after each
//     scalar print.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.2.3.3 (UVM-PRINTER-AUDIT-SCALAR-GENERIC-ELEMENT) gives
//    rule 1 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: One push/pop
//    is observed, the top/bottom return to the root, and the proxy contains
//    exactly the new element once.
// 2. 1800.2-2020 16.2.3.4 (UVM-PRINTER-AUDIT-SCALAR-GENERIC-ELEMENT-ELEMENT)
//    gives rule 2 above. Setup: Use the original selected fixtures and
//    explicit API arguments represented by the observation anchors. Expected:
//    One push/pop is observed, the top/bottom return to the root, and the
//    proxy contains exactly the new element once.
// 3. 1800.2-2020 16.2.3.8 (UVM-PRINTER-AUDIT-SCALAR-FIELD-ELEMENT) gives rule
//    3 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: One push/pop
//    is observed, the top/bottom return to the root, and the proxy contains
//    exactly the new element once.
// 4. 1800.2-2020 16.2.3.9 (UVM-PRINTER-AUDIT-SCALAR-FIELD-INT-ELEMENT) gives
//    rule 4 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: One push/pop
//    is observed, the top/bottom return to the root, and the proxy contains
//    exactly the new element once.
// 5. 1800.2-2020 16.2.3.10 (UVM-PRINTER-AUDIT-SCALAR-STRING-ELEMENT) gives
//    rule 5 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: One push/pop
//    is observed, the top/bottom return to the root, and the proxy contains
//    exactly the new element once.
// 6. 1800.2-2020 16.2.3.11 (UVM-PRINTER-AUDIT-SCALAR-TIME-ELEMENT) gives rule
//    6 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: One push/pop
//    is observed, the top/bottom return to the root, and the proxy contains
//    exactly the new element once.
// 7. 1800.2-2020 16.2.3.12 (UVM-PRINTER-AUDIT-SCALAR-REAL-ELEMENT) gives rule
//    7 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: One push/pop
//    is observed, the top/bottom return to the root, and the proxy contains
//    exactly the new element once.
// 8. 1800.2-2020 16.2.3.4 (UVM-PRINTER-AUDIT-GENERIC-ELEMENT-EXACT-FIELDS)
//    gives rule 8 above. Setup: Use the original selected fixtures and
//    explicit API arguments represented by the observation anchors. Expected:
//    The child retains direct, opaqueType, many and direct42 exactly.
// 9. 1800.2-2020 16.2.7 (UVM-PRINTER-AUDIT-SCALAR-STACK-ENCAPSULATION) gives
//    rule 9 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: All seven
//    selected scalar APIs retain the root top/bottom identity and add one
//    distinct reachable child each.
// 10. 1800.2-2020 16.2.7.1 (UVM-PRINTER-AUDIT-BOTTOM-ELEMENT-QUERY) gives rule
//     10 above. Setup: Use the original selected fixtures and explicit API
//     arguments represented by the observation anchors. Expected: All seven
//     selected scalar APIs retain the root top/bottom identity and add one
//     distinct reachable child each.
// 11. 1800.2-2020 16.2.7.2 (UVM-PRINTER-AUDIT-TOP-ELEMENT-QUERY) gives rule 11
//     above. Setup: Use the original selected fixtures and explicit API
//     arguments represented by the observation anchors. Expected: All seven
//     selected scalar APIs retain the root top/bottom identity and add one
//     distinct reachable child each.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_printer_scalar_methods_push_one_child_then_restore_the_parent_element;
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
    uvm_printer_element parent,children[$];
    int occurrences;
    printer.push_element("root","original","",""); parent=printer.top();
    for (int i=0;i<7;i++) begin
      printer.pushes=0; printer.pops=0;
      case (i)
        0: printer.print_generic("generic","opaque",13,"generic42");
        1: printer.print_generic_element("direct","opaqueType","many","direct42");
        2: printer.print_field("wide",65'h1000000000000002a,65,UVM_HEX);
        3: printer.print_field_int("narrow",64'h800000000000002a,64,UVM_HEX);
        4: printer.print_string("text","string42");
        5: printer.print_time("time",93);
        6: printer.print_real("real",-2.5);
      endcase
      children.delete(); proxy.get_immediate_children(parent,children); occurrences=0;
      foreach (children[k]) if (children[k]==printer.latest) occurrences++;
      $display("UT: scalar_stack %0d push %0d pop %0d parent %0d base %0d children %0d latest %0d",
               i,printer.pushes,printer.pops,printer.top()==parent,printer.bottom()==parent,
               children.size(),occurrences);
      if (i==1) $display("UT: direct_element fields %0d/%0d/%0d/%0d",
               printer.latest.get_element_name()=="direct",
               printer.latest.get_element_type_name()=="opaqueType",
               printer.latest.get_element_size()=="many",
               printer.latest.get_element_value()=="direct42");
    end
    $finish;
  end
endmodule
