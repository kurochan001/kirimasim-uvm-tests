/*
:name: test_phase_get_schedule_printed_string_return_is_accepted_by_a_typed_string_receiver
:description: phase get schedule printed string return is accepted by a typed string receiver
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.6.4 9.3.1.6.1 9.3.1.4.4 9.3.1.3.1 1800-2023 6.21 8.20 8.21 13.4 20.6.1
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_phase_get_schedule_printed_string_return_is_accepted_by_a_typed_string_receiver.expected
*/
// Qualified printed string return, not the prose parent-node return type.
module test_phase_get_schedule_printed_string_return_is_accepted_by_a_typed_string_receiver;
  import uvm_pkg::*;
  class task_imp extends uvm_task_phase;
    static task_imp singleton;
    function new(string name="singleton53");super.new(name);endfunction
    static function task_imp get();
      if (singleton==null) singleton=new();return singleton;
    endfunction
    virtual task exec_task(uvm_component comp,uvm_phase phase);endtask
  endclass

  int receiver_calls=0;
  function automatic void accepts_string(string value);receiver_calls++;endfunction
  initial begin
    automatic uvm_phase schedule=new("schedule53",UVM_PHASE_SCHEDULE);
    automatic task_imp imp=task_imp::get();
    uvm_phase node;
    schedule.add(imp);node=schedule.find(imp);
    accepts_string(node.get_schedule());
    $display("UT: phase_schedule_declaration declared_string %0d string_receiver_calls %0d",
      $typename(node.get_schedule())=="string",receiver_calls);
    $finish;
  end
endmodule
