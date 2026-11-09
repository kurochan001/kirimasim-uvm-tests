/*
:name: test_object_print_field_operation_controls_the_user_hook_and_current_policy
:description: Real sprint delegates field operations before an optionally suppressed user hook
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.13 5.3.6 5.3.6.1 5.3.6.2 5.3.6.3 5.7.2.7 5.7.2.8 16.2.3.9 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_print_field_operation_controls_the_user_hook_and_current_policy.expected
*/
// What it checks:
// 1. The original print customization uses the supplied printer API for
//    fields.
// 2. Field-operation dispatch precedes the selected user print hook.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.3.6 (UVM-BASE-AUDIT-PRINT-POLICY-API) gives rule 1 above.
//    Setup: Use an original emit string and field observer with real sprint
//    entry calls. Expected: The selected field and custom emit result
//    propagate through the policy.
// 2. 1800.2-2020 5.3.13 (UVM-BASE-AUDIT-FIELD-PRINT-ORDER) gives rule 2 above.
//    Setup: The original do_execute_op checks UVM_PRINT/current policy and
//    conditionally disables the user hook. Expected: The disabled trace is E
//    with no user field; the next enabled operation is EP with the selected
//    payload.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_object_print_field_operation_controls_the_user_hook_and_current_policy;
  import uvm_pkg::*;
  class original_object extends uvm_object;
    function new(string name=""); super.new(name); endfunction
    virtual function string get_type_name(); return "original_object61"; endfunction
    virtual function uvm_object create(string name="");
      original_object result;
      result=new(name); return result;
    endfunction
  endclass
  class capture_printer extends uvm_printer;
    int fields=0;
    uvm_integral_t last_value=0;
    function new(); super.new("printer61"); endfunction
    virtual function void print_field_int(string name,uvm_integral_t value,int size,
      uvm_radix_enum radix=UVM_NORADIX,byte scope_separator=".",string type_name="");
      if (name=="payload61") begin fields++; last_value=value; end
    endfunction
    virtual function string emit(); return "original_format61"; endfunction
  endclass
  class printable extends original_object;
    bit suppress=1,correct_operation=1,enabled_on_entry=1;
    uvm_printer expected_policy;
    string trace="";
    function new(); super.new("printable61"); endfunction
    virtual function void do_execute_op(uvm_field_op op);
      trace={trace,"E"};
      correct_operation &= op.get_op_type()==UVM_PRINT && op.get_policy()==expected_policy;
      enabled_on_entry &= op.user_hook_enabled();
      if (suppress) op.disable_user_hook();
    endfunction
    virtual function void do_print(uvm_printer printer);
      trace={trace,"P"}; printer.print_field_int("payload61",61,8,UVM_HEX);
    endfunction
    virtual function string get_type_name(); return "printable61"; endfunction
    virtual function uvm_object create(string name="");
      printable result;
      result=new(); result.set_name(name); return result;
    endfunction
  endclass
  initial begin
    printable value;
    capture_printer policy;
    string rendered;
    value=new(); policy=new(); value.expected_policy=policy;
    rendered=value.sprint(policy);
    $display("UT: print_suppressed field_only %0d no_user_field %0d policy %0d",
      value.trace=="E",policy.fields==0,value.correct_operation);
    value.trace=""; value.suppress=0; rendered=value.sprint(policy);
    $display("UT: print_restored order %0d current_value %0d enabled %0d emitted %0d",
      value.trace=="EP",policy.fields==1 && policy.last_value==61,
      value.enabled_on_entry,rendered=="original_format61");
    $finish;
  end
  initial begin #100; $fatal(1,"base hook fixture watchdog expired"); end
endmodule
