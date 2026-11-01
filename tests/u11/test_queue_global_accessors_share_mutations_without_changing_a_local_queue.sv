/*
:name: test_queue_global_accessors_share_mutations_without_changing_a_local_queue
:description: global queue access shares one queue while a local queue retains independent entries (IEEE 1800.2-2020 Section 11.3.2.2)
:tags: u11 uvm
:type: simulation
:lrm: 1800.2-2020 11.3.2.2 11.3.2.3 11.3.2.4 11.3.2.5 11.3.2.7 11.3.2.10 11.3.2.11 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_queue_global_accessors_share_mutations_without_changing_a_local_queue.expected
*/
module test_queue_global_accessors_share_mutations_without_changing_a_local_queue;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  typedef bit [31:0] word_t;
  class warning_probe extends uvm_report_catcher;
    int warnings = 0;
    function new(); super.new("probe"); endfunction
    virtual function action_e catch();
      if (get_severity() == UVM_WARNING) begin warnings++; return CAUGHT; end
      return THROW;
    endfunction
  endclass

  initial begin
    uvm_queue#(word_t) first;
    uvm_queue#(word_t) second;
    automatic uvm_queue#(word_t) local_queue = new("local_queue");
    word_t value;
    first = uvm_queue#(word_t)::get_global_queue();
    second = uvm_queue#(word_t)::get_global_queue();
    first.push_back(42); second.push_front(73); local_queue.push_back(91);
    value = uvm_queue#(word_t)::get_global(1);
    $display("UT: singleton %0d front %0d second %0d size %0d", first == second,
             first.get(0), value, second.size());
    first.delete(0);
    $display("UT: delete shared %0d size %0d local %0d", second.get(0), second.size(),
        local_queue.get(0));
    second.delete();
    $display("UT: cleared shared %0d local_size %0d", first.size(), local_queue.size());
    $finish;
  end

endmodule
