/*
:name: test_config_waiters_with_same_path_and_field_are_isolated_by_value_type
:description: An int and a string waiter on the same key wake for their own typed setting (IEEE 1800.2-2020 Section C.4.2.2.4)
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.2.4 C.4.2.2.1 C.4.2.2.2 C.4.2.1 1800-2023 9.3.2
:uvm: 2020.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_config_waiters_with_same_path_and_field_are_isolated_by_value_type.expected
*/
// Start both waiters before writing. A wrong-scope int write wakes neither. A
// string write must wake only the string waiter and an int write must wake
// the remaining waiter. Read the typed values at wakeup and recheck them
// after both writes. Positive delays separate each observation from the
// active updates.

module test_config_waiters_with_same_path_and_field_are_isolated_by_value_type;
  import uvm_pkg::*;
  bit saw_number, saw_text;
  int number;
  string label_value;

  initial begin
    fork
      begin
        uvm_config_db#(int)::wait_modified(null, "env.left", "setting");
        saw_number = 1;
        if (!uvm_config_db#(int)::get(null, "env.left", "setting", number))
          $fatal(1, "int waiter returned before its setting existed");
      end
      begin
        uvm_config_db#(string)::wait_modified(null, "env.left", "setting");
        saw_text = 1;
        if (!uvm_config_db#(string)::get(null, "env.left", "setting", label_value))
          $fatal(1, "string waiter returned before its setting existed");
      end
    join_none
    #1;
    uvm_config_db#(int)::set(null, "env.right", "setting", 19);
    #1;
    $display("UT: wrong scope %0d %0d", saw_number, saw_text);
    uvm_config_db#(string)::set(null, "env.left", "setting", "blue");
    #1;
    $display("UT: string only %0d %0d value %s", saw_number, saw_text, label_value);
    uvm_config_db#(int)::set(null, "env.left", "setting", 73);
    #1;
    $display("UT: both %0d %0d values %0d %s", saw_number, saw_text, number, label_value);
    $finish;
  end
endmodule
