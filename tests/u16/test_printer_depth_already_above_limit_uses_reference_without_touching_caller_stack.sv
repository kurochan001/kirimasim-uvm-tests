/*
:name: test_printer_depth_already_above_limit_uses_reference_without_touching_caller_stack
:description: printer depth already above limit uses reference without touching caller stack
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.5.10 16.2.3.1 16.1.3.1 16.1.3.2 16.1.3.3 16.1.3.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_depth_already_above_limit_uses_reference_without_touching_caller_stack.expected
*/
module test_printer_depth_already_above_limit_uses_reference_without_touching_caller_stack;
  import uvm_pkg::*;
  // Two caller-owned active entries already exceed limits zero and one.
  // A limit of three is a legal recursion control under either boundary view.
  class original_printer extends uvm_printer;
    virtual function string emit(); return ""; endfunction
  endclass
  class original_object extends uvm_object;
    int executes=0,prints=0;
    virtual function void do_execute_op(uvm_field_op op); executes++; endfunction
    virtual function void do_print(uvm_printer printer); prints++; endfunction
  endclass
  initial begin
    automatic int limits[3]='{0,1,3};
    foreach (limits[i]) begin
      automatic original_printer printer=new();
      automatic original_object first=new();
      automatic original_object second=new();
      automatic original_object value=new();
      printer.set_recursion_policy(UVM_DEEP); printer.set_max_depth(limits[i]);
      printer.push_active_object(first); printer.push_active_object(second);
      printer.print_object("selected",value);
      $display("UT: above_depth limit %0d executes %0d prints %0d depth %0d top %0d",limits[i],
               value.executes,value.prints,printer.get_active_object_depth(),
               printer.get_active_object()==second);
      void'(printer.pop_active_object()); void'(printer.pop_active_object());
      $display("UT: caller_unwound %0d",printer.get_active_object()==null);
    end
    $finish;
  end
endmodule
