/*
:name: test_copier_history_is_ordered_and_policy_local
:description: copier history distinguishes reversed pairs and separate policy instances (IEEE 1800.2-2020 Section 16.6.4.2)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.6.4.2 16.6.4.1
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_copier_history_is_ordered_and_policy_local.expected
*/
// Copy one ordered pair with one copier. The reverse pair and another
// copier have never performed that operation, even with the same objects.

module test_copier_history_is_ordered_and_policy_local;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class copy_probe extends uvm_object;
    `uvm_object_utils(copy_probe)
    int value = 0;
    uvm_copier selected;
    bit started_in_hook = 0;
    function new(string name="copy_probe"); super.new(name); endfunction
    function void do_copy(uvm_object rhs);
      copy_probe source;
      super.do_copy(rhs);
      if (!$cast(source, rhs)) $fatal(1, "unexpected copy type");
      if (selected != null)
        started_in_hook = selected.object_copied(this, rhs,
            selected.get_recursion_policy()) == uvm_policy::STARTED;
      value = source.value;
    endfunction
  endclass

  initial begin
    automatic copy_probe source = new("source");
    automatic copy_probe target = new("target");
    automatic uvm_copier first = new;
    automatic uvm_copier second = new;
    source.value = 23;
    first.copy_object(target, source);
    $display("UT: forward finished %0d reverse never %0d",
             first.object_copied(target, source, first.get_recursion_policy())
                 == uvm_policy::FINISHED,
             first.object_copied(source, target, first.get_recursion_policy())
                 == uvm_policy::NEVER);
    $display("UT: other policy never %0d target value %0d",
             second.object_copied(target, source, second.get_recursion_policy())
                 == uvm_policy::NEVER, target.value);
    $finish;
  end
endmodule
