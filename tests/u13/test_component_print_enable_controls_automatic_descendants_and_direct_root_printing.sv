/*
:name: test_component_print_enable_controls_automatic_descendants_and_direct_root_printing
:description: component print enable controls automatic descendants and direct root printing
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.2.2 13.1.2.3 5.3.6.2 5.3.13 5.7.2.8 16.2.3.1 16.2.4.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_print_enable_controls_automatic_descendants_and_direct_root_printing.expected
*/
module test_component_print_enable_controls_automatic_descendants_and_direct_root_printing;
  import uvm_pkg::*;
  class observer_printer extends uvm_printer;
    virtual function string emit(); return "P46"; endfunction
  endclass
  class print_actor extends uvm_component;
    int visits=0;
    bit suppress=0;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    virtual function void do_execute_op(uvm_field_op op);
      super.do_execute_op(op);
      if (suppress) op.disable_user_hook();
    endfunction
    virtual function void do_print(uvm_printer printer);
      visits++; super.do_print(printer);
    endfunction
  endclass
  function automatic void reset_probe(observer_printer printer,print_actor root,
                                     print_actor selected,print_actor peer,print_actor grand);
    root.visits=0; selected.visits=0; peer.visits=0; grand.visits=0;
    printer.flush(); printer.set_recursion_policy(UVM_DEEP); printer.set_max_depth(-1);
  endfunction
  initial begin
    automatic print_actor root=new("root46",null);
    automatic print_actor selected=new("selected",root);
    automatic print_actor peer=new("peer",root);
    automatic print_actor grand=new("grand",selected);
    automatic observer_printer printer=new();
    $display("UT: child_print_defaults selected %0d peer %0d grand %0d",
             selected.print_enabled,peer.print_enabled,grand.print_enabled);
    reset_probe(printer,root,selected,peer,grand); void'(root.sprint(printer));
    $display("UT: child_print_all root %0d selected %0d peer %0d grand %0d",
             root.visits,selected.visits,peer.visits,grand.visits);
    selected.print_enabled=0;
    reset_probe(printer,root,selected,peer,grand); void'(root.sprint(printer));
    $display("UT: child_print_disabled root %0d selected %0d peer %0d grand %0d",
             root.visits,selected.visits,peer.visits,grand.visits);
    reset_probe(printer,root,selected,peer,grand); void'(selected.sprint(printer));
    $display("UT: child_print_direct selected %0d grand %0d",selected.visits,grand.visits);
    selected.print_enabled=1; root.suppress=1;
    reset_probe(printer,root,selected,peer,grand); void'(root.sprint(printer));
    $display("UT: child_print_field_stage root %0d selected %0d peer %0d grand %0d",
             root.visits,selected.visits,peer.visits,grand.visits);
    $finish;
  end
endmodule
