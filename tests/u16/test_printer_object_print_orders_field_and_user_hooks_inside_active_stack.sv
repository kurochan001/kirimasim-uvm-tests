/*
:name: test_printer_object_print_orders_field_and_user_hooks_inside_active_stack
:description: printer object print orders field and user hooks inside active stack
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.3.1 16.2.3.2 16.1.3.3 16.1.3.4 5.3.13 5.3.6.3 5.7.2.8 16.1.3 16.1.3.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_object_print_orders_field_and_user_hooks_inside_active_stack.expected
*/
// What it checks:
// 1. A selected print operation brackets object hooks with the active-object
//    stack.
// 2. A recursed object receives the PRINT field operation with the current
//    printer as policy.
// 3. The object is active and marked STARTED before the print field hook.
// 4. The enabled do_print hook follows the field-operation hook and receives
//    the same policy.
// 5. The printer marks the recursed object FINISHED before popping its active
//    entry.
// 6. The selected object history changes from NEVER through STARTED to
//    FINISHED.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.1.3 (UVM-PRINTER-AUDIT-ACTIVE-OBJECT-BRACKETING) gives
//    rule 1 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: Selected hook
//    order, exact policy/active identity, depth one during hooks and empty
//    depth zero after return match; FINISHED is visible before the active pop.
// 2. 1800.2-2020 16.2.3.1 (UVM-PRINTER-AUDIT-PRINT-FIELD-OP) gives rule 2
//    above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: Selected hook
//    order, exact policy/active identity, depth one during hooks and empty
//    depth zero after return match; FINISHED is visible before the active pop.
// 3. 1800.2-2020 16.2.3.1 (UVM-PRINTER-AUDIT-PRINT-STARTED-BEFORE-FIELD) gives
//    rule 3 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: Selected hook
//    order, exact policy/active identity, depth one during hooks and empty
//    depth zero after return match; FINISHED is visible before the active pop.
// 4. 1800.2-2020 16.2.3.1 (UVM-PRINTER-AUDIT-PRINT-USER-HOOK-ORDER) gives rule
//    4 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: Selected hook
//    order, exact policy/active identity, depth one during hooks and empty
//    depth zero after return match; FINISHED is visible before the active pop.
// 5. 1800.2-2020 16.2.3.1 (UVM-PRINTER-AUDIT-PRINT-FINISHED-BEFORE-POP) gives
//    rule 5 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: Selected hook
//    order, exact policy/active identity, depth one during hooks and empty
//    depth zero after return match; FINISHED is visible before the active pop.
// 6. 1800.2-2020 16.2.3.2 (UVM-PRINTER-AUDIT-PRINT-HISTORY-STATES) gives rule
//    6 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: Selected hook
//    order, exact policy/active identity, depth one during hooks and empty
//    depth zero after return match; FINISHED is visible before the active pop.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_printer_object_print_orders_field_and_user_hooks_inside_active_stack;
  import uvm_pkg::*;
  class original_printer extends uvm_printer;
    bit finished_before_pop=0;
    virtual function uvm_object pop_active_object();
      finished_before_pop=object_printed(get_active_object(),UVM_DEEP)==uvm_policy::FINISHED;
      return super.pop_active_object();
    endfunction
    virtual function string emit(); return ""; endfunction
  endclass
  class original_object extends uvm_object;
    uvm_printer expected_printer;
    int executes=0, prints=0;
    bit suppress_hook=0;
    string trace;
    virtual function void do_execute_op(uvm_field_op op);
      uvm_printer printer;
      if (!$cast(printer,op.get_policy())) $fatal(1,"wrong print policy");
      executes++; trace={trace,"E"};
      $display("UT: print_execute op %s policy %0d active %0d depth %0d started %0d",
               op.get_op_name(),printer==expected_printer,printer.get_active_object()==this,
               printer.get_active_object_depth(),
               printer.object_printed(this,UVM_DEEP)==uvm_policy::STARTED);
      if (suppress_hook) op.disable_user_hook();
    endfunction
    virtual function void do_print(uvm_printer printer);
      prints++; trace={trace,"P"};
      $display("UT: print_hook policy %0d active %0d depth %0d started %0d",
               printer==expected_printer,printer.get_active_object()==this,
               printer.get_active_object_depth(),
               printer.object_printed(this,UVM_DEEP)==uvm_policy::STARTED);
    endfunction
  endclass
  initial begin
    automatic original_printer printer = new();
    automatic original_object value = new();
    value.expected_printer=printer; value.suppress_hook=0;
    printer.set_recursion_policy(UVM_DEEP);
    $display("UT: print_never %0d",printer.object_printed(value,UVM_DEEP)==uvm_policy::NEVER);
    printer.print_object("selected",value);
    $display("UT: print_complete trace %s executes %0d prints %0d finished %0d depth %0d empty %0d",
             value.trace,value.executes,value.prints,
             printer.object_printed(value,UVM_DEEP)==uvm_policy::FINISHED,
             printer.get_active_object_depth(),printer.get_active_object()==null);
    $display("UT: finished_before_pop %0d",printer.finished_before_pop);
    $finish;
  end
endmodule
