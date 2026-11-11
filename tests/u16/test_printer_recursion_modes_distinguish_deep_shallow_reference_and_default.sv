/*
:name: test_printer_recursion_modes_distinguish_deep_shallow_reference_and_default
:description: printer recursion modes distinguish deep shallow reference and default
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.5.9 16.2.3.1 16.2.3.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_recursion_modes_distinguish_deep_shallow_reference_and_default.expected
*/
// What it checks:
// 1. The selected DEEP recursion setting controls target and child printing.
// 2. The selected SHALLOW recursion setting controls target and child
//    printing.
// 3. The selected REFERENCE recursion setting controls target and child
//    printing.
// 4. The selected DEFAULT_POLICY recursion setting controls target and child
//    printing.
// 5. A fresh printer reports UVM_DEFAULT_POLICY before any recursion setting.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.2.5.9 (UVM-PRINTER-AUDIT-RECURSION-DEEP) gives rule 1
//    above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: A three-node
//    original chain has visit counts 1/1/1 and returns with an empty active
//    stack.
// 2. 1800.2-2020 16.2.5.9 (UVM-PRINTER-AUDIT-RECURSION-SHALLOW) gives rule 2
//    above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: A three-node
//    original chain has visit counts 1/0/0 and returns with an empty active
//    stack.
// 3. 1800.2-2020 16.2.5.9 (UVM-PRINTER-AUDIT-RECURSION-REFERENCE) gives rule 3
//    above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: A three-node
//    original chain has visit counts 0/0/0 and returns with an empty active
//    stack.
// 4. 1800.2-2020 16.2.5.9 (UVM-PRINTER-AUDIT-RECURSION-DEFAULT-POLICY) gives
//    rule 4 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: A three-node
//    original chain has visit counts 1/1/1 and returns with an empty active
//    stack.
// 5. 1800.2-2020 16.2.5.9 (UVM-PRINTER-AUDIT-RECURSION-DEFAULT-GETTER) gives
//    rule 5 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The omitted
//    recursion configuration getter equals the declared default.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_printer_recursion_modes_distinguish_deep_shallow_reference_and_default;
  import uvm_pkg::*;
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
    automatic original_printer default_value=new();
    automatic uvm_recursion_policy_enum modes[4]='{UVM_DEEP,UVM_SHALLOW,UVM_REFERENCE,
                                                   UVM_DEFAULT_POLICY};
    $display("UT: recursion_default_policy %0d",
             default_value.get_recursion_policy()==UVM_DEFAULT_POLICY);
    foreach (modes[i]) begin
      automatic original_printer printer=new();
      automatic node root=new();
      automatic node child=new();
      automatic node grandchild=new();
      root.child=child; child.child=grandchild;
      printer.set_recursion_policy(modes[i]); printer.print_object("root",root);
      $display("UT: recursion_mode %0d visits %0d/%0d/%0d depth %0d",i,root.visits,
               child.visits,grandchild.visits,printer.get_active_object_depth());
    end
    $finish;
  end
endmodule
