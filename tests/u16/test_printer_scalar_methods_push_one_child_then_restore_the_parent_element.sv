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
