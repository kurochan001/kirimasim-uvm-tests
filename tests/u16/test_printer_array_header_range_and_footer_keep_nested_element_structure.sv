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
