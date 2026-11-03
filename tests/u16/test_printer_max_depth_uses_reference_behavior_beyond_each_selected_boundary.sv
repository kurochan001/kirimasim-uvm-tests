/*
:name: test_printer_max_depth_uses_reference_behavior_beyond_each_selected_boundary
:description: printer max depth uses reference behavior beyond each selected boundary
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.5.10 16.2.5.9 16.2.3.1 16.1.3.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_max_depth_uses_reference_behavior_beyond_each_selected_boundary.expected
*/
module test_printer_max_depth_uses_reference_behavior_beyond_each_selected_boundary;
  import uvm_pkg::*;
  // This probe reads scope depth at print_object entry. Keep its boundary
  // interpretation reviewable; a separate above-limit probe avoids this tie.
  class original_printer extends uvm_printer;
    virtual function string emit(); return ""; endfunction
  endclass
  class node extends uvm_object;
    node child;
    int visits=0;
    virtual function void do_print(uvm_printer printer);
      visits++;
      if (child!=null) printer.print_object("child",child);
    endfunction
  endclass
  initial begin
    automatic int depths[4]='{-1,0,1,2};
    foreach (depths[i]) begin
      automatic original_printer printer=new();
      automatic node root=new();
      automatic node child=new();
      automatic node grandchild=new();
      root.child=child; child.child=grandchild;
      printer.set_recursion_policy(UVM_DEEP); printer.set_max_depth(depths[i]);
      printer.print_object("root",root);
      $display("UT: recursion_depth %0d visits %0d/%0d/%0d depth %0d",depths[i],root.visits,
               child.visits,grandchild.visits,printer.get_active_object_depth());
    end
    $finish;
  end
endmodule
