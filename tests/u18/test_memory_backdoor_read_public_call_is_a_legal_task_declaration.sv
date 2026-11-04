/*
:name: test_memory_backdoor_read_public_call_is_a_legal_task_declaration
:description: The printed public memory backdoor read task permits a call from an external task body
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.7.10 1800-2023 6.21 8.18
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_backdoor_read_public_call_is_a_legal_task_declaration.expected
*/
// Legal compile-surface probe only. The task body is statically checked but
// never executed: it asserts public accessibility, not a physical transfer.
module test_memory_backdoor_read_public_call_is_a_legal_task_declaration;
  import uvm_pkg::*;
  task public_access(uvm_mem memory,uvm_reg_item operation);
    memory.backdoor_read(operation);
  endtask
  initial begin
    $display("UT: public_read_task declaration_legal 1");
    $finish;
  end
endmodule
